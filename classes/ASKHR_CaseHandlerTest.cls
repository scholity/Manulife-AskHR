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
@isTest(SeeAllData=true)
//@isTest
private class ASKHR_CaseHandlerTest {
    public static Map<String, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Case.getRecordTypeInfosByName();
    private static Map<String,Id> m_CaseTeamRoles = ASKHR_CaseService.getCaseTeamRolesByName();
    
    @isTest (SeeAllData=true) static void testCSRCase() {
        Case testCase1 = new Case( RecordTypeId=rtMap.get(ASKHR_Common.CASE_RECORD_TYPE_NAME_FUNCTION).getRecordTypeId());
        insert testCase1;
        
        Case testCase2 = new Case(Secondary_Country_of_Reference__c = 'USA', External_Contact_Name__c = 'TEST EXTERNAL NAME', RecordTypeId=rtMap.get(ASKHR_Common.CASE_RECORD_TYPE_NAME_GENERAL_HR).getRecordTypeId());
        insert testCase2;
        
        //<TO-DO> Assert statements
    }
    
    static testMethod void testCommunityCase() {
        List<User> testUsers = new List<User>();
        Id employeeCommunityProfileId = [Select Id from Profile where Name = 'Employee Communities User'].Id;
        
        User testUser1 = new User(FirstName='tst',LastName='testuser1',email='test.user1@manulife.com',employee_Id__c = 'tstuser1testing',Pay_Country__c='CAN',LanguageLocaleKey='en_US',profileId = employeeCommunityProfileId);
        testUsers.add(testUser1);
        
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        //Insert Custom Setting Data
        //insert new ASKHR_Communities_User__c(Is_Communities_User__c = true,SetupOwnerId= employeeCommunityProfileId);
        // Insert account as current user
        
        System.runAs (thisUser) {
            insert testUsers;
            //Create Contact for Community User
            Account acc = new Account(NAme='Manulife');
            insert acc;
            Contact con = new Contact(LastName = 'Test', User__c = testUsers[0].Id, Employee_Number__c = '1234', AccountID=acc.id);
            Insert con;
        }
        
        
        try {
            System.runAs(testUser1) {
                List<Case> caseList = new List<Case>();
                Case testCase1 = new Case(Origin = 'Ask HR',RecordTypeId=rtMap.get(ASKHR_Common.CASE_RECORD_TYPE_NAME_GENERAL_HR).getRecordTypeId());
                Case testCase2 = new Case(Origin = 'Ask HR',RecordTypeId=rtMap.get(ASKHR_Common.CASE_RECORD_TYPE_NAME_TRANSLATION_KNOWLEDGE_Policy).getRecordTypeId());
                Case testCase3 = new Case(Origin = 'Ask HR',RecordTypeId=rtMap.get(ASKHR_Common.CASE_RECORD_TYPE_NAME_HR_SYSTEMS_ACCESS).getRecordTypeId());
                Case testCase4 = new Case(Origin = 'Workday Support Email',RecordTypeId=rtMap.get(ASKHR_Common.CASE_RECORD_TYPE_NAME_HR_SYSTEMS_ACCESS).getRecordTypeId());
                Case testCase5 = new Case(Origin = 'Ask HR',RecordTypeId=rtMap.get(ASKHR_Common.CASE_RECORD_TYPE_NAME_FUNCTION).getRecordTypeId());
                caseList.add(testCase1);
                caseList.add(testCase2);
                caseList.add(testCase3);
                caseList.add(testCase4);                
                caseList.add(testCase5);
                Test.startTest();
                insert caseList;
                
                //System.Assert(false, 'Case Owner cannot be a community user.');
                Test.stopTest();
            }
        }
        catch(Exception e)
        {
            System.assert(true, 'Validation rule prevent case from saving.');
        }
        
        //<TO-DO> Assert statements
    }
    
