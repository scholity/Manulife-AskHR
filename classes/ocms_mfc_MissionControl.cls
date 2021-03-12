/**
 * Created by tiandai on 2018-02-06.
 */

global with sharing class ocms_mfc_MissionControl extends ocms_ps_Content implements cms.ServiceInterface {

    global ocms_mfc_MissionControl() {
    }

    global ocms_mfc_MissionControl(cms.CreateContentController cc) {
        super(cc);
    }

    global ocms_mfc_MissionControl(cms.GenerateContent gc) {
        super(gc);
    }

    // For generated markup, we are overriding this to support multiple templates
    global override virtual String getHTML() {
        return '\'cid\':\'' + content.id + '\',\'coid\':\'' + versionOriginId + '\',\'title\':\'' + Title + '\',\'ArticleDate\':\'' + ArticleDate +
                '\',\'byline\':\'' + Byline + '\',\'body\':\'' + Body + '\',\'excerpt\':\'' + Excerpt +
                '\',\'pageWeight\':\'' + PageWeight + '\',\'image\':\'/employee' + Image + '\',\'tags\':\'' + Tags + '\', \'externalLinkText\':\'' + ExternalLinkText +
                '\',\'externalLink\':\'' + ExternalLink + '\',\'region\':\'' + Region + '\',\'feature\':\'' + Feature + '\',\'tileType\':\'' + TileType +
                '\',\'storyType\':\'' + StoryType + '\',\'series\':\'' + Series + '\',\'pageType\':\'' + PageType + '\',\'attachments\': [\'' +
                Attachment1 + '\',\'' + Attachment2 + '\',\'' + Attachment3 + '\',\'' + Attachment4 + '\',\'' + Attachment5 + '\']';
    }

    public System.Type getType() {
        return ocms_mfc_MissionControl.class;
    }

    // bookmarks and likes need to use this to persist counts across version edits
    public String versionOriginId {
        get {
            versionOriginId = content.Id;
            if (content.cms__Version_Origin__c != null) {
                versionOriginId = content.cms__Version_Origin__c;
            }
            return versionOriginId;
        }
        set;
    }

    public String Title {
        get {
            return (getProperty('Title') != null) ? getProperty('Title') : '';
        }
        set;
    }
    public String ArticleDate {
        get {
            return (getProperty('ArticleDate') != null) ? getProperty('ArticleDate') : '';
        }
        set;
    }
    public String Byline {
        get {
            return (getProperty('Byline') != null) ? getProperty('Byline') : '';
        }
        set;
    }
    public String Body {
        get {
            return (getProperty('Body') != null) ? getProperty('Body') : '';
        }
        set;
    }
    public String Excerpt {
        get {
            return (getProperty('Excerpt') != null) ? getProperty('Excerpt') : '';
        }
        set;
    }
    public String Image {
        get {
            return (getProperty('Image') != null) ? getProperty('Image') : '';
        }
        set;
    }
    public String Feature {
        get {
            return (getProperty('Feature') != null) ? getProperty('Feature') : '';
        }
        set;
    }
    public String Tags {
        get {
            return (getProperty('Tags') != null) ? getProperty('Tags') : '';
        }
        set;
    }
    public String ExternalLinkText {
        get {
            return (getProperty('ExternalLinkText') != null) ? getProperty('ExternalLinkText') : '';
        }
        set;
    }
    public String ExternalLink {
        get {
            return (getProperty('ExternalLink') != null) ? getProperty('ExternalLink') : '';
        }
        set;
    }
    public String Region {
        get {
            return (getProperty('Region') != null) ? getProperty('Region') : '';
        }
        set;
    }
    public String Video {
        get {
            return (getProperty('Video') != null) ? getProperty('Video') : '';
        }
        set;
    }
    public String StoryType {
        get {
            return (getProperty('StoryType') != null) ? getProperty('StoryType') : '';
        }
        set;
    }
    public String TileType {
        get {
            return (getProperty('TileType') != null) ? getProperty('TileType') : '';
        }
        set;
    }
    public String Series {
        get {
            return (getProperty('Series') != null) ? getProperty('Series') : '';
        }
        set;
    }

    //Page Specific Fields
    public String PageWeight {
        get {
            return (getProperty('PageWeight') != null) ? getProperty('PageWeight') : '';
        }
        set;
    }
    public String PageType {
        get {
            return (getProperty('PageType') != null) ? getProperty('PageType') : '';
        }
        set;
    }

    //Backend Variables
    public String brand {
        get {
            return getProperty('brand');
        }
        set;
    }
    public String customer {
        get {
            return getProperty('customer');
        }
        set;
    }
    public String efficiencies {
        get {
            return getProperty('efficiencies');
        }
        set;
    }
    public String growth {
        get {
            return getProperty('growth');
        }
        set;
    }
    public String optimization {
        get {
            return getProperty('optimization');
        }
        set;
    }
    public String team {
        get {
            return getProperty('team');
        }
        set;
    }
    public String transformation {
        get {
            return getProperty('transformation');
        }
        set;
    }
    public String costFit {
        get {
            return getProperty('costFit');
        }
        set;
    }
    public String values {
        get {
            return getProperty('values');
        }
        set;
    }
    public String article {
        get {
            return getProperty('article');
        }
        set;
    }
    public String poster {
        get {
            return getProperty('poster');
        }
        set;
    }

    // New 5+6 tags
    public String digitalCustomerLeader{
        get{
            return getProperty('digitalCustomerLeader');
        }
        set;
    }
    public String expenseEfficiency{
        get{
            return getProperty('expenseEfficiency');
        }
        set;
    }
    public String accelerateGrowth{
        get{
            return getProperty('accelerateGrowth');
        }
        set;
    }
    public String obsessAboutCustomers{
        get{
            return getProperty('obsessAboutCustomers');
        }
        set;
    }
    public String portfolioOptimization{
        get{
            return getProperty('portfolioOptimization');
        }
        set;
    }
    public String highPerformingTeam{
        get{
            return getProperty('highPerformingTeam');
        }
        set;
    }
    public String getItDoneTogether{
        get{
            return getProperty('getItDoneTogether');
        }
        set;
    }
    public String doTheRightThing{
        get{
            return getProperty('doTheRightThing');
        }
        set;
    }
    public String thinkBig{
        get{
            return getProperty('thinkBig');
        }
        set;
    }
    public String ownIt{
        get{
            return getProperty('ownIt');
        }
        set;
    }

    public String shareYourHumanity{
        get{
            return getProperty('shareYourHumanity');
        }
        set;
    }

    //Downloads
    public String Attachment1 {
        get {
            if (getProperty('Attachment1') == null)
                return '';
            return getProperty('Attachment1');
        }
        set;
    }
    public String Attachment2 {
        get {
            if (getProperty('Attachment2') == null)
                return '';
            return getProperty('Attachment2');
        }
        set;
    }
    public String Attachment3 {
        get {
            if (getProperty('Attachment3') == null)
                return '';
            return getProperty('Attachment3');

        }
        set;
    }
    public String Attachment4 {
        get {
            if (getProperty('Attachment4') == null)
                return '';
            return getProperty('Attachment4');
        }
        set;
    }
    public String Attachment5 {
        get {
            if (getProperty('Attachment5') == null)
                return '';
            return getProperty('Attachment5');
        }
        set;
    }

    // OCMS variable
    private cms.ServiceAPI sAPI {
        get {
            if (sApi == null) {
                sApi = getServiceAPI();
            }

            return sApi;
        }
        set;
    }

    private ocms_TaxonomyAPI taxonomyApi {
        get {
            if (taxonomyApi == null) {
                taxonomyApi = new ocms_TaxonomyAPI(sApi);
            }

            return taxonomyApi;
        }
        set;
    }

    private ocms_mfc_Taxonomy mfcTaxonomy {
        get {
            if (mfcTaxonomy == null) {
                mfcTaxonomy = new ocms_mfc_Taxonomy(sApi);
            }

            return mfcTaxonomy;
        }
        set;
    }

    public String category {
        get {
            return getProperty('category');
        }
        set;
    }

    public String contentType {
        get {
            return getProperty('contentType');
        }
        set;
    }

    public String MissionControlContentTemplate(String templateType) {
        String type = '';
        if (templateType.equals('article'))
            return 'Mission Control Article';

        if (templateType.equals('page'))
            return 'Mission Control Page';

        return type;
    }

    private String bookmarkRecordType {
        get {
            if (bookmarkRecordType == null) {
                RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType = 'MFC_Community_Object__c' AND DeveloperName = 'Bookmark'];
                bookmarkRecordType = rt.Id;
            }
            return bookmarkRecordType;
        }
        set;
    }

    /**
     * This method executes the request coming from Mission Control front-end
     *
     * @param params request parameters from MC FE
     *
     * @return response string
     */
    global String executeRequest(Map <String, String> params) {
        String response = '{"success" : false, "message" : "Action not supported."}';

        if (params.containsKey('action')) {
            String action = params.get('action');

            // Get single mission control article content by coid
            if ('getMissionControlSingleArticle' == action) {
                String contentId = params.get('content_id');
                String contentType = MissionControlContentTemplate('article');

                RenderingAPIRequest renderingRequest = new RenderingAPIRequest();
                renderingRequest.parameters.put('renderType', 'originId');
                renderingRequest.listParameters.put('originIds', new List<Id>{
                        contentId
                });

                List<String> contentLayouts = new List<String>{
                        contentType
                };
                renderingRequest.listParameters.put('contentLayouts', contentLayouts);

                Map<String, String> parameters = new Map<String, String>();
                parameters.put('renderingRequest', json.serialize(renderingRequest));
                parameters.put('action', 'getRenderedContent');
                parameters.put('service', 'OrchestraRenderingAPI');
                parameters.put('sname', 'MFC_Employee_Community');
                parameters.put('application', 'runtime');
                parameters.put('apiVersion', '5.0');

                String rawData = cms.ServiceEndpoint.doActionApex(parameters);
                JSONMessage.APIResponse apiResponse = (JSONMessage.APIResponse) json.deserialize(rawData, JSONMessage.APIResponse.class);
                MCMessage.MCResponse rawArticles = (MCMessage.MCResponse) json.deserialize(apiResponse.responseObject, MCMessage.MCResponse.class);

                String regExpApos = '([a-zA-Z_0-9])\'([a-zA-Z_0-9]?[ \t]?(?!:)(?!,)(?!]))';
                String parsedData = '{' + rawArticles.renderings[0].renderMap.get(contentType) + '}';
                parsedData = parsedData.replaceAll('\\\\', '\\\\\\\\').replaceAll('\\n', '').replaceAll('\\t', '').
                        replaceAll('>\\s+<', '><').replaceAll(regExpApos, '$1’$2').replace('"', '\\"').replaceAll('\'', '"');

                /*** The following code fixes attachments in MC Article is shown a URL instead of file name ***/
                Map<String, Object> returnMsg= (Map<String, Object>) json.deserializeUntyped(parsedData);
                List<Object> attachments = (List<Object>) returnMsg.get('attachments');
                for (Integer i = 0; i < attachments.size(); ++i){
                    String attaString = String.valueOf(attachments[i]);
                    // check if attachment exists
                    if (attaString.length() > 1){
                        //Extract the attachment ID
                        Integer idIndex = attaString.indexOf('file=');
                        String fileID = attaString.substring(idIndex + 5);

                        // Get filename from SF
                        List<Attachment> cAttachments = [select Name from Attachment where Id=:fileID];
                        if (cAttachments.size() > 0) {
                            System.debug(cAttachments[0].Name);
                            Map<String, Object> eachAttachment = new Map<String, Object>();
                            // Put file name and url into obj
                            eachAttachment.put('fileName', cAttachments[0].name);
                            eachAttachment.put('url', attaString);
                            attachments[i] = eachAttachment;
                            System.debug(eachAttachment);
                        }
                    }
                }

                // replace attachment URL with both name and URL
                returnMsg.put('attachments', attachments);
                parsedData = json.serialize(returnMsg);

                response = '{"success" : true, "markup" : ' + parsedData + ', "hasRenderings" : true}';
            }

            // Get the list of articles (tiles) based on given taxonomy
            if ('getMissionControlArticles' == action) {
                List<String> tagPaths = new List<String>();
                for (String tagPath : (List<String>) JSON.deserialize(params.get('categoryPaths'), List<String>.class)) {
                    tagPaths.add('/' + tagPath);
                }

                Integer listStart = Integer.valueof(params.get('start'));
                Integer listEnd = Integer.valueof(params.get('end'));
                Integer listLength = listEnd - listStart;
                String sortMethod = params.get('sort');

                RenderingAPIRequest renderingRequest = new RenderingAPIRequest();
                renderingRequest.parameters.put('renderType', 'taxonomy');
                renderingRequest.listParameters.put('contentTypes', new List<String>{
                        params.get('contentType')
                });
                renderingRequest.listParameters.put('tagPaths', tagPaths);

                if (sortMethod.equals('most-recent')) {
                    renderingRequest.parameters.put('offset', String.valueOf(listStart));
                    renderingRequest.parameters.put('limit', String.valueOf(listLength));
                }

                String contentType = MissionControlContentTemplate('article');
                List<String> layoutsForTaxonomy = new List<String>{
                        contentType
                };
                renderingRequest.layoutsForTaxonomy = new List<List<String>>{
                        layoutsForTaxonomy
                };

                Map<String, String> parameters = new Map<String, String>();
                parameters.put('renderingRequest', json.serialize(renderingRequest));
                parameters.put('action', 'getRenderedContent');
                parameters.put('service', 'OrchestraRenderingAPI');
                parameters.put('sname', 'MFC_Employee_Community'); // Replace site_name with the name of your OrchestraCMS site
                parameters.put('application', 'runtime');
                parameters.put('apiVersion', '5.0');

                String rawData = cms.ServiceEndpoint.doActionApex(parameters);
                JSONMessage.APIResponse apiResponse = (JSONMessage.APIResponse) json.deserialize(rawData, JSONMessage.APIResponse.class);
                MCMessage.MCResponse rawArticles = (MCMessage.MCResponse) json.deserialize(apiResponse.responseObject, MCMessage.MCResponse.class);

                // if required window is out of scope
                if (!sortMethod.equals('most-recent') && rawArticles.renderings.size() < listStart) {
                    return '{"success" : false, "message" : "required window is out of articles list size"}';
                }

                List<MCMessage.Article> dateList = new List<MCMessage.Article>();
                List<String> contentIdList = new List<String>();
                Map<String, String> resultList = new Map<String, String>();

                String regExpApos = '([a-zA-Z_0-9])\'([a-zA-Z_0-9]?[ \t]?(?!:)(?!,)(?!]))';

                // Only check feature tile if sorting is most recent && list start = 0
                Boolean hasFeature = sortMethod.equals('most-recent') && listStart == 0 ? false : true;

                // To deal with the scenario where there are no feature articles for one category, we create a buffer to buff the 20th
                MCMessage.Article article20 = null;
                String contentId20 = '';
                Map<String, String> resultList20 = new Map<String, String>();

                for (Integer i = 0; i < rawArticles.renderings.size(); i++) {
                    String parsedData = '{' + rawArticles.renderings[i].renderMap.get(contentType) + '}';
                    parsedData = parsedData.replaceAll('\\\\', '\\\\\\\\').replaceAll('\\n', '').replaceAll('\\t', '')
                            .replaceAll('>\\s+<', '><').replaceAll(regExpApos, '$1’$2').replace('"', '\\"').replaceAll('\'', '"');
                    MCMessage.Article article = (MCMessage.Article) json.deserialize(parsedData, MCMessage.Article.class);

                    String[] parts = article.articleDate.split(' ');
                    if (parts.size() < 2)
                        continue;

                    String[] aDay = parts[0].split('-');
                    String[] aTime = parts[1].split(':');
                    DateTime myDateTime = DateTime.newInstance(Integer.valueof(aDay[0]), Integer.valueof(aDay[1]),
                            Integer.valueof(aDay[2]), integer.valueof(aTime[0]),
                            Integer.valueof(aTime[1]), Integer.valueof(aTime[2]));
                    article.articleDate = String.valueof(myDateTime.getTime());

                    if (!hasFeature)
                        if (parsedData.indexOf('"feature":"checked"') > 0) {
                            hasFeature = true;
                        }
                        else if (i == rawArticles.renderings.size() - 1){
                            article20 = article;
                            resultList20.put(article.coid, parsedData);
                            contentId20 = article.coid;
                            break; //Still no feature, we don't feed the last article data as we need to get a feature article
                        }
                    dateList.add(article);
                    resultList.put(article.coid, parsedData);
                    contentIdList.add(article.coid);
                }

                Integer featureListStart = listStart;

                // Pull the most recent feature article from the rest of the feeds
                while (!hasFeature) {
                    featureListStart += 50;

                    renderingRequest = new RenderingAPIRequest();
                    renderingRequest.parameters.put('renderType', 'taxonomy');
                    renderingRequest.listParameters.put('contentTypes', new List<String>{
                            'Mission Control'
                    });
                    renderingRequest.listParameters.put('tagPaths', tagPaths);

                    renderingRequest.parameters.put('offset', String.valueOf(featureListStart));
                    renderingRequest.parameters.put('limit', String.valueOf(listEnd));

                    renderingRequest.layoutsForTaxonomy = new List<List<String>>{
                            layoutsForTaxonomy
                    };

                    parameters.put('renderingRequest', json.serialize(renderingRequest));

                    rawData = cms.ServiceEndpoint.doActionApex(parameters);
                    apiResponse = (JSONMessage.APIResponse) json.deserialize(rawData, JSONMessage.APIResponse.class);
                    rawArticles = (MCMessage.MCResponse) json.deserialize(apiResponse.responseObject, MCMessage.MCResponse.class);

                    // Reached the end of all articles and no feature articles
                    if (rawArticles.renderings.size() < 1){
                        hasFeature = true;
                        dateList.add(article20);
                        resultList.putAll(resultList20);
                        contentIdList.add(contentId20);
                        break;
                    }

                    for (Integer i = 0; i < rawArticles.renderings.size(); i++) {
                        String parsedData = '{' + rawArticles.renderings[i].renderMap.get(contentType) + '}';
                        parsedData = parsedData.replaceAll('\\\\', '\\\\\\\\').replaceAll('\\n', '').replaceAll('\\t', '')
                                .replaceAll('>\\s+<', '><').replaceAll(regExpApos, '$1’$2').replace('"', '\\"').replaceAll('\'', '"');
                        MCMessage.Article article = (MCMessage.Article) json.deserialize(parsedData, MCMessage.Article.class);

                        String[] parts = article.articleDate.split(' ');
                        if (parts.size() < 2)
                            continue;

                        String[] aDay = parts[0].split('-');
                        String[] aTime = parts[1].split(':');
                        DateTime myDateTime = DateTime.newInstance(Integer.valueof(aDay[0]), Integer.valueof(aDay[1]),
                                Integer.valueof(aDay[2]), integer.valueof(aTime[0]),
                                Integer.valueof(aTime[1]), Integer.valueof(aTime[2]));
                        article.articleDate = String.valueof(myDateTime.getTime());

                        if (!hasFeature && parsedData.indexOf('"feature":"checked"') > 0) {
                            hasFeature = true;
                            dateList.add(article);
                            resultList.put(article.coid, parsedData);
                            contentIdList.add(article.coid);
                            break;
                        }
                    }
                }

                //load likes
                String userId = params.get('user');
                List<ContentLikeRecord> contentLikesList = new List<ContentLikeRecord>();

                if (contentIdList.size() > 0 && userId != null) {
                    List<MFC_Community_Object__c> userLikes = Database.query('SELECT Content__c FROM MFC_Community_Object__c WHERE Content__c IN :contentIdList AND User__c = :userId AND RecordTypeId = :likeRecordType');
                    Set<MFC_Community_Object__c> userLikeSet = new Set<MFC_Community_Object__c>(userLikes);
                    List<AggregateResult> likes = Database.query('SELECT Content__c, Count(Id) cnt FROM MFC_Community_Object__c WHERE Content__c IN :contentIdList AND RecordTypeId = :likeRecordType GROUP BY Content__c');
                    for (AggregateResult aResult : likes) {
                        Boolean matchedUser = false;
                        for (Integer i = 0; i < userLikeSet.size(); i++) {
                            if (userLikes[i].Content__c == aResult.get('Content__c')) {
                                matchedUser = true;
                                break;
                            }
                        }
                        ContentLikeRecord likeRec = new ContentLikeRecord((String) aResult.get('Content__c'), matchedUser, String.valueOf(aResult.get('cnt')));
                        contentLikesList.add(likeRec);
                    }
                }

                String responseList = '{';

                if (sortMethod.equals('most-recent')) {
                    for (Integer i = 0; i < dateList.size() - 1; i++) {
                        responseList += '"' + dateList[i].coid + '":' + resultList.get(dateList[i].coid) + ',';
                    }
                    responseList += '"' + dateList[dateList.size() - 1].coid + '":' + resultList.get(dateList[dateList.size() - 1].coid) + '}';

                } else {
                    listEnd = contentLikesList.size() < listEnd ? contentLikesList.size() : listEnd;
                    //Corner case: no likes
                    if (contentLikesList.size() < 1){
                        for (Integer i = 0; i < dateList.size() - 1; i++) {
                            responseList += '"' + dateList[i].coid + '":' + resultList.get(dateList[i].coid) + ',';
                        }
                        responseList += '"' + dateList[dateList.size() - 1].coid + '":' + resultList.get(dateList[dateList.size() - 1].coid);
                    }else {
                        // FIXME: if there is 10 articles but only 8 has likes, this will only get back 8
                        contentLikesList.sort();
                        for (Integer i = listStart; i < listEnd - 1; i++) {
                            responseList += '"' + contentLikesList[i].coid + '":' + resultList.get(contentLikesList[i].coid) + ',';
                        }
                        if (contentLikesList.size() > listEnd - 1)
                            responseList += '"' + contentLikesList[listEnd - 1].coid + '":' + resultList.get(contentLikesList[listEnd - 1].coid);
                    }
                    responseList += '}';
                }
                response = '{"success" : true, "markup" : ' + responseList + ', "hasRenderings" : true}';
            }

            // get the full content of bookmarked articles
            if ('getMissionControlBookmarkedArticle' == action) {
                //get taxonomy
                List<String> tagPaths = new List<String>();
                for (String tagPath : (List<String>) JSON.deserialize(params.get('categoryPaths'), List<String>.class)) {
                    tagPaths.add('/' + tagPath);
                }

                //get all articles
                RenderingAPIRequest renderingRequest = new RenderingAPIRequest();
                renderingRequest.parameters.put('renderType', 'taxonomy');
                renderingRequest.listParameters.put('contentTypes', new List<String>{
                        params.get('contentType')
                });
                renderingRequest.listParameters.put('tagPaths', tagPaths);

                String contentType = MissionControlContentTemplate('article');
                List<String> layoutsForTaxonomy = new List<String>{
                        contentType
                };
                renderingRequest.layoutsForTaxonomy = new List<List<String>>{
                        layoutsForTaxonomy
                };

                Map<String, String> parameters = new Map<String, String>();
                parameters.put('renderingRequest', json.serialize(renderingRequest));
                parameters.put('action', 'getRenderedContent');
                parameters.put('service', 'OrchestraRenderingAPI');
                parameters.put('sname', 'MFC_Employee_Community'); // Replace site_name with the name of your OrchestraCMS site
                parameters.put('application', 'runtime');
                parameters.put('apiVersion', '5.0');

                String rawData = cms.ServiceEndpoint.doActionApex(parameters);
                JSONMessage.APIResponse apiResponse = (JSONMessage.APIResponse) json.deserialize(rawData, JSONMessage.APIResponse.class);
                MCMessage.MCResponse rawArticles = (MCMessage.MCResponse) json.deserialize(apiResponse.responseObject, MCMessage.MCResponse.class);

                /* get bookmarks */

                // The informative part of the bookmark is the URL containing coid, therefore just grab the url
                List<MFC_Community_Object__c> bookmarkSObjects = [SELECT URL__c FROM MFC_Community_Object__c WHERE User__c = :UserInfo.getUserId() AND (PageMode__c = :params.get('pm') OR PageMode__c = null) AND RecordTypeId = :bookmarkRecordType ORDER BY Original_Publish_Date__c DESC LIMIT 100];

                Set<String> bookmarks = new Set<String>();

                //for each full URL, parse and keep only the coid
                String filterStr = 'content_Id=';
                Integer filterStrLen = filterStr.length();

                for (MFC_Community_Object__c eachBookmark : bookmarkSObjects) {
                    Integer lastIndex = eachBookmark.URL__c.lastIndexOf(filterStr);
                    String articleCOID = eachBookmark.URL__c.substring(lastIndex + filterStrLen);
                    //use Regex to extract the only
                    Pattern pattern = Pattern.compile('[A-Za-z0-9]*');
                    Matcher matcher = pattern.matcher(articleCOID);
                    if (matcher.matches()) {
                        bookmarks.add(matcher.group(0));
                    }
                    ////TODO: how to handle wrong bookmark?
                }

                // filter by bookmark
                List<MCMessage.Article> dateList = new List<MCMessage.Article>();
                List<String> contentIdList = new List<String>();
                Map<String, String> resultList = new Map<String, String>();
                String regExpApos = '([a-zA-Z_0-9])\'([a-zA-Z_0-9]?[ \t]?(?!:)(?!,)(?!]))';
                for (Integer i = 0; i < rawArticles.renderings.size(); i++) {
                    String currentCOID = rawArticles.renderings[i].originId;
                    if (bookmarks.contains(currentCOID)) {
                        String parsedData = '{' + rawArticles.renderings[i].renderMap.get(contentType) + '}';
                        parsedData = parsedData.replaceAll('\\\\', '\\\\\\\\').replaceAll('\\n', '').replaceAll('\\t', '')
                                .replaceAll('>\\s+<', '><').replaceAll(regExpApos, '$1’$2').replace('"', '\\"').replaceAll('\'', '"');

                        MCMessage.Article article = (MCMessage.Article) json.deserialize(parsedData, MCMessage.Article.class);
                        String[] parts = article.articleDate.split(' ');
                        String[] aDay = parts[0].split('-');
                        String[] aTime = parts[1].split(':');
                        DateTime myDateTime = DateTime.newInstance(Integer.valueof(aDay[0]), Integer.valueof(aDay[1]),
                                Integer.valueof(aDay[2]), integer.valueof(aTime[0]),
                                Integer.valueof(aTime[1]), Integer.valueof(aTime[2]));
                        article.articleDate = String.valueof(myDateTime.getTime());

                        dateList.add(article);
                        resultList.put(article.coid, parsedData);
                        contentIdList.add(article.coid);
                    }
                }

                // sort by most recent
                if (dateList.size() < 1) {
                    response = '{"success" : true, "markup" : {}, "hasRenderings" : true}';
                } else {
                    //load likes
                    String sortMethod = params.get('sort');
                    List<ContentLikeRecord> contentLikesList = new List<ContentLikeRecord>();

                    if (contentIdList.size() > 0 && UserInfo.getUserId() != null) {
                        List<MFC_Community_Object__c> userLikes = [SELECT Content__c FROM MFC_Community_Object__c WHERE Content__c IN :contentIdList AND User__c = :UserInfo.getUserId() AND RecordTypeId = :likeRecordType];
                        Set<MFC_Community_Object__c> userLikeSet = new Set<MFC_Community_Object__c>(userLikes);
                        List<AggregateResult> likes = Database.query('SELECT Content__c, Count(Id) cnt FROM MFC_Community_Object__c WHERE Content__c IN :contentIdList AND RecordTypeId = :likeRecordType GROUP BY Content__c');

                        for (AggregateResult aResult : likes) {
                            Boolean matchedUser = false;
                            for (Integer i = 0; i < userLikeSet.size(); i++) {
                                if (userLikes[i].Content__c == aResult.get('Content__c')) {
                                    matchedUser = true;
                                    break;
                                }
                            }
                            ContentLikeRecord likeRec = new ContentLikeRecord((String) aResult.get('Content__c'), matchedUser, String.valueOf(aResult.get('cnt')));
                            contentLikesList.add(likeRec);
                        }
                    }

                    String responseList = '{';
                    if (sortMethod.equals('most-recent')) {
                        dateList.sort();
                        for (Integer i = 0; i < dateList.size() - 1; i++) {
                            responseList += '"' + dateList[i].coid + '":' + resultList.get(dateList[i].coid) + ',';
                        }
                        responseList += '"' + dateList[dateList.size() - 1].coid + '":' + resultList.get(dateList[dateList.size() - 1].coid) + '}';

                    } else {
                        contentLikesList.sort();
                        if (contentLikesList.size() >= contentIdList.size()) {
                            for (Integer i = 0; i < contentIdList.size() - 1; i++) {
                                responseList += '"' + contentLikesList[i].coid + '":' + resultList.get(contentLikesList[i].coid) + ',';
                            }
                            responseList += '"' + contentLikesList[contentIdList.size() - 1].coid + '":' + resultList.get(contentLikesList[contentIdList.size() - 1].coid) + '}';
                        } else {
                            /* there are bookmarked articles with 0 likes, so it won't be in the like list. We need to figure these
                             * articles out and put them into the bookmark responseList when sort by popularity/like */

                            //Convert contentIDList into a set
                            Set<String> contentIDSet = new Set<String>(contentIdList);

                            //Add all liked bookmark content first, and removed them from the set so we know what's left
                            for (Integer i = 0; i < contentLikesList.size(); i++) {
                                responseList += '"' + contentLikesList[i].coid + '":' + resultList.get(contentLikesList[i].coid) + ',';
                                contentIDSet.remove(contentLikesList[i].coid);
                            }

                            //Convert the Set back to List because apex is too stupid to loop through a set
                            List<String> contentIDLeftList = new List<String>(contentIDSet);

                            for (Integer i = 0; i < contentIDLeftList.size() - 1; i++) {
                                responseList += '"' + contentIDLeftList[i] + '":' + resultList.get(contentIDLeftList[i]) + ',';
                            }
                            responseList += '"' + contentIDLeftList[contentIDLeftList.size() - 1] + '":' + resultList.get(contentIDLeftList[contentIDLeftList.size() - 1]) + '}';
                        }
                    }
                    response = '{"success" : true, "markup" : ' + responseList + ', "hasRenderings" : true}';
                }
            }

            if (action == 'getMissionControlContent' || action == 'getMissionControlPage') {
                String markup = '';
                String comma = '';
                String mcContentTemplate = '';
                if (action == 'getMissionControlContent') {
                    mcContentTemplate = 'article';
                } else {
                    mcContentTemplate = 'page';
                }

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

                Map<Id, String> renderingMap = taxonomyApi.getLatestContentRenderingsForOriginContents(smallerList, MissionControlContentTemplate(mcContentTemplate));
                Boolean hasRenderings = false;

                String regExpApos = '([a-zA-Z_0-9])\'([a-zA-Z_0-9]?[ \t]?(?!:)(?!,)(?!]))';

                for (String contentId : smallerList) {
                    if (renderingMap.containsKey(contentId)) {
                        markup += comma + '"' + contentId + '":' + '"' + renderingMap.get(contentId)
                                .replaceAll('\\\\', '\\\\\\\\')
                                .replaceAll('\\n', '')
                                .replaceAll('\\t', '')
                                .replaceAll('>\\s+<', '><')
                                .replaceAll(regExpApos, '$1’$2')
                                .replace('\"', '\\"') + '"';
                        hasRenderings = true;
                        comma = ',';
                    }
                }
                response = '{"success" : true, "markup" : {' + markup + '}, "hasRenderings" : ' + hasRenderings + '}';
            }

            if (action == 'getArticleDetail') {
                String markup = '';
                String contentId = params.get('content_id');

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
                //smallerList.add(contentId);
                for (Integer i = 0; i < contentIds.size(); i++) {
                    smallerList.add(contentIds[i]);
                }

                Map<Id, String> renderingMap = taxonomyApi.getLatestContentRenderingsForOriginContents(smallerList, MissionControlContentTemplate('article'));

                String regExpApos = '([a-zA-Z_0-9])\'([a-zA-Z_0-9]?[ \t]?(?!:)(?!,)(?!]))';

                String targetIdString = '\'coid\':\'' + contentId;
                for (String articleId : contentIds) {
                    String article = renderingMap.get(articleId);
                    if (article.contains(targetIdString)) {
                        markup = '"message":' + '"' + article
                                .replaceAll('\\\\', '\\\\\\\\')
                                .replaceAll('\\n', '')
                                .replaceAll('\\t', '')
                                .replaceAll('>\\s+<', '><')
                                .replaceAll(regExpApos, '$1’$2')
                                .replace('\"', '\\"') + '"';
                    }
                }

                response = '{"success" : {' + markup + '}}';
            }
            if (action == 'updateOriginPublishStartDate') {
                String contentId = params.get('contentId');
                Datetime startDate = (Datetime) JSON.deserialize(params.get('startDate'), Datetime.class);
                response = updateOriginPublishStartDate(contentId, startDate);
            }

        }

        return response;
    }

    /*
	Class for Content Like
	*/
    public class ContentLikeRecord implements Comparable {
        public String coid;
        public Boolean liked;
        public Integer likeCount;

        public ContentLikeRecord(String cId, Boolean l, String lc) {
            coid = cId;
            liked = l;
            likeCount = Integer.valueOf(lc);
        }

        // Implement the compareTo() method
        public Integer compareTo(Object compareTo) {
            ContentLikeRecord compareToLikes = (ContentLikeRecord) compareTo;
            if (likeCount == compareToLikes.likeCount) return 0;
            if (likeCount < compareToLikes.likeCount) return 1;
            return -1;
        }
    }

    /*
    Property for like record type
    */
    private String likeRecordType {
        get {
            if (likeRecordType == null) {
                RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType = 'MFC_Community_Object__c' AND DeveloperName = 'Like'];
                likeRecordType = rt.Id;
            }
            return likeRecordType;
        }
        set;
    }

    /**
     * This method updates the publish date together with the
     *
     * @param contentId ID of the current content
     * @param startDate Desired date of this article
     *
     * @return Ajax respond, success or fail
     */
    public String updateOriginPublishStartDate(String contentId, Datetime startDate) {
        cms__Content__c c = [select Id, cms__Published__c, cms__Version_Number__c, cms__Revision_Number__c, cms__Published_Start_Date__c, cms__Preview_Start_Date__c, cms__Version_Origin__c from cms__Content__c where Id = :contentId];
        if (c.cms__Version_Origin__c != null) {
            c = [select Id, cms__Published__c, cms__Version_Number__c, cms__Revision_Number__c, cms__Published_Start_Date__c, cms__Preview_Start_Date__c from cms__Content__c where Id = :c.cms__Version_Origin__c];
        }

        if (c.cms__Version_Number__c != 1 || c.cms__Revision_Number__c != 0) {
            return '{"success":false,"message":"Must modify origin content only"}';
        }

        if (!c.cms__Published__c) {
            return '{"success":false,"message":"This action should only be performed on published content"}';
        }

        c.cms__Published_Start_Date__c = startDate;
        c.cms__Preview_Start_Date__c = startDate;

        try {
            cms__Content_Version_Index__c[] cvis = [select Id, cms__Original_Published_Start_Date__c, cms__Start_Date__c, cms__Origin__c, cms__Latest__c from cms__Content_Version_Index__c where cms__Origin__c = :c.Id];
            for (cms__Content_Version_Index__c cvi : cvis) {
                cvi.cms__Original_Published_Start_Date__c = c.cms__Published_Start_Date__c;
                if (cvi.cms__Origin__c == cvi.cms__Latest__c) {
                    cvi.cms__Start_Date__c = c.cms__Published_Start_Date__c;
                }
            }

            update cvis;
        } catch (QueryException e) {
            System.debug('No CVI found, carrying on.');
        }

        cms__Attribute__c[] attributes = [Select cms__Name__c, cms__Value__c from cms__Attribute__c where cms__Content__c = :contentId];
        for (cms__Attribute__c Attribute : attributes) {
            if (Attribute.cms__Name__c == 'ArticleDate') {
                Attribute.cms__Value__c = startDate.format('yyyy-MM-dd HH:mm:ss');
            }
        }
        update attributes;
        update c;
        return '{"success":true}';
    }
}