/**
*@description Contact Bulk Updater Batch Job
*/
global without sharing class ASKHR_ContactBulkUpdaterBatchJob implements Database.Batchable<sObject> {
    // TEST VARIABLES
    //global static boolean GENERATE_TASK_ON_TEST = false;
    //global static ID ACCOUNT_OWNER_ID;  // Needed for running tests because we have to limit the number of Execute calls are made during a  test process.

    private final string QUERY;

    global ASKHR_ContactBulkUpdaterBatchJob()
    {
        QUERY = 'SELECT Id, Name, Employee_Number__c, Manager_Employee_Number__c, ReportsToId, Reports_To_Requires_Resync__c FROM Contact WHERE Reports_To_Requires_Resync__c = true AND RecordType.Name = \'' + ASKHR_Common.ASKHR_RECORDTYPE + '\'';
    }

    global Database.Querylocator Start(Database.BatchableContext bc)
    {
        System.Debug('Starting ASKHR_ContactBulkUpdaterBatchJob');
        return Database.getQueryLocator(QUERY);
    }

    global void Execute(Database.BatchableContext bc, List<Contact> scope)
    {
        /*
            Potential room for improvement.
            Update main query to only grab Contacts that require resync.
            In Execute stage, do another query to capture all the actual Managers (Contacts)
            SELECT Id, Employee_Number__c FROM Contact WHERE Employee_Number__c in :Manager_Employee_Numbers
            This way, we're working with data that we need to, instead of grabbing everything.
        */
        
        System.Debug('Reviewing ' + scope.size() + ' Contacts');
        
        boolean IsUpdate = false;               
        Map<string, Contact> contactPool = new Map<string, Contact>();
        
        List<Contact> contactsToUpdate = new List<Contact>();
        List<Contact> managersToBeUsed;
        Set<String> managerEmployeeNumbers = new Set<String>();
        
        
        //Build a list of Manager Employee Numbers.
        for(SObject s : scope)
        {
            Contact c = (Contact)s;
            managerEmployeeNumbers.add(c.Manager_Employee_Number__c);           
            contactPool.put(c.Employee_Number__c, c);
        }
        
        // Get all the managers referenced in this run.
        managersToBeUsed = [SELECT Id, Name, Employee_Number__c, Manager_Employee_Number__c, ReportsToId, Reports_To_Requires_Resync__c FROM Contact WHERE Employee_Number__c = :managerEmployeeNumbers AND RecordType.Name = :ASKHR_Common.ASKHR_RECORDTYPE];
        
        
        //Put managers in Map collection for object reference
        for(Contact  m : managersToBeUsed) {                        
            contactPool.put(m.Employee_Number__c, m);           
        }

        //Update the ReportsTo field
        for(Contact contact : contactPool.values())
        {           
            if(contact.Reports_To_Requires_Resync__c == true) 
            {
                Contact manager = contactPool.get(contact.Manager_Employee_Number__c);
                if(manager != null)
                {
                    //Ensure the manager does not report to this contact (CIRCULAR REFERENCE).
                    if(manager.ReportsToId != contact.Id && contact.Id != manager.Id)
                    {
                        contact.ReportsToId = manager.Id;
                    }
                    else
                    {
                        System.Debug('Circular reference detected between Contacts ' + manager.Employee_Number__c + ' and ' + contact.Employee_Number__c);
                        contact.ReportsToId = null;                     
                    }   
                    
                }
                else
                {
                    System.Debug('Cannot find Manager for Contact (' + contact.Employee_Number__c + ') using Manager Employee Number: ' + contact.Manager_Employee_Number__c + ' clearing Manager Report To.');
                    contact.ReportsToId = null;
                    //contact.Manager_Employee_Number__c = null;
                }
                contactsToUpdate.add(contact);
            }
        }
        if(contactsToUpdate.size() > 0){            
            update contactsToUpdate;
        }
    }

    global void Finish(Database.BatchableContext bc)
    {
        System.debug('Job Finished');
    }
}