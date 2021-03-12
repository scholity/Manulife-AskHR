@isTest
private class ocms_mli_MegaMenuPromo_Test {
	
    @isTest static void instantiate() {
	   	
        ocms_TestContentHelper tch = new ocms_TestContentHelper();
        ocms_mli_MegaMenuPromo megaMenuPromo = new ocms_mli_MegaMenuPromo();
        List<Map<String,String>> attr_map = new List<Map<String,String>>();

        Map<String, String> am = new Map<String, String>();
        am.put('name', 'strLinkText');
        am.put('value', '');
        am.put('type', 'Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'strContentId');
        am.put('value', '');
        am.put('type', 'Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'strLinkAccessibilityText');
        am.put('value', '');
        am.put('type', 'Text');
        attr_map.add(am);        

        am = new Map<String, String>();
        am.put('name', 'strPromoImage');
        am.put('value', '');
        am.put('type', 'Text');
        attr_map.add(am);  

        am = new Map<String, String>();
        am.put('name', 'strImageHoverText');
        am.put('value', '');
        am.put('type', 'Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'strLink');
        am.put('value', '');
        am.put('type', 'Text');
        attr_map.add(am);

        tch.createContent(attr_map, 'MegaMenuPromo');
        megaMenuPromo = new ocms_mli_MegaMenuPromo(tch.gc);
        megaMenuPromo.pm = 'prev';

        megaMenuPromo.getHTML();

        megaMenuPromo.pm = 'production';

        megaMenuPromo.getHTML();

        Test.setCurrentPageReference(new PageReference('/apex/cms__CreateContent'));
        System.currentPageReference().getParameters().put('sname', 'manulife');
        System.currentPageReference().getParameters().put('content', tch.gc.content.Id);

        cms.CreateContentController ccc = new cms.CreateContentController();
        megaMenuPromo = new ocms_mli_MegaMenuPromo(ccc);

    }
	
}