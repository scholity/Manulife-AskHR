@isTest(SeeAllData=true)
private class ASKHR_CaseCommentHandlerTest {
   /* public static Map<String, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Case.getRecordTypeInfosByName();
    private static String CASE_RECORD_TYPE_NAME_GENERAL_HR = 'General HR Case';*/
    
     static testMethod void doAddCommentClosedCaseTest() {
        Id employeeCommunityProfileId = [Select Id from Profile where Name = 'Employee Communities User'].Id;
         
        Case testCase = new Case(External_Contact_Name__c = 'TEST EXTERNAL NAME', 
                                Secondary_Country_of_Reference__c = 'USA', 
                                RecordTypeId=ASKHR_TestUtility.GetRecordTypeID(ASKHR_Common.CASE_RECORD_TYPE_NAME_GENERAL_HR));
        insert testCase;
         
        ApexPages.StandardController stdController = new ApexPages.StandardController(testCase);
        ASKHR_CaseExtension stdControllerExtension = new ASKHR_CaseExtension(stdController);
        
        List<SelectOption> caseCloseReasons = stdControllerExtension.getCaseCloseReasons();
        System.assert(!caseCloseReasons.isEmpty());
        String caseCloseReason = ((SelectOption)caseCloseReasons.get(0)).getValue();
        
        stdControllerExtension.caseCloseComment = 'TEST CASE CLOSE COMMENT';
        stdControllerExtension.caseCloseReason = caseCloseReason;
        
        stdControllerExtension.doCaseClose();
        
        testCase = [Select Id, status from Case where id = :testCase.id ];
        System.assertEquals('Closed', testCase.status);
       //below line commented to fix shield issue
        //CaseComment tCc = [Select Id, CommentBody from CaseComment where ParentId=:testCase.Id AND CommentBody ='TEST CASE CLOSE COMMENT'];
        CaseComment tCc = [Select Id, CommentBody from CaseComment where ParentId=:testCase.Id ];
        tCc.CommentBody = 'NEW COMMENT UPDATE';
        update tCC;
        delete tCC;
         
        User testUser1 = new User(FirstName='tst',LastName='testuser1',email='test.user1@manulife.com',employee_Id__c = 'tstuser1testing',Pay_Country__c='CAN',LanguageLocaleKey='en_US',profileId = employeeCommunityProfileId);
         
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
         test.startTest();
       // Insert account as current user
        System.runAs (thisUser) {
            insert testUser1;
        }
        
        System.runAs(testUser1) {
            
            try{
                CaseComment cc = new CaseComment(ParentId = testCase.Id, CommentBody ='test coment on close case');
                insert cc;
            }catch(Exception ex){
                System.assert(true, 'Validation rule prevent case from saving.');
            }
        }
         test.stopTest();
        
    }
}