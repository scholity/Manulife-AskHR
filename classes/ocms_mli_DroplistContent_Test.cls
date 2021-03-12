/**
 * This class contains the unit tests for validating ocms_mil_DroplistContent apex class
 *
 * @author  Saloni Mittal
 * @date    2015-May-20
 *
 */

@isTest
private class ocms_mli_DroplistContent_Test {

    @isTest static void instantiate() {

        ocms_TestContentHelper tch = new ocms_TestContentHelper();
        ocms_mli_DroplistContent objDroplistContent = new ocms_mli_DroplistContent();
        List<Map<String,String>> attr_map = new List<Map<String,String>>();

        Map<String, String> am = new Map<String, String>();
        am.put('name', 'sDroplistText');
        am.put('value', 'Lorem ipsum dolor sit amet, consectetuer adipiscing elit.');
        am.put('type', 'Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'sDroplistAccessible');
        am.put('value', 'Accessible Text');
        am.put('type', 'Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'sLinkText');
        am.put('value', 'Learn More');
        am.put('type', 'Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'sLink');
        am.put('value', 'External,,NewWindow,,,,http://www.google.ca');
        am.put('type', 'Text');
        attr_map.add(am);

        tch.createContent(attr_map, 'objDroplistContent');
        objDroplistContent = new ocms_mli_DroplistContent(tch.gc);

        objDroplistContent.getHTML();

        Test.setCurrentPageReference(new PageReference('/apex/cms__CreateContent'));
        System.currentPageReference().getParameters().put('sname', 'manulife');
        System.currentPageReference().getParameters().put('content', tch.gc.content.Id);

        cms.CreateContentController ccc = new cms.CreateContentController();
        objDroplistContent = new ocms_mli_DroplistContent(ccc);


    }

}