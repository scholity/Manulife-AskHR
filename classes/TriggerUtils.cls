/**
 *@description this class used to provide utility functions to triggers 
*/
public without sharing class TriggerUtils {
	/**
	*@description define flag for bypassing Case Audit Event Trigger
	*/	
	private static boolean bypassCaseAuditEventTriggerFlag = false; 
	
	public static void setBypassCaseAuditEventTrigger() {
		bypassCaseAuditEventTriggerFlag = true;
	}
	/**
	 *@description return flag for bypassing Case Audit Event Trigger
	 *@return boolean flag
	 */
	public static boolean BypassCaseAuditEventTrigger() {
		return bypassCaseAuditEventTriggerFlag;
	}

	 /**
	 *@description define flag for bypassing Case Trigger
	 *@return boolean flag
	 */	
	private static boolean  bypassCaseTriggerFlag = false;
   
	public static void setBypassCaseTrigger() {
		bypassCaseTriggerFlag = true;
	}

   	public static boolean bypassCaseTrigger() {
		return bypassCaseTriggerFlag;
	}
    
    /**
	 *@description define flag for bypassing CaseComment Trigger
	 */
	private static boolean  bypassCaseCommentTriggerFlag = false;

    
	public static void setBypassCaseCommentTrigger() {
		bypassCaseCommentTriggerFlag = true;
	}

	public static boolean bypassCaseCommentTrigger() {
		return bypassCaseCommentTriggerFlag;
	}
    

	/**
	 * define flag for bypassing User Trigger
	 */
	private static boolean  bypassUserTriggerFlag = false;

	public static void setBypassUserTrigger() {
		bypassUserTriggerFlag = true;
	}

	public static boolean bypassUserTrigger() {
		return bypassUserTriggerFlag;
	}

	/**
	 * define flag for bypassing Contact Trigger
	 */
	private static boolean  bypassContactTriggerFlag = false;

	public static void setBypassContactTrigger() {
		bypassContactTriggerFlag = true;
	}

	public static boolean bypassContactTrigger() {
		return bypassContactTriggerFlag;
	}

	/*
	 * define flag for bypassing EmailMessage Trigger
	 */
	private static boolean  bypassEmailMessageTriggerFlag = false;

	public static void setBypassEmailMessageTrigger() {
		bypassEmailMessageTriggerFlag = true;
	}

	public static boolean bypassEmailMessageTrigger() {
		return bypassEmailMessageTriggerFlag;
	}

	/**
	 * Define flag for bypassing ActionStep Trigger
	 */
	private static boolean bypassActionStepTriggerFlag = false;

	public static void setBypassActionStepTrigger() {
		bypassActionStepTriggerFlag = true;
	}

	public static boolean bypassActionStepTrigger() {
		return bypassActionStepTriggerFlag;
	}

	/**
	 * Define flag for bypassing SurveyTaker Trigger
	 */
	private static boolean bypassSurveyTakerTriggerFlag = false;

	public static void setBypassSurveyTakerTrigger() {
		bypassActionStepTriggerFlag = true;
	}

	public static boolean bypassSurveyTakerTrigger() {
		return bypassActionStepTriggerFlag;
	}
    
    /**
	 * define flag for bypassing Contact Trigger
	 */
	private static boolean  bypassKnowledgeTriggerFlag = false;

	public static void setBypassKnowledgeTrigger() {
		bypassKnowledgeTriggerFlag = true;
	}

	public static boolean bypassKnowledgeTrigger() {
		return bypassKnowledgeTriggerFlag;
	}
}