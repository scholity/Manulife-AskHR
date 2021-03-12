/**
* @author Mohamad Ammar Amran <mohamadammar_amran@manulife.com>
* @description Trigger Handler for the Case SObject. This class implements the ITrigger
*			   interface to help ensure the trigger code is bulkified and all in one place.
*/
public without sharing class ASKHR_CaseHandler implements ITrigger {
	private Id m_ContactIdForCommunityUser;
	private Id m_GHRBSCaseTeamId;
	private Id m_CCBCaseTeamId;
	private Id m_CSRCaseTeamId;
	private Map<Id, Id> m_userIdsByCaseIds = new Map<Id, Id> ();
	private List<CaseTeamMember> m_CaseTeamMembers = new List<CaseTeamMember> ();
	private List<CaseTeamTemplateRecord> m_CaseTeamTemplateRecords = new List<CaseTeamTemplateRecord> ();
	private Map<String, Id> m_CaseTeamRoles = new Map<String, Id> ();

	public static Map<ID, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Case.getRecordTypeInfosById();

	private List<String> m_CaseIdListForReassignment = new List<String> ();
	private List<CustomCaseTeamNotifier__c> mCustomCaseTeamNotifiers = new List<CustomCaseTeamNotifier__c> ();

	private Boolean isRunReassignmentRuleFirst = true;

	Private string CASE_STATUS_CLOSED = 'Closed';
	Private string CASE_STATUS_ON_HOLD = 'On Hold';
	Private string CASE_STATUS_TESTED_VERIFIED = 'Tested - Verified';
	Private string CASE_STATUS_FIXED_AWAITING_TESTING = 'Fixed - Awaiting Testing';
    private Map<Id, Id> userContactMap = new Map<Id,Id>();
    private Map<Id, String> employeeCountryMap = new Map<Id, String>();

	// Constructor
    public ASKHR_CaseHandler()
    {
        //if(!Test.isRunningTest()){
            Id userId = UserInfo.getUserId();
            List<Contact> conList = [Select Id, User__c from Contact where User__c = :userId Limit 1];
            if(conList != null && conList.size() > 0){
                userContactMap.put(conList[0].Id, userId);
            }
        //}
    }

	/**
	 * @description This method is called prior to execution of a BEFORE trigger. Use this to cache
	 * any data required into maps prior execution of the trigger.
	 */
	public void bulkBefore()
	{
		// If this an insert trigger get Contact ID for the current User
		if (Trigger.isInsert)
		{
			m_ContactIdForCommunityUser = ASKHR_CaseService.getContactForCommunitiesUser();
		}
        
        //Rahul
        if(Trigger.isInsert || Trigger.isUpdate)
        {
            employeeCountryMap = ASKHR_CaseService.getEmployeeCountryMap(Trigger.new);
        }
    }

    /**
	*@description this method is called after the execution of a AFTER trigger. 
	*/
    
	public void bulkAfter()
	{
		// If this an insert trigger Cache a list of CaseShares for Cases' Contacts
		if (Trigger.isInsert)
		{
			if (!ASKHR_CaseService.isCommunitiesUser()) {
				m_userIdsByCaseIds = ASKHR_CaseService.getUsersForCasesContacts(Trigger.newMap);
				m_GHRBSCaseTeamId = ASKHR_CaseService.getPredefinedCaseTeamId(ASKHR_Common.CASE_TEAM_TEMPLATE_GHRBS_TEAM);
				m_CCBCaseTeamId = ASKHR_CaseService.getPredefinedCaseTeamId(ASKHR_Common.CASE_TEAM_TEMPLATE_CCB_TEAM);
			}
		}

		if (Trigger.isUpdate)
		{
			if (!ASKHR_CaseService.isCommunitiesUser()) {
				m_CSRCaseTeamId = ASKHR_CaseService.getPredefinedCaseTeamId(ASKHR_Common.CASE_TEAM_TEMPLATE_CSR_TEAM);
			}
		}

		m_CaseTeamRoles = ASKHR_CaseService.getCaseTeamRolesByName();
	}

    /**
	 * @description This method is called before the execution of a before insert trigger. 
	 */
	public void beforeInsert(SObject so)
	{
		Case c = (Case) so;
		System.debug('Case Details:' + c.Origin+ '&'+ m_ContactIdForCommunityUser +'&'+ ASKHR_CaseService.isCommunitiesUser());
		if ((c.Origin != 'Email') && m_ContactIdForCommunityUser != null && ASKHR_CaseService.isCommunitiesUser()) {
			c.ContactId = m_ContactIdForCommunityUser;
			c.Origin = ASKHR_Common.CASE_ORIGIN_COMMUNITIES_USERS;
			if (!ASKHR_CaseService.isCommunitiesManager()) {
				c.Employee_of_Record__c = m_ContactIdForCommunityUser;
				c.Contact_Relationship__c = 'Employee';
			}
		} 
        //else if (c.Origin == 'Workday Support Email' || c.Origin == 'Email to Case') { //TODO: add case origin if it require rule handling
        else if (c.Origin == ASKHR_Common.CASE_ORIGIN_WORKDAY_SUPPORT_EMAIL || c.Origin == ASKHR_Common.CASE_ORIGIN_EMAIL_TO_CASE) { //TODO: add case origin if it require rule handling

			ASKHR_CaseFromEmailHelper.handleCasefromEmail(c);
		}

		if (rtMap.get(c.RecordTypeId).getName().equals(ASKHR_Common.CASE_RECORD_TYPE_NAME_FUNCTION)) {
			isRunReassignmentRuleFirst = false;
		}
        //HRSALEFOR-1189
        if(c.Employee_of_Record__c != null && employeeCountryMap.get(c.Employee_of_Record__c) != null){
            
            c.Contact_Country__c = employeeCountryMap.get(c.Employee_of_Record__c);
        }else
            if(c.Secondary_Country_of_Reference__c != null){
                
                c.Contact_Country__c = c.Secondary_Country_of_Reference__c;
            }
	}

	/**
	 * @description This method is called before the execution of a before update trigger. 
	 */
	public void beforeUpdate(SObject oldSo, SObject so)
	{
		Case c = (Case) so;
		Case oldCase = (Case) oldSo;

		//new logic for Case Age No Hold
		//only run when the Status is changed
		if (!oldCase.Status.equals(c.Status)) {
			if (c.Status.equals(CASE_STATUS_ON_HOLD)) {
				c.TmpDateHold__c = Date.today();
			} 
			else if (c.Status.equals(CASE_STATUS_TESTED_VERIFIED) || (c.Status.equals(CASE_STATUS_CLOSED) && c.TmpDateTestedVerified__c == null)) {
				//Get the date the case updated to Tested - Verified for Case Age Tested-Verified calculation
				c.TmpDateTestedVerified__c = DateTime.Now();
			} //Fixed - Awaiting Testing condition added on 6 April 2016
			
			else if (c.Status.equals(CASE_STATUS_FIXED_AWAITING_TESTING) || (c.Status.equals(CASE_STATUS_CLOSED) && c.TmpDateFixedAwaitingTesting__c == null)) {
				//Get the date the case updated to Fixed - Awaiting Testing for Case Age Fixed - Awaiting Testing calculation
				c.TmpDateFixedAwaitingTesting__c = DateTime.Now();
			} 
			else if (oldCase.Status.equals(CASE_STATUS_ON_HOLD) && !c.Status.equals(CASE_STATUS_ON_HOLD))
			{
				if (c.TmpSumHoldDay__c == null) c.TmpSumHoldDay__c = 0;
				//if the case status changing from On Hold to other, get the total day the Case go On Hold
				c.TmpSumHoldDay__c = c.TmpSumHoldDay__c + c.TmpTotalHoldDay__c;
				c.TmpDateHold__c = null;
			}
		}
        //HRSALEFOR-1189
        if(c.Employee_of_Record__c != null && employeeCountryMap.get(c.Employee_of_Record__c) != null){
            
            c.Contact_Country__c = employeeCountryMap.get(c.Employee_of_Record__c);
        }else
            if(c.Secondary_Country_of_Reference__c != null){
                
                c.Contact_Country__c = c.Secondary_Country_of_Reference__c;
            }
	}

	public void beforeDelete(SObject so)
	{


	}

    /**
	 * @description This method is called after the execution of a After insert trigger. 
	 */
	public void afterInsert(SObject so)
	{
		System.debug('Case after Insert Start...');

		Case c = (Case) so;

		//if (ASKHR_CaseService.isCommunitiesUser() && c.Origin != 'Email')
		if (ASKHR_CaseService.isCommunitiesUser() && c.Origin != ASKHR_Common.CASE_ORIGIN_EMAIL)
		{
			m_CaseIdListForReassignment.add(c.Id);
		}

		//If the Current user is a Salesforce user, and the Case is either a Function or Change Control Case, 
		// and the owner is not a Queue, add the Case Owner to the Case Team, as the Case Owner.
		
		if (!ASKHR_CaseService.isCommunitiesUser() &&
		(rtMap.get(c.RecordTypeId).getName().equals(ASKHR_Common.CASE_RECORD_TYPE_NAME_FUNCTION) || rtMap.get(c.RecordTypeId).getName().equals(ASKHR_Common.CASE_RECORD_TYPE_NAME_CHANGE_CONTROL))) {

			//if owner not queue and not System Integration, add into Case Team
			if (!ASKHR_CaseService.IsUserQueue(c.OwnerId) && !ASKHR_CaseService.isUserProfileEquals(c.OwnerId, 'System Integration')) {
				CaseTeamMember ctm = new CaseTeamMember();
				ctm.ParentId = c.Id;
				ctm.MemberId = c.OwnerId;
				ctm.TeamRoleId = m_CaseTeamRoles.get(ASKHR_Common.CASE_TEAM_ROLE_CASE_OWNER);
				m_CaseTeamMembers.add(ctm);
			}
		}

		//If the Case Contact is provided, and the Case is not an ER Case, ER Termination Documents, or OHS Incident
		// Then either add the current user, if they are a community user, or add the Case's Contact to the Case
		// Team as a Contact.
		
		if (c.ContactId != null && (rtMap.get(c.RecordTypeId).getName().equals(ASKHR_Common.CASE_RECORD_TYPE_NAME_ER_CASE) == false &&
		                            rtMap.get(c.RecordTypeId).getName().equals(ASKHR_Common.CASE_RECORD_TYPE_NAME_ER_TERMINATION) == false &&
		                            rtMap.get(c.RecordTypeId).getName().equals(ASKHR_Common.CASE_RECORD_TYPE_NAME_OHS_INCIDENT) == false)) {

			CaseTeamMember ctm = new CaseTeamMember();
			ctm.ParentId = c.Id;

			if (ASKHR_CaseService.isCommunitiesUser()) {
				ctm.MemberId = System.Userinfo.getUserId();
			}
			else {
				//Id contactId = m_userIdsByCaseIds.get(c.Id);
				//for rewards case, add the contact into case team
				//if(rtMap.get(c.RecordTypeId).getName().equals('Rewards Case') || !CaseService.IsUserEmployeeCommunity(contactId))
				//    ctm.MemberId = contactId;  
				ctm.MemberId = m_userIdsByCaseIds.get(c.Id);
			}

			System.Debug('Case Team Contact ' + ctm.MemberId);
			ctm.TeamRoleId = m_CaseTeamRoles.get(ASKHR_Common.CASE_TEAM_ROLE_CASE_CONTACT);

			//if case contact = case contact. then do not add
			//this will only happen to Function. General HR Case is still not affected 
			
			if (rtMap.get(c.RecordTypeId).getName().equals(ASKHR_Common.CASE_RECORD_TYPE_NAME_FUNCTION)) {
				if (ctm.MemberId != c.OwnerId) {
					m_CaseTeamMembers.add(ctm);
					mCustomCaseTeamNotifiers.add(convertIntoCaseTeamNotifier(ctm));
				}
			} else {
				m_CaseTeamMembers.add(ctm);
				mCustomCaseTeamNotifiers.add(convertIntoCaseTeamNotifier(ctm));
			}
		}
		
		if (c.parentId != null && rtMap.get(c.RecordTypeId).getName().equals(ASKHR_Common.CASE_RECORD_TYPE_NAME_FUNCTION)) {
			if (c.OwnerId != null && !ASKHR_CaseService.IsUserQueue(c.OwnerId)) {
				String userRole = [Select UserRole.Name from User where Id = :c.OwnerId].UserRole.Name;
				userRole = userRole != null ? userRole : '';
				if (userRole != null && userRole.equals(ASKHR_Common.USER_ROLE_GHRBS_ANALYST)){
					addCaseOwnerAs(c, c.OwnerId, ASKHR_Common.CASE_TEAM_ROLE_CASE_TIER1);
				}
			}
		}

		if (m_GHRBSCaseTeamId != null && (rtMap.get(c.RecordTypeId).getName().equals(ASKHR_Common.CASE_RECORD_TYPE_NAME_FUNCTION) )) {
			CaseTeamTemplateRecord cttr = new CaseTeamTemplateRecord();
			cttr.ParentId = c.Id;
			cttr.TeamTemplateId = m_GHRBSCaseTeamId;
			m_CaseTeamTemplateRecords.add(cttr);
		}
		
        if (m_CCBCaseTeamId != null && rtMap.get(c.RecordTypeId).getName().equals(ASKHR_Common.CASE_RECORD_TYPE_NAME_CHANGE_CONTROL)) {
			CaseTeamTemplateRecord cttr = new CaseTeamTemplateRecord();
			cttr.ParentId = c.Id;
			cttr.TeamTemplateId = m_CCBCaseTeamId;
			m_CaseTeamTemplateRecords.add(cttr);
		}

		//this rule apply only to ER Case with parent case
		if (rtMap.get(c.RecordTypeId).getName().equals(ASKHR_Common.CASE_RECORD_TYPE_NAME_ER_CASE)) {
			addCaseOwnerIntoParent(c);
		}
        //HRSALEFOR-244
        //If the Current user is a Salesforce user, and the Case is Knowledge Case,
		// add the Case Creator to the Case Team, as the Case Creator.
        if (!ASKHR_CaseService.isCommunitiesUser() &&
            (rtMap.get(c.RecordTypeId).getName().equals(ASKHR_Common.CASE_RECORD_TYPE_NAME_TRANSLATION_KNOWLEDGE_Policy))){
                
                //if Creator is not System Integration, add into Case Team
	
	                if (!ASKHR_CaseService.isUserProfileEquals(c.CreatedByID, 'System Integration')) {
                    if(userContactMap != null && userContactMap.get(c.ContactId) != c.CreatedById){
                        CaseTeamMember ctm = new CaseTeamMember();
                        ctm.ParentId = c.Id;
                        ctm.MemberId = c.CreatedByID;
                        ctm.TeamRoleId = m_CaseTeamRoles.get(ASKHR_Common.CASE_TEAM_ROLE_CASE_CREATOR);
                        m_CaseTeamMembers.add(ctm);
                    }
                }
            }
        
        //HRSALEFOR-1483
        //If the Current user is a Salesforce user, and the Case is either a HR SystemsAccess case or HR SystemsSupport Case,
		// add the Case Creator to the Case Team, as the Case Creator.
        if (!ASKHR_CaseService.isCommunitiesUser() &&
            (rtMap.get(c.RecordTypeId).getName().equals(ASKHR_Common.CASE_RECORD_TYPE_NAME_HR_SYSTEMS_ACCESS) || rtMap.get(c.RecordTypeId).getName().equals(ASKHR_Common.CASE_RECORD_TYPE_NAME_HR_SYSTEMS_SUPPORT))){
               
                //if Creator is not System Integration, add into Case Team
	
	                if (!ASKHR_CaseService.isUserProfileEquals(c.CreatedByID, 'System Integration')) {
                    if(userContactMap != null && userContactMap.get(c.ContactId) != c.CreatedById){
                        CaseTeamMember ctm = new CaseTeamMember();
                        ctm.ParentId = c.Id;
                        ctm.MemberId = c.CreatedByID;
                        ctm.TeamRoleId = m_CaseTeamRoles.get(ASKHR_Common.CASE_TEAM_ROLE_CASE_CREATOR);  
                        m_CaseTeamMembers.add(ctm);
                    }
                }
            }
        
	}

    /**
	 * @description This method is called after the execution of a after Update trigger. 
	 */
    
	public void afterUpdate(SObject oldSo, SObject so)
	{
		System.debug('Case after Update Start...');
		Case c = (Case) so;
		Case oldC = (Case) oldSo;
		
		if (rtMap.get(c.RecordTypeId).getName().equals(ASKHR_Common.CASE_RECORD_TYPE_NAME_FUNCTION) ||
		    rtMap.get(c.RecordTypeId).getName().equals(ASKHR_Common.CASE_RECORD_TYPE_NAME_CHANGE_CONTROL)) {
			if (!ASKHR_CaseService.IsUserQueue(c.OwnerId)) {

				System.debug('Updating Case Team - Owner Role Members');
				CaseTeamMember existingTeamMember = ASKHR_CaseService.IsUserAlreadyCaseTeamMember(c.Id, c.OwnerId, null);
				if (existingTeamMember != null)
				{
					// User is already a team member, delete them from the existing team, and then re-add them.
					System.debug('Removing User ' + c.OwnerId + ' from Owner Role in Case Team');
					delete existingTeamMember;
				}

				// Add Case Owner to Case Team, as the Owner
				System.debug('Adding User ' + c.OwnerId + ' to Case Team as Owner');
				CaseTeamMember ctm = new CaseTeamMember();
				ctm.ParentId = c.Id;
				ctm.MemberId = c.OwnerId;
				ctm.TeamRoleId = m_CaseTeamRoles.get(ASKHR_Common.CASE_TEAM_ROLE_CASE_OWNER);
                
				m_CaseTeamMembers.add(ctm);
			}

			m_userIdsByCaseIds = ASKHR_CaseService.getUsersForCasesContacts(Trigger.newMap);
			boolean isContactChanged = oldC.ContactId != null ? !oldC.ContactId.equals(c.ContactId) : c.ContactId != null;

			if (c.ContactId != null && isContactChanged && (rtMap.get(c.RecordTypeId).getName().equals(ASKHR_Common.CASE_RECORD_TYPE_NAME_ER_CASE) == false &&
			                                                rtMap.get(c.RecordTypeId).getName().equals(ASKHR_Common.CASE_RECORD_TYPE_NAME_ER_TERMINATION) == false &&
			                                                rtMap.get(c.RecordTypeId).getName().equals(ASKHR_Common.CASE_RECORD_TYPE_NAME_OHS_INCIDENT) == false)) {

				System.debug('Updating Case Team - Contact Role Members');
				CaseTeamMember ctm = new CaseTeamMember();
				ctm.ParentId = c.Id;

				if (ASKHR_CaseService.isCommunitiesUser()) {
					ctm.MemberId = System.Userinfo.getUserId();
				} else {
					ctm.MemberId = m_userIdsByCaseIds.get(c.Id);
				}

				CaseTeamMember existingTeamMember = ASKHR_CaseService.IsUserAlreadyCaseTeamMember(c.Id, ctm.MemberId, null);

				if (existingTeamMember != null) {
					// If contact is already a case team member, delete them, and they will get re-added
					System.debug('Removing User ' + existingTeamMember.MemberId + ' from Contact Role in Case Team');

					CustomCaseTeamNotifier__c existingCCTN = convertIntoCaseTeamNotifier(existingTeamMember);
					if (existingCCTN != null) delete existingCCTN;

					delete existingTeamMember;
				}

				ctm.TeamRoleId = m_CaseTeamRoles.get(ASKHR_Common.CASE_TEAM_ROLE_CASE_CONTACT);

				if (!IsCaseTeamMemberAlreadyInList(m_CaseTeamMembers, ctm)) {
					System.debug('Adding User ' + ctm.MemberId + ' to case team as contact.');
					m_CaseTeamMembers.add(ctm);
					mCustomCaseTeamNotifiers.add(convertIntoCaseTeamNotifier(ctm));
				}
			}
                
           // System.debug('Record Type: '+ rtMap.get(c.RecordTypeId).getName().equals(ASKHR_Common.CASE_RECORD_TYPE_NAME_FUNCTION) );
			if (rtMap.get(c.RecordTypeId).getName().equals(ASKHR_Common.CASE_RECORD_TYPE_NAME_FUNCTION) && c.ParentId != null)
			{
           
				CaseTeamTemplateRecord caseTeamTemplateRecord = GetPredefinedTeamMember(c.ParentId, ASKHR_CaseService.getPredefinedCaseTeamId(ASKHR_Common.CASE_TEAM_TEMPLATE_CSR_TEAM));

				if (c.OwnerId != null && !ASKHR_CaseService.IsUserQueue(c.OwnerId)) {
					String userRole = [Select UserRole.Name from User where Id = :c.OwnerId].UserRole.Name;
					if (!oldC.OwnerId.equals(c.OwnerId) && userRole.equals(ASKHR_Common.USER_ROLE_GHRBS_ANALYST)){
						addCaseOwnerAs(c, c.OwnerId, ASKHR_Common.CASE_TEAM_ROLE_CASE_TIER1);
					}
				}

				if (caseTeamTemplateRecord != null)
				{
					CaseTeamTemplateRecord existingTeamMember = GetPredefinedTeamMember(c.Id, ASKHR_CaseService.getPredefinedCaseTeamId(ASKHR_Common.CASE_TEAM_TEMPLATE_CSR_TEAM));

					if (existingTeamMember != null)
					{
						// If contact is already a case team member, delete them, and they will get re-added
						System.debug('Removing User ' + existingTeamMember.TeamTemplateId + ' in Case Team');
						delete existingTeamMember;
					}

					CaseTeamTemplateRecord cttr = new CaseTeamTemplateRecord();
					cttr.ParentId = c.Id;
					cttr.TeamTemplateId = caseTeamTemplateRecord.TeamTemplateId;
					m_CaseTeamTemplateRecords.add(cttr);
				}
			}
		}

		//this rule apply only to ER Case with parent case
		
		if (rtMap.get(c.RecordTypeId).getName().equals(ASKHR_Common.CASE_RECORD_TYPE_NAME_ER_CASE)) {
			addCaseOwnerIntoParent(c);
		} else if (rtMap.get(c.RecordTypeId).getName().equals(ASKHR_Common.CASE_RECORD_TYPE_NAME_GENERAL_HR)) {

			//case owner has changed            
			if (!oldC.OwnerId.equals(c.OwnerId)) {

				if (!ASKHR_CaseService.IsUserQueue(oldC.OwnerId)) {
					//add old case owner as contact
					addCaseOwnerAs(c, oldC.OwnerId, ASKHR_Common.CASE_TEAM_ROLE_CASE_CONTACT);
				}
			}

			if (ASKHR_CaseService.IsUserQueue(c.OwnerId))
			{
				String newCaseOwner = [Select Owner.Name from Case where Id = :c.Id].Owner.Name;
				//if (newCaseOwner != null && newCaseOwner.equals('GHRBS Support'))
				if (newCaseOwner != null && newCaseOwner.equals(ASKHR_Common.QUEUE_GHRBS_SUPPORT))
				{
					if (m_CSRCaseTeamId != null) {
						CaseTeamTemplateRecord existingTeamMember = GetPredefinedTeamMember(c.Id, ASKHR_CaseService.getPredefinedCaseTeamId(ASKHR_Common.CASE_TEAM_TEMPLATE_CSR_TEAM));

						if (existingTeamMember != null)
						{
							// If contact is already a case team member, delete them, and they will get re-added
							System.debug('Removing User ' + existingTeamMember.TeamTemplateId + ' in Case Team');
							delete existingTeamMember;
						}

						CaseTeamTemplateRecord cttr = new CaseTeamTemplateRecord();
						cttr.ParentId = c.Id;
						cttr.TeamTemplateId = m_CSRCaseTeamId;
						m_CaseTeamTemplateRecords.add(cttr);
					}
				}
			}

			//to prevent owner to be in Case Team
			removeNewOwnerFromCaseTeamIfExist(c, c.OwnerId);
		}

	}

	public void afterDelete(SObject so)
	{

	}

	/**
	 * @description This method is called once all records have been processed by the trigger. Use this
	 * method to accomplish any final operations such as creation or updates of other records.
	 */
	public void andFinally()
	{
		if (!m_CaseTeamMembers.isEmpty()) {
			try {
				insert m_CaseTeamMembers;
			}
			catch(Exception e) {
				System.debug('@@@ Error adding user(s) to Case Team : ' + e.getMessage());
			}
		}

		try {
			if (!mCustomCaseTeamNotifiers.isEmpty()) {
				insert mCustomCaseTeamNotifiers;
			}
		} catch(Exception e) {
			System.debug('@@@ Error adding user(s) to CCTN : ' + e.getMessage());
		}

		if (!m_CaseTeamTemplateRecords.isEmpty()) {
			insert m_CaseTeamTemplateRecords;
		}

		if (!m_CaseIdListForReassignment.isEmpty()) {
			if (isRunReassignmentRuleFirst)
			ASKHR_CaseService.triggerCaseAutoAssignmentRuleNow(m_CaseIdListForReassignment);
			else
			ASKHR_CaseService.triggerCaseAutoAssignmentRule(m_CaseIdListForReassignment);
		}

	}

    /**
	 * @description This method is used to check the case team member already exist
	 * @param ctms List of case team members
	 * @param ctm CaseTeamMember to check 
	 * @return IsCaseTeamMemberAlreadyInList if the case team member exist returns true otherwise returns false
	 */
	private boolean IsCaseTeamMemberAlreadyInList(List<CaseTeamMember> ctms, CaseTeamMember ctm)
	{
		for (CaseTeamMember existingCTM : ctms)
		{
			if (existingCTM.MemberId == ctm.MemberId)
			{
				return true;
			}
		}
		return false;
	}

    /**
	 * @description This method is used to check the user is already a case team member then remove and readd back to the case team
	 * @param c case object
	 * @param OwnerId to check whether the case team member or not
	 * @param role string to check current role
	 */
    
	private void addCaseOwnerAs(Case c, Id ownerId, String role) {
		if (!ASKHR_CaseService.IsUserQueue(ownerId))
		{
			Id id = c.Id;
			//if (role != null && role.equals('CSR Tier 1 Visibility to GHRBS'))
			if (role != null && role.equals(ASKHR_Common.CASE_TEAM_ROLE_CASE_TIER1))
                
			id = c.ParentId;

			CaseTeamMember existingTeamMember = ASKHR_CaseService.IsUserAlreadyCaseTeamMember(id, ownerId, null);
			if (existingTeamMember != null)
			{
				// If contact is already a case team member, delete them, and they will get re-added
				System.debug('Removing User ' + existingTeamMember.MemberId + ' from Contact Role in Case Team');
				delete existingTeamMember;
			}

			// Add Old Case Owner to current Case Team, as the Contact
			System.debug('Adding User ' + ownerId + ' to Case Team as Owner');
			CaseTeamMember ctm = new CaseTeamMember();
			ctm.ParentId = id;
			ctm.MemberId = ownerId;
			ctm.TeamRoleId = m_CaseTeamRoles.get(role);
			m_CaseTeamMembers.add(ctm);
		}
	}

     /**
	 * @description This method is used to remove new owner from the case team if already exist
	 * @param c case object to check for the current case Id
	 * @param newOwnerId Id to check whether the case team member or not
	 */
	private void removeNewOwnerFromCaseTeamIfExist(Case c, Id newOwnerId) {
		if (!ASKHR_CaseService.IsUserQueue(newOwnerId)) {
			//if ever the old owner become the current case owner again, remove the owner from case team 
			CaseTeamMember existingTeamMember = ASKHR_CaseService.IsUserAlreadyCaseTeamMember(c.Id, newOwnerId, null);
			if (existingTeamMember != null)
			{
				// If contact is already a case team member, delete them, and they will get re-added
				System.debug('Removing User ' + existingTeamMember.MemberId + ' from Contact Role in Case Team');
				delete existingTeamMember;
			}
		}
	}

     /**
	 * @description This method is used to add child case owner as a case team member of parent case and
	 * also to Delete and readd the case owner from parent case team,this will remove old case owner 
	 * and readd the new owner 
	 * @param c case object to check for the current case Id and parent case id
	 * @param newOwnerId Id to check for the case team member
	 */
    
	private void addCaseOwnerIntoParent(Case c) {

		if (c.ParentId != null) {
			//check if current case owner already a case team member in the parent case
			Case parentCase = [Select Id, RecordTypeId, OwnerId from Case where Id = :c.ParentId];

			if (rtMap.get(parentCase.RecordTypeId).getName().equals(ASKHR_Common.CASE_RECORD_TYPE_NAME_GENERAL_HR)) {
				System.debug('Parent is GHR Case');

				CaseTeamMember existingTeamMember = ASKHR_CaseService.IsUserAlreadyCaseTeamMember(parentCase.Id, null, m_CaseTeamRoles.get(ASKHR_Common.CASE_TEAM_ROLE_CHILD_CASE_CONTACT));

				//Delete and readd the case owner from parent case team
				//this will remove old case owner and readd the new owner
				if (existingTeamMember != null)
				{
					System.debug('Remove existing case owner ' + existingTeamMember.MemberId + ' in parent case');

					CustomCaseTeamNotifier__c existingCCTN = convertIntoCaseTeamNotifier(existingTeamMember);
					if (existingCCTN != null) delete existingCCTN;

					delete existingTeamMember;

				}

				//if the case owner is not the same with parent case owner 
				//add the case owner
				if (parentCase.OwnerId != c.OwnerId)
				{
					// Add Case Owner to Parent Case Team, as the Child Case Contact
					System.debug('Adding User ' + c.OwnerId + ' to Case Team as Child Case Contact');
					CaseTeamMember ctm = new CaseTeamMember();
					ctm.ParentId = parentCase.Id;
					ctm.MemberId = c.OwnerId;
					ctm.TeamRoleId = m_CaseTeamRoles.get(ASKHR_Common.CASE_TEAM_ROLE_CHILD_CASE_CONTACT);
					m_CaseTeamMembers.add(ctm);
					mCustomCaseTeamNotifiers.add(convertIntoCaseTeamNotifier(ctm));
				}
			} else {
				System.debug('Parent is not GHR Case');
			}
		} else {
			System.debug('Parent Is Null');
		}
	}

    /**
	 * @description This method is used to retrieve Predefined Team Member
	 * @param caseID Id 
	 * @param teamTemplateId Id 
	 */

	private CaseTeamTemplateRecord GetPredefinedTeamMember(Id caseID, String teamTemplateId)
	{
		CaseTeamTemplateRecord[] caseTeamTemplateRecord = [Select ParentId, TeamTemplateId from
		                                                   CaseTeamTemplateRecord where ParentId = :caseID
		                                                   AND TeamTemplateId = :teamTemplateId];

		for (CaseTeamTemplateRecord cttr : caseTeamTemplateRecord)
		{
			System.debug('Case Owner ' + cttr.ParentId + ' is a member of this parent case team.');
			return cttr;
		}
		return null;

	}

    /**
	 * @description This method is used to add the member into the custom case team notifier
	 * @param ctm CaseTeamMember 
	 * @return convertIntoCaseTeamNotifier CustomCaseTeamNotifier__c 
	 */
	private CustomCaseTeamNotifier__c convertIntoCaseTeamNotifier(CaseTeamMember ctm) {

		if (ctm.Id == null) {
			CustomCaseTeamNotifier__c cctn = new CustomCaseTeamNotifier__c();
			cctn.User__c = ctm.MemberId;
			cctn.Case__c = ctm.ParentId;
			return cctn;
		} else {
			CustomCaseTeamNotifier__c[] cctns = [Select Id, Case__c, User__c from CustomCaseTeamNotifier__c where User__c = :ctm.MemberId AND Case__c = :ctm.ParentId LIMIT 1];
			if (cctns.size() > 0) return cctns[0];
			return null;
		}
	}

}