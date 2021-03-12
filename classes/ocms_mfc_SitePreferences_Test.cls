/*
 *  ocms_mfc_SitePreferences_Test
 *
 *  2014-Apr-15 Bill Lucas
 *              using new helper methods from <c ocms_TestContentHelper>
 */

@isTest
private class ocms_mfc_SitePreferences_Test {

	private static final String SITENAME = 'manulife';

	static testMethod void testGetters() {
		// Test the default controller
		ocms_mfc_SitePreferences sitePreferencesController = new ocms_mfc_SitePreferences();
		// Code coverage the mandatory getHTML

		ocms_TestContentHelper tch = new ocms_TestContentHelper(SITENAME);
		List<Map<String,String>> testAttributes = new List<Map<String, String>>();

		List<String> attrNames = new List<String>{
			'locationTaxonomy',
			'divisionTaxonomy',
			'employeeTypeTaxonomy',
			'newsCategoryTaxonomy',
			'appCategoriesTaxonomy',
			'articleCategoriesTaxonomy,/whatever/you/know/here!',
			'notificationsCheckInterval,60000',
			'notificationsMaxLoad',
			'notificationsPerPage',
			'uiLabelMenu,Menu',
			'uiLabelClose,CLOSE',	
			'uiLabelGear,My Preferences',
			'uiLabelBack,BACK',
			'uiLabelBookmark,Bookmark', 			
			'uiLabelShare,Share',
			'uiLabelArtContactInformation,Contact Information',
			'uiLabelArtPrevious,Previous',
			'uiLabelArtNext,Next',
			'uiLabelArtTopics,Topics',
			'uiLabelSearchErrorNoResults,No results found.',
			'uiLabelSearchErrorTimeout,Error timeout,',
			'searchGSARequestTimeout,10,',
			'uiLabelSearchErrorGeneric,Generic error.'
		};

		ocms_TestContentHelper.addToAttributesFromList(testAttributes, attrNames);
		
		tch.createContent(testAttributes, 'SitePreferences');
		sitePreferencesController = new ocms_mfc_SitePreferences(tch.gc);
		
		System.assertEquals(sitePreferencesController.getType(), ocms_mfc_SitePreferences.class, 'Expected ocms_mfc_SitePreferences.class got: ' + sitePreferencesController.getType());

		ocms_TestContentHelper.testAttributeValuesFromList(attrNames, sitePreferencesController);
        
        String getHTML = sitePreferencesController.getHTML();
	}
	
	static testMethod void testGetSitePreferencesData() {
		ocms_TestContentHelper tch = new ocms_TestContentHelper(SITENAME);
		List<Map<String,String>> testAttributes = new List<Map<String, String>>();
		
		Map<String, String> am = new Map<String, String>();
		am.put('name', 'locationTaxonomy');
		am.put('value', 'Test Taxonomy/first');
		am.put('type', 'text');
		testAttributes.add(am);

		am = new Map<String, String>();
		am.put('name', 'notificationsCheckInterval');
		am.put('value', '60000');
		am.put('type', 'text');
		testAttributes.add(am);
		
		
		tch.createContent(testAttributes, 'SitePreferences');
		cms__content__c content = [SELECT ID, cms__Published__c from cms__Content__c];
		
		// Create setting pointing to content
		ocms_mfc_SiteSettings__c settings = new ocms_mfc_SiteSettings__c();
		settings.Name = 'Manulife Central';
		Id sitePreferencesId = content.Id;
		settings.Site_Preferences_Id__c = sitePreferencesId;
		insert(settings);

		ocms_mfc_SitePreferences sitePreferencesController = new ocms_mfc_SitePreferences(tch.gc);
		Map<String, String> preferencesMap = sitePreferencesController.getSitePreferencesData();
		System.assertEquals('Test Taxonomy/first', preferencesMap.get('locationTaxonomy'));
		System.assertEquals('60000', preferencesMap.get('notificationsCheckInterval'));
	}
	
	static testMethod void testExecuteRequest() {
		ocms_TestContentHelper tch = new ocms_TestContentHelper(SITENAME);
		List<Map<String,String>> testAttributes = new List<Map<String, String>>();
		Map<String, String> am = new Map<String, String>();
		am.put('name', 'locationTaxonomy');
		am.put('value', 'Test Taxonomy/first');
		am.put('type', 'text');
		testAttributes.add(am);
		
		tch.createContent(testAttributes, 'SitePreferences');
		ocms_mfc_SitePreferences sitePreferencesController = new ocms_mfc_SitePreferences(tch.gc);
		cms__content__c content = [SELECT ID, cms__Published__c from cms__Content__c];
		
		Map<String, String> p = new Map<String, String>();
		p.put('action', 'setupSitePreferences');
		p.put('thisContentId', content.Id);
		String response = sitePreferencesController.executeRequest(p);
		System.assertEquals('{"success":true, "message": "Created new site preferences"}', response);
		
		p = new Map<String, String>();
		p.put('action', 'test');
		response = sitePreferencesController.executeRequest(p);
		System.assertEquals('{"success": false, "message": "Action not supported."}', response);
	}
	
	static testMethod void testSetupSitePreferencesJSONResponse() {
		ocms_TestContentHelper tch = new ocms_TestContentHelper(SITENAME);
		
		List<Map<String,String>> testAttributes = new List<Map<String, String>>();
		
		Map<String, String> am = new Map<String, String>();
		am.put('name', 'locationTaxonomy');
		am.put('value', 'Test Taxonomy/first');
		am.put('type', 'text');
		testAttributes.add(am);
		
		tch.createContent(testAttributes, 'SitePreferences');
		ocms_mfc_SitePreferences sitePreferencesController = new ocms_mfc_SitePreferences(tch.gc);
		cms__content__c content = [SELECT ID, cms__Published__c from cms__Content__c];
		
		String response = sitePreferencesController.setupSitePreferencesJSONResponse(content.Id);
		System.assertEquals('{"success":true, "message": "Created new site preferences"}', response, response);
		
		response = sitePreferencesController.setupSitePreferencesJSONResponse(content.Id);
		System.assertEquals('{"success":true, "message": "Site preferences already exists"}', response, response);
		
		response = sitePreferencesController.setupSitePreferencesJSONResponse('invalid');
		System.assertEquals('{"success":false, "message": "Content error"}', response, response);
	}
}