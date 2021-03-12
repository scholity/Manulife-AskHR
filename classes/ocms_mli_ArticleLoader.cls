/*
 * @author Jialin Guo, Daniel Sokolowski
 * @description Custom taxonomy loader to meet Manulife.com's article display requirements
 *
 *
 * Content Caching Settings: 'isContentCachable': FALSE, 'isPageCachable': FALSE
 * =============================================================================
 *
 * This content is not cachable as we are utilzing a cookie country to pre-select the country select
 * box on the back end.
 *
 */


global virtual with sharing class ocms_mli_ArticleLoader extends cms.ContentTemplateController implements cms.ServiceInterface{

    /*
    Class variables
    ===============*/

    private final cms.CreateContentController oCCC; // convenience reference to the CreateContentController instance use when Editing content
    private final cms.GenerateContent oGC; // convenience reference to the GenerateContent instance used when rendering or ajax end point?
    private final cms.ServiceAPI oServiceAPI; // convience variable to access the ServiceAPI instance which we initialize only once



    /*
    Initialization
    ==============*/

    // Default constructor invoked through `executeRequest` (where AJAX parameters become POST/GET page parameters) or
    // in OrchestraCMS cache generation
    // NOTE: if your content is cachable you must ensure that `getHTML` has no direct dependecny on POST/GET parameters
    public ocms_mli_ArticleLoader() { /* no need the `Layout` in the name word as we are extending ContentTemplateController */
        //super(); // not needed as per Murray McDonald's post https://stantive.my.salesforce.com/0D58000001qE596
        this.oServiceAPI = this.getServiceAPI();
    }

    // because we are an visual force page extension we must accept the instance of that visual forces page controller
    public ocms_mli_ArticleLoader(cms.CreateContentController cc) {
        super(cc);

        // looks like initialzing in the blank constructor is all that's needed - that is no the case as we were getting NULL exception for
        // not having it initlaizxed in oGC but something tells me we don't need to check for null because we only init class once
        this.oCCC = cc;
        this.oServiceAPI = this.getServiceAPI();
    }

    // because we are an visual force page extension we must accept the instance of that visual forces page controller
    public ocms_mli_ArticleLoader(cms.GenerateContent gc) {
        super(gc);

        this.oGC = gc;
        this.oServiceAPI = this.getServiceAPI();
    }

    // Required for cms.ServiceInterface instantiation.
    global System.Type getType() {
        return ocms_mli_ArticleLoader.class;
    }



    /*
    Apex class properties, a.k.a. Visual Force merge fields
    =======================================================*/

    // a XSS santized reference to page parameters
    public Map<String, String> oPageParametersMap {
        get {
             System.debug('>>> ocms_mli_SocialFeedTabbedPanel.oPageParametersMap');
             if (this.oPageParametersMap == null) {
                // XSS santize the data - inspired by 7.89.15 `ocmsContext.cls` - we don't need chunking since we don't leverage large values
                this.oPageParametersMap = ApexPages.currentPage() != null ?  ApexPages.currentPage().getParameters() : new Map<String,String>{};
                                              // during cache generation `ApexPages.currentPage()` is null so we fallback to empty map.
                Pattern oXSSRegexMatcher = Pattern.compile('(?i)(</?script|javascript:|<iframe|<input|<link|<object|<meta|<style|<base|<embed|url\\s*\\(|expression\\(|<[^>]*on[^=>]*(=|%3d)|".*on[^="]*(=|%3d))');

                String sValue = '';
                for (String sKey : oPageParametersMap.keySet()) {
                    sValue = oPageParametersMap.get(sKey);
                    sValue = sValue.replaceAll('(?s)[\\n\\r\\t\\x00]|(?:/\\*.*\\*/)', ''); // first cleanse the string of any cr (#13), lf(#10), horizontal tab(#9) or null characters which browsers tend to "ignore"
                    sValue = (EncodingUtil.urlDecode(sValue, 'UTF-8')).unescapeHtml4(); // decode those hidden <> see `xssAngleBrackets` in ocmsContext.cls, ex `System.debug((EncodingUtil.urlDecode('&lt;  &gt;  &#60; &#62; %3C %3E)', 'UTF-8')).unescapeHtml4());`
                    System.debug('=== ocms_mli_SocialFeedTabbedPanel.oPageParametersMap: sKey: '+ sKey + ' | sValue: ' + sValue + ' ');
                    // check for possible XSS and delete the key if so
                    if (oXSSRegexMatcher.matcher(sValue).find() == true) {
                        oPageParametersMap.remove(sKey);
                    }
                }
             }
             System.debug('=== ocms_mli_SocialFeedTabbedPanel.oPageParametersMap: this.oPageParametersMap: ' + this.oPageParametersMap);
             System.debug('<<< ocms_mli_SocialFeedTabbedPanel.oPageParametersMap');
             return this.oPageParametersMap;
        }
        set;
    }


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

    public Integer iQueryOffset {
        get { // default getter is: get { return iQueryOffset; } see: https://developer.salesforce.com/blogs/developer-relations/2008/06/property-access.html
            Integer iTemp = 0; // default value
            try {
                iTemp = Integer.valueOf(this.oPageParametersMap.get('iqueryoffset'));
            }
            catch (Exception e){} // can't use `finally` as it always executes and does not catch exceptions
            return iTemp;
        }
        //set; // default setter is: set { iQueryOffset = value; } see: https://developer.salesforce.com/blogs/developer-relations/2008/06/property-access.html
    }

    public Integer iQueryLimit {
        get {
            if (this.iQueryLimit == null) { // is the extra nesting worth the 'caching' precieved speedup - I say in most cases "no"
                this.iQueryLimit = 10; // default value
                try {
                    if (this.oPageParametersMap.get('iQueryLimit') != null) { // AJAX request
                        this.iQueryLimit = Integer.valueOf(this.oPageParametersMap.get('iquerylimit'));
                    }
                    else if (this.getProperty('iQueryLimit') != null) { // when rendered as content
                        this.iQueryLimit = Integer.valueOf(this.getProperty('iQueryLimit'));
                    }
                }
                catch (Exception e){}
            }
            return this.iQueryLimit;
        }
        set;
    }


    public String sTaxonomyName {
        get {
            return getProperty('sTaxonomyName') != null
                        ? getProperty('sTaxonomyName')
                        : ''; // default value
        }
        set;
    }

    public String sTaxonomyContentType {  // upadted from page GET/POST parameters, we support OCMS `tags` PAGE parameter too
        get {
            return 'MLIArticle';
            /* Since this is a highly customize taxonomy loader we are hard coding our `MLIArticle` content type. */
            /*if (this.sTaxonomyContentType == null) {
                String sTemp = '';
                if (this.oPageParametersMap.get('staxonomycontenttype') != null) {
                    sTemp = EncodingUtil.urlDecode(this.oPageParametersMap.get('staxonomycontenttype'), 'UTF-8');
                }
                else if (this.getProperty('sTaxonomyContentType') != null) {
                    sTemp = this.getProperty('sTaxonomyContentType');
                }
                this.sTaxonomyContentType = sTemp;
            }
            return this.sTaxonomyContentType;*/

        }
        set;
    }

    public String sTaxonomyContentLayout {
        get {
            if (this.sTaxonomyContentLayout == null) {
                String sTemp = '';
                if (this.oPageParametersMap.get('sTaxonomyContentLayout') != null) {
                    sTemp = EncodingUtil.urlDecode(this.oPageParametersMap.get('sTaxonomyContentLayout'), 'UTF-8');
                }
                else if (this.getProperty('sTaxonomyContentLayout') != null) {
                    sTemp = this.getProperty('sTaxonomyContentLayout');
                }
                this.sTaxonomyContentLayout = sTemp;
            }
            return this.sTaxonomyContentLayout;
        }
        set;

    }


    public String sTaxonomyPathFilter {
        get {
            if (this.sTaxonomyPathFilter == null) { // is the extra nesting worth the 'caching' precieved speedup - I say in most cases "no"
                String sTemp = '';
                if (this.oPageParametersMap.get('staxonomypathfilter') != null) {
                    sTemp = EncodingUtil.urlDecode(this.oPageParametersMap.get('staxonomypathfilter'), 'UTF-8');
                }
                else if (this.getProperty('sTaxonomyPathFilter') != null) {
                    sTemp = this.getProperty('sTaxonomyPathFilter');
                }
                this.sTaxonomyPathFilter = sTemp;
            }
            return this.sTaxonomyPathFilter;
        }
        set;

    }



    public String sTaxonomyTimeIntervalNode {
        get {
            // we are making the assumption that it's always Level 2, ex. `Brand Taxonomy/Time Interval`
            List<String> oTaxonomyTimeIntervalNodeAsList = new List<String>{};
            if (this.getProperty('sTaxonomyTimeIntervalNodeDefaultFilter')!= null) {
                oTaxonomyTimeIntervalNodeAsList = this.getProperty('sTaxonomyTimeIntervalNodeDefaultFilter').split('/');
            }
            return oTaxonomyTimeIntervalNodeAsList.size() >= 3
                        ? oTaxonomyTimeIntervalNodeAsList[0] + '/' + oTaxonomyTimeIntervalNodeAsList[1]
                        : ''; // default value
        }
        set;
    }


    public String sTaxonomyTimeIntervalNodeDefaultFilter {
        get {
           String sTemp = '';
            if (this.oPageParametersMap.get('sTaxonomyTimeIntervalNodeDefaultFilter') != null) {
                sTemp = EncodingUtil.urlDecode(this.oPageParametersMap.get('sTaxonomyTimeIntervalNodeDefaultFilter'), 'UTF-8');
            }
            else if (this.getProperty('sTaxonomyTimeIntervalNodeDefaultFilter') != null) {
                sTemp = this.getProperty('sTaxonomyTimeIntervalNodeDefaultFilter');
            }
            this.sTaxonomyTimeIntervalNodeDefaultFilter = sTemp;
            return this.sTaxonomyTimeIntervalNodeDefaultFilter;
        }
        set;

    }



     public ID oTaxonomyMandatoryFilterNodeTagDefID {
        get {
           ID oTemp = null;
            if (this.oPageParametersMap.get('sTaxonomyMandatoryFilterNode') != null) { // GET/POST are case insensetive
                try {
                    oTemp = Id.valueOf(EncodingUtil.urlDecode(this.oPageParametersMap.get('sTaxonomyMandatoryFilterNode'), 'UTF-8'));
                }
                catch (Exception e) {}
            }
            else  {
                try {
                    Map<String, Object> oMap = (Map<String, Object>)JSON.deserializeUntyped(this.sTaxonomyMandatoryFilterNode);
                    oTemp = (ID)oMap.get('tagDefId');
                }
                catch (Exception e) {}
            }
            return oTemp;
        }
        set;

    }



    public String sTaxonomyMandatoryFilterNode { //IMPRV: this should be named sTaxonomyMandatoryFilterNodeData??? no maybe because attribute wise it makes no sense to do  this.getProperty('sTaxonomyMandatoryFilterNode'), maybe it does for  this.getProperty('sTaxonomyMandatoryFilterNodeJSON')
        get {
           String sTemp = '';
           if (this.getProperty('sTaxonomyMandatoryFilterNode') != null) {
                sTemp = this.getProperty('sTaxonomyMandatoryFilterNode');
           }
           return sTemp.trim();
        }
        set;

    }



    public String sTaxonomyLocationNode {
        get {
            return getProperty('sTaxonomyLocationNode') != null
                        ? getProperty('sTaxonomyLocationNode')
                        : ''; // default value
        }
        set;
    }


    public String sTaxonomySortingMode {
        get {
            return getProperty('sTaxonomySortingMode') != null
                        ? getProperty('sTaxonomySortingMode')
                        : 'releaseDate'; // default value
        }
        set;
    }


    public Boolean bDisplaySearchBar {
        get {
            return getProperty('bDisplaySearchBar') != null
                        ? Boolean.valueOf(getProperty('bDisplaySearchBar'))
                        : true; // default value
        }
        set;
    }


    public String sSearchBarPlaceholderText {
        get {
            return getProperty('sSearchBarPlaceholderText') != null
                        ? getProperty('sSearchBarPlaceholderText')
                        : 'Enter Your Search Term...'; // default value
        }
        set;
    }


    public Boolean bDisplayFilterControls {
        get {
             return getProperty('bDisplayFilterControls') != null
                        ? Boolean.valueOf(getProperty('bDisplayFilterControls'))
                        : true; // default value
        }
        set;
    }


    public String sFilterToggleLabel {
        get {
            return getProperty('sFilterToggleLabel') != null
                        ? getProperty('sFilterToggleLabel')
                        : 'Filter'; // default value
        }
        set;
    }


/* // DS,2015-jul-23: not in latest July 23 HW merge, removed in their '2351
    public String sFilterToggleAccessibilityLabel {
        get {
            return getProperty('sFilterToggleAccessibilityLabel') != null
                        ? getProperty('sFilterToggleAccessibilityLabel')
                        : 'Has popup'; // default value
        }
        set;
    }
*/

    public String sFilterListSelectAllLabel {
        get {
            return getProperty('sFilterListSelectAllLabel') != null
                        ? getProperty('sFilterListSelectAllLabel')
                        : 'Select All'; // default value
        }
        set;
    }


    public String sFilterListResetLabel {
        get {
            return getProperty('sFilterListResetLabel') != null
                        ? getProperty('sFilterListResetLabel')
                        : 'Reset'; // default value
        }
        set;
    }


    public String sFilterListSubmitLabel {
        get {
            return getProperty('sFilterListSubmitLabel') != null
                        ? getProperty('sFilterListSubmitLabel')
                        : 'Submit'; // default value
        }
        set;
    }


    public String sFilterKeywordsListLabel {
        get {
            return getProperty('sFilterKeywordsListLabel') != null
                        ? getProperty('sFilterKeywordsListLabel')
                        : 'Filters'; // default value
        }
        set;
    }


    public Boolean bDisplayContentBlocksLayoutChanger {
        get {
            return getProperty('bDisplayContentBlocksLayoutChanger') != null
                        ? Boolean.valueOf(getProperty('bDisplayContentBlocksLayoutChanger'))
                        : true; // default value
        }
        set;
    }


    public String sBlockViewButtonAccessibilityLabel {
        get {
            return getProperty('sBlockViewButtonAccessibilityLabel') != null
                        ? getProperty('sBlockViewButtonAccessibilityLabel')
                        : 'Change to block view'; // default value
        }
        set;
    }


    public String sListViewButtonAccessibilityLabel {
        get {
            return getProperty('sListViewButtonAccessibilityLabel') != null
                        ? getProperty('sListViewButtonAccessibilityLabel')
                        : 'Change to list view'; // default value
        }
        set;
    }


    public Boolean bDisplayShowMoreControl {
        get {
            return getProperty('bDisplayShowMoreControl') != null
                        ? Boolean.valueOf(getProperty('bDisplayShowMoreControl'))
                        : true; // default value
        }
        set;
    }


    public String sShowMoreControlLabel {
        get {
            return getProperty('sShowMoreControlLabel') != null
                        ? getProperty('sShowMoreControlLabel')
                        : ''; // default value
        }
        set;
    }


    public String sDefaultContentBlocksLayout {
        get {
            return getProperty('sDefaultContentBlocksLayout') != null
                        ? getProperty('sDefaultContentBlocksLayout')
                        : 'blockView'; // default value
        }
        set;
    }

    public String sContentBlocksListViewStyle {
        get {
            return getProperty('sContentBlocksListViewStyle') != null
                        ? getProperty('sContentBlocksListViewStyle')
                        : 'variantA'; // default value
        }
        set;
    }


    public Boolean bDisplayFeaturedArticle {
        get {
            return getProperty('bDisplayFeaturedArticle') != null
                        ? Boolean.valueOf(getProperty('bDisplayFeaturedArticle'))
                        : false; // default value
        }
        set;
    }


    public Boolean bDisplaySocialMediaWidget { ///a.k.a. as C105, C105 - Social Feeds in HW mockups
        get {
            return getProperty('bDisplaySocialMediaWidget') != null
                        ? Boolean.valueOf(getProperty('bDisplaySocialMediaWidget'))
                        : false; // default value
        }
        set;
    }


     public String sResultItemViewMoreLabel {
        get {
            return getProperty('sResultItemViewMoreLabel') != null
                        ? getProperty('sResultItemViewMoreLabel')
                        : 'Read More '; // default value
        }
        set;
    }

    public String sAnalyticsPageInfoSiteSectionPath {
        get {
            return getProperty('sAnalyticsPageInfoSiteSectionPath') != null ? getProperty('sAnalyticsPageInfoSiteSectionPath') : ''; // default value
        }  set;
    }


    /*
     * executeRequest - AJAX end point
     * -------------------------------
     *
     * Provides front end Ajax services for the layout, example call method signature:
     *
     * `$.orchestracmsRestProxy.doAjaxServiceRequest('ocms_${className}LayoutController'
                                                      ,{
                                                         'action': 'getOppourtunityImage'
                                                         ,'otherKey': 'otherValue'
                                                      }
                                                      ,function fCallBackn(status, json) {alert(JSON.stringify(arguments))}
                                                      fCallBackFuncitonOnComplete,
                                                      true)` // last parameter is Boolean to execute as SF readOnly context
     *
     * @param this.oPageParametersMap - passed JSON object from `doAjaxServiceRequest`, needs to have key `action` and other arugments as needed
     * @return JSON.serialize(oResponseMap) - JSON seralized output based on matched `action` parameter
     */
     global String executeRequest(
             Map<String, String> oExecuteRequestParametersMap /* already same as `this.oPageParametersMap` because of default constructor since these
                                                       are passed as a POST/GET parameters BUT this is an issue for tests where the value is passed
                                                       direclty as a method call - so we must use `System.currentPageReference().getParameters().put('action', ...);`
                                                       IMPRV: make it so passed value updates our getParameters automtically */
      ) {
        // sync up our page map with passed value. TODO: determine if this is safe to overwrite our POST/GET parameters
        this.oPageParametersMap.putAll(oExecuteRequestParametersMap);


        String sAction = this.oPageParametersMap.get('action');
        Map<String,Object> oResponseMap = new Map<String,Object>{
            'bSuccess' => false
            ,'sMessage' => 'Unknown action'
        }; // default fallback response

        if(sAction == 'sSearchResultsAsJSON') {
            DateTime oStart = DateTime.now();
            DateTime oNow = DateTime.now();

            ContentReturn oReturn = new ContentReturn();

            // Get primary content matches. We don't do both because there isn't guaranteed
            // to be a lot of overlap and we want to minimize the huge list we get back
            List<cms.ServiceAPI.ContentObject> oContents;
            try {
                oContents = this.oServiceAPI
                   .getContentObjectsByTaxonomyPaths(
                    'date',                             // Ordering
                    new String[] { '/' + this.sTaxonomyTimeIntervalNodeDefaultFilter },   // Tag Paths (just one - we'll filter on secondary later)
                    this.sTaxonomyContentType,                       // Content Type
                    new String[] { this.sTaxonomyContentLayout },    // Content Layout renderings to fetch (none here)
                    400,//this.iQueryLimit,                                // Max to fetch back
                    0//this.iQueryOffset                                // Result offset
                );
            }
            catch(Exception e) { // this will handle a test run as it will catch: 'cms.CMS.TaxonomyException: None of the content types passed exist'
                // why we have to duplicate params: http://salesforce.stackexchange.com/questions/86134/does-apex-support-variable-arguments-varargs-in-java
                oResponseMap.put('bSuccess', false);
                oResponseMap.put('sMessage',
                    'An internal error has occured when calling: '
                    + '`this.oServiceAPI.getContentObjectsByTaxonomyPaths('
                    + '\'date\','
                    + new String[] { '/' + this.sTaxonomyTimeIntervalNodeDefaultFilter }
                    + ' ,' + this.sTaxonomyContentType + ', '
                    + new String[] { this.sTaxonomyContentLayout } + ', '
                    + '400, 0'
                    + ')`'
                );
                oResponseMap.put('sStackTrace',e.getStackTraceString());
                return JSON.serialize(oResponseMap);
            }

            Map<String, cms.ServiceAPI.ContentObject> oIdToContentObjects = new Map<String, cms.ServiceAPI.ContentObject>();

            for(cms.ServiceAPI.ContentObject oContent : oContents) {
                String sContent = oContent.Rendering.get(this.sTaxonomyContentLayout);

                // don't add the content if it's null
                if(sContent == null) {
                    continue;
                }

                // don't add the content if it is not matching mandatory node (if mandatory node is specified)
                // IMPRV: we can't match against `foo/bar` anymore because the JSON response contains tag path defintiion ids instead of text; can we somehow refactor this? perhaps store the tax def id in the editor?
                if (this.oTaxonomyMandatoryFilterNodeTagDefID != null && sContent.contains('\"' + this.oTaxonomyMandatoryFilterNodeTagDefID + '\"') == false) { // IMPRV: this might have to be made even more stringent, what if there is content that ends up somehow containing a href link with this pattern but the article is not actually taged with it? There was an older implementaion that used JSON parsing (git history), perhaps use that.
                    continue;
                }

                // we pass all checks and be added
                oReturn.oContent.put(oContent.contentId, sContent);

            }

            oResponseMap.put('bSuccess', true);
            oResponseMap.put('sMessage', oReturn);
        }

    return JSON.serialize(oResponseMap);

    }




    /*
    * getHTML()
    * ---------
    *
    * Using `getHTML()` is preferred over `Visualforce View` pages as it is faster and does not have 'maximum allowed length of 4,096'
    * limits, but note however that SF will not honor field level security compared to if a VF page is used - https://developer.salesforce.com/page/Enforcing_CRUD_and_FLS
    *
    */
    public override String getHTML() {
        // we don't want to bleed potential vector of attack info, so we only output our debug in prev mode

        //System.assert(false, 'this.oTaxonomyMandatoryFilterNodeTagDefID:' + this.oTaxonomyMandatoryFilterNodeTagDefID
        //    + '|this.oTaxonomyMandatoryFilterNodeTagDefID != null:' + (this.oTaxonomyMandatoryFilterNodeTagDefID != null));
        String sHTML = '<!-- >>> ocms_mli_ArticleLoader.getHTML(...): '
                    + (this.pm == 'prev' ? 'this.content_layout_instance=' + this.content_layout_instance : '').escapeHTML4()
                    + ' -->\n';  // to fix any jQuery parsing issue and it's a good design pattern, see: https://pl5.projectlocker.com/Stantive/PSTools/trac/wiki/gotcha/OCMSCachingMissingMarkup

        // special case for the class to handle detail generation of detail article based on id
        if (this.sContentLayoutName == 'MLISearchableArticleLoaderDetail') {
            sHTML += '<!-- === ocms_mli_ArticleLoader.getHTML(...): MLISearchableArticleLoaderDetail -->\n';

            String contentId ='';
            contentId = this.oPageParametersMap.get('content_id');
            //contentId = (this.oServiceAPI.getLatestContentVersions(new List<Id>{contentId})).get(contentId).Id;
            try {
                Map<Id, cms__Content__c> oLatestContentMap = this.oServiceAPI.getLatestContentVersions(new List<Id>{contentId});
                contentId = oLatestContentMap.get(contentId) != null ? oLatestContentMap.get(contentId).Id : null;
                if (contentId != null && contentId != '' ){

                    // TODO: [2015-Oct-28,DS] check if id passed if for expired content and if so find latest published, if no published content is avaible return a 404

                    String sGeneratedContent = this.oServiceAPI.getGeneratedContent(contentId, 'MLIArticleDetail');
                    if (sGeneratedContent != null) {
                        sHTML += sGeneratedContent + '\n';
                    }
                    else {
                        if (this.pm == 'prev') {
                            sHTML += 'Preview mode only output: Generated content markup empty, is the `content_id` GET/POST parameter correct?'; // or content type valid?';
                        }
                    }
                }
                else {
                    if (this.pm == 'prev') {
                        sHTML += 'Preview mode only output: No `content_id=xxxxx` GET/POST parameter provided, or the content is expired';
                    }
                }
            }
            catch (Exception e) {
                if (this.pm == 'prev') {sHTML += 'Preview mode only output: the provided id for `content_id` GET/POST is invalid, ' + e;}
            }
        }
        else if (this.sContentLayoutName == 'MLISearchableArticleLoaderList'){
            sHTML += '<!-- === ocms_mli_ArticleLoader.getHTML(...): MLISearchableArticleLoaderList -->\n';
            String sCookieOcmsCountryCode = ApexPages.currentPage().getCookies().get('ocmsCountry') != null
                                                ? ApexPages.currentPage().getCookies().get('ocmsCountry').getValue()
                                                : '*NO COOKIE SET*'; // we use `contains` later on why we have a long non-matchable default string
            // used to pre-check a geo-detected country - depends on `ocms_GeoLocation` and `countryLocator.js` being part of template.
            sHTML += '<!-- === ocms_mli_ArticleLoader.getHTML(...): this.sTaxonomyContentLayout == \'MLIArticleContentBlocks\' -->'
                // DS,2015-jul-15: we don not leverage the `#initialFeed` because we need to pass through our front end intermediate proxy. This is still ok as HW code executes a `_makeRequest` on load which then re-renders the results
                + '         <script  id="initialFeed=' + this.content_layout_instance.Id + '">'
                //+                       this.getArticleSummariesAsJSON()
                // + '[{"id": "1","title": "Looking Forward","mainContent": "Staff at Manulife have taken up walking, cycling and carpooling instead of driving alone to work.","endContent": "Lorem ipsum dolor sit amet, consectetur adipisicing elit. Alias ipsa obcaecati, eum molestiae sed quibusdam atque",                "imgPath": "/images/content/tileImage10.jpg","mainFeature" : "true","tileData" : "Canada, Feb XX, 20XX"},{"id": "2","title": "@Manulife","mainContent": "Be kind and make someone smilke <strong>#WorldKindnessDay</strong>!","endContent": "Lorem ipsum dolor sit amet, consectetur adipisicing elit. Alias, dolor. Delectus, a culpa nesciunt molestias distinctio","imgPath": "/images/content/tileImage4.jpg","tileData" : "Canada, Feb XX, 20XX"}}'

                + '                       []'
                + '         </script>';

            sHTML += '     <div data-hw-module="module/FeedsController" data-hw-options="'
                + 'selectors:{ contentLoader:\'#contentLoader-' + this.content_layout_instance.Id + '\', filters: \'#feedsFilters-' + this.content_layout_instance.Id
                + '\', contentBlocks:\'.contentBlocks-' + this.content_layout_instance.Id + '\', filterButtons: \'.filterKeywordsContainer-' + this.content_layout_instance.Id
                + ' button\', filtersContainer: \'.filterKeywordsContainer-' + this.content_layout_instance.Id + '\'}, view: \'' + (this.sDefaultContentBlocksLayout == 'blockView' ? 'block' : 'list') + '\'">'
                + '            <div class="mainFilterContainer">\n'
                //+ '                <h1>Brand</h1>\n' // client should use the 'MLI Page Title' content layout
                + '                <div class="feedsFilters" id="feedsFilters-' + this.content_layout_instance.Id + '" data-hw-module="module/Filters" data-hw-options="'
                + '                    view: \'' + (this.sDefaultContentBlocksLayout == 'blockView' ? 'block' : 'list') + '\' \n'
                + '                    ,selectors: {'
                + '                         form: \'#filterForm-' + this.content_layout_instance.Id + '\' \n'
                + '                         ,listViewButton: \'#listViewButton-' + this.content_layout_instance.Id + '\' \n'
                + '                         ,blockViewButton: \'#blockViewButton-' + this.content_layout_instance.Id + '\' \n'
                + '                         ,resetFilterArea: \'#resetFilterArea-' + this.content_layout_instance.Id + '\' \n'
                + '                         ,filterSearch: \'#filterSearch-' + this.content_layout_instance.Id + '\' \n'
                + '                    }'
                +                  '">\n'
                + '                    <div>\n'
                + '                        <div class="filters" data-hw-module="module/FilterShowHide" data-hw-options="\n'
                + '                            selectors: {button: \'.filterToggle\'}\n'
                + '                        ">\n'
                + '                            <!--*********************In-Page Search*********************-->\n'
                + '                            <div class="inPageSearch">\n'
                + '                                <div class="inPageSearchContainer">\n'
                + '                                    <div style="' + (this.bDisplaySearchBar ? '' : 'display: none' )
                +                                          '" class="searchBarContainer ' + (this.bDisplayFilterControls ? '' : ' noFilterControls')
                +                                                                         + (this.bDisplayContentBlocksLayoutChanger ? '' : ' noContentBlocksLayoutChanger')
                +                                      '">\n'
                + '                                        <label for="filterSearch-' + this.content_layout_instance.Id + '" class="accessible">' + this.sSearchBarPlaceholderText + '</label>\n'
                + '                                        <input id="filterSearch-' + this.content_layout_instance.Id + '" type="search" placeholder="' + this.sSearchBarPlaceholderText + '">\n'
                + '                                    </div>\n'
                + '                                    <input type="submit" class="button searchBarSubmit" value="Submit">\n'
                + '                                    <div class="buttonOptionsContainer">\n'
                + '                                        <button style="' + (this.bDisplayFilterControls ? '' : 'display: none' ) + '" type="button" class="filterToggle">' + this.sFilterToggleLabel + '<span class="icon"></span></button>\n'  // DS,2015-jul-23: not in latest July 23 HW merge, removed in their '2351' commit, <span class="accessible">:' + this.sFilterToggleAccessibilityLabel + '</span></button>\n'
                + '                                        <div role="radiogroup" style="' + (this.bDisplayContentBlocksLayoutChanger ? '' : 'display: none' ) + '" class="contentBlocksLayoutChanger">\n'
                + '                                            <button role="radio" type="button" class="blockViewButton accessibleLink ' + (this.sDefaultContentBlocksLayout == 'blockView' ? 'is-active' : '') + '" aria-checked="' + (this.sDefaultContentBlocksLayout == 'blockView' ? 'true' : 'false') + '" id="blockViewButton-' + this.content_layout_instance.Id + '">' + this.sBlockViewButtonAccessibilityLabel + '</button>\n'
                + '                                            <button role="radio" type="button" class="listViewButton accessibleLink ' + (this.sDefaultContentBlocksLayout == 'listView' ? 'is-active' : '') + '" aria-checked="' + (this.sDefaultContentBlocksLayout == 'listView' ? 'true' : 'false') + '" id="listViewButton-' + this.content_layout_instance.Id + '">' + this.sListViewButtonAccessibilityLabel + ' </button>\n'
                + '                                        </div>\n'
                + '                                    </div>\n'
                + '                                </div>\n'
                + '                            </div>\n'
                + '\n'
                + '                            <!--*********************Feeds Search*********************-->\n'
                + '                            <div class="contentArea">\n'
                + '                                <div class="feedsSearch">\n'
                + '                                    <div class="mainFilterArea">\n'
                + '                                        <form data-hw-attach-point="$form" data-hw-module="widget/form/Form" id="filterForm-' + this.content_layout_instance.Id + '">\n';


                // get the level 1 children of the taxonomy dsiplay those as headers
                // for each level 1 child get its children (level 2) and render them as options
                Map<String,cms.TaxonomyInfo> oStringKeyedTaxonomyInfoMap = null;
                cms.TaxonomyNodeInfo oTaxonomyRoot  = null;
                List<cms.TaxonomyNodeInfo> oTaxonomyNodeList = new List<cms.TaxonomyNodeInfo>{};
                try { // trying to handle testing where specified taxonomy 'nulls' out as it does not exist.
                    oStringKeyedTaxonomyInfoMap = this.oServiceAPI.getTaxonomyInfo(new List<String>{this.sTaxonomyName});
                    oTaxonomyRoot = (oStringKeyedTaxonomyInfoMap.get(this.sTaxonomyName)).getTaxonomy();
                    oTaxonomyNodeList = oTaxonomyRoot.getChildren();
                }
                catch (Exception e) {
                    System.debug(LoggingLevel.WARN, '`this.sTaxonomyName = \'' + this.sTaxonomyName + '\'` resulted in `null` exception (does the taxonomy exist?): ' + e);
                }

                // STI-6814 and Case 00009420 work around so that we can get the id of tag definition object for taxonomy node id
                // so that we can properly filter english default langauge articles on french pages for example by normalizing filters to common tag defintiion id regardless of language
                List<Id> oTaxNodeIdList = new List<Id>{};
                Map<Id,Id> oTaxNodeIdsToTaxDefinitionIdsMap = new Map<Id, Id>{};
                for (cms.TaxonomyNodeInfo oTaxonomyLevel1 : oTaxonomyNodeList) {
                    oTaxNodeIdList.add(oTaxonomyLevel1.getNodeId());

                    for (cms.TaxonomyNodeInfo oTaxonomyLevel2 : oTaxonomyLevel1.getChildren()) {
                        oTaxNodeIdList.add(oTaxonomyLevel2.getNodeId());
                    }
                }

                for (cms__Content__c oContentRecord :[SELECT Id, cms__Tag_Definition__r.Id FROM cms__Content__c WHERE Id in :oTaxNodeIdList]) {
                    oTaxNodeIdsToTaxDefinitionIdsMap.put(oContentRecord.Id, oContentRecord.cms__Tag_Definition__c);
                }
                //System.assert(false, oTaxNodeIdsToTaxDefinitionIdsMap);

                for (cms.TaxonomyNodeInfo oTaxonomyLevel1 : oTaxonomyNodeList) { //this chokes on null
                //for ()
                    String sCSSLevel1DisplayValue = (oTaxonomyLevel1.getName().startsWith('*') == true || this.bDisplayFilterControls == false)
                                              ? 'none' : 'block';
                    sHTML += '                                         <div style="display: ' + sCSSLevel1DisplayValue + '" class="item">                        \n'
                        + '                                                <fieldset data-hw-module="module/ShowHide" data-hw-options="\n'
                        + '                                                        selectors: {button: \'legend\'}, \n'
                        + '                                                        maxBreakpoint: \'mobile\'\n'
                        + '                                                    ">\n'
                        + '                                                    <legend '
                        + '                                                        data-mli-taxonomyPath="' + oTaxonomyLevel1.getParentPath().escapeHTML4() + '/' + oTaxonomyLevel1.getName().escapeHTML4() + '"'
                        // STI-6814
                        //+ '                                                        data-mli-taxonomyTagDefinitionId="' + oTaxNodeIdsToTaxDefinitionIdsMap.get(oTaxonomyLevel1.getNodeId()) + '"'
                        + '                                                        data-mli-taxonomyDescription="'  + (oTaxonomyLevel1.getDescription() != null ? oTaxonomyLevel1.getDescription().toUpperCase().escapeHTML4() : '') + '"'
                        + '                                                        class="legend" >' + oTaxonomyLevel1.getName().escapeHTML4()
                        + '                                                    </legend>\n'
                        + '                                                    <div class="contentArea">\n';


                    // generate level 2 options either as checkboxes or radio buttons for time interval node
                    if (this.sTaxonomyTimeIntervalNode
                        == (oTaxonomyLevel1.getParentPath() + '/' + oTaxonomyLevel1.getName())) {
                        sHTML += '                                                  <div class="filterArea TIMobile">\n'
                           + '                                                           <div data-hw-module="widget/form/RadioGroup">\n';

                        for (cms.TaxonomyNodeInfo oTaxonomyLevel2 : oTaxonomyLevel1.getChildren()) {
                            // IMPRV: we could refactor the below to have one for loop and below being common across the rendering types
                            String sCSSDisplayValue = oTaxonomyLevel2.getName().startsWith('*') ? 'none' : 'block'; // safe to reuse the variable name
                            String sAttributeIsHidden = '';
                            if (oTaxonomyLevel2.getName().startsWith('*') == true || sCSSLevel1DisplayValue == 'none') {
                                sAttributeIsHidden = ' data-is-hidden="true" ';
                            }
                            String sCheckedAttributeNode = '';
                            String sAttributeDataResetTo = ''; // will be used to output data attribute that this filter is part of first load and hence should be reset to when 'reset all' is clicked
                            if ((oTaxonomyLevel2.getParentPath() + '/' + oTaxonomyLevel2.getName()) == this.sTaxonomyTimeIntervalNodeDefaultFilter
                                  || oTaxNodeIdsToTaxDefinitionIdsMap.get(oTaxonomyLevel2.getNodeId()) == this.oTaxonomyMandatoryFilterNodeTagDefID) {
                                sCheckedAttributeNode = ' checked '; //the spaces prevents mallformed HTML and does not hurt
                                sAttributeDataResetTo = ' data-reset-to="checked" '; //the spaces prevents mallformed HTML when concatinating and does not hurt
                            }
                            String sDisabledAttributeNode = '';
                            if (oTaxNodeIdsToTaxDefinitionIdsMap.get(oTaxonomyLevel2.getNodeId()) == this.oTaxonomyMandatoryFilterNodeTagDefID) {
                                sDisabledAttributeNode = ' disabled '; //the spaces prevents mallformed HTML and does not hurt
                            }


                            sHTML += '                                                             <div style="display: ' + sCSSDisplayValue + '" class="radioContainer accessibleLink accessibleLinkTablet" data-hw-module="widget/form/RadioButton">\n'
                                + '                                                                    <label for="' + oTaxonomyLevel2.getParentPath().escapeHTML4() + '/' + oTaxonomyLevel2.getName().escapeHTML4() + '">' + oTaxonomyLevel2.getName().escapeHTML4() + '</label>\n'
                                + '                                                                    <input type="radio" '
                                +                                                                          sCheckedAttributeNode
                                +                                                                          sDisabledAttributeNode
                                +                                                                          sAttributeIsHidden
                                +                                                                          sAttributeDataResetTo
                                + '                                                                        data-mli-taxonomyDescription="'  + (oTaxonomyLevel2.getDescription() != null ? oTaxonomyLevel2.getDescription().toUpperCase().escapeHTML4() : '') + '"'
                                + '                                                                        name="' +  oTaxonomyLevel2.getParentPath().escapeHTML4() + '"'
                                //+                                                                          ' value="' + oTaxonomyLevel2.getParentPath().escapeHTML4() + '/' + oTaxonomyLevel2.getName().escapeHTML4() + '"'
                                // for STI-6814
                                +                                                                      ' value="' + oTaxonomyLevel2.getParentPath().escapeHTML4() + '/' + oTaxonomyLevel2.getName().escapeHTML4() + '"'
                                +                                                                      ' id="' + oTaxNodeIdsToTaxDefinitionIdsMap.get(oTaxonomyLevel2.getNodeId()) + '"'
                                +                                                                      ' data-mli-tagDefinitionId="' + oTaxNodeIdsToTaxDefinitionIdsMap.get(oTaxonomyLevel2.getNodeId()) + '">\n'
                      + '                                                                </div>\n';
                            sCheckedAttributeNode = '';
                        }
                        sHTML += '                                                       </div>\n'
                         + '                                                        </div>\n';
                    }
                    else {
                         sHTML += '                                                  <div class="filterArea catagoryMobile" data-hw-module="module/CheckboxController">\n'
                            + '                                                            <div class="checkboxContainer accessibleLink selectAllCheckbox" data-hw-module="module/SelectAllCheckbox">\n'
                            + '                                                                <label class="lessSelectAllMargin" for="selectAllCategory">' + this.sFilterListSelectAllLabel +'</label>\n'
                            + '                                                                <input name="selectAllCategory" type="checkbox" >\n' // id="selectAllCategory" >\n'
                            + '                                                            </div>\n';

                         for (cms.TaxonomyNodeInfo oTaxonomyLevel2 : oTaxonomyLevel1.getChildren()) {
                            // IMPRV: we could refactor the below to have one for loop and below being common across the rendering types
                            String sCSSDisplayValue = oTaxonomyLevel2.getName().startsWith('*') ? 'none' : 'block'; // safe to reuse the variable name
                            String sAttributeIsHidden = '';
                            if (oTaxonomyLevel2.getName().startsWith('*') == true || sCSSLevel1DisplayValue == 'none') {
                                sAttributeIsHidden = ' data-is-hidden="true" ';
                            }
                            String sCheckedAttributeNode = '';
                            String sAttributeDataResetTo = ''; // will be used to output data attribute that this filter is part of first load and hence should be reset to when 'reset all' is clicked
                            //System.assert(false, (oTaxonomyLevel2.getParentPath() + '/' + oTaxonomyLevel2.getName()).contains(this.sTaxonomyLocationNode));
                            if (oTaxNodeIdsToTaxDefinitionIdsMap.get(oTaxonomyLevel2.getNodeId()) == this.oTaxonomyMandatoryFilterNodeTagDefID
                                  || ( this.sTaxonomyLocationNode != ''
                                        && (oTaxonomyLevel2.getParentPath() + '/' + oTaxonomyLevel2.getName()).contains(this.sTaxonomyLocationNode) == true // checkbox the country but only if location node specified
                                        && oTaxonomyLevel2.getDescription() != null && oTaxonomyLevel2.getDescription().containsIgnoreCase(sCookieOcmsCountryCode) == true

                                     )
                                  || (this.sTaxonomyLocationNode != ''
                                       && (oTaxonomyLevel2.getParentPath() + '/' + oTaxonomyLevel2.getName()).contains(this.sTaxonomyLocationNode) == true  // 50/50 mode global check box but only if location node specified
                                       && this.sTaxonomySortingMode == 'releaseDate50LocationGlobalNode/50Local'
                                       && oTaxonomyLevel2.getDescription() != null && oTaxonomyLevel2.getDescription().containsIgnoreCase('GLOBAL') == true )
                                  ) {
                                sCheckedAttributeNode = ' checked '; //the spaces prevents mallformed HTML and does not hurt
                                sAttributeDataResetTo = ' data-reset-to="checked" '; //the spaces prevents mallformed HTML when concatinating and does not hurt

                            }
                            String sDisabledAttributeNode = '';
                            if (oTaxNodeIdsToTaxDefinitionIdsMap.get(oTaxonomyLevel2.getNodeId()) == this.oTaxonomyMandatoryFilterNodeTagDefID
                                ) {
                                sDisabledAttributeNode = ' disabled '; //the spaces prevents mallformed HTML and does not hurt
                            }


                            sHTML += '                                                     <div style="display: ' + sCSSDisplayValue + '" class="checkboxContainer accessibleLink" data-hw-module="widget/form/Checkbox">\n'
                                + '                                                            <label for="' + oTaxonomyLevel2.getParentPath().escapeHTML4() + '/' + oTaxonomyLevel2.getName().escapeHTML4() + '">' + oTaxonomyLevel2.getName().escapeHTML4() + '</label>\n'
                                + '                                                                <input  type="checkbox" '
                                +                                                                          sCheckedAttributeNode
                                +                                                                          sDisabledAttributeNode
                                +                                                                          sAttributeIsHidden
                                +                                                                          sAttributeDataResetTo
                                +                                                                      ' data-mli-taxonomyDescription="'  + (oTaxonomyLevel2.getDescription() != null ? oTaxonomyLevel2.getDescription().toUpperCase().escapeHTML4() : '') + '"'
                                +                                                                      ' data-type="' + oTaxonomyLevel2.getParentPath().escapeHTML4() + '/' + oTaxonomyLevel2.getName().escapeHTML4() + '"'
                                +                                                                      ' name="' + oTaxonomyLevel2.getParentPath().escapeHTML4() + '"'
                                //+                                                                      ' value="' + oTaxonomyLevel2.getParentPath().escapeHTML4() + '/' + oTaxonomyLevel2.getName().escapeHTML4() + '"'
                                +                                                                      ' value="' + oTaxonomyLevel2.getParentPath().escapeHTML4() + '/' + oTaxonomyLevel2.getName().escapeHTML4() + '"'
                                +                                                                      ' id="' + oTaxNodeIdsToTaxDefinitionIdsMap.get(oTaxonomyLevel2.getNodeId()) + '"'
                                +                                                                      ' data-mli-tagDefinitionId="' + oTaxNodeIdsToTaxDefinitionIdsMap.get(oTaxonomyLevel2.getNodeId()) + '">\n'
                                + '                                                        </div>\n';
                        }
                        sHTML += '                                                   </div>\n';
                    }

                    sHTML += '                                                 </div>\n'
                        + '                                                </fieldset>\n'
                        + '                                            </div>\n';
                }


                sHTML += '                                            <div class="filterActions">\n'
                + '                                                <!--\n'
                + '                                                <input class="submitButton" type="submit" value="Submit">\n'
                + '                                                -->\n'
                + '                                                <a class="resetFilterArea resetFilterArea-' + this.content_layout_instance.Id + '" href="#">' + this.sFilterListResetLabel + '</a>\n'
                + '                                                <input class="button" type="submit" value="' + this.sFilterListSubmitLabel + '">\n'
                + '                                            </div>\n'
                + '                                        </form>\n'
                + '                                    </div>   \n'
                + '                                </div>\n'
                + '                            </div>\n'
                + '                        </div>\n'
                + '\n'
                + '                    </div>\n'
                + '                </div>\n'
                + '                <!--*********************Filter Keywords Component*********************-->\n'
                + '                <div ' + (this.bDisplayFilterControls ? '' : 'display: none' ) + ' class="filterKeywords">\n'
                + '                    <div class="filterKeywordsContainer filterKeywordsContainer-' + this.content_layout_instance.Id + '">\n'
                //+ '                        <p>' + this.sFilterKeywordsListLabel + ':</p>\n'
                + '                    </div>\n'
                + '                </div>\n'
                + '\n'
                + '                <!--*********************Content Blocks*********************-->\n'
                + '                <div class="contentBlocks contentBlocks-' + this.content_layout_instance.Id + ' ' + this.sContentBlocksListViewStyle + '">\n'
                + '                    <div class="tileContainer" id="contentLoader-' + this.content_layout_instance.Id + '" data-hw-module="module/ContentLoader" data-hw-options="'
                +                           'feedsFilterSelector: \'#feedsFilters-' + this.content_layout_instance.Id + '\' \n'
                +                           ',selectors: { \n'
                + '                            initialFeed: \'#initialFeed-' + this.content_layout_instance.Id + '\' \n'
                +                           '} \n'
                +                           ',view: \'' + (this.sDefaultContentBlocksLayout == 'blockView' ? 'block' : 'list') + '\' \n'
                +                           ',dataSrc: \'ocms_mli_ArticleLoader\' \n'
                //+                           ',dataSrc: \'ocms_mli_InPageSearchService\''
                +                           ',resultsPerRequest: ' + this.iQueryLimit
                +                           ',queryParameters: { '
                + '                                               action: \'sSearchResultsAsJSON\''
                //+ '                                               action: \'getContent\''
               // +                                                 ',sTaxonomyPathFilter: \''  + this.sTaxonomyPathFilter + '\' /* this should contain a repersentation of the filter logic'
                //+                                                                                     ' (perhaps?) ex \'Brand Taxonomy/Time/2013&&(Brand Taxonomy/Locaiton/Global||Brand Taxonomy/Location/Canada)&&(Brand Taxonomy/Category/Community||Brand Taxonomy//Category/Lifestyle))\' '
                //+                                                                                     ' FIXME: once we figure out the format we can generate the initial path filter on back end based on editor settings */'
                +                                                 ',sTaxonomyTimeIntervalNodeDefaultFilter: \'' + this.sTaxonomyTimeIntervalNodeDefaultFilter + '\' \n'
                +                                                 ',sTaxonomyMandatoryFilterNode: \'' + (this.oTaxonomyMandatoryFilterNodeTagDefID != null ? (String)this.oTaxonomyMandatoryFilterNodeTagDefID : '')  + '\' \n'
                                                                                                                                                             // casting is needed see: http://salesforce.stackexchange.com/questions/110545/why-is-this-ternary-operator-erroring-out-with-system-stringexception-invalid
                +                                                 ',sTaxonomySortingMode: \'' + this.sTaxonomySortingMode + '\' \n'
                +                                                 ',sTaxonomyContentType: \'' + this.sTaxonomyContentType +  '\' /* value is hardcoded on backend*/'
                +                                                 ',sTaxonomyContentLayout: \'' + this.sTaxonomyContentLayout +  '\' \n'
                +                                                 ',iQuerylimit: \'' + this.iQueryLimit + '\' \n'
                +                                                 ',iQueryOffset: \'' + this.iQueryOffset + ' \''
                +                                                '}'

                //FIXME: do we still need to modify ContentLoader to include the below new variables or it's dynamically made available? I think it's the latter

                //+                            ',sTaxonomyTimeIntervalNodeDefaultFilter: \'' + this.sTaxonomyTimeIntervalNodeDefaultFilter + '\''
                +                            ',sTaxonomyLocationNode: \'' + this.sTaxonomyLocationNode + '\''
                //+                            ',sTaxonomyMandatoryFilterNode: \'' + this.oTaxonomyMandatoryFilterNodeTagDefID + '\''
                //+                            ',sTaxonomySortingMode: \'' + this.sTaxonomySortingMode + '\''
                +                            ',bDisplayFeaturedArticle: (\'' + this.bDisplayFeaturedArticle + '\'.toLowerCase() === \'true\')'
                +                            ',showSocialFeeds: (\'' + this.bDisplaySocialMediaWidget + '\'.toLowerCase() === \'true\')'
                +                            ',showShowMoreBtn: (\'' + this.bDisplayShowMoreControl + '\'.toLowerCase() === \'true\')'
                +                            ',sShowMoreControlLabel: \'' + this.sShowMoreControlLabel + '\''
                +                            ',resultItemViewMoreLabel: \'' + this.sResultItemViewMoreLabel + '\''
                +                            ',sAnalyticsPageInfoSiteSectionPath: \'' + this.sAnalyticsPageInfoSiteSectionPath + '\''
                +                      '"></div>\n'
                + '                </div>\n'
                + '            </div>\n'
                + '        </div>\n'
                + '        \n';

        }

        /*else if (this.sTaxonomyContentLayout == 'MLIArticleUpcomingEventsAndPresentationSummary'){

            sHTML += ''
                + '        <div data-hw-module="module/FeedsController" data-hw-options="selectors:{ contentLoader:\'#contentLoader\', filters: \'#feedsFilters\'}">\n'

                + '         <div class="genericListView">'
                + '             <h3 class="genericListViewTitle">'+this.sLoaderLabel+'</h3>'
                + '             <p>'+this.sLoaderSummary+'</p>'
                + '             <ul>'
                +                   this.getUpcomingEventsAsHTML()
                + '             </ul>'


                + '            <!--*********************Content Blocks*********************-->\n'
                + '            <div class="contentBlocks">\n'
                + '                <div class="tileContainer" id="contentLoader" data-hw-module="module/ContentLoader" data-hw-options="dataSrc: \'ocms_mli_ArticleLoader\', resultsPerRequest: ' + this.iQueryLimit + ', queryParameters: { action: \'getArticleTilesAsJSON\', sTaxonomyTimeIntervalNodeDefaultFilter: \'' + this.sTaxonomyTimeIntervalNodeDefaultFilter + '\', sTaxonomyContentType: \'' + this.sTaxonomyContentType +  '\', sTaxonomyContentLayout: \'' + this.sTaxonomyContentLayout +  '\', iQuerylimit: \'' + this.iQueryLimit + '\', iQueryOffset: \'' + this.iQueryOffset + ' \'}"></div>\n'
                + '            </div>\n'
                + '        </div>\n';

        }*/

        else {
            sHTML += '<!-- === ocms_mli_ArticleLoader.getHTML(...): Unknown -->\n';
            sHTML += 'Unknown rendering for `this.sContentLayoutName`: ' + this.sContentLayoutName + '\n';
        }

        // we don't want to bleed potential vector of attack info, so we only output our debug in prev mode
        sHTML += '<!-- <<< ocms_mli_ArticleLoader.getHTML(...): '
                   //FIXME: + (this.pm == 'prev' ? 'Limits.getCpuTime()=' + Limits.getCpuTime() + ', Limits.getAggregateQueries()=' + Limits.getAggregateQueries() + ', Limits.getHeapSize()=' + Limits.getHeapSize() : '').escapeHTML4()
                   + ' -->\n'; //  to fix any jQuery parsing issue and it's a good design pattern, see: https://pl5.projectlocker.com/Stantive/PSTools/trac/wiki/gotcha/OCMSCachingMissingMarkup

        return sHTML;
    }



    /*
    Helper Inner Methods and Classes
    ################################ */

    private class ContentReturn {
        public Map<String, String> oContent = new Map<String, String>();
    }


    private DateTime getFormatedDateTime(String sContentDateTime){

        Integer year = Integer.valueOf(sContentDateTime.substring(6,10));
        Integer month = Integer.valueOf(sContentDateTime.substring(0,2));
        Integer day = Integer.valueOf(sContentDateTime.substring(3,5));

        Integer hours = Integer.valueOf(sContentDateTime.substring(11,13));
        Integer minutes = Integer.valueOf(sContentDateTime.substring(14,16));

        DateTime dtFormattedDateTime = DateTime.newInstance(year,month,day,hours,minutes,0);

        return dtFormattedDateTime;
    }
}