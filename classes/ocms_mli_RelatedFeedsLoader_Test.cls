@isTest
private class ocms_mli_RelatedFeedsLoader_Test {

    static testMethod void createRelatedFeeds() {

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
        cms__Content__c oC = new cms__Content__c(
                cms__Content_Type__c         = oCT.Id,
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
        insert oC;

        // Create a page and associate the content layout with it
        cms__Page__c oPage = new cms__Page__c(cms__Name__c = page_name, cms__Site_Name__c = sSiteName);
        insert oPage;

        cms__Content_Layout_Instance__c oCLI = new cms__Content_Layout_Instance__c(cms__Content__c = oC.Id, cms__Content_Layout__c = oCL.Id);
        insert oCLI;

        cms__Page_Content_Layout_Instance__c oPCLI = new cms__Page_Content_Layout_Instance__c(cms__Content_Layout_Instance__c=oCLI.Id,cms__Page__c=oPage.Id);
        insert oPCLI;

        cms__Attribute__c oContentAttribute = null;


		oContentAttribute = new cms__Attribute__c(
		    cms__Content__c = oC.Id
		//    ,cms__Is_Simple__c = false
		    ,cms__Name__c = 'sLoaderTitle'
		    ,cms__Value__c = 'sLoaderTitle'
		);
		insert oContentAttribute;

		oContentAttribute = new cms__Attribute__c(
		    cms__Content__c = oC.Id
		//    ,cms__Is_Simple__c = false
		    ,cms__Name__c = 'sTaxonomyContentLayout'
		    ,cms__Value__c = 'MLIArticleRelatedFeedsItem'
		);
		insert oContentAttribute;

		oContentAttribute = new cms__Attribute__c(
		    cms__Content__c = oC.Id
		//    ,cms__Is_Simple__c = false
		    ,cms__Name__c = 'iQueryLimit'
		    ,cms__Value__c = '3'
		);
		insert oContentAttribute;

         // Create our Site object using `cms.TestExtensionFixtures.InitiateTest` which initializes some needed things (which ones?) using our context - see 'Create Site' section above for more info
        cms__Sites__c oSite = cms.TestExtensionFixtures.InitiateTest(
                            sSiteName
                            ,new Map<String, String>{'runtime' => 'Intranet'
                            //,'sname' => sSiteName not needed see 3013@TestFixtures.cls
                            ,'name' => page_name

                            // [DS,2015-jun-8] the below are commented out because even though they are accepted we continue
                            // getting erros unless we manually set these through ` System.currentPageReference().getParameters().put(...);`
                            // this finding was from Aimia project and digging in the `Content.cls` in OCMS

                            ,'page_mode' => 'prev'
                            ,'content_id' => oC.id
                            ,'cli_id' => oCLI.Id
                            ,'pcli_id' => oPCLI.Id
                            });

        ocms_mli_RelatedFeedsLoader oInitNoArgs = new ocms_mli_RelatedFeedsLoader();

        List<Map<String,String>> attr_map = new List<Map<String, String>>();

        ocms_TestContentHelper tch = new ocms_TestContentHelper();

        Map<String, String> am = new Map<String, String>();

        am = new Map<String, String>();
        am.put('name', 'sLoaderTitle');
        am.put('value', 'sLoaderTitle');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'sLoaderExternalLinkAccessible');
        am.put('value', 'sLoaderExternalLinkAccessible');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'sLoaderExternalLinkLabel');
        am.put('value', 'sLoaderExternalLinkLabel');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'sLoaderExternalLink');
        am.put('value', 'External,,NewWindow,,,,http://www.google.ca');
        am.put('type', 'text');
        attr_map.add(am);

        tch.createContent(attr_map, 'MLIRelatedFeedsLoader', false);

        ocms_mli_RelatedFeedsLoader relatedFeedsLoader = new ocms_mli_RelatedFeedsLoader(tch.gc);
        String getHTML1 = relatedFeedsLoader.getHTML();

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
                ,'name' => page_name
                ,'page_mode' => 'prev'
                ,'content_id' => oC.Id
                ,'cli_id' => oCLI.Id
                ,'pcli_id' => oPCLI.Id
                // 'ecms', anAPI.getSerialize() // looks like it's not needed
            }
        );
        ocms_mli_RelatedFeedsLoader oInitGC =  new ocms_mli_RelatedFeedsLoader(new cms.GenerateContent());

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
        oCL.cms__Name__c = 'MLIRelatedFeedsLoader';
        update oCL;
        oInitGC =  new ocms_mli_RelatedFeedsLoader(new cms.GenerateContent());
        sTemp = oInitGC.getHTML();

        /*
        AJAX end point
        --------------

        Testing this method next should also cover large chunks of code.

        Grab the below POST paramters from 'Chrome Developer Tools > Network tab' in the 'Form Data'
        section of the XHR, you don' tneed `sname`, `token`, and `ocms*` keys
        */

        //oInitNoArgs has executeRequest initialized for Google search, it is not needed in oInitGC
        sTemp = oInitNoArgs.executeRequest(new Map<String, String>{
            'service' => 'ocms_mli_RelatedFeedsLoader'
        });


        /*
        Remaining bits and pieces not tested through above
        --------------------------------------------------*/

        Type oType = oInitGC.getType();

        /*
        Create Content Controler init test
        ################################## */
        Test.setCurrentPage(new PageReference('/apex/cms__CreateContent'));
        // initialize GET/POST parameters - pulled the below by analyzing the Network traffic
        // in Chrome Developer Tools; OCMS uses page parameters to pass information arround
        // Note: appending the GET parameters to the URL won't work, i.e `?sname=' + sSiteName + '&content' + oC.Id)`
        System.currentPageReference().getParameters().put('sname', sSiteName);
        System.currentPageReference().getParameters().put('content', oC.Id);

        ocms_mli_RelatedFeedsLoader oInitCCC  = new ocms_mli_RelatedFeedsLoader(new cms.CreateContentController());

    }

}