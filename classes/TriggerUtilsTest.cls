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
private class TriggerUtilsTest {

    @isTest static void testSetBypassCaseTrigger() {
		TriggerUtils.setBypassCaseTrigger();
		System.assert(TriggerUtils.bypassCaseTrigger());
    }
    @isTest static void testsetBypassUserTrigger() {
		TriggerUtils.setBypassUserTrigger();
		System.assert(TriggerUtils.bypassUserTrigger());
    }

    @isTest static void testSetBypassContactTrigger() {
		TriggerUtils.setBypassContactTrigger();
		System.assert(TriggerUtils.bypassContactTrigger());
    }
    @isTest static void testSetBypassEmailMessageTrigger() {
		TriggerUtils.setBypassEmailMessageTrigger();
		System.assert(TriggerUtils.bypassEmailMessageTrigger());
    }
	@isTest static void testSetBypassActionStepMessageTrigger() {
		TriggerUtils.setBypassActionStepTrigger();
		System.assert(TriggerUtils.bypassActionStepTrigger());
    }
    
    @isTest static void testsetBypassCaseCommentTrigger() {
		TriggerUtils.setBypassCaseCommentTrigger();
		System.assert(TriggerUtils.bypassCaseCommentTrigger());
    }
    
    @isTest static void testsetBypassCaseAuditEventTrigger() {
		TriggerUtils.setBypassCaseAuditEventTrigger();
		System.assert(TriggerUtils.bypassCaseAuditEventTrigger());
    }
    
     @isTest static void testsetBypassSurveyTakerTrigger() {
		TriggerUtils.setBypassSurveyTakerTrigger();
		System.assert(TriggerUtils.bypassSurveyTakerTrigger());
    }
}