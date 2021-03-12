@isTest
private class ocms_mli_LatestNews_Test {
    static testMethod void createLatestNews() {
        /*
        Setup the data
        ############## */

        String sSiteName = 'TestSite'; // arbritary test site neame stored in `cms__Sites__.cms__Site_Name__c`
        String type_name = 'TestContentType';
        String page_name = 'TestPage';
        String contentName = 'TestContentName';


        // Create our Site object using `cms.TestExtensionFixtures.InitiateTest` which initializes some hidden things from us - see Create Site
        cms__Sites__c oSite = cms.TestExtensionFixtures.InitiateTest(
							sSiteName
							,new Map<String, String>{'runtime' => 'Intranet'
							,'sname' => sSiteName
							,'name' => page_name
						});

        /*
        Generate Content init test
        ########################## */
        // below are pull from `getData` in `Content.cls` where it says 'old custom template method'
        // IMPRV: is there better way to do below? When TextFixtures are opened up or using `cms.TestExtensionFixtures.InitiateTest` but we run into 'Context Not Initialized'

        Test.setCurrentPage(new PageReference('/apex/cms__Preview')); // is this needed? doesn't seem so
        System.currentPageReference().getParameters().put('sname', sSiteName);
        System.currentPageReference().getParameters().put('name', page_name);
        System.currentPageReference().getParameters().put('page_mode', 'prev');

        ocms_mli_LatestNews LatestNewsController = new ocms_mli_LatestNews();

        List<Map<String,String>> attr_map = new List<Map<String, String>>();

        ocms_TestContentHelper tch = new ocms_TestContentHelper();

        Map<String, String> am = new Map<String, String>();
        am.put('name', 'iQueryLimit');
        am.put('value', '9');
        am.put('type', 'integer');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'sLoaderTitle');
        am.put('value', 'Latest News');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'sLoaderIcon');
        am.put('value', 'http://www.path.to/resource/desktopImage.jpg');
        am.put('type', 'Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'sTaxonomyContentType');
        am.put('value', 'MLIArticle');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'sTaxonomyContentLayout');
        am.put('value', 'MLIArticleContentBlocks');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'sTagPaths');
        am.put('value', '/Brand Taxonomy/Location/Global');
        am.put('type', 'text');
        attr_map.add(am);

        tch.createContent(attr_map, 'MLIArticleLatestNews', false);
        LatestNewsController = new ocms_mli_LatestNews(tch.gc);

        String getHTML = LatestNewsController.getHTML();

	}

	static testMethod void getIArticleListableEventsTest() {
	    /*
        Setup the data
        ############## */

        String sSiteName = 'TestSite'; // arbritary test site neame stored in `cms__Sites__.cms__Site_Name__c`
        String type_name = 'TestContentType';
        String page_name = 'TestPage';
        String contentName = 'TestContentName';


        // Create our Site object using `cms.TestExtensionFixtures.InitiateTest` which initializes some hidden things from us - see Create Site
        cms__Sites__c oSite = cms.TestExtensionFixtures.InitiateTest(
                            sSiteName
                            ,new Map<String, String>{'runtime' => 'Intranet'
                            ,'sname' => sSiteName
                            ,'name' => page_name
                        });

        /*
        Generate Content init test
        ########################## */
        // below are pull from `getData` in `Content.cls` where it says 'old custom template method'
        // IMPRV: is there better way to do below? When TextFixtures are opened up or using `cms.TestExtensionFixtures.InitiateTest` but we run into 'Context Not Initialized'

        Test.setCurrentPage(new PageReference('/apex/cms__Preview')); // is this needed? doesn't seem so
        System.currentPageReference().getParameters().put('sname', sSiteName);
        System.currentPageReference().getParameters().put('name', page_name);
        System.currentPageReference().getParameters().put('page_mode', 'prev');

	    ocms_mli_LatestNews LatestNewsController1 = new ocms_mli_LatestNews();

        List<Map<String,String>> attr_map = new List<Map<String, String>>();

        ocms_TestContentHelper tch = new ocms_TestContentHelper();

        Map<String, String> am = new Map<String, String>();
        am = new Map<String, String>();
        am.put('name', 'sTaxonomyContentLayout');
        am.put('value', 'MLIArticleListableEventsAndPresentations');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'sEventsLabel');
        am.put('value', 'event label');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'sPresentationLabel');
        am.put('value', 'presentation label');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'sPresentationDetail');
        am.put('value', 'presentation detail');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name','sLoaderExternalLink');
        am.put('value','External,,NewWindow,,,,http://www.google.ca');
        am.put('type','Text');
        attr_map.add(am);

        tch.createContent(attr_map, 'MLIArticleLatestNews', false);
        LatestNewsController1 = new ocms_mli_LatestNews(tch.gc);

        String getHTML1 = LatestNewsController1.getHTML();
	}
}