trigger CaseAuditEventTrigger on Case_Audit_Event__c (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {
    if(!TriggerUtils.bypassCaseAuditEventTrigger()){
    	TriggerFactory.createHandler(Case_Audit_Event__c.sObjectType);  
    }
}