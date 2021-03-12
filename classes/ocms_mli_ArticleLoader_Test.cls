/*
OrchestraCMS Content Layout Tests
#################################

@author Daniel Sokolowski
@copyright Stantive Technologies Group Inc.
*/
@isTest private class ocms_mli_ArticleLoader_Test {

    static testMethod void test_ocms_mli_ArticleLoader(){

        /*
        Setup the data
        ############## */

        String sSiteName = 'TestSite'; // arbritary test site neame stored in `cms__Sites__.cms__Site_Name__c`
        String type_name = 'TestContentType';
        String page_name = 'TestPage';
        String contentName = 'TestContentName';


        // Create Site

        // [2015-jun-28,FIXME] the below manual site creation is commented beacuse using the below is not enough
        // and results in `Context Not Initialized` (since 6.11 see Bill's comment in `ocms_TestContentHelper.cls`).
        //
        // After testing a to `cms.TestExtensionFixtures.InitiateTest(...)` is needed however it does not matter or
        // is engouh you pass the required parameters (`name`, `page_mode`, etc.), one must also set the test page
        // and `put` page parameters.
        //
        // Another option suggested was to `cms.ServiceAPI sAPI = (cms.ServiceAPI)cms.ServiceEndpoint.getService('cms.ServiceAPI', contextParams );`
        // but that still resulted in 'cms.CMS.CacheExcepiton: You do not have permission to execute' so using InitiateTest
        // and setting pate and page parameters seems the only options at the moment.

        // create site based on `TextFixtures.setupSimpleSite(...)` code
        /*cms__Sites__c oSite = new cms__Sites__c(cms__Site_Domain__c = 'test.force.com'
                                     ,cms__Site_Name__c = sSiteName
                                     ,cms__Site_Label__c = sSiteName
                                     ,cms__Package_Version__c = 'test'
                                     ,cms__Site_Url__c = 'http://test.force.com/'
                                     ,cms__Site_Secure_URL__c = 'https://test.force.com');
        insert oSite;*/




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


        // DS,2015-jul-29: FIXME: none of the attributes seem to be honored our getters are defaulting to our default values
        // create content attributes - you can grab these with following steps:
        // - in OCMS go into Edit page of the content layout instance
        // - right click 'View Frame Source' and extract the `content=<SALESFORCEID>` from the URL
        // - take the SALESFORCEID and paste it into your SF org url ex: https://aimiaintranet--ocmsdev.cs17.my.salesforce.com/a1Kg0000000Pdj3EAC
        // - scroll down to the Attributes and see full list
        // - click on 'Go to list'
        // - run following JavaScript snippet and copy the console output bleow
        //   - you can turn it into a bookmarklet: https://en.wikipedia.org/wiki/Bookmarklet
        //
        // javascript:var sApex = 'cms__Attribute__c oContentAttribute = null;\n\n';var aElements = [].slice.call(document.querySelectorAll('table.list tr.dataRow'),0);for (var i=0; i < aElements.length; i++) {   var oRowElement = aElements[i];   var aTDList = oRowElement.querySelectorAll('td');   sApex += 'oContentAttribute = new cms__Attribute__c(\n'          + '    cms__Content__c = oC.Id\n'          + '//    ,cms__Is_Simple__c = false\n'          + '    ,cms__Name__c = \'' + aTDList[1].innerHTML + '\'\n'          + '    ,cms__Value__c = \'' + aTDList[2].innerHTML + '\'\n'          + ');\n'          + 'insert oContentAttribute;\n\n';}console.log(sApex);

        cms__Attribute__c oContentAttribute = null;

		oContentAttribute = new cms__Attribute__c(
		    cms__Content__c = oC.Id
		//    ,cms__Is_Simple__c = false
		    ,cms__Name__c = 'sContentBlocksListViewStyle'
		    ,cms__Value__c = 'listViewStyleVariantA'
		);
		insert oContentAttribute;

		oContentAttribute = new cms__Attribute__c(
		    cms__Content__c = oC.Id
		//    ,cms__Is_Simple__c = false
		    ,cms__Name__c = 'iQueryLimit'
		    ,cms__Value__c = '10'
		);
		insert oContentAttribute;

		oContentAttribute = new cms__Attribute__c(
		    cms__Content__c = oC.Id
		//    ,cms__Is_Simple__c = false
		    ,cms__Name__c = 'sTaxonomyContentLayout'
		    ,cms__Value__c = 'MLIArticleSearchableSummaryJSON'
		);
		insert oContentAttribute;

		oContentAttribute = new cms__Attribute__c(
		    cms__Content__c = oC.Id
		//    ,cms__Is_Simple__c = false
		    ,cms__Name__c = 'sTaxonomyContentType'
		    ,cms__Value__c = 'MLIArticle'
		);
		insert oContentAttribute;

		oContentAttribute = new cms__Attribute__c(
		    cms__Content__c = oC.Id
		//    ,cms__Is_Simple__c = false
		    ,cms__Name__c = 'sArticleDetailPageLink'
		    ,cms__Value__c = 'Internal,a0tW0000000ug3LIAQ,CurrentWindow,TEST---Article-Detail-Display-2,,,'
		);
		insert oContentAttribute;

		oContentAttribute = new cms__Attribute__c(
		    cms__Content__c = oC.Id
		//    ,cms__Is_Simple__c = false
		    ,cms__Name__c = 'sFeatureRequired'
		    ,cms__Value__c = 'false'
		);
		insert oContentAttribute;

		oContentAttribute = new cms__Attribute__c(
		    cms__Content__c = oC.Id
		//    ,cms__Is_Simple__c = false
		    ,cms__Name__c = '&nbsp;'
		    ,cms__Value__c = '&nbsp;'
		);
		insert oContentAttribute;

		oContentAttribute = new cms__Attribute__c(
		    cms__Content__c = oC.Id
		//    ,cms__Is_Simple__c = false
		    ,cms__Name__c = 'sDefaultContentBlocksLayout'
		    ,cms__Value__c = 'blockView'
		);
		insert oContentAttribute;

		oContentAttribute = new cms__Attribute__c(
		    cms__Content__c = oC.Id
		//    ,cms__Is_Simple__c = false
		    ,cms__Name__c = 'sLoaderLabel'
		    ,cms__Value__c = 'Sample: Content Loader Title Label (Optional)'
		);
		insert oContentAttribute;

		oContentAttribute = new cms__Attribute__c(
		    cms__Content__c = oC.Id
		//    ,cms__Is_Simple__c = false
		    ,cms__Name__c = 'sLoaderSummary'
		    ,cms__Value__c = 'Sample: Content Loader Summary (Optional)'
		);
		insert oContentAttribute;

		oContentAttribute = new cms__Attribute__c(
		    cms__Content__c = oC.Id
		//    ,cms__Is_Simple__c = false
		    ,cms__Name__c = 'sTaxonomyTimeIntervalNodeDefaultFilter'
		    ,cms__Value__c = 'Awards Taxonomy/Year/2015'
		);
		insert oContentAttribute;

		oContentAttribute = new cms__Attribute__c(
		    cms__Content__c = oC.Id
		//    ,cms__Is_Simple__c = false
		    ,cms__Name__c = 'sTaxonomyLocationNode'
		    ,cms__Value__c = 'Awards Taxonomy/Location'
		);
		insert oContentAttribute;

		oContentAttribute = new cms__Attribute__c(
		    cms__Content__c = oC.Id
		//    ,cms__Is_Simple__c = false
		    ,cms__Name__c = 'bDisplayShowMoreControl'
		    ,cms__Value__c = 'true'
		);
		insert oContentAttribute;

		oContentAttribute = new cms__Attribute__c(
		    cms__Content__c = oC.Id
		//    ,cms__Is_Simple__c = false
		    ,cms__Name__c = 'sSearchBarPlaceholderText'
		    ,cms__Value__c = 'Enter Your Search Term...'
		);
		insert oContentAttribute;

		oContentAttribute = new cms__Attribute__c(
		    cms__Content__c = oC.Id
		//    ,cms__Is_Simple__c = false
		    ,cms__Name__c = 'sFilterToggleLabel'
		    ,cms__Value__c = 'Filter'
		);
		insert oContentAttribute;

		oContentAttribute = new cms__Attribute__c(
		    cms__Content__c = oC.Id
		//    ,cms__Is_Simple__c = false
		    ,cms__Name__c = 'sFilterToggleAccessibilityLabel'
		    ,cms__Value__c = 'Has popup'
		);
		insert oContentAttribute;

		oContentAttribute = new cms__Attribute__c(
		    cms__Content__c = oC.Id
		//    ,cms__Is_Simple__c = false
		    ,cms__Name__c = 'sBlockViewButtonAccessibilityLabel'
		    ,cms__Value__c = 'Change to block view'
		);
		insert oContentAttribute;

		oContentAttribute = new cms__Attribute__c(
		    cms__Content__c = oC.Id
		//    ,cms__Is_Simple__c = false
		    ,cms__Name__c = 'sListViewButtonAccessibilityLabel'
		    ,cms__Value__c = 'Change to list view'
		);
		insert oContentAttribute;

		oContentAttribute = new cms__Attribute__c(
		    cms__Content__c = oC.Id
		//    ,cms__Is_Simple__c = false
		    ,cms__Name__c = 'sFilterListSelectAllLabel'
		    ,cms__Value__c = 'Select All'
		);
		insert oContentAttribute;

		oContentAttribute = new cms__Attribute__c(
		    cms__Content__c = oC.Id
		//    ,cms__Is_Simple__c = false
		    ,cms__Name__c = 'sFilterListResetLabel'
		    ,cms__Value__c = 'Reset'
		);
		insert oContentAttribute;

		oContentAttribute = new cms__Attribute__c(
		    cms__Content__c = oC.Id
		//    ,cms__Is_Simple__c = false
		    ,cms__Name__c = 'sFilterListSubmitLabel'
		    ,cms__Value__c = 'Submit'
		);
		insert oContentAttribute;

		oContentAttribute = new cms__Attribute__c(
		    cms__Content__c = oC.Id
		//    ,cms__Is_Simple__c = false
		    ,cms__Name__c = 'sFilterKeywordsListLabel'
		    ,cms__Value__c = 'Filters'
		);
		insert oContentAttribute;

		oContentAttribute = new cms__Attribute__c(
		    cms__Content__c = oC.Id
		//    ,cms__Is_Simple__c = false
		    ,cms__Name__c = 'sTileViewMoreLabel'
		    ,cms__Value__c = 'Read More'
		);
		insert oContentAttribute;

		oContentAttribute = new cms__Attribute__c(
		    cms__Content__c = oC.Id
		//    ,cms__Is_Simple__c = false
		    ,cms__Name__c = 'sTagPathsDefault'
		    ,cms__Value__c = 'Brand Taxonomy/Category'
		);
		insert oContentAttribute;

		oContentAttribute = new cms__Attribute__c(
		    cms__Content__c = oC.Id
		//    ,cms__Is_Simple__c = false
		    ,cms__Name__c = 'sTaxonomyTimeIntervalNode'
		    ,cms__Value__c = 'Brand Taxonomy/Time Interval'
		);
		insert oContentAttribute;

		oContentAttribute = new cms__Attribute__c(
		    cms__Content__c = oC.Id
		//    ,cms__Is_Simple__c = false
		    ,cms__Name__c = 'bDisplaySearchBar'
		    ,cms__Value__c = 'true'
		);
		insert oContentAttribute;

		oContentAttribute = new cms__Attribute__c(
		    cms__Content__c = oC.Id
		//    ,cms__Is_Simple__c = false
		    ,cms__Name__c = 'bDisplayFilterControls'
		    ,cms__Value__c = 'true'
		);
		insert oContentAttribute;

		oContentAttribute = new cms__Attribute__c(
		    cms__Content__c = oC.Id
		//    ,cms__Is_Simple__c = false
		    ,cms__Name__c = 'bDisplayContentBlocksLayoutChanger'
		    ,cms__Value__c = 'true'
		);
		insert oContentAttribute;

		oContentAttribute = new cms__Attribute__c(
		    cms__Content__c = oC.Id
		//    ,cms__Is_Simple__c = false
		    ,cms__Name__c = 'sListViewStyle'
		    ,cms__Value__c = 'variantA'
		);
		insert oContentAttribute;

		oContentAttribute = new cms__Attribute__c(
		    cms__Content__c = oC.Id
		//    ,cms__Is_Simple__c = false
		    ,cms__Name__c = 'bDisplayFeaturedArticle'
		    ,cms__Value__c = 'true'
		);
		insert oContentAttribute;

		oContentAttribute = new cms__Attribute__c(
		    cms__Content__c = oC.Id
		//    ,cms__Is_Simple__c = false
		    ,cms__Name__c = 'bDisplaySocialMediaWidget'
		    ,cms__Value__c = 'true'
		);
		insert oContentAttribute;

		oContentAttribute = new cms__Attribute__c(
		    cms__Content__c = oC.Id
		//    ,cms__Is_Simple__c = false
		    ,cms__Name__c = 'sTaxonomySortingMode'
		    ,cms__Value__c = 'releaseDate'
		);
		insert oContentAttribute;

		oContentAttribute = new cms__Attribute__c(
		    cms__Content__c = oC.Id
		//    ,cms__Is_Simple__c = false
		    ,cms__Name__c = 'sResultItemViewMoreLabel'
		    ,cms__Value__c = 'Read More'
		);
		insert oContentAttribute;

		oContentAttribute = new cms__Attribute__c(
		    cms__Content__c = oC.Id
		//    ,cms__Is_Simple__c = false
		    ,cms__Name__c = 'bHideSearchBar'
		    ,cms__Value__c = 'false'
		);
		insert oContentAttribute;

		oContentAttribute = new cms__Attribute__c(
		    cms__Content__c = oC.Id
		//    ,cms__Is_Simple__c = false
		    ,cms__Name__c = 'bHideFilterControls'
		    ,cms__Value__c = 'false'
		);
		insert oContentAttribute;

		oContentAttribute = new cms__Attribute__c(
		    cms__Content__c = oC.Id
		//    ,cms__Is_Simple__c = false
		    ,cms__Name__c = 'bHideContentBlocksLayoutChanger'
		    ,cms__Value__c = 'false'
		);
		insert oContentAttribute;

		oContentAttribute = new cms__Attribute__c(
		    cms__Content__c = oC.Id
		//    ,cms__Is_Simple__c = false
		    ,cms__Name__c = 'sTaxonomyName'
		    ,cms__Value__c = 'Awards Taxonomy'
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



        /*
        No arugment init test
        ##################### */
        // the below does not seem to be needed to test the no argumenet constructor
        /*
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
        );*/
        ocms_mli_ArticleLoader oInitNoArgs = new ocms_mli_ArticleLoader();



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
                ,'page_mode' => 'prev' // OCMS ignores it , context is like a 'stack'
                ,'content_id' => oC.Id // OCMS ignores it
                ,'cli_id' => oCLI.Id   // OCMS ignores it
                ,'pcli_id' => oPCLI.Id // OCMS ignores it
                // 'ecms', anAPI.getSerialize() // looks like it's not needed
            }
        );
        ocms_mli_ArticleLoader oInitGC =  new ocms_mli_ArticleLoader(new cms.GenerateContent());


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
        oCL.cms__Name__c = 'MLISearchableArticleLoaderDetail';
        update oCL;
        oInitGC =  new ocms_mli_ArticleLoader(new cms.GenerateContent());
        sTemp = oInitGC.getHTML();

