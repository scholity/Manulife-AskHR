@isTest
private class ocms_mfc_Taxonomy_Test {
    static testMethod void testGetters() {
        ocms_TestContentHelper tch = new ocms_TestContentHelper();
        List<Map<String,String>> attr_map = new List<Map<String, String>>();
        Map<String, String> am = new Map<String, String>();
        tch.createContent(attr_map, 'mfcTaxonomy');

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

        // Don't know how to get the service api in a test without doing weird stuff like this.
        ocms_mfc_NewsStream newsStreamController = new ocms_mfc_NewsStream(tch.gc);
        cms.ServiceAPI sAPI = newsStreamController.sAPI;
        ocms_mfc_Taxonomy taxonomy = new ocms_mfc_Taxonomy(sAPi);
        User user = ocms_mfc_Taxonomy.user;
        taxonomy.getEmployeeTypeAllPath();
        ocms_mfc_SitePreferences.preferencesMap = new Map<String, String>();
        ocms_mfc_SitePreferences.preferencesMap.put('employeeTypeContributorTaxonomy', '/master/taxonomy/employee/contributor');
        ocms_mfc_SitePreferences.preferencesMap.put('mandatoryNewsPaths', '{"ASD":"/path/here/json"}}');
        taxonomy.getContentIdsForTaxonomies(new List<List<String>>{new List<String>{'/master/taxonomy/cake'}, new List<String>{'/master/taxonomy/bake'}}, 'mfcTaxonomy', 'date', null, null);
        taxonomy.getContentIdsForTaxonomies(new List<List<String>>{new List<String>{'/master/taxonomy/cake'}}, 'mfcTaxonomy', 'date', null, null);
        taxonomy.getContentRenderingsForTaxonomies(new List<List<String>>{new List<String>{'/master/taxonomy/cake'}, new List<String>{'/master/taxonomy/bake'}}, 'mfcTaxonomy',  'template', 'date', null, null);
        taxonomy.getLocationPathList();
        taxonomy.getDivisionPathListForUser();
        taxonomy.getEmployeeTypeAllPath();
        taxonomy.getEmployeeTypePathListForUser();
        taxonomy.getAllNewsCategories();
        taxonomy.getAppCategories();
        taxonomy.getArticleCategories();
        taxonomy.getFeaturedPath();
        ocms_mfc_Taxonomy.getPathsForImmediateChildrenOfPath(sAPi, '/master/path/cake/to', true);
        ocms_mfc_Taxonomy.getPathsForImmediateChildrenOfPath(sAPi, '/master/path/cake/to', false);
        ocms_mfc_Taxonomy.getPathsForChildrenOfPath(sAPI, '/master/path/cake/to', true);
        ocms_mfc_Taxonomy.getPathsForChildrenOfPath(sAPI, '/master/path/cake/to', false);
        ocms_mfc_Taxonomy.getNodeNamesForChildrenOfPath(sAPI, '/master/path/cake/to', true);
        ocms_mfc_Taxonomy.getNodeNamesForChildrenOfPath(sAPI, '/master/path/cake/to', false);
        ocms_mfc_Taxonomy.getChildNodes(sApi, '/master/path/cake/to');
        ocms_mfc_Taxonomy.getTaxonomyNodeInfoAtPath(sApi, '/master/path/cake/to');
    	taxonomy.getUserNewsSubscriptionPaths();
    }
}