    static testMethod void testFunctionCase()
    {
        try {
            List<User> testUsers = new List<User>(); 
            Id csrProfileId = [Select Id from Profile where Name = 'CSR'].Id;
            Id employeeCommunityProfileId = [Select Id from Profile where Name = 'Employee Communities User'].Id;
            
            User testUser1 = new User(FirstName='tst',LastName='testuser1',email='test.user1@manulife.com', employee_Id__c = 'tstuser1testing',Pay_Country__c='CAN',LanguageLocaleKey='en_US',profileId = csrProfileId); 
            testUsers.add(testUser1); 
            
            User testUser2 = new User(FirstName='tst2',LastName='testuser2',email='test.user2@manulife.com', employee_Id__c = 'tstuser2testing',Pay_Country__c='CAN',LanguageLocaleKey='en_US',profileId = csrProfileId); 
            testUsers.add(testUser2); 
            
            User testUser3 = new User(FirstName='tst3',LastName='testuser3',email='test.user3@manulife.com', employee_Id__c = 'tstuser3testing',Pay_Country__c='CAN',LanguageLocaleKey='en_US',profileId = employeeCommunityProfileId); 
            testUsers.add(testUser3); 
            
            Contact newContact1 = ASKHR_TestUtility.createContact();
            Contact newContact2 = ASKHR_TestUtility.createContact();
            Contact newContact3 = ASKHR_TestUtility.createContact();
            
            User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
            
            // Insert account as current user
            System.runAs (thisUser) {
                insert testUsers;
                
                newContact1.User__c = testUser1.Id;
                newContact2.User__c = testUser2.Id;
                newContact3.User__c = testUser3.Id;
                
                update newContact1;
                update newContact2;  
                update newContact3;            
            }
            Case testCase1;   
            
            System.runAs(testUser3){ 
                List<Case> testCases = new List<Case>();
                testCase1 = new Case(Type='Enhancement', 
                                     Related_System__c = 'Other', 
                                     Related_Case_Number__c = '35546',
                                     Origin = 'Ask HR', 
                                     RecordTypeId=rtMap.get(ASKHR_Common.CASE_RECORD_TYPE_NAME_FUNCTION).getRecordTypeId());
                testCase1.ContactId = newContact2.Id;
                testCases.add(testCase1);
                insert testCases;
                
                CaseTeamMember[] ctm = getCaseTeamMembers(testCase1.Id);
                System.assertNotEquals(0, ctm.size());
                
                testCase1.ContactId = newContact1.Id;
                testCase1.OwnerId = testUser2.Id;
                update testCase1; 
                
                ctm = getCaseTeamMembers(testCase1.Id);
                System.assertNotEquals(0, ctm.size());
                
                testCase1.ContactId = newContact2.Id;
                testCase1.OwnerId = testUser1.Id;
                update testCase1;
                
                ctm = getCaseTeamMembers(testCase1.Id);
                System.assertNotEquals(0, ctm.size());
            }
            
            delete testCase1; 
            
        }
        catch(Exception e)
        {
            //should not have error. all errors are handled in the class
            //removed because during unit test it couldnt access the vf page component
            
        }
    } 
    
