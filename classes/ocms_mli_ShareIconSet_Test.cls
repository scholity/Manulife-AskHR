/**
 * This class contains the unit tests for validating ocms_mli_ShareIconSet apex class
 *
 * @author  Saloni Mittal
 * @date    2015-Jul-09
 *
 */

@isTest
private class ocms_mli_ShareIconSet_Test {

    @isTest static void instantiate() {

        ocms_TestContentHelper tch = new ocms_TestContentHelper();
        ocms_mli_ShareIconSet shareIconSetObj = new ocms_mli_ShareIconSet();
        List<Map<String,String>> attr_map = new List<Map<String,String>>();

        Map<String, String> am = new Map<String, String>();

        am = new Map<String, String>();
        am.put('name', 'sShareLabel');
        am.put('value', 'Lorem Ipsum dolor sit amet');
        am.put('type', 'Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'sShareAccessible');
        am.put('value', 'Lorem Ipsum dolor sit amet');
        am.put('type', 'Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'sFBLikeScript');
        am.put('value', 'Lorem Ipsum dolor sit amet');
        am.put('type', 'Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'sFBShareLabel');
        am.put('value', 'Lorem Ipsum dolor sit amet');
        am.put('type', 'Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'sFBShareAccessible');
        am.put('value', 'Lorem Ipsum dolor sit amet');
        am.put('type', 'Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'sFBShareAccessible');
        am.put('value', 'Lorem Ipsum dolor sit amet');
        am.put('type', 'Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'sTwitterShareLabel');
        am.put('value', 'Lorem Ipsum dolor sit amet');
        am.put('type', 'Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'sTwitterShareAccessible');
        am.put('value', 'Lorem Ipsum dolor sit amet');
        am.put('type', 'Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'sLinkedInShareLabel');
        am.put('value', 'Lorem Ipsum dolor sit amet');
        am.put('type', 'Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'sLinkedInShareAccessible');
        am.put('value', 'Lorem Ipsum dolor sit amet');
        am.put('type', 'Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'sPrintLabel');
        am.put('value', 'Lorem Ipsum dolor sit amet');
        am.put('type', 'Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'sPrintAccessible');
        am.put('value', 'Lorem Ipsum dolor sit amet');
        am.put('type', 'Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'sEmailLabel');
        am.put('value', 'Lorem Ipsum dolor sit amet');
        am.put('type', 'Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'sEmailAccessible');
        am.put('value', 'Lorem Ipsum dolor sit amet');
        am.put('type', 'Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'sEmailAddress');
        am.put('value', 'Lorem Ipsum dolor sit amet');
        am.put('type', 'Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'sEmailSubject');
        am.put('value', 'Lorem Ipsum dolor sit amet');
        am.put('type', 'Text');
        attr_map.add(am);

        tch.createContent(attr_map, 'shareIconSetObj');
        shareIconSetObj = new ocms_mli_ShareIconSet(tch.gc);

        shareIconSetObj.getHTML();

        Test.setCurrentPageReference(new PageReference('/apex/cms__CreateContent'));
        System.currentPageReference().getParameters().put('sname', 'manulife');
        System.currentPageReference().getParameters().put('content', tch.gc.content.Id);

        cms.CreateContentController ccc = new cms.CreateContentController();
        shareIconSetObj = new ocms_mli_ShareIconSet(ccc);

    }

}