@isTest
public class ASKHR_UserDeactivationTest {

    @isTest (SeeAllData=true)
    static void DeactivateUser()
    {
        Id csrProfileId = [Select Id from Profile where Name = 'CSR'].Id;
        User testUser1 = new User(FirstName='tst',LastName='testuser1',email='test.user1@manulife.com',employee_Id__c = 'tstuser1testing',Pay_Country__c='CAN',LanguageLocaleKey='en_US',profileId = csrProfileId);
        
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
            
        // Insert account as current user
        System.runAs (thisUser) {
            insert testUser1;
        }                     
  
        Test.startTest();
        //ASKHR_ContactUtils sh1 = new ASKHR_ContactUtils();// rename to as below
        ASKHR_UserDeactivation sh1 = new ASKHR_UserDeactivation();
        String sch = '0 0 23 * * ?'; 
        system.schedule('ASKHR_UserDeactivation', sch, sh1); 
        Test.stopTest();        
    } 
    
}