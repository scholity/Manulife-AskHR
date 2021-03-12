@isTest(SeeAlldata=false)
public class ASKHR_HRSSSOPHandlerTest {

    @isTest
    static void HandlerTest(){
        
        Trigger_Setting__c setting = new Trigger_Setting__c();
        setting.Name = 'Knowledge';
        setting.Bypass__c = false;
        insert setting;
        
        Id kRecordTypeId = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByName().get('HR_SOP').getRecordTypeId();
        
        Knowledge__kav article1 = new Knowledge__kav(
            Title = 'Test Article 1',
            UrlName = 'testing-article-1',
            Language = 'en_US',
            Review_Date__c = Date.today(),
            RecordTypeId = kRecordTypeId);
        insert article1;
        
        Knowledge__kav article2 = new Knowledge__kav(
            Title = 'Test Article 2',
            UrlName = 'test-article-2',
            Language = 'en_US',
            HR_SOP_Approval_Status__c = 'Submitted',
            Review_Date__c = Date.today(),
            RecordTypeId = kRecordTypeId);
        insert article2;
        
        article1.HR_SOP_Approval_Status__c = 'Submitted';
        update article1;
        
        article2.HR_SOP_Approval_Status__c = 'Approved';
        update article2;
    }
}