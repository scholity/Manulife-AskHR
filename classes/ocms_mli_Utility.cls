// *********************************
// BEFORE CONTRIBUTING TO THIS CLASS
// *********************************
//
// Ensure that the method you wish to add truly belongs here, use the following checklist
//
// 1. Will this method be used across multiple classes? (Y)
//
// 2. Does adding this method to this class cut down on copy/paste code? (Y)
//
// 3. Is this method generic enough to be here? (Y)
//
// Be sure to update ocms_mli_utility_test as well.
//
public with sharing class ocms_mli_Utility {

	public ocms_mli_Utility() {}

    public ocms_mli_Utility(cms.CoreController cc) {}

    /**
     * GetResourceURL - provided the name of the resource this method can build a URL string to a static resource from within
     *                  an Apex class. This is helpful for content controllers that include javascript resources in their
     *                  GetHTML methods.
     * @param  resourceName - Name of the resource you wish to create a URL for. ie 'ocms_mli_pageSupport'
     *         pathToFile   - Path to the file within the resource you wish to include, no leading slashes ie 'js/ps-mli.js'
     * @return              - Returns full URL with dateTimeStamp otherwise returns an empty string.
     */
    public static String getResourceURL(String resourceName, String pathToFile){

        List<StaticResource> resourceList = [SELECT Name, NamespacePrefix, SystemModStamp FROM StaticResource WHERE Name = :resourceName];
        String returnURL = '';

        if (resourceList.size() == 1){

            String namespace = resourceList[0].NamespacePrefix;
            Long systemModStamp = resourceList[0].SystemModStamp.getTime();
            returnURL = '/resource/' + systemModStamp + '/' + (namespace != null && namespace != '' ? namespace + '__' : '') + resourceName + '/' + pathToFile;

        }

        return returnURL;

    }

    /**
     * @description used with cms.Node and cms.Link objects, will return a blank string instead of "null" if null.
     * @param  javascript cms.Link javascript member.
     * @return            String containing javascript for popup window.
     */
    public static String getLinkScript(String javascript){
        return ((javascript != null) ? javascript : '');
    }

    /**
     * @description used with cms.Node and cms.Link objects, this is to return return "javascript:;" instead of "#" or "null" values and to propelry encode spaces.
     *              `#` will jump the page to top, `null` is output by OrchestraCMS if no attribute present, `` will reload a page, no `href` will mess with accessibility interfaces. (see: http://stackoverflow.com/a/15885150/913223)
     * @param  targetPage cms.Link targetPage member.
     * @return            String containing either valid URL or `javascript:;`
     */
    public static String getLinkHref(String targetPage){
        String sURL = (targetPage != null && targetPage != '#') ? targetPage : 'javascript:;';
        sURL = sURL.replace(' ', '+'); // encoding spaces
        return sURL;
    }


    /**
     * @description used with cms.Node and cms.Link objects  for the target attribute. It will return "_self" if value is "" or "null".
     *              Having target="" fails W3C validation as a value is required, `_self` is the default behaviours as per the spec.
     * @param  targetPage cms.Link targetPage member.
     * @return            String containing either valid URL or `javascript:;`
     */
    public static String getLinkTarget(String sTarget){
        String sReturn = (sTarget != null && sTarget != '') ? sTarget : '_self';
        return sReturn;
    }



    /**
     * @description used with any input to prevent writing 'null' to the page when a value is empty.
     * @param  input any input string.
     * @return        String containing either the original value or left empty.
     */
    public static String noNull(String input){
        return ((input != null) ? input : '');
    }

    /**
     * - returns the full script tag including the src path to the external Adobe Analytics JavaScript file as defined in the Manulife.com custom setting field Analytics_JavaScript_Path
     * - if there was a problem getting this custom setting value, an HTML comment element is returned
     *
     * @return String - script tag or comment tag if error
     */
    public String getAnalyticsScriptTag() {
        String path;

        try {
            String url = (String) ocms_mli_SiteSettings__c.getValues('Manulife.com').get('Analytics_JavaScript_Path__c');

            if (String.isNotBlank(url)) {
                path = '<script src=\"' + url + '\"></script>';
            } else {
                path = '<!-- blank value found for Analytics JavaScript path in Manulife Central’s Salesforce custom settings -->';
            }
        } catch (Exception ex) {
            path = '<!-- error getting Analytics JavaScript path: ' + ex.getMessage() + ' -->';
        }

        return path;
    }

}