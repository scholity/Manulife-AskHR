global with sharing virtual class ocms_mfc_NewsStream extends ocms_ps_Content implements cms.ServiceInterface {

    global ocms_mfc_NewsStream() {
    }
    global ocms_mfc_NewsStream(cms.GenerateContent gc) {
        super(gc);
    }
    global ocms_mfc_NewsStream(cms.CreateContentController cc) {
        super(cc);
    }

    public String contentType = 'News,CEOMessage,ExecutiveMessage,PollVote';

    public System.Type getType() {
        return ocms_mfc_NewsStream.class;
    }

    public String newsTileContentLayout { get {return 'NewsTile';} set; }
    public String pollVoteContentLayout { get {return 'PollVote';} set; }

    public String loadAmount { get {return getProperty('loadAmount');} set; }
    public String carouselNewsLimit { get {return getProperty('carouselNewsLimit');} set; }
    public String carouselPriorityLimit { get {return getProperty('carouselPriorityLimit');} set; }

    public string myNewsText { get {return getProperty('myNewsText') != null ? getProperty('myNewsText') : '';} set; }
    public string allText { get {return getProperty('allText') != null ? getProperty('allText') : '';} set; }

    public string iconTooltipChangeLayout { get {return getProperty('iconTooltipChangeLayout') != null ? getProperty('iconTooltipChangeLayout') : '';} set; }
    public string iconTooltipPreferences { get {return getProperty('iconTooltipPreferences') != null ? getProperty('iconTooltipPreferences') : '';} set; }

    public string filterText { get {return getProperty('filterText') != null ? getProperty('filterText') : '';} set; }

    public String image { get {return getProperty('image');} set; }
    public String listViewImage { get {return getProperty('listViewImage');} set; }
    public String imageText { get {return getProperty('imageText') != null ? getProperty('imageText') : '';} set; }
    public String imageLink { get {return this.getProperty('imageLink');} set; }

    public String initialLayoutAsList { get {return this.getProperty('initialLayoutAsList');} set; }

    public String leaderName1 { get {return getProperty('leaderName1');} set; }
    public String leaderName2 { get {return getProperty('leaderName2');} set; }
    public String leaderName3 { get {return getProperty('leaderName3');} set; }
    public String leaderTitle1 { get {return getProperty('leaderTitle1');} set; }
    public String leaderTitle2 { get {return getProperty('leaderTitle2');} set; }
    public String leaderTitle3 { get {return getProperty('leaderTitle3');} set; }
    public String leaderLink1 { get {return getProperty('leaderLink1');} set; }
    public String leaderLink2 { get {return getProperty('leaderLink2');} set; }
    public String leaderLink3 { get {return getProperty('leaderLink3');} set; }
    public String isListedCEOTile { get {return getProperty('isListedCEOTile');} set; }
    public String listedCEOTileColor { get {return getProperty('listedCEOTileColor');} set; }
    public String listedCEOTileFontColor { get {return getProperty('listedCEOTileFontColor');} set; }
    public String newFromLabel { get {return getProperty('newFromLabel');} set; }
    public String ceoCategoryLabel { get {return getProperty('ceoCategoryLabel');} set; }
    public String viewAllLeaderMsgLabel { get {return getProperty('viewAllLeaderMsgLabel');} set; }
    public String viewAllLeaderMsgLabelLink { get {return getProperty('viewAllLeaderMsgLabelLink');} set; }


    public cms.ServiceAPI sAPI {
        get {
            if (sApi == null) {
                sApi = getServiceAPI();
            }
            return sApi;
        }
        set;
    }

    public ocms_TaxonomyAPI taxonomyApi {
        get {
            if (taxonomyApi == null) {
                taxonomyApi = new ocms_TaxonomyAPI(sApi);
            }
            return taxonomyApi;
        }
        set;
    }

    public ocms_mfc_Taxonomy mfcTaxonomy {
        get {
            if (mfcTaxonomy == null) {
                mfcTaxonomy = new ocms_mfc_Taxonomy(sApi);
            }
            return mfcTaxonomy;
        }
        set;
    }

    public Map<String, String> sitePreferences {
        get {
            if (sitePreferences == null) {
                sitePreferences = ocms_mfc_SitePreferences.getSitePreferences(pm, getServiceAPI().getRenderLanguage());
            }
            return sitePreferences;
        }
        set;
    }

    global String executeRequest(Map <String, String> request) {
        String response = '{"success":false,"message":"Action not supported."}';

        if (request.containsKey('action')) {
            String action = request.get('action');

            if (action == 'getContentRenderings') {
                response = getContentRenderingsJSONResponse(
                        request.get('filter'),
                        request.get('filterValue'), request.get('offset'),
                        request.get('amountToRetrieve'), request.get('carouselNewsLimit'),
                        request.get('carouselPriorityLimit'), request.get('carouselIds'),
                        request.get('allNewsPaths'), request.get('userNewsPaths'), request.get('requestNumber'),
                        request.get('subscriptionChanged'), request.get('prevRenderLangCode'));
            } else if (action == 'getAllNewsPaths') {
                response = getAllNewsPathsJSONResponse();
            }
        }

        return response;
    }

    public override String getHTML() {
        Integer amountToLoad = 12;
        try {
            if (Integer.valueOf(loadAmount) < 0) {
                amountToLoad = 0;
            }
        } catch (Exception e) {
        }

        String html = '';
        html += '<div class="controls">';
        html += '<div class="global-content-filter">';
        html += '<div class="title">';
        html += filterText + ' ';
        html += '<span class="selected-filter">';
        html += myNewsText;
        html += '</span>';
        html += '<div class="arrow"></div>';
        html += '</div>';//Title
        html += '<ul>';
        html += getFilterBarHtml();
        html += '</ul>';
        html += '</div>';//global-content-filter
        html += '<div class="clear"></div>';
        html += '</div>';//controls
        html += '<div class="tile-block" id="dashboard-tile-block">';
        html += '<div class="inner"></div>';
        html += '<div class="inner"></div>';
        html += '</div>';//tile-block dashboard-tile-block
        html += '<a class="global-show-more clear loading">';
        html += '<span>' + sitePreferences.get('uiLabelShowMore') + '</span>';
        html += '<img src="' + ocms_mfc_Utility.getResourceURL('ocms_mfc_siteFiles') + '/img/global-show-more-sm.gif"/>';// This is doing a query
        html += '</a>';

        html += '<script>';
        html += 'MFC.newsStream = MFC.newsStream || {};';
        html += 'MFC.newsStream.allNewsPaths = "replaceMe' + getAllNewsPaths() + '";\n';
        html += 'MFC.newsStream.carouselNewsLimit = ' + carouselNewsLimit + ';\n';
        html += 'MFC.newsStream.carouselPriorityLimit = ' + carouselPriorityLimit + ';\n';
        html += 'MFC.newsStream.showMoreButton = $("#news-container .global-show-more");\n';
        html += 'MFC.newsStream.offset = 0;\n';
        html += 'MFC.newsStream.amountToRetrieve = ' + amountToLoad + ';\n';
        html += 'MFC.newsStream.loadingMore = false;\n';
        html += 'MFC.newsStream.topLocation = $("#dashboard-tile-block > .inner:nth-child(1)");\n';
        html += 'MFC.newsStream.bottomLocation = $("#dashboard-tile-block > .inner:nth-child(2)");\n';
        html += 'MFC.newsStream.carouselIds = "";\n';
        html += 'MFC.newsStream.CEOTile= \'' + getCEOTileHTML() + '\';\n';
        html += 'MFC.newsStream.prevRenderLangCode = "' + getServiceAPI().getRenderLanguage() + '";';
        html += 'MFC.analytics = MFC.analytics || {};\n';
        html += 'MFC.analytics.page = MFC.analytics.page || {};\n';
        html += 'MFC.analytics.page.layout = "Tile";\n';

        html += 'MFC.fNewsStreamSetup(' + initialLayoutAsList + ');\n';
        html += 'MFC.fNewsStreamLoadContent(0, MFC.newsStream["amountToRetrieve"]);\n';
        // click tracking on news facets
        html += '$(".global-content-filter ul li").each(function(){ $(this).click(function(){clickTracking("news facets", $(this).find("a").html());})});\n';
        html += '</script>';

        return html;
    }

    /**
     * @description - Get the filter bar html
     * @return String - Html
     */
    public virtual String getFilterBarHtml() {
        String html = '';
        html += '<li><a href="#" class="selected" data-mfc-filter="My News" data-mfc-value="My News">' + myNewsText + '</a></li>';
        html += '<li><a href="#" data-mfc-filter="All" data-mfc-value="All">' + allText + '</a></li>';
        return html;
    }

    /**
     * @description - Get the carousel html and puts the renderings given inside of it
     * @param renderingsToShow - List<String> rendered content to display in the carousel
     * @return String - Html
     */
    public virtual String getCarouselHtml(Map<String, String> renderingsToShow, Map<String, String> carouselImageRotators) {
        String html = '';

        html += '<div class = "tile type-news-carousel">';
        html += '<div class = "inner">';
        html += '<div class = "carousel" id = "news-carousel">';
        html += '<div class = "inner">';

        String dotClassHTML = '';
        Boolean isFirst = true;

        for (String contentId : renderingsToShow.keySet()) {
            String rendering = renderingsToShow.get(contentId);

            String carouselImage = carouselImageRotators.get(contentId);

            if (String.isNotBlank(carouselImage)) {
                String regEx = 'img class="imageIcon" src="[^"]*"';
                html += rendering.replaceAll(regEx, 'img class="imageIcon carouselImage" src="' + carouselImage + '"');
            } else {
                html += rendering;
            }

            dotClassHTML += '<div class="dot' + (isFirst ? ' selected' : '') + '" style="cursor: pointer;"></div>';
            isFirst = false;
        }

        html += '</div>';

        if (renderingsToShow.size() > 1) {
            html += '<div class = "arrow arrow-r"></div>';
            html += '<div class = "arrow arrow-l"></div>';
        }

        html += '<div class = "dots">';
        html += dotClassHTML;
        html += '</div>';
        html += '</div>';
        html += '</div>';
        html += '</div>';

        return html;
    }

    public String getCEOTileHTML() {
        String html = '';

        if (isListedCEOTile != null && isListedCEOTile.equals('checked')) { // Listed CEO tile
            html += '<div class="tile type-message fixedH listedCEOMessage">';
            html += '<div class="inner" style="background:' + listedCEOTileColor + '; color: ' + listedCEOTileFontColor + ';">';
            html += '<div class="content">';
            html += '<div class="v-align">';
            html += '<div class="inner" style="color:' + listedCEOTileFontColor + ';">';
            html += '<p id="newFromLabel">' + newFromLabel + '</p>';
            html += genListedCEORow(new cms.Link(leaderLink1), leaderName1, leaderTitle1);
            html += genListedCEORow(new cms.Link(leaderLink2), leaderName2, leaderTitle2);
            html += genListedCEORow(new cms.Link(leaderLink3), leaderName3, leaderTitle3);
            html += '</div>';
            html += '</div>';
            html += '</div>';
            html += '<div class="news-category">' + ceoCategoryLabel + '</div>';
            html += '<div class="link-footer">';
            html += '<a href="' + new cms.Link(viewAllLeaderMsgLabelLink).targetPage + '" target="_blank">' + viewAllLeaderMsgLabel + '</a>';
            html += '</div>';
            html += '</div>';
            html += '</div>';
        } else { // Image CEO tile
            String urlForLink = new cms.Link(imageLink).targetPage;
            if (urlForLink != null && urlForLink.indexOf('&lpos') > -1)
                urlForLink = urlForLink.substring(0, urlForLink.indexOf('&lpos'));

            html += '<div class="tile type-message fixedH LatestCEOMessage">';
            html += '<div class="inner">';

            if (new cms.Link(imageLink).target == '_blank')
                html += '<a href="' + urlForLink + '" target="_blank">'; else
                    html += '<a href="' + urlForLink + '">';

            html += '<div class="content">';
            html += '<div class="v-align">';
            html += '<div class="inner">';
            html += '<h3 class="title">' + imageText + '</h3>';
            html += '<p class="description"></p>';
            html += '</div>';
            html += '</div>';
            html += '</div>';
            html += '</a>';
            html += '<div class="bg">';
            html += '<img class="grid-image" src="' + getSiteURLForMedia(image) + '"/>';

            if (listViewImage != null && listViewImage != 'null')
                html += '<img class="list-image" src="' + getSiteURLForMedia(listViewImage) + '"/>';

            html += '<div class="shadow"></div>';
            html += '</div>';
            html += '<div class="news-category"></div>';
            html += '</div>';
            html += '</div>';
        }

        /*
        html += '<script>\n';
        html += '$(".LatestCEOMessage a .content").click(function(){clickTracking("homePage", "CEO_message", $(".LatestCEOMessage a").attr("href"))});\n';
        html += '$(".LatestCEOMessage a .content").contextmenu(function(){clickTracking("homePage", "CEO_message", $(".LatestCEOMessage a").attr("href"))});\n';
        html += '</script>\n';*/

        return html;
    }
    private String genListedCEORow(cms.Link leaderLink, String leaderName, String leaderTitle) {
        String html = '';
        String target = leaderLink.target == null ? '' : leaderLink.target;

        html += '<div class="leaderRow">';
        html += '<h3 class="leaderName">';
        html += '<a style="color:' + listedCEOTileFontColor + ';" href="' + leaderLink.targetPage + '" target="' + target + '">';
        html += leaderName == null ? '' : leaderName.escapeHtml4();
        html += '</a>';
        html += '</h3>';
        html += '<p class="leaderTitle">' + leaderTitle + '</p>';
        html += '</div>';
        return html;
    }

    /**
     * @description - gets renderings for the NewsStream page
     * @param filter - String filter to be used, check getFilteredContentIds function to see options
     * @param filterValue - String filterValue
     * @param offsetString - the offset
     * @param retrieveAmountString - the amount of content to retrieve
     * @return String - JSON String with these properties {success, totalAmount, retrievedAmount, html}
     */
    public String getContentRenderingsJSONResponse(String filter, String filterValue, String offsetString, String retrieveAmountString, String carouselNewsLimitString, String carouselPriorityLimitString, String carouselIdsString, String allNewsPaths, String userNewsPaths, String requestNumber, String subscriptionChanged, String prevRenderLangCode) {
        List<String> previousCarouselIds = new List<String>();

        if (carouselIdsString != null) {
            previousCarouselIds = carouselIdsString.split(',');
        }

        String cacheKey = filter;

        if (filter == 'My News') {
            cacheKey = 'MyNews';
        }

        Integer carouselPriorityLimitInteger = Integer.valueOf(carouselPriorityLimitString);
        Integer carouselNewsLimitInteger = Integer.valueOf(carouselNewsLimitString);
        Integer retrieveAmount = Integer.valueOf(retrieveAmountString);
        Integer offset = Integer.valueOf(offsetString);
        Boolean retrieveCarousel = offset == 0;
        String renderingHtml = '', featuredPath = mfcTaxonomy.getFeaturedPath();
        String renderLangCode = getServiceAPI().getRenderLanguage();

        //JB - P0001 - Refresh caches if language changes.
        if (renderLangCode != prevRenderLangCode) {
            CacheController.regenCache = true;
        }

        // Get the content ids based on the category we have selected.
        List<String> filteredContentIds = getFilteredContentIds(filter, filterValue, allNewsPaths, featuredPath);

        // Content Types that can go inside the carousel
        List<String> contentTypes = new List<String>{
                'CEOMessage', 'ExecutiveMessage'
        };

        List<String> combinedContentIds = new List<String>();
        List<String> carouselContentIds = new List<String>();

        Map<String, String> carouselImageRotators = new Map<String, String>();

        if (CacheController.regenCache) {
            // The Carousel has a set limit of "News" and "CEO Messages" that can be in the carousel
            // We need to know what each of our id's is so we can put the right amount of News or CEO Messages in the carousel.
            if (retrieveCarousel) {
                DateTime currentDate = DateTime.now();

                List<String> featuredContentIds = getContentIdsWithMatchingPath(filteredContentIds, featuredPath);

                String newsContentsQuery = 'SELECT Id, cms__Content_Type__r.cms__Name__c ' +
                        'FROM cms__Content__c ' +
                        'WHERE Id IN :featuredContentIds ' +
                        'AND cms__Content_Type__r.cms__Name__c = \'News\' ' +
                        'ORDER BY cms__Published_Start_Date__c DESC ' +
                        'LIMIT :carouselNewsLimitInteger';

                String ceoContentsQuery = 'SELECT Id, cms__Content_Type__r.cms__Name__c ' +
                        'FROM cms__Content__c ' +
                        'WHERE Id IN :featuredContentIds ' +
                        'AND cms__Content_Type__r.cms__Name__c IN :contentTypes ' +
                        'AND cms__Priority_End_Date__c > :currentDate ' +
                        'AND cms__Priority_Weight__c != NULL ' +
                        'ORDER BY cms__Priority_Weight__c ASC, cms__Published_Start_Date__c DESC ' +
                        'LIMIT :carouselPriorityLimitInteger';

                List<cms__Content__c> carouselNewsContents = Database.query(newsContentsQuery);
                List<cms__Content__c> carouselCEOContents = Database.query(ceoContentsQuery);

                // We need to get all the attributes for the carousel images since they are stored in an attrubite called newsStreamRotatorImage;
                // DEFECT P0001 - Image needs to be language specific.
                //JB - P0001 - Query for rotator image; qualify by current render language.
                String renderLang = getServiceAPI().getRenderLanguage();
                String attributeQuery = 'SELECT cms__Content__c, cms__Value__c ' +
                        'FROM cms__Attribute__c ' +
                        'WHERE (cms__Content__c IN :carouselNewsContents OR cms__Content__c IN :carouselCEOContents) AND cms__Simple_Name__c = \'newsStreamRotatorImage\' AND cms__Language__r.cms__Language_Code__c = :renderLang';

                for (cms__Attribute__c attr : Database.query(attributeQuery)) {
                    carouselImageRotators.put(attr.cms__Content__c, ocms_mfc_utility.getSiteURLForMedia(attr.cms__Value__c));
                }

                for (cms__Content__c content : carouselCEOContents) {
                    carouselContentIds.add(content.Id);
                    combinedContentIds.add(content.Id);
                }

                for (cms__Content__c content : carouselNewsContents) {
                    carouselContentIds.add(content.Id);
                    combinedContentIds.add(content.Id);
                }

                System.debug('generating content');

                CacheController.setNewsStreamKey(cacheKey + 'combinedContentIds', JSON.serialize(combinedContentIds));
                CacheController.setNewsStreamKey(cacheKey + 'carouselContentIds', JSON.serialize(carouselContentIds));
                CacheController.setNewsStreamKey(cacheKey + 'carouselImageRotators', JSON.serialize(carouselImageRotators));
            } else {
                carouselContentIds = previousCarouselIds;
            }
        } else {
            System.debug('getting cached content for cache key : ' + cacheKey);

            carouselImageRotators = (Map<String, String>) JSON.deserialize(CacheController.getNewsStreamKey(cacheKey + 'carouselImageRotators'), Map<String, String>.class);
            combinedContentIds = (List<String>) JSON.deserialize(CacheController.getNewsStreamKey(cacheKey + 'combinedContentIds'), List<String>.class);
            carouselContentIds = (List<String>) JSON.deserialize(CacheController.getNewsStreamKey(cacheKey + 'carouselContentIds'), List<String>.class);
        }

        List<String> newsStreamContentIds = new List<String>();
        Set<String> carouselContentIdsSet = new Set<String>(carouselContentIds);

        // Pagination - Start at the offset and get as many as the retrieveAmount
        // This ignores items in the carousel, the feed should always have the same amount of items regardless of carousel size.
        for (Integer i = offset; i < filteredContentIds.size() && i < retrieveAmount + offset; i++) {
            if (carouselContentIdsSet.contains(filteredContentIds[i]))
                offset++; else
                    newsStreamContentIds.add(filteredContentIds[i]);
        }

        offset += newsStreamContentIds.size();
        combinedContentIds.addAll(newsStreamContentIds);

        // Render all content (Carousel and News Stream)
        Map<Id, String> contentRenderings = getRenderingsForContentIds(combinedContentIds);
        Map<String, String> carouselRenderings = new Map<String, String>();

        for (String contentId : carouselContentIds) {
            if (contentRenderings.containsKey(contentId))
                carouselRenderings.put(contentId, contentRenderings.get(contentId));
        }

        // Grabs carousel renderings and the image, This should only happen on first load for the category.
        String topRenderings = '';
        if (retrieveCarousel)
            topRenderings += getCarouselHtml(carouselRenderings, carouselImageRotators);

        for (String contentId : newsStreamContentIds) {
            if (contentRenderings.containsKey(contentId)) {
                renderingHtml += contentRenderings.get(contentId);
            }
        }
        //JB - P0001 - update json returned to track previous render language.
        return '{"success": true, "carouselIds": "' + String.join(carouselContentIds, ',') + '", ' +
                '"totalAmount": ' + (filteredContentIds.Size() - carouselContentIds.size()) +
                ', "offset": ' + offset + ', "retrievedAmount": ' + newsStreamContentIds.size() +
                ', "html": ' + JSON.Serialize(renderingHtml) + ', "topHtml": ' + JSON.serialize(topRenderings) +
                ', "requestNumber": ' + requestNumber + ', "prevRenderLangCode" : "' + renderLangCode + '"}';
    }

    /**
     * @description - Gets a list of contentIds filtered by the given filter and filterValue.
     * @param filter - String filter
     * @param filterValue - String filterValue, things to filter by
     * @param allNewsPaths - All the news paths - Used for All
     * @param userNewsPaths - User Subscriptions - Used for My News filter
     * @param featuredPath - The featured path
     * @return List<String> - List of contentIds
     */
    public List<String> getFilteredContentIds(String filter, String filterValue, String allNewsPaths, String featuredPath) {
        List<List<String>> pathList = new List<List<String>>();

        String cacheKey = filter;

        if (filter == 'My News') {
            pathList.add(mfcTaxonomy.getLocationPathList());
            pathList.add(mfcTaxonomy.getEmployeeTypePathListForUser());
            pathList.add(mfcTaxonomy.getDivisionPathListForUser());
            //pathList.add(userNewsPaths.split(';;;'));
            pathList.add(allNewsPaths.split(';;;'));

            cacheKey = 'MyNews';
        } else if (filter == 'All') {
            pathList.add(allNewsPaths.split(';;;'));
        } else {
            pathList.add(new List<String>());
        }

        pathList[0].add(featuredPath);

        List<String> filteredContentIds = new List<String>();

        try {
            if (cacheKey != 'Popular' && !CacheController.regenCache && CacheController.hasNewsStreamKey(cacheKey)) {
                filteredContentIds = (List<String>) JSON.deserialize(CacheController.getNewsStreamKey(cacheKey), List<String>.class);
            } else {
                filteredContentIds = taxonomyApi.getContentIdsFromMultiplePathLists(pathList, this.contentType, 'date', null, null);

                if (cacheKey != 'Popular') {
                    CacheController.setNewsStreamKey(cacheKey, JSON.serialize(filteredContentIds));
                    CacheController.updateLastSeen();
                }

                CacheController.regenCache = true;
            }
        } catch (Exception e) {
            // If we run into any errors getting the cache lets generate it manually.
            System.debug('Error getting filter content from cache at line number ' + e.getLineNumber() + ' error messsage is : ' + e.getMessage());
            System.debug(e);
            System.debug(e.getStackTraceString());
            filteredContentIds = taxonomyApi.getContentIdsFromMultiplePathLists(pathList, this.contentType, 'date', null, null);
        }
        return filteredContentIds;
    }


    public ocms_mfc_PlatformCache CacheController {
        get {
            if (CacheController == null) {
                CacheController = new ocms_mfc_PlatformCache();
            }
            return CacheController;
        }
        set;
    }

    /**
     * @description gets all contentIds that have the associated path tagged on them
     * @param contentIds - List<String> contentIds to search through
     * @param pathToMatch - String path that the contentId must have
     * @return List<String> - List of contentIds
     */
    public List<String> getContentIdsWithMatchingPath(List<String> contentIds, String pathToMatch) {
        List<String> matchingContentIds = new List<String>();

        String dimension = pathToMatch.removeStart('/').substringBetween('/', '/');
        Set<String> matchingContentIdsSet = new Set<String> (contentIds);
        if (ocms_TaxonomyAPI.contentIdBuckets.containsKey(dimension)) {
            matchingContentIdsSet.retainAll(ocms_TaxonomyAPI.contentIdBuckets.get(dimension));

            for (String contentId : contentIds) {
                if (matchingContentIdsSet.contains(contentId)) {
                    matchingContentIds.add(contentId);
                }
            }
        }
        return matchingContentIds;
    }

    /**
     * @description gets renderings for only the contentIds using the template for this class
     * @param contentIds - List<String> list of contentIds to get renderings
     * @return Map<Id, String> - Map of ContentId to Renderings
     */
    public Map<Id, String> getRenderingsForContentIds(List<String> contentIds) {
        String contentsQuery = 'SELECT Id, cms__Content_Type__r.cms__Name__c ' +
                'FROM cms__Content__c ' +
                'WHERE Id IN :contentIds';

        List <cms__Content__c> contents = Database.query(contentsQuery);

        List<String> idsToSend = new List<String>();
        List<String> layoutsToSend = new List<String>();

        for (cms__Content__c thisContent : contents) {
            idsToSend.add(thisContent.Id);
            layoutsToSend.add(thisContent.cms__Content_Type__r.cms__Name__c == 'PollVote' ? pollVoteContentLayout : newsTileContentLayout);
        }

        return taxonomyApi.getLatestContentRenderingsForOriginContents(idsToSend, layoutsToSend);
    }

    /**
     * @description Get all the news paths - This is used to asynchronously get paths and load the news stream skeleton. Increases performance greatly.
     * @return String
     */
    public String getAllNewsPathsJSONResponse() {
        return '{"success": true, "allNewsPaths": "' + getAllNewsPaths() + '"}';
    }

    public String getAllNewsPaths() {
        for (String path : mfcTaxonomy.getAllNewsCategories()) {
            System.debug(path);
        }

        System.debug(String.join(mfcTaxonomy.getAllNewsCategories(), ';;;'));

        return String.join(mfcTaxonomy.getAllNewsCategories(), ';;;');
    }
}