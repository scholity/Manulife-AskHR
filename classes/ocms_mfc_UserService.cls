global without sharing class ocms_mfc_UserService implements cms.ServiceInterface {
	public ocms_mfc_UserService() { }
	public System.Type getType() { return ocms_mfc_UserService.class; }

	public String executeRequest(Map<String, String> p) {
		String action = p.get('action');
		String response = '{"success": false, "message" : "Action not supported"}';
	
		if (action == 'getAnalyticsData') {
			response = '{"success": true, "userinfo": ' + JSON.serialize(ocms_mfc_UserService.getAnalyticsUserData()) + '}';
		} 

		return response;
	}

	public static User getAnalyticsUserData() {
		String currentUserId = UserInfo.getUserId();

		User currentUser = Database.query('SELECT Id, City__c, MFC_Country__c, MFC_Division__c, Business_Unit__c, LanguageLocaleKey, FederationIdentifier FROM User WHERE Id = :currentUserId');
				
		return currentUser;
	}
}