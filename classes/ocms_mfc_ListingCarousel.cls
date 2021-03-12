global with sharing class ocms_mfc_ListingCarousel extends cms.ContentTemplateController implements cms.ServiceInterface {

    global ocms_mfc_ListingCarousel () {}

    global ocms_mfc_ListingCarousel (cms.GenerateContent gc) {
        super(gc);
    }

    global ocms_mfc_ListingCarousel (cms.CreateContentController cc) {
        super(cc);
    }

    public System.Type getType(){
        return ocms_mfc_ListingCarousel.class;
    }

    private cms.ServiceAPI sAPI {
        get {
            if (sApi == null) {
                sApi = getServiceAPI();
            }

            return sApi;
        } set;
    }

    private ocms_TaxonomyAPI taxonomyApi {
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

    public String category {
        get {
            return getProperty('category');
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

    public String MilkContentTemplate {
        get {
            return 'Milk Article';
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
    

    global String executeRequest (Map <String, String> params) {
        String response = '{"success" : false, "message" : "Action not supported."}';

        if (params.containsKey('action')) {
            String action = params.get('action');
            
            if (action == 'getMILKContent') {
                String markup = '';
                String comma = '';
    
                List<List<String>> pathLists = new List<List<String>>();
    
                List<String> categoryPaths = new List<String>();
    
                for (String categoryPath : (List<String>) JSON.deserialize(params.get('categoryPaths'), List<String>.class)) {
                    categoryPaths.add('/' + categoryPath);
                }
    
                if (!categoryPaths.isEmpty()) {
                    pathLists.add(categoryPaths);
                }
    
                List<String> contentIds = mfcTaxonomy.getContentIdsForTaxonomies(pathLists, params.get('contentType'), 'date', null, null);
                List<String> smallerList = new List<String>();
    
                for (Integer i = 0; i < contentIds.size(); i++) {
                    smallerList.add(contentIds[i]);
                }
    
                Map<Id, String> renderingMap = taxonomyApi.getLatestContentRenderingsForOriginContents(smallerList, MilkContentTemplate );
                Boolean hasRenderings = false;
    
                for(String contentId : smallerList) {
                    if (renderingMap.containsKey(contentId)) {
                        markup += comma + renderingMap.get(contentId);
                        hasRenderings = true;
                        comma = ',';
                    }
                }
    
    
                response = '{"success" : true, "markup" : ' + JSON.serialize(renderingMap)  + ', "hasRenderings" : ' + hasRenderings + ', "debug": ' + JSON.serialize(pathLists) + '}';
            }

            if (action == 'getListingCarouselResponse') {
                String markup = '';

                List<List<String>> pathLists = new List<List<String>>();

                List<String> categoryPaths = new List<String>();

                for (String categoryPath : (List<String>) JSON.deserialize(params.get('categoryPaths'), List<String>.class)) {
                    categoryPaths.add('/' + categoryPath);
                }

                if (!categoryPaths.isEmpty()) {
                    pathLists.add(categoryPaths);
                }

                pathLists.add(mfcTaxonomy.getLocationPathList());
                pathLists.add(mfcTaxonomy.getDivisionPathListForUser());
                pathLists.add(mfcTaxonomy.getEmployeeTypePathListForUser());

                List<String> contentIds = mfcTaxonomy.getContentIdsForTaxonomies(pathLists, params.get('contentType'), 'date', null, null);
                List<String> smallerList = new List<String>();

                for (Integer i = 0; i < contentIds.size(); i++) {
                    smallerList.add(contentIds[i]);
                }

                Map<Id, String> renderingMap = taxonomyApi.getLatestContentRenderingsForOriginContents(smallerList, contentTemplate);
                Boolean hasRenderings = false;

                for(String contentId : smallerList) {
                    if (renderingMap.containsKey(contentId)) {
                        markup += renderingMap.get(contentId);
                        hasRenderings = true;
                    }
                }

                // Analytics for CEO message on Leadership Message page
                if (params.containsKey('contentType')) {
                    string contentType = params.get('contentType');
                    if (contentType == 'CEOMessage') {
                        markup += '<script>\n';
                        markup += '$(".listing.categorize.ocmsCI").each(function(index) {\n';
                        markup += '$(this).click(function(){\n';
                        markup += 'clickTracking("CEO_Message", $(this).find(".info-wrapper .info-header h3").html(), $(this).find(".list-wrapper a.link-overlay").attr("href"))\n';
                        markup += '});\n';
                        markup += '$(this).contextmenu(function(){\n';
                        markup += 'clickTracking("CEO_Message", $(this).find(".info-wrapper .info-header h3").html(), $(this).find(".list-wrapper a.link-overlay").attr("href"))\n';
                        markup += '});\n';
                        markup += '});\n';
                        markup += '</script>\n';
                    } else if (contentType == 'MFC Article') {
                        if (params.containsKey('categoryPaths')){
                            List<String> allCatPath = (List<String>) JSON.deserialize(params.get('categoryPaths'), List<String>.class);
                            if (allCatPath != null && allCatPath.size() > 0) {
                                for (String eachString : allCatPath) {
                                    if (eachString.indexof('Leadership Messages') > 0) {
                                        markup += '<script>\n';
                                        markup += 'if (window.location.search.indexOf("Leadership") > 0){\n';
                                        markup += '$(".listing.categorize.ocmsCI").each(function(index) {\n';
                                        markup += 'var existingEvents = $._data($(this)[0], "events")\n';
                                        markup += 'if (!(existingEvents !== undefined && existingEvents.click !== undefined)){\n';
                                        markup += '$(this).click(function(){\n';
                                        markup += 'clickTracking("Leadership_MSG", $(this).find(".info-wrapper .info-header h3").html(), $(this).find(".list-wrapper a.link-overlay").attr("href"))\n';
                                        markup += '});\n';
                                        markup += '}\n'; // if (!( existingEvents...
                                        markup += 'if (!(existingEvents !== undefined && existingEvents.contextmenu !== undefined)){\n';
                                        markup += '$(this).contextmenu(function(){\n';
                                        markup += 'clickTracking("Leadership_MSG", $(this).find(".info-wrapper .info-header h3").html(), $(this).find(".list-wrapper a.link-overlay").attr("href"))\n';
                                        markup += '});\n';
                                        markup += '}\n'; // if (!( existingEvents...
                                        markup += '});\n'; //each
                                        markup += '}\n'; // if (window.location.search. ...
                                        markup += '</script>\n';
                                    }
                                }
                            }
                        }
                    }
                }
                response = '{"success" : true, "markup" : ' + JSON.serialize(markup)  + ', "hasRenderings" : ' + hasRenderings + '}';
            }
        }

        return response;
    }

    global override String getHTML () {
        String html = '';
        
        html += '<div class="listing-container" Id="' + content.Id + '">';
        html +=   '<div class="arrow arrow-r hideSelector"></div>';
        html +=   '<div class="arrow arrow-l hideSelector"></div>';
        html +=   '<div class="carousel inner">';
        html +=       '<div class="listing-wrapper"></div>';
        html +=   '</div>';
        html +=   '<div class="clear"></div>';
        html += '</div>';

        /**
         * When OrchestraCMS generates their cache they are looking for /" inside their generator and seem to replace
         * that markup with the site prefix. This is bad when we have a full qualified taxonoy path such as /Taxonomy/Root1/Child1/
         * We need to remove the / at the beggining during generation so it doesn't impact the code.
         */
        // Orchestra generation bug work around - begin

        List<String> categoryPaths = new List<String>();

        for (String path : ocms_mfc_Taxonomy.getPathsForImmediateChildrenOfPath(sApi, category, true)) {
            categoryPaths.add(path.removeStart('/'));
        }

        // Orchestra generation bug work around - end
        
        html += '<script>';
        html +=     'MFC.listCarousel = MFC.listCarousel || {};';
        html +=     'MFC.listCarousel["' + content.Id + '"] = {};';
        html +=     'MFC.listCarousel["' + content.Id + '"].categoryPaths = ' + JSON.serialize(categoryPaths) + ';';
        html +=     'MFC.listCarousel["' + content.Id + '"].contentType = "' + contentType + '";';
        html +=     'MFC.listCarousel["' + this.content.id + '"].hideTilesShareAction = Boolean(' + this.hideTilesShareAction + ');';
        html +=     'MFC.listCarousel["' + this.content.id + '"].hideTilesLikeAction = Boolean(' + this.hideTilesLikeAction + ');';
        
        html +=     'MFC.fListingCarouselSetup("' + content.Id + '");';
        html += '</script>';

        return html;
    }
}