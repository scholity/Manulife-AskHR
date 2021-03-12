/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
public class ASKHR_CaseAuditEventRecorderTests {

    static testMethod  void AddCaseAuditViewEvent_EnsureItSaved() {
        
        Case c = ASKHR_TestUtility.createERCase();
        
        Test.startTest();
        ASKHR_CaseAuditEventRecorder.RecordView(c.Id, Userinfo.getUserId());
        Test.stopTest();
        
        // Extract the Audit View Event, ensure one exists.
        Case_Audit_Event__c cae = [SELECT Id, User__c, Parent_Case__c, Event_Date_Time__c FROM Case_Audit_Event__c WHERE Parent_Case__c = :c.Id AND User__c = :Userinfo.getUserId()];
        
        System.assert(cae != null, 'Expecting Case Audit Event to exist.');
    }

    public static boolean AddCaseAuditViewEventAsynchronously = false;
    static testMethod  void AddCaseAuditViewEventAsync_EnsureItSaved() {
        
        AddCaseAuditViewEventAsynchronously = true;
        Case c = ASKHR_TestUtility.createERCase();
        
        Test.startTest();
        ASKHR_CaseAuditEventRecorder.RecordView(c.Id, Userinfo.getUserId());
        Test.stopTest();
        
        // Extract the Audit View Event, ensure one exists.
        Case_Audit_Event__c cae = [SELECT Id, User__c, Parent_Case__c, Event_Date_Time__c FROM Case_Audit_Event__c WHERE Parent_Case__c = :c.Id AND User__c = :Userinfo.getUserId()];
        
        System.assert(cae != null, 'Expecting Case Audit Event to exist.');
    }
        
    static testMethod void CaseAuditViewEvent_AttemptToUpdate() {
        
        Case c = ASKHR_TestUtility.createERCase();
                
        ASKHR_CaseAuditEventRecorder.RecordView(c.Id, Userinfo.getUserId());
                
        // Extract the Audit View Event, ensure one exists.
        Case_Audit_Event__c cae = [SELECT Id, User__c, Parent_Case__c, Event_Date_Time__c FROM Case_Audit_Event__c WHERE Parent_Case__c = :c.Id AND User__c = :Userinfo.getUserId()];
                    
        Test.startTest();
         // attempt to update event.
         cae.Event_Date_Time__c = DateTime.Now();
         try
         {
            update cae;
         }
         catch(Exception e)
         {
            System.Assert(e.getMessage().contains('Cannot update a Case Audit Event.'));
         }
         Test.stopTest();
        
    }    

    
    static testMethod void CaseAuditViewEvent_AttemptToDelete() {
        
        Case c = ASKHR_TestUtility.createERCase();
                
        ASKHR_CaseAuditEventRecorder.RecordView(c.Id, Userinfo.getUserId());
                
        // Extract the Audit View Event, ensure one exists.
        Case_Audit_Event__c cae = [SELECT Id, User__c, Parent_Case__c, Event_Date_Time__c FROM Case_Audit_Event__c WHERE Parent_Case__c = :c.Id AND User__c = :Userinfo.getUserId()];
                    
        Test.startTest();
        
         try
         {
            delete cae;
         }
         catch(Exception e)
         {
            System.Assert(e.getMessage().contains('Cannot delete a Case Audit Event.'));
         }
         Test.stopTest();
        
    }        
}