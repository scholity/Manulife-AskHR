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
//private class ASKHR_ContactUtilsTest // renamed as below
private class ASKHR_DowngradeAnalystTest
{
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
        insert con;                       

        con.Leave_Date__c = Date.newInstance(2016, 1, 1); 
        update con;

        Test.startTest();
        //ASKHR_ContactUtils sh1 = new ASKHR_ContactUtils();// rename to as below
        ASKHR_DowngradeAnalyst sh1 = new ASKHR_DowngradeAnalyst();
        String sch = '0 0 23 * * ?'; 
        system.schedule('ASKHR_DowngradeAnalyst', sch, sh1); 
        Test.stopTest();        
    }     

    @isTest (SeeAllData=true)
    static void downgradeUserManagerTest()
    {
        Id csrProfileId = [Select Id from Profile where Name = 'CSR Manager'].Id;
        User testUser1 = new User(FirstName='tst',LastName='testuser1',email='test.user1@manulife.com',Is_Manager__c = true, employee_Id__c = 'tstuser1testing',Pay_Country__c='CAN',LanguageLocaleKey='en_US',profileId = csrProfileId);
        
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
            
        // Insert account as current user
        System.runAs (thisUser) {
            insert testUser1;
        }
        
        Contact con = new Contact();
        con.LastName = 'Test Manager';
        con.Employee_Status__c ='Leave';
        con.User__c = testUser1.Id;
        con.Employee_Number__c = '0';
        insert con;                       

        con.Leave_Date__c = Date.newInstance(2016, 1, 1); 
        update con;
        
        Test.startTest();
        //ASKHR_ContactUtils sh1 = new ASKHR_ContactUtils(); // renamed to as below
        ASKHR_DowngradeAnalyst sh1 = new ASKHR_DowngradeAnalyst();
        String sch = '0 0 23 * * ?'; 
        system.schedule('ASKHR_DowngradeAnalyst', sch, sh1); 
        Test.stopTest();  
    }     

    @isTest (SeeAllData=true)
    static void downgradeAdminTest()
    {
        Id csrProfileId = [Select Id from Profile where Name = 'System Administrator'].Id;
        User testUser1 = new User(FirstName='tst',LastName='testuser1',email='test.user1@manulife.com', employee_Id__c = 'tstuser1testing',Pay_Country__c='CAN',LanguageLocaleKey='en_US',profileId = csrProfileId);
        
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
            
        // Insert account as current user
        System.runAs (thisUser) {
            insert testUser1;
        }

        Contact con = new Contact();
        con.LastName = 'Test Admin';
        con.Employee_Status__c ='Leave';
        con.User__c = testUser1.Id;
        con.Employee_Number__c = '0';
        insert con;                       

        con.Leave_Date__c = Date.newInstance(2016, 1, 1); 
        update con;

        Test.startTest();
        //ASKHR_ContactUtils sh1 = new ASKHR_ContactUtils(); // renamed as below
        ASKHR_DowngradeAnalyst sh1 = new ASKHR_DowngradeAnalyst();
        String sch = '0 0 23 * * ?'; 
        system.schedule('ASKHR_DowngradeAnalyst', sch, sh1); 
        Test.stopTest();        
    }     
}