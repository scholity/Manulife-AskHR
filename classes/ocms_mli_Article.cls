/**
 * Definition and markup generation for Manulife.com Article content.
 *
 * @author    Jialin Guo
 * @date    2015-Mar-15
 *
 *    2015-Mar-20 Jialin Guo
 *        Included logic for 'author' field to prepopulate field with content creator's name on content creation.
 *
 *    2015-Mar-15    Jialin Guo
 *        Class created
 *
 */
global virtual with sharing class ocms_mli_Article extends cms.ContentTemplateController {

    global ocms_mli_Article() {}

    global ocms_mli_Article (cms.GenerateContent gc) {
        super(gc);
    }

    global ocms_mli_Article(cms.CreateContentController cc) {
        super(cc);
    }

    /**
     * @description Content Attribute Block
     *              Attribute fields required for taxonomy search function and front end display
     **/


    /**
     * @description Article Header attributes
     **/



    public String title {
        get {
            if (getProperty('title') != null) {
                return getProperty('title');
            }else{
                return '';
            }

        } set;

    }

    // there is an assumption this is in EST timezone entered by the editor - we don't do any conversions, it is their responsbility
    public String articleDate {

        get {
            if (getProperty('articleDate') != null) {
                return getProperty('articleDate');
            }else{
                DateTime dtTemp = DateTime.now();
                return dtTemp.format('MM/dd/yyyy hh:mm');
            }
        } set;
    }

    public String articleFlagIcon {
        get {
            return getProperty('articleFlagIcon');
        }
        set;
    }

    public String articleLocation {

        get {
            if (getProperty('articleLocation') != null) {
                return getProperty('articleLocation');
            }else{
                return '';
            }

        } set;
    }

    public String sNewsArticleLeaderText {
        get {
            return getProperty('sNewsArticleLeaderText');
        } set;
    }

    /**
     * @description     Check the value of the 'author' property. If the value is null, populate the field with the current User's name.
     *                     The 'author' property should only be empty during content creation, or if the 'author' field value is deleted.
     *
     * @author    Jialin Guo
     * @date    2015-Mar-20
     * @return    String - Author's name
     */
    public String author {
        get {
            if (getProperty('author') != null) {
                return getProperty('author');
            }else{
                if (getProperty('author') != ''){
                    return getProperty('author');
                }else{
                    return '';
                }
            }
        } set;
    }

    public String articleSummaryImage {
        get {
            return getProperty('articleSummaryImage');
        }
        set;
    }

    public String summaryImageAlt {
        get { return ocms_mli_Utility.noNull(getProperty('summaryImageAlt')); }
    }

    public String articleDetailImage {
        get {
            return getProperty('articleDetailImage');
        }
        set;
    }

    public String detailImageAlt {
        get { return ocms_mli_Utility.noNull(getProperty('detailImageAlt')); }
    }

    public String sVideoURL {
        get {
            return getProperty('sVideoURL') != null
                        ? getProperty('sVideoURL')
                        : ''; // default value
        }
    }

    public String articleType {
        get {
            return getProperty('articleType');
        }
        set;
    }

    public String articleFeatureItem {
         get {
            return getProperty('articleFeatureItem') != null
                        ? getProperty('articleFeatureItem')
                        : 'false'; // default value
        }
        set;
    }

    public String articleSummaryHeader {
        get {
            return getProperty('articleSummaryHeader');
        } set;
    }

    public String articleSummary {
        get {
            return getProperty('articleSummary');
        } set;
    }

    public String articleDetail {
        get {
            return getProperty('articleDetail');
        } set;
    }

    /**
     * @description attribute articleDetail - required
     */
    public String detailPageAsData {
        get {
            return getProperty('detailPage');
        }
        set;
    }

    global String detailPage {
        get {
            String sProcessedDetailPage = new cms.Link(getProperty('detailPage'), null, null, 'content_id=' + this.versionOriginId).targetPage;
            return ocms_mli_Utility.getLinkHref(sProcessedDetailPage);
        }
        set;
    }

    global String detailPageTarget {
        get {
            String sProcessedDetailPageTarget = new cms.Link(getProperty('detailPage'), null, null, 'content_id=' + this.versionOriginId).target;
            if (String.isBlank(sProcessedDetailPageTarget)) {
                sProcessedDetailPageTarget = '_self'; // empty value is not valid as per W3C, the correct value is `_self`
            }
            return sProcessedDetailPageTarget;
        }
        set;
    }

    /**
     * @description call to action button attributes
     */

    public String actionLabel {
        get {
            return getProperty('actionLabel');
        }set;
    }

    public String accessibleActionLabel {
        get {
            return getProperty('accessibleActionLabel');
        }set;
    }

    public String actionPageAsData {
        get {
            return getProperty('actionPage');
        }
        set;
    }

    global cms.Link actionPage {
        get {
            return new cms.Link(getProperty('actionPage'));
        }set;
    }

    global String actionPageTarget {
        get {
            String sProcessedActionPageTarget = new cms.Link(getProperty('actionPage'), null, null, 'content_id=' + this.versionOriginId).target;
            if (String.isBlank(sProcessedActionPageTarget)) {
                sProcessedActionPageTarget = '_self';
            }
            return sProcessedActionPageTarget;
        }
        set;
    }

    public String versionOriginId {
        get {
            versionOriginId = content.Id;
            if (content.cms__Version_Origin__c != null) {
                versionOriginId = content.cms__Version_Origin__c;
            }
            return versionOriginId;
        } set;
    }

    public List<String> tagPaths {
        get {
            if(tagPaths == null) {
                tagPaths = getPropertyList('tagPathId');
                //tagPaths = null;

                // Fall back to sAPI for content created before renderTagPath was configured
                if(tagPaths == null || tagPaths.size() == 0) {
                    tagPaths = new List<String>();

                    Map<String, List<List<cms__Tag__c>>> tags = getServiceAPI().getActiveTagsForContent(new Set<String> { this.content.Id });
                    for(List<cms__Tag__c> tagList : tags.get(this.content.Id)) {
                        List<String> tagPathParts = new List<String>();


                        //for(cms__Tag__c tag : tagList) {
                            //tagPathParts.add(tag.cms__Tag_Definition__r.cms__Name__c);
                            // this cms__Name__c is whatever langauge it's first created so let's hope it's in English, Mike W. can explain better
                            // STI-0000006814,TODO: render default langauge always
                            // tagPathParts.add(tag.cms__Name__c);
                            // Mike: says to use Tag_Definition__c (so just use ID which is same regardless of Language)
                            tagPathParts.add(tagList.get(tagList.size()-1).cms__Tag_Definition__r.Id);
                        //}

                        String path = String.join(tagPathParts, '/');
                        tagPaths.add(path);
                    }

                    //tagPaths.add('sapi');
                }
            }

            return tagPaths;
        } set;
    }

    public String renderLang {
        get{
            String rLang = getServiceAPI().getRenderLanguage();
            if(Test.isRunningTest()) {
                rLang = 'en_US';
            }
            return rLang;
        } set;
    }

    private String articleAnalyticsJS {
        get {
            String html = '';

            html += '<script>\n ';
            html += '\n if(window.MLI === undefined) window.MLI = {};';
            html += '\n if(window.MLI.analytics === undefined) window.MLI.analytics = {};';
            html += '\n if(window.MLI.analytics.page === undefined) window.MLI.analytics.page = {};';
            //html += '\n var analytics = window.MLI.analytics.page;';

            html += '\n window.MLI.analytics.page.pageInfo = {};'
                + '\n window.aAnalyticsPageInfoSiteSectionPath = window.location.search.match(\'sAnalyticsPageInfoSiteSectionPath=([^&$]*)\') ? (decodeURIComponent(window.location.search.match(\'sAnalyticsPageInfoSiteSectionPath=([^&$]*)\')[1])).split(\'/\') : [];' // we could have also used a function closure to prevent scope pollution
                + '\n for (var i =0; i < aAnalyticsPageInfoSiteSectionPath.length; i++) {'
                + '\n   window.MLI.analytics.page.pageInfo[\'siteSection\' + (i > 0 ? i : \'\')] = aAnalyticsPageInfoSiteSectionPath[i];'
                + '\n }';
            html += '\n delete window.aAnalyticsPageInfoSiteSectionPath;'; // we could have also used a function closure to prevent scope pollution

            if(this.articleDate != null){
                html += '\n window.MLI.analytics.page.articleDate = \'' + this.articleDate + '\';';
            } else {
                html += '\n window.MLI.analytics.page.articleDate = null;';
            }

            if(this.content.Id != null){
                html += '\n window.MLI.analytics.page.articleID = \'' + this.content.Id + '\';';
            } else {
                html += '\n window.MLI.analytics.page.articleID = null;';
            }

            if(this.title != null){
                html += '\n window.MLI.analytics.page.pageName = \'' + this.title + '\';';
                html += '\n window.MLI.analytics.page.articleTitle = \'' + this.title + '\';';
            } else {
                html += '\n window.MLI.analytics.page.articleTitle = null;';
            }

            // tells Adobe analytic that we have loaded the page (updated the analatics object) and to trigger a tracking
            //html += '\n _satellite.track(\'pageLoad\');';

            html += '\n// Debuging reference for inlined scritps or those loaded through `eval`';
            html += '\n//# sourceURL=ocms_mli_Article.cls#inlinedScript1';

            html += '</script>';

            return html;
        }
    }

    public String sOverlayTitle {
        get {
            return getProperty('sOverlayTitle');
        }set;
    }

    public String sOverlayCloseAccessible {
        get {
            return getProperty('sOverlayCloseAccessible');
        }set;
    }

    private String sHTMLOverlay {
        get {

            String html = '';

            html += '<script type="text/template" id="overlay' + this.content.Id + '">' +
                        '<!-- Overlay Markup -->' +
                        '<div class="dialog" role="dialog" aria-labelledby="' + this.content.Id + 'Title">' +
                            '<button type="button" class="closeOverlay accessibleLink">' + sOverlayCloseAccessible + '</button>' +
                            '<div class="dialogHeader">' +
                                '<h2 class="dialogHeading" id="' + this.content.Id + 'Title">' + sOverlayTitle + '</h2>' +
                            '</div>' +
                            '<div class="dialogContent">' +
                                '<div class="videoContainer">' +
                                    '<iframe width="560" height="315" src="' + sVideoURL + '" frameborder="0" allowfullscreen></iframe>' +
                                '</div>' +
                            '</div>' +
                        '</div>' +
                    '</script>';

            return html;

        }
    }


    global string getArticleDetailHTML() {
        return 'FIXME: this method was removed about 5 weeks ago and renamed to getBlogArticleDetailHTML()';
    }


    // For generated markup
    global virtual override String getHTML() { // For generated markup
        String sHTML = '<!-- >>> ocms_mli_Article.getHTML(): '
                    + (this.pm == 'prev' ? 'this.content_layout_instance=' + this.content_layout_instance : '').escapeHTML4()
                    + ' -->\n';  // to fix any jQuery parsing issue and it's a good design pattern, see: https://pl5.projectlocker.com/Stantive/PSTools/trac/wiki/gotcha/OCMSCachingMissingMarkup
        sHTML += getArticleTitle();
        
        if (this.articleType == 'News') {
            sHTML += getNewsArticleDetailHTML();
            sHTML += articleAnalyticsJS;
        }else {
            sHTML += getBlogArticleDetailHTML();
            sHTML += articleAnalyticsJS;
        }

        sHTML += '<!-- <<< ocms_mli_Article.getHTML() -->\n'; //  to fix any jQuery parsing issue and it's a good design pattern, see: https://pl5.projectlocker.com/Stantive/PSTools/trac/wiki/gotcha/OCMSCachingMissingMarkup


        return sHTML;
    }


    /** IMPRV: rename this to JSONLIKE - which because it's not reall JSON
     * @description     Generate JSON object representing the summary tile view of each Article used in the Searchable Article Loader
     *
     * @author    Daniel Sokolowski
     * @date    2015-Jul-15
     * @return    String - JSON object representing article summary, see source code for details
     */
    global String getArticleSummaryJSON() {
        String sLocation = '';
        //String sFormattedDate = getFormattedDate(this.articleDate, this.renderLang);

        if (this.articleLocation != null && this.articleLocation != '')
            sLocation = this.articleLocation + ' / ';

        return '<caching-attribute-trap-parse-me-out />' + JSON.serialize(
            new Map<String,Object>{
              'id' => (String) this.content.id
              ,'tagPaths' => this.tagPaths
              ,'title' => this.title
              ,'mainContent' => this.articleSummaryHeader
              ,'endContent' => this.articleSummary
              ,'imgPath' =>  (this.articleSummaryImage  != null ? this.articleSummaryImage : '')
              ,'imgAltText' =>  this.summaryImageAlt
              ,'mainFeature'  => this.articleFeatureItem
              ,'tileData'  => (sLocation + this.getFormattedDate(this.articleDate, this.renderLang))

              ,'linkPath'  => this.detailPage
              ,'linkTarget'  => this.detailPageTarget //.targetPage + '?content_id=' + this.versionOriginId  //IMPRV: this should understand if there are existing ? parmeters like in preview
              ,'isVideo' => (this.sVideoURL != '') ? true : false // seems to be needed by template in `hw-mli.js` line `define("app/modules/templates/feedTile.html"`
              ,'videoLink'  => this.sVideoURL  // no need for IF - front does `if(data[i].videoLink){ ...`
              ,'videoTitle' => this.title//IMPRV: does this need seperate attribute?
              ,'videoDescription'  => this.articleSummaryHeader  //IMPRV: does this need seperate attribute?

              // DS,2015-jul-15: below are currently extra attributes that HW mockup does not use
              //,'articleDate'  => sFormattedDate
              ,'articleDate'  => this.articleDate

              ,'articleFlagIcon'  => this.articleFlagIcon
            }
        );
    }



    /**
     * @description     Generate the markup for the summary tile view of each Article on the requested landing page
     *
     * @author    Jialin Guo
     * @date    2015-Apr-08
     * @return    String - Article Summary Markup
     */

    global String getArticleSummaryHTML() {
        String sArticleSummary = '';
        sArticleSummary = '<!-- >>> ocms_mli_Article.getHTML(): '
                    + (this.pm == 'prev' ? 'this.content_layout_instance=' + this.content_layout_instance : '').escapeHTML4()
                    + ' -->\n';  // to fix any jQuery parsing issue and it's a good design pattern, see: https://pl5.projectlocker.com/Stantive/PSTools/trac/wiki/gotcha/OCMSCachingMissingMarkup
        sArticleSummary += '<meta property="og:title" content="' + this.title.escapeHTML4() + '"/>';

            //sArticleSummary +=     '<div class="tile">';
            sArticleSummary +=         '<a href="'+ this.detailPage + '" class="tileLink" tabindex="-1" aria-hidden="true" target="'+detailPageTarget+'">';
            sArticleSummary +=         '</a>';
            sArticleSummary +=         '<div class="tileContent">';

            // If there is no image, do not generate the image markup
            if (this.articleSummaryImage != null){
                sArticleSummary +=         '<div class="imageContainer">';
                sArticleSummary +=             '<img src="' + this.articleSummaryImage + '" alt="' + this.summaryImageAlt + '"/>';
                sArticleSummary +=         '</div>';
            }


                sArticleSummary +=             '<div class="tileTextContent">';
                sArticleSummary +=                 '<h2 class="tileHeader">';
            if (this.title != null){
                sArticleSummary +=                     '<a href="'+ this.detailPage +'" target="'+detailPageTarget+'">';
                sArticleSummary +=                         this.title;
                sArticleSummary +=                     '</a>';
            }
                sArticleSummary +=                 '</h2>';

                sArticleSummary +=                 '<p class="tileMainContent">';
            if (this.articleSummaryHeader != null){
                sArticleSummary +=                     this.articleSummaryHeader;
            }
                sArticleSummary +=                 '</p>';

                sArticleSummary +=                 '<p class="tileEndContent">';
            if (this.articleSummary != null){
                sArticleSummary +=                     this.articleSummary;
            }
                sArticleSummary +=                 '</p>';

            sArticleSummary +=                 '<p class="tileData">';
            sArticleSummary +=                     this.articleSummary;
            sArticleSummary +=                     this.versionOriginId;
            sArticleSummary +=                 '</p>';
            sArticleSummary +=             '</div>';
            sArticleSummary +=         '</div>';
            //sArticleSummary +=     '</div>';


        sArticleSummary += '<!-- <<< ocms_mli_Article.getArticleSummaryHTML() -->\n'; //  to fix any jQuery parsing issue and it's a good design pattern, see: https://pl5.projectlocker.com/Stantive/PSTools/trac/wiki/gotcha/OCMSCachingMissingMarkup
        return sArticleSummary;
    }

    /**
     * @description     Generate the markup for the Latest News article tile of each Article on the Latest News widget
     *                  PLEASE NOTE: THIS METHOD IS NOW BEING USED TO GENERATE THE MARKUP FOR THE GENERIC LISTABLE ARTICLE SUMMARY CONTENT LAYOUT
     *
     * @author    Jialin Guo
     * @date    2015-May-27
     * @return    String - Listable Article Summary markup
     */


    global String getArticleLatestNewsSummaryHTML() {
        String sFormattedDate = getFormattedDate(this.articleDate, this.renderLang);
        String sArticleListSummary = '';
        sArticleListSummary = '<!-- >>> ocms_mli_Article.getArticleLatestNewsSummaryHTML(): '
                    + (this.pm == 'prev' ? 'this.content_layout_instance=' + this.content_layout_instance : '').escapeHTML4()
                    + ' -->\n';  // to fix any jQuery parsing issue and it's a good design pattern, see: https://pl5.projectlocker.com/Stantive/PSTools/trac/wiki/gotcha/OCMSCachingMissingMarkup
        sArticleListSummary +=          '<div class="widgetContentBlock__listViewItem">';

            // If an article has a flag associated with it, display the appropriate classname
            // All flag icons are stored in a sprite sheet and generated based on class ex: "flag-ca"
            if (this.articleFlagIcon != null && this.articleFlagIcon != 'none'){
                sArticleListSummary +=            '<p class="widgetContentBlock__information widgetContentBlock__information--withFlag">';
                sArticleListSummary +=                '<span class="flag-sprite '+this.articleFlagIcon+'"></span>';
            }else{
                sArticleListSummary +=            '<p class="widgetContentBlock__information">';
            }

            // Leader text is used in the case a City Name is required beside the Date
            // Ex: "Hong Kong / February 12, 2015"
            if (this.articleLocation != null && this.articleLocation != '')
                sArticleListSummary +=                    this.articleLocation + ' / ';

            if (this.articleDate != null && this.articleDate != '')
                sArticleListSummary +=                    '<span class="articleDate" data-date="'+this.articleDate+'">'+sFormattedDate +'</span>';

            sArticleListSummary +=                '</p>'; //widgetContentBlock__information

            sArticleListSummary +=                '<h3 class="widgetContentBlock__heading">';
            if (this.title != null  && this.title != '')
                sArticleListSummary +=                    this.title;
            sArticleListSummary +=                '</h3>';

            sArticleListSummary +=                '<p>';
            if (this.articleSummary != null  && this.articleSummary != '')
                sArticleListSummary +=                this.articleSummary;
            sArticleListSummary +=                '</p>';

            sArticleListSummary +=        '</div>';

            sArticleListSummary += getFormattedDateMethod();
        sArticleListSummary += '<!-- <<< ocms_mli_Article.getArticleLatestNewsSummaryHTML() -->\n'; //  to fix any jQuery parsing issue and it's a good design pattern, see: https://pl5.projectlocker.com/Stantive/PSTools/trac/wiki/gotcha/OCMSCachingMissingMarkup

        return sArticleListSummary;
    }

    /**
     * @description     Generate the markup for the Awards article tile of each Article on the Latest News widget
     *                  PLEASE NOTE: THIS METHOD IS NOW BEING USED TO GENERATE THE MARKUP FOR THE GENERIC LISTABLE ARTICLE DETAIL CONTENT LAYOUT
     *
     * @author    Jialin Guo
     * @date    2015-Jul-23
     * @return    String - Listable Article Detail markup
     */

    global String getArticleAwardDetailHTML() {
        String sFormattedDate = getFormattedDate(this.articleDate, this.renderLang);
        String sArticleListDetail = '';
        sArticleListDetail = '<!-- >>> ocms_mli_Article.getArticleLatestNewsSummaryHTML(): '
                    + (this.pm == 'prev' ? 'this.content_layout_instance=' + this.content_layout_instance : '').escapeHTML4()
                    + ' -->\n';  // to fix any jQuery parsing issue and it's a good design pattern, see: https://pl5.projectlocker.com/Stantive/PSTools/trac/wiki/gotcha/OCMSCachingMissingMarkup
        sArticleListDetail +=          '<div class="widgetContentBlock__listViewItem">';


            sArticleListDetail +=        '<div class="widgetContentBlock__listViewItem">';

            // If an article has a flag associated with it, display the appropriate classname
            // All flag icons are stored in a sprite sheet and generated based on class ex: "flag-ca"
            if (this.articleFlagIcon != null && this.articleFlagIcon != 'none'){
                sArticleListDetail +=            '<p class="widgetContentBlock__information widgetContentBlock__information--withFlag">';
                sArticleListDetail +=                '<span class="flag-sprite '+this.articleFlagIcon+'"></span>';
            }else{
                sArticleListDetail +=            '<p class="widgetContentBlock__information">';
            }

            // Leader text is used in the case a City Name is required beside the Date
            // Ex: "Hong Kong / February 12, 2015"
            if (this.articleLocation != null && this.articleLocation != '')
                sArticleListDetail +=                    this.articleLocation + ' / ';

            if (this.articleDate != null)
                sArticleListDetail +=                    '<span class="articleDate" data-date="'+this.articleDate+'">'+sFormattedDate+'</span>';

            sArticleListDetail +=                '</p>'; //widgetContentBlock__information

            sArticleListDetail +=                '<h3 class="widgetContentBlock__heading">';
            if (this.title != null){
                sArticleListDetail +=                this.title;
            }
            sArticleListDetail +=                '</h3>'; //widgetContentBlock__heading

            sArticleListDetail +=                '<p>';
            if (this.articleDetail != null){
                sArticleListDetail +=                this.articleDetail;
            }
            sArticleListDetail +=                '</p>';

            sArticleListDetail +=        '</div>'; //widgetContentBlock__listViewItem

            sArticleListDetail += getFormattedDateMethod();
        sArticleListDetail += '<!-- <<< ocms_mli_Article.getArticleLatestNewsSummaryHTML() -->\n'; //  to fix any jQuery parsing issue and it's a good design pattern, see: https://pl5.projectlocker.com/Stantive/PSTools/trac/wiki/gotcha/OCMSCachingMissingMarkup
        return sArticleListDetail;
    }

    global String getArticleEventsSummaryHTML() {
        String sFormattedDate = getFormattedDate(this.articleDate, this.renderLang);

        String sEventsArticleSummary = '';
        sEventsArticleSummary = '<!-- >>> ocms_mli_Article.getArticleEventsSummaryHTML(): '
                    + (this.pm == 'prev' ? 'this.content_layout_instance=' + this.content_layout_instance : '').escapeHTML4()
                    + ' -->\n';  // to fix any jQuery parsing issue and it's a good design pattern, see: https://pl5.projectlocker.com/Stantive/PSTools/trac/wiki/gotcha/OCMSCachingMissingMarkup

            sEventsArticleSummary +=    '<li>';


            if (this.articleDate != null || this.articleDate != ''){
            sEventsArticleSummary +=        '<p class="widgetContentBlock__information">';
            sEventsArticleSummary +=            '<span class="articleDate" data-date="'+this.articleDate+'">'+sFormattedDate+'</span>';
            sEventsArticleSummary +=        '</p>';
            }

            sEventsArticleSummary +=        '<p>';
            if (this.title != null || this.title != '')
            sEventsArticleSummary +=            this.title;
            sEventsArticleSummary +=        '</p>';

            sEventsArticleSummary +=    '</li>';

            sEventsArticleSummary += getFormattedDateMethod();
        sEventsArticleSummary += '<!-- <<< ocms_mli_Article.getArticleEventsSummaryHTML() -->\n'; //  to fix any jQuery parsing issue and it's a good design pattern, see: https://pl5.projectlocker.com/Stantive/PSTools/trac/wiki/gotcha/OCMSCachingMissingMarkup
        return sEventsArticleSummary;
    }

     /** IMPRV: rename this to JSONLIKE - which because it's not reall JSON
     * @description     Generate JSON object representing the detail article tile for the Searchable and Presentations Summary
     *
     * @author    Daniel Sokolowski
     * @date    2015-Jul-15
     * @return    String - JSON object representing article detail info, see source code for details
     */
    global String getArticleDetailJSON() {
        //String sFormattedDate = getFormattedDate(this.articleDate, this.renderLang);

         return '<caching-attribute-trap-parse-me-out />' + JSON.serialize(
            new Map<String,Object>{
              'id' => (String) this.content.id
              ,'tagPaths' => this.tagPaths
              ,'title' => this.title
              ,'mainContent' => (this.articleSummaryHeader)
              ,'endContent' => this.articleDetail
              ,'imgPath' =>  (this.articleSummaryImage  != null ? this.articleSummaryImage : '')
              ,'imgAltText' =>  this.detailImageAlt
              ,'mainFeature'  => this.articleFeatureItem
              ,'tileData'  => this.getFormattedDate(this.articleDate, this.renderLang)
              ,'linkPath'  => this.detailPage //.targetPage + '?id=' + this.versionOriginId  //IMPRV: this should understand if there are existing ? parmeters like in preview
              ,'isVideo' => (this.sVideoURL != '') ? true : false // seems to be needed by template in `hw-mli.js` line `define("app/modules/templates/feedTile.html"`
              ,'videoLink'  => this.sVideoURL  // no need for IF - front does `if(data[i].videoLink){ ...`
              ,'videoTitle' => this.title//IMPRV: does this need seperate attribute?
              ,'videoDescription'  => this.articleSummaryHeader  //IMPRV: does this need seperate attribute?

              // DS,2015-jul-15: below are currently extra attributes that HW mockup does not use
              //,'articleDate'  => sFormattedDate
              ,'articleDate'  => this.articleDate
              ,'articleFlagIcon'  => this.articleFlagIcon
            }
        );
    }

    /**
     * @description     Generate the markup for the detail tile view of a News Article
     *
     * @author    Jialin Guo
     * @date    2015-May-23
     * @return    String - Article Detail Markup
     */
    global String getNewsArticleDetailHTML() {
        String sFormattedDate = getFormattedDate(this.articleDate, this.renderLang);
        String sFormattedTime = getFormattedTime(this.articleDate);

        String sNewsArticleDetail = '';
        sNewsArticleDetail = '<!-- >>> ocms_mli_Article.getNewsArticleDetailHTML(): '
                    + (this.pm == 'prev' ? 'this.content_layout_instance=' + this.content_layout_instance : '').escapeHTML4()
                    + ' -->\n';  // to fix any jQuery parsing issue and it's a good design pattern, see: https://pl5.projectlocker.com/Stantive/PSTools/trac/wiki/gotcha/OCMSCachingMissingMarkup


        sNewsArticleDetail +=     '<main id="main" role="main" class="pageContainer">';
        sNewsArticleDetail +=     '<div class="mainContent">';

        sNewsArticleDetail +=     '<div class="contentSharing">';
        sNewsArticleDetail +=         '<div class="contentSharingContainer">';
        sNewsArticleDetail +=         '<ul></ul>';
        sNewsArticleDetail +=         '</div>'; // <div class="contentSharingContainer">
        sNewsArticleDetail +=     '</div>'; // <div class="contentSharing">

        sNewsArticleDetail +=     '<div class="genericContentContainer">';

        sNewsArticleDetail +=         '<article class="articleBlock">';

        sNewsArticleDetail +=             '<p class="supplementaryInfo">';

        if (this.sNewsArticleLeaderText != null && this.sNewsArticleLeaderText != '')
        sNewsArticleDetail +=                 '<strong>' + this.sNewsArticleLeaderText + '</strong>';

        if ((this.sNewsArticleLeaderText != null && this.sNewsArticleLeaderText != ''))
        sNewsArticleDetail +=                 ' / ';

        if (this.articleLocation != null && this.articleLocation != '')
        sNewsArticleDetail +=                 this.articleLocation;

        //if (this.articleLocation != null && this.articleLocation != '')
        //sNewsArticleDetail +=                 ' / ';

        if (this.articleDate != null && this.articleDate != '')
        sNewsArticleDetail +=                 ' / <span class="articleDate" data-date="'+this.articleDate+'">'+sFormattedDate+'</span>';

        sNewsArticleDetail +=             '</p>'; // <p class="supplementaryInfo">

        if (this.title != null  && this.title  != ''){
            sNewsArticleDetail +=             '<h3 class="title" id="ArticleTitle">'; //mmcg 2017-07-18 added specific id to fix PT#148091947: https://www.pivotaltracker.com/story/show/148091947
            sNewsArticleDetail +=                 this.title;
            sNewsArticleDetail +=             '</h3>'; // <h3 class="title">
        }

        if (articleDetail != null){
            sNewsArticleDetail +=             '<div class="details">';
            sNewsArticleDetail +=             articleDetail;
            sNewsArticleDetail +=             '</div>'; // <div class="details">
        }
        sNewsArticleDetail +=         '</article>'; // <article class="articleBlock">

        sNewsArticleDetail +=     '</div>'; // <div class="genericContentContainer">

        sNewsArticleDetail +=     '</div>'; // '<div class="mainContent">';
        sNewsArticleDetail +=     '</main>';
        sNewsArticleDetail += getFormattedDateMethod();
        sNewsArticleDetail += getArticleTitle();

        sNewsArticleDetail += '<!-- <<< ocms_mli_Article.getNewsArticleDetailHTML() -->\n'; //  to fix any jQuery parsing issue and it's a good design pattern, see: https://pl5.projectlocker.com/Stantive/PSTools/trac/wiki/gotcha/OCMSCachingMissingMarkup
        return sNewsArticleDetail;
    }

    /**
     * @description     Generate the markup for the detail tile view of each Article on the requested landing page
     *
     * @author    Jialin Guo
     * @date    2015-Apr-08
     * @return    String - Article Detail Markup
     */
    global String getBlogArticleDetailHTML() {
        String sFormattedDate = getFormattedDate(this.articleDate, this.renderLang);
        String sFormattedTime = getFormattedTime(this.articleDate);

        String sBlogArticleDetail = '';
        sBlogArticleDetail = '<!-- >>> ocms_mli_Article.getBlogArticleDetailHTML(): '
                    + (this.pm == 'prev' ? 'this.content_layout_instance=' + this.content_layout_instance : '').escapeHTML4()
                    + ' -->\n';  // to fix any jQuery parsing issue and it's a good design pattern, see: https://pl5.projectlocker.com/Stantive/PSTools/trac/wiki/gotcha/OCMSCachingMissingMarkup



            sBlogArticleDetail +=     '<div class="genericContentContainer">';

            sBlogArticleDetail +=         '<article class="articleBlock">';

            sBlogArticleDetail +=             '<p class="supplementaryInfo">';

            if (articleDate != null){
                sBlogArticleDetail +=                 '<strong> <span class="articleDate" data-date="'+this.articleDate+'">' + sFormattedDate + '</span></strong>' ;
                if (sNewsArticleLeaderText != null)
                    sBlogArticleDetail +=             ' / '+this.sNewsArticleLeaderText;
                sBlogArticleDetail +=             ' <span class="articleTime"> ' + sFormattedTime + '</span> EST';
                if (author != null){
                    sBlogArticleDetail +=             ' / ' + author;
                }
            }else{
                if (author != null){
                    sBlogArticleDetail += author;
                }
            }
            //sNewsArticleDetail +=                 '<strong>' + this.articleDate + '</strong>' + ' - Last Updated Date - ' + this.author;
            sBlogArticleDetail +=             '</p>'; // <p class="supplementaryInfo">

            if (title != null){
            sBlogArticleDetail +=             '<h2 class="title" id="ArticleTitle">';
            sBlogArticleDetail +=                 this.title;
            sBlogArticleDetail +=             '</h2>'; // <h2 class="title">
            }

            sBlogArticleDetail +=             '<div class="media">';
            sBlogArticleDetail +=                 '<figure>';
            sBlogArticleDetail +=                     '<div class="preview">';

            if (this.articleDetailImage != null){
                sBlogArticleDetail +=                     '<img src="' + this.articleDetailImage + '" alt="' + this.detailImageAlt + '"/>';
            }

            if (sVideoURL != null && sVideoURL != '') {

                sBlogArticleDetail +=                     '<a href="#overlay' + this.content.Id +'" data-hw-module="widget/core/OverlayTrigger" title="Play video with embedded YouTube video player: Opens in an overlay" class="playVideoButton accessibleLink">';
                sBlogArticleDetail +=                       '<span class="accessible">Media Title: Play video with embedded YouTube video player: Opens in an overlay</span>';
                sBlogArticleDetail +=                     '</a>';
            }



            sBlogArticleDetail +=                     '</div>'; // <div class="preview">

            sBlogArticleDetail +=                     '<figcaption>';

            sBlogArticleDetail +=                     '</figcaption>';

            sBlogArticleDetail +=                 '</figure>';
            sBlogArticleDetail +=             '</div>'; // <div class="media">

            sBlogArticleDetail +=             '<div class="details">';
            if (this.articleDetail != null){
            sBlogArticleDetail +=                 this.articleDetail;
            }
            sBlogArticleDetail +=             '</div>'; // <div class="details">

            if (actionPage.targetPage != null && actionPage.targetPage != '' && this.actionLabel != null && this.actionLabel != ''){
                sBlogArticleDetail +=         '<div class="action">';
                sBlogArticleDetail +=             '<a class="button" href="'+ocms_mli_Utility.getLinkHref(actionPage.targetPage)+'" target="'+actionPageTarget+'">';
                if (this.actionLabel != null){
                    sBlogArticleDetail +=             actionLabel;
                }
                sBlogArticleDetail +=             '</a>';
                sBlogArticleDetail +=         '</div>'; // <div class="action">
            }

            sBlogArticleDetail +=         '</article>'; // <article class="articleBlock">

            sBlogArticleDetail +=     '</div>'; // <div class="genericContentContainer">

            sBlogArticleDetail += sHTMLOverlay;
            sBlogArticleDetail += getFormattedDateMethod();

        sBlogArticleDetail += '<!-- <<< ocms_mli_Article.getBlogArticleDetailHTML() -->\n'; //  to fix any jQuery parsing issue and it's a good design pattern, see: https://pl5.projectlocker.com/Stantive/PSTools/trac/wiki/gotcha/OCMSCachingMissingMarkup
        return sBlogArticleDetail;
    }

    /**
     * @description     Generate the markup for the tile view of a Related Feed article
     *
     * @author    Jialin Guo
     * @date    2015-Apr-08
     * @return    String - Related Feed Item markup
     */
    global String getArticleRelatedFeedItemHTML() {
        String sRelatedFeedItem = '';
        sRelatedFeedItem = '<!-- >>> ocms_mli_Article.getArticleRelatedFeedItemHTML(): '
                    + (this.pm == 'prev' ? 'this.content_layout_instance=' + this.content_layout_instance : '').escapeHTML4()
                    + ' -->\n';  // to fix any jQuery parsing issue and it's a good design pattern, see: https://pl5.projectlocker.com/Stantive/PSTools/trac/wiki/gotcha/OCMSCachingMissingMarkup

        sRelatedFeedItem += '<li class="relatedFeedItem">';
        sRelatedFeedItem +=     '<div class="content">';

        if (this.articleSummaryImage != null){
            if (detailPage != null){
            sRelatedFeedItem +=     '<a href="'+detailPage+'" class="feed" target="'+detailPageTarget+'">';
            }else{
            sRelatedFeedItem +=     '<a href="#" class="feed">';
            }

            sRelatedFeedItem +=         '<div class="picture">';
            sRelatedFeedItem +=             '<img src="' + this.articleSummaryImage + '" alt="' + this.summaryImageAlt + '"/>';
            sRelatedFeedItem +=         '</div>'; //picture
        }else{
            if (detailPage != null){
            sRelatedFeedItem +=     '<a href="'+detailPage+'" class="feed noPictureFeed" target="'+detailPageTarget+'">';
            }else{
            sRelatedFeedItem +=     '<a href="#" class="feed noPictureFeed">';
            }
            sRelatedFeedItem +=         '<div class="picture">';
            sRelatedFeedItem +=         '</div>'; //picture
        }

        sRelatedFeedItem +=             '<div class="feedContent">';
        if(this.title != null) {
        sRelatedFeedItem +=                 '<p class="tag">';
        sRelatedFeedItem +=                     this.title;
        sRelatedFeedItem +=                 '</p>'; //tag
        }

        if (this.articleSummaryHeader != null && this.articleSummaryHeader != ''){
        sRelatedFeedItem +=                 '<p class="intro">';
        sRelatedFeedItem +=                     this.articleSummaryHeader;
        sRelatedFeedItem +=                 '</p>'; //intro
        }

        if (this.articleSummary != null && this.articleSummary != ''){
        sRelatedFeedItem +=                 '<p>';
        sRelatedFeedItem +=                 this.articleSummary;
        sRelatedFeedItem +=                 '</p>';
        }
        sRelatedFeedItem +=             '</div>'; //feedContent;

        sRelatedFeedItem +=         '</a>'; //feed
        sRelatedFeedItem +=     '</div>'; //content
        sRelatedFeedItem += '</li>'; //relatedFeedItem

        sRelatedFeedItem += getFormattedDateMethod();
        sRelatedFeedItem += '<!-- <<< ocms_mli_Article.getArticleRelatedFeedItemHTML() -->\n'; //  to fix any jQuery parsing issue and it's a good design pattern, see: https://pl5.projectlocker.com/Stantive/PSTools/trac/wiki/gotcha/OCMSCachingMissingMarkup
        return sRelatedFeedItem;

    }

    /**
     * @description     Translate and Format the date by language (Either en_US or fr). Including sRenderLang as an option for future proofing
     *
     * @author    Jialin Guo
     * @return    String - Translated and Formatted Date string
     */
    public String getFormattedDate(String sDateTimeString, String sRenderLang){
        String sFormattedDate = '';
        String sTranslatedMonth = '';
        String sFormattedMonth = '';
        String sFormattedDay = '';
        String sFormattedYear = '';

        // try to perform date operations, but we must handle older or incorrect data so we catch any exceptions
        // this was added after analyzing cache content refresh errors
        try {
	        Integer year = Integer.valueOf(sDateTimeString.substring(6,10));
	        Integer month = Integer.valueOf(sDateTimeString.substring(0,2));
	        Integer day = Integer.valueOf(sDateTimeString.substring(3,5));

	        Integer hours = Integer.valueOf(sDateTimeString.substring(11,13));
	        Integer minutes = Integer.valueOf(sDateTimeString.substring(14,16));


	        if (sRenderLang == 'en_US'){
	            DateTime dtDateTime = DateTime.newInstance(year,month,day,hours,minutes,0);
	            sFormattedDate = dtDateTime.format('MMMMM dd, yyyy');
	        }else{
	            sTranslatedMonth = getTranslatedMonth(month, sRenderLang);

	            DateTime dtDateTime = DateTime.newInstance(year,month,day,hours,minutes,0);
	            sFormattedDate = dtDateTime.format('dd MMM yyyy');

	            sFormattedDay = sFormattedDate.substring(0,2);
	            sFormattedMonth = sFormattedDate.substring(3,6);
	            sFormattedYear = sFormattedDate.substring(7,11);

	            sFormattedMonth = sTranslatedMonth;

	            sFormattedDate = sFormattedDay + ' ' + sFormattedMonth + ' ' + sFormattedYear;
	        }
        }
        catch(Exception e) {}
        return sFormattedDate;
    }

    /**
     * @description     Time formatting, only applied to some articles so formatting is done separately from the date
     *
     * @author    Jialin Guo
     * @return    String - Formatted Time string
     */
    public String getFormattedTime(String sDateTimeString){
        String sFormattedTime = '';

        // attempting to resolve all caching generation exceptions
        try {
	        Integer year = Integer.valueOf(sDateTimeString.substring(6,10));
	        Integer month = Integer.valueOf(sDateTimeString.substring(0,2));
	        Integer day = Integer.valueOf(sDateTimeString.substring(3,5));

	        Integer hours = Integer.valueOf(sDateTimeString.substring(11,13));
	        Integer minutes = Integer.valueOf(sDateTimeString.substring(14,16));

	        DateTime dtDateTime = DateTime.newInstance(year,month,day,hours,minutes,0);
	        sFormattedTime = dtDateTime.format('h:mm a');
        }
        catch (Exception e) {}
        return sFormattedTime;
    }

    /**
     * @description     A hardcoded list of month names in French. Including sRenderLang as an option for future proofing
     *
     * @author    Jialin Guo
     * @return    String - Translated Month name
     */

    public String getTranslatedMonth(Integer month, String sRenderLang){
        List<String> sMonthList = new List<String>();
        String sTranslatedMonth = '';

        if (sRenderLang == 'fr'){
            sMonthList.add('janvier');
            sMonthList.add('février');
            sMonthList.add('mars');
            sMonthList.add('avril');
            sMonthList.add('mai');
            sMonthList.add('juin');
            sMonthList.add('juillet');
            sMonthList.add('août');
            sMonthList.add('septembre');
            sMonthList.add('octobre');
            sMonthList.add('novembre');
            sMonthList.add('décembre');
        }

        sTranslatedMonth =  sMonthList[month - 1];

        System.debug('getTranslatedMonth sTranslatedMonth : ' + sTranslatedMonth);

        return sTranslatedMonth;
    }

    public String getFormattedDateMethod() {

        String sFormattedDateMethod = '';

        sFormattedDateMethod +=     '<script type="text/javascript">';
        sFormattedDateMethod +=         '$( document ).ajaxStop(function() {';
        sFormattedDateMethod +=             '$(\'.articleDate\').each(function (index){';
        sFormattedDateMethod +=                 'debug.log(\'article: getFormattedDateMethod()\');';
        sFormattedDateMethod +=                 'if ($(this).is(\':empty\')){';
        sFormattedDateMethod +=                     'var t = $(this).data(\'date\');';
        sFormattedDateMethod +=                     'var date = moment(t).locale(CMS.lang);';
        sFormattedDateMethod +=                     '$(this).append(date.format("LL"));';
        sFormattedDateMethod +=                     'if ( $(this).parent().next().hasClass(\'articleTime\')){';
        sFormattedDateMethod +=                         'if ( $(this).parent().next().is(\':empty\')){';
        sFormattedDateMethod +=                             '$(this).parent().next().text(date.format("LT"));';
        sFormattedDateMethod +=                         '}';
        sFormattedDateMethod +=                     '}';
        sFormattedDateMethod +=                 '}';
        sFormattedDateMethod +=             '});';
        sFormattedDateMethod +=         '});';
        sFormattedDateMethod +=     '</script>';

        return sFormattedDateMethod;

    }

    //mmcg 2017-07-18 added specific id to fix PT#148091947: https://www.pivotaltracker.com/story/show/148091947
    public String getArticleTitle() {

        String sTitleMethod = '';

            sTitleMethod += '<script id="mliArticleScript">\n';
            sTitleMethod +=     '$(document).ocmsDynamicLoadFinished(function () {\n';
            sTitleMethod +=         'document.title = $("#ArticleTitle").text();\n';
            sTitleMethod +=     '})\n';
            sTitleMethod += '</script>\n';

        return sTitleMethod;

    }

    global System.Type getType() {
        return ocms_mli_Article.class;
    }
}