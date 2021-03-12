/**
 	*@author
 	*@description Test class for TaskTrigger
 	*/
@isTest
public class TaskTrigger_Test {
    
    public static Map<String, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Case.getRecordTypeInfosByName();
    
    @isTest(SeeAllData=true)
    static void createTask(){
        
        Id userId = userInfo.getUserId();
        Case testCase1 = new Case(Type='Enhancement', 
                                  Related_System__c = 'Other', 
                                  Related_Case_Number__c = '35546',
                                  Origin = 'Ask HR', 
                                  //RecordTypeId=rtMap.get('Function').getRecordTypeId());
                                  RecordTypeId=rtMap.get(ASKHR_Common.CASE_RECORD_TYPE_NAME_FUNCTION).getRecordTypeId());
        testCase1.OwnerId = userId;
        insert testCase1;
        Account testacct = new Account(Name = 'ApexTaskTest');
        insert testacct;
        
        Task testTask = new Task(); 
        testTask.WhatId=testacct.Id;
        testTask.OwnerId=userId;
        testTask.Subject='Task Test';
        testTask.ActivityDate= date.today();
        testTask.Description='TEST RECORD!';
        testTask.Status = 'Completed';
        insert testTask;
        
        Task testTask1 = new Task(); 
        testTask1.WhatId=testacct.Id;
        testTask1.OwnerId=userId;
        testTask1.Subject='Task Test';
        testTask1.ActivityDate= date.today();
        testTask1.Description='TEST RECORD!';
        testTask1.Status = 'Completed';
        insert testTask1;
        
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        Id csrProfileId = [Select Id from Profile where Name = 'CSR'].Id;
        system.debug('csrProfileId'+String.valueOf(csrProfileId).substring(0, 15));
        System.runAs (thisUser) {
            
            delete testTask;
            User testUser1 = new User(FirstName='tst',LastName='testuser1',email='test.user1@manulife.com', employee_Id__c = 'tstuser1testing',Pay_Country__c='CAN',LanguageLocaleKey='en_US',profileId = csrProfileId); 
            
            // Insert account as current user
            
            insert testUser1;           
            system.runAs(testUser1){
                //delete testTask;
                
                try{
                    
                    delete testTask1;
                    //System.assert(false);
                }catch(DMLException e){
                    
                }
            }
        }
    }
    
}