        oCL.cms__Name__c = 'MLISearchableArticleLoaderList';
        update oCL;
        oInitGC =  new ocms_mli_ArticleLoader(new cms.GenerateContent());
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
	        'service' => 'ocms_mli_ArticleLoader' // the class name
            ,'action' => 'sSearchResultsAsJSON' // the action to test
			,'sTaxonomyTimeIntervalNodeDefaultFilter' => ''
			,'sTaxonomyMandatoryFilterNode' => ''
            ,'sTaxonomyContentType' => ''
			,'sTaxonomyContentLayout' => ''
			,'iQueryOffset' => '0'
			,'iQueryLimit' => '10'

        });


        /*
        Remaining bits and pieces not tested through above
        --------------------------------------------------*/


        Type oType = oInitGC.getType();
        sTemp = oInitGC.sContentAsJSON;
        sTemp = oInitGC.sContentPropertiesAsJSON;
        sTemp = oInitGC.sContentLayoutLabel;
        sTemp = oInitGC.sContentLayoutDescription;
        sTemp = oInitGC.sTaxonomyPathFilter; //IMPRV: you can also test the POST/GET pathway
        sTemp = oInitGC.sTaxonomyTimeIntervalNode;
        sTemp = oInitGC.sFilterListSelectAllLabel;
        //DateTime oDateTime = oInitGC.getFormatedDateTime('06/10/2015 00:00');

        /*sTemp = oInitGC.sContentAsJSON; // common method to DS design patterns
        sTemp = oInitGC.contentPropertiesAsJSON; // common method to DS design patterns
        sTemp = oInitGC.sContentLayoutName; // common method to DS design patterns
        sTemp = oInitGC.sContentLayoutLabel; // common method to DS design patterns
        sTemp = oInitGC.sContentLayoutDescription; // common method to DS design patterns
        iTemp = oInitGC.iQueryOffset; // common method to DS design patterns
        iTemp = oInitGC.iQueryLimit; // common method to DS design patterns
        sTemp = oInitGC.sTaxonomyName; // common method to DS design patterns
        sTemp = oInitGC.sTaxonomyContentType; // common method to DS design patterns
        sTemp = oInitGC.sTaxonomyContentLayout; // common method to DS design patterns
        sTemp = oInitGC.sTaxonomyPathFilter; // common method to DS design patterns
        sTemp = oInitGC.sTaxonomyContentLayout; // common method to DS design patterns
        sTemp = oInitGC.sTaxonomyContentLayout; // common method to DS design patterns
        sTemp = oInitGC.sTaxonomyContentLayout; // common method to DS design patterns

        sTemp = oInitGC.getType().getName(); // needed by cms.ServiceInterface*/




        /*
        Create Content Controler init test
        ################################## */
        Test.setCurrentPage(new PageReference('/apex/cms__CreateContent'));
        // initialize GET/POST parameters - pulled the below by analyzing the Network traffic
        // in Chrome Developer Tools; OCMS uses page parameters to pass information arround
        // Note: appending the GET parameters to the URL won't work, i.e `?sname=' + sSiteName + '&content' + oC.Id)`
        System.currentPageReference().getParameters().put('sname', sSiteName);
        System.currentPageReference().getParameters().put('content', oC.Id);

        ocms_mli_ArticleLoader oInitCCC  = new ocms_mli_ArticleLoader(new cms.CreateContentController());


    }
}