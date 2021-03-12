@isTest
private class ocms_mfc_App_Test {

    private static ocms_TestContentHelper createApplication() {
        ocms_TestContentHelper tch = new ocms_TestContentHelper();
        List<Map<String,String>> attr_map = new List<Map<String, String>>();

        Map<String, String> am = new Map<String, String>();
        am.put('name', 'title');
        am.put('value', 'title');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'imageIcon');
        am.put('value', 'imageIcon');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'link');
        am.put('value', 'link');
        am.put('type', 'text');
        attr_map.add(am);

        tch.createContent(attr_map, 'App');

        String appId = tch.gc.content.Id;
        
        List<Map<String,String>> testAttributes = new List<Map<String, String>>();
        
        am = new Map<String, String>();
        am.put('name', 'appCategoriesTaxonomy');
        am.put('value', 'Test Taxonomy/First');
        am.put('type', 'text');
        testAttributes.add(am);

        am = new Map<String, String>();
        am.put('name', 'mandatoryAppIDs');
        am.put('value', appId);
        am.put('type', 'text');
        testAttributes.add(am);
        
        tch.createContent(testAttributes, 'SitePreferences', false);

        ocms_mfc_SiteSettings__c sitePreferenceCustomSetting = new ocms_mfc_SiteSettings__c();
        sitePreferenceCustomSetting.Name = 'Manulife Central';
        sitePreferenceCustomSetting.Site_Preferences_Id__c = tch.gc.content.Id;

        insert sitePreferenceCustomSetting;

        return tch;
    }
    
    static testMethod void testGetFullAppList() {
        String applicationId = ocms_mfc_App_Test.createApplication().gc.content.Id;
        String userId = UserInfo.getUserId();

        List<MFC_Community_Object__c> lAppUserRelations =  Database.query('SELECT Id FROM MFC_Community_Object__c WHERE User__c = :userId');
        System.assertEquals(0, lAppUserRelations.size(), 'Expected no results for lAppUserRelations list in test testSubscribeToApp.  Received: ' + lAppUserRelations.size());

        ocms_mfc_App AppController = new ocms_mfc_App();        
        MFC_Community_Object__c appUserRelation = AppController.subscribeToApp(applicationId, userId);

        AppController.getFullAppList('');
    }


    static testMethod void testGetMostUsedApplications() {
        String applicationId = ocms_mfc_App_Test.createApplication().gc.content.Id;
        String userId = UserInfo.getUserId();

        List<MFC_Community_Object__c> lAppUserRelations =  Database.query('SELECT Id FROM MFC_Community_Object__c WHERE User__c = :userId');
        System.assertEquals(0, lAppUserRelations.size(), 'Expected no results for lAppUserRelations list in test testSubscribeToApp.  Received: ' + lAppUserRelations.size());

        ocms_mfc_App AppController = new ocms_mfc_App();        
        MFC_Community_Object__c appUserRelation = AppController.subscribeToApp(applicationId, userId);

        AppController.getMostUsedApplications(userId, true);
    }

    static testMethod void testGetFullAppListForUser() {
        String applicationId = ocms_mfc_App_Test.createApplication().gc.content.Id;
        String userId = UserInfo.getUserId();

        List<MFC_Community_Object__c> lAppUserRelations =  Database.query('SELECT Id FROM MFC_Community_Object__c WHERE User__c = :userId');
        System.assertEquals(0, lAppUserRelations.size(), 'Expected no results for lAppUserRelations list in test testSubscribeToApp.  Received: ' + lAppUserRelations.size());

        ocms_mfc_App AppController = new ocms_mfc_App();        
        MFC_Community_Object__c appUserRelation = AppController.subscribeToApp(applicationId, userId);

        AppController.getFullAppListForUser(userId);
    }

    static testMethod void testUnsubscribeToApp() {
        String applicationId = ocms_mfc_App_Test.createApplication().gc.content.Id;
        String userId = UserInfo.getUserId();

        ocms_mfc_App AppController = new ocms_mfc_App();        
        Boolean success = AppController.unsubscribeToApp(applicationId, userId);
    }

    static testMethod void testAddViewToApp() {
        String applicationId = ocms_mfc_App_Test.createApplication().gc.content.Id;
        String userId = UserInfo.getUserId();

        List<MFC_Community_Object__c> lAppUserRelations =  Database.query('SELECT Id FROM MFC_Community_Object__c WHERE User__c = :userId');
        System.assertEquals(0, lAppUserRelations.size(), 'Expected no results for lAppUserRelations list in test testSubscribeToApp.  Received: ' + lAppUserRelations.size());

        ocms_mfc_App AppController = new ocms_mfc_App();        
        MFC_Community_Object__c appUserRelation = AppController.subscribeToApp(applicationId, userId);

        System.debug('Adding view to app.');

        AppController.addViewToApp(applicationId, userId);
        
        // Instantiate a new controller since that is how the service is going to be using the App class.
        AppController = new ocms_mfc_App();
        AppController.addViewToApp(applicationId, userId);

        System.debug('Finished adding view to app.');
    }

    static testMethod void testSubscribeToApp() {
        String applicationId = ocms_mfc_App_Test.createApplication().gc.content.Id;
        String userId = UserInfo.getUserId();

        List<MFC_Community_Object__c> lAppUserRelations =  Database.query('SELECT Id FROM MFC_Community_Object__c WHERE User__c = :userId');
        System.assertEquals(0, lAppUserRelations.size(), 'Expected no results for lAppUserRelations list in test testSubscribeToApp.  Received: ' + lAppUserRelations.size());

        ocms_mfc_App AppController = new ocms_mfc_App();        
        MFC_Community_Object__c appUserRelation = AppController.subscribeToApp(applicationId, userId);

        lAppUserRelations =  Database.query('SELECT Id, Content__c, User__c, IsSubscribed__c FROM MFC_Community_Object__c WHERE User__c = :userId AND Content__c = :applicationId');
        System.assertEquals(1, lAppUserRelations.size(), 'Expected a single AppUserRelation for the User: ' + userId + '.  Received: ' + lAppUserRelations.size());
        System.assertEquals(appUserRelation.Content__c, applicationId, 'Expected: ' + applicationId + '. Received: ' + lAppUserRelations[0].Content__c);
        System.assertEquals(appUserRelation.User__c, userId, 'Expected: ' + userId + '. Received: ' + lAppUserRelations[0].User__c);
        System.assertEquals(appUserRelation.IsSubscribed__c, true, 'Expected: true. Received: ' + lAppUserRelations[0].IsSubscribed__c);
    }

    static testMethod void testGetDetail() {
        ocms_TestContentHelper tch = ocms_mfc_App_Test.createApplication();
        String applicationId = tch.gc.content.Id;

        // Testing the application detail controller
        ocms_mfc_AppDetail AppDetailController = new ocms_mfc_AppDetail(tch.gc);
        Map<String, List<String>> categories = new Map<String, List<String>>();
        categories.put(applicationId, new List<String>{'Productivity'});
        AppDetailController.categories = categories;

        String appDetailHTML = AppDetailController.getHTML();

        ocms_mfc_AppSummary AppSummaryController = new ocms_mfc_AppSummary(tch.gc);
        AppSummaryController.categories = categories;
        String appSummaryHTML = AppSummaryController.getHTML();

        ocms_mfc_AppWidget AppWidgetController = new ocms_mfc_AppWidget();
        String appWidgetHTML = AppWidgetController.getHTML();
    }

    static testMethod void testGetters() {
        // Test the default controller
        ocms_mfc_App AppController = new ocms_mfc_App();
        // Code coverage the mandatory getHTML
        String getHTML = AppController.getHTML();
         
        List<Map<String,String>> testAttributes = new List<Map<String, String>>();

        List<String> attrNames = new List<String>{
            'title',
            'imageIcon',
            'link',
            'linkAsData',
            'appWidgetTitle,test',
            'summary',
            'tutorial',
            'tutorialVideoLink,test'
        };

        ocms_TestContentHelper tch = new ocms_TestContentHelper();
        ocms_TestContentHelper.addToAttributesFromList(testAttributes, attrNames);
        
        tch.createContent(testAttributes, '');
        
        AppController = new ocms_mfc_App(tch.gc);
        
        ocms_TestContentHelper.testAttributeValuesFromList(attrNames, AppController);
        
        String appliation1 = '1;abc;category;contentId';
        String appliation2 = '1;abc;category;contentId';
        String appliation3 = '2;bbb;category;contentId';
        String appliation4 = '3;zza;category;contentId';

        List<ocms_mfc_App.AppSorter> appSortList = new List<ocms_mfc_App.AppSorter>();
        appSortList.add(new ocms_mfc_App.AppSorter(appliation1));
        appSortList.add(new ocms_mfc_App.AppSorter(appliation2));
        appSortList.add(new ocms_mfc_App.AppSorter(appliation3));
        appSortList.add(new ocms_mfc_App.AppSorter(appliation4));

        appSortList.sort();
    }
}