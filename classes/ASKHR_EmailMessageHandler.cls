/**
* @author Mohamad Ammar Amran <mohamadammar_amran@manulife.com>
* @description Trigger Handler for the EmailMessage SObject. This class implements the ITrigger
*			   interface to help ensure the trigger code is bulkified and all in one place.
*/
public without sharing class ASKHR_EmailMessageHandler implements ITrigger {

	private List<Case> m_email2caseOwnerUpdate = new List<Case> ();
	private ASKHR_EmailToCase_Setting__mdt m_GlobalSetting;
	private Integer m_EmailTimeDifferent = 20;

	// Constructor
	public ASKHR_EmailMessageHandler()
	{
		try {
			m_GlobalSetting = [Select Email_Time_Different__c from ASKHR_EmailToCase_Setting__mdt where Enable_Global__c = true AND Active__c = true LIMIT 1];
			if (m_GlobalSetting != null) {
				m_EmailTimeDifferent = m_GlobalSetting.Email_Time_Different__c.intValue();
			}
		} catch(Exception ex) {
			System.debug('ASKHR_EmailMessageHandler Error : ' + ex.getMessage());
		}
	}

	/**
	 *@description this method is called prior to execution of a BEFORE trigger. Use this to cache
	 * any data required into maps prior execution of the trigger.
	 */
	public void bulkBefore()
	{

	}

	/*
	 * @description This method is called prior to execution of a AFTER trigger. Use this to cache
	 * any data required into maps prior execution of the trigger.
	 * Prepare the list of cases to update owner based on ToAddress
	 */
	public void bulkAfter()
	{
		if (Trigger.isInsert) {
			m_email2caseOwnerUpdate = ASKHR_EmailMessageService.getCasesByEmailAddresss(Trigger.newMap);
		}
	}

	public void beforeInsert(SObject so)
	{

	}

	public void beforeUpdate(SObject oldSo, SObject so)
	{
	}


	public void beforeDelete(SObject so)
	{
	}
    
	/**
	 * @description This method is called After the execution of a after insert trigger. 
	 */
	public void afterInsert(SObject so)
	{
		EmailMessage em = (EmailMessage) so;

		//handle the incoming email only
		if (em.Incoming) {
			Case parentCase = [Select Id, ContactId, Case.RecordTypeId, RecordType.Name, CreatedDate, LastModifiedDate from Case where Id = :em.ParentId];
			DateTime now = DateTime.now();

			//only new case will update the details and perform the necessary update
			if (parentCase != null && isNewCase(parentCase.CreatedDate, now)) {
				 string filterHTMLBody = ASKHR_CaseFromEmailHelper.CheckHTMLBody(em.HtmlBody);
                parentCase.Description__c = filterHTMLBody; //em.HtmlBody;
				ASKHR_CaseFromEmailHelper.handleCasefromEmail(parentCase, em);
				m_email2caseOwnerUpdate.add(parentCase);
			}
		}
	}
    
	/**
	*@description this method is used to check the case is newly created (theoretically newly created case should have the same lastmodifieddate with createddate 
	*to be sure that this is a new case we compare the createddate and lastmodifieddate to be within the same minutes)
	*@param createdDate DateTime
	*@param lastmodifiedDate DateTime
	*@return boolean isNewCase is assigned to the user 
	*/
	private boolean isNewCase(DateTime createdDate, DateTime lastModifiedDate) {
		Double second = Math.Floor((lastModifiedDate.getTime() - createdDate.getTime()) / (1000.0));
		if (second < m_EmailTimeDifferent) {
			return true;
		} else
		return false;
	}

	public void afterUpdate(SObject oldSo, SObject so)
	{

	}

	public void afterDelete(SObject so)
	{
	}

	/**
	 * andFinally
	 *
	 * @description This method is called once all records have been processed by the trigger. Use this 
	 * method to accomplish any final operations such as creation or updates of other records.
	 *
	 *  Update the owner for the case list prepared in BulkAfter().
	 */
	public void andFinally()
	{
		try {
			if (!m_email2caseOwnerUpdate.isEmpty()) {
				ASKHR_EmailMessageService.updateCase(JSON.serialize(m_email2caseOwnerUpdate));
			}
		} catch(Exception ex) {
			System.debug('Error Updating Case:' + ex.getMessage());
		}
	}
}