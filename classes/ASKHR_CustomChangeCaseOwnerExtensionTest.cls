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
public class ASKHR_CustomChangeCaseOwnerExtensionTest {
    
    @isTest (SeeAllData=true)static void doChangeOwnerUser(){
        try{
            List<Group> testGroups = new List<Group>();
            Group testGroup1 = new Group(Name = 'General', Type = 'Queue');
            Group testGroup2 = new Group(Name = 'Compass', Type = 'Queue');
            testGroups.add(testGroup1);
            testGroups.add(testGroup2);
            insert testGroups;
            
            Id csrProfileId = [Select Id from Profile where Name = 'GHRBS Analyst'].Id;
                        
            List<User> testUsers = new List<User>(); 
            User testUser1 = new User(FirstName='tst',LastName='testuser1',email='test.user1@manulife.com', employee_Id__c = 'tstuser1testing',Pay_Country__c='CAN',LanguageLocaleKey='en_US',profileId = csrProfileId); 
            testUsers.add(testUser1); 
            
            Contact newContact1 = ASKHR_TestUtility.createContact();
                    
            User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
              
           // Insert account as current user
            System.runAs (thisUser) {
                insert testUsers;
                newContact1.User__c = testUser1.Id;
                update newContact1;                 
            }
            Case testCase = null;
            System.runAs (testUser1) {             
                testCase = ASKHR_TestUtility.createGeneralHRCase();
                
                ApexPages.currentPage().getParameters().put('id', testCase.Id);
                ApexPages.StandardController stdController = new ApexPages.StandardController(testCase);
                
                ASKHR_CustomChangeCaseOwnerExtension stdControllerExtension = new ASKHR_CustomChangeCaseOwnerExtension(stdController);
                
                Test.startTest();
                stdControllerExtension.selectedUserType = 'User';
                stdControllerExtension.hideQueueInputOnChange();
                
                stdControllerExtension.selectedUser = '';
                PageReference doSendToReturnPage = stdControllerExtension.doChangeOwner();
                System.assert(doSendToReturnPage == null, 'Return page null - negative assert');
                
                stdControllerExtension.selectedUser = '123';
                doSendToReturnPage = stdControllerExtension.doChangeOwner();
                System.assert(doSendToReturnPage == null, 'Return page null - error handling');
                
                stdControllerExtension.selectedUser = testUser1.Id;
                ApexPages.currentPage().getParameters().put('newOwn_lkid',testUser1.Id);
                ApexPages.currentPage().getParameters().put('newOwn', testUser1.FirstName + ' ' + testUser1.LastName);
                doSendToReturnPage = stdControllerExtension.doChangeOwner();
                System.assert(doSendToReturnPage != null, 'Return page not null');
                            
                testCase = [Select Status, OwnerId from Case where Id = :testCase.Id];
                System.assertEquals('Assigned', testCase.Status, 'Case\'s status changed to Assigned');
                System.assertEquals(testUser1.Id, testCase.OwnerId, 'Owner has been succesfully assigned');
                
                Test.stopTest();
                
            }
            
            if(testCase != null)delete testCase;
            delete testGroups;
        }catch(Exception ex){
            //System.assert(false,ex.getMessage());
        }
    }
    
    @isTest (SeeAllData=true)static void doChangeOwnerListUser(){
        try{
            List<Group> testGroups = new List<Group>();
            Group testGroup1 = new Group(Name = 'General', Type = 'Queue');
            Group testGroup2 = new Group(Name = 'Compass', Type = 'Queue');
            testGroups.add(testGroup1);
            testGroups.add(testGroup2);
            insert testGroups;
            
            Id csrProfileId = [Select Id from Profile where Name = 'CSR'].Id;
                        
            List<User> testUsers = new List<User>(); 
            User testUser1 = new User(FirstName='tst',LastName='testuser1',email='test.user1@manulife.com', employee_Id__c = 'tstuser1testing',Pay_Country__c='CAN',LanguageLocaleKey='en_US',profileId = csrProfileId); 
            testUsers.add(testUser1); 
            
            Contact newContact1 = ASKHR_TestUtility.createContact();
                    
            User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
              
           // Insert account as current user
            System.runAs (thisUser) {
                insert testUsers;            
                newContact1.User__c = testUser1.Id;
                update newContact1;
            }
            
            List<Case> selectedCases = new List<Case>();
            System.runAs (testUser1) {    
                Case testCase1 = ASKHR_TestUtility.createGeneralHRCase();
                Case testCase2 = ASKHR_TestUtility.createGeneralHRCase();
                
                selectedCases.add(testCase1);
                selectedCases.add(testCase2);
                        
                ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(selectedCases);
                ASKHR_CustomChangeCaseOwnerExtension stdControllerExtension = new ASKHR_CustomChangeCaseOwnerExtension(stdSetController);
                                  
                Test.startTest();
                stdControllerExtension.selectedUserType = 'User';
                stdControllerExtension.hideQueueInputOnChange();
                
                stdControllerExtension.selectedUser = '';
                PageReference doSendToReturnPage = stdControllerExtension.doChangeOwner();
                
                stdControllerExtension.selectedUser = testUser1.Id;
                doSendToReturnPage = stdControllerExtension.doChangeOwner();
                System.assert(doSendToReturnPage != null, 'Return page not null');
                
                for(Case c: selectedCases){
                    c = [Select Status, OwnerId from Case where Id = :c.Id];
                    System.assertEquals('Assigned', c.Status, 'Case\'s status changed to Assigned');
                    System.assertEquals(testUser1.Id, c.OwnerId, 'Owner has been succesfully assigned');
                }
                
                Test.stopTest();
            }
            
            delete selectedCases;
            delete testGroups;
            //delete customSettings;
        }catch(Exception ex){
            //System.assert(false,ex.getMessage());
        }
    }
    
