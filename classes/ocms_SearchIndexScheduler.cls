global without sharing class ocms_SearchIndexScheduler implements Schedulable{
	private class SearchSchedulerException extends Exception {}

	private Boolean rebuild {get; set;}
	private String jobName {get; set;}
	private Boolean isContinuation {get; set;}
	private String rebuildId {get; set;}

	List<Database.Batchable<sObject>> batchJobs;

	global ocms_SearchIndexScheduler()
	{
		this.jobName = 'OCMS Search Indexer';
		this.rebuild = false;
		this.batchJobs = new List<Database.Batchable<sObject>>();
		this.isContinuation = false;
	}

	global ocms_SearchIndexScheduler(String jobName, Boolean rebuild)
	{
		this.jobName = jobName;
		this.rebuild = rebuild;
		this.batchJobs = new List<Database.Batchable<sObject>>();
		this.isContinuation = false;
	}

	global static void schedule(String jobName, Boolean rebuild)
	{
		schedule(jobName, rebuild, Datetime.now());
	}

	global static void schedule(String jobName, Boolean rebuild, Datetime nextRun)
	{
		String newExpression = '0 ' + nextRun.minute() + ' ' + nextRun.hour() + ' * * ?';

		System.schedule(jobName, newExpression, new ocms_SearchIndexScheduler(jobName, false));
	}

	private void reschedule(String jobName, Datetime nextRun)
	{
		String newExpression = nextRun.second() + ' ' + nextRun.minute() + ' ' + nextRun.hour() + ' * * ?';

		System.schedule(jobName, newExpression, this);
	}

	global static void execute()
	{
		ocms_SearchIndexScheduler sch = new ocms_SearchIndexScheduler();
		sch.execute(null);
	}

	global void execute(SchedulableContext SC)
	{
		Datetime now = Datetime.now();

		if(SC != null && SC.getTriggerId() != null) {
			System.abortJob(SC.getTriggerId());
		}

		if(this.rebuildId != null)
		{
			AsyncApexJob rebuildJob = [SELECT Status FROM AsyncApexJob WHERE Id=:rebuildId];
			if(rebuildJob.Status != 'Completed') {
				reschedule(this.jobName, now.addMinutes(5));
				System.debug('Waiting 5 minutes for batch cleanup to complete');
				return;
			}

			this.rebuildId = null;
			System.debug('Batch cleanup complete');
		}

		if(!this.isContinuation) {
			ocms_Search_Index_Settings__c[] settings = [
				SELECT Name, Last_Index_Date__c, URL_Rewriting_Enabled__c, Site_Prefix__c, Use_Revision_Origin_Dates__c
				FROM ocms_Search_Index_Settings__c
			];

			if (this.rebuild == true)  // rebuild the index
			{
				ocms_SearchCleanup job = new ocms_SearchCleanup(DateTime.now());
				this.rebuildId = Database.executeBatch(job, 5000);

				this.rebuild = false;

				for(ocms_Search_Index_Settings__c setting : settings) {
					setting.Last_Index_Date__c = null;
				}
				update settings;

				reschedule(this.jobName, now.addMinutes(5));
				System.debug('Waiting 5 minutes for batch cleanup to complete');
				return;
			}

			for(ocms_Search_Index_Settings__c setting : settings) {
				executeContentIndex(setting);
				executePageIndex(setting);

				setting.Last_Index_Date__c = now;
			}

			update settings;

			schedule(this.jobName, false, now.addMinutes(15));
		}

		Integer jobCount = [SELECT count() FROM AsyncApexJob WHERE JobType='BatchApex' AND (Status = 'Processing' OR Status = 'Preparing' OR Status = 'Queued')];

		System.debug(batchJobs.size() + ' indexing jobs pending, ' + jobCount + ' existing jobs in process.');

		for(Integer i = jobCount; i < 5; ++i) {
			executeJob();
		}

		if(batchJobs.size() > 0) {
			this.isContinuation = true;
			reschedule(this.jobName + ' - Continuation', now.addSeconds(30));
		}
	}

	private void executeContentIndex(ocms_Search_Index_Settings__c setting) {
		ocms_SearchIndexExecutor sie = new ocms_SearchIndexExecutor(
			new Map<String, String> {
				'sname' => setting.Name,
				'page_mode' => 'production'
			}, false, setting
		);

		batchJobs.add(sie);
	}

	private void executePageIndex(ocms_Search_Index_Settings__c setting) {
		for(cms__Language__c l : [SELECT cms__Language_Code__c from cms__Language__c WHERE cms__Sites__r.cms__Site_Name__c = :setting.Name]) {
			ocms_SearchIndexPageExecutor sipe = new ocms_SearchIndexPageExecutor(
				new Map<String, String> {
					'sname' => setting.Name,
					'page_mode' => 'production',
					'ocmsLang' => l.cms__Language_Code__c
				}, false, setting
			);

			batchJobs.add(sipe);
		}
	}

	private Boolean executeJob() {
		if(batchJobs.size() == 0) return false;

		Database.Batchable<sObject> job = batchJobs.remove(0);
		Database.executeBatch(job, 50);

		return true;
	}
}