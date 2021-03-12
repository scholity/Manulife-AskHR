@isTest
private class ocms_mli_LanguageSelector_Test {

    @isTest static void instantiate() {
	       	
        ocms_TestContentHelper tch = new ocms_TestContentHelper();
        ocms_mli_LanguageSelector languageSelector = new ocms_mli_LanguageSelector();
        List<Map<String,String>> attr_map = new List<Map<String,String>>();

        Map<String, String> am = new Map<String, String>();
        am.put('name', 'jsnLanguageButtons');
        am.put('value', '{en_US: "EN", fr: "FR"}');
        am.put('type', 'Text');
        attr_map.add(am);

        tch.createContent(attr_map, 'languageSelector');
        languageSelector = new ocms_mli_LanguageSelector(tch.gc);

        languageSelector.getHTML();

        languageSelector.test_pm = 'prev';

        languageSelector.getHTML();
        System.Debug(languageSelector.jsnAvailableLanguages);

        Test.setCurrentPageReference(new PageReference('/apex/cms__CreateContent'));
        System.currentPageReference().getParameters().put('sname', 'manulife');
        System.currentPageReference().getParameters().put('content', tch.gc.content.Id);

        cms.CreateContentController ccc = new cms.CreateContentController();
        languageSelector = new ocms_mli_LanguageSelector(ccc);

    }
}