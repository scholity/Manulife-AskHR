global with sharing class ocms_mfc_AppLauncher extends cms.ContentTemplateController {
	global ocms_mfc_AppLauncher() { }

	global ocms_mfc_AppLauncher(cms.GenerateContent gc) {
		super(gc);
	}

	global ocms_mfc_AppLauncher(cms.CreateContentController cc) {
		super(cc);
	}

	global override String getHTML() {
		return appContentRenderings.replace('{Add to Launchpad}', launchpadAdd).replace('{Tutorial}', tutorialheader).replace('{Launch App}', launchApp).replace('{Subscribed App}', alreadySubscribed);
	}

    public String appContentRenderings {
        get {
            if (appContentRenderings == null) {
                // Find the application by the application id.  This will be the content origin id
                // Get the AppDetail content template renders
                String applicationContentOriginId = ApexPages.currentPage().getParameters().get('appId');

                if(String.isBlank(applicationContentOriginId)) {
                    applicationContentOriginId = ApexPages.currentPage().getParameters().get('content_id');
                }

                cms.ServiceAPI sApi = getServiceAPI();
                ocms_TaxonomyAPI TaxonomyHelper = new ocms_TaxonomyAPI(sApi);

                TaxonomyHelper.getLatestContentRenderingsForOriginContents(new List<String>{applicationContentOriginId}, 'AppDetail');
                appContentRenderings = TaxonomyHelper.contentRenderings.get(TaxonomyHelper.contentIdsMapping.get(applicationContentOriginId));
            } 

            return appContentRenderings;
        } set;
    }

    /**
     * @description attribute tutorialheader - required
     */
    public String tutorialheader {
        get { return (getProperty('tutorialheader') != null) ? getProperty('tutorialheader') : ''; }
    }

    /**
     * @description attribute alreadySubscribed - required
     */
    public String alreadySubscribed {
        get { return (getProperty('alreadySubscribed') != null) ? getProperty('alreadySubscribed') : ''; }
    }

    /**
     * @description attribute launchpadAdd - required
     */
    public String launchpadAdd {
        get { return (getProperty('launchpadAdd') != null) ? getProperty('launchpadAdd') : ''; }
    }

    /**
     * @description attribute launchApp - required
     */
    public String launchApp {
        get { return (getProperty('launchApp') != null) ? getProperty('launchApp') : ''; }
    }
}