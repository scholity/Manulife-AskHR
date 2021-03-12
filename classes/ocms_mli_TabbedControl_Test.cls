@isTest
private class ocms_mli_TabbedControl_Test {

    @isTest static void instantiation() {
        
        ocms_TestContentHelper tch = new ocms_TestContentHelper();
        ocms_mli_TabbedControl tabbedControl = new ocms_mli_TabbedControl();
        List<Map <String, String>> attr_map = new List<Map <String, String>>();
        
        Map<String, String> am = new Map<String, String>();
        am.put('name', 'jsnTabList');
        am.put('value', '["tab1","tab2","tab3"]');
        am.put('type', 'Text');
        attr_map.add(am);
        
        tch.createContent(attr_map, 'tabbedControl');
        tabbedControl = new ocms_mli_TabbedControl(tch.gc);
        
        tabbedControl.getHTML();
        
        Test.setCurrentPageReference(new PageReference('/apex/cms__CreateContent'));
        System.currentPageReference().getParameters().put('sname','manulife');
        System.currentPageReference().getParameters().put('content',tch.gc.content.Id);
        
        cms.CreateContentController ccc = new cms.CreateContentController();
        tabbedControl = new ocms_mli_TabbedControl(ccc);
        
    }

}