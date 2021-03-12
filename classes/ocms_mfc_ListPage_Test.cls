@isTest
private class ocms_mfc_ListPage_Test {

    static testMethod void testGetters() {
        ocms_TestContentHelper tch = new ocms_TestContentHelper();
        // Test the default controller
        ocms_mfc_ListPage listPageController = new ocms_mfc_ListPage();
        listPageController.getType();
        // Code coverage the mandatory getHTML

        List<Map<String,String>> attributes = new List<Map<String, String>>();
        List<String> attrNames = new List<String>{
            'title',
            'parentTaxonomyNode',
            'siteMapPath,Taxonomy/Node 1/Node 2',
            'contentTypeId,a9232323232323dd',
            'contentType,MFC Article',
            'contentTemplate,Tile',
            'showFeatured,true',
            'helperTitle',
            'helperText',
            'filter',
            'allLocationsText',
            'initialFilterCat,allfirst',
            'initialFilterChild,/Taxonomy/Node 1/',
            'loadAmount,2',
            'allText,AWL',
            'showSearchBar,true',
            'listView,true',
            'sortOrder,latestDate',
            'allFilterIsLast,true'
        };

        ocms_TestContentHelper.addToAttributesFromList(attributes, attrNames);
        tch.createContent(attributes, 'ListPage');

        listPageController = new ocms_mfc_ListPage(tch.gc);

        ocms_TaxonomyAPI taxApi = listPageController.taxonomyApi;
        System.assertNotEquals(taxApi, null, 'ListPageControoler.taxonomyApi unexpectedly null');

        // note: tests only getProperty(), NOT the corresponding get methods
        ocms_TestContentHelper.testAttributeValuesFromList(attrNames, listPageController);

        // test getters not otherwise exercised by these test methods
        System.assertEquals(listPageController.initialFilterCat, 'allfirst');
        System.assertEquals(listPageController.initialFilterChild, '/Taxonomy/Node 1/');
        System.assertEquals(listPageController.allFilterIsLast, 'true');
        
    }   // testGetters


    static testMethod void testExecuteRequest() {
        ocms_mfc_ListPage listPageController = new ocms_mfc_ListPage();
        Map<String, String> request = new Map<String, String>();
        request.put('action', 'fail');
        String response = listPageController.executeRequest(request);
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response);
        System.assertEquals(false, responseMap.get('success'));

        createDefaultSitePrefsAndSetting();

