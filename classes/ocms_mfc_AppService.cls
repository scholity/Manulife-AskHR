global without sharing class ocms_mfc_AppService implements cms.ServiceInterface {
	public ocms_mfc_AppService() { }
	public System.Type getType() { return ocms_mfc_AppService.class; }

	public String executeRequest(Map<String, String> p) {
		String action = p.get('action');
		String response = '{"success": false, "message" : "Action not supported"}';
		
		ocms_mfc_App App = new ocms_mfc_App();

		if (action == 'getFullAppListForUser') {
			response = '{"success": true, "apps": ' + JSON.serialize(App.getFullAppListForUser(UserInfo.getUserId())) + '}';
		} else if (action == 'getFullApplList') {
			response = '{"success": true, "apps": ' + JSON.serialize(App.getFullAppList('')) + '}';
		} else if (action == 'getFavouriteAppsForUser') {
			response = '{"success": true, "apps": ' + JSON.serialize(App.getMostUsedApplications(UserInfo.getUserId(), true)) + '}';
		} else if (action == 'addViewToApp') {
			response = '{"success": true, "app": ' + JSON.serialize(App.addViewToApp(p.get('applicationId'), UserInfo.getUSerId())) + '}';
		} else if (action == 'subscribeToApp') {
			response = '{"success": true, "app": ' + JSON.serialize(App.subscribeToApp(p.get('applicationId'), UserInfo.getUSerId())) + '}';
		} else if (action == 'unsubscribeToApp') {
			response = '{"success": ' + App.unsubscribeToApp(p.get('applicationId'), UserInfo.getUSerId()) + '}';
		} else if (action == 'getFullAppListByName') {
			response = '{"success": true, "apps": ' + JSON.serialize(App.getFullAppListByName()) + '}';
		} else if (action == 'getAppSubscriptionStatus') {
			response = '{"success": true, "applicationId": "' + p.get('applicationId') + '", "isSubscribed" : ' + App.getSubscriptionStatus(UserInfo.getUserId(), p.get('applicationId')) + '}';
		}

		return response;
	}
}