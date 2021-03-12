/*
OrchestraCMS Content Layout Controller + ServiceInterface
#########################################################

@author Daniel Sokolowski
@copyright Stantive Technologies Group Inc.
*/
global with sharing class ocms_mli_Search extends cms.ContentTemplateController implements cms.ServiceInterface{

    /*
    Class variables
    ===============*/

    private final cms.CreateContentController oCCC; // convenience reference to the CreateContentController instance use when Editing content
    private final cms.GenerateContent oGC; // convenience reference to the GenerateContent instance used when rendering or ajax end point?
    private final cms.ServiceAPI oServiceAPI; // convience variable to access the ServiceAPI instance which we initialize only once
    //private final Map<String, String> oPageParametersMap; // will hold `ApexPages.currentPage().getParameters()`
                                                          // this.pp from `ContentTemplateController` appears to be unexpectedly null
    private final ocms_GSASearchService oGSASS; // will hold a reference to the GSASS



    /*
    Initialization
    ==============*/

    // Default constructor invoked through `executeRequest` (where AJAX parameters become POST/GET page parameters) or
    // in OrchestraCMS cache generation
    // NOTE: if your content is cachable you must ensure that `getHTML` has dependecny on `ApexPages` (POST/GET parameters, cookies, etc)
    public ocms_mli_Search() { /* no need the `Layout` in the name word as we are extending ContentTemplateController */
        //super(); // not needed as per Murray McDonald's post https://stantive.my.salesforce.com/0D58000001qE596
        this.oServiceAPI = this.getServiceAPI();
        //this.oPageParametersMap = ApexPages.currentPage() != null ?  ApexPages.currentPage().getParameters() : new Map<String,String>{};
                                  // during cache generation `ApexPages.currentPage()` is null so we fallback to empty map.
        this.oGSASS = new ocms_GSASearchService();

    }


    // because we are an visual force page extension we must accept the instance of that visual forces page controller
    public ocms_mli_Search(cms.CreateContentController cc) {
        super(cc);

        // looks like initialzing in the blank constructor is all that's needed - that is no the case as we were getting NULL exception for
        // not having it initlaizxed in oGC but something tells me we don't need to check for null because we only init class once
        this.oCCC = cc;
        this.oServiceAPI = this.getServiceAPI();
        //this.oPageParametersMap = ApexPages.currentPage().getParameters();
        //this.TCC = new cms.TaxonomyLoadComponentController();
        //this.TCC.init(null);
    }

    // because we are an visual force page extension we must accept the instance of that visual forces page controller
    public ocms_mli_Search(cms.GenerateContent gc) {
        super(gc);
        this.oGC = gc;
        this.oServiceAPI = this.getServiceAPI();
        //this.oPageParametersMap = ApexPages.currentPage().getParameters();
        //this.TCC = new cms.TaxonomyLoadComponentController();
        ///this.TCC.init(null);
        //System.assert(false, this.TCC.getHTML());
    }

    // Required for cms.ServiceInterface instantiation.
    global System.Type getType() {
        return ocms_mli_Search.class;
    }


    /*
    Apex class properties, a.k.a. Visual Force merge fields
    =======================================================*/

    // a XSS santized reference to page parameters
    public Map<String, String> oPageParametersMap {
        get {
             System.debug('>>> ocms_mli_Search.oPageParametersMap');
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
                    System.debug('=== ocms_mli_Search.oPageParametersMap: sKey: '+ sKey + ' | sValue: ' + sValue + ' ');
                    // check for possible XSS and delete the key if so
                    if (oXSSRegexMatcher.matcher(sValue).find() == true) {
                        oPageParametersMap.remove(sKey);
                    }
                }
             }
             System.debug('=== ocms_mli_Search.oPageParametersMap: this.oPageParametersMap: ' + this.oPageParametersMap);
             System.debug('<<< ocms_mli_Search.oPageParametersMap');
             return this.oPageParametersMap;
        }
        set;
    }

    // Below return some `ContentTempalteController.cls` methods converted to JSON useful for fronend JS development,
    // ex. `var oContent = {!contentAsJSON];` - see other available global instance variables in  `cms.ContentTemplateController`
   // NOTE: VF pages have a url GET 4096 limit which we have encountered so we should always use getHTML()
    public String contentAsJSON {
        get {return System.JSON.serializePretty(this.content);}
    }

    public String contentPropertiesAsJSON {
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
                                               Id, cms__Name__c
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
            this.sContentLayoutLabel = 'Unknown';
            if (null != content_layout_instance) {
                cms__Content_Layout__c[] cl = [
                                               SELECT
                                               Id, cms__Label__c
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

    /* Because there is no method on the `cms.Link` object to be rendered as a proper string for `cms:PageSelector` we
       end up with two support class get attributes - IMPRV: 2015-jun-17 - Daniel see your ' Improve the link handlign,
       so semnatically we are linking Link and PageSelector better' email.

       `sSearchResultsPageSelectorValue` is used in our Editor page, whereas `sSearchResultsPageSelectorValueAsLink`
       in the generator/getHTML(), ex `this.sSearchResultsPageSelectorValueAsLink.targetPage`.
    */
    public cms.Link sSearchResultsPageSelectorValueAsLink {
        get { // default getter is: get { return iQueryOffset; } see: https://developer.salesforce.com/blogs/developer-relations/2008/06/property-access.html
            return new cms.Link(this.sSearchResultsPageSelectorValue);
        }
        set; // default setter is: set { iQueryOffset = value; } see: https://developer.salesforce.com/blogs/developer-relations/2008/06/property-access.html
    }
    public String sSearchResultsPageSelectorValue {
        get { // default getter is: get { return iQueryOffset; } see: https://developer.salesforce.com/blogs/developer-relations/2008/06/property-access.html
            if (this.sSearchResultsPageSelectorValue == null) { // if we are defined don't execute populating code below again
                this.sSearchResultsPageSelectorValue = super.getProperty('sSearchResultsPageSelectorValue') != null
                                                    ? super.getProperty('sSearchResultsPageSelectorValue')
                                                    : ''; // default value - otherwise we get 'null' from `getProperty(...)` directly
            }
            return this.sSearchResultsPageSelectorValue;
        }
        set; // default setter is: set { iQueryOffset = value; } see: https://developer.salesforce.com/blogs/developer-relations/2008/06/property-access.html
    }


    public Integer iQueryOffset {
        get { // default getter is: get { return iQueryOffset; } see: https://developer.salesforce.com/blogs/developer-relations/2008/06/property-access.html
            this.iQueryOffset = 0; // it's good to provide a default value, helps in deployments and circumvents null checking
            try {
                this.iQueryOffset = Integer.valueOf(this.oPageParametersMap.get('iQueryOffset'));
            }
            catch (Exception e){} // can't use `finally` as it always executes and does not catch exceptions
            return this.iQueryOffset;
        }
        set; // default setter is: set { iQueryOffset = value; } see: https://developer.salesforce.com/blogs/developer-relations/2008/06/property-access.html
    }

    public Integer iQueryLimit {
        get {
            if (this.iQueryLimit == null) {
                this.iQueryLimit = 10; // it's good to provide a default value, helps in deployments and circumvents null checking
                try {
                    this.iQueryLimit = Integer.valueOf(this.oPageParametersMap.get('iQueryLimit'));
                }
                catch (Exception e){}
            }
            return this.iQueryLimit;
        }
        set;
    }


    public String sQueryTerm {
        get {
            if (this.sQueryTerm == null) { // if we are defined don't execute populating code below again
                this.sQueryTerm = this.oPageParametersMap.get('sQueryTerm') != null
                                  ? this.oPageParametersMap.get('sQueryTerm')
                                  : ''; // default value
            }
            return this.sQueryTerm;
        }
        set;
    }


    public String sQueryMode {
        get {
            if (this.sQueryMode == null) { // if we are defined don't execute populating code below again
                Set<String> oAllowedOptionsSet = new Set<String>{
                                                    'worldwide'
                                                    ,'local'
                                                 };
                this.sQueryMode = this.oPageParametersMap.get('sQueryMode') != null && oAllowedOptionsSet.contains(this.oPageParametersMap.get('sQueryMode'))
                                  ? this.oPageParametersMap.get('sQueryMode')
                                  : 'worldwide'; // default value
            }
            return this.sQueryMode;
        }
        set;
    }


    public String sQueryOrder {
        get {
            if (this.sQueryOrder == null) {
                this.sQueryOrder = this.oPageParametersMap.get('sQueryOrder') != null
                                   ? this.oPageParametersMap.get('sQueryOrder')
                                   : 'asc'; // default value
            }
            return this.sQueryOrder;
        }
        set;
    }



    public String sQueryTermInputPlaceholder {
        get {
            if (this.sQueryTermInputPlaceholder == null) {
                this.sQueryTermInputPlaceholder = super.getProperty('sQueryTermInputPlaceholder') != null
                                   ? super.getProperty('sQueryTermInputPlaceholder')
                                   : 'Enter search terms'; // it's good to provide a default value, helps in deployments and circumvents null checking
            }
            return this.sQueryTermInputPlaceholder;
        }
        set;
    }

    public String sIconSearchLabel {
        get {
            if (this.sIconSearchLabel == null) {
                this.sIconSearchLabel = super.getProperty('sIconSearchLabel') != null
                                   ? super.getProperty('sIconSearchLabel')
                                   : 'Site search: Click to open: Has popup'; // it's good to provide a default value, helps in deployments and circumvents null checking
            }
            return this.sIconSearchLabel;
        }
        set;
    }

    public String sButtonSubmitLabel {
        get {
            if (this.sButtonSubmitLabel == null) {
                this.sButtonSubmitLabel = super.getProperty('sButtonSubmitLabel') != null
                                   ? super.getProperty('sButtonSubmitLabel')
                                   : 'Submit search'; // it's good to provide a default value, helps in deployments and circumvents null checking
            }
            return this.sButtonSubmitLabel;
        }
        set;
    }

    public String sQueryTermInputLabel {
        get {
            if (this.sQueryTermInputLabel == null) {
                this.sQueryTermInputLabel = super.getProperty('sQueryTermInputLabel') != null
                                   ? super.getProperty('sQueryTermInputLabel')
                                   : 'Site search'; // it's good to provide a default value, helps in deployments and circumvents null checking
            }
            return this.sQueryTermInputLabel;
        }
        set;
    }

    public String sSortByLabel {
        get {
            if (this.sSortByLabel == null) {
                this.sSortByLabel = super.getProperty('sSortByLabel') != null
                                   ? super.getProperty('sSortByLabel')
                                   : 'Sort by:'; // it's good to provide a default value, helps in deployments and circumvents null checking
            }
            return this.sSortByLabel;
        }
        set;
    }

    public String sSortByAscendingLabel {
        get {
            if (this.sSortByAscendingLabel == null) {
                this.sSortByAscendingLabel = super.getProperty('sSortByAscendingLabel') != null
                                   ? super.getProperty('sSortByAscendingLabel')
                                   : 'Ascending'; // it's good to provide a default value, helps in deployments and circumvents null checking
            }
            return this.sSortByAscendingLabel;
        }
        set;
    }

    public String sSortByDescendingLabel {
        get {
            if (this.sSortByDescendingLabel == null) {
                this.sSortByDescendingLabel = super.getProperty('sSortByDescendingLabel') != null
                                   ? super.getProperty('sSortByDescendingLabel')
                                   : 'Descending'; // it's good to provide default value, helps in deployments and circumvents null checking
            }
            return this.sSortByDescendingLabel;
        }
        set;
    }

    public String sTabWorldwideLabel {
        get {
            if (this.sTabWorldwideLabel == null) {
                this.sTabWorldwideLabel = super.getProperty('sTabWorldwideLabel') != null
                                   ? super.getProperty('sTabWorldwideLabel')
                                   : 'Manulife Worldwide'; // it's good to provide default value, helps in deployments and circumvents null checking
            }
            return this.sTabWorldwideLabel;
        }
        set;
    }

    public String sTabLocalLabel {
        get {
            if (this.sTabLocalLabel == null) {
                this.sTabLocalLabel = super.getProperty('sTabLocalLabel') != null
                                   ? super.getProperty('sTabLocalLabel')
                                   : 'Other Manulife Local Site'; // it's good to provide default value, helps in deployments and circumvents null checking
            }
            return this.sTabLocalLabel; // TODO: .replaceAll('<', '&lt;').replaceAll('>', '&gt;')
                                        // was trying to prevent HTML/JS injection, but the issue is .escapeHtml4(..) would doulbe escape &
                                        // where as `.replaceAll(...) could confuse the editor as the entities appear in the Edit template
                                        // and also we are changing the 'saved' data - seems somewhat sane is to do it in getHTML(...) or VF page
                                        // OR perhaps we in the editor call `unescapeHtml4` on our attribute? - but consider if the 'saved' data conversion is ok
        }
        set;
    }

    public String sResultInformationHTML {
        get {
            if (this.sResultInformationHTML == null) {
                this.sResultInformationHTML = super.getProperty('sResultInformationHTML') != null
                                   ? super.getProperty('sResultInformationHTML')
                                   : '<span class="resultTextEmphasis">Result:</span> (<span class="resultFrom">1</span>-<span class="resultTo">10</span> OF <span class="resultCounter">0</span>) of about \'<span class="query"></span>\' from'; // it's good to provide default value, helps in deployments and circumvents null checking
            }
            return this.sResultInformationHTML;
        }
        set;
    }

    public String sResultsLabel {
        get {
            if (this.sResultsLabel == null) {
                this.sResultsLabel = super.getProperty('sResultsLabel') != null
                                   ? super.getProperty('sResultsLabel')
                                   : 'Results:'; // it's good to provide a default value, helps in deployments and circumvents null checking
            }
            return this.sResultsLabel;
        }
        set;
    }

    public String sNoResults {
        get {
            if (this.sNoResults == null) {
                this.sNoResults = super.getProperty('sNoResults') != null
                                   ? super.getProperty('sNoResults')
                                   : 'No results.'; // it's good to provide a default value, helps in deployments and circumvents null checking
            }
            return this.sNoResults;
        }
        set;
    }

    public String accTitle {
        get { return ocms_mli_Utility.noNull(getProperty('accTitle')); }
    }

    /*
     * executeRequest - AJAX end point
     * -------------------------------
     *
     * Provides front end Ajax services for the layout, call method signature:
     *
     * `$.orchestracmsRestProxy.doAjaxServiceRequest('ocms_${className}LayoutController'
                                                      ,{'action': 'getOppourtunityImage'
                                                      ,'otherKey': 'otherValue'}
                                                      ,function fCallBackFunction(status, json) {alert(JSON.stringify(arguments))}
                                                      fCallBackFuncitonOnComplete,
                                                      true)` // last parameter is Boolean to execute as SF readOnly context
     *
     * @param this.oPageParametersMap - passed JSON object from `doAjaxServiceRequest`, needs to have key `action` and other arugments as needed
     * @return sResponse - JSON seralized
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

        String sResponse = '{"bSuccess":false,"sMessage":"Action not supported."}';

        if(sAction == 'getSearchResultAsJSON') {
            /*
            Calls the Google Search Appliance service endpoint and returns the results straight through
            */
            Map<String, String> oSearchParamMap = new Map<String, String>{
                'action' => 'getCOMResults',
                'q' => this.sQueryTerm,
                'start' => String.valueOf(this.iQueryOffset),
                'num' => String.valueOf(this.iQueryLimit),
                'sOrder' => this.sQueryOrder
            };
            sResponse = this.oGSASS.executeRequest(oSearchParamMap);
        }

        return sResponse;

    }



    /*
    * getHTML()
    * ---------
    *
    * Using `getHTML()` is preferred over `Visualforce View` pages as it is faster, do note however that SF will not honor
    * field level security compared to if a VF page is used - https://developer.salesforce.com/page/Enforcing_CRUD_and_FLS
    *
    * *NOTE*: [2015-Feb-16] to self - I refuse to assamble my HTML in getHTML() - VF pages ease of devleopment trumps
    *         the speedup increases; the extra effort/difficulty/slowness/errors has to be outweighted by client requirements
    *         few hours later: System.VisualforceException: URL starting with 'https://aimiaintranet--OCMSDev--c.cs17.visual.force.com/apex/stg_tp_NewsSummaryWithSmallImageView?cl'... is longer than the maximum allowed length of 4,096
    *         SO WE MUST USE getHTML() - unbelivable !
    */
    global override String getHTML() {
        String html = '<!-- >>> ocms_mli_Search.getHTML(...) -->';  // to fix jQuery parsing gotcha, see: https://pl5.projectlocker.com/Stantive/PSTools/trac/wiki/gotcha/OCMSCachingMissingMarkup
        if ('MLIGoogleSearchHeaderInput' == this.sContentLayoutName) {
            html += '<!-- === ocms_mli_Search.getHTML(...): \'MLIGoogleSearchHeaderInput\' == this.sContentLayoutName -->';
            html += '<div role="search" class="mastheadUtilitiesItem mastheadSearch" data-hw-module="module/MastheadSearch">' +
                        '<a class="mastheadSearchTrigger accessibleLink" href="#" tabindex="0" id="mainSearchTrigger" title="' + accTitle + '">' +
                            // 2016-06-03 - [Stephen Scholtz] Added title to display; search widget looked "empty" after other utilities
                            // were moved into the masthead
                            accTitle + 
                            '<span class="icon icon-search"></span>' +
                            '<span class="accessible">' + sIconSearchLabel.escapeHtml4() + '</span>' +
                        '</a>' +
                        // action must be POST becuase our `?` parameters would get wiped - see of http://stackoverflow.com/a/9882750
                        '<form action="' + ocms_mli_Utility.getLinkHref(this.sSearchResultsPageSelectorValueAsLink.targetPage) + '" class="mastheadSearchForm" method="POST" onsubmit="if (typeof _satellite !== \'undefined\') {_satellite.track(\'GSASearchByHeaderMenuInput\');}">' +
                            '<label for="sQueryTerm" class="accessible">' + this.sQueryTermInputLabel.escapeHtml4() + '</label>' +
                            '<input id="sQueryTerm" name="sQueryTerm" placeholder="' + this.sQueryTermInputPlaceholder.escapeHtml4() + '" type="search" autocomplete="off">' +
                            '<button type="submit" class="mastheadSubmitSearch accessibleLink">' +
                                '<span class="submitInner">' +
                                    '<span class="icon icon-search"></span>' +
                                    '<span class="accessible">' + this.sButtonSubmitLabel.escapeHtml4() + '</span>' +
                                '</span>' +
                            '</button>' +
                            '<div class="menu"></div>' +
                        '</form>' +
                    '</div>';
        }
        else if ('MLIGoogleSearchResults' == this.sContentLayoutName) {
            Map<String, String> oSearchParamMap = new Map<String, String>{
                'action' => 'getCOMResults',
                'q' => this.sQueryTerm,
                'start' => String.valueOf(this.iQueryOffset),
                'num' => String.valueOf(this.iQueryLimit),
                'sOrder' => this.sQueryOrder
            };
            html += '<!-- === ocms_mli_Search.getHTML(...): \'MLIGoogleSearchResults\' == this.sContentLayoutName -->';
            // IMPRV: how should we santize our attributes? esacpeHtml4()?
            html += ''
            + '            <script>'
            + '                 MLI.analytics.searchTerm = "' + sQueryTerm.escapeUnicode() + '";' // we know that the MLI objects exists as it's in `<head>` of template
            + '             </script>'
            + '\n'
            + '            <form data-hw-module="module/GoogleSearch" id="googleSearchForm" data-hw-options="searchOnLoad: true, itemsPerPage: ' + this.iQueryLimit + '">\n'
            + '\n'
            + '                <!--Search Results Filter Component-->\n'
            // the autocomplete module is not yet styled for the result page so we disabled it, to re-enable remove the `DISABLED` data attribute affix.
            + '                <div class="searchFilter" data-hw-module-DISABLED="module/MastheadSearch" data-hw-options-DISABLED="selectors: {searchInput: \'#sSearchInput-' + this.content_layout_instance.id +'\'}">\n'
            + '                    <div data-hw-module="widget/form/Placeholder">\n'
            + '                        <input id="sSearchInput-' + this.content_layout_instance.id + '" onchange="MLI.analytics.searchTerm = this.value; if (typeof _satellite !== \'undefined\') {_satellite.track(\'GSASearchByFullFormInput\');}" class="filterSearchBar" autocomplete="off" type="search" placeholder="' + this.sQueryTermInputPlaceholder  + '" value="' + this.sQueryTerm.escapeHtml4() + '"\n'
            + '                        >\n'
            + '                        <div class="menu"></div>'
            + '                    </div>\n'
            + '                    <div class="filterSelectArea">\n'
            + '                        <p class="searchSelectText">' + this.sSortByLabel + '</p>\n'
            + '                        <div class="customSelect sortBySelect" data-hw-module="module/SelectWithMenuAndCustomScrollbar">\n'
            + '                            <label class="accessible" for="sortSelect">Select a report</label>\n'
            + '                            <select name="sortSelect" id="sortSelect">\n'
            + '                                <option selected value="">' + this.sSortByAscendingLabel + '</option>\n'
            + '                                <option value="desc">' + this.sSortByDescendingLabel + '</option>\n'
            + '                            </select>\n'
            + '                        </div>\n'
            + '                    </div>\n'
            + '                </div>\n'
            + '\n'
            + '                <!--Main Page Results Grid Area-->\n'
            + '                <div class="grid grid1 searchResultsContainer">\n'
            + '                    <div class="gridWidth">\n'
            + '                        <div class="row">\n'
            + '                            <div class="col col1">\n'
            + '\n'
            + '                                <div class="inPageTabs inPageTabs--2tabs inPageTabs--tabsHidden" id="resultTabs" data-hw-module="widget/core/Tabs" data-hw-options="index: 1, selectors: { list: \'.inPageTabsContainer > ul\', section: \'section.tabSection\', content: \'div.tabContent\'}">\n'
            + '                                    <div class="inPageTabsContainer">\n'
            + '                                        <ul>\n'
            + '                                            <li role="presentation" data-result-test="manulife.com">\n'
            + '                                                <a role="tab" aria-controls="tab1" href="#tab1">\n'
            + '                                                    <span>' + this.sTabWorldwideLabel + ' (<span class="resultCounter" style="display: inline; padding: 0px;">0</span>)</span>\n'
            + '                                                </a>\n'
            + '                                            </li>\n'
            + '                                            <li role="presentation" data-result-test="^(?:(?!manulife.com).)*$">\n'
            + '                                                <a role="tab" aria-controls="tab2" href="#tab2">\n'
            + '                                                    <span>' + this.sTabLocalLabel + '  (<span class="resultCounter" style="display: inline; padding: 0px;">0</span>)</span>\n'
            + '                                                </a>\n'
            + '                                            </li>\n'
            + '                                        </ul>\n'
            + '                                    </div>\n'
            + '                                    <section role="tabpanel" id="tab1" class="tabSection">\n'
            + '                                        <div class="tabContent">\n'
            + '                                            <!--Tab 1 Contents-->\n'
            + '                                            <div class="searchResult">\n'
            + '                                                <p class="resultInformation">' + this.sResultInformationHTML + ' ' + this.sTabWorldwideLabel + '</p>\n'
            + '                                                <p class="emptyResultInformation"><span class="resultTextEmphasis">' + this.sResultsLabel + '</span>' + this.sNoResults + '</p>'
            + '                                                <span class="loading"></span>'
            + '                                            </div>\n'
            + '                                            <div class="searchResultPagination">\n'
            + '                                                <ul>\n'
            + '                                                    <li class="direction">\n'
            + '                                                        <button class="previous icon-caret-left accessibleLink" type="button"><span class="accessible">Previous page</span></button>\n'
            + '                                                    </li>\n'
            + '                                                    <li class="direction">\n'
            + '                                                        <button class="next icon-caret-right accessibleLink" type="button"><span class="accessible">Next page</span></button>\n'
            + '                                                    </li>\n'
            + '                                                </ul>\n'
            + '                                            </div>\n'
            + '\n'
            + '                                        </div>\n'
            + '                                    </section>\n'
            + '                                    <section role="tabpanel" id="tab2" class="tabSection">\n'
            + '                                        <div class="tabContent">\n'
            + '                                            <!--Tab 2 Contents-->\n'
            + '                                            <div class="searchResult">\n'
            + '                                                <p class="resultInformation">' + this.sResultInformationHTML + ' ' + this.sTabLocalLabel + '</p>\n'
            + '                                                <p class="emptyResultInformation"><span class="resultTextEmphasis">' + this.sResultsLabel + '</span>' + this.sNoResults + '</p>'
            + '                                                <span class="loading"></span>'
            + '                                            </div>\n'
            + '                                            <div class="searchResultPagination">\n'
            + '                                                <ul>\n'
            + '                                                    <li class="direction">\n'
            + '                                                        <button class="previous icon-caret-left accessibleLink" type="button"><span class="accessible">Previous page</span></button>\n'
            + '                                                    </li>\n'
            + '                                                    <li class="direction">\n'
            + '                                                        <button class="next icon-caret-right accessibleLink" type="button"><span class="accessible">Next page</span></button>\n'
            + '                                                    </li>\n'
            + '                                                </ul>\n'
            + '                                            </div>\n'
            + '\n'
            + '                                        </div>\n'
            + '                                    </section>\n'
            + '                                </div>\n'
            + '\n'
            + '                            </div>\n'
            + '\n'
            + '                        </div>\n'
            + '                    </div>\n'
            + '                </div>\n'
            + '            </form>\n'
            + '\n'
            + '\n'
            + '        </div>\n';

        }
        else {
            html += 'Unknown rendering for `this.sContentLayoutName`: ' + this.sContentLayoutName;
        }
        return html + '<!-- <<< ocms_mli_Search.getHTML(...) -->'; // to fix jQuery parsing gotcha,, see: https://pl5.projectlocker.com/Stantive/PSTools/trac/wiki/gotcha/OCMSCachingMissingMarkup
    }

}