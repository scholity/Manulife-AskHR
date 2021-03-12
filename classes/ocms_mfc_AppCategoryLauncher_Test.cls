@isTest
private class ocms_mfc_AppCategoryLauncher_Test {

    private static ocms_mfc_AppCategoryLauncher setup() {
        List<Map<String,String>> testAttributes = new List<Map<String, String>>();
        List<String> attrNames = new List<String>{'title'};

        ocms_TestContentHelper.addToAttributesFromList(testAttributes, attrNames);
        
        ocms_TestContentHelper tch = new ocms_TestContentHelper();
        tch.createContent(testAttributes, '');

        testAttributes = new List<Map<String, String>>();
        attrNames = new List<String>{'title, imageIcon, link'};
        tch.createContent(testAttributes, 'App', false);

        String appId = tch.gc.content.Id;

        ocms_mfc_AppCategoryLauncher AppCategoryController = new ocms_mfc_AppCategoryLauncher(tch.gc);
        
        testAttributes = new List<Map<String, String>>();
        
        Map<String, String> am = new Map<String, String>();
        am.put('name', 'mandatoryAppIDs');
        am.put('value', appId);
        am.put('type', 'text');
        testAttributes.add(am);
        
        tch.createContent(testAttributes, 'SitePreferences', false);

        ocms_mfc_SiteSettings__c sitePreferenceCustomSetting = new ocms_mfc_SiteSettings__c();
        sitePreferenceCustomSetting.Name = 'Manulife Central';
        sitePreferenceCustomSetting.Site_Preferences_Id__c = tch.gc.content.Id;

        insert sitePreferenceCustomSetting;

        return AppCategoryController;
    }

    static testMethod void testGetCategory() {
        // Test the default controller
        ocms_mfc_AppCategoryLauncher AppCategoryController = new ocms_mfc_AppCategoryLauncher();

        System.currentPageReference().getParameters().put('category', 'testCategory');

        String getHTML = ocms_mfc_AppCategoryLauncher_Test.setup().getHTML();
    }
    
    static testMethod void testGetCategoryWithInjectList() {
        ocms_mfc_AppCategoryLauncher AppCategoryController = ocms_mfc_AppCategoryLauncher_Test.setup();

        Map<String, List<String>> content = new Map<String, List<String>>();
        
        System.currentPageReference().getParameters().put('category', 'testCategory');
        content.put('contenId', new List<String>{'Markup test {mobileSize} {tabletSize} {desktopSize} test markup'});
        content.put('contenId1', new List<String>{'Markup test {mobileSize} {tabletSize} {desktopSize} test markup'});
        content.put('contenId2', new List<String>{'Markup test {mobileSize} {tabletSize} {desktopSize} test markup'});

        AppCategoryController.allApps = content;

        String getHTML = AppCategoryController.getHTML();
    }

}