/**
 * This class contains the unit tests for validating ocms_mil_HighlightBlockHorizontal apex class
 *
 * @author  Saloni Mittal
 * @date    2015-May-13
 *
 */

@isTest
private class ocms_mli_HightlightBlockHorizontal_Test {

    @isTest static void instantiate() {

        ocms_TestContentHelper tch = new ocms_TestContentHelper();
        ocms_mli_HighlightBlockHorizontal highlightBlockHorizontal = new ocms_mli_HighlightBlockHorizontal();
        List<Map<String,String>> attr_map = new List<Map<String,String>>();

        Map<String, String> am = new Map<String, String>();

        am = new Map<String, String>();
        am.put('name', 'blockImage');
        am.put('value', 'http://www.path.to/resource/desktopImage.jpg');
        am.put('type', 'Text');
        attr_map.add(am);

        am.put('name', 'sBlockImageAlt');
        am.put('value', 'Test Image');
        am.put('type', 'Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'sBlockTitle');
        am.put('value', 'Lorem Ipsum dolor sit amet');
        am.put('type', 'Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'sBlockDescription');
        am.put('value', 'Lorem Ipsum dolor sit amet, consectetur adipiscing elit.');
        am.put('type', 'Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'sLinkText');
        am.put('value', 'Call to action');
        am.put('type', 'Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'blockLink');
        am.put('value', 'External,,NewWindow,,,,http://www.google.ca');
        am.put('type', 'Text');
        attr_map.add(am);

        tch.createContent(attr_map, 'highlightBlockHorizontal');
        highlightBlockHorizontal = new ocms_mli_HighlightBlockHorizontal(tch.gc);

        highlightBlockHorizontal.getHTML();

        Test.setCurrentPageReference(new PageReference('/apex/cms__CreateContent'));
        System.currentPageReference().getParameters().put('sname', 'manulife');
        System.currentPageReference().getParameters().put('content', tch.gc.content.Id);

        cms.CreateContentController ccc = new cms.CreateContentController();
        highlightBlockHorizontal = new ocms_mli_HighlightBlockHorizontal(ccc);

    }

}