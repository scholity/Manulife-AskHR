@isTest
private class ocms_mli_CountryLocator_Test {
	
    @isTest static void instantiate() {
        
        ocms_TestContentHelper tch = new ocms_TestContentHelper();
        ocms_mli_CountryLocator countryLocator = new ocms_mli_CountryLocator();
        List<Map<String,String>> attr_map = new List<Map<String,String>>();

        Map<String, String> am = new Map<String, String>();
        am.put('name', 'jsnCountryInfo');
        am.put('value', '{CA:{buttonLink: "http://www.manulife.ca", buttonText: "visit Manulife.ca", message: "Are you looking for products or services in Canada?"}}');
        am.put('type', 'Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'lblClose');
        am.put('value', 'Close');
        am.put('type', 'Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'accAction');
        am.put('value', 'Opens in a new Window');
        am.put('type', 'Text');
        attr_map.add(am);

        tch.createContent(attr_map, 'countryLocator');
        countryLocator = new ocms_mli_CountryLocator(tch.gc);

        countryLocator.getHTML();

        countryLocator.test_pm = 'prev';

        countryLocator.getHTML();

        Test.setCurrentPageReference(new PageReference('/apex/cms__CreateContent'));
        System.currentPageReference().getParameters().put('sname', 'manulife');
        System.currentPageReference().getParameters().put('content', tch.gc.content.Id);

        cms.CreateContentController ccc = new cms.CreateContentController();
        countryLocator = new ocms_mli_CountryLocator(ccc);


    }
	
}