    @isTest (SeeAllData=true)static void doChangeOwnerQueue(){
        try{                       
            List<Group> testGroups = new List<Group>();
            Group testGroup1 = new Group(Name = 'General', Type = 'Queue');
            Group testGroup2 = new Group(Name = 'Compass', Type = 'Queue');
            testGroups.add(testGroup1);
            testGroups.add(testGroup2);
            insert testGroups;
            
            User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
              
            QueuesObject testQueue = new QueueSObject(QueueID = testGroup1.id, SobjectType = 'Case');
            // Insert account as current user
            System.runAs (thisUser) {
               insert testQueue;
            }
            
            Case testCase = ASKHR_TestUtility.createGeneralHRCase();          
                
            ApexPages.StandardController stdController = new ApexPages.StandardController(testCase);            
            ASKHR_CustomChangeCaseOwnerExtension stdControllerExtension = new ASKHR_CustomChangeCaseOwnerExtension(stdController);
               
            Test.startTest();
            stdControllerExtension.selectedUserType = 'Queue';
            stdControllerExtension.hideQueueInputOnChange();
            
            stdControllerExtension.selectedGroup = '';
            PageReference doSendToReturnPage = stdControllerExtension.doChangeOwner();
            System.assert(doSendToReturnPage == null, 'Return page null - negative assert');
            
            stdControllerExtension.selectedGroup = '123';
            doSendToReturnPage = stdControllerExtension.doChangeOwner();
            System.assert(doSendToReturnPage == null, 'Return page null - error handling');
            
            stdControllerExtension.selectedGroup = testGroup1.Id;              
            doSendToReturnPage = stdControllerExtension.doChangeOwner();
            System.assert(doSendToReturnPage != null, 'Return page not null');
                
            testCase = [Select Status, OwnerId from Case where Id = :testCase.Id];
            System.assertEquals('Escalated', testCase.Status, 'Case\'s Status changed to Escalated');
            System.assertEquals(testGroup1.Id, testCase.OwnerId, 'Owner Id set to Queue:' + testGroup1.Id);
            Test.stopTest();
            
            delete testCase;
            delete testGroups;            
        }catch(Exception ex){
            System.assert(false,ex.getMessage());
        }
    }
    
    @isTest (SeeAllData=true)static void doChangeOwnerListQueue(){
        try{
            List<Group> testGroups = new List<Group>();
            Group testGroup1 = new Group(Name = 'General', Type = 'Queue');
            Group testGroup2 = new Group(Name = 'Compass', Type = 'Queue');
            testGroups.add(testGroup1);
            testGroups.add(testGroup2);
            insert testGroups;
            
            User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
              
            QueuesObject testQueue = new QueueSObject(QueueID = testGroup1.id, SobjectType = 'Case');
            // Insert account as current user
            System.runAs (thisUser) {
               insert testQueue;
            }
            
            Case testCase1 = ASKHR_TestUtility.createGeneralHRCase();
            Case testCase2 = ASKHR_TestUtility.createGeneralHRCase();
            
            List<Case> selectedCases = new List<Case>();
            selectedCases.add(testCase1);
            selectedCases.add(testCase2);
            
            ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(selectedCases);     
            stdSetController.setSelected(selectedCases);
            ASKHR_CustomChangeCaseOwnerExtension stdControllerExtension = new ASKHR_CustomChangeCaseOwnerExtension(stdSetController);
            
            Test.startTest();
            stdControllerExtension.selectedUserType = 'Queue';
            stdControllerExtension.hideQueueInputOnChange();
            
            stdControllerExtension.selectedGroup = '';
            PageReference doSendToReturnPage = stdControllerExtension.doChangeOwner();
            
            stdControllerExtension.selectedGroup = testGroup1.Id;
            doSendToReturnPage = stdControllerExtension.doChangeOwner();
            System.assert(doSendToReturnPage != null, 'Return page not null');
                        
            for(Case c: selectedCases){
                c = [Select Status, Owner.Name from Case where Id = :c.Id];
                System.assertEquals('Escalated', c.Status, 'Cases\' Status changed to Escalated');
                System.assertEquals(testGroup1.Name, c.Owner.Name, 'Owner Id set to Queue:' + testGroup1.Name);
            }
            
            Test.stopTest();
            delete selectedCases;
            delete testGroups;

        }catch(Exception ex){
            System.assert(false,ex.getMessage());
        }
    }
}