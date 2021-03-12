@isTest//(SeeAlldata = true)
public class AskHR_AuditBatchClassTest {
    
    static testmethod void test() {
        
        AuditTrail__c setting = new AuditTrail__c();
        setting.Name = 'Main';
        setting.Last_Batch_Run__c = null;
        setting.Batch_Sync__c = true;
        insert setting;
        
        Test.startTest();
        AskHR_AuditBatchSchedule c = new AskHR_AuditBatchSchedule();
        c.execute(null);
        Test.stopTest();
    }
    
}