global with sharing class ocms_mfc_SitePreferences extends cms.ContentTemplateController implements cms.ServiceInterface {
    final static String MANULIFE_CENTRAL_NAME = 'Manulife Central';
    public static Map<String, String> preferencesMap;

    global ocms_mfc_SitePreferences() {}

    // constructor for content editor
    global ocms_mfc_SitePreferences(cms.CreateContentController cc) {
        super(cc);
        thisContentId = this.content.id;
    }

    // constructor for generator
    global ocms_mfc_SitePreferences(cms.GenerateContent gc) {
        super(gc);
    }

    /**
     * @description required by cms.ServiceInterface
     * @return System.Type
     */
    public System.Type getType() {
        return ocms_mfc_SitePreferences.class;
    }

    public String locationTaxonomy {
        get {
            return this.getProperty('locationTaxonomy');
        }
        set;
    }

    public String uiLabelSearchErrorNoResults {
        get {
            return this.getProperty('uiLabelSearchErrorNoResults');
        } set;
    }

    public String uiLabelSearchErrorNoResultsP2 {
        get {
            return this.getProperty('uiLabelSearchErrorNoResultsP2');
        } set;
    }

    public String uiLabelSearchErrorTimeout {
        get {
            return this.getProperty('uiLabelSearchErrorTimeout');
        } set;
    }

    public String uiLabelSearchFacet1 {
        get {
            return this.getProperty('uiLabelSearchFacet1');
        } set;
    }

    public String uiLabelSearchFacet2 {
        get {
            return this.getProperty('uiLabelSearchFacet2');
        } set;
    }

    public String uiLabelSearchFacet3 {
        get {
            return this.getProperty('uiLabelSearchFacet3');
        } set;
    }

    public String uiLabelSearchFacet4 {
        get {
            return this.getProperty('uiLabelSearchFacet4');
        } set;
    }

    public String uiLabelSearchFacet5 {
        get {
            return this.getProperty('uiLabelSearchFacet5');
        } set;
    }
    
    public Integer searchGSARequestTimeout { // in seconds
        get {
            this.searchGSARequestTimeout = 10; //default value
            try {
                Integer iTemp = Integer.valueOf(this.getProperty('searchGSARequestTimeout'));
                if (iTemp > 0) {
                    this.searchGSARequestTimeout = iTemp;
                }
            }
            catch (Exception e) {}
            return this.searchGSARequestTimeout;
        } set;
    }

    public String uiLabelSearchErrorGeneric {
        get {
            return this.getProperty('uiLabelSearchErrorGeneric');
        } set;
    }

    public String divisionTaxonomy {
        get {
            return this.getProperty('divisionTaxonomy');
        }
        set;
    }

    public String employeeTypeContributorTaxonomy {
        get {
            return this.getProperty('employeeTypeContributorTaxonomy');
        }
        set;
    }

    public String employeeTypePeopleManagerTaxonomy {
        get {
            return this.getProperty('employeeTypePeopleManagerTaxonomy');
        }
        set;
    }

    public String newsCategoryTaxonomy {
        get {
            return this.getProperty('newsCategoryTaxonomy');
        }
        set;
    }

    // now known within the UI as *Tool Categories*
    public String appCategoriesTaxonomy {
        get {
            return this.getProperty('appCategoriesTaxonomy');
        }
        set;
    }

    public String articleCategoriesTaxonomy {
        get {
            return this.getProperty('articleCategoriesTaxonomy');
        }
        set;
    }

    public String featuredItemTagPath {
        get {
            return this.getProperty('featuredItemTagPath');
        }
        set;
    }

    public String notificationsCheckInterval {
        get {
            return this.getProperty('notificationsCheckInterval');
        }
        set;
    }

    public String notificationsMaxLoad {
        get {
            return this.getProperty('notificationsMaxLoad');
        }
        set;
    }

    public String notificationsPerPage {
        get {
            return this.getProperty('notificationsPerPage');
        }
        set;
    }

    public String uiLabelMenu {
        get {
            return this.getProperty('uiLabelMenu');
        }
        set;
    }

    public String uiLabelClose {
        get {
            return this.getProperty('uiLabelClose');
        }
        set;
    }

    public String uiLabelGear {
        get {
            return this.getProperty('uiLabelGear');
        }
        set;
    }
    
    public String uiLabelBack {
        get {
            return this.getProperty('uiLabelBack');
        }
        set;
    }

    public String uiLabelBackToTop {
        get {
            return this.getProperty('uiLabelBackToTop');
        }
        set;
    }

    public String uiLabelBackToHome {
        get {
            return this.getProperty('uiLabelBackToHome');
        }
        set;
    }

    public String uiLabelShowMore {
        get {
            return this.getProperty('uiLabelShowMore');
        }
        set;
    }

    public String uiLabelSearchPlaceholder {
        get {
            return this.getProperty('uiLabelSearchPlaceholder');
        }
        set;
    }

    // social site “Follow” call to action text
    public String uiLabelFollowC2A {
        get {
            return this.getProperty('uiLabelFollowC2A');
        }
        set;
    }

    // Tool tip for ethics hotline toolbar icon
    public String uiTitleEthics {
        get {
            return this.getProperty('uiTitleEthics');
        }
        set;
    }

    // the vague 'Explore' has now become 'browse employee directory within MFConnect'
    public String uiTitleExplore {
        get {
            return this.getProperty('uiTitleExplore');
        }
        set;
    }

    public String uiTitleNotifications {
        get {
            return this.getProperty('uiTitleNotifications');
        }
        set;
    }

    public String uiTitleLaunchPad {
        get {
            return this.getProperty('uiTitleLaunchPad');
        }
        set;
    }

    public String uiTopIconsGroup {
        get {
            return this.getProperty('uiTopIconsGroup');
        }
        set;
    }

    public String uiTitleSearch {
        get {
            return this.getProperty('uiTitleSearch');
        }
        set;
    }

    public String uiTitleFacebook {
        get {
            return this.getProperty('uiTitleFacebook');
        }
        set;
    }

    public String uiTitleTwitter {
        get {
            return this.getProperty('uiTitleTwitter');
        }
        set;
    }

    public String uiTitleInstagram {
        get {
            return this.getProperty('uiTitleInstagram');
        }
        set;
    }

    public String uiTitleLinkedIn {
        get {
            return this.getProperty('uiTitleLinkedIn');
        }
        set;
    }

    public String uiTitleYouTube {
        get {
            return this.getProperty('uiTitleYouTube');
        }
        set;
    }


    public String uiLabelViewNotificationDetails {
        get {
            return this.getProperty('uiLabelViewNotificationDetails');
        }
        set;
    }

    public String uiLabelBookmark {
        get {
            return this.getProperty('uiLabelBookmark');
        }
        set;
    }

    public String uiLabelShare {
        get {
            return this.getProperty('uiLabelShare');
        }
        set;
    }


    public String uiLabelArtContactInformation {
        get {
            return this.getProperty('uiLabelArtContactInformation');
        }
        set;
    }

    public String uiLabelArtPrevious {
        get {
            return this.getProperty('uiLabelArtPrevious');
        }
        set;
    }

    public String uiLabelArtNext {
        get {
            return this.getProperty('uiLabelArtNext');
        }
        set;
    }

    public String uiLabelArtTopics {
        get {
            return this.getProperty('uiLabelArtTopics');
        }
        set;
    }

    public String uiLabelArtRelated {
        get {
            return this.getProperty('uiLabelArtRelated');
        }
        set;
    }

    public String uiLabelArtReadMore {
        get {
            return this.getProperty('uiLabelArtReadMore');
        }
        set;
    }

    public String uiNewsItemLinkText {
        get {
            return this.getProperty('uiNewsItemLinkText');
        }
        set;
    }

    public String uiSocialPostLinkText {
        get {
            return this.getProperty('uiSocialPostLinkText');
        }
        set;
    }

    public String uiLabelLike {
        get {
            return this.getProperty('uiLabelLike');
        }
        set;
    }

    public String articlePageAsData {
        get { return getProperty('articlePage'); }
    }

    public cms.Link articlePage {
        get { return new cms.Link(articlePageAsData); }
    }

    public String bannerPageAsData {
        get { return getProperty('bannerPage'); }
    }

    public cms.Link bannerPage {
        get { return new cms.Link(bannerPageAsData); }
    }

    public String ceoArticlePageAsData {
        get { return getProperty('ceoArticlePage'); }
    }

    public cms.Link ceoArticlePage {
        get { return new cms.Link(ceoArticlePageAsData); }
    }

    public String appLibraryAsData {
        get { return getProperty('appLibrary'); }
    }

    public cms.Link appLibrary {
        get { return new cms.Link(appLibraryAsData, this.pm, this.sn); }
    }

    public String appDetailAsData {
        get { return getProperty('appDetail'); }
    }

    public cms.Link appDetail {
        get { return new cms.Link(appDetailAsData, this.pm, this.sn); }
    }

    public String categoryDetailAsData {
        get { return getProperty('categoryDetail'); }
    }

    public cms.Link categoryDetail {
        get { return new cms.Link(categoryDetailAsData, this.pm, this.sn); }
    }

    public String eventPageAsData {
        get { return getProperty('eventPage'); }
    }

    public cms.Link eventPage {
        get { return new cms.Link(eventPageAsData); }
    }

    public String calendarPageAsData {
        get { return getProperty('calendarPage'); }
    }

    public cms.Link calendarPage {
        get { return new cms.Link(calendarPageAsData); }
    }

    public String eventFormPageAsData {
        get { return getProperty('eventFormPage'); }
    }

    public cms.Link eventFormPage {
        get { return new cms.Link(eventFormPageAsData); }
    }

    public String userPrefsPageAsData {
        get { return getProperty('userPrefsPage'); }
    }

    public cms.Link userPrefsPage {
        get { return new cms.Link(userPrefsPageAsData); }
    }

    public String ethicsHotlinePageAsData {
        get { return getProperty('ethicsHotlinePage'); }
    }

    public cms.Link ethicsHotlinePage {
        get { return new cms.Link(ethicsHotlinePageAsData); }
    }

    public String mfConnectDirectoryAsData {
        get { return getProperty('mfConnectDirectory'); }
    }

    public cms.Link mfConnectDirectory {
        get { return new cms.Link(mfConnectDirectoryAsData); }
    }

    public String facebookPage {
        get {
            return getProperty('facebookPage');
        }
    }

    public String twitterPage {
        get {
            return getProperty('twitterPage');
        }
    }

    public String instagramPage {
        get {
            return getProperty('instagramPage');
        }
    }

    public String linkedInPage {
        get {
            return getProperty('linkedInPage');
        }
    }

    public String youTubePage {
        get {
            return getProperty('youTubePage');
        }
    }

    public String socialLinksInNewTab {
    	get {
    		return getProperty('socialLinksInNewTab');
    	}
    }

    public String mandatoryAppIDs {
        get {
            return getProperty('mandatoryAppIDs');
        }
    }

    public String mandatoryAppNames {
        get {
            return getProperty('mandatoryAppNames');
        }
    }

    public String shareEmailSubject {
        get {
            return getProperty('shareEmailSubject');
        }
    }

    public String ceoCategory1 {
        get {
            return getProperty('ceoCategory1');
        }
    }

    public String ceoCategory2 {
        get {
            return getProperty('ceoCategory2');
        }
    }

    public String ceoCategory3 {
        get {
            return getProperty('ceoCategory3');
        }
    }

    public String ceoCategory4 {
        get {
            return getProperty('ceoCategory4');
        }
    }

    public String ceoCategory5 {
        get {
            return getProperty('ceoCategory5');
        }
    }

    public String ceoCategory6 {
        get {
            return getProperty('ceoCategory6');
        }
    }

    public String ceoCategory1Image {
        get {
            return getProperty('ceoCategory1Image');
        }
    }

    public String ceoCategory2Image {
        get {
            return getProperty('ceoCategory2Image');
        }
    }

    public String ceoCategory3Image {
        get {
            return getProperty('ceoCategory3Image');
        }
    }

    public String ceoCategory4Image {
        get {
            return getProperty('ceoCategory4Image');
        }
    }

    public String ceoCategory5Image {
        get {
            return getProperty('ceoCategory5Image');
        }
    }

    public String ceoCategory6Image {
        get {
            return getProperty('ceoCategory6Image');
        }
    }

    public String reportButtonEmail {
        get {
            return getProperty('reportButtonEmail');
        }
    }

    public String mandatoryNewsPaths {
        get {
            return this.getProperty('mandatoryNewsPaths');
        }
        set;
    }

    public String uiLabelToday {
        get {
            return this.getProperty('uiLabelToday');
        }
        set;
    }
    public String uiLabelYesterday {
        get {
            return this.getProperty('uiLabelYesterday');
        }
        set;
    }

    public String thisContentId {get; private set;}


    global override String getHTML() {
        return JSON.Serialize(sitePreferences);
    }


    public String executeRequest(Map<String, String> p) {
        String response = '{"success": false, "message": "Action not supported."}';

        if (p.containsKey('action')) {
            if (p.get('action') == 'setupSitePreferences' ) {
                if (p.containsKey('thisContentId')) {
                    response = setupSitePreferencesJSONResponse(p.get('thisContentId'));
                }
            }
        }

        return response;
    }

    private Map<String, String> sitePreferences {
        get {
            if (sitePreferences == null) {
                sitePreferences = new Map<String, String>();
                List<String> newWindowURLs = new List<String>();

                sitePreferences.put('locationTaxonomy',                     locationTaxonomy);
                sitePreferences.put('divisionTaxonomy',                     divisionTaxonomy);
                sitePreferences.put('employeeTypeContributorTaxonomy',      employeeTypeContributorTaxonomy);
                sitePreferences.put('employeeTypePeopleManagerTaxonomy',    employeeTypePeopleManagerTaxonomy);
                sitePreferences.put('newsCategoryTaxonomy',                 newsCategoryTaxonomy);
                sitePreferences.put('appCategoriesTaxonomy',                appCategoriesTaxonomy);
                sitePreferences.put('articleCategoriesTaxonomy',            articleCategoriesTaxonomy);
                sitePreferences.put('featuredItemTagPath',                  featuredItemTagPath);
                sitePreferences.put('mandatoryNewsPaths',                   mandatoryNewsPaths);

                sitePreferences.put('mandatoryAppNames',                    mandatoryAppNames);
                sitePreferences.put('mandatoryAppIDs',                      mandatoryAppIDs);

                sitePreferences.put('reportButtonEmail',                    reportButtonEmail);

                sitePreferences.put('notificationsCheckInterval',           notificationsCheckInterval);
                sitePreferences.put('notificationsMaxLoad',                 notificationsMaxLoad);
                sitePreferences.put('notificationsPerPage',                 notificationsPerPage);

                sitePreferences.put('uiLabelMenu',                          uiLabelMenu);
                sitePreferences.put('uiLabelClose',                         uiLabelClose);
                sitePreferences.put('uiLabelGear',                          uiLabelGear);
                sitePreferences.put('uiLabelBack',                          uiLabelBack);
                sitePreferences.put('uiLabelBackToTop',                     uiLabelBackToTop);
                sitePreferences.put('uiLabelBackToHome',                    uiLabelBackToHome);
                sitePreferences.put('uiLabelShowMore',                      uiLabelShowMore);
                sitePreferences.put('uiLabelFollowC2A',                     uiLabelFollowC2A);

                sitePreferences.put('uiTitleEthics',                        uiTitleEthics);
                sitePreferences.put('uiTitleExplore',                       uiTitleExplore);
                sitePreferences.put('uiTitleNotifications',                 uiTitleNotifications);
                sitePreferences.put('uiTitleLaunchPad',                     uiTitleLaunchPad);
                sitePreferences.put('uiTopIconsGroup',                      uiTopIconsGroup);
                sitePreferences.put('uiTitleSearch',                        uiTitleSearch);

                sitePreferences.put('uiTitleFacebook',                      uiTitleFacebook);
                sitePreferences.put('uiTitleTwitter',                       uiTitleTwitter);
                sitePreferences.put('uiTitleInstagram',                     uiTitleInstagram);
                sitePreferences.put('uiTitleLinkedIn',                      uiTitleLinkedIn);
                sitePreferences.put('uiTitleYouTube',                       uiTitleYouTube);
                sitePreferences.put('socialLinksInNewTab',                  socialLinksInNewTab);

                sitePreferences.put('uiLabelViewNotificationDetails',       uiLabelViewNotificationDetails);
                sitePreferences.put('uiLabelBookmark',                      uiLabelBookmark);
                sitePreferences.put('uiLabelShare',                         uiLabelShare);

                sitePreferences.put('uiLabelArtContactInformation',         uiLabelArtContactInformation);
                sitePreferences.put('uiLabelArtPrevious',                   uiLabelArtPrevious);
                sitePreferences.put('uiLabelArtNext',                       uiLabelArtNext);
                sitePreferences.put('uiLabelArtTopics',                     uiLabelArtTopics);
                sitePreferences.put('uiLabelArtRelated',                    uiLabelArtRelated);
                sitePreferences.put('uiLabelArtReadMore',                    uiLabelArtReadMore);

                sitePreferences.put('uiNewsItemLinkText',                   uiNewsItemLinkText);
                sitePreferences.put('uiSocialPostLinkText',                 uiSocialPostLinkText);
                sitePreferences.put('uiLabelLike',                          uiLabelLike);
                sitePreferences.put('uiLabelToday',                         uiLabelToday);
                sitePreferences.put('uiLabelYesterday',                     uiLabelYesterday);

                sitePreferences.put('uiLabelSearchPlaceholder',             uiLabelSearchPlaceholder);
                sitePreferences.put('uiLabelSearchErrorNoResults',          uiLabelSearchErrorNoResults);
                sitePreferences.put('uiLabelSearchErrorNoResultsP2',        uiLabelSearchErrorNoResultsP2);
                sitePreferences.put('uiLabelSearchErrorTimeout',            uiLabelSearchErrorTimeout);
                sitePreferences.put('searchGSARequestTimeout',              String.valueOf(searchGSARequestTimeout));
                sitePreferences.put('uiLabelSearchErrorGeneric',            uiLabelSearchErrorGeneric);
                sitePreferences.put('uiLabelSearchFacet1',                  uiLabelSearchFacet1);
                sitePreferences.put('uiLabelSearchFacet2',                  uiLabelSearchFacet2);
                sitePreferences.put('uiLabelSearchFacet3',                  uiLabelSearchFacet3);
                sitePreferences.put('uiLabelSearchFacet4',                  uiLabelSearchFacet4);
                sitePreferences.put('uiLabelSearchFacet5',                  uiLabelSearchFacet5);


                sitePreferences.put('articlePage',                          articlePage.targetPage);

                if (articlePage.target == '_blank') {
                    newWindowURLs.add('articlePage');
                }

                sitePreferences.put('bannerPage',                           bannerPage.targetPage);

                if (bannerPage.target == '_blank') {
                    newWindowURLs.add('bannerPage');
                }

                sitePreferences.put('ceoArticlePage',                       ceoArticlePage.targetPage);

                if (ceoArticlePage.target == '_blank') {
                    newWindowURLs.add('ceoArticlePage');
                }

                sitePreferences.put('appLibrary',                           appLibrary.targetPage);

                if (appLibrary.target == '_blank') {
                    newWindowURLs.add('appLibrary');
                }

                sitePreferences.put('appDetail',                            appDetail.targetPage);

                if (appDetail.target == '_blank') {
                    newWindowURLs.add('appDetail');
                }

                sitePreferences.put('categoryDetail',                       categoryDetail.targetPage);

                if (categoryDetail.target == '_blank') {
                    newWindowURLs.add('categoryDetail');
                }

                sitePreferences.put('eventPage',                            eventPage.targetPage);

                if (eventPage.target == '_blank') {
                    newWindowURLs.add('eventPage');
                }

                sitePreferences.put('calendarPage',                         calendarPage.targetPage);

                if (calendarPage.target == '_blank') {
                    newWindowURLs.add('calendarPage');
                }

                sitePreferences.put('eventFormPage',                        eventFormPage.targetPage);

                if (eventFormPage.target == '_blank') {
                    newWindowURLs.add('eventFormPage');
                }

                sitePreferences.put('userPrefsPage',                        userPrefsPage.targetPage);

                if (userPrefsPage.target == '_blank') {
                    newWindowURLs.add('userPrefsPage');
                }

                sitePreferences.put('ethicsHotlinePage',                    ethicsHotlinePage.targetPage);

                if (ethicsHotlinePage.target == '_blank') {
                    newWindowURLs.add('ethicsHotlinePage');
                }

                sitePreferences.put('mfConnectDirectory',                   mfConnectDirectory.targetPage);

                if (mfConnectDirectory.target == '_blank') {
                    newWindowURLs.add('mfConnectDirectory');
                }

                sitePreferences.put('facebookPage',                         facebookPage);
                sitePreferences.put('twitterPage',                          twitterPage);
                sitePreferences.put('instagramPage',                        instagramPage);
                sitePreferences.put('linkedInPage',                         linkedInPage);
                sitePreferences.put('youTubePage',                          youTubePage);

                sitePreferences.put('shareEmailSubject',                    shareEmailSubject);

                sitePreferences.put('ceoCategory1',                         ceoCategory1);
                sitePreferences.put('ceoCategory2',                         ceoCategory2);
                sitePreferences.put('ceoCategory3',                         ceoCategory3);
                sitePreferences.put('ceoCategory4',                         ceoCategory4);
                sitePreferences.put('ceoCategory5',                         ceoCategory5);
                sitePreferences.put('ceoCategory6',                         ceoCategory6);
                sitePreferences.put('ceoCategory1Image',                    ceoCategory1Image);
                sitePreferences.put('ceoCategory2Image',                    ceoCategory2Image);
                sitePreferences.put('ceoCategory3Image',                    ceoCategory3Image);
                sitePreferences.put('ceoCategory4Image',                    ceoCategory4Image);
                sitePreferences.put('ceoCategory5Image',                    ceoCategory5Image);
                sitePreferences.put('ceoCategory6Image',                    ceoCategory6Image);
                sitePreferences.put('renderLanguage',                       getServiceAPI().getRenderLanguage());

                sitePreferences.put('newWindowURLs',                         JSON.serialize(newWindowURLs));
            }

            return sitePreferences;
        }

        private set;
    }

    public static Map<String, String> getSitePreferences() {
        ocms_mfc_SitePreferences prefsController = new ocms_mfc_SitePreferences();

        return prefsController.getSitePreferencesData();   
    }

    public static Map<String, String> getSitePreferences(String pageMode, String renderLanguage) {
        ocms_mfc_SitePreferences prefsController = new ocms_mfc_SitePreferences();

        Map<String, String> sitePreferences = new Map<String, String>();
        
        try {
            String cacheKey = renderLanguage.replace('_', '') + pageMode;

            ocms_mfc_PlatformCache CacheController = new ocms_mfc_PlatformCache();

            if (CacheController.hasSitePreferencesKey(cacheKey)) {
                System.debug('getting cached site preferences for ' + cacheKey);
                sitePreferences = (Map<String, String>) JSON.deserialize(CacheController.getSitePreferencesKey(cacheKey), Map<String, String>.class);
            } else {
                System.debug('generating site preferences for ' + cacheKey);
                sitePreferences = prefsController.getSitePreferencesData();

                if (sitePreferences.get('cacheKey') == cacheKey) {
                    CacheController.setSitePreferencesKey(cacheKey, JSON.serialize(sitePreferences));
                } else {
                    System.debug('Cache key mismatch, not saving cache for key: ' + cacheKey + ' Expected: ' + sitePreferences.get('cacheKey'));
                }
            }
        } catch (Exception e) {
            // If we run into any errors getting the cache lets generate it manually.
            System.debug('Error getting site preferences from cache at line number ' + e.getLineNumber() + ' error messsage is : ' + e.getMessage());
            sitePreferences = prefsController.getSitePreferencesData();
        }

        return sitePreferences;
    }

    /*
     * @description Checks to see if the site preferences exists, If it doesn't exist it creates a new one and gives it a Site_Preference_Id
     * @return String - JSON Response of success with a message
     */
    public String setupSitePreferencesJSONResponse(String contentId) {
        Boolean success = true;
        String message = 'Success';
        cms.ServiceAPI api = this.getServiceAPI();
        cms__Content__c content;
        cms__Content__c[] contents = [SELECT Id, cms__Content_Type__r.cms__Name__c, cms__Version_Origin__c from cms__Content__c where Id = :contentId];

        if (contents.size() > 0) {
            content = contents[0];
        }

        ocms_mfc_PlatformCache.removeSitePreferencesCache();

        if (content != null) {
            if (content.cms__Content_Type__r.cms__Name__c == 'SitePreferences') {
                ocms_mfc_SiteSettings__c settings = ocms_mfc_SiteSettings__c.getValues(MANULIFE_CENTRAL_NAME);

                // If there isn't a site preferences create one
                if (settings == null) {
                    try {
                        settings = new ocms_mfc_SiteSettings__c();
                        settings.Name = MANULIFE_CENTRAL_NAME;
                        Id sitePreferencesId = content.Id;

                        if (content.cms__Version_Origin__c != null) {
                            sitePreferencesId = content.cms__Version_Origin__c;
                        }

                        settings.Site_Preferences_Id__c = sitePreferencesId;
                        insert(settings);
                        message = 'Created new site preferences';
                    } catch(Exception e) {
                        success = false;
                        message = 'Failed to create site preferences';
                    }
                } else if (settings.Site_Preferences_Id__c == null){
                    // If site preferences was already created but it didn't have a site preference id
                    Id sitePreferencesId = content.Id;

                    if (content.cms__Version_Origin__c != null) {
                        sitePreferencesId = content.cms__Version_Origin__c;
                    }

                    settings.Site_Preferences_Id__c = sitePreferencesId;
                    update(settings);
                    message = 'Set the site preference Id on the existing site preferences.';
                } else {
                    message = 'Site preferences already exists';
                }
            }
        } else {
            message = 'Content error';
            success = false;
        }

        return '{"success":' + success + ', "message": "' + message + '"}';
    }
 
    /*
     * @description Gets the site preferences using the custom setting ocms_mfc_SiteSettings__c
     * @return Map<String, String> - [Field Name, Value]
     */
    public Map<String, String> getSitePreferencesData() {
        if (preferencesMap == null) {
            preferencesMap = new Map<String, String>{'problem!' => 'could not find SitePreferences content or other error'};

            cms.ServiceAPI api;
            ocms_mfc_SiteSettings__c settings = ocms_mfc_SiteSettings__c.getValues(MANULIFE_CENTRAL_NAME);

            try {
                api = this.getServiceAPI();
            } catch (Exception e) {
                api = (cms.ServiceAPI)cms.ServiceEndpoint.getService('cms.ServiceAPI', new Map<String, String> {
                   'sname' => settings.Site_Name__c,
                   'page_mode' => 'production',
                   'ocmsLang' => 'en'
                });
            }

            // store the language that site prefs is instantiated with
            // ContentItem calls siteprefs as static, and during cache runs, prefs needs to be re-instantiated when the language changes
            String prefsLanguage = api.getRenderLanguage();
            String versionId = '';

            List<cms__Content_Version_Index__c> cvi = [SELECT cms__Latest__c FROM cms__Content_Version_Index__c WHERE cms__Origin__c = :settings.Site_Preferences_Id__c AND cms__Language__r.cms__Language_Code__c = :prefsLanguage];

            if (cvi.size() > 0) {
                versionId = cvi.get(0).cms__Latest__c;
            } else if (Test.isRunningTest()) {
                cms__Content__c testingContent = [SELECT Id, cms__Content_Type__r.cms__Name__c FROM cms__Content__c WHERE cms__Content_Type__r.cms__Name__c = 'SitePreferences' LIMIT 1];
                versionId = testingContent.Id;
            }
            
            if (String.isNotBlank(versionId)) {
                this.content = new cms__Content__c();
                this.content_properties = new List<cms__Attribute__c>();

                List<cms__Attribute__c> attrs = [SELECT Id, cms__Language__c, cms__Is_Simple__c, cms__Simple_Name__c, cms__Simple_Value__c, cms__Name__c, cms__Value__c, cms__Type__c, cms__Index__c, cms__Object_Id__c, cms__Object_Type__c, cms__Page_Content_Layout_Instance__c, cms__Content_Layout_Instance__c, cms__Content__c, cms__Page__c, cms__Key__c, cms__Namespace__c, cms__Requires_Rewrite__c, RecordTypeId FROM cms__Attribute__c
                        WHERE cms__Content__c = :versionId AND (cms__Language__r.cms__Language_Code__c = :prefsLanguage OR cms__Language__c = null)];
                    
                this.content_properties.addAll(attrs);

                preferencesMap = sitePreferences;
                preferencesMap.put('cacheKey', prefsLanguage.replace('_','') + pm);
            } else {
                preferencesMap = new Map<String, String>{'problem!' => 'Site Preferences is not published or does not exist: ' + settings.Site_Preferences_Id__c};
            }
        }

        return preferencesMap;
    }
}