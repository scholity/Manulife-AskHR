/**
 * This class contains the unit tests for validating ocms_mil_DroplistSelect apex class
 *
 * @author  Saloni Mittal
 * @date    2015-May-20
 *
 */

@isTest
private class ocms_mli_DroplistSelect_Test {

    @isTest static void instantiate() {

        ocms_TestContentHelper tch = new ocms_TestContentHelper();
        ocms_mli_DroplistSelect objDroplistSelect = new ocms_mli_DroplistSelect();
        List<Map<String,String>> attr_map = new List<Map<String,String>>();

        Map<String, String> am = new Map<String, String>();
        am.put('name', 'jsnDroplist');
        am.put('value', '[{"sLabel":"Lorem ipsum1","sValue":"0"},{"sLabel":"Lorem ipsum2","sValue":"1"}]');
        am.put('type', 'Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'sDroplistTitle');
        am.put('value', 'Lorem ipsum dolor sit');
        am.put('type', 'Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'sDroplistAccessible');
        am.put('value', 'Please select an option');
        am.put('type', 'Text');
        attr_map.add(am);

        tch.createContent(attr_map, 'objDroplistSelect');
        objDroplistSelect = new ocms_mli_DroplistSelect(tch.gc);

        objDroplistSelect.getHTML();

        Test.setCurrentPageReference(new PageReference('/apex/cms__CreateContent'));
        System.currentPageReference().getParameters().put('sname', 'manulife');
        System.currentPageReference().getParameters().put('content', tch.gc.content.Id);

        cms.CreateContentController ccc = new cms.CreateContentController();
        objDroplistSelect = new ocms_mli_DroplistSelect(ccc);


    }

}