/**
 * This class contains the unit tests for validating ocms_mli_GenericContent apex class
 *
 * @author  Saloni Mittal
 * @date    2015-Jun-16
 *
 */

@isTest
private class ocms_mli_GenericContent_Test {

    @isTest static void instantiate() {

        ocms_TestContentHelper tch = new ocms_TestContentHelper();
        ocms_mli_GenericContent genericContentObj = new ocms_mli_GenericContent();
        List<Map<String,String>> attr_map = new List<Map<String,String>>();

        Map<String, String> am = new Map<String, String>();

        am = new Map<String, String>();
        am.put('name', 'sGenericContentIcon');
        am.put('value', 'http://www.path.to/resource/desktopImage.jpg');
        am.put('type', 'Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'sGenericContentTitle');
        am.put('value', 'Lorem Ipsum dolor sit amet');
        am.put('type', 'Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'sGenericContentHeading');
        am.put('value', 'Lorem Ipsum dolor sit amet');
        am.put('type', 'Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'sGenericContentBody');
        am.put('value', 'Lorem Ipsum dolor sit amet, consectetur adipiscing elit.');
        am.put('type', 'Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'sGenericContentImage');
        am.put('value', 'http://www.path.to/resource/desktopImage.jpg');
        am.put('type', 'Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'sGenericContentImageMobile');
        am.put('value', 'http://www.path.to/resource/mobileImage.jpg');
        am.put('type', 'Text');
        attr_map.add(am);

        am.put('name', 'sGenericContentImageAlt');
        am.put('value', 'Test Image');
        am.put('type', 'Text');
        attr_map.add(am);


        am = new Map<String, String>();
        am.put('name', 'sLinkTitle');
        am.put('value', 'Learn More');
        am.put('type', 'Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'sLink');
        am.put('value', 'External,,NewWindow,,,,http://www.google.ca');
        am.put('type', 'Text');
        attr_map.add(am);

        tch.createContent(attr_map, 'genericContentObj');
        genericContentObj = new ocms_mli_GenericContent(tch.gc);

        genericContentObj.getHTML();

        Test.setCurrentPageReference(new PageReference('/apex/cms__CreateContent'));
        System.currentPageReference().getParameters().put('sname', 'manulife');
        System.currentPageReference().getParameters().put('content', tch.gc.content.Id);

        cms.CreateContentController ccc = new cms.CreateContentController();
        genericContentObj = new ocms_mli_GenericContent(ccc);

    }

}