/**
*@description this class is used to record the actions done on cases
*/

public without sharing class ASKHR_CaseAuditEventRecorder {
    
    private static Map<String, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Case_Audit_Event__c.getRecordTypeInfosByName();
    
    public static void RecordView(Id caseId, Id userId)
    {
           if(system.isFuture() || (Test.isRunningTest() && !ASKHR_CaseAuditEventRecorderTests.AddCaseAuditViewEventAsynchronously))
           {
                RecordViewSync(caseId, userId, DateTime.Now());
           }
           else
           {
                RecordViewAsync(caseId, userId, DateTime.Now());
           }
    }
    
    @future
    private static void RecordViewAsync(Id caseId, Id userId, datetime eventDateTime)
    {
        RecordViewSync(caseId, userId, eventDateTime);
    }
    
	/**
	*@description this method to record the view 
	*@param Id caseId
	*@param Id userId
	*@param datetime eventDateTime
	*/

    private static void RecordViewSync(Id caseId, Id userId, datetime eventDateTime)
    {
        
        
        if(ShouldRecordView(caseId, userId, eventDateTime))
        {       
            Case_Audit_Event__c auditEvent = new Case_Audit_Event__c();
            auditEvent.Action__c = 'View';
            auditEvent.Parent_Case__c = caseId;
            auditEvent.User__c = userId;
            auditEvent.Event_Date_Time__c = eventDateTime;
            auditEvent.RecordTypeId = rtMap.get(ASKHR_Common.ASKHR_RECORDTYPE).getRecordTypeId();
            System.debug('Inserting Case Audit View Event: ' + caseId + ' User ID: ' + userID);
            insert auditEvent;
        }
    }   
    /**
    *@description this method checks whether to record the view 
	*@param Id caseId
	*@param Id userId
	*@param datetime eventDateTime
	*@return boolean value to record or not 
	*/
    private static boolean ShouldRecordView(Id caseId, Id userId, datetime eventDateTime)   {
        
        // Check if case was viewed by the same user in the last 1 minutes.
        DateTime startingTime = eventDateTime.addMinutes(-1);
        integer recCount = 0;
        boolean canRecord = false;
        
        recCount = [SELECT COUNT() FROM Case_Audit_Event__c WHERE Parent_Case__c = :caseID AND 
                                User__c = :userId AND Event_Date_Time__c > :startingTime AND Event_Date_Time__c < :eventDateTime]; 
        
        if(recCount == 0)
        {
            canRecord = true;
        }
        
        return canRecord;
        
    }
    
}