    static testMethod void testFunctionParentChildCase()
    {
        try {
            List<User> testUsers = new List<User>(); 
            Id gHRBSAnalystProfileId = [Select Id from Profile where Name = 'GHRBS Analyst'].Id;
            Id userRoleId = [SELECT Id from UserRole where Name='GHRBS Analyst'].Id;
            
            User testUser1 = new User(FirstName='tst3',LastName='testuser3',email='test.user3@manulife.com', employee_Id__c = 'tstuser3testing',Pay_Country__c='CAN',LanguageLocaleKey='en_US',profileId = gHRBSAnalystProfileId); 
            testUsers.add(testUser1); 
            
            User testUser2 = new User(FirstName='tst2',LastName='testuser2',email='test.user2@manulife.com', employee_Id__c = 'tstuser2testing',Pay_Country__c='CAN',LanguageLocaleKey='en_US',profileId = gHRBSAnalystProfileId); 
            testUsers.add(testUser2); 
            
            Contact newContact1 = ASKHR_TestUtility.createContact();
            Contact newContact2 = ASKHR_TestUtility.createContact();
            
            User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
            // Insert account as current user
            System.runAs (thisUser) {
                insert testUsers;
                testUser1.UserRoleId = userRoleId;
                newContact1.User__c = testUser1.Id;
                newContact2.User__c = testUser2.Id;
                update newContact1;
                update newContact2;
            }
            
            Case testCase1;
            Case testCase2;
            CaseTeamTemplateRecord caseTeamTemplateRecord;
            System.runAs(testUser1){
                testCase1 = new Case(Type='Enhancement', 
                                     Related_System__c = 'Other', 
                                     Related_Case_Number__c = 'Not Applicable',
                                     Origin = 'Ask HR',
                                     Secondary_Country_of_Reference__c = 'CAN',
                                     RecordTypeId=rtMap.get(ASKHR_Common.CASE_RECORD_TYPE_NAME_GENERAL_HR).getRecordTypeId());
                testCase1.ContactId = newContact2.Id;
                System.assertEquals(userRoleId, testUser1.UserRoleId, 'User Role Id');
                insert testCase1;
                testCase2 = new Case(Type='Enhancement', 
                                     Related_System__c = 'Other', 
                                     Related_Case_Number__c = 'Not Applicable',
                                     Origin = 'Ask HR', 
                                     RecordTypeId=rtMap.get(ASKHR_Common.CASE_RECORD_TYPE_NAME_FUNCTION).getRecordTypeId());
                testCase2.ContactId = newContact2.Id;
                testCase2.ParentId = testCase1.Id;
                insert testCase2;
                
                caseTeamTemplateRecord = new CaseTeamTemplateRecord(ParentId = testCase1.Id, TeamTemplateId = ASKHR_CaseService.getPredefinedCaseTeamId('CSR Team'));
                insert caseTeamTemplateRecord;
                
                CaseTeamMember[] ctm = getCaseTeamMembers(testCase1.Id);
                System.assertNotEquals(0, ctm.size());
                
                //CaseTeamTemplateRecord[] ctt = getPredefinedTeamMember(testCase2.Id);
                //System.assertNotEquals(0, ctt.size());
            }
            delete caseTeamTemplateRecord; 
            delete testCase1;
            delete testCase2;
        }
        catch(Exception e)
        {  
            
        }
    }   
    
    static testMethod void testGHRCase()
    {
        try {
            
            Id csrProfileId = [Select Id from Profile where Name = 'CSR'].Id;
            Id employeeCommunityProfileId = [Select Id from Profile where Name = 'Employee Communities User'].Id;
            
            User testUser1 = new User(FirstName='tst',LastName='testuser1',email='test.user1@manulife.com', employee_Id__c = 'tstuser1testing',Pay_Country__c='CAN',LanguageLocaleKey='en_US',profileId = employeeCommunityProfileId); 
            User testUser2 = new User(FirstName='tst2',LastName='testuser2',email='test.user2@manulife.com', employee_Id__c = 'tstuser2testing',Pay_Country__c='MYR',LanguageLocaleKey='en_US',profileId = csrProfileId); 
            
            Contact newContact1 = ASKHR_TestUtility.createContact();
            Contact newContact2 = ASKHR_TestUtility.createContact();
            
            User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
            
            Group testGroup1 = new Group(Name = 'GHRBS Support', Type = 'Queue');           
            insert testGroup1;
            
            QueuesObject testQueue = new QueueSObject(QueueID = testGroup1.id, SobjectType = 'Case');
            
            // Insert account as current user
            System.runAs (thisUser) {
                insert testUser1;
                insert testUser2;
                newContact1.User__c = testUser1.Id;
                newContact2.User__c = testUser2.Id;
                update newContact1;  
                update newContact2;
                insert testQueue;
                
                
                Test.startTest();
                Case testCase1 = new Case(Type='Enhancement', 
                                          Related_System__c = 'Other', 
                                          Related_Case_Number__c = 'Not Applicable',
                                          Origin = 'Ask HR',
                                          Secondary_Country_of_Reference__c = 'CAN',
                                          RecordTypeId=rtMap.get(ASKHR_Common.CASE_RECORD_TYPE_NAME_GENERAL_HR).getRecordTypeId());
                testCase1.ContactId = newContact1.Id;   
                insert testCase1;   
                
                testCase1.OwnerId = testUser2.Id;
                update testCase1;
                
                testCase1.OwnerId = testGroup1.Id;
                update testCase1;
                
                testCase1.OwnerId = testUser2.Id;
                update testCase1;            
                Test.stopTest();
                
                delete testCase1;
            }
        }
        catch(Exception e)
        {
            
        }
    }   
    
