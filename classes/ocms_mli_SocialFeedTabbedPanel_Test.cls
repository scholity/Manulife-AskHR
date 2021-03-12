/**
 * This class contains the unit tests for validating ocms_mli_SocialFeedTabedPanel apex class
 *
 * @author  Saloni Mittal
 * @date    2015-Jun-23
 *
 */

@isTest
public with sharing class ocms_mli_SocialFeedTabbedPanel_Test {
     public static testmethod void instantiate() {

        /*
        Setup the data
        ############## */

        String sSiteName = 'TestSite'; // arbritary test site name stored in `cms__Sites__.cms__Site_Name__c`
        String type_name = 'TestContentType';
        String page_name = 'TestPage';
        String contentName = 'TestContentName';


        // Create our Site object using `cms.TestExtensionFixtures.InitiateTest` which initializes some hidden things from us - see Create Site
        cms__Sites__c oSite = cms.TestExtensionFixtures.InitiateTest(
                            sSiteName
                            ,new Map<String, String>{'runtime' => 'Intranet'
                            ,'sname' => sSiteName
                            ,'name' => page_name
                        });

        /*
        Generate Content init test
        ########################## */

        Test.setCurrentPage(new PageReference('/apex/cms__Preview')); // is this needed? doesn't seem so
        System.currentPageReference().getParameters().put('sname', sSiteName);
        System.currentPageReference().getParameters().put('name', page_name);
        System.currentPageReference().getParameters().put('page_mode', 'prev');

        ocms_mli_SocialFeedTabbedPanel objSMediaTabPanel = new ocms_mli_SocialFeedTabbedPanel();
        List<Map<String,String>> attr_map = new List<Map<String, String>>();

        ocms_TestContentHelper tch = new ocms_TestContentHelper();

        Map<String, String> am = new Map<String, String>();
        am.put('name', 'sFeedAreaTabName');
        am.put('value', 'Twitter');
        am.put('type', 'Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'sFeedAreaTabId');
        am.put('value', '1');
        am.put('type', 'Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'sFeedAreaTitle');
        am.put('value', 'Test Title');
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
        am.put('name', 'sFeedAreaError');
        am.put('value', 'Error Message');
        am.put('type', 'Text');
        attr_map.add(am);

        tch.createContent(attr_map, 'objSMediaTabPanel');
        objSMediaTabPanel = new ocms_mli_SocialFeedTabbedPanel(tch.gc);

        objSMediaTabPanel.getHTML();

        Test.setCurrentPageReference(new PageReference('/apex/cms__CreateContent'));
        System.currentPageReference().getParameters().put('sname', 'manulife');
        System.currentPageReference().getParameters().put('content', tch.gc.content.Id);

        cms.CreateContentController ccc = new cms.CreateContentController();
        objSMediaTabPanel = new ocms_mli_SocialFeedTabbedPanel(ccc);

        Test.startTest();
        Test.setMock(HTTPCalloutMock.class, new CountryFailureMock());
        System.assertNotEquals('{"bSuccess":true,"sMessage"{"foo":"bar"}}', objSMediaTabPanel.getSocialFeedsAsJSON('Twitter'));

        Test.setMock(HTTPCalloutMock.class, new CountrySuccessMock());
        System.assertEquals('{"bSuccess":true,"sMessage":{"foo":"bar"}}', objSMediaTabPanel.getSocialFeedsAsJSON('Twitter'));
        Test.stopTest();

        Map<String, String> p = new Map<String, String>();
        objSMediaTabPanel = new ocms_mli_SocialFeedTabbedPanel();
        p.put('action', 'getSocialFeedsAsJSON');
        p.put('tab', 'Twitter');
        objSMediaTabPanel.executeRequest(p);
      }

      public class CountrySuccessMock implements HttpCalloutMock {
          public HTTPResponse respond(HTTPRequest req) {
              System.assertEquals('GET', req.getMethod(), 'HTTP request should use GET');
              // Fake success response
              HTTPResponse res = new HTTPResponse();
              res.setStatusCode(200);
              res.setBody('{"foo":"bar"}');
              return res;
          }
      }

      public class CountryFailureMock implements HttpCalloutMock {
          public HTTPResponse respond(HTTPRequest req) {
              // Fake server error
              HTTPResponse res = new HTTPResponse();
              res.setStatusCode(500);
              return res;
          }
      }
}