@isTest
private class ocms_mfc_NewsStream_Test {
    static private ocms_TestContentHelper getTestContentHelper() {
        ocms_TestContentHelper tch = new ocms_TestContentHelper();
        // Test the default controller
        ocms_mfc_NewsStream newsStreamController = new ocms_mfc_NewsStream();

        List<Map<String,String>> attr_map = new List<Map<String, String>>();
        Map<String, String> am = new Map<String, String>();

        am = new Map<String, String>();
        am.put('name', 'carouselNewsLimit');
        am.put('value', '2');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'carouselPriorityLimit');
        am.put('value', '1');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'myNewsText');
        am.put('value', 'myNewsText');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'allText');
        am.put('value', 'allText');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'settingsPage');
        am.put('value', 'settingsPageAsData');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'image');
        am.put('value', 'image');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'imageText');
        am.put('value', 'imageText');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'imageLink');
        am.put('value', 'imageLink');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'isListedCEOTile');
        am.put('value', 'checked');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'leaderName1');
        am.put('value', 'leaderName1');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'leaderTitle1');
        am.put('value', 'leaderTitle1');
        am.put('type', 'text');
        attr_map.add(am);

        tch.createContent(attr_map, 'News');

        return tch;
    }

    static testMethod void testGetters() {
        ocms_TestContentHelper tch = getTestContentHelper();
        ocms_mfc_NewsStream newsStreamController = new ocms_mfc_NewsStream(tch.gc);
        newsStreamController.getType();
        System.assertEquals(newsStreamController.carouselNewsLimit, '2');
        System.assertEquals(newsStreamController.carouselPriorityLimit, '1');
        System.assertEquals(newsStreamController.myNewsText, 'myNewsText');
        System.assertEquals(newsStreamController.allText, 'allText');
        System.assertEquals(newsStreamController.getType(), ocms_mfc_NewsStream.class);
        System.assertEquals(newsStreamController.image, 'image');
        System.assertEquals(newsStreamController.imageText, 'imageText');
        System.assertEquals(newsStreamController.imageLink, 'imageLink');
        System.assertEquals(newsStreamController.isListedCEOTile, 'checked');
        System.assertEquals(newsStreamController.leaderName1, 'leaderName1');
        System.assertEquals(newsStreamController.leaderTitle1, 'leaderTitle1');
    }

    static testMethod void testGetHTML() {
        ocms_TestContentHelper tch = getTestContentHelper();
        ocms_mfc_NewsStream newsStreamController = new ocms_mfc_NewsStream(tch.gc);
        String html = newsStreamController.getHTML();

        // Test to see if it contains commmon elements that should be there
        System.assertEquals(html.contains('<script>'), true);
        System.assertEquals(html.contains('</script>'), true);
        System.assertEquals(html.contains('dashboard-tile-block'), true);
        System.assertEquals(html.contains('global-show-more'), true);
    }

    static testMethod void testGetFilterBarHtml() {
        ocms_TestContentHelper tch = getTestContentHelper();
        ocms_mfc_NewsStream newsStreamController = new ocms_mfc_NewsStream(tch.gc);

        String filterBarHtml = newsStreamController.getFilterBarHtml();
        System.assertEquals(filterBarHtml.contains('myNewsText'), true);
        System.assertEquals(filterBarHtml.contains('allText'), true);
    }

    static testMethod void testGetCarouselHTML() {
        ocms_TestContentHelper tch = getTestContentHelper();
        ocms_mfc_NewsStream newsStreamController = new ocms_mfc_NewsStream(tch.gc);
        Map<String, String> carouselRenderings = new Map<String, String>();
        carouselRenderings.put('test1','<rendering1>');
        carouselRenderings.put('test1','forty74');

        String carouselHTML = newsStreamController.getCarouselHtml(carouselRenderings, new Map<String, String>{'test1' => 'test2'});
        carouselHTML = newsStreamController.getCarouselHtml(new Map<String, String>(), new Map<String, String>());
    }

    static testMethod void testGetCEOTileHTML() {
        ocms_TestContentHelper tch = getTestContentHelper();
        ocms_mfc_NewsStream newsStreamController = new ocms_mfc_NewsStream(tch.gc);
        newsStreamController.getCEOTileHTML();
    }

    static testMethod void testExecuteRequest() {
        ocms_TestContentHelper tch = getTestContentHelper();
        ocms_mfc_NewsStream newsStreamController = new ocms_mfc_NewsStream(tch.gc);
        Map<String, String> request = new Map<String, String>();
        request.put('action', 'fail');
        String response = newsStreamController.executeRequest(request);
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response);

        System.assertEquals(false, responseMap.get('success'));
    }

    static testMethod void testGetFilteredContentIds() {
        ocms_TestContentHelper tch = getTestContentHelper();
        ocms_mfc_NewsStream newsStreamController = new ocms_mfc_NewsStream(tch.gc);
        System.assertEquals(newsStreamController.getFilteredContentIds('News', 'My News', '', '').size(), 0);
        System.assertEquals(newsStreamController.getFilteredContentIds('News', 'All', '', '').size(), 0);
        System.assertEquals(newsStreamController.getFilteredContentIds('News', 'Popular', '', '').size(), 0);
        System.assertEquals(newsStreamController.getFilteredContentIds('News', 'Global', '', '').size(), 0);
    }

    static testMethod void testGetContentIdsWithMatchingPath() {
        ocms_TestContentHelper tch = getTestContentHelper();
        ocms_mfc_NewsStream newsStreamController = new ocms_mfc_NewsStream(tch.gc);
        ocms_taxonomyApi.contentIdsToPaths.put('abcdefcakee', new List<String>{'cake'});
        ocms_taxonomyApi.contentIdsToPaths.put('abcwaffle', new List<String>{'waffles'});
        List<String> matchingContentIds = newsStreamController.getContentIdsWithMatchingPath(new List<String>{'abcdefcakee', 'abcwaffle'}, 'cake');

        System.assertEquals(matchingContentIds.size(), 0);
    }

    static testMethod void testGetContentRenderingsJSONResponse() {
        ocms_TestContentHelper tch = getTestContentHelper();

        List<Map<String,String>> attr_map = new List<Map<String, String>>();
        Map<String, String> am = new Map<String, String>();
        am.put('name', 'title');
        am.put('value', 'title');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'contentType');
        am.put('value', 'News');
        am.put('type', 'text');
        attr_map.add(am);

        tch.createContent(attr_map, 'Content__c', false);

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

        ocms_mfc_NewsStream newsStreamController = new ocms_mfc_NewsStream(tch.gc);
        Map<String, String> request = new Map<String, String>();
        request.put('action', 'getContentRenderings');
        request.put('contentType', 'News');
        request.put('filter', 'All News');
        request.put('filterValue', 'News');
        request.put('offset', '0');
        request.put('amountToRetrieve', '5');
        request.put('carouselNewsLimit', '2');
        request.put('carouselPriorityLimit', '2');
        request.put('carouselIds', '');
        request.put('firstImage', 'image');
        request.put('imageText', 'chippy');
        request.put('imageLink', 'External,,,,,,http://www.example.com');

        String response = newsStreamController.executeRequest(request);
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response);

        System.assertEquals(responseMap.get('success'), true);
    }
}