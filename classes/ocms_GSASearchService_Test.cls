@isTest
private class ocms_GSASearchService_Test {
	static testMethod void testSuggest() {
        ocms_mfc_SiteSettings__c sitePreferenceCustomSetting = new ocms_mfc_SiteSettings__c();
        sitePreferenceCustomSetting.Name = 'Manulife Central';
        sitePreferenceCustomSetting.GSA_MLI_Endpoint__c = 'http://gsaextranetd.manulife.com';
        sitePreferenceCustomSetting.GSA_MFC_Endpoint__c = 'https://gsaintranetd.manulife.com';
        sitePreferenceCustomSetting.GSA_Client_Certificate_Name__c = '';

        insert sitePreferenceCustomSetting;

		ocms_GSASearchService SearchController = new ocms_GSASearchService();

		Map<String, String> params = new Map<String, String>();
		params.put('q', 'Manulife');
		params.put('action', 'getMFCSuggest');

        ocms_SingleRequestMock fakeResponse = new ocms_SingleRequestMock(200, 'Complete', '[{"Name": "sForceTest1"}]', null);
		Test.setMock(HttpCalloutMock.class, fakeResponse);

		String response = SearchController.executeRequest(params);
		System.debug(response);

		params = new Map<String, String>();
		params.put('q', 'Manulife');
		params.put('action', 'getCOMSuggest');
		response = SearchController.executeRequest(params);
	}

	static testMethod void testFailedSuggest() {
		ocms_mfc_SiteSettings__c sitePreferenceCustomSetting = new ocms_mfc_SiteSettings__c();
        sitePreferenceCustomSetting.Name = 'Manulife Central';
        sitePreferenceCustomSetting.GSA_MLI_Endpoint__c = 'http://gsaextranetd.manulife.com';
        sitePreferenceCustomSetting.GSA_MFC_Endpoint__c = 'https://gsaintranetd.manulife.com';
        sitePreferenceCustomSetting.GSA_Client_Certificate_Name__c = '';

        insert sitePreferenceCustomSetting;
        
		ocms_GSASearchService SearchController = new ocms_GSASearchService();

		Map<String, String> params = new Map<String, String>();
		params.put('action', 'getMFCSuggest');

        ocms_SingleRequestMock fakeResponse = new ocms_SingleRequestMock(400, 'Bad Request', '[{"Name": "sForceTest1"}]', null);
		Test.setMock(HttpCalloutMock.class, fakeResponse);

		String response = SearchController.executeRequest(params);
		System.debug(response);
		
		params = new Map<String, String>();
		params.put('q', 'Manulife');
		params.put('action', 'getCOMSuggest');
		response = SearchController.executeRequest(params);
	}

	static testMethod void testSearch() {
		ocms_mfc_SiteSettings__c sitePreferenceCustomSetting = new ocms_mfc_SiteSettings__c();
		sitePreferenceCustomSetting.Name = 'Manulife Central';
		sitePreferenceCustomSetting.GSA_MLI_Endpoint__c = 'http://gsaextranetd.manulife.com';
		sitePreferenceCustomSetting.GSA_MFC_Endpoint__c = 'https://gsaintranetd.manulife.com';
		sitePreferenceCustomSetting.GSA_Client_Certificate_Name__c = '';

		insert sitePreferenceCustomSetting;

		ocms_GSASearchService SearchController = new ocms_GSASearchService();

		Map<String, String> params = new Map<String, String>();
		params.put('q', 'Manulife');
		params.put('action', 'getMFCResults');
		params.put('sOrder', 'asc');

        ocms_SingleRequestMock fakeResponse = new ocms_SingleRequestMock(200, 'Complete', '[{"Name": "sForceTest1"}]', null);
		Test.setMock(HttpCalloutMock.class, fakeResponse);

		String response = SearchController.executeRequest(params);

		Cookie usernameCookie = new Cookie('USERNAME', '999999', null, -1, false);
		ApexPages.currentPage().setCookies(new Cookie[]{usernameCookie});

		Cookie gsaCookie = new Cookie('GSA_SESSION_ID', 'value', null, -1, false);
		ApexPages.currentPage().setCookies(new Cookie[]{gsaCookie});

		params = new Map<String, String>();
		params.put('q', 'Manulife');
		params.put('action', 'getMFCResults');
		params.put('sOrder', 'asc');
		response = SearchController.executeRequest(params);

		params = new Map<String, String>();
		params.put('q', 'Manulife');
		params.put('action', 'getCOMResults');
		params.put('sOrder', 'desc');
		response = SearchController.executeRequest(params);
	}

	static testMethod void testFailedSearch() {
        ocms_mfc_SiteSettings__c sitePreferenceCustomSetting = new ocms_mfc_SiteSettings__c();
        sitePreferenceCustomSetting.Name = 'Manulife Central';
        sitePreferenceCustomSetting.GSA_MLI_Endpoint__c = 'http://gsaextranetd.manulife.com';
        sitePreferenceCustomSetting.GSA_MFC_Endpoint__c = 'https://gsaintranetd.manulife.com';
        sitePreferenceCustomSetting.GSA_Client_Certificate_Name__c = '';

        insert sitePreferenceCustomSetting;

		ocms_GSASearchService SearchController = new ocms_GSASearchService();

		Map<String, String> params = new Map<String, String>();
		params.put('action', 'getMFCResults');

        ocms_SingleRequestMock fakeResponse = new ocms_SingleRequestMock(400, 'Bad Request', '[{"Name": "sForceTest1"}]', null);
		Test.setMock(HttpCalloutMock.class, fakeResponse);

		String response = SearchController.executeRequest(params);
		System.debug(response);
		
		params = new Map<String, String>();
		params.put('q', 'Manulife');
		params.put('action', 'getCOMResults');
		response = SearchController.executeRequest(params);
	}

	static testMethod void testSearchGetType() {
		ocms_mfc_SiteSettings__c sitePreferenceCustomSetting = new ocms_mfc_SiteSettings__c();
		sitePreferenceCustomSetting.Name = 'Manulife Central';
		sitePreferenceCustomSetting.GSA_MLI_Endpoint__c = 'http://gsaextranetd.manulife.com';
		sitePreferenceCustomSetting.GSA_MFC_Endpoint__c = 'https://gsaintranetd.manulife.com';
		sitePreferenceCustomSetting.GSA_Client_Certificate_Name__c = '';

		insert sitePreferenceCustomSetting;

		ocms_GSASearchService SearchController = new ocms_GSASearchService();
		// This code is used for reflection in OrchestraCMS. 
		// Running code to get the code coverage.
		SearchController.getType();
	}
}