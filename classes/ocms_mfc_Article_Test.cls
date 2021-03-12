@isTest
private class ocms_mfc_Article_Test {

    private static void setupSitePrefernces() {
        List<Map<String,String>> testAttributes = new List<Map<String, String>>();
        ocms_TestContentHelper tch = new ocms_TestContentHelper();

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
    }

	static testMethod void testArticleProperties() {
		ocms_TestContentHelper tch = new ocms_TestContentHelper();
        List<Map<String,String>> attr_map = new List<Map<String, String>>();

        Datetime nowDate = Datetime.now();
        Map<String, String> am = new Map<String, String>();
        am.put('name', 'title');
        am.put('value', 'title');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'publishDate');
        am.put('value', String.valueOf(nowDate));
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'summary');
        am.put('value', 'summary');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'body');
        am.put('value', 'body');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'detailSidebar');
        am.put('value', 'detailSidebar');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'imageIcon');
        am.put('value', 'imageIcon');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'imageHero');
        am.put('value', 'imageHero');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'author');
        am.put('value', 'author');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'authorTitle');
        am.put('value', 'authorTitle');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'authorEmail');
        am.put('value', 'authorEmail');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'authorPhone');
        am.put('value', 'authorPhone');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'contentFlavor');
        am.put('value', 'article');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'sTitle');
        am.put('value', 'someasdjkasjkds');
        am.put('type', 'text');
        attr_map.add(am);

        tch.createContent(attr_map, 'Article');

        ocms_mfc_Article articalController = new ocms_mfc_Article(tch.gc);

        // Code coverage the mandatory getHTML
        String getHTML = articalController.getHTML();

        System.assertEquals(articalController.title, 'title', 'Expected title got: ' + articalController.title);
        System.assertEquals(articalController.publishDate, String.valueOf(nowDate), 'Expected publishDate got: ' + articalController.publishDate);
        System.assertEquals(articalController.summary, 'summary', 'Expected summary got: ' + articalController.summary);
        System.assertEquals(articalController.body, 'body', 'Expected body got: ' + articalController.body);
        System.assertEquals(articalController.detailSidebar, 'detailSidebar', 'Expected detailSidebar got: ' + articalController.detailSidebar);
        System.assertEquals(articalController.imageIcon, 'imageIcon', 'Expected imageIcon got: ' + articalController.imageIcon);
        System.assertEquals(articalController.imageHero, 'imageHero', 'Expected imageHero got: ' + articalController.imageHero);
        System.assertEquals(articalController.author, 'author', 'Expected author got: ' + articalController.author);
        System.assertEquals(articalController.authorTitle, 'authorTitle', 'Expected authorTitle got: ' + articalController.authorTitle);
        System.assertEquals(articalController.authorEmail, 'authorEmail', 'Expected authorEmail got: ' + articalController.authorEmail);
        System.assertEquals(articalController.authorPhone, 'authorPhone', 'Expected authorPhone got: ' + articalController.authorPhone);

        String versionId = articalController.versionOriginId;
        //System.assertEquals(articalController.imageIcon, 'imageIcon', 'Expected imageIcon got: ' + AppController.imageIcon);
        // Hard to test what the link data is going to come back as for tests.  Just output the variable for coverage on the getter
	}

	static testMethod void testExecuteRequestFunctions() {
		ocms_TestContentHelper tch = new ocms_TestContentHelper();
        List<Map<String,String>> attr_map = new List<Map<String, String>>();

        tch.createContent(attr_map, 'Article');

        ocms_mfc_Article articalController = new ocms_mfc_Article(tch.gc);

        //Lets test both ajax requests failure status first
        String response = articalController.executeRequest(new Map<String, String>{
    		'action' => 'authorAutoComplete',
    		'name' => 'nevergoingtofindanyone'
		});
    	Map<String, Object> mResponse = (Map<String, Object>) JSON.deserializeUntyped(response);

    	System.assertEquals(false, mResponse.get('success'), 'There are currently no users when searching for nevergoingtofindanyone');
    	System.assertEquals('No matching users', mResponse.get('exception'), 'We have an exception');

		response = articalController.executeRequest(new Map<String, String>{
    		'action' => 'getAuthor',
    		'name' => 'Thisshouldbeunique Stantive',
    		'email' => 'standarduser@manulife.com'
		});
    	mResponse = (Map<String, Object>) JSON.deserializeUntyped(response);

    	System.assertEquals(false, mResponse.get('success'), 'There are currently no users with that name and email');
    	System.assertEquals('No matching users', mResponse.get('exception'), 'We have an exception');

    	//Now lest insert a user and get some successful results.
        Profile p = [select Id from profile where name='System Administrator'];
		User u = new User (alias = 'standt', email='standarduser@manulife.com',
		emailencodingkey='UTF-8', lastname='Stantive', languagelocalekey='en_US',
		localesidkey='en_US', profileid = p.Id, firstname='Thisshouldbeunique',
		timezonesidkey='America/Los_Angeles', username='standarduserrr@manulife.com',
		phone='(613) 561-3574', title='Developer');
		TriggerUtils.setBypassUserTrigger();

		insert u;

		response = articalController.executeRequest(new Map<String, String>{
    		'action' => 'authorAutoComplete',
    		'name' => 'Thisshouldbeunique'
		});
    	mResponse = (Map<String, Object>) JSON.deserializeUntyped(response);

    	List<User> userRecord = (List<User>) JSON.deserialize(JSON.serialize(mResponse.get('users')), List<User>.class);
    	System.assertEquals(true, mResponse.get('success'), 'There is one user found when searching for Thisshouldbeunique');
    	System.assertEquals(1, userRecord.size(), 'We have found ' + String.valueOf(userRecord.size()));

    	response = articalController.executeRequest(new Map<String, String>{
    		'action' => 'getAuthor',
    		'name' => 'Thisshouldbeunique Stantive',
    		'email' => 'standarduser@manulife.com'
		});
    	mResponse = (Map<String, Object>) JSON.deserializeUntyped(response);

    	userRecord = (List<User>) JSON.deserialize(JSON.serialize(mResponse.get('users')), List<User>.class);
    	System.assertEquals(true, mResponse.get('success'), 'There is one user found when searching for Username'+ userRecord[0].Name +' and Email ' + userRecord[0].Email);

        //Test getPOID functionality
        cms__Page__c pageObj = new cms__Page__c();
        pageObj.cms__Name__c = 'Page Name';
        pageObj.cms__Title__c = 'Page Title';

        insert pageObj;

        response = articalController.executeRequest(new Map<String, String>{
            'action' => 'getPOID',
            'pageId' => pageObj.Id
        });
        mResponse = (Map<String, Object>) JSON.deserializeUntyped(response);
        System.assertEquals(true, mResponse.get('success'), 'WE were returned the page inserted above');


        //Test Failure getArticlesByName
        response = articalController.executeRequest(new Map<String, String>{
            'action' => 'getArticleTilesByName',
            'contentId' => tch.gc.content.Id,
            'term' => 'woodpecker'

        });
        mResponse = (Map<String, Object>) JSON.deserializeUntyped(response);
        System.assertEquals(false, mResponse.get('success'), 'Nothing was returned.');

	}

	static testMethod void testGetSummaryHTML() {
		ocms_TestContentHelper tch = new ocms_TestContentHelper();
        List<Map<String,String>> attr_map = new List<Map<String, String>>();

        Datetime nowDate = Datetime.now();
        Map<String, String> am = new Map<String, String>();
        am.put('name', 'title');
        am.put('value', 'title');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'publishDate');
        am.put('value', String.valueOf(nowDate.format('MM/dd/yyyy')));
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'summary');
        am.put('value', 'summary');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'body');
        am.put('value', 'body');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'detailSidebar');
        am.put('value', 'detailSidebar');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'imageIcon');
        am.put('value', 'imageIcon');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'imageHero');
        am.put('value', 'imageHero');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'author');
        am.put('value', 'author');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'authorTitle');
        am.put('value', 'authorTitle');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'authorEmail');
        am.put('value', 'authorEmail');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'authorPhone');
        am.put('value', 'authorPhone');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'authorImage');
        am.put('value', 'authorImage');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'contentFlavor');
        am.put('value', 'article');
        am.put('type', 'text');
        attr_map.add(am);
        am = new Map<String, String>();
        am.put('name', 'sTitle');
        am.put('value', 'someasdjkasjkds');
        am.put('type', 'text');
        attr_map.add(am);

        tch.createContent(attr_map, 'Article');

        setupSitePrefernces();

        ocms_mfc_Article articalController = new ocms_mfc_Article(tch.gc);

        String html = articalController.getArticleSummaryHTML();
        System.assertEquals(true, html.contains(articalController.versionOriginId), 'Contains versionOriginId');
        System.assertEquals(true, html.contains(articalController.imageIcon), 'Contains imageIcon');
        System.assertEquals(true, html.contains(articalController.summary), 'Contains summary');
	}

    static testMethod void testGetWebLinkSummaryHTML() {
        ocms_TestContentHelper tch = new ocms_TestContentHelper();
        List<Map<String,String>> attr_map = new List<Map<String, String>>();

        Datetime nowDate = Datetime.now();
        Map<String, String> am = new Map<String, String>();
        am.put('name', 'title');
        am.put('value', 'title');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'publishDate');
        am.put('value', String.valueOf(nowDate.format('MM/dd/yyyy')));
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'summary');
        am.put('value', 'summary');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'body');
        am.put('value', 'body');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'detailSidebar');
        am.put('value', 'detailSidebar');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'imageIcon');
        am.put('value', 'imageIcon');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'imageHero');
        am.put('value', 'imageHero');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'author');
        am.put('value', 'author');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'authorTitle');
        am.put('value', 'authorTitle');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'authorEmail');
        am.put('value', 'authorEmail');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'authorPhone');
        am.put('value', 'authorPhone');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'contentFlavor');
        am.put('value', 'webLink');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'webLink');
        am.put('value', 'webLink');
        am.put('type', 'Link');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'webLinkType');
        am.put('value', 'webLinkType');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'sTitle');
        am.put('value', 'someasdjkasjkds');
        am.put('type', 'text');
        attr_map.add(am);

        tch.createContent(attr_map, 'Article');

        setupSitePrefernces();

        ocms_mfc_Article articalController = new ocms_mfc_Article(tch.gc);

        String html = articalController.getArticleSummaryHTML();
        System.assertEquals(true, html.contains(articalController.summary), 'Contains summary');
    }

    static testMethod void testGetCEOArticleSummaryHTML() {
        ocms_TestContentHelper tch = new ocms_TestContentHelper();
        List<Map<String,String>> attr_map = new List<Map<String, String>>();

        Datetime nowDate = Datetime.now();
        Map<String, String> am = new Map<String, String>();
        am.put('name', 'title');
        am.put('value', 'title');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'publishDate');
        am.put('value', String.valueOf(nowDate.format('MM/dd/yyyy')));
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'summary');
        am.put('value', 'summary');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'body');
        am.put('value', 'body');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'detailSidebar');
        am.put('value', 'detailSidebar');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'imageIcon');
        am.put('value', 'imageIcon');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'imageHero');
        am.put('value', 'imageHero');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'author');
        am.put('value', 'author');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'authorTitle');
        am.put('value', 'authorTitle');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'authorEmail');
        am.put('value', 'authorEmail');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'authorPhone');
        am.put('value', 'authorPhone');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'contentFlavor');
        am.put('value', 'ceoArticle');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'ceoCategory');
        am.put('value', 'testCategory~~~~test.jpg');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'sTitle');
        am.put('value', 'someasdjkasjkds');
        am.put('type', 'text');
        attr_map.add(am);

        tch.createContent(attr_map, 'Article');

        setupSitePrefernces();

        ocms_mfc_Article articalController = new ocms_mfc_Article(tch.gc);

        String html = articalController.getArticleSummaryHTML();
        System.assertEquals(true, html.contains(articalController.versionOriginId), 'Contains versionOriginId');
    }

    static testMethod void testGetArticleNewsTileHTML() {
        ocms_TestContentHelper tch = new ocms_TestContentHelper();
        List<Map<String,String>> attr_map = new List<Map<String, String>>();

        Datetime nowDate = Datetime.now();
        Map<String, String> am = new Map<String, String>();
        am.put('name', 'title');
        am.put('value', 'title');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'publishDate');
        am.put('value', String.valueOf(nowDate.format('MM/dd/yyyy')));
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'summary');
        am.put('value', 'summary');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'body');
        am.put('value', 'body');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'detailSidebar');
        am.put('value', 'detailSidebar');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'imageIcon');
        am.put('value', 'imageIcon');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'imageHero');
        am.put('value', 'imageHero');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'author');
        am.put('value', 'author');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'authorTitle');
        am.put('value', 'authorTitle');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'authorEmail');
        am.put('value', 'authorEmail');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'authorPhone');
        am.put('value', 'authorPhone');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'contentFlavor');
        am.put('value', 'article');
        am.put('type', 'text');
        attr_map.add(am);
        am = new Map<String, String>();
        am.put('name', 'sTitle');
        am.put('value', 'someasdjkasjkds');
        am.put('type', 'text');
        attr_map.add(am);

        tch.createContent(attr_map, 'Article');

        setupSitePrefernces();

        ocms_mfc_Article articalController = new ocms_mfc_Article(tch.gc);
        String html = articalController.getNewsTileHTML();

    }

    static testMethod void testGetCEOArticleNewsTileHTML() {
        ocms_TestContentHelper tch = new ocms_TestContentHelper();
        List<Map<String,String>> attr_map = new List<Map<String, String>>();

        Datetime nowDate = Datetime.now();
        Map<String, String> am = new Map<String, String>();
        am.put('name', 'title');
        am.put('value', 'title');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'publishDate');
        am.put('value', String.valueOf(nowDate.format('MM/dd/yyyy')));
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'summary');
        am.put('value', 'summary');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'body');
        am.put('value', 'body');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'detailSidebar');
        am.put('value', 'detailSidebar');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'imageIcon');
        am.put('value', 'imageIcon');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'imageHero');
        am.put('value', 'imageHero');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'author');
        am.put('value', 'author');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'authorTitle');
        am.put('value', 'authorTitle');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'authorEmail');
        am.put('value', 'authorEmail');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'authorPhone');
        am.put('value', 'authorPhone');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'contentFlavor');
        am.put('value', 'ceoArticle');
        am.put('type', 'text');
        attr_map.add(am);
        am = new Map<String, String>();
        am.put('name', 'sTitle');
        am.put('value', 'someasdjkasjkds');
        am.put('type', 'text');
        attr_map.add(am);

        tch.createContent(attr_map, 'Article');

        setupSitePrefernces();

        ocms_mfc_Article articalController = new ocms_mfc_Article(tch.gc);
        String html = articalController.getNewsTileHTML();

        System.assertEquals(true, html.contains('executive-message'), 'Contains executive-message class');
    }

    static testMethod void testGetFacebookNewsTileHTML() {
        ocms_TestContentHelper tch = new ocms_TestContentHelper();
        List<Map<String,String>> attr_map = new List<Map<String, String>>();

        Datetime nowDate = Datetime.now();
        Map<String, String> am = new Map<String, String>();
        am.put('name', 'title');
        am.put('value', 'title');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'publishDate');
        am.put('value', String.valueOf(nowDate.format('MM/dd/yyyy')));
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'summary');
        am.put('value', 'summary');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'body');
        am.put('value', 'body');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'detailSidebar');
        am.put('value', 'detailSidebar');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'imageIcon');
        am.put('value', 'imageIcon');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'imageHero');
        am.put('value', 'imageHero');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'author');
        am.put('value', 'author');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'authorTitle');
        am.put('value', 'authorTitle');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'authorEmail');
        am.put('value', 'authorEmail');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'authorPhone');
        am.put('value', 'authorPhone');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'contentFlavor');
        am.put('value', 'socialPost');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'socialType');
        am.put('value', 'facebook');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'socialLink.targetPage');
        am.put('value', 'socialLink');
        am.put('type', 'text');
        attr_map.add(am);
        am = new Map<String, String>();
        am.put('name', 'sTitle');
        am.put('value', 'someasdjkasjkds');
        am.put('type', 'text');
        attr_map.add(am);

        tch.createContent(attr_map, 'Article');

        setupSitePrefernces();

        ocms_mfc_Article articalController = new ocms_mfc_Article(tch.gc);
        String html = articalController.getNewsTileHTML();

        System.assertEquals(true, html.contains('type-social'), 'Contains social post class');
        System.assertEquals(true, html.contains('icon-fb'), 'Contains facebook class');
        System.assertEquals(true, html.contains(articalController.summary), 'Contains summary');
    }

    static testMethod void testGetTwitterNewsTileHTML() {
        ocms_TestContentHelper tch = new ocms_TestContentHelper();
        List<Map<String,String>> attr_map = new List<Map<String, String>>();

        Datetime nowDate = Datetime.now();
        Map<String, String> am = new Map<String, String>();
        am.put('name', 'title');
        am.put('value', 'title');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'publishDate');
        am.put('value', String.valueOf(nowDate.format('MM/dd/yyyy')));
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'summary');
        am.put('value', 'summary');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'body');
        am.put('value', 'body');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'detailSidebar');
        am.put('value', 'detailSidebar');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'imageIcon');
        am.put('value', 'imageIcon');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'imageHero');
        am.put('value', 'imageHero');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'author');
        am.put('value', 'author');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'authorTitle');
        am.put('value', 'authorTitle');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'authorEmail');
        am.put('value', 'authorEmail');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'authorPhone');
        am.put('value', 'authorPhone');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'contentFlavor');
        am.put('value', 'socialPost');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'socialType');
        am.put('value', 'twitter');
        am.put('type', 'text');
        attr_map.add(am);
        am = new Map<String, String>();
        am.put('name', 'sTitle');
        am.put('value', 'someasdjkasjkds');
        am.put('type', 'text');
        attr_map.add(am);

        tch.createContent(attr_map, 'Article');

        setupSitePrefernces();

        ocms_mfc_Article articalController = new ocms_mfc_Article(tch.gc);
        String html = articalController.getNewsTileHTML();

        System.assertEquals(true, html.contains('type-social'), 'Contains social post class');
        System.assertEquals(true, html.contains('icon-tw'), 'Contains twitter class');
        System.assertEquals(true, html.contains(articalController.summary), 'Contains summary');
    }

    static testMethod void testGetExternalNewsTileHTML() {
        ocms_TestContentHelper tch = new ocms_TestContentHelper();
        List<Map<String,String>> attr_map = new List<Map<String, String>>();

        Datetime nowDate = Datetime.now();
        Map<String, String> am = new Map<String, String>();
        am.put('name', 'title');
        am.put('value', 'title');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'publishDate');
        am.put('value', String.valueOf(nowDate.format('MM/dd/yyyy')));
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'summary');
        am.put('value', 'summary');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'body');
        am.put('value', 'body');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'detailSidebar');
        am.put('value', 'detailSidebar');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'imageIcon');
        am.put('value', 'imageIcon');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'imageHero');
        am.put('value', 'imageHero');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'author');
        am.put('value', 'author');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'authorTitle');
        am.put('value', 'authorTitle');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'authorEmail');
        am.put('value', 'authorEmail');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'authorPhone');
        am.put('value', 'authorPhone');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'newsLink');
        am.put('value', 'newsLink');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'contentFlavor');
        am.put('value', 'newsItem');
        am.put('type', 'text');
        attr_map.add(am);
        am = new Map<String, String>();
        am.put('name', 'sTitle');
        am.put('value', 'someasdjkasjkds');
        am.put('type', 'text');
        attr_map.add(am);

        tch.createContent(attr_map, 'Article');

        setupSitePrefernces();

        ocms_mfc_Article articalController = new ocms_mfc_Article(tch.gc);
        String html = articalController.getNewsTileHTML();

        System.assertEquals(true, html.contains('type-external'), 'Contains news item class');
        System.assertEquals(true, html.contains(articalController.summary), 'Contains summary');
    }

	static testMethod void testGetDetailNoSideBarHTML() {
		ocms_TestContentHelper tch = new ocms_TestContentHelper();
        List<Map<String,String>> attr_map = new List<Map<String, String>>();

        Datetime nowDate = Datetime.now();
        Map<String, String> am = new Map<String, String>();
        am.put('name', 'title');
        am.put('value', 'title');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'publishDate');
        am.put('value', String.valueOf(nowDate.format('MM/dd/yyyy')));
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'summary');
        am.put('value', 'summary');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'body');
        am.put('value', 'body');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'detailSidebar');
        am.put('value', 'false');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'imageIcon');
        am.put('value', 'imageIcon');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'imageHero');
        am.put('value', 'imageHero');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'author');
        am.put('value', 'author');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'authorTitle');
        am.put('value', 'authorTitle');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'authorEmail');
        am.put('value', 'authorEmail');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'authorPhone');
        am.put('value', 'authorPhone');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'webLink');
        am.put('value', 'webLink');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'newsLink');
        am.put('value', 'newsLink');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'socialLink');
        am.put('value', 'socialLink');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'socialType');
        am.put('value', 'socialType');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'contentFlavor');
        am.put('value', 'contentFlavor');
        am.put('type', 'text');
        attr_map.add(am);
        am = new Map<String, String>();
        am.put('name', 'sTitle');
        am.put('value', 'someasdjkasjkds');
        am.put('type', 'text');
        attr_map.add(am);

        tch.createContent(attr_map, 'Article');

        setupSitePrefernces();

        ocms_mfc_Article articalController = new ocms_mfc_Article(tch.gc);

        cms__Language__c langObj = new cms__Language__c();
		langObj.cms__Language__c = 'English';
		langObj.cms__Language_Code__c = 'en_US';
		langObj.cms__Index_Key__c = 0;
		langObj.Name = 'English';

		insert langObj;

		Ad_Hoc_Tag__c tag = new Ad_Hoc_Tag__c();
		tag.Name = 'tag1';
		tag.Content__c = articalController.versionOriginId;
		tag.Language__c = langObj.Id;

		insert tag;

		Ad_Hoc_Tag__c tagTwo = new Ad_Hoc_Tag__c();
		tagTwo.Name = 'tag2';
		tagTwo.Content__c = articalController.versionOriginId;
		tagTwo.Language__c = langObj.Id;

		insert tagTwo;

		Ad_Hoc_Tag__c tagThree = new Ad_Hoc_Tag__c();
		tagThree.Name = 'tag3';
		tagThree.Content__c = articalController.versionOriginId;
		tagThree.Language__c = langObj.Id;

		insert tagThree;

        cms__Content_Type__c contentType =  new cms__Content_Type__c();
        contentType.cms__Name__c = 'MFC Article';
        contentType.cms__Label__c = 'MFC Article';
        contentType.cms__Site_Name__c = 'AskHR_Employee_Community';

        insert contentType;

        String html = articalController.getArticleDetailHTML();
        System.assertEquals(true, html.contains(articalController.versionOriginId), 'Contains versionOriginId');
        System.assertEquals(true, html.contains(articalController.body), 'Contains body');
        System.assertEquals(true, html.contains(articalController.author), 'Contains author');
        System.assertEquals(true, html.contains(articalController.authorTitle), 'Contains authorTitle');
        //Tags removed for awhile.
        //Test for the three added tags!
        //System.assertEquals(true, html.contains('<a href="#">tag1</a>'), 'Contains tag 1 markup');
        //System.assertEquals(true, html.contains('<a href="#">tag2</a>'), 'Contains tag 2 markup');
        //System.assertEquals(true, html.contains('<a href="#">tag3</a>'), 'Contains tag 3 markup');

        //Test for sidebar items, these asserts should be false
        System.assertEquals(false, html.contains(articalController.imageHero), 'Contains imageHero');
        System.assertEquals(false, html.contains('<a href="mailto:'+ articalController.authorEmail +'">'), 'Contains authorEmail');

	}

	static testMethod void testGetDetailHTML() {
		ocms_TestContentHelper tch = new ocms_TestContentHelper();
        List<Map<String,String>> attr_map = new List<Map<String, String>>();

        Datetime nowDate = Datetime.now();
        Map<String, String> am = new Map<String, String>();
        am.put('name', 'title');
        am.put('value', 'title');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'publishDate');
        am.put('value', String.valueOf(nowDate.format('MM/dd/yyyy')));
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'summary');
        am.put('value', 'summary');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'body');
        am.put('value', 'body');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'detailSidebar');
        am.put('value', 'true');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'imageIcon');
        am.put('value', 'imageIcon');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'imageHero');
        am.put('value', 'imageHero');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'author');
        am.put('value', 'author');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'authorTitle');
        am.put('value', 'authorTitle');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'authorEmail');
        am.put('value', 'authorEmail');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'authorPhone');
        am.put('value', 'authorPhone');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'webLink');
        am.put('value', 'webLink');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'newsLink');
        am.put('value', 'newsLink');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'socialLink');
        am.put('value', 'socialLink');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'socialType');
        am.put('value', 'socialType');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'contentFlavor');
        am.put('value', 'contentFlavor');
        am.put('type', 'text');
        attr_map.add(am);
        am = new Map<String, String>();
        am.put('name', 'sTitle');
        am.put('value', 'someasdjkasjkds');
        am.put('type', 'text');
        attr_map.add(am);

        tch.createContent(attr_map, 'Article');

        setupSitePrefernces();

        ocms_mfc_Article articalController = new ocms_mfc_Article(tch.gc);

        cms__Language__c langObj = new cms__Language__c();
		langObj.cms__Language__c = 'English';
		langObj.cms__Language_Code__c = 'en_US';
		langObj.cms__Index_Key__c = 0;
		langObj.Name = 'English';

		insert langObj;

		Ad_Hoc_Tag__c tag = new Ad_Hoc_Tag__c();
		tag.Name = 'tag1';
		tag.Content__c = articalController.versionOriginId;
		tag.Language__c = langObj.Id;

		insert tag;

		Ad_Hoc_Tag__c tagTwo = new Ad_Hoc_Tag__c();
		tagTwo.Name = 'tag2';
		tagTwo.Content__c = articalController.versionOriginId;
		tagTwo.Language__c = langObj.Id;

		insert tagTwo;

		Ad_Hoc_Tag__c tagThree = new Ad_Hoc_Tag__c();
		tagThree.Name = 'tag3';
		tagThree.Content__c = articalController.versionOriginId;
		tagThree.Language__c = langObj.Id;

		insert tagThree;

        String html = articalController.getArticleDetailHTML();
        System.assertEquals(true, html.contains(articalController.versionOriginId), 'Contains versionOriginId');
        System.assertEquals(true, html.contains(articalController.body), 'Contains body');
        System.assertEquals(true, html.contains(articalController.author), 'Contains author');
        System.assertEquals(true, html.contains(articalController.authorTitle), 'Contains authorTitle');
        System.assertEquals(true, html.contains(articalController.authorEmail), 'Contains authorEmail');

	}


}