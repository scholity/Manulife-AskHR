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
private class ASKHR_ContactHandlerTest {

    @isTest (SeeAllData=true) static void testContactCore() {
        List<User> testUsers = new List<User>();
        Id employeeCommunityProfileId = [Select Id from Profile where Name = 'Employee Communities User'].Id;
        
        User testUser1 = new User(FirstName='tst',LastName='testuser1',email='test.user1@manulife.com',employee_Id__c = 'tstuser1testing',Pay_Country__c='CAN',LanguageLocaleKey='en_US',profileId = employeeCommunityProfileId);
        testUsers.add(testUser1);
        
        User testUser2 = new User(LastName='testuser2',email='test.user2@manulife.com',employee_Id__c = 'tstuser2testing',Pay_Country__c='USA',LanguageLocaleKey='en_US', profileId = employeeCommunityProfileId);
        testUsers.add(testUser2);
    
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
       // Insert account as current user
        System.runAs (thisUser) {   
            Test.startTest();
            insert testUsers;
            Test.stopTest();
        }
        
        List<Contact> newContacts = [Select Id, AccountId, FirstName, LastName, Employee_Number__c from Contact where user__c in (:testUser1.Id,:testUser2.Id)];
        System.assertEquals(2,newContacts.size());
        
        List<Id> newAccountIds = new List<Id>();
        List<Id> newContactIds = new List<Id>();
        
        for (Contact con : newContacts){
            con.lastname = 'modified_test_contact_lastname';
            newContactIds.add(con.Id);
            newAccountIds.add(con.AccountId);
        }
        
        List<Account> newAccountsById  = [Select Id, Name from Account where Id in :newAccountIds];
        System.assertEquals(2,newAccountsById.size());
        
        List<Account> newAccountsByName = [Select Id,Name from Account where name in ('tst.testuser1.tstuser1testing','.testuser2.tstuser2testing')];   
        System.assertEquals(2,newAccountsByName.size());
    
        Id manulifeAccountId = ASKHR_ContactService.getManulifeAccountId();
        System.assert(manulifeAccountId!=null);
    
        update newContacts;
                
        newContacts = [Select Id, AccountId, FirstName, LastName, Employee_Number__c from Contact where user__c in (:testUser1.Id,:testUser2.Id)];
        System.assertEquals(2,newContacts.size());
        
        for (Contact con : newContacts){
            System.assertEquals('modified_test_contact_lastname', con.LastName);
        }       
        
        delete newContacts;

        newContacts = [Select Id  from Contact where id in :newContactIds];
        System.assertEquals(0,newContacts.size());

        newContacts = [Select Id  from Contact where user__c in (:testUser1.Id,:testUser2.Id)];
        System.assertEquals(0,newContacts.size());

        newAccountsById  = [Select Id  from Account where Id in :newAccountIds];
        System.assertEquals(0,newAccountsById.size());
        
        newAccountsByName = [Select Id  from Account where name in ('tst.testuser1.tstuser1testing','.testuser2.tstuser2testing')]; 
        System.assertEquals(0,newAccountsByName.size());
        
    }
}