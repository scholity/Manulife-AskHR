public virtual without sharing class ASKHR_ContactBulkUpdaterBatchScheduler extends ASKHR_BatchSchedulerBase {
    
    public static boolean m_ScheduleStarted = false; 
    private static datetime m_DateTimeScheduled;
    
    private final integer m_defaultRescheduleThresholdInMinutes = 5;    
    private final integer m_defaultWaitTimeInMinutes = 30;
    
    protected virtual override string GetJobName()
    {
        return 'ContactBulkUpdaterBatchJob';
    }
    
    protected override string GetBatchClassName()
    {
        return 'ASKHR_ContactBulkUpdaterBatchJob';
    }
    
    private integer RescheduleThresholdTime()
    {
        integer thresholdTime;
        
        Contact_Reports_To_Resync_Wait_Time__c waitTime = Contact_Reports_To_Resync_Wait_Time__c.getInstance('Default');
        if(waitTime == null || waitTime.Reschedule_Threshold_Time__c == 0)
        {
            thresholdTime =  m_defaultRescheduleThresholdInMinutes;
        }
        else
        {
            thresholdTime =  (integer)waitTime.Reschedule_Threshold_Time__c;
        }
        return thresholdTime;
    }
    
    private integer WaitTime()
    {
        integer retVal;
        
        // Get value from custom setting, if it doesn't exist then use default.
        Contact_Reports_To_Resync_Wait_Time__c waitTime = Contact_Reports_To_Resync_Wait_Time__c.getInstance('Default');
        if(waitTime == null || waitTime.Resync_Wait_Time__c == 0)
        {
            retVal =  m_defaultWaitTimeInMinutes;
        }
        else
        {
            retVal = (integer)waitTime.Resync_Wait_Time__c;
        }
        return retVal;
    }
    
    private datetime DateTimeScheduled()
    {
        if(m_DateTimeScheduled == null)
        {
            m_DateTimeScheduled = NextFireDateTime();
        }

        return m_DateTimeScheduled;
    }
    
    protected virtual override string GetScheduleTime()
    {
        // Usage: http://www.salesforce.com/us/developer/docs/apexcode/Content/apex_scheduler.htm
        // get current date
        DateTime timeToRun = DateTime.now();
        timeToRun = timeToRun.AddMinutes(WaitTime());
         
        String scheduleTime = '0 ' + timeToRun.Minute() + ' ' + timeToRun.Hour() + ' ' + timeToRun.Day() + ' ' + timeToRun.Month() + ' ? ' + timeToRun.Year();
        //System.Debug('Running Contact Updater Batch Coverage Job at: ' + scheduleTime); //Run 30 minit after scheduled, once.
        
        return scheduleTime;        
    }
    
    protected override boolean AllowReschedule()
    {
        //If we're being asked to reschedule, and
        //we're below the threshold time, then allow a reshedule
        //otherwise keep with original schedule.
        //This is for situations where there's a lot of activity, but
        //we do not want to constantly reschedule over and over again.
        //If request to schedule comes in, and we're close to scheduled time, then
        //reschedule.
        
        //If DateTimeScheduled is null, then job hasn't been scheduled yet.
        if(DateTimeScheduled() == null ) return true;
        
        if(DateTime.Now().AddMinutes(RescheduleThresholdTime()) >= DateTimeScheduled())
        {
            System.Debug('Allowing a Reschedule, Scheduled: ' + DateTimeScheduled() + ' Threshold :' + DateTime.Now().AddMinutes(RescheduleThresholdTime()));
            return true;
        }
        else
        {
            System.Debug('Not allowing a reschedule, Scheduled: ' + DateTimeScheduled() + ' Threshold :' + DateTime.Now().AddMinutes(RescheduleThresholdTime()));
            return false;
        }
    }
    
    protected override Schedulable GetSchedulableObject()
    {
        return new ASKHR_ContactUpdaterScheduledDispatcher();
    }   
    
    protected override boolean IsScheduleStarted()
    {
        return m_ScheduleStarted;
    }
    
    protected override void ScheduleStarted()
    {
        m_ScheduleStarted = true;
        m_DateTimeScheduled = DateTime.Now().AddMinutes(WaitTime());
    }
    
    protected virtual override boolean CancelPendingJobs()
    {
        return true;
    }

}