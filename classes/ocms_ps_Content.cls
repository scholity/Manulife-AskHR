//	ocms_ps_Content

global virtual with sharing class ocms_ps_Content extends cms.ContentTemplateController {
	public ocms_ps_Content() {
		// Unexpected instantiation of class!
	}


	global ocms_ps_Content(cms.CreateContentController cmsCC) {
		super(cmsCC);
	}


	global ocms_ps_Content(cms.GenerateContent cmsGC) {
		super(cmsGC); 
	}


	String testSitePrefix = '';

	public ocms_ps_Content(String sitePrefixForTesting) {
		if (!Test.isRunningTest()) {
			System.assert(false, 'This constructor should only be called when running a class test!');
		}
		testSitePrefix = sitePrefixForTesting;
	}


	global virtual override String getHTML () {
		return '<span style="display: none;">override me!</span>';
	}

	public Map<String, String> sitePreferences {
		get {
			if (sitePreferences == null) {
				sitePreferences = ocms_mfc_SitePreferences.getSitePreferences();
			}

			return sitePreferences;
		} set;
	}

	/**
	 * similar, but not identical to OrchestraCMS’s GeneralUtil.getValidImageUrl() this method will make the necessary
	 * adjustments to the value of a content item’s 'image' attribute, as saved by OrchestraCMS’s image selector.
	 * This is expected to be of the form '/servlet/servlet.FileDownload?file=XXXXXXXXXXXXXXX'.
	 * Site.getPrefix() deprecated as of API 30 in favour of getPathPrefix()
	 * 
	 * @param  mediaURL - domain relative path string to media library asset
	 * @return media library URL suitable for inclusion in the DOM, starting with the site prefix if necessary; returns
	 *         an unmodified mediaURL if it did not begin with '/servlet'
	 */

    public String getSiteURLForMedia (String mediaURL) {
		if (String.isNotBlank(mediaURL)) {
			String sitePrefix = !Test.isRunningTest() ? Site.getPathPrefix() : testSitePrefix;

			if (sitePrefix != null && mediaURL.startsWith('/servlet')) {
				mediaURL = sitePrefix + mediaURL;
			}
		} else {
			mediaURL = '';
		}

		return mediaURL;
	}	// getSiteURLForMedia

	/**
	 * Attempts get value from the site prefences object and returns it. This can be useful to retrieve attributes
	 * that are URL's. Using this object will cache the site preferences object and render it multiple times.
	 * 
	 * @param  attributeName - The key in the site preferences object to get.
	 * @return                 The value of the site preference object.
	 */
	public String getSitePreferncesUrl (String attributeName) {
		return sitePreferences.get(attributeName);
	} // getSitePreferncesUrl

	/**
	 * Attempts to get an attribute from the sitePreferences.  If the object is found then it will determe if the
	 * URL has a '?' and appends the correct character to continue to URL.  It will go through our map and use the
	 * key as the param name and the value as the param value.
	 *
	 * Example: www.manulife.com - This value is retrieved from the sitePreferences object.
	 * Map<String, String> {'queryParam1' => 'queryValue1', 'queryParam2' => 'queryValue2'}
	 *
	 * Result = www.manulife.com?queryParam1=queryValue1&queryParam2=queryValue2
	 * 
	 * @param  attributeName   [description]
	 * @param  queryParameters [description]
	 * @return                 [description]
	 */
	public String appendQueryStringsToSitePreferences (String attributeName, Map<String, String> queryParameters) {
		String url = getSitePreferncesUrl(attributeName);

		if (url != null) {
			if (url.indexOf('?') < 0) {
				url += '?';
			} else {
				url += '&';
			}
			
			for (String paramName : queryParameters.keySet()) {
				url += paramName + '=' + queryParameters.get(paramName) + '&';
			}
		}  else {
			url = '';
		}		

		return url.removeEnd('&');
	} // appendQueryStringsToSitePreferences

	/**
	 * Clears SitePreferences cache when doing a content rendering cache if the language is different.
	 * When content is being rendered that has multiple languages attached, it will do all of the rendering caches in a single transaction.
	 * Site Preferences gets set to the first language it renders and then all further renderings would be using that languages cached version.
	 * This code checks to see if the renderLanguage has changed and if it has it will get a new sitePreferences with the new render language.
	 */
   	public void validateSitePreferencesCache() {
   		if (sitePreferences.get('renderLanguage') != getServiceAPI().getRenderLanguage()) {
			sitePreferences = null;
			ocms_mfc_SitePreferences.preferencesMap = null;
			ocms_TaxonomyAPI.contentIdsToPaths = new Map<String, List<String>>();
		}
   	}
}	// <c ocms_ps_Content>