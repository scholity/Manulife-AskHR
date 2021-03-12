public without sharing class ASKHR_ContactUpdaterScheduledDispatcher 
    extends ASKHR_ScheduledDispatcherBase {
        
    protected override string GetScheduleDispatcheeTypeName()
    {
        return 'ASKHR_ContactBulkUpdaterBatchDispatcher'; 
    }

}