@isTest
private class ocms_mli_FooterMenuItem_Test {
	
	@isTest static void instantiate() {
		
        ocms_TestContentHelper tch = new ocms_TestContentHelper();
        ocms_mli_FooterMenuItem footerMenuItem = new ocms_mli_FooterMenuItem();
        List<Map<String,String>> attr_map = new List<Map<String,String>>();

        Map<String, String> am = new Map<String, String>();
        am.put('name', 'strLabel');
        am.put('value', 'Privacy');
        am.put('type', 'Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'strLink');
        am.put('value', 'External,,NewWindow,,,,http://www.google.ca');
        am.put('type', 'Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'accLabel');
        am.put('value', 'Opens in a new window');
        am.put('type', 'Text');
        attr_map.add(am);

        tch.createContent(attr_map, 'footerMenuItem');
        footerMenuItem = new ocms_mli_FooterMenuItem(tch.gc);

        footerMenuItem.getHTML();

        Test.setCurrentPageReference(new PageReference('/apex/cms__CreateContent'));
        System.currentPageReference().getParameters().put('sname', 'manulife');
        System.currentPageReference().getParameters().put('content', tch.gc.content.Id);

        cms.CreateContentController ccc = new cms.CreateContentController();
        footerMenuItem = new ocms_mli_FooterMenuItem(ccc);

	}	
}