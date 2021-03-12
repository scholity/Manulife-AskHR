@isTest
private class ocms_mli_SocialFeedItem_Test {
	
	@isTest static void instantiate() {
		
        ocms_TestContentHelper tch = new ocms_TestContentHelper();
        ocms_mli_SocialFeedItem socialFeedItem = new ocms_mli_SocialFeedItem();
        List<Map<String,String>> attr_map = new List<Map<String,String>>();

        Map<String, String> am = new Map<String, String>();
        am.put('name', 'strSocialMedia');
        am.put('value', 'ello');
        am.put('type', 'Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'strLink');
        am.put('value', 'http://www.ello.com');
        am.put('type', 'Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'accLinkTitle');
        am.put('value', 'accessible link title');
        am.put('type', 'Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'accDescription');
        am.put('value', 'accessible description');
        am.put('type', 'Text');
        attr_map.add(am);

        tch.createContent(attr_map, 'socialFeedItem');
        socialFeedItem = new ocms_mli_SocialFeedItem(tch.gc);

        socialFeedItem.getHTML();

        Test.setCurrentPageReference(new PageReference('/apex/cms__CreateContent'));
        System.currentPageReference().getParameters().put('sname', 'manulife');
        System.currentPageReference().getParameters().put('content', tch.gc.content.Id);

        cms.CreateContentController ccc = new cms.CreateContentController();
        socialFeedItem = new ocms_mli_SocialFeedItem(ccc);

	}
	
}