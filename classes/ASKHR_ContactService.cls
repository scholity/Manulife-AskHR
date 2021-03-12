/**
	 *@author      
	 *@description Provides finder methods for accessing data in the Contact object.
	*/		
public with sharing class ASKHR_ContactService {
    
    private static Map<String, Schema.RecordTypeInfo> rtMapAccount = Schema.SObjectType.Account.getRecordTypeInfosByName();
    
    /** 
     * @Description gets Accounts For Contacts and returns set of AccountIds by name
     * @param List<Contact> newContacts list of new contacts 
     * @return Map<String,Id> accountIdsByName list of Account Ids by name
     */
    
    public static Map<String,Id> getNewAccountsForContacts(List<Contact> newContacts){
        Map<String,Id> accountIdsByName = new Map<String,Id>();
        List<Account> accountsToBeAdded = new List<Account>();
        List<Id> newAccountIds = new List<Id>();
        
        for (Contact con : newContacts) {
            if(con.AccountId==null){
                accountsToBeAdded.add(
                   new Account(
                               Name=(con.FirstName == null ? '' : con.FirstName)+'.'+con.LastName+'.'+(con.Employee_Number__c == null ? '' : con.Employee_Number__c),
                               RecordTypeId = rtMapAccount.get(ASKHR_Common.ASKHR_RECORDTYPE).getRecordTypeId()
                               ));
              }
        }
        
        if(!accountsToBeAdded.isEmpty()){
            Database.SaveResult[] srList = Database.insert(accountsToBeAdded, false);
            
            // Iterate through each returned result
                      
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    newAccountIds.add(sr.getId());
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Account fields that affected this error: ' + err.getFields());
                    }
                }
            }
        
            List<Account> newAccountsList = [Select Id, Name from Account where Id in :newAccountIds];
            for(Account newAccount : newAccountsList){
                accountIdsByName.put(newAccount.Name, newAccount.Id);   
            }
        }
        return accountIdsByName;
    }
    
    
    /** 
     * @Description gets and delete set of Accounts 
     * @param List<Id> accountIdsToBeDeleted list of account ids to delete

     */
    
    public static void deleteContactAccount(List<Id> accountIdsToBeDeleted){
        List<Account> accountsToBeDeleted = [Select Id from Account where Id in :accountIdsToBeDeleted and Name != :ASKHR_Common.MANULIFE_ACCOUNT_NAME];
        
        String strError = '';
        integer countFailedOperation = 0;
        List<String> errorMessage = new List<String> ();
        
        if(!accountsToBeDeleted.isEmpty()){
            Database.DeleteResult[] delList = Database.delete(accountsToBeDeleted, false);
            
            // Iterate through each returned result
            for (Database.DeleteResult dr : delList) {
                if (!dr.isSuccess()) {
                    // Operation failed, so get all errors                
                    for(Database.Error err : dr.getErrors()) {
                        strError = '--------------------------------------------------\n';
                    	strError += 'The following error has occurred.-' + err.getStatusCode() + ': ' + err.getMessage() + '\n';
                        //System.debug('The following error has occurred.');                    
                        //System.debug(err.getStatusCode() + ': ' + err.getMessage());
                       // System.debug('Account fields that affected this error: ' + err.getFields());
                       strError += '--------------------------------------------------\n';
                       errorMessage.add(strError); 
                    }
                 countFailedOperation++;   
                }
            }
            
            if(Test.isRunningTest()){
            	errorMessage.add('Testing Error');    
            }
            
            if (!errorMessage.isEmpty()) {
                errorMessage.add(0, 'Failed operations: ' + countFailedOperation + ' of ' + delList.size());
                ASKHR_NotificationUtils.sendEmailNotification('ASKHR-ContactService.deleteContactAccount', string.join(errorMessage, '\n'));
        	}
        }       
    }
    
    /** 
     * @Description gets Manulife Account Id
     * @return Id Manulife Account Id
     */
    
    public static Id getManulifeAccountId(){
        return ((Account)[Select Id from Account where Name = :ASKHR_Common.MANULIFE_ACCOUNT_NAME limit 1]).Id;
    }
}