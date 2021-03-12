/**
	 *@author
	 *@description this class is used for job scheduling
	 */
public abstract without sharing class ASKHR_BatchSchedulerBase {
    
    protected abstract string GetJobName();
    protected abstract string GetBatchClassName();
    protected abstract string GetScheduleTime();
    protected abstract Schedulable GetSchedulableObject();  
    protected abstract boolean IsScheduleStarted();
    protected abstract void ScheduleStarted();
    protected abstract boolean CancelPendingJobs();
    protected abstract boolean AllowReschedule();
    
    /**
	 * @description this method is used to start the scheduler
	 */
    public void StartScheduler()
    {
        // Consider putting a static variable gate here so the method is only called
        // once per execution context (like StartBatch)
        System.Debug('Checking if Schedule was already started in this context.');
        if(!IsScheduleStarted() || AllowReschedule())
        {
            // Is the job already running?
            List<CronTrigger> jobs = GetActiveJobInstances();
                                       
            System.Debug('Batch has not been scheduled in this context, checking if it is in the Schedule');
            if(IsScheduled(jobs) && AllowReschedule())
            {
                
                System.Debug('Checking of job is actually running.');
                // It's already running - Is the batch running?
                if(IsJobRunning()) return;  // The batch is running
    
                System.Debug('Checking of job set to run in 30 seconds.');
                
                // If we're going to run soon, exit
                if(DateTime.Now().AddSeconds(30) > jobs[0].NextFireTime) return;
                
                System.Debug('Checking of pending job should be cancelled, and replaced by this one.');
                // check if scheduled jobs should be aborted, and rescheduled.
                if(CancelPendingJobs())
                {
                    System.Debug('Cancelling pending jobs.');
                    CancelJobs(jobs);       
                    
                    System.Debug('Scheduling job again after being cancelled.');
                    ScheduleJob();                                         
                }
                else
                {
                    System.Debug('Do not cancel any pending job(s) let them run, this request to be scheduled will be cancelled.');
                    return; // job is already scheduled, don't do anything.
                }
                
            }
            else
            {
                System.Debug('Checking if job is not running, and reschedule is allowed, if so scheduling again.');
                if(!IsJobRunning() && AllowReschedule())
                {
                     // Make sure there aren't any inactive jobs with the same name. If so, abort them
                    // Need to do this because an exception will occur if attempting to schedule something with the same name.
                    System.Debug('Cancelling inactive job instances.');
                    CancelJobs(GetInactiveJobInstances());
                    
                    System.Debug('Scheduling the job');
                    ScheduleJob();               
                }   
            }
                             
        }
    }
    
    /**
	 *@description this method is used to check whether job is running or not
	 *@return boolean
	 */
    protected boolean IsJobRunning()
    {
        // It's already running - Is the batch running?
        Set<String> activejobstates = new Set<String>{'Queued','Processing','Preparing'};
        List<AsyncApexJob> apexjobs = [Select ID, ApexClass.Name from AsyncApexJob 
                                       where ApexClass.Name = :GetBatchClassName() And Status in :activejobstates];
                                       
        if(apexjobs.size()>0) 
        {
            System.Debug('Job is still running');
            return true;  // The batch is running
        }
        else
        {
            System.Debug('Job is not running');
            return false;
        }
    }
    
    /**
 	*@description this method is used to get the list of active jobs
	*@return List<Id> return list of active job ids
	*/
    public List<Id> GetActiveJobIds()
    {
        List<CronTrigger> jobs = GetActiveJobInstances();
        List<Id> jobIds = new List<Id>();
        for(CronTrigger job :jobs)
        {
            jobIds.Add(job.Id);
        }
        return jobIds;
    }
    
     /**
	 *@description this method is used to retrieve next fire time of the job
	 *@return DateTime
	 */

    public DateTime NextFireDateTime()
    {
         List<CronTrigger> jobs = GetActiveJobInstances();
         if(IsScheduled(jobs))
         {
            return jobs[0].NextFireTime;
         }
         else
         {
            return null;
         }
    }
    
     /**
	 *@description this method is used to abort the job
	 *@return DateTime
	 */
    private void CancelJobs(List<CronTrigger> jobs)
    {
        for(CronTrigger job :jobs)
        {
            system.abortJob(job.Id);
        }
            
    }
 
	/**
	 *@description this method is used to retrieve the active job instances
	 *@return List<CronTrigger> returns list of active job instances
	 */  
    private List<CronTrigger> GetActiveJobInstances()
    {
        Set<String> inactiveScheduleStates = new Set<String>{'COMPLETED','ERROR','DELETED'};
            
        List<CronTrigger> jobs = [SELECT Id, CronJobDetail.Name, State, NextFireTime
                                      FROM CronTrigger where CronJobDetail.Name=:GetJobName() And State not in :inactiveScheduleStates];
        
        return jobs;
    }
	/**
	 *@description this method is used to retrieve the inactive job instances
	 *@return List<CronTrigger> returns list of inactive job instances
	 */    
    private List<CronTrigger> GetInactiveJobInstances()
    {
        // Get jobs that are not active, and are not scheduled to run.
        Set<String> inactiveScheduleStates = new Set<String>{'COMPLETED','ERROR','DELETED'};
            
        List<CronTrigger> jobs = [SELECT Id, CronJobDetail.Name, State, NextFireTime
                                      FROM CronTrigger where CronJobDetail.Name=:GetJobName() And NextFireTime = null And State in :inactiveScheduleStates];
        
        return jobs;
    }
    
    /**
	 *@description this method is used to check the active jobs are in scheduele
	 *@return boolean
	 */
    public boolean IsScheduled()
    {
        return IsScheduled(GetActiveJobInstances());
    }
    
     /**
	 *@description this method is used to check the given job is in scheduele
	 *@return boolean
	 */
    private boolean IsScheduled(List<CronTrigger> jobs)
    {
        boolean result=false;       
        
        if(jobs.size() > 0)
        {
            result=true;
        }
        return result;      
    }
    /**
	*@description this method is used to schedule a job
	*/    
    private void ScheduleJob()
    {
        try
            {
                System.schedule(GetJobName(), 
                                GetScheduleTime(), 
                                GetSchedulableObject());
                                
                ScheduleStarted();
                
            } catch(Exception ex){}
    }
    
}