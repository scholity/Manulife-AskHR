/**
 * This class contains the unit tests for validating ocms_mil_Accordion apex class
 *
 * @author  Saloni Mittal
 * @date    2015-May-14
 *
 */

@isTest
private class ocms_mli_Accordion_Test {

    @isTest static void instantiate() {

        ocms_TestContentHelper tch = new ocms_TestContentHelper();
        ocms_mli_Accordion objAccordion = new ocms_mli_Accordion();
        List<Map<String,String>> attr_map = new List<Map<String,String>>();

        Map<String, String> am = new Map<String, String>();

        am = new Map<String, String>();
        am.put('name', 'sAccordionImage');
        am.put('value', 'http://www.path.to/resource/desktopImage.jpg');
        am.put('type', 'Text');
        attr_map.add(am);

        am.put('name', 'sAccordianImageAlt');
        am.put('value', 'Test Image');
        am.put('type', 'Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'sShowContent');
        am.put('value', 'true');
        am.put('type', 'Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'sFirstAccordion');
        am.put('value', 'true');
        am.put('type', 'Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'sAccordianLinkTitle');
        am.put('value', 'Lorem Ipsum dolor sit amet');
        am.put('type', 'Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'sAccordianSummary');
        am.put('value', 'Lorem Ipsum dolor sit amet, consectetur adipiscing elit.');
        am.put('type', 'Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'sAccordianDetail');
        am.put('value', 'Lorem Ipsum dolor sit amet, consectetur adipiscing elit.');
        am.put('type', 'Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'sCallToActionText');
        am.put('value', 'Call to action');
        am.put('type', 'Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'sAccordionDestLink');
        am.put('value', 'External,,NewWindow,,,,http://www.google.ca');
        am.put('type', 'Text');
        attr_map.add(am);

        tch.createContent(attr_map, 'objAccordion');
        objAccordion = new ocms_mli_Accordion(tch.gc);

        objAccordion.getHTML();

        Test.setCurrentPageReference(new PageReference('/apex/cms__CreateContent'));
        System.currentPageReference().getParameters().put('sname', 'manulife');
        System.currentPageReference().getParameters().put('content', tch.gc.content.Id);

        cms.CreateContentController ccc = new cms.CreateContentController();
        objAccordion = new ocms_mli_Accordion(ccc);

    }

}