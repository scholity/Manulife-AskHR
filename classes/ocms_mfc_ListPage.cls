/**
 *  ocms_mfc_ListPage
 *
 *  2015-Nov-13 Bill Lucas
 *              CR2 - added sortOrder (default: originalDate, latestDate); added allFilterIsLast (default: false)
 *
 *  2015-May    Tyson Riehl
 *              Original
 */

global with sharing class ocms_mfc_ListPage extends cms.ContentTemplateController implements cms.ServiceInterface {

    global ocms_mfc_ListPage () {}

    global ocms_mfc_ListPage (cms.GenerateContent gc) {
        super(gc);
    }

    global ocms_mfc_ListPage (cms.CreateContentController cc) {
        super(cc);
    }

    final static String MANULIFE_CENTRAL_NAME = 'Manulife Central';

    public System.Type getType(){
        return ocms_mfc_ListPage.class;
    }

    public String title {
        get {
            return getProperty('title') != null ? getProperty('title') : '';
        } set;
    }

    public String siteMapPath {
        get {
            return getProperty('siteMapPath') != null ? getProperty('siteMapPath') : '';
        } set;
    }

    public String filterText {
        get {
            return getProperty('filterText') != null ? getProperty('filterText') : '';
        } set;
    }

    public String parentTaxonomyNode {
        get {
            return getProperty('parentTaxonomyNode');
        } set;
    }

    // the initial filter category (if relevent, i.e. the filter is being shown) will be 'allfirst' or 'child'
    // 'allfirst' is the default and equivalent to how ListPage has been working from the start; it this value
    // is 'child' then initialFilterChild should be a taxonomy path to a child node that will be the filter bar's initialselection
    public String initialFilterCat {
        get {
            String ifc = getProperty('initialFilterCat');
            return String.isNotBlank(ifc) ? ifc : 'allfirst';
        } set;
    }

    // the child taxonomy node as a path
    public String initialFilterChild {
        get {
            String initialChild = getProperty('initialFilterChild');
            return String.isNotBlank(initialChild) ? initialChild : '';
        } set;
    }

    public String contentTypeId {
        get {
            return getProperty('contentTypeId');
        } set;
    }

    public String contentType {
        get {
            return getProperty('contentType');
        } set;
    }

    public String contentTemplate {
        get {
            return 'Tile';
        } set;
    }

    public String loadAmount {
        get {
            return getProperty('loadAmount');
        } set;
    }

    public String showMaxPriorityItems {
        get {
            String maxItems = getProperty('showMaxPriorityItems');
            return maxItems == null ? '0' : maxItems;
        } set;
    }

    public string allLocationsText {
        get {
            return getProperty('allLocationsText') != null ? getProperty('allLocationsText') : '';
        } set;
    }

    public string allText {
        get {
            return getProperty('allText') != null ? getProperty('allText') : '';
        } set;
    }

    public String stopAllLocLoad {
        get {
            String stopAllLocationLoad = getProperty('stopAllLocLoad');
            return (stopAllLocationLoad == null ? 'false' : stopAllLocationLoad);
        }set;
    }

    // the child taxonomy node as a path
    public String initialLocLoad {
        get {
            String initialLoc = getProperty('initialLocLoad');
            return String.isNotBlank(initialLoc) ? initialLoc : '';
        } set;
    }

    public String useParentPath {
        get {
            String parentPath = getProperty('useParentPath');
            return (parentPath == null ? 'false' : parentPath);
        } set;
    }

    public String showAllFilter {
        get {
            String allFilter = getProperty('showAllFilter');
            return (allFilter == null ? 'false' : allFilter);
        } set;
    }

    public String allFilterIsLast {
        get {
            String isLast = getProperty('allFilterIsLast');
            return String.isNotBlank(isLast) ? isLast : 'false';
        } set;
    }

    public String showSearchBar {
         get {
            String searchBar = getProperty('showSearchBar');
             return (searchBar == null ? 'false' : searchBar);
         } set;
     }

    public String showFeatured {
        get {
            String featured = getProperty('showFeatured');
            return (featured == null ? 'false' : featured);
        } set;
    }

    public String showPriorityMessages {
        get {
            String priorityMessages = getProperty('showPriorityMessages');
            return (priorityMessages == null ? 'false' : priorityMessages);
        } set;
    }

    public String listView {
         get {
            String view = getProperty('listView');
             return (view == null ? 'false' : view);
         } set;
     }

    public String hideTilesLikeAction {
         get {
            String view = getProperty('hideTilesLikeAction');
             return (view == null ? 'false' : view);
         } set;
     }

    public String hideTilesShareAction {
         get {
            String view = getProperty('hideTilesShareAction');
             return (view == null ? 'false' : view);
         } set;
     }

     public String sortOrder {
        get {
            String sOrder = getProperty('sortOrder');
            return String.isNotBlank(sOrder) ? sOrder : 'originalDate';
        } set;
     }

     public String helperTitle {
         get {
            return getProperty('helperTitle') != null ? getProperty('helperTitle') : '';
         } set;
     }

    public String helperText {
        get {
            return getProperty('helperText') != null ? getProperty('helperText') : '';
        } set;
     }

    public String filter {
        get {
            return getProperty('filter');
        } set;
    }

    public String viewAllLabel {
        get {
            return getProperty('viewAllLabel');
        }set;
    }

    public String viewAllTargetPage {
        get {
            return getProperty('viewAllTargetPage');
        }set;
    }

    public cms.Link viewAllTargetPageLink {
        get {
            return new cms.Link(viewAllTargetPage);
        }
    }

    public String viewAllTargetPageURL {
        get {
            return viewAllTargetPageLink.targetPage;
        }
    }

    private cms.ServiceAPI sAPI {
        get {
            if (sApi == null) {
                sApi = getServiceAPI();
            }

            return sApi;
        } set;
    }

    public ocms_TaxonomyAPI taxonomyApi {
        get {
            if (taxonomyApi == null) {
                taxonomyApi = new ocms_TaxonomyAPI(sApi);
            }

            return taxonomyApi;
        } set;
    }

    private ocms_mfc_Taxonomy mfcTaxonomy {
        get {
            if (mfcTaxonomy == null) {
                mfcTaxonomy = new ocms_mfc_Taxonomy(sApi);
            }

            return mfcTaxonomy;
        } set;
    }

    public List<cms__Content_Template_Relationship__c> contentTemplateRelationships;


    global String executeRequest (Map <String, String> request) {
        String response = '{"success":false,"message":"Action not supported."}';

        if(request.containsKey('action')) {
            String action = request.get('action');

            if (action == 'getContentTypes') {
                response = getContentTypesJSONResponse(request.get('contentTemplate'));
            } else if (action == 'getPageRenderings') {
                response = getPageRenderingsJSONResponse(
                    request.get('term'),
                    request.get('contentType'),
                    request.get('contentTypeId'),
                    request.get('contentTemplate'),
                    request.get('filter'),
                    request.get('filterValue'),
                    request.get('subMenuTag'),
                    request.get('parentTaxonomyNode'),
                    request.get('offset'),
                    request.get('amountToRetrieve'),
                    request.get('showFeatured'),
                    request.get('featuredId'),
                    request.get('requestNumber'),
                    request.get('useParentPath'),
                    request.get('sortOrder'),
                    request.get('listPageListLayout'),
                    request.get('showPriorityMessages'),
                    request.get('showMaxPriorityItems'),
                    request.get('priorityIds')
                );
            }
        }
        return response;
    }

    private List<cms__Content_Template_Relationship__c> getRelationships(String contentTemplate) {
        ocms_mfc_SiteSettings__c settings = ocms_mfc_SiteSettings__c.getValues(MANULIFE_CENTRAL_NAME);
        String siteName = settings.Site_Name__c;

        if (contentTemplateRelationships == null) {
            contentTemplateRelationships = [SELECT cms__Content_Type__r.cms__Name__c, cms__Content_Type__r.cms__Label__c, cms__Content_Layout__r.cms__Name__c FROM cms__Content_Template_Relationship__c WHERE cms__Content_Layout__r.cms__Name__c = :contentTemplate AND cms__Content_Type__r.cms__Site_Name__c  = :siteName];
        }

        return contentTemplateRelationships;
    }

    /**
     * @description gets all content types that have the given template
     * @param contentTemplate - The content template each Content Type must have
     * @return String - JSON object with {"Content Name": {"Name": "name", "Label": "label", "id": "id"}}
     */
    public String getContentTypesJSONResponse(String contentTemplate) {

        List<cms__Content_Template_Relationship__c> relationships = getRelationships(contentTemplate);
        String jsonResponse = '{"success": true, "contentTypes": {';
        Boolean first = true;
        for (cms__Content_Template_Relationship__c relationship : relationships) {
            cms__Content_Type__c contentTypeC = relationship.cms__Content_Type__r;

            if (contentTypeC != null) {
                jsonResponse += (first ? '' : ', ');
                jsonResponse += '"' + contentTypeC.cms__Name__c + '": {"name": "' + contentTypeC.cms__Name__c + '",';
                jsonResponse += '"label": "' + contentTypeC.cms__Label__c + '",';
                jsonResponse += '"id": "' + contentTypeC.Id + '"';
                jsonResponse += '}';
                first = false;
            }
        }

        return jsonResponse + '}}';
    }

    global override String getHTML () {
        Integer amountToLoad = 12;
        try {
            amountToLoad = Integer.valueOf(loadAmount);
            if (amountToLoad < 0) {
                amountToLoad = 0;
            }
        } catch(Exception ex) {
            System.Debug(ex.getStackTraceString());
        }

        Integer showMaxPriorityItemsInt = showMaxPriorityItems.isNumeric() ? Integer.valueOf(showMaxPriorityItems) : 0;

        Map<String, String> sitePreferences = ocms_mfc_SitePreferences.getSitePreferences(pm, sApi.getRenderLanguage());
        String html = '<div id="list-content" data-list-id="' + this.content.Id + '">';
        Boolean hasFilterOrSearch = (showSearchBar == 'true' || filter == 'location');

        if (hasFilterOrSearch) {
           html += '<div class="list-search">';
        }

        // DropDown filtering by location
        if (filter == 'location') {
            cms.TaxonomyNodeInfo rootNode = ocms_mfc_Taxonomy.getTaxonomyNodeInfoAtPath(sApi, sitePreferences.get('locationTaxonomy'));
            String nodeName = '';
            String parentPath = '';
            String selectedInitialNodeName = '';

            if (rootNode != null) {
                nodeName = rootNode.getName();
                parentPath = rootNode.getParentPath();
            }

            //if initial selection != null, find node name for selected node
            //cms.TaxonomyNodeInfo selectedNode = ocms_mfc_Taxonomy.getTaxonomyNodeInfoAtPath(sApi, <selected path>);
            //String nodeName = '';
            //if (selectedNode != null){
            //    nodeName = selectedNode.getName();
            //}

            String tagValue = parentPath + '/' + nodeName;

            html += '<div class="col col-1">';
            html +=     '<div class="global-accordion-filter">';

            if (!String.isEmpty(initialLocLoad)) {
                //get the node name from the taxonomy given the initial selected node
                cms.TaxonomyNodeInfo selectedNode = ocms_mfc_Taxonomy.getTaxonomyNodeInfoAtPath(sApi, initialLocLoad);
                if (selectedNode != null){
                    selectedInitialNodeName = selectedNode.getName();
                }                
                html +=         '<input type="text" data-mfc-name="' + selectedInitialNodeName +'" data-mfc-value="' + initialLocLoad + '"/>';
                html +=         '<div class="input">';
                html +=             '<span>' + selectedInitialNodeName + '</span>';     
            }else{
                html +=         '<input type="text" data-mfc-name="' + nodeName + '" data-mfc-value="' + tagValue +'"/>';
                html +=         '<div class="input">';
                html +=             '<span>' + allLocationsText+ '</span>';
            }

            html +=             '<div class="arrow"></div>';
            html +=             '<div class="drop">';
            html +=                 '<ul>';
            html +=                     '<li class="item num-Item open">' + '<a href="#" data-mfc-stop-all-load="' + stopAllLocLoad + '" data-mfc-name="' + allLocationsText + '" data-mfc-value="' + tagValue + '">' + allLocationsText + '</a>';
            html +=                     '<div class="arrow"></div>';
            html +=                     '<ul>';

            if (rootNode != null) {
                for(cms.TaxonomyNodeInfo taxonomyRootNodeChild : rootNode.getChildren()) {
                    html += getLocationDropDown(taxonomyRootNodeChild);
                }
            }

            html +=                     '</ul>';
            html +=                 '</ul>';
            html +=             '</div>';
            html +=         '</div>';
            html +=     '</div>';
            html += '</div>';
        }

        List<String> childNodeNames = new List<String>();

        if (useParentPath == 'false') {
            // Loop through all children of the parent node and get their names to be used for the filter bar
            cms.TaxonomyNodeInfo categoryNodes = ocms_mfc_Taxonomy.getTaxonomyNodeInfoAtPath(sApi, parentTaxonomyNode);
            if (categoryNodes != null) {
                for(cms.TaxonomyNodeInfo currentNode : categoryNodes.getChildren()) {
                    childNodeNames.add(currentNode.getName());
                }
            }

            if (childNodeNames.isEmpty()) {
                System.debug('::: ListPage: filter bar requested but no child nodes were found!');
                System.debug(parentTaxonomyNode);
                childNodeNames.add('No child taxonomy categories below ' + parentTaxonomyNode.removeEnd('/').substringAfterLast('/'));
            }
        } else {
            showAllFilter = 'false';
            childNodeNames.add(parentTaxonomyNode.removeEnd('/').substringAfterLast('/'));
        }


        if (showSearchBar == 'true') {
        // Taxonomy Filter Bar html
            html += '<div class="col col-2">';
            html +=     '<input class="global-input-text" type="text" value placeholder="' + sitePreferences.get('uiLabelSearchPlaceholder') + '"/>';
            html +=     '<div class="clear"></div>';
            html += '</div>';
        }

        if (hasFilterOrSearch) {
            html +=     '<div class="clear"></div>';
            html += '</div>';// List Search
            html += '<hr>';
        }

        // when useParentPath, the filter bar is never shown
        // // why is global-content-filter still generated? Does something rely on div.title within, which style rules for #list-content do not display?
        if (useParentPath == 'true') {
            html += '<div class="global-content-filter" style="display:none">';
        } else {
            html += '<div class="global-content-filter">';
        }

        html +=     '<div class="title">';
        if (String.isNotBlank(filterText)) {
            html += filterText + ' ';           // OCMS seems to strip trailing spaces; surely they want at least one
        }
        html +=         '<span class="selected-filter">';

        if (showAllFilter == 'true') {
            html +=         allText;
        } else if (childNodeNames.size() > 0) {
            html +=         childNodeNames[0];
        }

        html +=         '</span>';
        html +=         '<div class="arrow"></div>';
        html +=     '</div>';
        html +=     '<ul>';



        final String CLASS_SELECTED = ' class="selected"';
        String htmlAllFilter;

        String initialFilterName;
        if (useParentPath == 'true') {
            // "Do not show filter bar"
            initialFilterName = childNodeNames[0];
        } else {
            // "Show filter bar"
            if (initialFilterCat == 'allfirst') {
                if (showAllFilter == 'true') {
                    initialFilterName = allText;
                } else {
                    initialFilterName = childNodeNames[0];
                }
            } else {
                // note: we do nothing to ensure they picked a category from the appropriate taxonomy
                initialFilterName = initialFilterChild.removeEnd('/').substringAfterLast('/');
                if (String.isBlank(initialFilterName)) {
                    // INVALID DATA: fallback so something not bad happens
                    initialFilterName = childNodeNames[0];
                }
            }

            if (showAllFilter == 'true') {
                htmlAllFilter = '<li><a href="#"' + (initialFilterName == allText ? CLASS_SELECTED : '') + ' data-mfc-value="' + String.join(childNodeNames, '/') + '">' + allText + '</a></li>';
            }
        }


        if (String.isNotBlank(htmlAllFilter) && allFilterIsLast == 'false') {
            html += htmlAllFilter;
        }

        for (String childName : childNodeNames) {
            html += '<li><a href="#"' + (initialFilterName == childName ? CLASS_SELECTED : '') + ' data-mfc-value="' + childName + '">' + childName + '</a></li>';
        }

        if (String.isNotBlank(htmlAllFilter) && allFilterIsLast == 'true') {
            html += htmlAllFilter;
        }

        html +=     '</ul>';
        html += '</div>'; //global-content-filter

        html += '<div class="listings' + (listView == 'true' ? ' list-view' : '') + '"></div>';

        html += '<a class="global-show-more clear" style="display: none">';
        html +=     '<span>' + sitePreferences.get('uiLabelShowMore') + '</span>';
        html +=     '<img src="' + ocms_mfc_Utility.getResourceURL('ocms_mfc_siteFiles') + '/img/global-show-more-sm.gif"/>';
        html += '</a>';
        //view all text from loader, but only if label text and destination has been specified.
//        System.debug(viewAllTargetPage);
//        System.debug(viewAllTargetPageLink);
//        System.debug(viewAllTargetPageLink.link);
//        System.debug(viewAllTargetPageLink.target);
//        System.debug(viewAllTargetPageURL);
        if (!String.isBlank(viewAllLabel) && !String.isBlank(viewAllTargetPageURL)) {
            html += '<div class="viewAllBtn">';
            html += '<a href="' + viewAllTargetPageURL  + '"';
            if (!String.isBlank(viewAllTargetPageLink.target)){
                html += ' target="'+ viewAllTargetPageLink.target +'"';
            }
            html += '><span>' + viewAllLabel + '</span></a>';
            html += '</div>';
        }
        // FootNote Drawer
        html += '<div id="footnote-drawer">';
        html +=     '<div class="overlay"></div>';
        html +=     '<div class="drawer">';
        html +=         '<div class="title">';
        html +=             '<div class="inner">';
        html +=                 '<h6>' + helperTitle + '</h6>';
        html +=                 '<div class="close"></div>';
        html +=             '</div>';
        html +=         '</div>';
        html +=         '<div class="content">' + helperText + '</div>';
        html +=     '</div>';
        html += '</div>';

        // Footer Javascript
        html += '<script>\n';
        html +=     'MFC.analytics = MFC.analytics || {};\n';
        html +=     'MFC.analytics.page = MFC.analytics.page || {};\n';
                        // !TODO! Why is listView on analytics.page.layout?
        html +=     'MFC.analytics.page.layout = "' + (listView == 'true' ? 'List' : 'Tile') + '";\n';
        html +=     'MFC.setPageTitle("' + title + '");\n';
        html +=     'MFC.listPage = MFC.listPage || {};';
        html +=     'MFC.listPage["' + this.content.id + '"] = {};';
        html +=     'MFC.listPage["' + this.content.id + '"].$element = $("div#list-content[data-list-id=' + this.content.id + ']");';
        html +=     'MFC.listPage["' + this.content.id + '"].offset = 0;';
        html +=     'MFC.listPage["' + this.content.id + '"].amountToRetrieve = ' + amountToLoad + ';';
        html +=     'MFC.listPage["' + this.content.id + '"].featuredId = "";';
        html +=     'MFC.listPage["' + this.content.id + '"].contentTypeId = "' + this.contentTypeId + '";';
        html +=     'MFC.listPage["' + this.content.id + '"].contentType = "' + this.contentType + '";';
        html +=     'MFC.listPage["' + this.content.id + '"].filter = "' + this.filter + '";';
//      html +=     'MFC.listPage["' + this.content.id + '"].allFilterIsLast = "' + this.allFilterIsLast + '";';                -- unused by JS
        html +=     'MFC.listPage["' + this.content.id + '"].sortOrder = "' + this.sortOrder + '";';
        html +=     'MFC.listPage["' + this.content.id + '"].parentTaxonomyNode = "' + this.parentTaxonomyNode + '";';
//      html +=     'MFC.listPage["' + this.content.id + '"].initialFilterChild = "' + this.initialFilterChild + '";';          -- unused by JS
        html +=     'MFC.listPage["' + this.content.id + '"].contentTemplate = "' + this.contentTemplate + '";';
        html +=     'MFC.listPage["' + this.content.id + '"].showFeatured = "' + this.showFeatured + '";';
        html +=     'MFC.listPage["' + this.content.id + '"].isLoadingMore = false;';
        html +=     'MFC.listPage["' + this.content.id + '"].requestNumber = 0;';
        html +=     'MFC.listPage["' + this.content.id + '"].useParentPath = ' + this.useParentPath + ';';
        html +=     'MFC.listPage["' + this.content.id + '"].siteMapPath = "' + this.siteMapPath + '";';
        html +=     'MFC.listPage["' + this.content.id + '"].hideTilesShareAction = Boolean(' + this.hideTilesShareAction + ');';
        html +=     'MFC.listPage["' + this.content.id + '"].hideTilesLikeAction = Boolean(' + this.hideTilesLikeAction + ');';
        html +=     'MFC.listPage["' + this.content.id + '"].listPageListLayout = Boolean(' + this.listView + ');';
        html +=     'MFC.listPage["' + this.content.id + '"].showPriorityMessages = Boolean(' + this.showPriorityMessages + ');';
        html +=     'MFC.listPage["' + this.content.id + '"].showMaxPriorityItems = ' + showMaxPriorityItemsInt +  ';';
        html +=     'MFC.listPage["' + this.content.id + '"].priorityIds = "";';
        html +=     'MFC.fListPageSetup("' + this.content.id + '");';
        html += '</script>';

        html += '</div>';

        return html;
    }

    public List<String> locationPaths;
    public List<String> getPathsForChildrenOfPath(String filterValue) {
        if (locationPaths == null) {
            locationPaths = ocms_mfc_Taxonomy.getPathsForChildrenOfPath(sApi, filterValue, true);
        }

        return locationPaths;
    }

    public String getPageRenderingsJSONResponse(
            String term,
            String contentType,
            String contentTypeId,
            String contentTemplate,
            String filter,
            String filterValue,
            String subMenuTag,
            String parentTaxonomyNode,
            String offset,
            String amountToRetrieve,
            String showFeatured,
            String featuredId,
            String requestNumber,
            String usingParentPath,
            String theSortOrder,
            String listPageListLayout,
            String showPriorityMessages,
            String showMaxPriorityItems,
            String priorityIds) {
        List<List<String>> pathLists = new List<List<String>>();

        //JB - CR6 - Jan 2017; added following:
        List<String> priorityIdList = String.isBlank(priorityIds) ? new List<String>() : (List<String>)JSON.deserialize(priorityIds,List<String>.class);

        Integer showMaxPriority;
        if (!String.isBlank(showMaxPriorityItems)){
             showMaxPriority = showMaxPriorityItems.isNumeric() ? Integer.valueOf(showMaxPriorityItems) : 0;
        } else {
            showMaxPriority = 0;
        }

        Integer reqNumber;
        if (!String.isBlank(requestNumber)) {
            reqNumber = requestNumber.isNumeric() ? Integer.valueOf(requestNumber) : 0;
        } else {
            reqNumber = 1;
        }
        //JB - CR6 - Jan 2017; added following:

        // If we are filtering by location add the location to the paths
        if (filter == 'location') {
            try {
                List<String> paths = (List<String>)JSON.deserialize(filterValue, List<String>.class);
                pathLists.add(paths);
            } catch(Exception e) {
                //return '{"success": false, "html": "Location taxonomy improperly setup"}';
            }
        } else {
            pathLists.add(mfcTaxonomy.getLocationPathList());
        }

        // If we are selected on all in the filter bar, retrieve all content tagged at all of the children of the parent taxonomy node
        // This only grabs content that is one level deeper
        List<String> categoryPaths = subMenuTag != null ? subMenuTag.split('/') : new List<String>();

        Integer categoryIndex = 0;
        for(String categoryPath : categoryPaths) {
            if (usingParentPath == 'true') {
                categoryPaths[categoryIndex] = '/' + parentTaxonomyNode;
            } else {
                categoryPaths[categoryIndex] = '/' + parentTaxonomyNode + '/' + categoryPath;
            }
            categoryIndex++;
        }

        System.debug ('category paths: ' + categoryPaths);
        String featuredPath = mfcTaxonomy.getFeaturedPath();
        categoryPaths.add(featuredPath);
        pathLists.add(categoryPaths);
        pathLists.add(mfcTaxonomy.getEmployeeTypePathListForUser());
        pathLists.add(mfcTaxonomy.getDivisionPathListForUser());

        System.debug(pathLists);

        // possible sort orders: 'level_priority_date', 'priority_date', 'date', 'publish_date', 'alpha'
        //         'date' => Original_Published_Start_Date__c DESC
        // 'publish_date' => Published_Start_Date__c          DESC
        // property sortOrder is in ('originalDate', 'latestDate' or 'priority_date'), as defined by our Edit page
        // the stored sort order for priority is the actual taxonomy sort order, so if that was selected, no change is needed.
        // JB - CR6 - Jan 2017 ; modified following:

        // due to STI-0000011094, the only faithful sort order is original publish date and latest publish date.
        // will manually perform priroity sorting later if it was requsted by user.
        String requestedSortOrder = theSortOrder;
        if (theSortOrder == 'latestDate'){
            theSortOrder = 'publish_date';
        } else {
            theSortOrder = 'date'; //original publish date.
        }

        System.debug('here we go.');
        System.debug(theSortOrder);

        System.debug(pathLists);
        List<String> taxonomyContentIds = mfcTaxonomy.getContentIdsForTaxonomies(
            pathLists,
            contentType,
            theSortOrder,
            null,
            null);

        System.debug(taxonomyContentIds);
        System.debug(theSortOrder);
        System.debug(pathLists);
        // If the search term is empty
        List<String> contentIds = new List<String>();
        if (String.isEmpty(term)) {
            contentIds = taxonomyContentIds;
        } else {
            Set<String> searchedIds = new Set<String>(sApi.searchContent(term, new Set<String>{contentTypeId}, 10000));

            for (String contentId : taxonomyContentIds) {
                if (searchedIds.contains(contentId)) {
                    contentIds.add(contentId);
                }
            }
        }

        System.debug(contentIds);

        Integer offsetInt = Integer.valueOf(offset);
        Integer amountToRetrieveInt = Integer.valueOf(amountToRetrieve);

        List<String> displayedContentIds = new List<String>();
        String response = '';
        Boolean haveFeatured = false;
        List<String> combinedIds = new List<String>();

        // The following is used for featured items on the home page or when using tiles.
        // If we are trying to show a featured item and we do not already have a featured item
        if (Boolean.valueOf(showFeatured) && String.isEmpty(featuredId)) {
            String dimension = featuredPath.removeStart('/').substringBetween('/','/');
            Set<String> matchingContentIdsSet = new Set<String> (contentIds);

            if (ocms_TaxonomyAPI.contentIdBuckets.containsKey(dimension)) {
                matchingContentIdsSet.retainAll(ocms_TaxonomyAPI.contentIdBuckets.get(dimension));
                System.debug(matchingContentIdsSet);
                if (matchingContentIdsSet.size() >= 0) {
                    haveFeatured = true;

                    for (String contentId : contentIds) {
                        System.debug(contentId);
                        if (matchingContentIdsSet.contains(contentId)) {
                            featuredId = contentId;
                            combinedIds.add(featuredId);
                            break;
                        }
                    }
                }
            }
        }

        // JB - CR6 - Jan 2017
        // the following is used to identify priority messages (typically CEO and Leadership messages
        // NOTE: If this is re-written at a future date, investigation should be perfomed to see if the current OrchestraCMS API has
        // a method to retrieve the content's priority meta-data rather than a driect query against the data model.
        //
        // On the initial request, build a list of priority IDs if the loader is configured to show them assuming there are any records at all
        // to show.
        if (Boolean.valueOf(showPriorityMessages) && contentIds.size()>0 && showMaxPriority > 0){
            //build list of priority Ids where priority > 0
            //NOTE: this is only checking published priority values.
            // need to check both priority and priority weight, as priority is always assigned, but weight is only >0
            // when user asssigns a priority other than none.
            Datetime nowDate = Datetime.now();
            String priorityIDQuery = 'SELECT Id ' +
                    'FROM cms__Content__c ' +
                    'WHERE Id IN:contentIds ' +
                    'AND cms__Priority__c > 0 AND cms__Priority_Weight__c > 0 ' +
                    'AND cms__Priority_End_Date__c > :nowDate ' +
                    'ORDER BY cms__Priority__c DESC NULLS LAST, cms__Original_Published_Start_Date__c DESC NULLS LAST LIMIT :showMaxPriority';
            List<cms__Content__c> priorityQueryResults = Database.query(priorityIdQuery);
            //build string set of Ids
            Set<String> priorityQueryResultsSet = new Set<String>();
            for (cms__Content__c item : priorityQueryResults){
                priorityQueryResultsSet.add(String.valueOf(item.id));
            }

            System.debug(priorityQueryResultsSet);

            // OrchestraCMS Story STI-0000011094 - ALL content has priority, MAY cause incorrect order when using priority_date from taxonomy call
            if (requestedSortOrder == 'priority_date') {
                //re-build the content id list to be in order - priority items first (by priority then original publish date), then non-priority items by original publish date.
                List<String> orderedContentIdsList = new List<String>(priorityQueryResultsSet);
//                System.debug('priorityQueryResults (list): ' + priorityQueryResults);
//                System.debug('priorityQueryResultsSet: ' + priorityQueryResultsSet);
//                System.debug('orderedContentIdsList: ' +orderedContentIdsList);
                //set.addAll from a list adds the items from the list in reverse ordeer; to maintain order, manually loop through list
                for (Integer i=0, j=contentIds.size(); i < j; i++){
                    //check priority set to see if content id present.  If not present, add to priority list
                    //orderedContentIdsList.add(contentIds[i]);
                    //System.debug('contenteIds [i]: ' +  contentIds[i]);
                    if (!priorityQueryResultsSet.contains(contentIds[i])){
                        orderedContentIdsList.add(contentIds[i]);
                    }
                }

//                System.debug('contentIds: ' + contentIds);
//                System.debug('orderedContentIdsList: ' + orderedContentIdsList);
                contentIds.clear();
                contentIds.addAll(orderedContentIdsList);
                System.debug(contentIds);
            }


            //ensure we're creating a new list.
            priorityIdList.clear();
            //build list of priority Ids to send with response - limit to number of priority msgs to show (max)
            for (Integer i = 0, j=contentIds.size(); i < showMaxPriority && i < j; i++ ){
                if (priorityQueryResultsSet.contains(contentIds[i])){
                    priorityIdList.add(contentIds[i]);
                }
            }
            //System.debug(priorityIdList);
        } // End JB - CR6 - Jan 2017 - priority determination/processing.

        // We are doing manual pagination here, given the returned id's only return content from the offset + the amount to retrieve
        for (Integer idCounter = offsetInt; idCounter < contentIds.Size() && idCounter < offsetInt + amountToRetrieveInt; idCounter++) {
            if (featuredId == contentIds[idCounter]) {
                offsetInt++;
            } else {
                displayedContentIds.add(contentIds[idCounter]);
            }
        }

        combinedIds.addAll(displayedContentIds);
        Map<Id, String> contentRenderings = new Map<Id, String>();

        System.debug(combinedIds);
        System.debug(contentTemplate);

        // Render content
        if (combinedIds.size() > 0) {
            contentRenderings = taxonomyApi.getLatestContentRenderingsForOriginContents(combinedIds, contentTemplate);
        }

        System.debug(contentRenderings);

        // Add Featured as first image, but only if in grid view.
        //if (this.listView == 'false' && haveFeatured && String.isNotEmpty(featuredId) && contentRenderings.containsKey(featuredId)) {
        //System.debug('this.listView? ' + this.listView);
        //System.debug('have featured? ' + haveFeatured);
        //System.debug('featuredIsList size: ' + featureIdList.size());
        //System.debug('content renderings contains key? ' + contentRenderings.containsKey(featureIdList[0]));
        if (listPageListLayout == 'false' && haveFeatured && String.isNotEmpty(featuredId) && contentRenderings.containsKey(featuredId)) {
            // We need to get all the attributes for the carousel images since they are stored in an attrubite called listPageRotatorImage;
            String attributeQuery = 'SELECT cms__Content__c, cms__Value__c ' +
                                                    'FROM cms__Attribute__c ' +
                                                    'WHERE cms__Content__c = :featuredId AND cms__Simple_Name__c = \'listPageRotatorImage\'';

            List<cms__Attribute__c> attributes = Database.query(attributeQuery);
            String listPageRotatorImage = '';

            if (!attributes.isEmpty()) {
                listPageRotatorImage = ocms_mfc_utility.getSiteURLForMedia(attributes[0].cms__Value__c);
            }

            if (String.isNotEmpty(listPageRotatorImage)) {
                String regEx = 'img class="imageIcon" src="[^"]*"';
                String regEx2 = 'img class="thumbnail" src="[^"]*"';
                // This logic is very depedant on having only the imageIcon or thumbnail class on the img of the article.
                // If any other class is present this code will break. - Not Tyson
                response += contentRenderings.get(featuredId).replaceAll(regEx, 'img class="carouselImage" src="' + listPageRotatorImage + '"').replaceAll(regEx2, 'img class="carouselImage" src="' + listPageRotatorImage + '"');
            } else {
                response += contentRenderings.get(featuredId);
            }

            contentRenderings.remove(featuredId);
        }

        for (String contentId : displayedContentIds) {
            if (contentRenderings.containsKey(contentId)) {
                response += contentRenderings.get(contentId);
            }
        }

        return '{"success": true, "totalAmount": ' + contentIds.size() + ', "retrievedAmount": ' + contentRenderings.size() + ', "offset": ' + (offsetInt + contentRenderings.size()) + ' ,"featuredId": "' + featuredId + '", "html": ' + JSON.Serialize(response) + ', "requestNumber": ' + requestNumber + ' ,"priorityIds": '+ JSON.serialize(priorityIdList) + '}';
    }

    public String getLocationDropDown(cms.TaxonomyNodeInfo taxonomyNode) {
        String nodeName = '';
        String nodeParentPath = '';

        if (taxonomyNode != null) {
            nodeName = taxonomyNode.getName();
            nodeParentPath = taxonomyNode.getParentPath();
        }

        String tagValue = nodeParentPath + '/' + nodeName;

        String response = '<li class="item num-Item">' + '<a href="#" data-mfc-name="' + nodeName + '" data-mfc-value="' + tagValue + '">' + nodeName + '</a>';
        response += '<div class="arrow"></div>';

        if (taxonomyNode != null && taxonomyNode.hasChildren()) {
            response += '<ul>';

            for(cms.TaxonomyNodeInfo taxonomyRootNodeChild : taxonomyNode.getChildren()) {
                response += getLocationDropDown(taxonomyRootNodeChild);
            }

            response += '</ul>';
        }

        response += '</li>';

        return response;
    }
}