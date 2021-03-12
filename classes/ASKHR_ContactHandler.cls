/**
 * Class ASKHR_ContactHandler
 *
 * Trigger Handler for the Contact SObject. This class implements the ITrigger
 * interface to help ensure the trigger code is bulkified and all in one place.
 */
public with sharing class ASKHR_ContactHandler
    implements ITrigger
{
    //Member variables
    private Id m_ManulifeAccountId;
    private Map<String,Id> m_accountIdsByName = new Map<String,Id>();
    private List<Id> m_accountIdsToBeDeleted = new List<Id>();

    //Constructor
    public ASKHR_ContactHandler()
    {
    }

    /**
     * bulkBefore
     *
     * This method is called prior to execution of a BEFORE trigger. Use this to cache
     * any data required into maps prior execution of the trigger.
     */
    public void bulkBefore()
    {
        if(Trigger.isInsert) {
            m_ManulifeAccountId = ASKHR_ContactService.getManulifeAccountId();
            m_accountIdsByName = ASKHR_ContactService.getNewAccountsForContacts(Trigger.New);
        }
    }

    public void bulkAfter()
    {
         
        if(Trigger.isDelete) return; //If deleting a contact, do not perform resync, SF will clear ReportsTo for us.
         
        // If there any new Contacts, or Updated ones that Require the ReportsTo to be resynchronized
        // schedule the job.
        Integer recordFound = [SELECT COUNT() FROM Contact WHERE Reports_To_Requires_Resync__c = True AND RecordType.Name = :ASKHR_Common.ASKHR_RECORDTYPE AND Id = :Trigger.New LIMIT 1]; 
        if(recordFound > 0)
        {
             ASKHR_ContactBulkUpdaterBatchScheduler schedule = new ASKHR_ContactBulkUpdaterBatchScheduler();
             schedule.StartScheduler();
        }       
    }

    public void beforeInsert(SObject so)
    {
        Contact con = (Contact)so;
        Id accountId = m_accountIdsByName.get((con.FirstName == null ? '' : con.FirstName) + '.' + con.LastName + '.' + (con.Employee_Number__c == null ? '' : con.Employee_Number__c));
        if(accountId != null) {
            con.AccountId = accountId;
        }
        else {
            con.AccountId = m_ManulifeAccountId;
        }
    }

    public void beforeUpdate(SObject oldSo, SObject so)
    {
    }

    public void beforeDelete(SObject so)
    {
    }

    public void afterInsert(SObject so)
    {
        
    }

    public void afterUpdate(SObject oldSo, SObject so)
    {

    }

    public void afterDelete(SObject so)
    {
        Contact con = (Contact)so;
        m_accountIdsToBeDeleted.add(con.AccountId);
    }

    /**
     * andFinally
     *
     * This method is called once all records have been processed by the trigger. Use this
     * method to accomplish any final operations such as creation or updates of other records.
     */
    public void andFinally()
    {
        if(!m_accountIdsToBeDeleted.isEmpty()) {
            ASKHR_ContactService.deleteContactAccount(m_accountIdsToBeDeleted);
        }
    }
}