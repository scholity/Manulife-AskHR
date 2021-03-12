public with sharing class ocms_mfc_PageHelper {
    public ocms_mfc_PageHelper() {}

    public ocms_mfc_PageHelper(cms.CoreController cc) {
        // some day (please!), IE will just be a horror story web developers tell their grandkids
        // Note that the .put() correctly affects the response headers, but does not show as a <meta> element in the document's <head>
        ApexPages.CurrentPage().GetHeaders().put('X-UA-Compatible', 'IE=edge');
    }

    /**
     * - returns the full script tag including the src path to the external Adobe Analytics JavaScript file as defined in the Manulife Central custom setting field Analytics_JavaScript_Path
     * - if there was a problem getting this custom setting value, an HTML comment element is returned
     * 
     * @return String - script tag or comment tag if error
     */
    public String getAnalyticsScriptTag () {
        String path;

        try {
            String url = (String) ocms_mfc_SiteSettings__c.getValues('Manulife Central').get('Analytics_JavaScript_Path__c');

            if (String.isNotBlank(url)) {
                path = '<script src=\"' + url + '\" async></script>';
            } else {
                path = '<!-- blank value found for Analytics JavaScript path in Manulife Central’s Salesforce custom settings -->';
            }
        } catch (Exception ex) {
            path = '<!-- error getting Analytics JavaScript path: ' + ex.getMessage() + ' -->';
        }

        return path;
    }   // getAnalyticsScriptTag


    public String getSitePreferences() {
        return JSON.Serialize(ocms_mfc_SitePreferences.getSitePreferences());
    }
    

    public Map<String, String> mSitePreferences {
    /*
     * Allows us to refrence using keys in visualforce as such: {!mSitePrefrences['notificationMaxLoad']}
     */
        get {
            return ocms_mfc_SitePreferences.getSitePreferences();
        }
    }
}