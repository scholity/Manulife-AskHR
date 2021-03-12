global with sharing class ocms_GSASearchService implements cms.ServiceInterface {

    public ocms_GSASearchService() { }

    public static final String comEndpoint;
    public static final String centralEndpoint;
    public static final String centralClientCertificateName;

    
    /*
    DS,2016-jul-26: GSA language collections are based on following as of 2016-Jul-26 email 'Fwd: Support for Search Collections by Language'     
	
	"""
	Each site, Manulife.com and MFCentral, is configured for each language plus language collections for the MFCentral mobile users. For a total of 21 new collections. This will affect the &site= parameter used for search. Simply append a dash “-“ and the preferred language code to the site value. For example, instead of &site=com, use &site=com-en for searching English only content on Manulife.com.
	 
	Manulife.com Collections
	com - all of manulife.com public content
	com-en - all of manulife.com public English content
	com-fr - all of manulife.com public English and French content
	com-id - all of manulife.com public English and Indonesian content
	com-ja - all of manulife.com public English and Japanese content
	com-th - all of manulife.com public English and Thai content
	com-vi - all of manulife.com public English and Vietnamese content
	com-zh -all of manulife.com public English and Chinese content
	
	MFCentral Collections
	mfc - all of MFCentral public and secure content
	mfc-en - all of MFCentral public and secure English content
	mfc-fr - all of MFCentral public and secure English and French content
	mfc-id - all of MFCentral public and secure English and Indonesian content
	mfc-ja - all of MFCentral public and secure English and Japanese content
	mfc-th - all of MFCentral public and secure English and Thai content
	mfc-vi - all of MFCentral public and secure English and Vietnamese content
	mfc-zh - all of MFCentral public and secure English and Chinese content
	
	MFCentral Mobile Collections
	mfcm - all of MFCentral public content
	mfcm-en - all of MFCentral public English content
	mfcm-fr - all of MFCentral public English and French content
	mfcm-id - all of MFCentral public English and Indonesian content
	mfcm-ja - all of MFCentral public English and Japanese content
	mfcm-th - all of MFCentral public English and Thai content
	mfcm-vi - all of MFCentral public English and Vietnamese content
	mfcm-zh - all of MFCentral public English and Chinese content
	"""
    */
    public static final String GSASite_MFCentral = 'mfc';
    public static final String GSASite_MFCentral_Mobile = 'mfcm'; // DS,2016-jul-26: this actually means "mobile or not-on-a-Manulife-network" //IMPRV: refactor these constants as their meaning no longer fits the 'langauge sets' that are still passed as `site` parameter and possibly flatter the abstract of the search class 
    public static final String GSASite_Manulife_com = 'com';
    public static final String oSFLangToGSALangDefault = 'en';
    public static final Map<String,String> oSFLangToGSALangMap = new Map<String,String>{
        // 2016-Jul-26: lis from: `https://help.salesforce.com/HTViewHelpDoc?id=faq_getstart_what_languages_does.htm` 

        /* 
        Fully Supported Languages
        =========================*/
        'zh_CN' => 'zh' // Chinese (Simplified) 
		,'zh_TW' => 'zh' // Chinese (Traditional) 
		,'en_US' => 'en' // English 
		,'fr' => 'fr' // French 
		,'ja' => 'ja' // Japanese 
		,'th' => 'th' // Thai 
		
		/* 
        End-User Langauges
        ==================*/
        ,'vi' => 'vi'
        ,'in' => 'id'


        /* 
        Platform-Only Languages
        =======================*/
        ,'zh_SG' => 'zh' // Chinese (Simplified—Singapore): zh_SG
        ,'zh_HK' => 'zh' // Chinese (Traditional—Hong Kong): 
    };
    
    public static Integer searchGSARequestTimeout = 10; // default value must match what's in `39@ocms_mfc_SitePreferences.cls`, in seconds
        

    /*
       The custom settings are stored in ocms_mfc_SiteSettings__c for both Central and .com because
       if the limitations of custom objects. If we were to reference the custom setting called
       ocms_mli_SiteSettings we would be adding another reference to an object where we only have
       7 custom objects availible in our implementation. This is not a clean solution but it helps us
       keep within our custom object limitations.
    */

    static {
        comEndpoint = (String) ocms_mfc_SiteSettings__c.getValues('Manulife Central').get('GSA_MLI_Endpoint__c');
        centralEndpoint = (String) ocms_mfc_SiteSettings__c.getValues('Manulife Central').get('GSA_MFC_Endpoint__c');
        centralClientCertificateName = (String) ocms_mfc_SiteSettings__c.getValues('Manulife Central').get('GSA_Client_Certificate_Name__c');
    }

    public System.Type getType() {
        return ocms_GSASearchService.class;
    }

    public class GSASearchServiceException extends Exception {
        public Integer HttpRequestCode {get; set;}

        public GSASearchServiceException (String error, Integer code) {
            this(error);
            this.HttpRequestCode = code;
        }
    }
    public class GSASearchServiceTermsException extends Exception {}

    public class SearchTerm {
        /**
         * @description
         * @required true
         */
        public String q {get; set;}

        /**
         * @description The search string
         * @required true
         */
        public String site {get; set;}

        /**
         * @description Starting offset for result set
         * @required false
         */
        public String start {get; set;}

        /**
         * @description The Number of results to return
         * @required false
         */
        public String num {get; set;}

        /**
         * @description one of "date:D:S:d1" (date descending) or "date:A:S:d1" (date ascending)
         * @required false
         */
        public String sOrder {get; set;}

        /**
         * @description pass facet:xxxxxx when filtering by facet (GSA facet names tbd)
         * @required false
         */
        public String requiredFields {get; set;}

        /**
         * @description the username accessing the search, this should be the federate id from the current users record
         * @required false
         */
        public String username {get; set;}

        /**
         * @description the GSA will return a token after performing a search this is the storage for it
         * @required false
         */
        public String gsaId {get; set;}

        /**
         * @description the responseCookies is never something that we send out as part of a search
         *              this object comes back from the GSA.
         * @required false
         */
        public String responseCookies {get; set;}

        public String requestUrl {get; set;}

        /**
         * @description the searchResponse from the GSA Appliance
         */
        public String searchResponse {get; set;}

        public SearchTerm (Map<String, String> params) {
            this.q = params.get('q');
            this.start = params.get('start');
            this.num = params.get('num');
            this.username = null;
            this.gsaId = null;

            if (params.get('sOrder') == 'asc') {
                this.sOrder = 'date:A:S:d1';
            } else if (params.get('sOrder') == 'desc') {
                this.sOrder = 'date:D:S:d1';
            }

            this.requiredFields = params.get('requiredFields');

            if (params.containsKey('searchId') && String.isNotEmpty(params.get('searchId'))) {
                this.username = params.get('searchId');
            }

            if (params.containsKey('searchKey') && String.isNotEmpty(params.get('searchKey'))) {
                this.gsaId = params.get('searchKey');
            }

            searchResponse = '';
            requestUrl = '';
        }

        public String search() {
            validateTerms();

            HTTPRequest feedRequest = new HTTPRequest();

            try {
                String endpointRequest = 'search';
                if (site.containsIgnoreCase(GSASite_Manulife_com)) {
                    requestUrl = comEndpoint + '/' + endpointRequest;
                } else if (site.containsIgnoreCase(GSASite_MFCentral)) {
                    if (this.username != null && this.gsaId != null) {
                        feedRequest.setHeader('Cookie','GSA_SESSION_ID=' + this.gsaId + ';USERNAME=' + this.username);
                    } else if (this.username != null) {
                        feedRequest.setHeader('Cookie','USERNAME=' + this.username);
                    }

                    if (String.isNotEmpty(centralClientCertificateName)) {
                        feedRequest.setClientCertificateName(centralClientCertificateName);
                    }

                    requestUrl = centralEndpoint + '/' + endpointRequest;
                } else if (site.containsIgnoreCase(GSASite_MFCentral_Mobile)) {
                    if (String.isNotEmpty(centralClientCertificateName)) {
                        feedRequest.setClientCertificateName(centralClientCertificateName);
                    }
                    requestUrl = centralEndpoint + '/' + endpointRequest;
                }

                System.debug(feedRequest.getHeader('Cookie'));

                feedRequest.setEndpoint(buildQueryStringFromTerm());
                feedRequest.setCompressed(true);
                feedRequest.setMethod('GET');
                // get site preferences for the time out
                feedRequest.setTimeout(ocms_GSASearchService.searchGSARequestTimeout * 1000);

                HTTP http = new HTTP();
                HTTPResponse feedResponse = http.send(feedRequest);
                responseCookies = feedResponse.getHeader('Set-Cookie');

                if (feedResponse.getStatusCode() != 200) {
                    throw new GSASearchServiceException('Searching term failed failed with code ' + feedResponse.getStatusCode() + ': ' + feedResponse.getStatus(), feedResponse.getStatusCode());
                }

                searchResponse = feedResponse.getBody();
            } catch (CalloutException e) {
                if (e.getMessage() == 'Read timed out') {
                    throw new GSASearchServiceException('Search has timed out.', 408);
                } else {
                    throw new GSASearchServiceTermsException(e.getMessage() + ' Requesting URL : ' + requestUrl);
                }
            }

            return searchResponse;
        }

        public void validateTerms() {
            if (String.isEmpty(this.q)) {
                throw new GSASearchServiceTermsException('Search must be provided a search parameter to operate.');
            }
        }

        /**
         * Takes in any qualified requestUrl (i.e. www.endpoint.com/search) and appends the current instance of the objects
         * variables as valid query paramters
         *
         * @param the requestUrl you wish to have the parameters attached to
         * @return String the new requestUrl with the parameters attached
         */
        private String buildQueryStringFromTerm() {
            //Defect 9954, 9952 - update to allow quoted search terms.
            requestUrl += '?q=' + EncodingUtil.urlEncode(this.q.trim(), 'UTF-8') + '&';
            requestUrl += 'site=' + this.site + '&';

            requestUrl += (this.start != null) ? 'start=' + this.start + '&' : '';
            requestUrl += (this.num != null) ? 'num=' + this.num + '&' : '';
            requestUrl += (this.sOrder != null) ? 'sort=' + this.sOrder + '&' : '';

            // People has it's own facet that doesn't fall inside the mfc_location object
            if (this.requiredFields == 'People') {
                requestUrl += 'requiredfields=mfc_content_source:People&';
            } else if (this.requiredFields == 'Communities') {
                requestUrl += 'requiredfields=mfc_content_source:Communities&';
            } else {
                requestUrl += (this.requiredFields != null && String.isNotEmpty(this.requiredFields)) ? 'requiredfields=mfc_content_source:' + this.requiredFields.replace(' ', '+') + '&' : '';
            }

            requestUrl = requestUrl.removeEnd('&');

            return requestUrl;
        }
    }

    private class SuggestTerm {
        /**
         * @description partial search string
         * @required true
         */
        public String q {get; set;}

        /**
         * @description one of "mfc" (MFCentral) or "com" (.com)
         * @required true
         */
        public String site {get; set;}

        /**
         * @description (optional | default 10) : number of suggestions to return
         * @required false
         */
        public String max {get; set;}

        /**
         * @description the response of the request to get the suggest terms based on the passed (q) term
         */
        public String suggestResponse {get; set;}

        /**
         * @description the resulting site where the callout was made
         */
        public String requestUrl {get; set;}

        public SuggestTerm (Map<String, String> params) {
            this.q = params.get('q');
            this.max = params.get('max');

            suggestResponse = '';
            requestUrl = '';
        }

        public String suggest() {
            validateTerms();

            try {
                HTTPRequest feedRequest = new HTTPRequest();

                String endpointRequest = 'suggest';

                if (site == 'COM') {
                    requestUrl = comEndpoint + '/suggest';
                } else {
                    /*
                    ** Defect 9960 - Ensure request includes security certificate if available for calls originating in MFCentral
                     */
                    if (String.isNotEmpty(centralClientCertificateName)) {
                        feedRequest.setClientCertificateName(centralClientCertificateName);
                    }
                    requestUrl = centralEndpoint + '/suggest';
                }

                feedRequest.setEndpoint(buildQueryStringFromTerm());
                feedRequest.setCompressed(true);
                feedRequest.setMethod('GET');

                HTTP http = new HTTP();
                HTTPResponse feedResponse = http.send(feedRequest);

                if (feedResponse.getStatusCode() != 200) {
                    throw new GSASearchServiceException('Searching term failed failed with code ' + feedResponse.getStatusCode() + ': ' + feedResponse.getStatus());
                }

                suggestResponse = feedResponse.getBody();
            } catch (CalloutException e) {
                throw new GSASearchServiceTermsException(e.getMessage() + ' Requesting URL : ' + requestUrl);
            }

            return suggestResponse;
        }

        public void validateTerms() {
            if (String.isEmpty(this.q)) {
                throw new GSASearchServiceTermsException('Suggesting of terms call must be provided a search parameter to operate.');
            }
        }

        /**
         * Takes in any qualified requestUrl (i.e. www.endpoint.com/suggest) and appends the current instance of the objects
         * variables as valid query paramters
         *
         * @param the requestUrl you wish to have the parameters attached to
         * @return String the new requestUrl with the parameters attached
         */
        private String buildQueryStringFromTerm() {
            requestUrl += '?q=' + this.q.trim().replace(' ', '+') + '&';
            requestUrl += 'site=' + this.site + '&';
            requestUrl += (this.max != null) ? 'max=' + this.max + '&' : '';

            requestUrl = requestUrl.removeEnd('&');

            System.debug('Search requestUrl: ' + requestUrl);

            return requestUrl;
        }
    }


    public String executeRequest(Map<String, String> params) {
        String action = params.get('action');
        String site_name = params.get('sname');
        try {
            ocms_GSASearchService.searchGSARequestTimeout = Integer.valueOf(params.get('sgrt'));
        }
        catch (Exception e) {}
        String response = '{"success": "false", "message":"Unknown action"}';

        if (action == 'getCoveoToken') {
            HttpRequest req = new HttpRequest();
            req.setEndpoint('https://platform.cloud.coveo.com/rest/search/token');
            req.setMethod('POST');

            String sandbox = UserInfo.getUserName().substringAfterLast('.');
            if(sandbox != 'uat2' && sandbox != 'uat') {
                sandbox = 'prod';
            }
            Coveo_API_Key__c coveoKeys = [SELECT Key__c, OrgID__c FROM Coveo_API_Key__c WHERE Name = :sandbox];

            req.setHeader('Authorization', 'Bearer ' + coveoKeys.Key__c);
            req.setHeader('Content-Type', 'application/json');

            String nameString = 'SalesforceUser:Irrelevant:' + UserInfo.getUserName() + '|' + UserInfo.getUserEmail();
            //String nameString = 'anonymous@coveo.com';

            String body = '';
            String filterString = '';
            try {
                AskHR_CoveoUtill AskHRUserInfo = new AskHR_CoveoUtill();
                filterString = AskHRUserInfo.getUserFilter();

                body = '{"filter":"' + filterString.replace('"', '\\"') + '","userIds":[{"name":"' + nameString + '","provider":"Email Security Provider", "type": "User"}]}';
            }catch (Exception e) {
                body = '{"userIds":[{"name":"' + nameString +'","provider":"Email Security Provider", "type": "User"}]}';
            }
            req.setBody(body);

            Http http = new Http();
            HTTPResponse res = http.send(req);
            response = '{"success": "true", "message":' + res.getBody() + ', "orgID":"' + coveoKeys.OrgID__c + '", "filterString":"'+ filterString.replace('"', '\\"') +'"}';

        } else if (action == 'getMFCResults') {
            try {
                SearchTerm st = new SearchTerm(params);
                // use MFC’s "mobile" GSA site if they are not recognized as an internal IP
                st.site = ocms_mfc_IPUtility.isInternalIP() ? GSASite_MFCentral : GSASite_MFCentral_Mobile;

                // IMPRV: once client requests to have the langauge sets for Manulife.com too, possibly refactor this inot the `.search(...)` function
                // based on user's langauge prefference append a language specific collection IF it exists in OrchestraCMS active languages list. 
                // getServiceApi().getLanguageOptions(); will return inactive languages - direct query instead
		        Set <String> languageSet = new Set <String>();
		        for(cms__Language__c language : [SELECT cms__Language__c, cms__Language_Code__c FROM cms__Language__c
		            WHERE cms__Sites__r.cms__Site_Name__c = :site_name AND cms__Active__c = true]
		        ) {
		            languageSet.add(language.cms__Language_Code__c);
		        }
		        // if user language is in the list and exists in the GSA supported langauges then append the language to get the tailored 
		        // langauge collection, otherwise we will get the default collleciton
		        if (languageSet.contains(UserInfo.getLanguage()) == true && ocms_GSASearchService.oSFLangToGSALangMap.containsKey(UserInfo.getLanguage()) == true) {
		            st.site = st.site + '-' + ocms_GSASearchService.oSFLangToGSALangMap.get(UserInfo.getLanguage());
		        }
		        else {
		            st.site = st.site + '-' + ocms_GSASearchService.oSFLangToGSALangDefault;		          
		        }
		        //System.assert(false, 'UserInfo.getLanguage(): ' + UserInfo.getLanguage() + ' | `languageSet`=' + languageSet + ' | ocms_GSASearchService.oSFLangToGSALangMap=' + ocms_GSASearchService.oSFLangToGSALangMap);
                
                // This will give me back the raw data.
                st.search();

                response = '{"success":"true","searchresponse":' + JSON.serialize(st.searchResponse) + ', "requestUrl":"' + st.requestUrl + '", "responseCookies": "' + st.responseCookies + '", "params": ' + JSON.serialize(params) + '}';
            } catch (GSASearchServiceException gsae) {
                response = '{"success": false, "message": "' + gsae.getMessage() + '", "errorCode" : ' + gsae.HttpRequestCode + '}';
            } catch (Exception e) {
                response = '{"success": false, "message": "' + e.getMessage() + '"}';
            }
        }  else if (action == 'getMFCMobileResults') {
            try {
                SearchTerm st = new SearchTerm(params);
                st.site = GSASite_MFCentral_Mobile;

                // IMPRV: once client requests to have the langauge sets for Manulife.com too, possibly refactor this inot the `.search(...)` function
                // based on user's langauge prefference append a language specific collection IF it exists in OrchestraCMS active languages list. 
                // getServiceApi().getLanguageOptions(); will return inactive languages - direct query instead
                Set <String> languageSet = new Set <String>();
                for(cms__Language__c language : [SELECT cms__Language__c, cms__Language_Code__c FROM cms__Language__c
                    WHERE cms__Sites__r.cms__Site_Name__c = :site_name AND cms__Active__c = true]
                ) {
                    languageSet.add(language.cms__Language_Code__c);
                }
                //System.assert(false, 'UserInfo.getLanguage(): ' + UserInfo.getLanguage() + ' | `languageSet`=' + languageSet);
                // if user language is in the list and exists in the GSA supported langauges then append the language to get the tailored 
                // langauge collection, otherwise we will get the default collleciton
                if (languageSet.contains(UserInfo.getLanguage()) == true && ocms_GSASearchService.oSFLangToGSALangMap.containsKey(UserInfo.getLanguage()) == true) {
                    st.site = st.site + '-' + ocms_GSASearchService.oSFLangToGSALangMap.get(UserInfo.getLanguage());
                }
                else {
                    st.site = st.site + '-' + ocms_GSASearchService.oSFLangToGSALangDefault;                  
                }
                

                // This will give me back the raw data.
                st.search();

                response = '{"success":"true","searchresponse":' + JSON.serialize(st.searchResponse) + ', "requestUrl":"' + st.requestUrl + '", "responseCookies": "' + st.responseCookies + '", "params": ' + JSON.serialize(params) + '}';
            } catch (GSASearchServiceException gsae) {
                response = '{"success": false, "message": "' + gsae.getMessage() + '", "errorCode" : ' + gsae.HttpRequestCode + '}';
            } catch (Exception e) {
                response = '{"success": false, "message": "' + e.getMessage() + '"}';
            }
        } else if (action == 'getMFCSuggest') {
            try {
                SuggestTerm st = new SuggestTerm(params);
                // use MFC’s "mobile" GSA site if they are not recognized as an internal IP
                st.site = ocms_mfc_IPUtility.isInternalIP() ? GSASite_MFCentral : GSASite_MFCentral_Mobile;
                st.suggest();

                // url encode requesting url to avoid json errors.
                response = '{"success":"true","suggestresponse":' + JSON.serialize(st.suggestResponse) + ',"requestUrl":"' + EncodingUtil.urlEncode(st.requestUrl, 'UTF-8') + '"}'; 
            } catch (Exception e) {
                response = '{"success": false, "message": "' + e.getMessage() + '"}';
            }
        } else if (action == 'getCOMSuggest') {
            try {
                SuggestTerm st = new SuggestTerm(params);
                st.site = GSASite_Manulife_com;
                st.suggest();

                // url encode requesting url to avoid json errors.
                response = '{"success":"true","suggestresponse":' + JSON.serialize(st.suggestResponse) + ',"requestUrl":"' + EncodingUtil.urlEncode(st.requestUrl, 'UTF-8') + '"}'; 
            } catch (Exception e) {
                response = '{"success": false, "message": "' + e.getMessage() + '"}';
            }
        } else if (action == 'getCOMResults') {
            try {
                SearchTerm st = new SearchTerm(params);
                st.site = GSASite_Manulife_com;

                st.search();

                response = '{"success":"true","searchresponse":' + JSON.serialize(st.searchResponse) + ', "requestUrl":"' + st.requestUrl + '"}';
            } catch (Exception e) {
                response = '{"success": false, "message": "' + e.getMessage() + '"}';
            }
        }

        return response;
    }
}