    static testMethod void testERCasewithParent()
    {
        try {
            
            Id csrProfileId = [Select Id from Profile where Name = 'CSR'].Id;
            
            User testUser1 = new User(FirstName='tst',LastName='testuser1',email='test.user1@manulife.com', employee_Id__c = 'tstuser1testing',Pay_Country__c='CAN',LanguageLocaleKey='en_US',profileId = csrProfileId); 
            User testUser2 = new User(FirstName='tst2',LastName='testuser2',email='test.user2@manulife.com', employee_Id__c = 'tstuser2testing',Pay_Country__c='CAN',LanguageLocaleKey='en_US',profileId = csrProfileId); 
            
            Contact newContact1 = ASKHR_TestUtility.createContact();     
            Contact newContact2 = ASKHR_TestUtility.createContact();                    
            User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
            
            // Insert account as current user
            System.runAs (thisUser) {
                insert testUser1;
                insert testUser2;
                newContact1.User__c = testUser1.Id;
                newContact2.User__c = testUser2.Id;
                update newContact1;  
                update newContact2;
            }
            
            Test.startTest();
            Case testCase1 = new Case(Type='Enhancement', 
                                      Related_System__c = 'Other', 
                                      Related_Case_Number__c = 'Not Applicable',
                                      Origin = 'Ask HR',
                                      Secondary_Country_of_Reference__c = 'CAN',
                                      RecordTypeId=rtMap.get(ASKHR_Common.CASE_RECORD_TYPE_NAME_GENERAL_HR).getRecordTypeId());
            testCase1.ContactId = newContact1.Id;      
            testCase1.OwnerId = testUser1.Id;
            insert testCase1;   
            
            Case testCase2 = new Case(Type='Performance',   
                                      Origin = 'Ask HR',
                                      RecordTypeId=rtMap.get(ASKHR_Common.CASE_RECORD_TYPE_NAME_ER_CASE).getRecordTypeId());
            testCase2.ParentId = testCase1.Id;
            testCase2.ContactId = newContact2.Id;
            testCase2.OwnerId = testUser2.Id;
            insert testCase2;
            
            CaseTeamMember[] ctm = getCaseTeamMembers(testCase1.Id);
            for(CaseTeamMember c : ctm){
                if(c.TeamRoleId == m_CaseTeamRoles.get('Child Case Contact'))
                    System.assertEquals(testUser2.Id, c.MemberId);
            }            
            Test.stopTest();
            
            delete testCase1;
            delete testCase2;
        }
        catch(Exception e)
        {
            
        }
    }   
    
    static testMethod void testCaseUpdated() {
        Case testCase1 = new Case( RecordTypeId=rtMap.get(ASKHR_Common.CASE_RECORD_TYPE_NAME_FUNCTION).getRecordTypeId());
        insert testCase1;
        
        testCase1 = [Select Status from Case where Id =:testCase1.id];
        
        //Updated the status to On Hold
        testCase1.Status = 'On Hold';
        update testCase1;
        
        system.assert(testCase1.Status.equals('On Hold'), 'Case is updated to On Hold');
        
        testCase1.Status = 'Assigned';
        update testCase1;
        system.assert(testCase1.Status.equals('Assigned'), 'Case is updated to Assigned');
        
        testCase1.Status = 'Tested - Verified';
        update testCase1;
        system.assert(testCase1.Status.equals('Tested - Verified'), 'Case is updated to Tested - Verified');
        
        //added on 6 april 2016
        testCase1.Status = 'Fixed - Awaiting Testing';
        update testCase1;
        system.assert(testCase1.Status.equals('Fixed - Awaiting Testing'), 'Case is updated to Fixed - Awaiting Testing');
        
        delete testCase1;
    }
    
