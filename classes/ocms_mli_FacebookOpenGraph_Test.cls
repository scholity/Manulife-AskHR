/*
OrchestraCMS Content Layout Tests
#################################

@author Saloni Mittal
@copyright Stantive Technologies Group Inc.
*/
@isTest private class ocms_mli_FacebookOpenGraph_Test {

    static testMethod void instantiate(){

        /*
        Setup the data
        ############## */

        String sSiteName = 'TestSite'; // arbritary test site neame stored in `cms__Sites__.cms__Site_Name__c`
        String type_name = 'TestContentType';
        String page_name = 'TestPage';
        String contentName = 'TestContentName';

        // create content type - based on `testContentHelper.createContent(...)`
        cms__Content_Type__c oCT = new cms__Content_Type__c(cms__Name__c = type_name, cms__Site_Name__c = sSiteName);
        insert oCT;

        // create content layout
        cms__Content_Layout__c oCL = new cms__Content_Layout__c(cms__Name__c = 'TestLayout');
        insert oCL;

        // create content
        // DS, 2017-Feb-26: this still is not picked up the deprecated API call, so we are levraging isTestRunning in the class.
        cms__Content__c oC = new cms__Content__c(
                cms__Content_Type__c         = oCT.Id,
                cms__Name__c                 = contentName,
                cms__Description__c       = 'Testing',
                cms__Preview__c           = true,
                cms__Published__c           = true,
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
        insert oC;

        // Create a page and associate the content layout with it
        cms__Page__c oPage = new cms__Page__c(cms__Name__c = page_name, cms__Site_Name__c = sSiteName);
        insert oPage;

        cms__Content_Layout_Instance__c oCLI = new cms__Content_Layout_Instance__c(cms__Content__c = oC.Id, cms__Content_Layout__c = oCL.Id);
        insert oCLI;

        cms__Page_Content_Layout_Instance__c oPCLI = new cms__Page_Content_Layout_Instance__c(cms__Content_Layout_Instance__c=oCLI.Id,cms__Page__c=oPage.Id);
        insert oPCLI;

        cms__Attribute__c oContentAttribute = null;

        /*oContentAttribute = new cms__Attribute__c(
            cms__Content__c = oC.Id
        //    ,cms__Is_Simple__c = false
            ,cms__Name__c = 'title'
            ,cms__Value__c = '[DS] C18G Awards Article 5'
        );
        insert oContentAttribute;

        oContentAttribute = new cms__Attribute__c(
            cms__Content__c = oC.Id
        //    ,cms__Is_Simple__c = false
            ,cms__Name__c = 'detailPage'
            ,cms__Value__c = 'Internal,a0tW0000000uks9IAA,CurrentWindow,t2-searchable-article-loader-detail-page,,,'
        );
        insert oContentAttribute;

        oContentAttribute = new cms__Attribute__c(
            cms__Content__c = oC.Id
        //    ,cms__Is_Simple__c = false
            ,cms__Name__c = 'articleSummaryImage'
            ,cms__Value__c = '/servlet/servlet.FileDownload?file=00PW0000000zDYXMA2'
        );
        insert oContentAttribute;

        oContentAttribute = new cms__Attribute__c(
            cms__Content__c = oC.Id
        //    ,cms__Is_Simple__c = false
            ,cms__Name__c = 'articleType'
            ,cms__Value__c = 'Blog'
        );
        insert oContentAttribute;*/

         // Create our Site object using `cms.TestExtensionFixtures.InitiateTest` which initializes some needed things (which ones?) using our context - see 'Create Site' section above for more info
        cms__Sites__c oSite = cms.TestExtensionFixtures.InitiateTest(
                            sSiteName
                            ,new Map<String, String>{'runtime' => 'Intranet'
                            ,'name' => page_name
                            ,'page_mode' => 'prev'
                            ,'content_id' => oC.id
                            ,'cli_id' => oCLI.Id
                            ,'pcli_id' => oPCLI.Id
                            });



        /*
        No arugment init test
        ##################### */
        ocms_mli_FacebookOpenGraph oInitNoArgs = new ocms_mli_FacebookOpenGraph();

        /*
        Generate Content init test
        ########################## */

        // Below are pulling the below from `getData` in `Content.cls` where it says 'old custom template method'
        // IMPRV: is there better way to do below? When TextFixtures are opened up. Using `cms.TestExtensionFixtures.InitiateTest`
        // alone is not enough and would result 'Context Not Initialized', one must set the page and page parameters.
        Test.setCurrentPage(new PageReference('/apex/cms__Preview')); // is this needed? doesn't seem so
        System.currentPageReference().getParameters().putAll(
            new Map<String,String>{
                'sname' => sSiteName
                        ,'runtime' => 'Intranet'
                ,'name' => page_name
                ,'page_mode' => 'prev' // OCMS ignores it , context is like a 'stack'
                ,'content_id' => oC.Id // OCMS ignores it
                ,'cli_id' => oCLI.Id   // OCMS ignores it
                ,'pcli_id' => oPCLI.Id // OCMS ignores it
                // 'ecms', anAPI.getSerialize() // looks like it's not needed
            }
        );
        ocms_mli_FacebookOpenGraph oInitGC =  new ocms_mli_FacebookOpenGraph(new cms.GenerateContent());

        /*
        Smoke test
        ==========

        *NOTE:* you must test these in after init the class with `new cms.GenerateContent()` context
        or you will get 'cms.CMS.CacheExcepiton: You do not have permission to execute' if you test using default no
        argument constructor.
        */

        String sTemp = null; // will hold temporary testing results of String type
        Integer iTemp = null; // will hold temporary testing results of Integer type

        /*
        `getHTML()` method
        ------------------

        Testing this method first should cover large chunks of code. We must also take into account
        different rendering pathways if present.
        */

        // `getHTML()` `this.sContentLayoutName` unmatched code pathway
        sTemp = oInitGC.getHTML(); // OCMS method that is called during rendering

        // `getHTML()` has different code pathways based on layout name - let's smoke test those
        oCL.cms__Name__c = 'MLIFacebookOpenGraphArticle';
        update oCL;

        System.currentPageReference().getParameters().put('content_id', oC.Id);

        oInitGC =  new ocms_mli_FacebookOpenGraph(new cms.GenerateContent());
        sTemp = oInitGC.getHTML();

        /*
        Remaining bits and pieces not tested through above
        --------------------------------------------------*/
        sTemp = oInitGC.sContentAsJSON;
        sTemp = oInitGC.sContentPropertiesAsJSON;
        sTemp = oInitGC.sContentLayoutName;
        sTemp = oInitGC.sContentLayoutLabel;
        sTemp = oInitGC.sContentLayoutDescription;

        /*
        Create Content Controler init test
        ################################## */
        Test.setCurrentPage(new PageReference('/apex/cms__CreateContent'));
        // initialize GET/POST parameters - pulled the below by analyzing the Network traffic
        // in Chrome Developer Tools; OCMS uses page parameters to pass information arround
        // Note: appending the GET parameters to the URL won't work, i.e `?sname=' + sSiteName + '&content' + oC.Id)`
        System.currentPageReference().getParameters().put('sname', sSiteName);
        System.currentPageReference().getParameters().put('content', oC.Id);

        ocms_mli_FacebookOpenGraph oInitCCC  = new ocms_mli_FacebookOpenGraph(new cms.CreateContentController());
    }
}