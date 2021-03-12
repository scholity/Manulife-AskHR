/**
 * This class contains the unit tests for validating ocms_mli_SocialFeedsTabbedMenu apex class
 *
 * @author  Saloni Mittal
 * @date    2015-Jun-18
 *
 */

@isTest
private class ocms_mli_SocialFeedsTabbedMenu_Test {

    @isTest static void instantiate() {

        ocms_TestContentHelper tch = new ocms_TestContentHelper();
        ocms_mli_SocialFeedsTabbedMenu objSocialFeedsTabbedMenu = new ocms_mli_SocialFeedsTabbedMenu();
        List<Map<String,String>> attr_map = new List<Map<String,String>>();

        Map<String, String> am = new Map<String, String>();
        am.put('name', 'jsnSocialFeedslist');
        am.put('value', '[{"sSocialMedia":"Twitter","sAccessibleText":"Twitter","sTabId":"1"},{"sSocialMedia":"Facebook","sAccessibleText":"Facebook","sTabId":"2"}]');
        am.put('type', 'Text');
        attr_map.add(am);

        tch.createContent(attr_map, 'objSocialFeedsTabbedMenu');
        objSocialFeedsTabbedMenu = new ocms_mli_SocialFeedsTabbedMenu(tch.gc);

        objSocialFeedsTabbedMenu.getHTML();

        Test.setCurrentPageReference(new PageReference('/apex/cms__CreateContent'));
        System.currentPageReference().getParameters().put('sname', 'manulife');
        System.currentPageReference().getParameters().put('content', tch.gc.content.Id);

        cms.CreateContentController ccc = new cms.CreateContentController();
        objSocialFeedsTabbedMenu = new ocms_mli_SocialFeedsTabbedMenu(ccc);


    }

}