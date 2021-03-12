/*
OrchestraCMS Content Layout Controller
######################################

Facebook Open Graph ("Saved by the Bell") generic content layout that should be tailored per project through the
if conditional blocks in `getHTML(...)`.

@author Daniel Sokolowski
@copyright Stantive Technologies Group Inc.
*/
global with sharing class ocms_mli_FacebookOpenGraph extends cms.ContentTemplateController {

    /*
    Class variables
    ===============*/

    private final cms.CreateContentController oCCC; // convenience reference to the CreateContentController instance use when Editing content
    private final cms.GenerateContent oGC; // convenience reference to the GenerateContent instance used when rendering or ajax end point?
    private final cms.ServiceAPI oServiceAPI; // convience variable to access the ServiceAPI instance which we initialize only once
    private final Map<String, String> oPageParametersMap; // will hold `ApexPages.currentPage().getParameters()`


    /*
    Initialization
    ==============*/

    // constructor called for example in `executeRequest`
    public ocms_mli_FacebookOpenGraph() { /* no need the `Layout` in the name word as we are extending ContentTemplateController */
        //super(); // not needed as per Murray McDonald's post https://stantive.my.salesforce.com/0D58000001qE596
        this.oServiceAPI = this.getServiceAPI();
        this.oPageParametersMap = ApexPages.currentPage().getParameters();

        //this.sTaxonomyContentType = this.getProperty('sTaxonomyContentType') ? this.getProperty('sTaxonomyContentType')
        //                            : this.oPageParametersMap.get('sTaxonomyContentType')
    }

    // because we are an visual force page extension we must accept the instance of that visual forces page controller
    public ocms_mli_FacebookOpenGraph(cms.CreateContentController cc) {
        super(cc);

        // looks like initialzing in the blank constructor is all that's needed - that is no the case as we were getting NULL exception for
        // not having it initlaizxed in oGC but something tells me we don't need to check for null because we only init class once
        this.oCCC = cc;
        this.oServiceAPI = this.getServiceAPI();
        this.oPageParametersMap = ApexPages.currentPage().getParameters();
        //this.TCC = new cms.TaxonomyLoadComponentController();
        //this.TCC.init(null);
    }

    // because we are an visual force page extension we must accept the instance of that visual forces page controller
    public ocms_mli_FacebookOpenGraph(cms.GenerateContent gc) {
        super(gc);
        this.oGC = gc;
        this.oServiceAPI = this.getServiceAPI();
        this.oPageParametersMap = ApexPages.currentPage().getParameters();
        //this.TCC = new cms.TaxonomyLoadComponentController();
        ///this.TCC.init(null);
        //System.assert(false, this.TCC.getHTML());
    }


    /*
    Visual Force merge fields / class properties
    ============================================*/

    // Below return some `ContentTempalteController.cls` methods converted to JSON useful for fronend JS development,
    // ex. `var oContent = {!contentAsJSON];` - see other available global instance variables in  `cms.ContentTemplateController`
    // NOTE: VF pages have a url GET 4096 limit which we have encountered so we should always use getHTML()
    public String sContentAsJSON {
        get {return System.JSON.serializePretty(this.content);}
    }

    public String sContentPropertiesAsJSON {
        get {return System.JSON.serializePretty(this.content_properties);}
    }

    public String sContentLayoutName {
        get {
            // based on Bill's code
            // IMPRV: cache the query hit for both LayoutName and LayoutLabel
            this.sContentLayoutName = 'Unknown';
            if (null != content_layout_instance) {
                cms__Content_Layout__c[] cl = [
                        SELECT
                                Id, cms__Name__c, cms__Label__c
                        FROM
                                cms__Content_Layout__c
                        WHERE
                                Id = :this.content_layout_instance.cms__content_layout__c
                ];

                if (cl.size() == 1) {
                    this.sContentLayoutName = cl[0].cms__Name__c;

                }
            }
            return this.sContentLayoutName;
        }
        set;
    }

    public String sContentLayoutLabel {
        get {
            // based on Bill's code
            // IMPRV: cache the query hit for both LayoutName and LayoutLabel
            this.sContentLayoutName = 'Unknown';
            if (null != content_layout_instance) {
                cms__Content_Layout__c[] cl = [
                        SELECT
                                Id, cms__Name__c, cms__Label__c
                        FROM
                                cms__Content_Layout__c
                        WHERE
                                Id = :this.content_layout_instance.cms__content_layout__c
                ];

                if (cl.size() == 1) {
                    this.sContentLayoutLabel = cl[0].cms__Label__c;

                }
            }
            return this.sContentLayoutLabel;
        }
        set;
    }


    public String sContentLayoutDescription {
        get {
            // based on Bill's code
            // IMPRV: cache the query hit for both LayoutName and LayoutLabel
            this.sContentLayoutDescription = 'Unknown';
            if (null != content_layout_instance) {
                cms__Content_Layout__c[] cl = [
                        SELECT
                                Id, cms__Description__c
                        FROM
                                cms__Content_Layout__c
                        WHERE
                                Id = :this.content_layout_instance.cms__content_layout__c
                ];

                if (cl.size() == 1) {
                    this.sContentLayoutDescription = cl[0].cms__Description__c;

                }
            }
            return this.sContentLayoutDescription;
        }
        set;
    }



    /*
    * getHTML()
    * ---------
    *
    * Using `getHTML()` is preferred over `Visualforce View` pages as it is faster and does not have 'maximum allowed length of 4,096' issue
    * limit, but note however that SF will not honor field level security compared to if a VF page is used - https://developer.salesforce.com/page/Enforcing_CRUD_and_FLS
    *
    */
    public override String getHTML() {
        String sHTML = '<!-- >>> ocms_mli_FacebookOpenGraph.getHTML(...): '
                //+ (this.pm == 'prev' ? 'this.content_layout_instance=' + this.content_layout_instance : '').escapeHTML4() this can error out on non escaped/encoded -->
                + ' -->\n';  // to fix any jQuery parsing issue and it's a good design pattern, see: https://pl5.projectlocker.com/Stantive/PSTools/trac/wiki/gotcha/OCMSCachingMissingMarkup

        // special case for the class to handle detail generation of detail article based on id
        if (this.sContentLayoutName == 'MLIFacebookOpenGraphArticle') {
            sHTML += '<!-- === ocms_mli_FacebookOpenGraph.getHTML(...): MLIFacebookOpenGraphArticle -->\n';
            String contentId ='';
            contentId = this.oPageParametersMap.get('content_id');
            try {
                System.debug('contentId:' + contentId);
                cms__Content__c oLatestContent = this.oServiceAPI.getLatestContentVersion(contentId);
                if (Test.isRunningTest() && oLatestContent == null) {
                    // create content type - based on `testContentHelper.createContent(...)`
                    String sSiteName = 'TestSite'; // arbritary test site neame stored in `cms__Sites__.cms__Site_Name__c`
                    String type_name = 'TestContentType';
                    String page_name = 'TestPage';
                    String contentName = 'TestContentName';

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
                    oLatestContent = oC;
                }
                System.debug('oLatestContent:' + oLatestContent);
                // NOTE: for proper initializaiton of GenearteContent.cls we must pass ` if(key == cache_key || Test.isRunningTest()) {` but we can't
                //       since we can't call `GenearteContent.getOcmsCachingKey` we tried in a 'hackish' way populate some of the global
                //       variables so that we can still leverage the class instance - i.e. foo.formattedDate() however that was
                //       not successful, TODO: createa  story to allow content layout initialization from another content layout's class
                //System.currentPageReference().getParameters().put('content_id', oLatestContent.id);
                /*cms.GenerateContent oGC = new cms.GenerateContent();
                oGC.properties =  oLatestContent.cms__Attributes__r;
                ocms_mli_Article oArticleGC = new ocms_mli_Article(oGC);
                System.assert(false,oArticleGC); // still didn't work
                */
                if (oLatestContent != null){
                    sHTML += '<meta property="og:type" content="website" />';
                    Boolean bArticleSummaryImageExists = False; //used to output default image tag if no image on article
                    Boolean bArticleSummaryExists = False;      //used to output blank if no article summary
                    String sArticleType = '';
                    for (cms__Attribute__c attr : oLatestContent.cms__Attributes__r) {
                        if (attr.cms__Name__c == 'title') {
                            sHTML += '<meta property="og:title" content="' + attr.cms__Value__c.escapeHTML4() + '"/>';
                        }
                        if (attr.cms__Name__c == 'detailPage') {
                            sHTML += '<meta property="og:url" content="' + sManulifeBaseUrl + ocms_mli_Utility.getLinkHref((new cms.Link(attr.cms__Value__c, null, null, 'content_id=' + contentId).targetPage)) + '"/>';
                        }
                        if (attr.cms__Name__c == 'articleSummaryImage') {
                            sHTML += '<meta property="og:image" content="' + sManulifeBaseUrl + attr.cms__Value__c.escapeHTML4() + '"/>';
                            sHTML += '<meta property="og:image:secure_url" content="' + sManulifeBaseUrl + attr.cms__Value__c.escapeHTML4() + '"/>';
                            bArticleSummaryImageExists = True;
                        }
                        if (attr.cms__Name__c == 'articleSummary') {
                            sHTML += '<meta property="og:description" content="' + attr.cms__Value__c.escapeHTML4() + '"/>';
                            bArticleSummaryExists = True;
                        }
                        if (attr.cms__Name__c == 'articleType') {
                            sArticleType = attr.cms__Value__c;
                        }
                    }
                    if (bArticleSummaryImageExists == False) {
                        sHTML += '<meta property="og:image" content="' + sManulifeBaseUrl + '/resource/ocms_mli_pageSupport/fbImages/default-' + sArticleType + '.png"/>';
                        sHTML += '<meta property="og:image:secure_url" content="' + sManulifeBaseUrl + '/resource/ocms_mli_pageSupport/fbImages/default-' + sArticleType + '.png"/>';
                        sHTML += '<meta property="og:image:type" content="image/png"/>';
                        sHTML += '<meta property="og:image:width" content="600"/>';
                        sHTML += '<meta property="og:image:height" content="315"/>';
                    }

                    if (bArticleSummaryExists == False) {
                        sHTML += '<meta property="og:description" content=""/>';
                    }
                }
                else {
                    if (this.pm == 'prev') {
                        sHTML += '<meta name="OCMSDebug" content="Preview mode only output: No `content_id=xxxxx` GET/POST parameter provided, or the content is expired" >';
                    }
                }
            }
            catch (Exception e) {
                if (this.pm == 'prev') {sHTML += '<meta name="OCMSDebug" content="Preview mode only output: the provided id for `content_id` GET/POST is invalid, ' + e + '" >';}
            }
        }
        else {
            sHTML += '<!-- === ocms_mli_FacebookOpenGraph.getHTML(...): Unknown -->\n';
            sHTML += 'Unknown rendering for `this.sContentLayoutName`: ' + this.sContentLayoutName + '\n';
        }

        // we don't want to bleed potential vector of attack info, so we only output our debug in prev mode
        sHTML += '<!-- <<< ocms_mli_FacebookOpenGraph.getHTML(...): '
                // below gives total for request's duration not this method's NET
                //+ (this.pm == 'prev' ? 'Limits.getCpuTime()=' + Limits.getCpuTime() + ', Limits.getAggregateQueries()=' + Limits.getAggregateQueries() + ', Limits.getHeapSize()=' + Limits.getHeapSize() : '').escapeHTML4()
                + ' -->\n'; //  to fix any jQuery parsing issue and it's a good design pattern, see: https://pl5.projectlocker.com/Stantive/PSTools/trac/wiki/gotcha/OCMSCachingMissingMarkup

        return sHTML;
    }
    
    public String sManulifeBaseUrl {
        get {
            return getProperty('sManulifeBaseUrl');
        }
        set;
    }

}