public without sharing class ASKHR_ContactBulkUpdaterBatchDispatcher implements ASKHR_ScheduledDispatcherBase.IScheduleDispatchee {
    
    
    private static Boolean m_BatchRequested = false; 
   
    public void execute(SchedulableContext sc)
    {
        StartBatch();
        //system.abortJob(sc.getTriggerID()); // Always abort the job on completion
    }
    
    
    public static void StartBatch()
    {
        if(m_BatchRequested) return;
                
        ASKHR_ContactBulkUpdaterBatchJob tcj = new ASKHR_ContactBulkUpdaterBatchJob();      
        Database.executeBatch(tcj);
        
        m_BatchRequested = true;
    }

}