global class mfc_Batch_UpdateUserAttributes implements Database.Batchable<sObject> {

    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        return Database.getQueryLocator('SELECT Id,Country__c, Division__c, MFC_Country__c, MFC_Division__c FROM User WHERE MFC_Country__c = NULL OR MFC_Division__c = NULL' );
    }
    
    global void execute (Database.BatchableContext bc, list<sObject> users)
    {
        
        for(Object obj :users)
        {
            User u = (User)obj;
            mfc_UpdateUserAttributes.UpdateMFCAttributes(u);
        }
        update users;
    }
    
    global void finish(Database.BatchableContext bc){
        
    }
    
}