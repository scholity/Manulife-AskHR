@isTest
private class ocms_mli_Copyright_Test {
	
	@isTest static void instantiate() {
		
                ocms_TestContentHelper tch = new ocms_TestContentHelper();
                ocms_mli_Copyright copyright = new ocms_mli_Copyright();
                List<Map<String,String>> attr_map = new List<Map<String,String>>();

                Map<String, String> am = new Map<String, String>();
                am.put('name', 'strLabel');
                am.put('value', 'coypright 1999');
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

                tch.createContent(attr_map, 'copyright');
                copyright = new ocms_mli_Copyright(tch.gc);

                copyright.getHTML();

                Test.setCurrentPageReference(new PageReference('/apex/cms__CreateContent'));
                System.currentPageReference().getParameters().put('sname', 'manulife');
                System.currentPageReference().getParameters().put('content', tch.gc.content.Id);

                cms.CreateContentController ccc = new cms.CreateContentController();
                copyright = new ocms_mli_Copyright(ccc);

	}

}