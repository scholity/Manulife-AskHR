@isTest
private class ASKHR_CaseCommunicationExtTest {
    
    @isTest(SeeAllData=true)
    static void caseCommGeneralTest(){ 
		try{
			Id csrProfileId = [Select Id from Profile where Name = 'CSR'].Id;
			Contact newContact1 = ASKHR_TestUtility.createContact();
			User testUser = new User(FirstName='tst',LastName='testuser1',email='test.user1@manulife.com', employee_Id__c = 'tstuser1testing',Pay_Country__c='CAN',LanguageLocaleKey='en_US',profileId = csrProfileId); 
			
			User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
			
			// Insert account as current user
			System.runAs (thisUser) {
				insert testUser;                
				newContact1.User__c = testUser.Id; 
				update newContact1;         
			}
			
			Case testCase = new Case(Type='Enhancement', 
									 Related_System__c = 'Other', 
									 Related_Case_Number__c = '35546',
									 Origin = 'Ask HR', 
									 RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get(ASKHR_Common.CASE_RECORD_TYPE_NAME_FUNCTION).getRecordTypeId());
			 testCase.ContactId = newContact1.Id;
			insert testCase;
			
			system.runAs(testUser){
				ApexPages.currentPage().getParameters().put('id', testCase.Id);
				ApexPages.StandardController stdController = new ApexPages.StandardController(testCase);
				ASKHR_CaseCommunicationExt caseCommExt = new ASKHR_CaseCommunicationExt(stdController);
				
				Test.startTest();
				system.assertNotEquals(null, caseCommExt.mIsError);
				system.assertNotEquals(null, caseCommExt.mIsAllowComment);     
				system.assertNotEquals(null, caseCommExt.mCommentRecordTypeId);
				Test.stopTest();
			}
		}catch(Exception ex){}
    }
}