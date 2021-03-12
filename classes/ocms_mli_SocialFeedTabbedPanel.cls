/**
 * Definition and markup generation for Manulife.com Social Feed Tabbed Section (C105).
 *
 * @author  Saloni Mittal
 * @date    2015-Jun-26
 *
 */
global virtual with sharing class ocms_mli_SocialFeedTabbedPanel extends cms.ContentTemplateController implements cms.ServiceInterface {
    private static final String endpointTwitter;
    private static final String endpointFacebook;
    private static final String endpointInstagram;
    private static final String bearerToken;
    private static final String appId;
    private static final String appSecret;
    private static final String accessToken;

    static {
        endpointTwitter = 'https://api.twitter.com/1.1/statuses/user_timeline.json?screen_name=manulife&exclude_replies=true&include_rts=false';
        endpointFacebook = 'https://graph.facebook.com/v2.3/Manulife/posts?access_token=';
        endpointInstagram = 'https://api.instagram.com/v1/users/748266724/media/recent?access_token=';
        bearerToken = 'AAAAAAAAAAAAAAAAAAAAAC%2B5gAAAAAAApULN15YFZgl2JF9LAEJhYmS%2FURI%3DqTb08rYeIfXrvC1QeWZgM24QutijBEZq3WZoxjHftRaWnLabx0';
        appId = '1457201694595287';
        appSecret = '7fe42ef5aeda235fc648ac79f5082101';
        accessToken = '748266724.fb55e48.ca2ee6d00920441aa8aa3234fd007ee5';
    }

    private final cms.ServiceAPI oServiceAPI; // convience variable to access the ServiceAPI instance which we initialize only once
    //private final Map<String, String> oPageParametersMap; // will hold `ApexPages.currentPage().getParameters()`

    // Default constructor invoked through `executeRequest` (where AJAX parameters become POST/GET page parameters) or
    // in OrchestraCMS cache generation
    // NOTE: if your content is cachable you must ensure that `getHTML` has dependecny on `ApexPages` (POST/GET parameters, cookies, etc)
    public ocms_mli_SocialFeedTabbedPanel() { /* no need the `Layout` in the name word as we are extending ContentTemplateController */
        //super(); // not needed as per Murray McDonald's post https://stantive.my.salesforce.com/0D58000001qE596
        this.oServiceAPI = this.getServiceAPI();
    }

    // Constructor for generator
    public ocms_mli_SocialFeedTabbedPanel(cms.GenerateContent gc) {
        super(gc);
        this.oServiceAPI = this.getServiceAPI();
    }

    // Constructor for the content editor VF page
    public ocms_mli_SocialFeedTabbedPanel(cms.CreateContentController cc) {
        super(cc);
        this.oServiceAPI = this.getServiceAPI();
    }

    // Required for cms.ServiceInterface instantiation.
    global System.Type getType() {
        return ocms_mli_SocialFeedTabbedPanel.class;
    }

    // a XSS santized reference to page parameters
    public Map<String, String> oPageParametersMap {
        get {
             System.debug('>>> ocms_mli_SocialFeedTabbedPanel.oPageParametersMap');
             if (this.oPageParametersMap == null) {
                // XSS santize the data - inspired by 7.89.15 `ocmsContext.cls` - we don't need chunking since we don't leverage large values
                this.oPageParametersMap = ApexPages.currentPage() != null ?  ApexPages.currentPage().getParameters() : new Map<String,String>{};
                                              // during cache generation `ApexPages.currentPage()` is null so we fallback to empty map.
                Pattern oXSSRegexMatcher = Pattern.compile('(?i)(</?script|javascript:|<iframe|<input|<link|<object|<meta|<style|<base|<embed|url\\s*\\(|expression\\(|<[^>]*on[^=>]*(=|%3d)|".*on[^="]*(=|%3d))');

                String sValue = '';
                for (String sKey : oPageParametersMap.keySet()) {
                    sValue = oPageParametersMap.get(sKey);
                    sValue = sValue.replaceAll('(?s)[\\n\\r\\t\\x00]|(?:/\\*.*\\*/)', ''); // first cleanse the string of any cr (#13), lf(#10), horizontal tab(#9) or null characters which browsers tend to "ignore"
                    sValue = (EncodingUtil.urlDecode(sValue, 'UTF-8')).unescapeHtml4(); // decode those hidden <> see `xssAngleBrackets` in ocmsContext.cls, ex `System.debug((EncodingUtil.urlDecode('&lt;  &gt;  &#60; &#62; %3C %3E)', 'UTF-8')).unescapeHtml4());`
                    System.debug('=== ocms_mli_SocialFeedTabbedPanel.oPageParametersMap: sKey: '+ sKey + ' | sValue: ' + sValue + ' ');
                    // check for possible XSS and delete the key if so
                    if (oXSSRegexMatcher.matcher(sValue).find() == true) {
                        oPageParametersMap.remove(sKey);
                    }
                }
             }
             System.debug('=== ocms_mli_SocialFeedTabbedPanel.oPageParametersMap: this.oPageParametersMap: ' + this.oPageParametersMap);
             System.debug('<<< ocms_mli_SocialFeedTabbedPanel.oPageParametersMap');
             return this.oPageParametersMap;
        }
        set;
    }

    public String JSONResponse{get;set;}



    /**
     * @description  Used for Feed Area Tab sequence.
     */
    public String sFeedAreaTabId {
        get {
            return getProperty('sFeedAreaTabId');
        }
        set;
    }

    /**
     * @description  Used for Feed Area Tab Name.
     */
    public String sFeedAreaTabName {
        get {
            return getProperty('sFeedAreaTabName');
        }
        set;
    }

    /**
     * @description  Used for Feed Area Title.
     */
    public String sFeedAreaTitle {
        get {
            return getProperty('sFeedAreaTitle');
        }
        set;
    }

    /**
     * @description  Used for Twitter API.
     */
    public String sTwitterApi {
        get {
           String sTemp = endpointTwitter;
            if (this.oPageParametersMap.get('sTwitterApi') != null) { // GET/POST are case insensitive
                sTemp = this.oPageParametersMap.get('sTwitterApi');
            }
            else if (this.getProperty('sTwitterApi') != null) {
                sTemp = this.getProperty('sTwitterApi');
            }
            return sTemp;
        }
        set;
    }

    /**
     * @description  Used for Facebook API.
     */
    public String sFacebookApi {
        get {
           String sTemp = endpointFacebook;
            if (this.oPageParametersMap.get('sFacebookApi') != null) { // GET/POST are case insensitive
                sTemp = this.oPageParametersMap.get('sFacebookApi');
            }
            else if (this.getProperty('sFacebookApi') != null) {
                sTemp = this.getProperty('sFacebookApi');
            }
            return sTemp;
        }
        set;
    }

    /**
     * @description  Used for Instagram API.
     */
    public String sInstagramApi {
        get {
           String sTemp = endpointInstagram;
            if (this.oPageParametersMap.get('sInstagramApi') != null) { // GET/POST are case insensitive
                sTemp = this.oPageParametersMap.get('sInstagramApi');
            }
            else if (this.getProperty('sInstagramApi') != null) {
                sTemp = this.getProperty('sInstagramApi');
            }
            return sTemp;
        }
        set;
    }

    /**
     * @description  Used for Twitter Bearer Token.
     */
    public String sBearerToken {
        get {
           String sTemp = bearerToken;
            if (this.oPageParametersMap.get('sBearerToken') != null) { // GET/POST are case insensitive
                sTemp = this.oPageParametersMap.get('sBearerToken');
            }
            else if (this.getProperty('sBearerToken') != null) {
                sTemp = this.getProperty('sBearerToken');
            }
            return sTemp;
        }
        set;
    }

    /**
     * @description  Used for Facebook App Id.
     */
    public String sAppId {
        get {
           String sTemp = appId;
            if (this.oPageParametersMap.get('sAppId') != null) { // GET/POST are case insensitive
                sTemp = this.oPageParametersMap.get('sAppId');
            }
            else if (this.getProperty('sAppId') != null) {
                sTemp = this.getProperty('sAppId');
            }
            return sTemp;
        }
        set;
    }

    /**
     * @description  Used for Facebook App Secret.
     */
    public String sAppSecret {
        get {
           String sTemp = appSecret;
            if (this.oPageParametersMap.get('sAppSecret') != null) { // GET/POST are case insensitive
                sTemp = this.oPageParametersMap.get('sAppSecret');
            }
            else if (this.getProperty('sAppSecret') != null) {
                sTemp = this.getProperty('sAppSecret');
            }
            return sTemp;
        }
        set;
    }

    /**
     * @description  Used for Instagram Access Token.
     */
    public String sAccessToken {
        get {
           String sTemp = accessToken;
            if (this.oPageParametersMap.get('sAccessToken') != null) { // GET/POST are case insensitive
                sTemp = this.oPageParametersMap.get('sAccessToken');
            }
            else if (this.getProperty('sAccessToken') != null) {
                sTemp = this.getProperty('sAccessToken');
            }
            return sTemp;
        }
        set;
    }

    /**
     * @description  Used for Tweet To text.
     */
    public String sTweetToText {
        get {
            return getProperty('sTweetToText');
        }
        set;
    }

    /**
     * @description  Used for Feed Area Follow Us Link Text.
     */
    public String sFeedAreaFollowLinkText {
        get { return getProperty('sFeedAreaFollowLinkText'); }
    }

    /**
     * @description  Used for Feed Area Error Message.
     */
    public String sFeedAreaError {
        get {
            return getProperty('sFeedAreaError');
        }
        set;
    }

    /**
     * @description  Used for loading text.
     */
    public String sLoadingText {
        get {
            return getProperty('sLoadingText');
        }
        set;
    }

    /**
     * @description  Used for Facebook follow script.
     */
    public String sFBFollowScript {
        get {
            return getProperty('sFBFollowScript');
        }
        set;
    }

    global String executeRequest(
            Map<String, String> oExecuteRequestParametersMap /* already same as `this.oPageParametersMap` because of default constructor since these
                                                       are passed as a POST/GET parameters BUT this is an issue for tests where the value is passed
                                                       direclty as a method call - so we must use `System.currentPageReference().getParameters().put('action', ...);`
                                                       IMPRV: make it so passed value updates our getParameters automtically */
     ) {
        // sync up our page map with passed value. TODO: determine if this is safe to overwrite our POST/GET parameters
        this.oPageParametersMap.putAll(oExecuteRequestParametersMap);

        String sAction = this.oPageParametersMap.get('action');
        String sTabName = this.oPageParametersMap.get('tab');
        String sResponse = '{"bSuccess":false,"sMessage":"' + ((this.sFeedAreaError != null) ? this.sFeedAreaError : 'Feeds failed to load.') + '"}';

         if(sAction == 'getSocialFeedsAsJSON') {
            sResponse =  this.getSocialFeedsAsJSON(sTabName);
        }

        return sResponse;
    }

    public String getSocialFeedsAsJSON(String sTabName) {
        HTTPRequest request = new HTTPRequest();
        if (sTabName == 'Twitter') {
            request.setEndpoint(this.sTwitterApi);
            request.setHeader('Authorization', 'Bearer ' + this.sBearerToken);
        } else if (sTabName == 'Facebook') {
            request.setEndpoint(this.sFacebookApi + this.sAppId + '|' + this.sAppSecret);
        } else if (sTabName == 'Instagram') {
            request.setEndpoint(this.sInstagramApi + this.sAccessToken);
        }
        request.setCompressed(true);
        request.setMethod('GET');

        HTTP http = new HTTP();
        HTTPResponse response = http.send(request);

        if(response.getStatusCode() != 200) {
            String responseMessage = 'HTTP ' + response.getStatusCode() + ' : ' + response.getStatus();
            JSONResponse = '{"bSuccess":false,"sMessage":"' + ((this.sFeedAreaError != null) ? this.sFeedAreaError : 'Feeds failed to load.') + '"}';
        }

        JSONResponse = '{"bSuccess":true,"sMessage":' + response.getBody() + '}';
        return JSONResponse;
    }

    /**
     * @description  Generates mark-up for social feeds tabbed section content.
     * @return  String  A string of mark-up used to generate the content.
     */
    global override String getHTML() {
        String sHTML = '<!-- >>> ocms_mli_SocialFeedTabbedPanel.getHTML(...) '
            + (this.pm == 'prev' ? 'this.content_layout_instance=' + this.content_layout_instance : '').escapeHTML4()
            + ' -->\n';  // to fix any jQuery parsing issue and it's a good design pattern, see: https://pl5.projectlocker.com/Stantive/PSTools/trac/wiki/gotcha/OCMSCachingMissingMarkup

        sHTML =+  '<div role="tabpanel" id="socialFeedsTab' + ((this.sFeedAreaTabId != null) ? this.sFeedAreaTabId : 'None') + '" class="socialMediaTab tabSection section'
	                   +  ((this.sFeedAreaTabName != null) ? this.sFeedAreaTabName : 'None') + ' hidden';
        if (this.sFeedAreaTabId == '1') {
            sHTML += ' is-active';
        }
        sHTML += '">';
        if (this.sFeedAreaTabName == 'Facebook') {
            shtml += ((this.sFBFollowScript != null) ? this.sFBFollowScript : '');
        }
        sHTML                 +=     '<div class="tabContent">'
                              +        '<div data-hw-module="module/social/' + ((this.sFeedAreaTabName != null) ? this.sFeedAreaTabName : 'None') + 'Feed" class="socialFeed"'
                              +        ' data-hw-options="text: { title: \'' + ((this.sFeedAreaTitle != null) ? this.sFeedAreaTitle : 'Recent Activity')
                              +        '\', loadingAlt: \'' + ((this.sLoadingText != null) ? this.sLoadingText : 'Follow')
                              +        '\', follow: \'' + ((this.sFeedAreaFollowLinkText != null) ? this.sFeedAreaFollowLinkText : 'Follow');
        if (this.sFeedAreaTabName == 'Twitter') {
            sHTML +=    '\', tweetTo: \'' + ((this.sTweetToText != null) ? this.sTweetToText : 'Tweet to @Manulife');
        }
        sHTML +=        '\', failedToLoadMessage: \'' + ((this.sFeedAreaError != null) ? this.sFeedAreaError : 'Feeds failed to load.') + '\' }, ';
        if (this.sFeedAreaTabName == 'Facebook') {
            sHTML +=    'sFacebookApi: \'' + this.sFacebookApi + '\', '
                  +     'sAppId: \'' + this.sAppId + '\', '
                  +     'sAppSecret: \'' + this.sAppSecret + '\'';
        }
        if (this.sFeedAreaTabName == 'Twitter') {
            sHTML +=    'sTwitterApi: \'' + this.sTwitterApi + '\', '
                  +     'sBearerToken: \'' + this.sBearerToken + '\'';
        }
        if (this.sFeedAreaTabName == 'Instagram') {
            sHTML +=    'sInstagramApi: \'' + this.sInstagramApi + '\', '
                  +     'sAccessToken: \'' + this.sAccessToken + '\'';
        }
        sHTML                 +=       '">'
                              +        '<!-- Social Feed Area -->'
                              +        '</div>'
                              +     '</div>'
                              + '</div>';

        // we don't want to bleed potential vector of attack info, so we only output our debug in prev mode
        sHTML += '<!-- <<< ocms_mli_SocialFeedTabbedPanel.getHTML(...) '
               + (this.pm == 'prev' ? 'Limits.getCpuTime()=' + Limits.getCpuTime() + ', Limits.getAggregateQueries()=' + Limits.getAggregateQueries() + ', Limits.getHeapSize()=' + Limits.getHeapSize() : '').escapeHTML4()
               + ' -->\n'; //  to fix any jQuery parsing issue and it's a good design pattern, see: https://pl5.projectlocker.com/Stantive/PSTools/trac/wiki/gotcha/OCMSCachingMissingMarkup

        return sHTML;
    }
}