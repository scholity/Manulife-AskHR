/**
 	*@description trigger Handler for the Case Comment SObject. This class implements the ITrigger
 	* interface to help ensure the trigger code is bulkified and all in one place.
 	*/
public without sharing class ASKHR_CaseCommentHandler
implements ITrigger {

    private static List<Case> updatedCases = new List<Case> ();
    // Constructor
    public ASKHR_CaseCommentHandler()
    {
    }

    /**
     * bulkBefore
     *
     * This method is called prior to execution of a BEFORE trigger. Use this to cache
     * any data required into maps prior execution of the trigger.
     */
    public void bulkBefore()
    {

    }

    public void bulkAfter()
    {

    }
	/**
	 * @description This method is called before the execution of a before insert trigger. 
	 */
    public void beforeInsert(SObject so)
    {
        CheckIfAllowToInsert(so);
    }

    public void beforeUpdate(SObject oldSo, SObject so)
    {

    }

    public void beforeDelete(SObject so)
    {

    }
	/**
    * @description this method is used to check wheather allow to insert comment or not 
    * @param SObject so
    */
    private void CheckIfAllowToInsert(SObject so)
    {

        String ERROR_MESSAGE = System.Label.ASKHR_No_Comment_Close_Case;

        CaseComment cc = (CaseComment) so;
        Id caseId = cc.ParentId;

        Case parentCase = [Select IsClosed, RecordType.Name from Case where Id = :caseId];

        Id userId = userinfo.getUserId();
        String userLicense = [Select User_License__c from User where Id = :userId].User_License__c;

        //validation if case is closed, not Salesforce user license and a General HR Case
        if (parentCase.IsClosed && parentCase.RecordType.Name.equals(ASKHR_common.CASE_RECORD_TYPE_NAME_GENERAL_HR) && userLicense != ASKHR_Common.USER_LICENSE_SALESFORCE)
        {
            cc.addError(ERROR_MESSAGE);
        }

    }
	/**
	 * @description This method is called after the execution of a after insert trigger and used to update the case comment 
	 */
    public void afterInsert(SObject so)
    {
        CaseComment cc = (CaseComment) so;
        Id caseId = cc.ParentId;
        Case parentCase = [Select IsClosed, RecordType.Name,Tmp_Case_Comment__c from Case where Id = :caseId];
        parentCase.Tmp_Case_Comment__c = cc.CommentBody;
        updatedCases.add(parentCase);
    }

    public void afterUpdate(SObject oldSo, SObject so)
    {

    }

    public void afterDelete(SObject so)
    {

    }

    /**
     *@description this method is called once all records have been processed by the trigger. Use this
     * method to accomplish any final operations such as creation or updates of other records.
     */
    public void andFinally()
    {
        if (!updatedCases.isEmpty()) {
            update updatedCases;
        }
    }
}