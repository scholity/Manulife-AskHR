@isTest
private class ocms_mli_CountryMenuPromo_Test {
	
	@isTest static void instantiate() {
		
        ocms_TestContentHelper tch = new ocms_TestContentHelper();
        ocms_mli_CountryMenuPromo countryMenuPromo = new ocms_mli_CountryMenuPromo();
        List<Map<String,String>> attr_map = new List<Map<String,String>>();

        Map<String, String> am = new Map<String, String>();
        am.put('name', 'strContentId');
        am.put('value', 'promo1');
        am.put('type', 'Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'strSummary');
        am.put('value', 'summary text');
        am.put('type', 'Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'strLink');
        am.put('value', 'linkAttributesHere');
        am.put('type', 'Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'strLinkTitle');
        am.put('value', 'Opens in a new window');
        am.put('type', 'Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'strLinkText');
        am.put('value', 'Learn More');
        am.put('type', 'Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'strImage');
        am.put('value', 'pathToImageFile');
        am.put('type', 'Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'strPromoImageAlt');
        am.put('value', 'Opens In A New Window');
        am.put('type', 'Text');
        attr_map.add(am);        

        am = new Map<String, String>();
        am.put('name', 'accText');
        am.put('value', 'Opens in a new window');
        am.put('type', 'Text');
        attr_map.add(am);

        tch.createContent(attr_map, 'countryMenuPromo');
        countryMenuPromo = new ocms_mli_CountryMenuPromo(tch.gc);
        countryMenuPromo.pm = 'prev';

        countryMenuPromo.getHTML();

        countryMenuPromo.pm = 'production';

        countryMenuPromo.getHTML();

        Test.setCurrentPageReference(new PageReference('/apex/cms__CreateContent'));
        System.currentPageReference().getParameters().put('sname', 'manulife');
        System.currentPageReference().getParameters().put('content', tch.gc.content.Id);

        cms.CreateContentController ccc = new cms.CreateContentController();
        countryMenuPromo = new ocms_mli_CountryMenuPromo(ccc);

	}

}