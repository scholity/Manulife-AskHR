public with sharing class ocms_StockFeedSchedulable implements Schedulable {
	private String jobName;

	public ocms_StockFeedSchedulable() {
		jobName = 'Stock Price Update';
	}

	public ocms_StockFeedSchedulable(String jobName) {
		this.jobName = jobName;
	}

	public void execute(SchedulableContext sc) {
		fetchCurrentPrices();

		// Remove current job
		if(sc != null) {
			String cronid = sc.getTriggerId();

			System.abortJob(cronid); //abort scheduled job
		}

		// Fetch interval - default 5
		Integer interval = 5;
		try {
			Stock_Feed_Settings__c settings = [select Refresh_Frequency__c from Stock_Feed_Settings__c limit 1];

			interval = (Integer)settings.Refresh_Frequency__c;
		} catch(Exception e) {
			interval = 5;
		}

		// Get next time to run
		Datetime now = System.now();
		Datetime nextRun = now.addMinutes(interval);

		String newExpression = '0 ' + nextRun.minute() + ' ' + nextRun.hour() + ' * * ?';

		ocms_StockFeedSchedulable stockFeedUpdater = new ocms_StockFeedSchedulable(jobName);
		System.schedule(jobName, newExpression, stockFeedUpdater);
	}

	@future(callout=true)
	public static void fetchCurrentPrices() {
		ocms_StockFeedUpdateCurrent currentFeeds = new ocms_StockFeedUpdateCurrent();
		currentFeeds.fetchAndStore();
	}
}