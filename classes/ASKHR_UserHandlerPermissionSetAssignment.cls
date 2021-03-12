/**
  * @author Mohamad Ammar Amran <mohamadammar_amran@manulife.com>
  * @description class for handling adding permissionset based on Employee Country and MFCentral.
*/
public without sharing class ASKHR_UserHandlerPermissionSetAssignment {


	/**
	 * @description Check and Add permission set to user based on their Pay_Country and Add MFCentral Permission set
	 * @param JSON_user the list of user in JSON format
	 */
	@future
	public static void checkAndAddPermissionSet(String JSON_user) {
		Map<String, Id> m_PermissionSetIdsByName = ASKHR_UserService.getPermissionSetIdsByName();
		Map<String, User_Country_Code_Based_Config__c> m_UserCountryCodeBasedConfigs = ASKHR_UserService.getUserCountryCodeBasedConfigs();
		List<PermissionSetAssignment> newPermissionSetAssignments = new List<PermissionSetAssignment> ();

		List<User> users = (List<User>) JSON.deserialize(JSON_user, List<User>.class);
		List<Id> userIds = new List<Id> ();
		for (User u : users) {
			userIds.add(u.Id);
		}

		List<PermissionSetAssignment> permissionSetList = [Select AssigneeId, PermissionSetId from PermissionSetAssignment where AssigneeId in :userIds];

		for (User userObj : users) {
			PermissionSetAssignment psa = new PermissionSetAssignment();
			psa.AssigneeId = userObj.Id;
			System.debug('**** value of psa assigneeID ' + psa.AssigneeId);
			if (m_UserCountryCodeBasedConfigs.get(userObj.Pay_Country__c) != null)
			{
				if (m_PermissionSetIdsByName.get(m_UserCountryCodeBasedConfigs.get(userObj.Pay_Country__c).PermissionSetName__c) != null)
				{
					psa.PermissionSetId = m_PermissionSetIdsByName.get(m_UserCountryCodeBasedConfigs.get(userObj.Pay_Country__c).PermissionSetName__c);

					//check if the employee already assigned with the permission set. if not then assign
					if (!isPermissionSetAssigned(permissionSetList, psa))
					{
						System.debug('****checkAndAddPermissionSet: New permission to be assigned is ' + m_UserCountryCodeBasedConfigs.get(userObj.Pay_Country__c).PermissionSetName__c);
						newPermissionSetAssignments.add(psa);
					}

				}
			}

			//checking for MFCentral permission set. add new if not exist
			PermissionSetAssignment psaMFCentral = new PermissionSetAssignment();
			psaMFCentral.AssigneeId = userObj.Id;
			psaMFCentral.PermissionSetId = m_PermissionSetIdsByName.get(mfc_Common.DEFAULT_MFCENTRAL_Permission_Set);
			if (!isPermissionSetAssigned(permissionSetList, psaMFCentral)) {
				newPermissionSetAssignments.add(psaMFCentral);
			}
		}

		ASKHR_UserService.insertPermissionSets(newPermissionSetAssignments);
	}


	/*  @description Check if the permission set is already assigned to the user or not
	 *  @param permissionSetList List of PermissionSetAssignment as reference to verify 
	 *  @param psa PermissionSetAssignment to compare 
	 *  @return Boolean PermissionSet has been assigned to user, true - Yes, false - NO
	 *  
	 */
	private static Boolean isPermissionSetAssigned(List<PermissionSetAssignment> permissionSetList, PermissionSetAssignment psa) {

		String psaAssigneeId = getLongId(psa.AssigneeId);
		String psaPermissionSetId = getLongId(psa.PermissionSetId);

		for (PermissionSetAssignment p : permissionSetList) {
			String assigneeId = getLongId(p.AssigneeId);
			String permissionSetId = getLongId(p.PermissionSetId);

			if (assigneeId.equals(psaAssigneeId) && permissionSetId.equals(psaPermissionSetId)) {
				return true;
			}
		}

		return false;
	}

	//SF somehow will return 15 digit id, so this method is to ensure that comparison works
	@TestVisible
    private static String getLongId(String currentId) {
        if(currentId.length() < 18){
            String suffix = '';
            integer flags;
            
            for (integer i = 0; i < 3; i++) {
                flags = 0;
                for (integer j = 0; j < 5; j++) {
                    string c = currentId.substring(i * 5 + j, i * 5 + j + 1);
                    //Only add to flags if c is an uppercase letter:
                    if (c.toUpperCase().equals(c) && c >= 'A' && c <= 'Z') {
                        flags = flags + (1 < < j);
                    }
                }
                if (flags <= 25) {
                    suffix = suffix + 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.substring(flags, flags + 1);
                } else {
                    suffix = suffix + '012345'.substring(flags - 25, flags - 24);
                }
            }
            
            //18 Digit Id with checksum
            //System.debug(' ::::::: ' + currentId + suffix);
            String longId = currentId + suffix;
            return longId;
        }else{
            return currentId;
        }
		
	}
}