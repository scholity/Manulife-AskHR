@isTest
private class ocms_SearchIndexExecutorTest {
	private static String siteName;
	private static ocms_Search_Index_Settings__c settings;

	private static void init() {
		String contentType = 'TestContentType';
		String contentLayout = 'TestLayout';
		String pageName = 'TestPage';
		siteName = 'TestSite';

		// Set up search settings
		settings = new ocms_Search_Index_Settings__c(
			Name = siteName
		);

		//  Setup the test content for the batchable
        ocms_SearchIndexTestContentHelper tch = new ocms_SearchIndexTestContentHelper();
        tch.createSitePreferences();

        List<Map<String, String>> tag_map = new List<Map<String, String>>();
        List<Map<String, String>> attr_map = new List<Map<String, String>>();
        Map<String, String> am = new Map<String, String>();

        String summary = 'This is a summary with potential reserved non-encoded characters: \"#$%&\'()*+,/:;<=>?@[\\]^`{|}!';
        attr_map.add(new Map<String, String>{'name'=>'summary', 'type'=>'text', 'value'=>summary});

        tag_map.add( new Map<String,String>{'name' => 'News Taxonomy'} );
        tag_map.add( new Map<String,String>{'name' => 'News'} );
        tag_map.add( new Map<String,String>{'name' => 'Critical Global'} );

        Id txc = tch.createContent('TESTCONTENT', attr_map, tag_map);

		//  Update the content type isSearchable flag
		cms__Content_Type__c ct = [SELECT Id, Name, cms__Name__c, Include_In_Search_Index__c, cms__Sites__c FROM cms__Content_Type__c WHERE cms__Name__c = :contentType AND cms__Site_Name__c = :siteName LIMIT 1];
		ct.Include_In_Search_Index__c = true;
		ct.cms__Sites__c = tch.theSite.Id;
		update ct;

		for (cms__Content_Type__c ct1: [SELECT cms__Name__c, cms__Site_Name__c, cms__Sites__r.cms__Site_Name__c, Include_In_Search_Index__c FROM cms__Content_Type__c
									 WHERE cms__Sites__r.cms__Site_Name__c = :siteName
									 AND   Include_In_Search_Index__c = true
										])
		{
			System.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>>  CONTENT TYPE = ' + ct1);
		}

		cms__Content_Layout__c cl = [SELECT Id, Name, cms__Name__c FROM cms__Content_Layout__c WHERE cms__Name__c = :contentLayout];

		cms__Page__c p = [SELECT Id, Name, cms__Name__c FROM cms__Page__c WHERE cms__Name__c = :pageName AND cms__Site_Name__c = :siteName];

		cms__Content_Template_Relationship__c ctr = new cms__Content_Template_Relationship__c(cms__Auto_Create__c = true, cms__Content_Type__c = ct.Id, cms__Content_Layout__c = cl.Id, cms__Preview_Page__c = p.Id, cms__Default__c = true);
		insert ctr;

		cms__Content__c c = [SELECT Id, Name, cms__Name__c, cms__Published__c, cms__Published_Start_Date__c, cms__Published_End_Date__c, cms__Sites__c FROM cms__Content__c WHERE Id = :txc];
		c.cms__Published__c = true;
		c.cms__Sites__c = tch.theSite.Id;
		update c;
		System.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>>  CONTENT = ' + c);

        cms__Language__c theLanguage = [SELECT id FROM cms__Language__c LIMIT 1];

		cms__Content_Tag_Index__c tagIndex = new cms__Content_Tag_Index__c(
			cms__Content__c = c.Id,
			cms__Language__c = theLanguage.Id,
			cms__Full_Path__c = '/foo/bar/baz'
		);
		insert tagIndex;
	}

    static testMethod void testSearchIndexExecutor() {
    	init();

		Test.StartTest();

			ocms_SearchIndexExecutor sie = new ocms_SearchIndexExecutor(new Map<String, String>{'sname' => siteName, 'runtime' => 'Intranet'}, false, settings);
			Id batchProcessId = Database.executeBatch(sie, 10000);

		Test.StopTest();
    }

    static testMethod void testPageSearchIndexExecutor() {
    	init();

    	Test.StartTest();
    		ocms_SearchIndexPageExecutor psie = new ocms_SearchIndexPageExecutor(new Map<String, String>{'sname' => siteName, 'runtime' => 'Intranet', 'ocmsLang' => 'en_US'}, false, settings);
    		Id batchProcessId = Database.executeBatch(psie, 50);
    	Test.StopTest();
    }
}