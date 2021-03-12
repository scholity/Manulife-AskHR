/**
 * @author Jialin Guo
 * @description Latest News panel for Investor Relations page
 *					Will load most recent News Articles under the Investor Relations taxonomy node
 *					Maps to C18A Latest News
 */

global with sharing class ocms_mli_LatestNews extends cms.ContentTemplateController  implements cms.ServiceInterface{

    private final cms.CreateContentController CCC; // convenience reference to the CreateContentController instance use when Editing content
    private final cms.GenerateContent GC; // convenience reference to the GenerateContent instance used when rendering or ajax end point?
    private final cms.ServiceAPI oServiceAPI; // convience variable to access the ServiceAPI instance which we initialize only once
    private final Map<String, String> oPageParametersMap; // will hold `ApexPages.currentPage().getParameters()`

    private System.JSONGenerator response;
    public String JSONResponse{get;set;}

    global ocms_mli_LatestNews() {
        this.oServiceAPI = this.getServiceAPI();
        this.oPageParametersMap = ApexPages.currentPage().getParameters();
        this.response = System.JSON.createGenerator(false);

    }

    global ocms_mli_LatestNews (cms.GenerateContent gc) {
        super(gc);
    }

    global ocms_mli_LatestNews(cms.CreateContentController cc) {
        super(cc);
    }

    // Required for cms.ServiceInterface instantiation.
    global System.Type getType() {
        return ocms_mli_LatestNews.class;
    }

    // For generated markup
    global virtual override String getHTML() { // For generated markup
    	String strHTML = '';

        //strHTML +=  '<div class="grid2">';
        //strHTML +=  '<div class="col col1">';
        strHTML +=  '<div class="landingWidget">';

        if (this.sLoaderTitle != null ){
        strHTML +=      '<div class="widgetHeader">';
        strHTML +=          '<h3 class="widgetHeading';
            if (this.sLoaderIcon == null ){
                strHTML +=              ' widgetHeading--noIcon';
            }
        strHTML +=      '">';
            if (this.sLoaderIcon != null ){
                strHTML +=              '<span class="image-icon">';
                strHTML +=                  '<img src="'+this.sLoaderIcon+'" alt="'+ ((this.sLoaderIconAlt != null) ? this.sLoaderIconAlt : '') +'">';
                strHTML +=              '</span>';
            }

        strHTML +=              this.sLoaderTitle;
        strHTML +=           '</h3>';
        strHTML +=      '</div>'; // widgetHeader
        }

        strHTML +=      '<div class="widgetContent">';

        String sLatestNewsSummary = getLatestNewsSummary();

        if (this.sTaxonomyContentLayout == 'MLIArticleListableEventsAndPresentations'){

            strHTML +=          '<div class="widgetContentBlock widgetContentBlock--twoColumn">';
            strHTML +=              '<div class="widgetContentBlock__content">';
            strHTML +=                  '<div class="widgetContentBlock__contentWrapper">';

            strHTML +=                      '<div class="widgetContentBlock__leftColumn">';
            strHTML +=                          '<div class="widgetContentBlock__columnWrapper">';

            if (this.sEventsLabel != null){
            strHTML +=                              '<h4 class="widgetContentBlock__heading">';
            strHTML +=                                  this.sEventsLabel;
            strHTML +=                              '</h4>'; //widgetContentBlock__heading
            }

            strHTML +=                              '<ul>';
            if (sLatestNewsSummary != null && sLatestNewsSummary != '') {
                strHTML +=                              sLatestNewsSummary;
            } else {
                if (this.sNoArticles != null){
                    strHTML +=                          '<li>';
                    strHTML +=                              ((this.sNoArticles != null) ? this.sNoArticles : '');
                    strHTML +=                          '</li>';
                }
            }
            strHTML +=                              '</ul>';

            strHTML +=                          '</div>'; //widgetContentBlock__columnWrapper
            strHTML +=                      '</div>'; //widgetContentBlock__leftColumn


            strHTML +=                      '<div class="widgetContentBlock__rightColumn">';
            strHTML +=                          '<div class="widgetContentBlock__columnWrapper">';

            if (this.sPresentationLabel != null){
            strHTML +=                              '<h4 class="widgetContentBlock__heading">';
            strHTML +=                                  this.sPresentationLabel;
            strHTML +=                              '</h4>'; //widgetContentBlock__heading
            }

            if (this.sPresentationDetail != null)
            strHTML +=                              this.sPresentationDetail;


            strHTML +=                          '</div>'; //widgetContentBlock__columnWrapper
            strHTML +=                      '</div>'; //widgetContentBlock__rightColumn

            strHTML +=                  '</div>'; //widgetContentBlock__contentWrapper
            strHTML +=              '</div>'; //widgetContentBlock__content
            strHTML +=          '</div>'; //widgetContentBlock widgetContentBlock--twoColumn

        } else {
            strHTML +=          '<div class="widgetContentBlock widgetContentBlock--listView">';
            strHTML +=              '<div class="widgetContentBlock__content">';
            strHTML +=              '<div class="widgetContentBlock__contentWrapper">';
            if (sLatestNewsSummary != null && sLatestNewsSummary != '') {
                strHTML +=              sLatestNewsSummary;
            } else {
                //strHTML +=              '<div class="widgetContentBlock__listViewItem">';
                strHTML +=              '<ul>';
                strHTML +=                  '<li>';
                strHTML +=                      ((this.sNoArticles != null) ? this.sNoArticles : '');
                strHTML +=                  '</li>';
                strHTML +=              '</ul>';
                //strHTML +=              '</div>'; //widgetContentBlock__listViewItem
            }
            strHTML +=              '</div>'; //widgetContentBlock__contentWrapper
            strHTML +=              '</div>'; //widgetContentBlock__content
            strHTML +=          '</div>'; //widgetContentBlock widgetContentBlock--listView
        }

        strHTML +=      '</div>'; // widgetContent

        if (this.sTaxonomyContentLayout != 'MLIArticleListableDetail'){ //The Awards detail list will not require a show more action button
            strHTML +=      '<div class="widgetFooter">';
            if (sLoaderExternalLink.targetPage != null){
                if(this.bPassTagAsFilter == true){
                    String sEncodePresetFilter = EncodingUtil.urlEncode(this.sTagPaths, 'UTF-8');
                    sEncodePresetFilter = sEncodePresetFilter.replaceAll('[+]', '%20');

                    strHTML +=      '<a href="'+ocms_mli_Utility.getLinkHref(sLoaderExternalLink.targetPage)+'#presetFilter='+sEncodePresetFilter+'" class="jumper" target="'+sLoaderExternalLinkTarget+'">';

                    strHTML +=          '<span class="title">';
                    strHTML +=              '<span class="accessible">'+this.sLoaderExternalLinkAccessible+' </span>'+this.sLoaderExternalLinkLabel+'';
                    strHTML +=          '</span>';

                    //strHTML +=          '<span class="icon icon-angle-right">';
                    strHTML +=          '</span>';

                    strHTML +=      '</a>';

                    }else{
                    strHTML +=      '<a href="'+ocms_mli_Utility.getLinkHref(sLoaderExternalLink.targetPage)+'" class="jumper" target="'+sLoaderExternalLinkTarget+'">';

                    strHTML +=          '<span class="title">';
                    strHTML +=              '<span class="accessible">'+this.sLoaderExternalLinkAccessible+' </span>'+this.sLoaderExternalLinkLabel+'';
                    strHTML +=          '</span>';

                    //strHTML +=          '<span class="icon icon-angle-right">';
                    strHTML +=          '</span>';

                    strHTML +=      '</a>';
                }
            }
            strHTML +=      '</div>'; // widgetFooter
        }

        strHTML +=  '</div>';

    	return	strHTML;
	}

    /**
     * @description Get summary renderings of all Articles found under the specified Taxonomy path
     *              Rendering is determined by the selected content layout for the article
     **/

    public String getLatestNewsSummary() {
        Pattern oRegexPattern = Pattern.compile('(\\|\\||&&)*(.*?)(?=&&|\\|\\||$)');
        String sTaxonomyContentType = 'MLIArticle';
        String sTaxonomyContentLayout = this.sTaxonomyContentLayout;
        List<String> lsTaxonomyContentLayoutList = new List<String>();

        lsTaxonomyContentLayoutList.add(this.sTaxonomyContentLayout);
        lsTaxonomyContentLayoutList.add(this.sTaxonomyContentLayout);

        ocms_TaxonomyAPI taxApi = new ocms_TaxonomyAPI (oServiceAPI);

        cms.TagContentGroup oTCGDisplay = null;

        Matcher oMatcher = oRegexPattern.matcher(this.sTagPaths);
        Map<Id, String> oPrunedContentRenderingsMap = null; // Id is of content and string is the rendered markup

        List<String> oCurrentTagPathList = new List<String>();
        oCurrentTagPathList.add('/' + this.sTagPaths);

        List<String> contentIds = new List<String>();
        try {
            contentIds = taxApi.getContentIdsForMultiplePathLevels(oCurrentTagPathList, sTaxonomyContentType, '', 100, 0, lsTaxonomyContentLayoutList);
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
        Map<Id, String> renderingMap = null;

        try {
            renderingMap = taxApi.getLatestContentRenderingsForOriginContents(contentIds, sTaxonomyContentLayout);
        } catch(Exception e) {
                System.debug('***** ***** Exception***' + e);
        }

        // now that we have pruned Ids we need to order them - for that we sadly hit the DB - the return content
        // records lack original published date which should be avaible in 7.x
        List<cms__Content__c> oOrderedContentIds = new List <cms__Content__c>();
        List<SortableEventContentWrapper> oTempSortableEventsList = new List <SortableEventContentWrapper>();

        oOrderedContentIds = new List <cms__Content__c> ();

        List<cms__Content__c> oContentList = [select (select cms__Value__c from cms__Attributes__r WHERE cms__Simple_Name__c = 'articleDate')
                                                from cms__Content__c where Id IN :contentIds];

        // Some lists only display article summaries if their dates are later than the current Date/Time
        // We need to check when those layouts are in use and remove all articles that are older than .now()

        if (this.sTaxonomyContentLayout == 'MLIArticleListableEventsAndPresentations'){
                for (cms__Content__c oContent : oContentList) {

                    // Check the release date of the Article to see if it is later than .Now()
                    Boolean bArticleDateCheck = checkFutureArticleDate(oContent);

                    if (bArticleDateCheck)
                        oTempSortableEventsList.add(new SortableEventContentWrapper(oContent));
                }
            }else {
                for (cms__Content__c oContent : oContentList) {
                    oTempSortableEventsList.add(new SortableEventContentWrapper(oContent));
                }
            }

        // sort our sortable events
        oTempSortableEventsList.sort();
        // now populate our `oOrderedContentIds` based on iQueryLimit and iQueryOffset
        Integer iLoopMax = this.iQueryLimit;
        if (oTempSortableEventsList.size() < iLoopMax) {
            iLoopMax = oTempSortableEventsList.size();
        }

        /***
         * The .sort() method only sorts via Ascending order
         * this will not sort the articles correctly as the most recent article to .now() is placed at the end of the list
         * We need to create an offset to start at the correct position within the list if the list is larger than iQueryLimit
         * If the limit and the list size are equal, the offset is equal to 0
         */

        Integer iLoopOffset = oTempSortableEventsList.size() - iLoopMax;

        if (this.sTaxonomyContentLayout == 'MLIArticleListableEventsAndPresentations'){
            //for(Integer iCurrent = 0; iCurrent < iLoopMax; iCurrent++ ){
            for(Integer iCurrent = iLoopOffset; iCurrent < iLoopMax + iLoopOffset; iCurrent++ ){
                oOrderedContentIds.add(oTempSortableEventsList.get(iCurrent).oContent);
            }
        } else {
            for(Integer iCurrent = 0; iCurrent < iLoopMax; iCurrent++ ){
                oOrderedContentIds.add(oTempSortableEventsList.get(iCurrent).oContent);
            }
        }

        String strNewsSummary = '';

        try {
            for (cms__Content__c oContent: oOrderedContentIds) {
                strNewsSummary +=     renderingMap.get(oContent.Id);
            }
        } catch(Exception ex){
            System.debug('***** ***** Did I hit an exception?' + ex);
        }

        return strNewsSummary;
    }

    /**
     * @description Check the release date of the Article to see if it is later than .Now()
     **/

    public Boolean checkFutureArticleDate(cms__Content__c oContent) {
        Boolean bDateCheck = False;

        String sArticleStartDate = ((cms__Attribute__c) oContent.getSObjects('cms__Attributes__r')[0]).cms__Value__c;

        String sYear = sArticleStartDate .substring(6,10);
        String sMonth = sArticleStartDate.substring(0,2);
        String sDay = sArticleStartDate.substring(3,5);
        String sHour = sArticleStartDate.substring(11,13);
        String sMinute = sArticleStartDate.substring(14,16);

        // We can use the Timezone's getOffset method to determine the numeric timezone offset value adjusted for Daylight Savings Time
        Timezone tz = Timezone.getTimeZone('America/New_York');
        Long lDLSOffset = tz.getOffset(DateTime.now());
        system.debug(tz.getOffset(DateTime.now()));

        // We are performing a 4 or 5 hour offset so the comparison time is consistent with the EDT/EST timezone
        // The assumption is that the server timezone will always be in Eastern Daylight/Standard Time (GMT -4/-5) entered by cthe content editor
        Long lArticleStartDate;
        if(lDLSOffset == -14400000){
            lArticleStartDate  = DateTime.newInstanceGMT(Integer.valueOf(sYear), Integer.valueOf(sMonth), Integer.valueOf(sDay), Integer.valueOf(sHour) + 4, Integer.valueOf(sMinute), 0).getTime();
        }else{
            lArticleStartDate  = DateTime.newInstanceGMT(Integer.valueOf(sYear), Integer.valueOf(sMonth), Integer.valueOf(sDay), Integer.valueOf(sHour) + 5, Integer.valueOf(sMinute), 0).getTime();
        }

        Long lNow = DateTime.now().getTime();

        System.debug('***** ***** checkFutureArticleDate : lArticleStartDate : ' + lArticleStartDate + ' lNow : ' + lNow );

        if (lArticleStartDate > lNow)
            bDateCheck = True;

        return bDateCheck;
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
            Integer iTemp = 2;
            try{
                iTemp =  integer.valueof(getProperty('iQueryLimit'));
            }catch (Exception e) {}

            return  iTemp;
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

    /**
     * @description Loader Header attributes
     **/

    public String sLoaderIcon {
        get {
            return getProperty('sLoaderIcon');
        }
        set;
    }

    // Alt text for Loader icon
    public String sLoaderIconAlt {
        get {
            return getProperty('sLoaderIconAlt');
        }
        set;
    }

    public String sLoaderTitle {
        get {
            return getProperty('sLoaderTitle');
        }
        set;
    }

    /**
     *  @description Attributes for C18D Upcoming Events & Presentations loader
     **/

    public String sEventsLabel {
        get {
            return getProperty('sEventsLabel');
        }
        set;
    }

    public String sPresentationLabel {
        get {
            return getProperty('sPresentationLabel');
        }
        set;
    }

    public String sPresentationDetail {
        get {
            return getProperty('sPresentationDetail');
        }
        set;
    }

    /**
     *  @description Attributes for Show More action button
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

    global String sLoaderExternalLinkTarget {
        get {
            String sProcessedExternalLinkTarget = new cms.Link(getProperty('sLoaderExternalLink')).target;
            if (String.isBlank(sProcessedExternalLinkTarget)) {
                sProcessedExternalLinkTarget = '_self'; // W3C valid
            }
            return sProcessedExternalLinkTarget;
        }
        set;
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

    public String sNoArticles {
        get {
            return getProperty('sNoArticles');
        }
        set;
    }


    global String executeRequest(Map<String, String> oPageParametersMap /* already same as `this.oPageParametersMap` because of constructor */) {
        String sResponse = '{"bSuccess":false,"sMessage":"This message changed"}';
	    return sResponse;
	}

    /*
    Helper Inner Classes
    #################### */

    /*
     * Assists with sorting events based on the event attribute date
     */
    public without sharing class SortableEventContentWrapper implements Comparable {

        public cms__Content__c oContent;
        public Long lEventStartTime = null;

        public SortableEventContentWrapper(cms__Content__c oContent) {
            this.oContent = oContent;

            try {
                String sEventStartTime = ((cms__Attribute__c)this.oContent.getSObjects('cms__Attributes__r')[0]).cms__Value__c;
                //System.assert(false, ((cms__Attribute__c) this.oContent.getSObjects('cms__Attributes__r')[0]).cms__Value__c);
                //System.debug('***** ***** DATE TIME RAW : ' + ((cms__Attribute__c)this.oContent.getSObjects('cms__Attributes__r')[0]).cms__Value__c);
                if (sEventStartTime != null) {
                    String sYear = sEventStartTime .substring(6,10);
                    String sMonth = sEventStartTime.substring(0,2);
                    String sDay = sEventStartTime.substring(3,5);
                    String sHour = sEventStartTime.substring(11,13);
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

    public String getFormattedDateMethod() {

        String sFormattedDateMethod = '';

        sFormattedDateMethod +=     '<script type="text/javascript" ';
        sFormattedDateMethod +=     '$( document ).ajaxStop(function() {';
        sFormattedDateMethod +=         '$(\'.articleDate\').each(function (index){';
        sFormattedDateMethod +=             'if ($(this).is(\':empty\')){';
        sFormattedDateMethod +=                 'var t = $(this).data(\'date\');';
        sFormattedDateMethod +=                 'var date = moment(t).locale(CMS.lang);';

        sFormattedDateMethod +=                 '$(this).append(date.format("LL"));';

        sFormattedDateMethod +=                 'if ( $(this).parent().next().hasClass(\'articleTime\')){';
        sFormattedDateMethod +=                     'if ( $(this).parent().next().is(\':empty\')){';
        sFormattedDateMethod +=                         '$(this).parent().next().text(date.format("LT"));';
        sFormattedDateMethod +=                     '}';
        sFormattedDateMethod +=                 '}';
        sFormattedDateMethod +=             '}';
        sFormattedDateMethod +=         '});';
        sFormattedDateMethod +=     '});';
        sFormattedDateMethod +=     '</script>';

        return sFormattedDateMethod;
    }
}