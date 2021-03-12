@isTest
private class ocms_mfc_Notification_Test {

 static testMethod void testGetters() {
 	    ocms_TestContentHelper tch = new ocms_TestContentHelper();
		// Test the default controller
        ocms_mfc_Notification notificationController = new ocms_mfc_Notification();

		List<Map<String,String>> attr_map = new List<Map<String, String>>();
		
		Map<String, String> am = new Map<String, String>();
		am.put('name', 'title');
		am.put('value', 'title');
		am.put('type', 'text');
		attr_map.add(am);

		am = new Map<String, String>();
		am.put('name', 'message');
		am.put('value', 'message');
		am.put('type', 'text');
		attr_map.add(am);

		am = new Map<String, String>();
		am.put('name', 'altText');
		am.put('value', 'altText');
		am.put('type', 'text');
		attr_map.add(am);

		am = new Map<String, String>();
		am.put('name', 'image');
		am.put('value', 'image');
		am.put('type', 'text');
		attr_map.add(am);

		am = new Map<String, String>();
		am.put('name', 'link');
		am.put('value', 'link');
		am.put('type', 'text');
		attr_map.add(am);

		tch.createContent(attr_map, 'Notifications');

		notificationController = new ocms_mfc_Notification(tch.gc);
		
		List<Map<String,String>> testAttributes = new List<Map<String, String>>();
		tch = new ocms_TestContentHelper();

		am = new Map<String, String>();
		am.put('name', 'mandatoryAppIDs');
		am.put('value', 'test');
		am.put('type', 'text');
		testAttributes.add(am);
		
		tch.createContent(testAttributes, 'SitePreferences', false);

		ocms_mfc_SiteSettings__c sitePreferenceCustomSetting = new ocms_mfc_SiteSettings__c();
		sitePreferenceCustomSetting.Name = 'Manulife Central';
		sitePreferenceCustomSetting.Site_Preferences_Id__c = tch.gc.content.Id;

		insert sitePreferenceCustomSetting;

		String getHTML = notificationController.getHTML();
		String originId = notificationController.versionOriginId;
		System.assertEquals(notificationController.title, 'title', 'Expected title got: ' + notificationController.Title);
		System.assertEquals(notificationController.Message, 'message', 'Expected message got: ' + notificationController.Message);
		System.assertEquals(notificationController.AltText, 'altText', 'Expected altText got: ' + notificationController.AltText);
		System.assertEquals(notificationController.Image, 'image', 'Expected image got: ' + notificationController.Image);
		System.assertEquals(notificationController.Link, 'link', 'Expected link got: ' + notificationController.Link);
    }
}