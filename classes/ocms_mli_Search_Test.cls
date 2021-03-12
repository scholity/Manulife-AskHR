/*
OrchestraCMS Content Layout Tests
#################################

@author Daniel Sokolowski
@copyright Stantive Technologies Group Inc.
*/
@isTest private class ocms_mli_Search_Test {

    static testMethod void test_ocms_mli_Search(){

        /*
        Setup the data
        ############## */

        String sSiteName = 'TestSite'; // arbritary test site neame stored in `cms__Sites__.cms__Site_Name__c`
        String type_name = 'TestContentType';
        String page_name = 'TestPage';
        String contentName = 'TestContentName';


        // Create Site

        // [2015-jun-8] the below manual site creation is commented beacuse using `cms.TestExtensionFixtures.InitiateTest(...)` create the site
        // and set our context (it has to be placed after our cli/pcli defintitons) did not work for us in Aimia and we were getting null
        // pointer exception. But creating `System.currentPageReference().getParameters().put`  GET parameters manually did work HOWEVER
        // not using `cms.TestExtensionFixtures.InitiateTest(...)` resulted in `Context Not Initialized` so the solution was to use both

        // create site based on `TextFixtures.setupSimpleSite(...)` code
        /*cms__Sites__c oSite = new cms__Sites__c(cms__Site_Domain__c = 'test.force.com'
                                     ,cms__Site_Name__c = sSiteName
                                     ,cms__Site_Label__c = sSiteName
                                     ,cms__Package_Version__c = 'test'
                                     ,cms__Site_Url__c = 'http://test.force.com/'
                                     ,cms__Site_Secure_URL__c = 'https://test.force.com');
        insert oSite;
        */


        // create content type - based on `testContentHelper.createContent(...)`
        cms__Content_Type__c ct = new cms__Content_Type__c(cms__Name__c = type_name, cms__Site_Name__c = sSiteName);
        insert ct;

        cms__Content__c txc = new cms__Content__c(
                cms__Content_Type__c         = ct.Id,
                cms__Name__c                 = contentName,
                cms__Description__c       = 'Testing',
                cms__Preview__c           = true,
                cms__Published__c           = false,
                cms__Published_Start_Date__c = System.now(),
                cms__Site_Name__c           = sSiteName,
                cms__Revision_Number__c   = 0,
                cms__Revision_Origin__c   = null,
                cms__Version_Number__c     = 1,
                cms__Version_Origin__c     = null,
                cms__Version_Original__c     = true,
                cms__Version_Parent__c     = null,
                cms__Depth__c               = 0
        );
        insert txc;

        // create content layout
        cms__Content_Layout__c cl = new cms__Content_Layout__c(cms__Name__c = 'TestLayout');
        insert cl;

        // Create a page and associate the content layout with it
        cms__Page__c page = new cms__Page__c(cms__Name__c = page_name, cms__Site_Name__c = sSiteName);
        insert page;

        cms__Content_Layout_Instance__c cli = new cms__Content_Layout_Instance__c(cms__Content__c = txc.Id, cms__Content_Layout__c = cl.Id);
        insert cli;

        cms__Page_Content_Layout_Instance__c pcli = new cms__Page_Content_Layout_Instance__c(cms__Content_Layout_Instance__c=cli.Id,cms__Page__c=page.Id);
        insert pcli;

        // create content attributes - you can grab these with following steps:
        // - in OCMS go into Edit page of the content layout instance
        // - right click 'View Frame Source' and extract the `content=<SALESFORCEID>` from the URL
        // - take the SALESFORCEID and paste it into your SF org url ex: https://aimiaintranet--ocmsdev.cs17.my.salesforce.com/a1Kg0000000Pdj3EAC
        // - scroll down to the Attributes and see full list

        /*
        cms__Attribute__c oContentAttribute = null;
        oContentAttribute = new cms__Attribute__c(
            cms__Content__c = txc.Id
            //,cms__Page_Content_Layout_Instance__c = pcli.Id
            ,cms__Is_Simple__c = false
            ,cms__Name__c = 'HTMLContent'
            ,cms__Value__c = 'This is for ALL USERS - GLOBAL'
            ,cms__Simple_Name__c = 'HTMLContent'
            ,cms__Simple_Value__c = ''
        );
        insert oContentAttribute;
        */


        // Create our Site object using `cms.TestExtensionFixtures.InitiateTest` which initializes some hidden things from us - see Create Site
        cms__Sites__c oSite = cms.TestExtensionFixtures.InitiateTest(
							sSiteName
							,new Map<String, String>{'runtime' => 'Intranet'
							,'sname' => sSiteName
							,'name' => page_name

                            // [DS,2015-jun-8] the below are commented out because even though they are accepted we continue
                            // getting erros unless we manually set these through ` System.currentPageReference().getParameters().put(...);`
                            // this finding was from Aimia project and digging in the `Content.cls` in OCMS
							/*,'page_mode' => 'prev'
							,'content_id' => txc.id
							,'cli_id' => cli.Id
							,'pcli_id' => pcli.Id*/
							});



        /*
        No arugment intitalization test
        ############################### */

        ocms_mfc_SiteSettings__c sitePreferenceCustomSetting = new ocms_mfc_SiteSettings__c();
        sitePreferenceCustomSetting.Name = 'Manulife Central';
        sitePreferenceCustomSetting.GSA_MLI_Endpoint__c = 'http://gsaextranetd.manulife.com';
        sitePreferenceCustomSetting.GSA_MFC_Endpoint__c = 'https://gsaintranetd.manulife.com';
        sitePreferenceCustomSetting.GSA_Client_Certificate_Name__c = '';

        insert sitePreferenceCustomSetting;
        
        ocms_mli_Search oInitNoArgs = new ocms_mli_Search();



        /*
        Generate Content init test
        ########################## */
        // below are pull from `getData` in `Content.cls` where it says 'old custom template method'
        // IMPRV: is there better way to do below? When TextFixtures are opened up or using `cms.TestExtensionFixtures.InitiateTest` but we run into 'Context Not Initialized'

        Test.setCurrentPage(new PageReference('/apex/cms__Preview')); // is this needed? doesn't seem so
        System.currentPageReference().getParameters().put('sname', sSiteName);
        System.currentPageReference().getParameters().put('name', page_name);
        System.currentPageReference().getParameters().put('page_mode', 'prev');
        System.currentPageReference().getParameters().put('content_id', txc.Id);
        System.currentPageReference().getParameters().put('cli_id', cli.Id);
        System.currentPageReference().getParameters().put('pcli_id', pcli.Id);
        //System.currentPageReference().getParameters().put('ecms', anAPI.getSerialize());

        // initialize our contnet layout
        cms.GenerateContent gc = new cms.GenerateContent();



        /*
        Smoke test
        ##########*/
        String sTemp = null;


        // `getHTML()` unknown `this.sContentLayoutName` pathway
        ocms_mli_Search oInitGC  = new ocms_mli_Search(gc);
        sTemp = oInitGC.contentAsJSON; // DS's convention class property
        sTemp = oInitGC.contentPropertiesAsJSON;
        sTemp = oInitGC.sContentLayoutLabel;
        sTemp = oInitGC.sContentLayoutDescription;
        //sTemp = oInitGC.getType(); // needed by cms.ServiceInterface
        sTemp = oInitGC.getHTML(); // OCMS method call during rendering
        Type oTemp = oInitGC.getType();
        sTemp = oInitGC.sContentLayoutDescription;
        sTemp = oInitGC.sButtonSubmitLabel;
        sTemp = oInitGC.sQueryTermInputLabel;
        sTemp = oInitGC.sSortByLabel;
        sTemp = oInitGC.sSortByAscendingLabel;
        sTemp = oInitGC.sSortByDescendingLabel;
        sTemp = oInitGC.sTabWorldwideLabel;
        sTemp = oInitGC.sTabLocalLabel;
        sTemp = oInitGC.sResultInformationHTML;
        cms.Link oLink = oInitGC.sSearchResultsPageSelectorValueAsLink;
        sTemp = oInitGC.sSearchResultsPageSelectorValue;
        sTemp = oInitGC.sQueryTermInputPlaceholder;
        sTemp = oInitGC.sIconSearchLabel;

        // `getHTML()` has different code pathways based on layout name - let's smoke test those
        cl.cms__Name__c = 'MLIGoogleSearchHeaderInput';
        update cl;
        oInitGC  = new ocms_mli_Search(gc);
        sTemp = oInitGC.getHTML(); // OCMS method call during rendering

        cl.cms__Name__c = 'MLIGoogleSearchResults';
        update cl;
        oInitGC  = new ocms_mli_Search(gc);
        sTemp = oInitGC.getHTML(); // OCMS method call during rendering


        // Grab the below POST paramters from 'Chrome Developer Tools > Network tab' in the 'Form Data'
        // section of the XHR, you don' tneed `sname`, `token`, and `ocms*` keys
        sTemp = oInitNoArgs.executeRequest(new Map<String, String>{
	        'action' => 'getSearchResultAsJSON'
			,'sQueryTerm' => 'test'
			,'sQueryOrder' => 'asc'
			,'iQueryOffset' => '0'
			,'iQueryLimit' => '10'
			,'service' => 'ocms_mli_Search'
        });


        /*
        Create Content Controler test
        ############################# */
        Test.setCurrentPage(new PageReference('/apex/cms__CreateContent'));
        // initialize GET/POST parameters - pulled the below by analyzing the Network traffic
        // in Chrome Developer Tools; OCMS uses page parameters to pass information arround
        // Note: appending the GET parameters to the URL won't work, i.e `?sname=' + sSiteName + '&content' + txc.Id)`
        System.currentPageReference().getParameters().put('sname', sSiteName);
        System.currentPageReference().getParameters().put('content', txc.Id);

        cms.CreateContentController ccc = new cms.CreateContentController();
        ocms_mli_Search ncccc  = new ocms_mli_Search(ccc);



    }

}