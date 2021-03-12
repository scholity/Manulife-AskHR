/**
 * This class contains the unit tests for validating ocms_mli_SectionTitle apex class
 *
 * @author  Saloni Mittal
 * @date    2015-May-20
 *
 */

@isTest
private class ocms_mli_SectionTitle_Test {

    @isTest static void instantiate() {

        ocms_TestContentHelper tch = new ocms_TestContentHelper();
        ocms_mli_SectionTitle objSectionTitle = new ocms_mli_SectionTitle();
        List<Map<String,String>> attr_map = new List<Map<String,String>>();

        Map<String, String> am = new Map<String, String>();

        am = new Map<String, String>();
        am.put('name', 'sTitleImageIcon');
        am.put('value', 'http://www.path.to/resource/desktopImage.jpg');
        am.put('type', 'Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'sTitleImageAlt');
        am.put('value', 'Individual');
        am.put('type', 'Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'sTitleText');
        am.put('value', 'Individual');
        am.put('type', 'Text');
        attr_map.add(am);

        tch.createContent(attr_map, 'objSectionTitle');
        objSectionTitle = new ocms_mli_SectionTitle(tch.gc);

        objSectionTitle.getHTML();

        Test.setCurrentPageReference(new PageReference('/apex/cms__CreateContent'));
        System.currentPageReference().getParameters().put('sname', 'manulife');
        System.currentPageReference().getParameters().put('content', tch.gc.content.Id);

        cms.CreateContentController ccc = new cms.CreateContentController();
        objSectionTitle = new ocms_mli_SectionTitle(ccc);

    }

}