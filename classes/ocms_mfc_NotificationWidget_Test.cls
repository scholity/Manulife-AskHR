@isTest
private class ocms_mfc_NotificationWidget_Test {
	static testMethod void testGetters() {
		ocms_TestContentHelper tch = new ocms_TestContentHelper();
		// Test the default controller
		ocms_mfc_NotificationWidget notificationWidgetController = new ocms_mfc_NotificationWidget();
		
		List<Map<String,String>> attr_map = new List<Map<String, String>>();
		
		Map<String, String> am = new Map<String, String>();
		am.put('name', 'heading');
		am.put('value', 'heading');
		am.put('type', 'text');
		attr_map.add(am);

		am = new Map<String, String>();
		am.put('name', 'countText');
		am.put('value', '[count] freddy [count]');
		am.put('type', 'text');
		attr_map.add(am);
		
		tch.createContent(attr_map, 'NotificationWidget');
		
		//String versionOriginId = notificationWidgetController.versionOriginId;
		notificationWidgetController = new ocms_mfc_NotificationWidget(tch.gc);
		String getHTML = notificationWidgetController.getHTML();
		//String originId = notificationWidgetController.versionOriginId;
		
		System.assertEquals(notificationWidgetController.heading, 'heading');
		System.assertEquals(notificationWidgetController.countText, '[count] freddy [count]');
	}
}