/**
* @author 
* @description Common method use for User object
*/

public without sharing class ASKHR_UserService {
	/*  @description 
     *  @param 
     *  @return   
     */
    public static Map<String, User_Language_Based_Config__c> getUserLanguageBasedConfigs() {
		List<User_Language_Based_Config__c> userLanguageBasedConfigList = User_Language_Based_Config__c.getAll().values();
		Map<String, User_Language_Based_Config__c> userLanguageBasedConfigMap = new Map<String, User_Language_Based_Config__c> ();
		for (User_Language_Based_Config__c userLanguageBasedConfig : userLanguageBasedConfigList) {
			userLanguageBasedConfigMap.put(userLanguageBasedConfig.Name, userLanguageBasedConfig);
		}
		return userLanguageBasedConfigMap;
	}
    
    /*  @description 
     *  @param 
     *  @return   
     */

	public static Map<String, User_Country_Code_Based_Config__c> getUserCountryCodeBasedConfigs() {
		List<User_Country_Code_Based_Config__c> userCountryCodeBasedConfigList = User_Country_Code_Based_Config__c.getAll().values();
		Map<String, User_Country_Code_Based_Config__c> userCountryCodeBasedConfigMap = new Map<String, User_Country_Code_Based_Config__c> ();
		for (User_Country_Code_Based_Config__c userCountryCodeBasedConfig : userCountryCodeBasedConfigList) {
			userCountryCodeBasedConfigMap.put(userCountryCodeBasedConfig.Name, userCountryCodeBasedConfig);
		}
		return userCountryCodeBasedConfigMap;
	}
	/*  @description 
     *  @param 
     *  @return   
     */
	public static Map<String, Communities_Profile_Role_Mapping__c> getCommunitiesProfileRoleMapping() {
		List<Communities_Profile_Role_Mapping__c> communitiesProfileRoleMappingList = Communities_Profile_Role_Mapping__c.getAll().values();
		Map<String, Communities_Profile_Role_Mapping__c> communitiesProfileRoleMappingMap = new Map<String, Communities_Profile_Role_Mapping__c> ();
		for (Communities_Profile_Role_Mapping__c communitiesProfileRoleMapping : communitiesProfileRoleMappingList) {
			communitiesProfileRoleMappingMap.put(communitiesProfileRoleMapping.Name, communitiesProfileRoleMapping);
		}
		return communitiesProfileRoleMappingMap;
	}
	/*  @description 
     *  @param 
     *  @return   
     */
	public static Map<String, Map<String, String>> getCountryStateTimeZoneMapping() {
		List<Country_State_TimeZone_Mapping__c> countryStateTimeZoneMappingList = Country_State_TimeZone_Mapping__c.getAll().values();
		Map<String, Map<String, String>> countryStateTimeZoneMappingMap = new Map<String, Map<String, String>> ();
		for (Country_State_TimeZone_Mapping__c countryStateTimeZoneMapping : countryStateTimeZoneMappingList) {
			Map<String, String> stateTimeZoneForCountry = countryStateTimeZoneMappingMap.get(countryStateTimeZoneMapping.Country__c);
			if (stateTimeZoneForCountry == null) {
				stateTimeZoneForCountry = new Map<String, String> ();
			}
			stateTimeZoneForCountry.put(countryStateTimeZoneMapping.State__c, countryStateTimeZoneMapping.TimeZoneSidKey__c);
			countryStateTimeZoneMappingMap.put(countryStateTimeZoneMapping.Country__c, stateTimeZoneForCountry);
		}
		return countryStateTimeZoneMappingMap;
	}

	/*  @description 
     *  @param -
     *  @return   
     */
	public static Map<String, Id> getPermissionSetIdsByName() {
		List<PermissionSet> permissionSets = [Select Id, Name from PermissionSet];
		Map<String, Id> permissionSetIdsByName = new Map<String, Id> ();
		for (PermissionSet pSet : permissionSets) {
			permissionSetIdsByName.put(pSet.Name, pSet.Id);
		}
		return permissionSetIdsByName;
	}
	/*  @description 
     *  @param contacts_JSON
     *  @return - 
     */
	@future
	public static void upsertContacts(String contacts_JSON) {
		List<Contact> contacts = (List<Contact>) JSON.deserialize(contacts_JSON, List<Contact>.class);

		if (Test.isRunningTest()) {
			Contact c = new Contact();
			c.FirstName = 'First Test';
			c.LastName = 'Last Test';
			contacts.add(c);
		}

		Schema.SObjectField f = Contact.Fields.Id;
		Database.UpsertResult[] results = Database.upsert(contacts, f, false);
		List<String> errorMessage = new List<String> ();
		// Iterate through each returned result
		String strError = '';
		Integer index = 0;
		integer countFailedOperation = 0;
		for (Database.UpsertResult sr : results) {
			if (!sr.isSuccess()) {
				// Operation failed, so get all errors                
				for (Database.Error err : sr.getErrors()) {
					strError = '--------------------------------------------------\n';
					strError += 'The following error has occurred.-' + err.getStatusCode() + ': ' + err.getMessage() + '\n';
					if (contacts != null && !contacts.isEmpty() && contacts.size() > index) {
						Contact ctc = contacts.get(index);
						strError += 'Contact failed: ' + ctc.FirstName + ' ' + ctc.LastName + ',' + ctc.Email + ',' + ctc.Employee_Number__c + '\n';
					}
					strError += '--------------------------------------------------\n';
					errorMessage.add(strError);
				}
				countFailedOperation++;
			}

			index++;
		}

		if (!errorMessage.isEmpty()) {
			errorMessage.add(0, 'Failed operations: ' + countFailedOperation + ' of ' + results.size());
			ASKHR_NotificationUtils.sendEmailNotification('ASKHR-UserService.upsertContacts', string.join(errorMessage, '\n'));
		}
	}
	/*  @description 
     *  @param newPermissionSetAssignments
     *  @return - 
     */
	public static void insertPermissionSets(List<PermissionSetAssignment> newPermissionSetAssignments) {
		System.debug('About to insert Permission Sets ' + newPermissionSetAssignments);

		//for unit testing, mock faulty psa 
		if (Test.isRunningTest()) {
			newPermissionSetASsignments.add(new PermissionSetAssignment());
		}

		Database.SaveResult[] results = Database.insert(newPermissionSetAssignments, false);
		List<String> errorMessage = new List<String> ();
		// Iterate through each returned result
		String strError = '';
		Integer index = 0;
		integer countFailedOperation = 0;
		for (Database.SaveResult sr : results) {
			if (!sr.isSuccess()) {
				// Operation failed, so get all errors                
				for (Database.Error err : sr.getErrors()) {
					strError = '--------------------------------------------------\n';
					strError += 'The following error has occurred.-' + err.getStatusCode() + ': ' + err.getMessage() + '\n';
					if (newPermissionSetAssignments != null && !newPermissionSetAssignments.isEmpty() && newPermissionSetAssignments.size() > index) {
						PermissionSetAssignment psa = newPermissionSetAssignments.get(index);
						strError += 'User failed: ' + psa.AssigneeId + '\n';
						strError += 'Permission Set to insert: ' + psa.PermissionSetId + '\n';
					}
					strError += '--------------------------------------------------\n';
					errorMessage.add(strError);
				}
				countFailedOperation++;
			}

			index++;
		}

		if (!errorMessage.isEmpty()) {
			errorMessage.add(0, 'Failed operations: ' + countFailedOperation + ' of ' + results.size());
			ASKHR_NotificationUtils.sendEmailNotification('ASKHR-UserService.insertPermissionSets', string.join(errorMessage, '\n'));
		}
	}
    
	/*  @description 
     *  @param permissionSetAssignmentsToBeDeleted
     *  @return - 
     */
	public static void deletePermissionSets(List<PermissionSetAssignment> permissionSetAssignmentsToBeDeleted) {
		System.debug('About to delete Permission Sets ' + permissionSetAssignmentsToBeDeleted);

		Database.DeleteResult[] results = Database.delete(permissionSetAssignmentsToBeDeleted, false);
		List<String> errorMessage = new List<String> ();
		// Iterate through each returned result
		String strError = '';
		Integer index = 0;
		integer countFailedOperation = 0;
		for (Database.DeleteResult sr : results) {
			if (!sr.isSuccess()) {
				// Operation failed, so get all errors                
				for (Database.Error err : sr.getErrors()) {
					strError = '--------------------------------------------------\n';
					strError += 'The following error has occurred.-' + err.getStatusCode() + ': ' + err.getMessage() + '\n';
					if (permissionSetAssignmentsToBeDeleted != null && !permissionSetAssignmentsToBeDeleted.isEmpty() && permissionSetAssignmentsToBeDeleted.size() > index) {
						PermissionSetAssignment psa = permissionSetAssignmentsToBeDeleted.get(index);
						strError += 'User failed: ' + psa.AssigneeId + '\n';
						strError += 'Permission Set to delete: ' + psa.PermissionSetId + '\n';
					}
					strError += '--------------------------------------------------\n';
					errorMessage.add(strError);
				}
				countFailedOperation++;
			}

			index++;
		}

		if (!errorMessage.isEmpty()) {
			errorMessage.add(0, 'Failed operations: ' + countFailedOperation + ' of ' + results.size());
			ASKHR_NotificationUtils.sendEmailNotification('ASKHR-UserService.deletePermissionSets', string.join(errorMessage, '\n'));
		}
	}
	/*  @description 
     *  @param userIds
     *  @return - 
     */
	public static Map<Id, List<PermissionSetAssignment>> getPermissionSetAssignmentsByUserIds(Set<Id> userIds) {
		List<PermissionSetAssignment> psas = [Select Id, AssigneeId, PermissionSetId from PermissionSetAssignment where AssigneeId in :userIds];
		Map<Id, List<PermissionSetAssignment>> permissionSetAssignmentsByUserIdMap = new Map<Id, List<PermissionSetAssignment>> ();
		for (PermissionSetAssignment psa : psas) {
			List<PermissionSetAssignment> psasForUser = permissionSetAssignmentsByUserIdMap.get(psa.AssigneeId);
			if (psasForUser == null) {
				psasForUser = new List<PermissionSetAssignment> ();
			}
			psasForUser.add(psa);
			permissionSetAssignmentsByUserIdMap.put(psa.AssigneeId, psasForUser);
		}
		return permissionSetAssignmentsByUserIdMap;
	}
	/*  @description 
     *  @param newUsersList
     *  @return - 
     */
	public static Map<String, Contact> getContactsByEmployeeIds(List<User> newUsersList) {
		Map<String, Id> userIdsByEmployeeIds = new Map<String, Id> ();
		for (User usr : newUsersList) {
			userIdsByEmployeeIds.put(usr.Employee_Id__c, usr.Id);
		}

		List<Contact> contacts = [Select Id, Employee_Number__c, User__c from Contact where Employee_Number__c in :userIdsByEmployeeIds.keySet()];
		Map<String, Contact> contactsByEmployeeIds = new Map<String, Contact> ();
		for (Contact con : contacts) {
			contactsByEmployeeIds.put(con.Employee_Number__c, con);
		}
		return contactsByEmployeeIds;
	}
	/*  @description 
     *  @param user
     *  @param userRole
     *  @return - 
     */
	public static void addUserToPredefineCaseTeam(User user, String userRole)
	{
        try{
		if (userRole != null && userRole.substring(0, 3).equals('CSR') && !String.isBlank(ASKHR_Common.CASE_TEAM_TEMPLATE_CSR_TEAM) && !String.isBlank(ASKHR_Common.CASE_TEAM_ROLE_CASE_TIER1))
		{
			Id ctrId = [SELECT Id, Name FROM CaseTeamRole WHERE Name = :ASKHR_Common.CASE_TEAM_ROLE_CASE_TIER1].Id;
			String cttId = [SELECT Id, Name FROM CaseTeamTemplate WHERE Name = :ASKHR_Common.CASE_TEAM_TEMPLATE_CSR_TEAM].Id;

			CaseTeamTemplateMember existingTeamMember = ASKHR_CaseService.IsUserAlreadyCaseTeamTemplateMember(user.Id, cttId, ctrId);
			if (existingTeamMember != null)
			{
				// User is already a team member, delete them from the existing team, and then re-add them.
				System.debug('Removing User from Predefined Case Team');
				delete existingTeamMember;
			}

			CaseTeamTemplateMember cttmadd = new CaseTeamTemplateMember();
			cttmadd.MemberId = user.Id;
			cttmadd.TeamRoleId = ctrId;
			cttmadd.TeamTemplateId = cttId;
			insert cttmadd;
			system.debug('adding user into csr team');
		}
        }catch(Exception ex){
            system.debug(ex.getMessage());
            ASKHR_NotificationUtils.sendEmailNotification('ASKHR-UserService.addintopredefined', ex.getMessage());
        }
	}
	/*  @description 
     *  @param newUser
     *  @param oldUser
     *  @param userRole
     *  @param oldUserRole
     *  @return - 
     */
	public static void editUserToPredefineCaseTeam(User newUser, User oldUser, String userRole, String oldUserRole)
	{
	try{
			if (oldUser.UserRoleId != newUser.UserRoleId)
			{  
				if (!String.isBlank(userRole) && !String.isBlank(oldUserRole) && !userRole.substring(0, 3).equals(oldUserRole.substring(0, 3)))
				{
					if (userRole != null && userRole.substring(0, 3).equals('CSR'))
					{
						addUserToPredefineCaseTeam(newUser, userRole);
					}
					else if (oldUserRole != null && oldUserRole.substring(0, 3).equals('CSR'))
					{
						Id ctrId = [SELECT Id, Name FROM CaseTeamRole WHERE Name = :ASKHR_Common.CASE_TEAM_ROLE_CASE_TIER1].Id;
						String cttId = [SELECT Id, Name FROM CaseTeamTemplate WHERE Name = :ASKHR_Common.CASE_TEAM_TEMPLATE_CSR_TEAM].Id;

						List<CaseTeamTemplateMember> cttmaddList = null;

						if (ctrId != null && !String.isBlank(cttId))
						{
							cttmaddList = [Select Id FROM CaseTeamTemplateMember WHERE MemberId = :String.valueOf(oldUser.Id) and TeamRoleId = :ctrId and TeamTemplateId = :cttId];
						}

						if (cttmaddList != null && !cttmaddList.isEmpty())
						{
							for (CaseTeamTemplateMember cttmadd : cttmaddList)
							delete cttmadd;
						}
					}
				}
			}
		}catch(Exception ex){
			system.debug(ex.getMessage());
            ASKHR_NotificationUtils.sendEmailNotification('ASKHR-UserService.editaddintopredefined', ex.getMessage());
		}
	}
	/*  @description 
     *  @param 
     *  @return 
     */
	public static Map<Id, String> getProfileIdMapping() {
		List<Profile> profiles = [Select Id, Name from Profile];
		Map<Id, String> profileIdMapping = new Map<Id, String> ();
		for (Profile profile : profiles) {
			profileIdMapping.put(profile.Id, profile.Name);
		}

		return profileIdMapping;
	}
	/*  @description 
     *  @param 
     *  @return 
     */
	public static Map<Id, String> getRoleIdMapping() {
		List<UserRole> roles = [Select Id, Name from UserRole];
		Map<Id, String> roleIdMapping = new Map<Id, String> ();
		for (UserRole role : roles) {
			roleIdMapping.put(role.Id, role.Name);
		}

		return roleIdMapping;
	}
}