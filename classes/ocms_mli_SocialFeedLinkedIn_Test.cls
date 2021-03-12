/**
 * This class contains the unit tests for validating ocms_mli_SocialFeedLinkedIn apex class
 *
 * @author  Saloni Mittal
 * @date    2015-Jun-18
 *
 */

@isTest
private class ocms_mli_SocialFeedLinkedIn_Test {

    @isTest static void instantiate() {

        ocms_TestContentHelper tch = new ocms_TestContentHelper();
        ocms_mli_SocialFeedLinkedIn objSMediaLinkedIn = new ocms_mli_SocialFeedLinkedIn();
        List<Map<String,String>> attr_map = new List<Map<String,String>>();

        Map<String, String> am = new Map<String, String>();

        am = new Map<String, String>();
        am.put('name', 'sFeedAreaTabId');
        am.put('value', '1');
        am.put('type', 'Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'sTabCheck');
        am.put('value', 'true');
        am.put('type', 'Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'sFeedAreaTitle');
        am.put('value', 'Test Title');
        am.put('type', 'Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'sFeedAreaImage');
        am.put('value', 'http://www.path.to/resource/desktopImage.jpg');
        am.put('type', 'Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'sFeedAreaImageAltText');
        am.put('value', 'Lorem Ipsum dolor sit amet');
        am.put('type', 'Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'sFeedAreaMessage');
        am.put('value', 'Lorem Ipsum dolor sit amet, consectetur adipiscing elit.');
        am.put('type', 'Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'sFeedAreaSignInLinkText');
        am.put('value', 'Call to action');
        am.put('type', 'Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'sFeedAreaSignInLink');
        am.put('value', 'External,,NewWindow,,,,http://www.google.ca');
        am.put('type', 'Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'sFeedAreaFollowLinkText');
        am.put('value', 'Call to action');
        am.put('type', 'Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'sFeedAreaFollowLink');
        am.put('value', 'External,,NewWindow,,,,http://www.google.ca');
        am.put('type', 'Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'sFeedAreaSupplierText');
        am.put('value', 'Lorem Ipsum dolor sit amet, consectetur adipiscing elit.');
        am.put('type', 'Text');
        attr_map.add(am);

        tch.createContent(attr_map, 'objSMediaLinkedIn');
        objSMediaLinkedIn = new ocms_mli_SocialFeedLinkedIn(tch.gc);

        objSMediaLinkedIn.getHTML();

        Test.setCurrentPageReference(new PageReference('/apex/cms__CreateContent'));
        System.currentPageReference().getParameters().put('sname', 'manulife');
        System.currentPageReference().getParameters().put('content', tch.gc.content.Id);

        cms.CreateContentController ccc = new cms.CreateContentController();
        objSMediaLinkedIn = new ocms_mli_SocialFeedLinkedIn(ccc);

    }

}