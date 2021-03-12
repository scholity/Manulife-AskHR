/**
 * This class contains the unit tests for validating ocms_mli_PageTitle apex class
 *
 * @author  Saloni Mittal
 * @date    2015-May-20
 *
 */

@isTest
private class ocms_mli_PageTitle_Test {

    @isTest static void instantiate() {

        ocms_TestContentHelper tch = new ocms_TestContentHelper();
        ocms_mli_PageTitle objPageTitle = new ocms_mli_PageTitle();
        List<Map<String,String>> attr_map = new List<Map<String,String>>();

        Map<String, String> am = new Map<String, String>();

        am = new Map<String, String>();
        am.put('name', 'sTitleText');
        am.put('value', 'Page Title');
        am.put('type', 'Text');
        attr_map.add(am);

        tch.createContent(attr_map, 'objPageTitle');
        objPageTitle = new ocms_mli_PageTitle(tch.gc);

        objPageTitle.getHTML();

        Test.setCurrentPageReference(new PageReference('/apex/cms__CreateContent'));
        System.currentPageReference().getParameters().put('sname', 'manulife');
        System.currentPageReference().getParameters().put('content', tch.gc.content.Id);

        cms.CreateContentController ccc = new cms.CreateContentController();
        objPageTitle = new ocms_mli_PageTitle(ccc);

    }

}