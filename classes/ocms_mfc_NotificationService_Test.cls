@isTest
private class ocms_mfc_NotificationService_Test {
	
	private static void setup() {
		ocms_TestContentHelper tch = new ocms_TestContentHelper();
		tch.createContent(new List<Map<String, String>>(), 'Notification');

		List<Map<String,String>> testAttributes = new List<Map<String, String>>();
		tch = new ocms_TestContentHelper();

		Map<String, String> am = new Map<String, String>();
		am.put('name', 'mandatoryAppIDs');
		am.put('value', 'test');
		am.put('type', 'text');
		testAttributes.add(am);
		
		tch.createContent(testAttributes, 'SitePreferences', false);

		ocms_mfc_SiteSettings__c sitePreferenceCustomSetting = new ocms_mfc_SiteSettings__c();
		sitePreferenceCustomSetting.Name = 'Manulife Central';
		sitePreferenceCustomSetting.Site_Preferences_Id__c = tch.gc.content.Id;

		insert sitePreferenceCustomSetting;

	}
	static testMethod void testExecuteRequest() {
		

		setup();
		//public String executeRequest(Map<String, String> p) {
		String failResponse = '{"success":false,"message":"Action not supported."}';
		ocms_mfc_NotificationService notificationService = getNotificationService();
		
		Map<String, String> executeMap = new Map<String, String>();
		String response = notificationService.executeRequest(executeMap);
		System.assertEquals(response, failResponse, 'Expected ' + failResponse);
		
		
		executeMap = new Map<String, String>();
		executeMap.put('action','fakeAction');
		response = notificationService.executeRequest(executeMap);
		
		System.assertEquals(response, failResponse, 'Expected ' + failResponse);
	}
	
	private static ocms_mfc_NotificationService getNotificationService() {
		return new ocms_mfc_NotificationService();
	}
	
	static testMethod void testGetType() {
		setup();
		ocms_mfc_NotificationService notificationService = getNotificationService();
		System.assertEquals(notificationService.getType(),ocms_mfc_NotificationService.class, 'Expected ocms_mfc_NotificationService.class got: ' + notificationService.getType());
	}
	
	static testMethod void getUnreadCount() {
		setup();
		ocms_mfc_NotificationService notificationService = getNotificationService();
		Map<String, String> executeMap = new Map<String, String>();
		executeMap.put('action','getUnreadCount');
		executeMap.put('widgetTitle','false');
		
		String testerino = '';
		String response = notificationService.executeRequest(executeMap);
		String failResponse = '{"success":false,"message":"Action not supported."}';
		String getUnreadCountCorrectResponse = '{"success":' + 'true' + ',"unread":1}';
		
		System.assertNotEquals(response, failResponse, 'Not Expected ' + failResponse);
		System.assertEquals(getUnreadCountCorrectResponse, response);
		
		getUnreadCountCorrectResponse = '{"success":' + 'true' + ',"unread":1}';
		executeMap = new Map<String, String>();
		executeMap.put('action','getUnreadCount');
		executeMap.put('widgetTitle','true');
		response = notificationService.executeRequest(executeMap);
		System.assertEquals(response, getUnreadCountCorrectResponse);
	}
	
	static testMethod void testGetLatestContent() {
		setup();
		ocms_mfc_NotificationService notificationService = getNotificationService();
		Map<String, String> executeMap = new Map<String, String>();
		executeMap.put('action','getLatestContent');
		String response = notificationService.executeRequest(executeMap);
		String failResponse = '{"success":false,"message":"Action not supported."}';
		System.assertEquals(response, failResponse, 'Expected ' + failResponse);
		
		executeMap = new Map<String, String>();
		executeMap.put('action','getLatestContent');
		executeMap.put('amount','5');
		response = notificationService.executeRequest(executeMap);
		System.assertNotEquals(response, failResponse, 'Not Expected ' + response);
	}
	
	static testMethod void testGetNotificationPage() {
		setup();
		ocms_mfc_NotificationService notificationService = getNotificationService();
		Map<String, String> executeMap = new Map<String, String>();
		executeMap.put('action','getNotificationPage');
		String response = notificationService.executeRequest(executeMap);
		String failResponse = '{"success":false,"message":"Action not supported."}';
		System.assertEquals(response, failResponse, 'Expected ' + failResponse);
		
		executeMap = new Map<String, String>();
		executeMap.put('action','getNotificationPage');
		executeMap.put('amount','5');
		response = notificationService.executeRequest(executeMap);
		System.assertNotEquals(response, failResponse, 'Not Expected ' + response);
	}
	
	static testMethod void testUpdateLastVisited() {
		setup();
		ocms_mfc_NotificationService notificationService = getNotificationService();
		Map<String, String> executeMap = new Map<String, String>();
		executeMap.put('action','updateLastVisited');
		String response = notificationService.executeRequest(executeMap);
		String updateLastVisitedResponse = '{"success":' + true + '}';
	}
}