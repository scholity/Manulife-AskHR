global virtual without sharing class ocms_mfc_App extends ocms_ps_Content {
    // Constructor for the execute request
    global ocms_mfc_App() { }

    // Constructor for the content editor VF page
    global ocms_mfc_App(cms.CreateContentController cc) {
        super(cc);
    }

    // constructor for generator
    global ocms_mfc_App(cms.GenerateContent gc) {
         super(gc);
    } 
    
    // Allows the get HTML to be overriten for different templates.
    global virtual override String getHTML() { 
        return '';
    }

    private String appRecordTypeId {
        get {
            if (appRecordTypeId == null) {
                RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType = 'MFC_Community_Object__c' AND DeveloperName = 'App'];
                appRecordTypeId = rt.Id;
            }

            return appRecordTypeId;
        } set;
    }

    /**
     * @description Get the most used application for the specific user.  You can change the number of items
     *              rendered by changing the favouriteAppCount variable in the function.
     * @param  String userId    The String userId of the user you want to get the applications for.
     * @return List<String>  A list with all of the favourite applications for user.  The values are the rendereings.
     */
    public List<String> getMostUsedApplications(String userId, Boolean canFutureCall) {
        Integer favouriteAppCount = 5;

        // Setup the ServiceAPI and helpers
        cms.ServiceAPI sApi = getServiceAPI();
        ocms_TaxonomyAPI TaxonomyHelper = new ocms_TaxonomyAPI(sApi);
        
        // Get the current users favorite apps
        List<MFC_Community_Object__c> lUserFavouriteApps = Database.query('SELECT Content__c FROM MFC_Community_Object__c WHERE User__c = :userId AND IsSubscribed__c = true AND RecordTypeId = :appRecordTypeId ORDER BY UseCount__c DESC NULLS LAST LIMIT :favouriteAppCount');

        Set<String> lContentOriginIds = new Set<String>();

        List<String> mandatoryContentIds = new List<String>();
        Map<String, String> sitePreferences = ocms_mfc_SitePreferences.getSitePreferences(pm, sApi.getRenderLanguage());

        // Get the site preferences mandatory applications
        if (sitePreferences.containsKey('mandatoryAppIDs') && sitePreferences.get('mandatoryAppIDs') != null) {
            mandatoryContentIds = sitePreferences.get('mandatoryAppIDs').split(',');
        }

        for (MFC_Community_Object__c app : lUserFavouriteApps) {
            lContentOriginIds.add(app.Content__c);
        }

        // If the user doesn't have four favorite applications yet, fill them up with the mandatory applications
        // until they have reached their 4 they need
        if (lUserFavouriteApps.size() < 5) {
            for (String mandatoryContentId : mandatoryContentIds) {
                if (lContentOriginIds.add(mandatoryContentId)) {
                    // We need to add it to the app user relation to maintain the order.
                    MFC_Community_Object__c app = new MFC_Community_Object__c();
                    app.Content__c = mandatoryContentId;
                    app.RecordTypeId = appRecordTypeId;

                    lUserFavouriteApps.add(app);
                }
                
                if (lContentOriginIds.size() >= 5) {
                    break;
                }
            }
    
        }

        // Is our user subscribed to all the mandartory apps
        List<MFC_Community_Object__c> allUserMandatoryApps = Database.query('SELECT Content__c FROM MFC_Community_Object__c WHERE User__c = :userId AND RecordTypeId = :appRecordTypeId AND Content__c IN :mandatoryContentIds AND IsSubscribed__c = true');

        // If there user doesn't have all the mandatory apps currently, perform a future call (if possible- canFutureCall) to upate those apps at a later time.
        if (allUserMandatoryApps.size() != mandatoryContentIds.size() && canFutureCall) {
            updateMandarotyApps(userId, mandatoryContentIds);
        }

        // Generate our content for our 4 applications
        TaxonomyHelper.getLatestContentRenderingsForOriginContents(new List<String>(lContentOriginIds), 'AppIcon');

        // This will likely happen when they expire a content and someone is still subscribed to it as part of their favorites
        // This will purge all the old apps from their list causing one slow call.
        if (TaxonomyHelper.contentIdsMapping.size() != lUserFavouriteApps.size()) {
            List<MFC_Community_Object__c> allUserApps = Database.query('SELECT Content__c FROM MFC_Community_Object__c WHERE User__c = :userId AND RecordTypeId = :appRecordTypeId');
            lContentOriginIds = new Set<String>();

            for (MFC_Community_Object__c app : allUserApps) {
                lContentOriginIds.add(app.Content__c);
            }

            TaxonomyHelper.getLatestContentRenderingsForOriginContents(new List<String>(lContentOriginIds), 'AppIcon');

            lContentOriginIds.removeAll(TaxonomyHelper.contentIdsMapping.keyset());

            Map<Id, MFC_Community_Object__c> deletingApps = new Map<Id, MFC_Community_Object__c>((List<MFC_Community_Object__c>)Database.query('SELECT Id FROM MFC_Community_Object__c WHERE Content__c IN :lContentOriginIds AND User__c = :userId AND RecordTypeId = :appRecordTypeId'));

            deleteApps(deletingApps.keySet());
        }

        // We need to sort our list by our list of content origin ids.
        List<String> sortedApplications = new List<String>();

        // Since generation the content might return a different order for our apps, go through out lUserFavouriteApps to maintain the order.
        for (MFC_Community_Object__c app : lUserFavouriteApps) {
            // app.Content__c points to the content origin id, the TaxonomyHelper returns us a map of contentIdsMaps which is content origin to latest content version ids
            sortedApplications.add(TaxonomyHelper.contentRenderings.get(TaxonomyHelper.contentIdsMapping.get(app.Content__c)));
        }

        return sortedApplications;
    }

    @future
    public static void deleteApps(Set<Id> deletingAppsIds) {
        List<MFC_Community_Object__c> deletingApps = Database.query('SELECT Id FROM MFC_Community_Object__c WHERE Id IN :deletingAppsIds');

        delete deletingApps;
    }

    /**
     * This call is used inside the content editor of site preferences to get all of the applications by there
     * name to display in autocomplete.
     * 
     * @return A list of all of the apps. 
     */
    public List<AppSorter> getFullAppListByName() {
        cms.ServiceAPI sApi = getServiceAPI();

        Map<String, String> apps = new Map<String, String>();

        List<AppSorter> contentHashes = new List<AppSorter>();
        
        for (cms__Content__c content : sApi.getLatestContentVersions(new List<String>{'App'}, new List<String>{'AppIcon'})) {
            String sAppTitle = null;
            String sDisplayPriority = '0'; // default value for apps that lack the attribute, must match `iDisplayPriority` default value for consistency
            for (cms__Attribute__c attr : content.cms__Attributes__r) {
                if (attr.cms__Name__c == 'title') {
                    sAppTitle = attr.cms__Value__c; 
                }
                if (attr.cms__Name__c == 'iDisplayPriority') {
                    sDisplayPriority = attr.cms__Value__c;
                }
            }
            
            // at this point we should at least have title and priority if it existed so add the item to our content hashes
            String contentOriginId = (content.cms__Version_Origin__c == null) ? content.Id : content.cms__Version_Origin__c;
            contentHashes.add(new AppSorter(
                sDisplayPriority 
                + ';' + sAppTitle
                + ';' + ((content.cms__Version_Origin__c == null) ? content.Id : content.cms__Version_Origin__c) 
                + ';' + content.cms__Name__c));
        }

        contentHashes.sort();

        return contentHashes;
    }

    /**
     * @description Get's the full application list.  This list is sorted by category and the list is no
     *              restricted by any filters.  The application will return the AppIcon layout.
     * @return Map<String, List<String>>    Map of content where the key is the category for the application
     *                                      and the values are the content renderings for that content.
     */
    public Map<String, List<String>> getFullAppList(String limitByCategoryName) {
        Map<String, List<String>> mContentByCategory = new Map<String, List<String>>();

        // Setup the ServiceAPI and helpers
        cms.ServiceAPI sApi = getServiceAPI();
        ocms_TaxonomyAPI TaxonomyHelper = new ocms_TaxonomyAPI(sApi);
        ocms_mfc_Taxonomy mfcTaxonomy = new ocms_mfc_Taxonomy(sApi);

        // Gets the category path from the Site Preferences piece of content
        String categoryPath = mfcTaxonomy.getAppCategories();
        categoryPath = categoryPath.startsWith('/') ? categoryPath.removeStart('/') : categoryPath;

        // Split the tags that were saved and find the node at which Categories is stored at.
        // Latest category will be the node at which the Categories are at.
        String latestCategory = '';

        List<String> categoryTags = categoryPath.split('/');
        Integer categorySize = categoryTags.size();

        if (categoryTags.size() > 0) {
            latestCategory = categoryTags[categoryTags.size() - 1];
        }
        
        List<List<String>> pathLists = new List<List<String>>();

        if (String.isEmpty(limitByCategoryName)) {
            pathLists.add(mfcTaxonomy.getLocationPathList());
        } else {
            // Weird... See Tyson
            pathLists.add(new List<String>{'/' + categoryPath.removeStart('/').removeEnd('/') + '/' + limitByCategoryName});
        }
        
        List<String> mandatoryContentIds = new List<String>();

        Map<String, String> sitePreferences = ocms_mfc_SitePreferences.getSitePreferences(pm, sApi.getRenderLanguage());

        if (sitePreferences.containsKey('mandatoryAppIDs') && sitePreferences.get('mandatoryAppIDs') != null) {
            mandatoryContentIds = sitePreferences.get('mandatoryAppIDs').split(',');
        }
        
        List<String> listcontent = mfcTaxonomy.getContentIdsForTaxonomies(pathLists, 'App', 'date', null, null);

        Set<String> setContent = new Set<String>(listcontent);
        setContent.addAll(mandatoryContentIds);

        Map<Id, String> mContentRenderings = TaxonomyHelper.getLatestContentRenderingsForOriginContents(new List<String>(setContent), 'AppIcon');

        String userId = UserInfo.getUserId();

        List<MFC_Community_Object__c> allUserMandatoryApps = Database.query('SELECT Content__c FROM MFC_Community_Object__c WHERE User__c = :userId AND RecordTypeId = :appRecordTypeId AND Content__c IN :mandatoryContentIds AND IsSubscribed__c = true');

        if (allUserMandatoryApps.size() != mandatoryContentIds.size()) {
            updateMandarotyApps(userId, mandatoryContentIds);
        }

        Set<String> contentIds = new Set<String>();
        for (String contentId : mContentRenderings.keySet()) {
            contentIds.add(contentId);
        }

        Map<String, List<String>> pathsForContent = TaxonomyHelper.getPathsForContentIds(contentIds);

        List<AppSorter> contentHashes = new List<AppSorter>();

        String keyPath = '/' + categoryPath.removeStart('/').removeEnd('/') + '/';

        for (String contentId : pathsForContent.keySet()) {
            for (String pathForContent : pathsForContent.get(contentId)) {
                
                // pathForContent = '/Master/App Categories/News'
                // pathForContent = '/Master/App Categories'
                // keyPath =  /Master/App Categories/
                 
                if (pathForContent.contains(keyPath)) {
                    Boolean addCategory = true;
                    String categoryName = pathForContent.substringAfterLast('/');

                    if (String.isNotEmpty(limitByCategoryName) && categoryName != limitByCategoryName) {
                        addCategory = false;
                    } 

                    if (addCategory) {
                        contentHashes.add(new AppSorter(
                            mContentRenderings.get(contentId).substringBetween('data-nDisplayPriority="', '" href="') //IMPRV: maybe use a regex to make this a little more robust
                            + ';' + mContentRenderings.get(contentId).substringBetween('<span class="name">', '</span>') 
                            + ';' + contentId 
                            + ';' + categoryName
                            )
                        ); 
                          
                    }
                }
            }
        }

        // Sort our hash list
        contentHashes.sort();

        // We now have a sorted list of all of our applications
        for (AppSorter app : contentHashes) {
            // We need to ensure that we have the content name, content id and the content category to reference the list by an index
            if (mContentByCategory.containsKey(app.appCategory)) {
                mContentByCategory.get(app.appCategory).add(mContentRenderings.get(app.appId));
            } else {
                mContentByCategory.put(app.appCategory, new List<String>{mContentRenderings.get(app.appId)});
            }   
        }

        return mContentByCategory;
    }

    global class AppSorter implements Comparable {

        public Integer iDisplayPriority;
        public String appName;
        public String appId;
        public String appCategory;
        public Boolean duplicateName;

        public AppSorter(String appHash) {
            List<String> appContent = appHash.split(';');
            try {
                iDisplayPriority = Integer.valueOf(appContent[0]); 
            }
            catch (Exception e) {
                iDisplayPriority = 0; // default value - muyst match iDisplayPriority dfeault value defined above, we would only (probably) get here if have stale cache and are extracting the priority @258, which was the case when we pushed the code to DEPLOYmfc 
            }
            appName = appContent[1];
            appId = appContent[2];
            appCategory = appContent[3];
            duplicateName = false;
        }

        global Integer compareTo(Object compareTo) {
            AppSorter compareToEmp = (AppSorter)compareTo;

            if (iDisplayPriority > compareToEmp.iDisplayPriority) {
                return -1;
            }
            if (iDisplayPriority < compareToEmp.iDisplayPriority) {
                return 1;
            }
            else { // priority is equal so sort by name
                if (appName.toLowerCase() == compareToEmp.appName.toLowerCase()) {
                    compareToEmp.duplicateName = true;
                    duplicateName = true;
                    return 0;
                }
                if (appName.toLowerCase() > compareToEmp.appName.toLowerCase()) { 
                    return 1;
                }
                return -1;
            }

           
        }
    }

    /**
     * @description Get the full application list for the user id
     * @param  String userId                The user ID that you want to get the applications for
     * @return Map<String, List<String>>    Map<Category, Listr<SontentRenderings>>
     */
    public Map<String, List<String>> getFullAppListForUser(String userId) {
        List<MFC_Community_Object__c> lUserApps = Database.query('SELECT Id, Content__c, User__c, IsSubscribed__c, UseCount__c FROM MFC_Community_Object__c WHERE User__c = :userId AND IsSubscribed__c = true AND RecordTypeId = :appRecordTypeId');
        // Stores all of the contentOriginId's based on the users application
        Set<String> lContentOriginIds = new Set<String>();

        for (MFC_Community_Object__c userApp : lUserApps) {
            lContentOriginIds.add(userApp.Content__c);
        }

        Set<String> lContentOriginIdsCast = new Set<String>();
        lContentOriginIdsCast.addAll(lContentOriginIds);

        List<String> mandatoryContentIds = new List<String>();

        cms.ServiceAPI sApi = getServiceAPI();

        Map<String, String> sitePreferences = ocms_mfc_SitePreferences.getSitePreferences(pm, sApi.getRenderLanguage());

        if (sitePreferences.containsKey('mandatoryAppIDs') && sitePreferences.get('mandatoryAppIDs') != null) {
            mandatoryContentIds = sitePreferences.get('mandatoryAppIDs').split(',');
        }

        lContentOriginIdsCast.addAll(mandatoryContentIds);

        List<MFC_Community_Object__c> allUserMandatoryApps = Database.query('SELECT Content__c FROM MFC_Community_Object__c WHERE User__c = :userId AND RecordTypeId = :appRecordTypeId AND Content__c IN :mandatoryContentIds AND IsSubscribed__c = true');

        if (allUserMandatoryApps.size() != mandatoryContentIds.size()) {
            updateMandarotyApps(userId, mandatoryContentIds);
        }

        // Get the tags for the applications that this user is subscribed to
        Map<String, List<List<cms__Tag__c>>> mContentTags = sApi.getAllTagsForContent(lContentOriginIds);

        // Get all of the conten rendereds for the list of of application
        ocms_TaxonomyAPI TaxonomyHelper = new ocms_TaxonomyAPI(sApi);
        Map<Id, String> mContentRenderings = TaxonomyHelper.getLatestContentRenderingsForOriginContents(new List<String>(lContentOriginIdsCast), 'AppIcon');
        ocms_mfc_Taxonomy mfcTaxonomy = new ocms_mfc_Taxonomy(sApi);
        
        String categoryPath = mfcTaxonomy.getAppCategories();

        Map<String, List<String>> mContentByCategory = new Map<String, List<String>>();
        List<AppSorter> contentHashes = new List<AppSorter>();
        
        Map<String, List<String>> pathsForContent = null;

        if (Test.isRunningTest()) {
            pathsForContent = testPathForContent;
        } else {
            pathsForContent = TaxonomyHelper.getPathsForContentIds((Set<String>)JSON.deserialize(JSON.serialize(mContentRenderings.keySet()), Set<String>.class));
        }

        String keyPath = '/' + categoryPath.removeStart('/').removeEnd('/') + '/';
        
        for (String contentId : pathsForContent.keySet()) {
            for (String pathForContent : pathsForContent.get(contentId)) {
                
                // pathForContent = '/Master/App Categories/News'
                // pathForContent = '/Master/App Categories'
                // keyPath =  /Master/App Categories/
                 
                if (pathForContent.contains(keyPath)) {
                    String categoryName = pathForContent.substringAfterLast('/');
 
                    contentHashes.add(new AppSorter(
                            mContentRenderings.get(contentId).substringBetween('data-nDisplayPriority="', '" href="') //IMPRV: maybe use a regex to make this a little more robust
                            + ';' + mContentRenderings.get(contentId).substringBetween('<span class="name">', '</span>') 
                            + ';' + contentId 
                            + ';' + categoryName
                            )
                        ); 
                }
            }
        }

        contentHashes.sort();

        // We now have a sorted list of all of our applications
        for (AppSorter app : contentHashes) {
            // We need to ensure that we have the content name, content id and the content category to reference the list by an index
            if (mContentByCategory.containsKey(app.appCategory)) {
                mContentByCategory.get(app.appCategory).add(mContentRenderings.get(app.appId));
            } else {
                mContentByCategory.put(app.appCategory, new List<String>{mContentRenderings.get(app.appId)});
            }   
        }

        return mContentByCategory;
    }

    public Map<String, List<String>> testPathForContent {
        get {
            if (testPathForContent == null) {
                testPathForContent = new Map<String, List<String>>();   
            }

            return testPathForContent;
        } set;
    }
    
    @future
    public static void updateMandarotyApps(String userId, List<String> applicationIds) {
        RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType = 'MFC_Community_Object__c' AND DeveloperName = 'App'];
        String appRecordTypeId = rt.Id;

        List<MFC_Community_Object__c> appsToUpdate = new List<MFC_Community_Object__c>();        
        List<MFC_Community_Object__c> lUserFavouriteApps = Database.query('SELECT Id, Content__c FROM MFC_Community_Object__c WHERE User__c = :userId AND Content__c IN :applicationIds AND RecordTypeId = :appRecordTypeId');

        Map<String,String> favContentId = new Map<String,String>();

        for (MFC_Community_Object__c app : lUserFavouriteApps) {
            favContentId.put(app.Content__c, app.Id);
        }

        for (String applicationId : applicationIds) {
            MFC_Community_Object__c newApp = new MFC_Community_Object__c();

            if (favContentId.containsKey(applicationId)) {
                newApp.Id = favContentId.get(applicationId);
            }
            
            newApp.User__c = userId;
            newApp.Content__c = applicationId;
            newApp.IsSubscribed__c = true;
            newApp.RecordTypeId = appRecordTypeId;

            appsToUpdate.add(newApp);
        }

        upsert appsToUpdate;
    }

    public MFC_Community_Object__c application {get; set;}

    /**
     * Increases the count of the application based on the applicationId and userId.  If the application
     * doesn’t exist than it creates the application and the sets the count to 1.  This application created 
     * isn’t subscribed to by default.
     * 
     * @param {[String]} applicationId [The ID of the application which should be the content_origin ID]
     * @param {[String]} userId        [The ID of the user that is accessing the application]
     * 
     * @return {[MFC_Community_Object__c]}     [The instance of the application object]
     */
    public MFC_Community_Object__c addViewToApp(String applicationId, String userId) {
        MFC_Community_Object__c application = getUserApplication(applicationId, userId);    
        application.UseCount__c = (application.UseCount__c != null) ? application.UseCount__c + 1 : 1;
        
        update application;

        return application;
    }

    /**
     * Changes the subscription for the application to true.
     * 
     * @param  {[String]} applicationId     [The ID of the application which should be the content_origin.Id]
     * @param  {[String]} userId            [The ID of the users application]
     * 
     * @return {[MFC_Community_Object__c]}     [The instance of the application object]
     */
    public MFC_Community_Object__c subscribeToApp(String applicationId, String userId) {
        MFC_Community_Object__c application = getUserApplication(applicationId, userId);
        application.IsSubscribed__c = true;

        update application;

        return application;
    }

    public Boolean unsubscribeToApp(String applicationId, String userId) {
        List<MFC_Community_Object__c> lAppUserRelations = Database.query('SELECT Id, IsSubscribed__c, Content__c, User__c, UseCount__c FROM MFC_Community_Object__c WHERE RecordTypeId = :appRecordTypeId AND User__c = :userId AND Content__c = :applicationId LIMIT 1');

        if (!lAppUserRelations.isEmpty()) {
            lAppUserRelations[0].IsSubscribed__c = false;
            update lAppUserRelations[0];
        }

        return true;
    }

    /**
     * Determines if there is an application that is existent or not.  If there isn’t an application that is existing
     * it will create a new one.
     * 
     * @param String applicationId The look up ID for the application
     * @param String userId        The look up ID for the user of the application
     */
    private MFC_Community_Object__c getUserApplication(String applicationId, String userId) {
        if (this.application == null) {
            List<MFC_Community_Object__c> lAppUserRelations = Database.query('SELECT Id, IsSubscribed__c, Content__c, User__c, UseCount__c FROM MFC_Community_Object__c WHERE RecordTypeId = :appRecordTypeId AND User__c = :userId AND Content__c = :applicationId');

            if (lAppUserRelations.isEmpty()) {
                this.application = new MFC_Community_Object__c();
                this.application.Content__c = applicationId;
                this.application.User__c = userId;
                this.application.IsSubscribed__c = false;
                this.application.RecordTypeId = appRecordTypeId;

                insert this.application;
                
                this.application = Database.query('SELECT Id, IsSubscribed__c, Content__c, User__c, UseCount__c FROM MFC_Community_Object__c WHERE RecordTypeId = :appRecordTypeId AND Content__c = :applicationId AND User__c = :userId LIMIT 1');
            } else {
                this.application = lAppUserRelations[0];
            }
        }

        return this.application;
    }

    public Boolean getSubscriptionStatus(String userId, String applicationId) {
        List<MFC_Community_Object__c> currentSubscriptionApp = Database.query('SELECT Id FROM MFC_Community_Object__c WHERE User__c = :userId AND RecordTypeId = :appRecordTypeId AND Content__c = :applicationId AND IsSubscribed__c = true');

        return !currentSubscriptionApp.isEmpty();
    }

    public String versionOriginId {
        get {
            if (content != null) {
                versionOriginId = content.Id;
                if (content.cms__Version_Origin__c != null) {
                    versionOriginId = content.cms__Version_Origin__c;
                }
            }
             
            return versionOriginId;
        } set;
    }


    /**
     * @description display priority relative to other app records represented as a string
     */
    public Integer iDisplayPriority {
        get {
            try {
                return Integer.valueOf(getProperty('iDisplayPriority'));
            }
            catch (Exception e){
                return 0;
            }
        }
        set;
    }


    /**
     * @description attribute title - required
     */
    public String title {
        get {
            return (String.isBlank(getProperty('title')) ? '' : getProperty('title'));
        }
        set;
    }

    /**
     * @description attribute imageIcon - required
     */
    public String imageIcon {
        get {
            return (String.isBlank(getProperty('imageIcon')) ? '' : getProperty('imageIcon'));
        }
        set;
    }

    /**
     * @description attribute linkAsData - required
     */
    public String linkAsData {
        get {
            return (String.isBlank(getProperty('link')) ? '' : getProperty('link'));
        }
        set;
    }

    /**
     * @description attribute link - required
     */
    public cms.Link link {
        get {
            return new cms.Link(linkAsData, this.pm, this.sn);
        }
        set;
    }

    /**
     * @description attribute appWidgetTitle - required
     */
    public String appWidgetTitle {
        get {
            return (String.isBlank(getProperty('appWidgetTitle')) ? '' : getProperty('appWidgetTitle'));
        }
        set;
    }

    /**
     * @description attribute embedLink - optional
     */
    public String embedLink {
        get {
            return (String.isBlank(getProperty('embedLink')) ? '' : getProperty('embedLink'));
        }
    }

    /**
     * @description attribute summary - required
     */
    public String summary {
        get { return (String.isBlank(getProperty('summary')) ? '' : getProperty('summary')); }
    }

    /**
     * @description attribute tutorial - required
     */
    public String tutorial {
        get { return (String.isBlank(getProperty('tutorial')) ? '' : getProperty('tutorial')); }
    }

    /**
     * @description attribute tutorialVideoLink - required
     */
    public String tutorialVideoLink {
        get { return (String.isBlank(getProperty('tutorialVideoLink')) ? '' : getProperty('tutorialVideoLink')); }
    }    
}