        request.put('action', 'getContentTypes');
        response = listPageController.executeRequest(request);
        responseMap = (Map<String, Object>) JSON.deserializeUntyped(response);
        System.assertEquals(true, responseMap.get('success'));
    }   // testExecuteRequest


    static testMethod void testGetContentTypesJSONResponse() {
        cms__Content_Template_Relationship__c contentTemplateRelationship = new cms__Content_Template_Relationship__c();
        cms__Content_Type__c contentType = new cms__Content_Type__c();
        contentType.cms__Name__c = 'News';
        contentType.cms__Label__c = 'News Label';
        cms__Content_Layout__c contentLayout = new cms__Content_Layout__c();
        contentLayout.cms__Name__c = 'NewsTile';
        contentTemplateRelationship.cms__Content_Type__r = contentType;
        contentTemplateRelationship.cms__Content_Layout__r = contentLayout;
        ocms_mfc_ListPage listPageController = new ocms_mfc_ListPage();
        listPageController.contentTemplateRelationships = new List<cms__Content_Template_Relationship__c>{contentTemplateRelationship};

        createDefaultSitePrefsAndSetting();

        String response = listPageController.getContentTypesJSONResponse('NewsTile');
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response);
        Map<String, Object> contentTypesMap = (Map<String, Object>)responseMap.get('contentTypes');
        Map<String, Object> newsMap = (Map<String, Object>)contentTypesMap.get('News');
        System.assertEquals('News Label', (String)newsMap.get('label'));
        System.assertEquals('News', (String)newsMap.get('name'));
    }   // testGetContentTypesJSONResponse


    static testMethod void testGetHTML() {
        ocms_TestContentHelper tch = new ocms_TestContentHelper();

        List<Map<String,String>> attributes = new List<Map<String, String>>();
        List<String> attrNames = new List<String>{
            'filter,location',
            'useParentPath,true',
            'parentTaxonomyNode,/master/listpage',
            'showSearchBar,true',
            'showAllFilter,true'
        };

        ocms_TestContentHelper.addToAttributesFromList(attributes, attrNames);
        tch.createContent(attributes, 'ListPage');
        ocms_mfc_ListPage listPageController = new ocms_mfc_ListPage(tch.gc);

        ocms_mfc_SitePreferences.preferencesMap = new Map<String, String>();
        ocms_mfc_SitePreferences.preferencesMap.put('featuredItemTagPath', 'master/featured/featured');
        ocms_mfc_SitePreferences.preferencesMap.put('locationTaxonomy', 'someplace/over/there');

        ocms_TaxonomyAPI.contentIdBuckets.put('featured', new Set<String>{'a0bW0000001Isq1', 'a0bW0000001Isq2', 'a0bW0000001Isq3', 'a0bW0000001Isq4', 'a0bW0000001Isq5', 'a0bW0000001Isq6', 'a0bW0000001Isq7'});

        listPageController.locationPaths = new List<String>{'/Taxonomy/location/canada/ontario/kingston'};
        listPageController.getPathsForChildrenOfPath('/Taxonomy/featured');

        String response = listPageController.getHTML();
        System.debug('••• testGetHTML: ListPage response: ' + response);

        // ----
        // go again, re-using attributes and attrNames Lists

        attributes = new List<Map<String, String>>();
        attrNames = new List<String>{
            'parentTaxonomyNode,/master/listpage',
            'useParentPath,false',
            'showSearchBar,true',
            'showAllFilter,true',
            'loadAmount,-2',
            'initialFilterCat,child',
            'initialFilterChild,/master/listpage/childCategory'
        };
        ocms_TestContentHelper.addToAttributesFromList(attributes, attrNames);
        tch.createContent(attributes, 'ListPage', false);
        listPageController = new ocms_mfc_ListPage(tch.gc);

        listPageController.getLocationDropDown(null);

        response = listPageController.getHTML();
    }   // testGetHTML


    static testMethod void testGetPageRenderingsJSONResponse() {
        ocms_TestContentHelper tch = new ocms_TestContentHelper();

        List<Map<String, String>> attributes = new List<Map<String, String>>();
        List<String> attrNames = new List<String>{
            'filter,Location',
            'parentTaxonomyNode,/master/listpage',
            'showAllFilter,true',
            'allFilterIsLast,false',
            'initialFilterCat,allfirst',
            'initialFilterChild,/irrelevent-for-allfirst'
        };

        ocms_TestContentHelper.addToAttributesFromList(attributes, attrNames);
        tch.createContent(attributes, 'ListPage');
        ocms_mfc_ListPage listPageController = new ocms_mfc_ListPage(tch.gc);

        List<Map<String,String>> spAttributes = new List<Map<String, String>>();        
        spAttributes.add(ocms_TestContentHelper.makeTextAttributeMap('featuredItemTagPath', 'Test Taxonomy/First'));
        tch.createContent(spAttributes, 'SitePreferences', false);

        createDefaultSitePrefsAndSetting(tch);

        Map<String, String> request = new Map<String, String>();
        request.put('action', 'getPageRenderings');
        request.put('showFeatured', 'true');
        request.put('offset', '0');
        request.put('term', 'the');
        request.put('amountToRetrieve', '-2');
        request.put('parentTaxonomyNode', '/master/listpage');
        request.put('showPriorityMessages', 'true');
        request.put('showMaxPriorityItems', '1');
        request.put('priorityIds', '');
        request.put('requestNumber', '1');
        //Causes exception in filter == location if statement
        String response = listPageController.executeRequest(request);

        // Fix exception
        listPageController.locationPaths = new List<String>{'/Taxonomy/location/canada/ontario/kingston'};
        response = listPageController.executeRequest(request);
    }


    static ocms_TestContentHelper createDefaultSitePrefsAndSetting() {
        ocms_TestContentHelper tch = new ocms_TestContentHelper();
        
        List<Map<String, String>> attributes = new List<Map<String, String>>();
        List<String> attrNames = new List<String>{
            'featuredItemTagPath,Test Taxonomy/First',
            'locationTaxonomy,Test Taxonomy/All Locations/Hyperion Court'
        };

        ocms_TestContentHelper.addToAttributesFromList(attributes, attrNames);
        tch.createContent(attributes, 'SitePreferences', true);
        
        createDefaultSitePrefsAndSetting(tch);

        return tch;
    }   // createDefaultSitePrefsAndSetting()


    static void createDefaultSitePrefsAndSetting(ocms_TestContentHelper tchSitePreferences) {
        ocms_mfc_SiteSettings__c sitePreferenceCustomSetting = new ocms_mfc_SiteSettings__c();

        sitePreferenceCustomSetting.Name = 'Manulife Central';
        sitePreferenceCustomSetting.Site_Preferences_Id__c = tchSitePreferences.gc.content.Id;
        sitePreferenceCustomSetting.Site_Name__c = 'Manulife Central';

        insert sitePreferenceCustomSetting;        
    }   // createDefaultSitePrefsAndSetting(ocms_TestContentHelper)

}   // testGetPageRenderingsJSONResponse