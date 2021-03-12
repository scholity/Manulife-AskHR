public with sharing class ocms_WeatherFeedSchedulable implements Schedulable {
	private String jobName;

	public ocms_WeatherFeedSchedulable() {
		jobName = 'Weather Current Conditions Update';
	}

	public ocms_WeatherFeedSchedulable(String jobName) {
		this.jobName = jobName;
	}

	public void execute(SchedulableContext sc) {
		//updateCityLocationKeys(); // temporarily disabled due to switch to open weather
		fetchCurrentConditions();

		// Remove current job
		if(sc != null) {
			String cronid = sc.getTriggerId();

			System.abortJob(cronid); //abort scheduled job
		}

		// Fetch interval - default 30
		Integer interval = 30;
		try {
			Weather_Settings__c settings = [select Refresh_Frequency__c from Weather_Settings__c limit 1];

			interval = (Integer)settings.Refresh_Frequency__c;
		} catch(Exception e) {
			interval = 30;
		}

		// Get next time to run
		Datetime now = System.now();
		Datetime nextRun = now.addMinutes(interval);

		String newExpression = '0 ' + nextRun.minute() + ' ' + nextRun.hour() + ' * * ?';

		ocms_WeatherFeedSchedulable weatherUpdater = new ocms_WeatherFeedSchedulable(jobName);
		System.schedule(jobName, newExpression, weatherUpdater);
	}

	@future(callout=true)
	public static void updateCityLocationKeys() {
		ocms_WeatherFeedCurrent feed = new ocms_WeatherFeedCurrent();
		feed.resolveCityNames();
	}

	@future(callout=true)
	public static void fetchCurrentConditions() {
		ocms_WeatherFeedCurrent feed = new ocms_WeatherFeedCurrent();
		feed.fetchCurrentConditions();
	}
}