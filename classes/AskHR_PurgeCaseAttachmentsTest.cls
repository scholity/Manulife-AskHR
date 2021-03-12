@isTest
public class AskHR_PurgeCaseAttachmentsTest {
    
    public static Map<String, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Case.getRecordTypeInfosByName();
    
    static testMethod void testmethod1() {
        
        Case testCase = new Case(External_Contact_Name__c = 'TEST EXTERNAL NAME', 
                                Secondary_Country_of_Reference__c = 'USA', Type = 'HR Reporting', Status = 'Closed',
                                RecordTypeId=ASKHR_TestUtility.GetRecordTypeID(ASKHR_Common.CASE_RECORD_TYPE_NAME_GENERAL_HR));
		insert testCase;
        
        Attachment att = new Attachment();
        att.Name = 'Test Attachment';
        att.Body = Blob.valueOf('Unit Test Attachment Body');
        att.ParentId = testCase.Id;
        insert att;
        Test.startTest();
        AskHR_PurgeCaseAttachments purgeJob = new AskHR_PurgeCaseAttachments();
        purgeJob.execute(null);
        
        
        Test.stopTest();
    }

}