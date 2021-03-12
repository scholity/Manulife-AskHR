@isTest
public class AskHR_PurgeAuditTrailRecordsTest {
    
    static testmethod void test() {
        
         Audit_Trail__c at = new Audit_Trail__c();
        at.Action__c = 'Action';
        at.Section__c = 'Section';
        at.CreatedDate__c = system.today();
        at.Audit_Rec_User__c = UserInfo.getUserId();
        insert at;
        
        AskHR_PurgeAuditTrailRecords purgeJob = new AskHR_PurgeAuditTrailRecords();
        purgeJob.execute(null);

    }

}