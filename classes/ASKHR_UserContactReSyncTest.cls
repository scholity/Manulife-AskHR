@isTest
public class ASKHR_UserContactReSyncTest { 

@isTest (SeeAllData=true)
    static void downgradeUserTest()
    {
        Id csrProfileId = [Select Id from Profile where Name = 'CSR'].Id;
        User testUser1 = new User(FirstName='tst',LastName='testuser1',email='test.user1@manulife.com',employee_Id__c = 'tstuser1testing',Pay_Country__c='CAN',LanguageLocaleKey='en_US',profileId = csrProfileId);
        
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
            
        // Insert account as current user
        System.runAs (thisUser) {
            insert testUser1;
        }

        Contact con = new Contact();
        con.LastName = 'Test Name';
        con.Employee_Status__c ='Leave';
        con.User__c = testUser1.Id;
        con.Employee_Number__c = '0';
        con.Employee_Status__c = 'Terminated';
        insert con;                       
  
        Test.startTest();
        //ASKHR_ContactUtils sh1 = new ASKHR_ContactUtils();// rename to as below
        ASKHR_UserContactReSync sh1 = new ASKHR_UserContactReSync();
        String sch = '0 0 23 * * ?'; 
        system.schedule('ASKHR_UserContactReSync', sch, sh1); 
        Test.stopTest();        
    } 	
}