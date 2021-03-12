@isTest
private class ocms_mfc_ToolLibrary_Test {

	public static testMethod void getGetters() {
		List<Map<String,String>> testAttributes = new List<Map<String, String>>();

		List<String> attrNames = new List<String>{
			'allToolsHeader',
			'myToolsHeader',
			'removeButtonText',
			'viewGlobalText'
		};
		
		ocms_TestContentHelper tch = new ocms_TestContentHelper();
		ocms_TestContentHelper.addToAttributesFromList(testAttributes, attrNames);

        tch.createContent(testAttributes, '');

        testAttributes = new List<Map<String, String>>();
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
        
        ocms_mfc_ToolLibrary ToolLibraryController = new ocms_mfc_ToolLibrary(tch.gc);

        System.debug(ToolLibraryController.allToolsHeader);
        System.debug(ToolLibraryController.myToolsHeader);
        System.debug(ToolLibraryController.removeButtonText);
        System.debug(ToolLibraryController.viewGlobalText);

        System.debug(ToolLibraryController.getHTML());
	}	
}