/**
 * @author Jialin Guo
 * @description Custom taxonomy loader to meet Manulife.com's (C6) RelatedFeeds Article Loader
 */

global virtual with sharing class ocms_mli_RelatedFeedsLoader extends cms.ContentTemplateController implements cms.ServiceInterface{

    /*
    Class variables
    ===============*/

    private final cms.CreateContentController oCCC; // convenience reference to the CreateContentController instance use when Editing content
    private final cms.GenerateContent oGC; // convenience reference to the GenerateContent instance used when rendering or ajax end point?
    private final cms.ServiceAPI oServiceAPI; // convience variable to access the ServiceAPI instance which we initialize only once
    private final Map<String, String> oPageParametersMap; // will hold `ApexPages.currentPage().getParameters()`
                                                          // this.pp from `ContentTemplateController` appears to be unexpectedly null
    //private final ocms_GSASearchService oGSASS; // will hold a reference to the GSASS



    /*
    Initialization
    ==============*/

    // called for example in `executeRequest`
    public ocms_mli_RelatedFeedsLoader() { /* no need the `Layout` in the name word as we are extending ContentTemplateController */
        //super(); // not needed as per Murray McDonald's post https://stantive.my.salesforce.com/0D58000001qE596
        this.oServiceAPI = this.getServiceAPI();
        this.oPageParametersMap = ApexPages.currentPage().getParameters();
    }

    // because we are an visual force page extension we must accept the instance of that visual forces page controller
    public ocms_mli_RelatedFeedsLoader(cms.CreateContentController cc) {
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
    public ocms_mli_RelatedFeedsLoader(cms.GenerateContent gc) {
        super(gc);
        this.oGC = gc;
        this.oServiceAPI = this.getServiceAPI();
        this.oPageParametersMap = ApexPages.currentPage().getParameters();
        //this.TCC = new cms.TaxonomyLoadComponentController();
        ///this.TCC.init(null);
        //System.assert(false, this.TCC.getHTML());
    }

    // Required for cms.ServiceInterface instantiation.
    global System.Type getType() {
        return ocms_mli_RelatedFeedsLoader.class;
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
     * @return sResponse - JSON seralized depending on matched `action` parameter
     */
     global String executeRequest(Map<String, String> oExecuteRequestParametersMap) {
      	return '';
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
    	String sHTML = '';

    		sHTML +=    '<div class="relatedFeeds" data-hw-module="module/ResponsiveCarousel" data-hw-options="maxBreakpoint: \'mobile\', selectors: {pager: \'ul.pagination\', item: \'.relatedFeedItem\', belt: \'.belt\', viewport: \'.viewport\'}">';
    		if (this.sLoaderTitle != null)
    		sHTML +=    	'<p class="sectionTitle">'+this.sLoaderTitle+'</p>';

    		sHTML +=    	'<div class="viewport">';
    		sHTML +=    		'<div class="belt">';
    		sHTML +=    			'<ul class="relatedFeedList">';

    		sHTML +=    				getRelatedFeedItemsHTML();

    		sHTML +=    			'</ul>'; //relatedFeedList
    		sHTML +=    		'</div>'; //belt
    		sHTML +=    	'</div>'; //viewport

    		sHTML +=    	'<div class="controls">';
    		sHTML +=    		'<ul class="pagination">';
    		sHTML +=    			'<!-- pager built dynamically by Carousel.js -->';
    		sHTML +=    		'</ul>'; //pagination
    		sHTML +=    	'</div>'; //controls

    		if (this.sLoaderExternalLink.targetPage != null && this.sLoaderExternalLinkLabel != null){
    		sHTML +=    	'<div class="jumper">';

            if(this.bPassTagAsFilter == true){
                String sEncodePresetFilter = EncodingUtil.urlEncode(this.sTagPaths, 'UTF-8');
                sEncodePresetFilter = sEncodePresetFilter.replaceAll('[+]', '%20');
            sHTML +=            '<a href="'+ocms_mli_Utility.getLinkHref(sLoaderExternalLink.targetPage)+'#presetFilter='+sEncodePresetFilter+'" target="'+ocms_mli_Utility.getLinkTarget(sLoaderExternalLink.target)+'">';

    		sHTML +=    			this.sLoaderExternalLinkLabel;
    		sHTML +=    		'</a>'; //pagination
            } else{
            sHTML +=            '<a href="'+ocms_mli_Utility.getLinkHref(sLoaderExternalLink.targetPage)+'" target="'+ocms_mli_Utility.getLinkTarget(sLoaderExternalLink.target)+'">';
            sHTML +=                this.sLoaderExternalLinkLabel;
            sHTML +=            '</a>'; //pagination

            }
    		sHTML +=    	'</div>'; //jumper
    		}

    		sHTML +=    '</div>'; //relatedFeeds
    	return sHTML;
	}

    public String getRelatedFeedItemsHTML() {

        Pattern oRegexPattern = Pattern.compile('(\\|\\||&&)*(.*?)(?=&&|\\|\\||$)');
        String sTaxonomyContentType = 'MLIArticle';
        String sTaxonomyContentLayout = this.sTaxonomyContentLayout;

        ocms_TaxonomyAPI taxApi = new ocms_TaxonomyAPI (oServiceAPI);
        cms.TagContentGroup oTCGDisplay = null;
        Matcher oMatcher = oRegexPattern.matcher(this.sTagPaths);

        List<String> oCurrentTagPathList = new List<String>();
        oCurrentTagPathList.add('/' + this.sTagPaths);

        List<String> contentIds = new List<String>();
        try {
            contentIds = taxApi.getContentIdsForPathList(oCurrentTagPathList, sTaxonomyContentType, '', 100, 0);
        } catch(Exception e) { // this will handle a test run as it will catch: 'cms.CMS.TaxonomyException: None of the content types passed exist'
                // why we have to duplicate params: http://salesforce.stackexchange.com/questions/86134/does-apex-support-variable-arguments-varargs-in-java
                String strErr =
                    'An internal error has occured when calling: '
                    + '`taxApi.getContentIdsForPathList('
                    + oCurrentTagPathList
                    + ' ,' + sTaxonomyContentType + ', '
                    + '\'\', '
                    + '100, 0'
                    + ')`';
                system.debug(strErr);
        }
        Map<Id, String> renderingMap = taxApi.getLatestContentRenderingsForOriginContents(contentIds, sTaxonomyContentLayout);
        List<SortableEventContentWrapper> oTempSortableEventsList = new List <SortableEventContentWrapper> ();
        List<cms__Content__c> oContentList = [select (select cms__Value__c from cms__Attributes__r WHERE cms__Simple_Name__c = 'articleDate')
                                                from cms__Content__c where Id IN :contentIds];
        for (cms__Content__c oContent : oContentList) {
            oTempSortableEventsList.add(new SortableEventContentWrapper(oContent));
        }

        oTempSortableEventsList.sort();

        // now populate our `oOrderedContentIds` based on iQueryLimit and iQueryOffset
        Integer iLoopMax = this.iQueryLimit;
        if (oTempSortableEventsList.size() < iLoopMax) {
            iLoopMax = oTempSortableEventsList.size();
        }

        /*
         * The .sort() method sorts in Ascending order, which means that the article with the highest (most recent) date will come first
         * Originally the for loop below had a decision tree that used an offset to get the last-most articles in the list which may have
         * been assuming a descending order after .sort()
         * To correct this, instead, we simply start at 0 and work our way to the max display size.
         */

        Integer iListSize = oTempSortableEventsList.size();
        Integer iLoopOffset = oTempSortableEventsList.size() - iLoopMax;

        List<cms__Content__c> oOrderedContentIds = new List <cms__Content__c>();

        /* This originally compensated for an assumed descending order (newest article last)
           it was discovered (STI-6941) that this is not the case and that the newest article comes first */
        for(Integer iCurrent = 0; iCurrent < iLoopMax; iCurrent++ ){
            oOrderedContentIds.add(oTempSortableEventsList.get(iCurrent).oContent);
        }


        String strNewsSummary = '';
        try{
			for (cms__Content__c oContent: oOrderedContentIds) {
	            strNewsSummary +=     renderingMap.get(oContent.Id);
	        }
        } catch(Exception ex){
            System.debug('***** ***** Did I hit an exception?' + ex);
        }
        return strNewsSummary;
    }

    /**
     * @description Content Attribute Block
     *              Attribute fields required for taxonomy search function and front end display
     **/

    /**
     * @description Taxonomy attributes
     **/

    global String sTagPaths {  // upadted from page GET/POST parameters
        get {
            return (this.getProperty('sTagPaths') != null ? this.getProperty('sTagPaths') : '');
        }
    }

    global String sTaxonomyContentLayout {  // upadted from page GET/POST parameters, we support OCMS `tags` PAGE parameter too
        get {
            return getProperty('sTaxonomyContentLayout');
        }
        set;
    }

    global Integer iQueryLimit {
        get {
            Integer iTemp = 3;
            try{
                iTemp =  integer.valueof(getProperty('iQueryLimit'));
            }catch (Exception e) {}

            if (iTemp > 3)
            	iTemp = 3;

            return  iTemp;
        }
        set;
    }

    /**
     * @description Loader Header attributes
     **/

    public String sLoaderTitle {
        get {
            return getProperty('sLoaderTitle');
        }
        set;
    }

    /**
     *  @description Attributes for More Articles action button
     **/

    public String sLoaderExternalLinkAsData {
        get {
            return getProperty('sLoaderExternalLink');
        }
        set;
    }

    global cms.Link sLoaderExternalLink {
        get {
            return new cms.Link(getProperty('sLoaderExternalLink'));
        }set;
    }

    public String sLoaderExternalLinkLabel {
        get {
            return getProperty('sLoaderExternalLinkLabel');
        }
        set;
    }

    public String sLoaderExternalLinkAccessible {
        get {
            return getProperty('sLoaderExternalLinkAccessible');
        }
        set;
    }

    public Boolean bPassTagAsFilter {
        get {
            return getProperty('bPassTagAsFilter') != null
                        ? Boolean.valueOf(getProperty('bPassTagAsFilter'))
                        : true; // default value
        }
        set;
    }

    /*
    Helper Inner Classes
    #################### */

    /*
     * Assists with sorting events based on the event attribute date
     */
    public with sharing class SortableEventContentWrapper implements Comparable {

        public cms__Content__c oContent;
        public Long lEventStartTime = null;
        public SortableEventContentWrapper(cms__Content__c oContent) {
            this.oContent = oContent;
            try {
                String sEventStartTime = ((cms__Attribute__c)this.oContent.getSObjects('cms__Attributes__r')[0]).cms__Value__c;
                if (sEventStartTime != null) {
                    String sYear = sEventStartTime .substring(6,10);
                    String sMonth = sEventStartTime.substring(0,2);
                    String sDay = sEventStartTime.substring(3,5);
                    String sHour = sEventStartTime.substring(11, 13);
                    String sMinute = sEventStartTime.substring(14,16);

                    this.lEventStartTime = DateTime.newInstance(Integer.valueOf(sYear), Integer.valueOf(sMonth), Integer.valueOf(sDay), Integer.valueOf(sHour), Integer.valueOf(sMinute), 0).getTime();
                }
                else {
                    this.lEventStartTime = DateTime.now().getTime(); // will put them as first times if no event date attribute found
                }
            }
            catch (Exception ex) {
                this.lEventStartTime = DateTime.now().getTime(); //if event date data is corrupt or missing use today and these events go at the top
            }
        }

        // Implement the compareTo() method
        public Integer compareTo(Object oCompareTo) {
            if (this.lEventStartTime < ((SortableEventContentWrapper)oCompareTo).lEventStartTime) {
                return 1;
            }
            return -1;
        }
    }
}