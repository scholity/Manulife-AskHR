/**
* @author Mohamad Ammar Amran <mohamadammar_amran@manulife.com>
* @description Unit test class for ensuring code coverage for EmailTemplateVF Controller and CaseUpdatedVF Controller
*/
@isTest
private class ASKHR_VFControllerTest {
    private static Map<String, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Case.getRecordTypeInfosByName();
     
    static testmethod void CaseUpdatedVFControllerTest(){
       
            User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
           Case testCase1;   
            
            System.runAs(thisUser){  
                testCase1 = new Case(Type='Enhancement', 
                                     Related_System__c = 'Other', 
                                     Related_Case_Number__c = '35546',
                                     Origin = 'Ask HR', 
                                     RecordTypeId= rtMap.get('Function').getRecordTypeId());
                testCase1.Description__c = 'Test 1';
                insert testCase1;
                
                testCase1.Description__c = 'Test 2';
                update testCase1;
            }
                String input = 'A message from GHRBS ' +
                    'This is to notify you that you the following case has been recently modified. ' +
                    'Case: {!Case.CaseNumber}: {!Case.Subject} ' +
                    'Details: ' +
                    '{!recentHistory} ' +
                    'To view the details of the case please click on the enclosed link (https://mfcentral.my.salesforce.com/console#/{!Case.Id})';
                ASKHR_CaseUpdatedVFController cuvfc = new ASKHR_CaseUpdatedVFController();
            	cuvfc.mCaseId = testCase1.Id;
                String output = cuvfc.mOutput;
                Test.startTest();
                cuvfc.mInput = input;
                //System.assert(!String.isBlank(output));
                
               // System.assert(!String.isBlank(output));
                Test.stopTest();
            
            
            delete testCase1; 
        
    }
    
    @isTest(SeeAllData=true)
    static void EmailTemplateVFControllerTest(){
        try {
            List<User> testUsers = new List<User>(); 
            Id csrProfileId = [Select Id from Profile where Name = 'CSR'].Id;
            
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
            
            Case testCase1;   
            System.runAs(thisUser){  
                testCase1 = new Case(Type='Enhancement', 
                                     Related_System__c = 'Other', 
                                     Related_Case_Number__c = '35546',
                                     Origin = 'Ask HR', 
                                     OwnerId = thisUser.id,
                                     Subject = 'Test Subject', 
                                     RecordTypeId= rtMap.get('Function').getRecordTypeId());
                testCase1.ContactId = newContact1.Id;
                testCase1.Description__c = 'Test 1';
                insert testCase1;
                
                Test.startTest();
                
                String input = ' Hi {!recipient.Name} ' +                       
                    'This is to notify you that you the following case has been recently modified. ' +
                    'Case: {!Case.CaseNumber}: {!Case.Subject} ' +
                    'owner: {!Case.Owner.Name} ' +
                    'To view the details of the case please click on the enclosed link ';
                ASKHR_EmailTemplateVFCompController cuvfc = new ASKHR_EmailTemplateVFCompController();
                
                cuvfc.mInput = input;
                System.assert(!String.isBlank(cuvfc.mInput));
                cuvfc.mRelatedToId = testCase1.Id;
                cuvfc.mRecipientId = newContact1.Id;
                System.assert(!String.isBlank(cuvfc.mOutput));
                Test.stopTest();
            }
            
            delete testCase1;             
        }
        catch(Exception e)
        {
            //should not have error. all errors are handled in the class
            System.assert(false, 'Error: ' + e.getMessage());
        }
        
    }
 
}