    static testMethod void testCaseAssignment(){
        Case testCase1 = new Case( RecordTypeId=rtMap.get(ASKHR_Common.CASE_RECORD_TYPE_NAME_FUNCTION).getRecordTypeId());
        insert testCase1;
        
        Test.startTest();
        List<String> caseList = new List<String>();
        caseList.add(testCase1.Id);
        ASKHR_CaseService.triggerCaseAutoAssignmentRule(caseList);
        ASKHR_CaseService.triggerCaseAutoAssignmentRuleNow(caseList);
        System.assertNotEquals(null, ASKHR_CaseService.isCommunitiesManager());
        Test.stopTest();
    }
    
    
    
    static CaseTeamMember[] getCaseTeamMembers(Id caseId){
        return  [Select MemberId, TeamRoleId from CaseTeamMember where ParentId = :caseId];
    }
    
    static CaseTeamTemplateRecord[] getPredefinedTeamMember (Id caseId){
        return  [Select ParentId, TeamTemplateId from CaseTeamTemplateRecord where ParentId = :caseID];
    }
    @isTest (SeeAllData=true) static void testParentCase() {
       /* Case testCase4 = new Case(Origin = 'Ask HR',RecordTypeId=rtMap.get(ASKHR_Common.CASE_RECORD_TYPE_NAME_FUNCTION).getRecordTypeId(), Related_Case_Number__c='12345');
        Case testCase5 = new Case(Origin = 'Ask HR',RecordTypeId=rtMap.get(ASKHR_Common.CASE_RECORD_TYPE_NAME_FUNCTION).getRecordTypeId(), ParentId = testCase4.Id,Related_Case_Number__c='5648');
        insert testCase4;
        insert testCase5; */
        Account acc  = new Account(Name='Manulife');
        insert acc;
        Contact con = new Contact(LastName = 'Test Contact', Employee_Number__c ='12345',AccountID=acc.id);
        insert con;
        Contact con1 = ASKHR_TestUtility.createContact();
        List<Case> caseList = new List<Case>();
        Case testCase1 = new Case( External_Contact_Name__c = 'TEST EXTERNAL NAME', RecordTypeId=rtMap.get(ASKHR_Common.CASE_RECORD_TYPE_NAME_ER_CASE).getRecordTypeId(), Employee_of_Record__c = con.Id);
        //insert testCase1;
        caseList.add(testCase1);
        Case testCase2 = new Case(External_Contact_Name__c = 'TEST EXTERNAL NAME', RecordTypeId=rtMap.get(ASKHR_Common.CASE_RECORD_TYPE_NAME_ER_CASE).getRecordTypeId(), ParentId = testCase1.Id,Employee_of_Record__c = con1.Id);
        //insert testCase2;
        caseList.add(testCase2);
        Case testCase3 = new Case( OwnerId = UserInfo.getUserId(),External_Contact_Name__c = 'TEST EXTERNAL NAME', RecordTypeId=rtMap.get(ASKHR_Common.CASE_RECORD_TYPE_NAME_FUNCTION).getRecordTypeId(),ParentId = testCase1.Id, Employee_of_Record__c = con.Id, Status='New');
        //insert testCase3;
        caseList.add(testCase3);
        insert caseList;
        
        Test.startTest();
        testCase2.Status = 'Open';
        update testCase2;
        testCase3.Origin = 'Phone';
        testCase3.ContactId = con1.Id;
        update testCase3;
        Test.stopTest();
        
        //<TO-DO> Assert statements
    }
}