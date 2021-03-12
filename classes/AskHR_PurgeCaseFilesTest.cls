@isTest
public class AskHR_PurgeCaseFilesTest {
    
    public static Map<String, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Case.getRecordTypeInfosByName();
    
    static testMethod void testmethod1() {
        
        Case testCase = new Case(External_Contact_Name__c = 'TEST EXTERNAL NAME', 
                                 Secondary_Country_of_Reference__c = 'USA', Type = 'HR Reporting', Status = 'Closed',
                                 RecordTypeId=ASKHR_TestUtility.GetRecordTypeID(ASKHR_Common.CASE_RECORD_TYPE_NAME_GENERAL_HR));
        insert testCase;
        
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Test',
            PathOnClient = 'Test.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion; 
        
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = testCase.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;
        
        Test.startTest();
        AskHR_PurgeCaseFiles purgeJob = new AskHR_PurgeCaseFiles();
        purgeJob.execute(null);
        Test.stopTest();
    }
    
}