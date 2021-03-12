public without sharing class ocms_mfc_Utility {

	private static Boolean allowLanguageChange = false;

	/**
	 * Sets a flag to prevent the UserLanguageOverride trigger from resetting changes to the LanguageLocaleKey field on the User record
	 */
	public static void bypassUserLanguageTrigger () {
		allowLanguageChange = true;
	}

	public static Boolean getBypassLanguageStatus () {
		return allowLanguageChange;
	}

	/**
	 * Determines the true API hostname for a Salesforce org using the Identity API.
	 * eg 'https://pod.salesforce.com' (most orgs)
	 * eg 'https://custom.my.salesforce.com' (my domain)
	 * eg 'https://custom--dev.pod.my.salesforce.com' (sandbox orgs)
	 */
	public static String protocolAndHost {
		get {
			if (protocolAndHost == null) {
				String orgId = UserInfo.getOrganizationId();
				String userId = UserInfo.getUserId();
				String sessionId = UserInfo.getSessionId();

				//use getSalesforceBaseUrl within batches and schedules (not Visualforce), and fix inconsistent protocol
				if (sessionId == null) return Url.getSalesforceBaseUrl().toExternalForm().replace('http:', 'https:');

				PageReference pr = new PageReference('/id/' + orgId + '/' + userId);
				pr.getParameters().put('oauth_token', sessionId);
				pr.getParameters().put('format', 'json');

				//within test context use url class, else derive from identity api
				String data = Test.isRunningTest() ? '{"urls": {"rest": "' + Url.getSalesforceBaseUrl().toExternalForm() + '"}}' : pr.getContent().toString();
				Map<String,Object> result = (Map<String,Object>)Json.deserializeUntyped(data);
				Map<String,Object> urls = (Map<String,Object>)result.get('urls');
				Url rest = new Url((String)urls.get('rest'));
				protocolAndHost = rest.getProtocol() + '://' + rest.getHost();
			}

			return protocolAndHost;
		}
	}

	/**
	 * Grabs the url for the resource, used to get the resoruce location in a controller, Example: Need to output an image inside a controller getHTML
	 * Returns String - /resource/{timestamp numbers}/{resourceName}
	 */
    public static String getResourceURL(String resourceName) {
        // Fetching the resource
        List<StaticResource> resourceList= [SELECT Name, NamespacePrefix, SystemModStamp FROM StaticResource WHERE Name = :resourceName];

        // Checking if the result is returned or not
        if(resourceList.size() == 1){
           	String namespace = resourceList[0].NamespacePrefix;

           	return Site.getPathPrefix() + '/resource/' + resourceList[0].SystemModStamp.getTime() + '/' + (namespace != null && namespace != '' ? namespace + '__' : '') + resourceName;
        }

    	return '';
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

    public static String getSiteURLForMedia (String mediaURL) {
		if (String.isNotBlank(mediaURL)) {
			String sitePrefix = Site.getPathPrefix();

			if (sitePrefix != null && mediaURL.startsWith('/servlet')) {
				mediaURL = sitePrefix + mediaURL;
			}
		} else {
			mediaURL = '';
		}

		return mediaURL;
	}	// getSiteURLForMedia

}