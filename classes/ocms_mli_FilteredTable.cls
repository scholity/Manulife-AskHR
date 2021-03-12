/**
 * Definition and markup generation for Manulife.com (C11) Filtered Table/List Content
 *
 * @author    Jialin Guo
 * @date    2015-June-19
 *    2015-June-30    Jialin Guo
 *        Updated list of attributes for multi-lingual support/remove hardcoded table values
 *
 *    2015-June-23    Jialin Guo
 *        Updated getFilteredListAsJSON method to selectively filtered query based on filter parameters
 *
 *    2015-June-22    Jialin Guo
 *        Included getPicklist value methods, added sStartingYear attribute
 *
 *    2015-June-19    Jialin Guo
 *        Class created
 *
 */

global virtual with sharing class ocms_mli_FilteredTable extends cms.ContentTemplateController implements cms.ServiceInterface {

    private final cms.CreateContentController CCC; // convenience reference to the CreateContentController instance use when Editing content
    private final cms.GenerateContent GC; // convenience reference to the GenerateContent instance used when rendering or ajax end point?
    private final cms.ServiceAPI oServiceAPI; // convience variable to access the ServiceAPI instance which we initialize only once
    private final Map<String, String> oPageParametersMap; // will hold `ApexPages.currentPage().getParameters()`

    //private System.JSONGenerator response;
    public String JSONResponse{get;set;}

    // Default constructor invoked through `executeRequest` (where AJAX parameters become POST/GET page parameters) or
    // in OrchestraCMS cache generation
    // NOTE: if your content is cachable you must ensure that `getHTML` has dependecny on `ApexPages` (POST/GET parameters, cookies, etc)
    public ocms_mli_FilteredTable() { /* no need the `Layout` in the name word as we are extending ContentTemplateController */
        //super(); // not needed as per Murray McDonald's post https://stantive.my.salesforce.com/0D58000001qE596
        this.oServiceAPI = this.getServiceAPI();
        this.oPageParametersMap = ApexPages.currentPage() != null ?  ApexPages.currentPage().getParameters() : new Map<String,String>{};
                                  // IMPORTANT: during cache generation `ApexPages.currentPage()` is null so we fallback to empty map.
    }

    global ocms_mli_FilteredTable (cms.GenerateContent gc) {
        super(gc);
        this.oServiceAPI = this.getServiceAPI();
        this.oPageParametersMap = ApexPages.currentPage().getParameters();
    }

    global ocms_mli_FilteredTable(cms.CreateContentController cc) {
        super(cc);
        this.oServiceAPI = this.getServiceAPI();
        this.oPageParametersMap = ApexPages.currentPage().getParameters();
    }

    // Required for cms.ServiceInterface instantiation.
    global System.Type getType() {
        return ocms_mli_FilteredTable.class;
    }

    /**
     * Title icon and label attributes
     */

    public String sTableIcon {
        get {
            return getProperty('sTableIcon');
        }
        set;
    }

    public String sTableTitle {
        get {
            return getProperty('sTableTitle');
        }
        set;
    }

    /**
     * Labels for filtered dropdowns
     * Needed for multi-lingual translation
     */

    public String sStartingYear {
        get {
            return getProperty('sStartingYear');
        }
        set;
    }

    public String sYearFilterLabel {
        get {
            return getProperty('sYearFilterLabel');
        }
        set;
    }

    public String sQuarterFilterLabel {
        get {
            return getProperty('sQuarterFilterLabel');
        }
        set;
    }

    public String sReportTypeFilterLabel {
        get {
            return getProperty('sReportTypeFilterLabel');
        }
        set;
    }

    /**
     * Labels for column headings
     * Needed for multi-lingual translation
     */

    public String sDocumentTitle {
        get {
            return getProperty('sDocumentTitle');
        }
        set;
    }

    public String sReportType {
        get {
            return getProperty('sReportType');
        }
        set;
    }

    public String sFileType {
        get {
            return getProperty('sFileType');
        }
        set;
    }

    public String sDate {
        get {
            return getProperty('sDate');
        }
        set;
    }

    public String sQuarter {
        get {
            return getProperty('sQuarter');
        }
        set;
    }

    public String sDescription {
        get {
            return getProperty('sDescription');
        }
        set;
    }


    public String sDownload {
        get {
            return getProperty('sDownload');
        }
        set;
    }


    public String sEmail {
        get {
            return getProperty('sEmail');
        }
        set;
    }

    /**
     * Accessibility Labels
     */

    public String sYearFilterLabelAccessible {
        get {
            String sTemp = '';
            if (getProperty('sYearFilterLabelAccessible') != null) {
                sTemp = this.getProperty('sYearFilterLabelAccessible');
            }
            return sTemp;
        }
        set;
    }

    public String sQuarterFilterLabelAccessible {
        get {
             String sTemp = '';
            if (getProperty('sQuarterFilterLabelAccessible') != null) {
                sTemp = this.getProperty('sQuarterFilterLabelAccessible');
            }
            return sTemp;
        }
        set;
    }

    public String sReportTypeFilterLabelAccessible {
        get {
            String sTemp = '';
            if (getProperty('sReportTypeFilterLabelAccessible') != null) {
                sTemp = this.getProperty('sReportTypeFilterLabelAccessible');
            }
            return sTemp;
        }
        set;
    }

    public String sDownloadLabelAccessible {
        get {
            String sTemp = '';
            if (getProperty('sDownloadLabelAccessible') != null) {
                sTemp = this.getProperty('sDownloadLabelAccessible');
            }
            return sTemp;
        }
        set;
    }

    /*public String sShareHasPopupLabelAccessible {
        get {
            return getProperty('sShareHasPopupLabelAccessible');
        }
        set;
    }

    public String sShareFacebookLabelAccessible {
        get {
            return getProperty('sShareFacebookLabelAccessible');
        }
        set;
    }

    public String sShareTwitterLabelAccessible {
        get {
            return getProperty('sShareTwitterLabelAccessible');
        }
        set;
    }

    public String sShareLinkedInLabelAccessible {
        get {
            return getProperty('sShareLinkedInLabelAccessible');
        }
        set;
    }*/

    public String sEmailLabelAccessible {
        get {
            return getProperty('sEmailLabelAccessible');
        }
        set;
    }

    public String sPageLeftAccessible {
        get {
            return getProperty('sPageLeftAccessible');
        }
        set;
    }

    public String sPageRightAccessible {
        get {
            return getProperty('sPageRightAccessible');
        }
        set;
    }

    global String executeRequest(
        Map<String, String> oPageParametersMap /* already same as `this.oPageParametersMap` because of constructor */
    ) {
        String sAction = this.oPageParametersMap.get('action');
        String sResponse = '{"bSuccess":false,"sMessage":"Unknown action"}';

        if(sAction == 'getFilteredListDataAsJSON') {
            sResponse =  '{"bSuccess":true,"sMessage":' + this.getFilteredListAsJSON()  + '}';
        }

        return sResponse;
    }

    public String getFilteredListAsJSON() {
        String sLanguageCode = '';

        sLanguageCode = getServiceAPI().getRenderLanguage();

        if(Test.isRunningTest()) {
            sLanguageCode = 'en_US';
        }

        if (sLanguageCode != 'en_US' && sLanguageCode != 'fr')
            sLanguageCode = 'en_US';

        String sQuery = '';
        sQuery = 'SELECT Id, Name, Date__c, Description__c, Document_Title__c, File_Type__c, Quarter__c, Report_Type__c, Language__c, (SELECT Id from NotesAndAttachments) FROM mli_Quarterly_Report__c';

        String sQueryYear = this.oPageParametersMap.get('year');
        String sQueryQuarter = this.oPageParametersMap.get('quarter');
        String sQueryReportType = this.oPageParametersMap.get('reportType');

        Boolean useWhere = true;

        if (sQueryYear != null && sQueryYear != ''){
            Integer iQueryYear = integer.valueOf(sQueryYear);
            sQuery += ' WHERE Calendar_Year(Date__c) = ' + iQueryYear;

            if (useWhere == true)
                useWhere = false;
        }

        if (sQueryQuarter != null && sQueryQuarter != ''){

            if (useWhere == true){
                sQuery += ' WHERE Quarter__c = :sQueryQuarter';
                useWhere = false;
            }else{
                sQuery += ' AND Quarter__c = :sQueryQuarter';
            }
        }

        if (sQueryReportType != null && sQueryReportType != ''){
            if (useWhere == true){
                sQuery += ' WHERE Report_Type__c = :sQueryReportType';
                useWhere = false;
            }else{
                sQuery += ' AND Report_Type__c = :sQueryReportType';
            }

        }

        if (sLanguageCode != null && sLanguageCode != ''){
            if (useWhere == true){
                sQuery += ' WHERE Language__c = :sLanguageCode';
                useWhere = false;
            }else{
                sQuery += ' AND Language__c = :sLanguageCode';
            }

        }

        // 2016-03-14 - [Stephen Scholtz] Added ORDER BY clause to provide a sort
        // order for the quarterly reports, addressing Defect 9781
        sQuery += ' ORDER BY Date__c DESC';

        List<mli_Quarterly_Report__c> oQuarterlyReportsList = database.query(sQuery);

        System.JSONGenerator response;
        response = System.JSON.createGenerator(false);
        response.writeStartArray();

        if (oQuarterlyReportsList != null ){
            Integer iReportCount = 0;
            for (mli_Quarterly_Report__c oQuarterlyReport : oQuarterlyReportsList){

                String sQReportDate =  string.valueOfGmt(oQuarterlyReport.Date__c);
                String sDownloadLink = '';
                if (oQuarterlyReport.NotesAndAttachments.size() > 0) {
                    //TODO:  make this change again, this should not have been reversed.
                    // 2016-09-26 - [mmcg] Made URL relative, addressing Defect 9824
                    sDownloadLink =  URL.getSalesforceBaseUrl().toExternalForm() + '/servlet/servlet.FileDownload?file=' + oQuarterlyReport.NotesAndAttachments[0].Id;
                    //sDownloadLink =  'http://www.manulife.com/servlet/servlet.FileDownload?file=' + oQuarterlyReport.NotesAndAttachments[0].Id;
                }

                Integer year = Integer.valueOf(sQReportDate.substring(0,4));

                response.writeStartObject();

                    response.writeStringField('id : ', oQuarterlyReport.Id);
                    response.writeStringField('downloadLink', sDownloadLink);
                    response.writeStringField('itemTitle', oQuarterlyReport.Document_Title__c);
                    response.writeFieldName('row');
                    response.writeStartObject();
                    response.writeStringField('title', '<span class=\'download\' tabindex=\'0\'>' + oQuarterlyReport.Document_Title__c  + '</span>');
                    response.writeStringField('sEmail', '<span class=\'email\' tabindex=\'0\'> </span>');
                        if (oQuarterlyReport.Report_Type__c != null) {

                            String sReportLabel = getLanguageLabel(oQuarterlyReport.Report_Type__c, sLanguageCode);
                            response.writeStringField('reportType', sReportLabel);
                            //response.writeStringField('reportType', oQuarterlyReport.Report_Type__c);
                        } else {
                            response.writeStringField('reportType', '');
                        }
                        response.writeStringField('fileType', oQuarterlyReport.File_Type__c);
                        response.writeNumberField('year', year);
                        if (oQuarterlyReport.Quarter__c != null) {
                            String sQuarterLabel = getLanguageLabel(oQuarterlyReport.Quarter__c, sLanguageCode);
                            response.writeStringField('quarter', sQuarterLabel);
                        } else {
                            response.writeStringField('quarter', '');
                        }


                    response.writeEndObject();

                response.writeEndObject();
            }
        }

        response.writeEndArray();
        response.close();
        JSONResponse = response.getAsString();
        return JSONResponse;

    }

    public String getYearPicklistValues(){

        Integer iCurrentYear = System.Today().year();
        Integer iStartingYear;

        if(Test.isRunningTest()) {
            this.sStartingYear = '2013';
            iStartingYear = 2013;
        }

        if (sStartingYear != null){
          iStartingYear = integer.valueof(sStartingYear);
        }

        String sYears = '';

        if (iStartingYear < iCurrentYear) {
            if (sYearFilterLabel != null || sYearFilterLabel != '')
                sYears = '<option value="">' +sYearFilterLabel+ '</option>';
            else
                sYears = '<option value="">Year</option>';

            for (Integer iYear = iCurrentYear; iYear >= iStartingYear; iYear -- ) {
                sYears += '<option value="'+iYear+'">' + string.valueOf(iYear) + '</option>';
            }
        }

        return sYears;
    }


    public String getQuarterPicklistValues(){
        String sLanguageCode = '';
        sLanguageCode = getLanguageCode();

        String sLanguageLabel = '';
        String sQuarters = '';

        if (sQuarterFilterLabel != null)
            sQuarters = '<option value="">' + sQuarterFilterLabel + '</option>';
        else
            sQuarters = '<option value="">Quarter</option>';

        Schema.DescribeFieldResult fieldResult = mli_Quarterly_Report__c.Quarter__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

        for( Schema.PicklistEntry f : ple)
        {
            if (f.getValue().contains(sLanguageCode)){
                sLanguageLabel = getLanguageLabel(f.getValue(), sLanguageCode);
                sQuarters += '<option value="'+f.getValue()+'">'+sLanguageLabel+'</option>';
            }
        }

        return sQuarters;
    }

    public String getTypePicklistValues(){

        String sLanguageCode = '';
        sLanguageCode = getLanguageCode();

        String sLanguageLabel = '';

        List<SelectOption> options = new List<SelectOption>();
        String sReportType = '';

        if (sReportTypeFilterLabel != null)
            sReportType += '<option value="">' + sReportTypeFilterLabel + '</option>';
        else
            sReportType += '<option value="">Report Type</option>';

        Schema.DescribeFieldResult fieldResult = mli_Quarterly_Report__c.Report_Type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple)
        {
            if (f.getValue().contains(sLanguageCode)){
                sLanguageLabel = getLanguageLabel(f.getValue(), sLanguageCode);
                sReportType += '<option value="'+f.getValue()+'">'+sLanguageLabel+'</option>';
            }
        }

        return sReportType;
    }

    public String getLanguageLabel(String sLanguageCookie, String sLanguageCode){
        String sLanguageLabel = '';

        sLanguageLabel = sLanguageCookie.removeStart(sLanguageCode + '::');

        return sLanguageLabel;
    }

    public String getLanguageCode(){
        String sLanguageCode = '';

        sLanguageCode = getServiceAPI().getRenderLanguage();

        if (sLanguageCode != 'en_US' && sLanguageCode != 'fr')
            sLanguageCode = 'en_US';

        return sLanguageCode;
    }

    // For generated markup
    global virtual override String getHTML() { // For generated markup


        String sHTML = '<!-- >>> ocms_mli_FilteredTable.getHTML(...): '
                    + (this.pm == 'prev' ? 'this.content_layout_instance=' + this.content_layout_instance : '').escapeHTML4()
                    + ' -->\n';  // to fix any jQuery parsing issue and it's a good design pattern, see: https://pl5.projectlocker.com/Stantive/PSTools/trac/wiki/gotcha/OCMSCachingMissingMarkup


        
        sHTML +=    '<div class="genericContentContainer" style="overflow:visible;">'; //adding in-line style to address drop-down overflow issue, but avoid affecting other Generic Content items
        sHTML +=        '<!-- filter list START -->';
        sHTML +=        '<div class="basicTable filterList">';

        sHTML +=            '<div class="basicTableContainer" data-hw-module="module/FilterList">';

        // Only show the title row if there is a title to display
        if (this.sTableTitle != null || this.sTableTitle != ''){
        sHTML +=            '<div class="genericIconTitle genericIconTitleAlt">';
        sHTML +=                '<h3 class="title';
        if (this.sTableIcon == null) {
            sHTML +=            ' genericIconTitle__title--noIcon';
        }
        sHTML +=                '">';
        if (this.sTableIcon != null || this.sTableIcon != '') {
            sHTML +=                '<span class="image-icon"><img src="' + this.sTableIcon + '" alt=""></span>';
        }
        sHTML +=                    '<span class="text">' + ((this.sTableTitle != null) ? this.sTableTitle : '') + '</span>';
        sHTML +=                '</h3>';
        sHTML +=            '</div>';
        }

        sHTML +=            '<div class="filterSelectRow">';

        sHTML +=                '<div class="filterSelectContainer">';
        sHTML +=                    '<div class="customSelect accessibleLink customSelectInverted reportTypeFilterSelect" data-hw-module="module/SelectWithMenuAndCustomScrollbar" aria-label="'+this.sReportTypeFilterLabelAccessible.escapeHtml4()+'">';
        sHTML +=                            '<select name="reportType" id="reportSelect">';
        sHTML +=                                getTypePicklistValues();
        sHTML +=                            '</select>';
        sHTML +=                    '</div>';
        sHTML +=                '</div>';

        sHTML +=                '<div class="filterSelectContainer">';
        sHTML +=                    '<div class="customSelect accessibleLink customSelectInverted yearFilterSelect" data-hw-module="module/SelectWithMenuAndCustomScrollbar" aria-label="'+this.sYearFilterLabelAccessible.escapeHtml4()+'">';
        sHTML +=                            '<select name="year" id="yearSelect">';
        sHTML +=                                getYearPicklistValues();
        sHTML +=                            '</select>';
        sHTML +=                    '</div>';
        sHTML +=                '</div>';

        sHTML +=                '<div class="filterSelectContainer">';
        sHTML +=                    '<div class="customSelect accessibleLink customSelectInverted quarterFilterSelect" data-hw-module="module/SelectWithMenuAndCustomScrollbar" aria-label="'+this.sQuarterFilterLabelAccessible.escapeHtml4()+'">';
        sHTML +=                            '<select name="quarter" id="quarterSelect">';
        sHTML +=                                getQuarterPicklistValues();
        sHTML +=                            '</select>';
        sHTML +=                    '</div>';
        sHTML +=                '</div>';

        sHTML +=            '</div>'; //filterSelectRow

        sHTML +=            '<p class="instruction mobileOnly">Scroll left and right to view content</p>';
        sHTML +=            '<div class="tableContent">';
        sHTML +=                '<table>';
        sHTML +=                    '<thead>';
        sHTML +=                        '<tr>';
        // Add some graceful error handling. If any column header values are null, display a default value:
        if (this.sDocumentTitle != null || this.sDocumentTitle != '')
            sHTML +=                        '<th scope="col">'+this.sDocumentTitle+'</th>';
        else
            sHTML +=                        '<th scope="col">Document Title</th>';

        if (this.sEmail != null || this.sEmail != '')
            sHTML +=                        '<th scope="col">'+this.sEmail+'</th>';
        else
            sHTML +=                        '<th scope="col">Email</th>';

        if (this.sReportType != null || this.sReportType != '')
            sHTML +=                        '<th scope="col">'+this.sReportType+'</th>';
        else
            sHTML +=                        '<th scope="col">Report Type</th>';

        if (this.sFileType != null || this.sFileType != '')
            sHTML +=                        '<th scope="col">'+this.sFileType+'</th>';
        else
            sHTML +=                        '<th scope="col">File Type</th>';

        if (this.sDate != null || this.sDate != '')
            sHTML +=                        '<th scope="col">'+this.sDate+'</th>';
        else
            sHTML +=                        '<th scope="col">Date</th>';

        if (this.sQuarter != null || this.sQuarter != '')
            sHTML +=                        '<th scope="col">'+this.sQuarter+'</th>';
        else
            sHTML +=                        '<th scope="col">Quarter</th>';

        sHTML +=                        '</tr>';
        sHTML +=                    '</thead>';
        sHTML +=                    '<tbody>';
        sHTML +=                        '<!-- Template output here-->';
        sHTML +=                    '</tbody>';
        sHTML +=                '</table>';
        sHTML +=            '</div>'; //tableContent

        sHTML +=            '<div class="row">';
        sHTML +=                '<div class="filterListActions">';
        sHTML +=                    '<!-- Note: \'download\', \'share\', \'shareTrigger\', \'shareDropdown\' and \'email\' are used for JS -->';
        sHTML +=                    '<ul class="filterListActions__list">';

        //sHTML +=                        '<li class="filterListActions__item download">';
        /*sHTML +=                        '<li class="filterListActions__item">';
        sHTML +=                            '<button type="button" disabled="true" aria-disabled="true" class="filterListActions__button filterListActions__button--download accessibleLink shareTrigger">';
        if (this.sDownloadLabelAccessible != null || this.sDownloadLabelAccessible != '')
        sHTML +=                                '<span class="accessible">'+this.sDownloadLabelAccessible+'</span>';
        sHTML +=                            '</button>';
        sHTML +=                        '</li>';*/

        /*sHTML +=                      '<li class="filterListActions__item filterListActions__item--withDropdown share" data-hw-module="module/ShowHide" data-hw-options="';

        sHTML +=                            'selectors: {';
        sHTML +=                                'button: \'.shareTrigger\',';
        sHTML +=                                'contentArea: \'.shareDropdown\'';
        sHTML +=                            '},';
        sHTML +=                            'classes: {';
        sHTML +=                                'isOpen: \'is-open\'';
        sHTML +=                            '}';
        sHTML +=                        '">';

        sHTML +=                            '<button type="button" disabled="true" aria-disabled="true" class="filterListActions__button filterListActions__button--share shareTrigger accessibleLink">';
        if (this.sShareHasPopupLabelAccessible != null || this.sShareHasPopupLabelAccessible != '')
        sHTML +=                                '<span class="accessible">'+this.sShareHasPopupLabelAccessible+'</span>';
        sHTML +=                            '</button>';

        sHTML +=                            '<div class="filterListActionsMenu shareDropdown">';
        sHTML +=                                '<ul class="filterListActionsMenu__list">';

        sHTML +=                                    '<li class="filterListActionsMenu__item">';
        sHTML +=                                        '<a href="#" class="filterListActionsMenu__icon filterListActionsMenu__icon--facebook" title="External site: Opens in a new window">';
        if (this.sShareFacebookLabelAccessible != null || this.sShareFacebookLabelAccessible != '')
        sHTML +=                                            '<span class="accessible">'+this.sShareFacebookLabelAccessible+'</span>';
        sHTML +=                                            'Share';
        sHTML +=                                            '<span class="share-value">64k</span>';
        sHTML +=                                        '</a>';
        sHTML +=                                    '</li>';

        sHTML +=                                    '<li class="filterListActionsMenu__item">';
        sHTML +=                                        '<a href="#" class="filterListActionsMenu__icon filterListActionsMenu__icon--twitter">';
        if (this.sShareTwitterLabelAccessible != null || this.sShareTwitterLabelAccessible != '')
        sHTML +=                                            '<span class="accessible">'+this.sShareTwitterLabelAccessible+'</span>';
        sHTML +=                                                'Share';
        sHTML +=                                            '<span class="filterListActionsMenu__shareValue">1k</span>';
        sHTML +=                                        '</a>';
        sHTML +=                                    '</li>';

        sHTML +=                                    '<li class="filterListActionsMenu__item">';
        sHTML +=                                        '<a href="#" class="filterListActionsMenu__icon filterListActionsMenu__icon--linkedin">';
        if (this.sShareLinkedInLabelAccessible != null || this.sShareLinkedInLabelAccessible != '')
        sHTML +=                                            '<span class="accessible">'+this.sShareLinkedInLabelAccessible+'</span>';
        sHTML +=                                                'LinkedIn';
        sHTML +=                                            '<span "filterListActionsMenu__shareValue">1k</span>';
        sHTML +=                                        '</a>';
        sHTML +=                                    '</li>';

        sHTML +=                                '</ul>';
        sHTML +=                            '</div>';
        sHTML +=                        '</li>';*/


        /*sHTML +=                        '<li class="filterListActions__item filterListActions__item--email email">';
        sHTML +=                            '<button type="button" disabled="true" aria-disabled="true" class="filterListActions__button filterListActions__button--email accessibleLink">';
        if (this.sEmailLabelAccessible != null || this.sEmailLabelAccessible != ''){
        sHTML +=                                '<span class="accessible">';
        sHTML +=                                    this.sEmailLabelAccessible;
        sHTML +=                                '</span>';
        }
        sHTML +=                            '</button>';
        sHTML +=                        '</li>';*/
        sHTML +=                    '</ul>';
        sHTML +=                '</div>'; //filterListActions

        sHTML +=                '<div class="pagination searchResultPagination">';

        sHTML +=                    '<button type="button" class="previous icon-caret-left">';
        if (this.sPageLeftAccessible != null || this.sPageLeftAccessible != '') {
        sHTML +=                        '<span class="accessible">>';
        sHTML +=                            this.sPageLeftAccessible;
        sHTML +=                        '</span>';
        }
        sHTML +=                    '</button>';

        sHTML +=                        '<ul><!-- generated by JS --></ul>';

        sHTML +=                    '<button type="button" class="next icon-caret-right">';
        if (this.sPageRightAccessible != null || this.sPageRightAccessible != '') {
        sHTML +=                        '<span class="accessible">';
        sHTML +=                            this.sPageRightAccessible;
        sHTML +=                        '</span>';
        }
        sHTML +=                    '</button>';

        sHTML +=                '</div>'; //pagination searchResultPagination
        sHTML +=            '</div>'; //row
        sHTML +=            '</div>'; //basicTableContainer


        sHTML +=        '</div>'; //basicTable filterList
        sHTML +=        '<!-- filter list END -->';
        sHTML +=    '</div>'; //genericContentContainer

        sHTML += '<!-- <<< ocms_mli_FilteredTable.getHTML(...) -->'; //  to fix any jQuery parsing issue and it's a good design pattern, see: https://pl5.projectlocker.com/Stantive/PSTools/trac/wiki/gotcha/OCMSCachingMissingMarkup
        return sHTML;
    }
}