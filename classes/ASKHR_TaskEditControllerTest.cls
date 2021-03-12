/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
public class ASKHR_TaskEditControllerTest {
    public static Map<String, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Case.getRecordTypeInfosByName();
    
    public static Task createTestTask (Case testCase1)
    {
        Account testacct = new Account(Name = 'ApexTaskTest');
        insert testacct;
        
        Task testTask = new Task(); 
        testTask.WhatId=testacct.Id;
        testTask.OwnerId=testCase1.OwnerId;
        testTask.Subject='Task Test';
        testTask.ActivityDate= date.today();
        testTask.Description='TEST RECORD!';
        testTask.Status = 'Completed';
        insert testTask;
        
        return testTask;
    }
    
     public static List <Attachment> createAttactmentList(Id id, Id ownerId)
    {
        List <Attachment> taskattachmentList  = new List <Attachment> ();
        
        Attachment attachment = new Attachment();  
        attachment.ParentId = id;  
        attachment.Name = 'Test Attachment for Parent';  
        attachment.Body = Blob.valueOf('Test Task Data');  
        attachment.OwnerId = ownerId;
        taskattachmentList.add(attachment);
           
        return taskattachmentList;
    }

    
    @isTest(SeeAllData=true)   
    static void testTaskEditCore(){

        List<User> testUsers = new List<User>();
        Id csrProfileId = [Select Id from Profile where Name = 'CSR'].Id;
        User testUser1 = new User(FirstName='tst',LastName='testuser1',email='test.user1@manulife.com', employee_Id__c = 'tstuser1testing',Pay_Country__c='CAN',LanguageLocaleKey='en_US',profileId = csrProfileId); 
        testUsers.add(testUser1); 
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];

       // Insert account as current user
        System.runAs (thisUser) {
            insert testUsers;           
        }
             
       Case testCase1 = new Case(Type='Enhancement', 
                                     Related_System__c = 'Other', 
                                     Related_Case_Number__c = '35546',
                                     Origin = 'Ask HR', 
                                    //RecordTypeId=rtMap.get('Function').getRecordTypeId());
                                    RecordTypeId=rtMap.get(ASKHR_Common.CASE_RECORD_TYPE_NAME_FUNCTION).getRecordTypeId());
       testCase1.OwnerId = testUser1.Id;
       insert testCase1;
       
      
       Task testTask = createTestTask (testCase1);
       ApexPages.currentPage().getParameters().put('id', testTask.Id);
       ApexPages.StandardController testStandardController = new ApexPages.StandardController(testTask); 
       ASKHR_TaskEditController testController = new ASKHR_TaskEditController(testStandardController);
       Pagereference doSave = testController.doSave();
       testController.attachmentList = createAttactmentList(testTask.Id, testCase1.OwnerId);
       doSave = testController.doSave();
       
       Task testTask1 = createTestTask (testCase1);
       ApexPages.currentPage().getParameters().put('id', testTask1.Id);
       testStandardController = new ApexPages.StandardController(testTask1); 
       testController = new ASKHR_TaskEditController(testStandardController);
       Pagereference doSaveAndNew = testController.doSaveAndNew();
       testController.attachmentList = createAttactmentList(testTask.Id, testCase1.OwnerId);
       doSaveAndNew = testController.doSaveAndNew();
        
       Task[] testTaskVerify = [select id from task where OwnerId = :testCase1.OwnerId];
       Attachment[] testAttactmentVerfify = [select id from Attachment where OwnerId = :testCase1.OwnerId];
       System.assertEquals(testTaskVerify.size(), 2); 
       System.assertEquals(testAttactmentVerfify.size(), 2); 
       
       Pagereference processRemove = testController.processRemove();
       Pagereference processUpload = testController.processUpload();
        
    }   
}