@isTest
private class ocms_mli_SupportTopic_Test {
	
	@isTest static void instantiate() {
		
        ocms_TestContentHelper tch = new ocms_TestContentHelper();
        ocms_mli_SupportTopic supportTopic = new ocms_mli_SupportTopic();
        List<Map<String,String>> attr_map = new List<Map<String,String>>();

        Map<String, String> am = new Map<String, String>();
        am.put('name','supportTopic');
        am.put('value','blankStringsAreBadForBusiness');
        am.put('type','Text');
        attr_map.add(am);

        tch.createContent(attr_map, 'supportTopic');
        supportTopic = new ocms_mli_SupportTopic(tch.gc);

        supportTopic.getHTML();

        Test.setCurrentPageReference(new PageReference('/apex/cms__CreateContent'));
        System.currentPageReference().getParameters().put('sname', 'manulife');
        System.currentPageReference().getParameters().put('content', tch.gc.content.Id);

        cms.CreateContentController ccc = new cms.CreateContentController();
        supportTopic = new ocms_mli_SupportTopic(ccc);

	}
	
}