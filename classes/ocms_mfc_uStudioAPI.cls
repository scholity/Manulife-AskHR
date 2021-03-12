/**
 * Created by rhyanmitchell on 2017-02-06.
 */

global with sharing class ocms_mfc_uStudioAPI {

    private static final String ENDPOINT;
    private static final String TOKEN;
    private static final String DESTINATION_ID;

    static {
        // uStudio API Endpoint and user authentication token
        ENDPOINT = (String) ocms_mfc_SiteSettings__c.getValues('Manulife Central').get('uStudio_MFC_Endpoint__c');
        TOKEN = '?token=' + (String) ocms_mfc_SiteSettings__c.getValues('Manulife Central').get('uStudio_MFC_Token__c');
        DESTINATION_ID = (String) ocms_mfc_SiteSettings__c.getValues('Manulife Central').get('uStudio_MFC_Destination_Id__c');
    }

   /**
     * Get this user based on auth token
     */
    public String getUser() {
        String body;

        String resource = '/api/v2/users/me';
        String url = ENDPOINT + resource + TOKEN;

        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod('GET');

        try {
            Http http = new Http();
            HttpResponse response = http.send(req);
            System.debug('#### Response: ' + response);
            if (response.getStatusCode() != 200) {
                String errorMessage = getHttpResponseErrorMessage(response);
                System.debug('#### ' + errorMessage);
            } else {
                body = response.getBody();
                System.debug('#### Response Body: ' + body);
            }
        } catch (Exception e) {
            System.debug('#### Exception: ' + e);
        }
        return body;
    }

    /**
     * Get all the studios for this user
     */
    public String getStudios() {
        String body;

        String resource = '/api/v2/studios';
        String url = ENDPOINT + resource + TOKEN;

        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod('GET');

        try {
            Http http = new Http();
            HttpResponse response = http.send(req);
            System.debug('#### Response: ' + response);
            if (response.getStatusCode() != 200) {
                String errorMessage = getHttpResponseErrorMessage(response);
                System.debug('#### ' + errorMessage);
            } else {
                body = response.getBody();
                System.debug('#### Response Body: ' + body);
            }
        } catch (Exception e) {
            System.debug('#### Exception: ' + e);
        }
        return body;
    }

    /**
     * Get studio
     *
     * @param String uid    Studio ID
     */
    public String getStudio(String uid) {
        String body;

        String resource = '/api/v2/studios/' + uid;
        String url = ENDPOINT + resource + TOKEN;

        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod('GET');

        try {
            Http http = new Http();
            HttpResponse response = http.send(req);

            if (response.getStatusCode() != 200) {
                String errorMessage = getHttpResponseErrorMessage(response);
            } else {
                body = response.getBody();
            }

        } catch (Exception e) {
            System.debug('#### Exception: ' + e);
        }
        return body;
    }

    /**
     * Get available collections for the given studio
     *
     * @param String uid    Studio ID
     */
    public String getCollections(String uid) {
        String body;
        String resource = '/api/v2/studios/' + uid + '/collections';
        String url = ENDPOINT + resource + TOKEN;

        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod('GET');

        try {
            Http http = new Http();
            HttpResponse response = http.send(req);
            System.debug('#### Response: ' + response);
            if (response.getStatusCode() != 200) {
                String errorMessage = getHttpResponseErrorMessage(response);
                System.debug('#### ' + errorMessage);
            } else {
                body = response.getBody();
                System.debug('#### Response Body: ' + body);
            }
        } catch (Exception e) {
            System.debug('#### Exception: ' + e);
        }
        return body;
    }

    /**
     * Get available destinations for the given studio
     *
     * @param String uid    Studio ID
     */
    public String getDestinations(String uid) {
        String body;

        String resource = '/api/v2/studios/' + uid + '/destinations';
        String url = ENDPOINT + resource + TOKEN;

        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod('GET');

        try {
            Http http = new Http();
            HttpResponse response = http.send(req);
            System.debug('#### Response: ' + response);
            if (response.getStatusCode() != 200) {
                String errorMessage = getHttpResponseErrorMessage(response);
                System.debug('#### ' + errorMessage);
            } else {
                body = response.getBody();
                System.debug('#### Response Body: ' + body);
            }
        } catch (Exception e) {
            System.debug('#### Exception: ' + e);
        }
        return body;
    }

    /**
     * Get available videos for the given studio
     *
     * @param String studio_uid         Studio ID
     * @param String sort_order         Field to order on
     * @param String sort_direction     Ascending or descending sort direction
     * @param String search_query       Search term against title and keywords
     * @param String video_limit        Number of videos to return per page
     * @param String index              Video offset index (ex. 5 videos per page would have video indexes: 0, 5, 10 etc)
     */
    public String getVideos(String studio_uid, String sort_order, String sort_direction, String search_query, String video_limit, String index) {
        String body;

        String resource = '/api/v2/studios/' + studio_uid + '/videos';
        String uQuery = search_query.length() > 0 ? '&query=' + search_query: '';
        String uOrder = sort_order.length() > 0 ? '&order=' + sort_order + ':' + sort_direction: '';
        String uLimit = video_limit.length() > 0 ? '&limit=' + video_limit: '';
        String uIndex = index.length() > 0 ? '&index=' + index: '';
        String url = ENDPOINT + resource + TOKEN + uQuery + uOrder + uLimit + uIndex;

        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod('GET');

        try {
            Http http = new Http();
            HttpResponse response = http.send(req);
            System.debug('#### Response: ' + response);
            if (response.getStatusCode() != 200) {
                String errorMessage = getHttpResponseErrorMessage(response);
                System.debug('#### ' + errorMessage);
            } else {
                body = response.getBody();
                System.debug('#### Response Body: ' + body);
            }
        } catch (Exception e) {
            System.debug('#### Exception: ' + e);
        }
        return body;
    }

    /**
     * Get available videos for the given studio and collection
     *
     * @param String studio_uid         Studio ID
     * @param String collection_uid     Collection ID
     * @param String sort_order         Field to order on
     * @param String sort_direction     Ascending or descending sort direction
     * @param String search_query       Search term against title and keywords
     * @param String video_limit        Number of videos to return per page
     * @param String index              Video offset index (ex. 5 videos per page would have video indexes: 0, 5, 10 etc)
     */
    public String getCollectionVideos(String studio_uid, String collection_uid, String sort_order, String sort_direction, String search_query, String video_limit, String index) {
        String body;
        String resource = '/api/v2/studios/' + studio_uid + '/collections/' + collection_uid + '/videos';
        String uQuery = search_query.length() > 0 ? '&query=' + search_query: '';
        String uOrder = sort_order.length() > 0 ? '&order=' + sort_order + ':' + sort_direction: '';
        String uLimit = video_limit.length() > 0 ? '&limit=' + video_limit: '';
        String uIndex = index.length() > 0 ? '&index=' + index: '';
        String url = ENDPOINT + resource + TOKEN + uQuery + uOrder + uLimit + uIndex;

        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod('GET');

        try {
            Http http = new Http();
            HttpResponse response = http.send(req);
            System.debug('#### Response: ' + response);
            if (response.getStatusCode() != 200) {
                String errorMessage = getHttpResponseErrorMessage(response);
                System.debug('#### ' + errorMessage);
            } else {
                body = response.getBody();
                System.debug('#### Response Body: ' + body);
            }
        } catch (Exception e) {
            System.debug('#### Exception: ' + e);
        }
        return body;
    }

    /**
     * Get specific video within the given studio and destination
     *
     * @param String studio_uid         Studio ID
     * @param String destination_uid    Destination ID
     * @param String video_uid          Video ID
     */
    public String getDestinationVideo(String studio_uid, String destination_uid, String video_uid) {
        String body;
        String resource = '/api/v2/studios/' + studio_uid + '/destinations/' + destination_uid + '/videos/' + video_uid;
        String url = ENDPOINT + resource + TOKEN;

        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod('GET');

        try {
            Http http = new Http();
            HttpResponse response = http.send(req);
            System.debug('#### Response: ' + response);
            if (response.getStatusCode() != 200) {
                String errorMessage = getHttpResponseErrorMessage(response);
                System.debug('#### ' + errorMessage);
            } else {
                body = response.getBody();
                System.debug('#### Response Body: ' + body);
            }
        } catch (Exception e) {
            System.debug('#### Exception: ' + e);
        }
        return body;
    }

    /**
     * Get available videos for the given studio and destination
     *
     * @param String studio_uid         Studio ID
     * @param String destination_uid    Destination ID
     * @param String sort_order         Field to order on
     * @param String sort_direction     Ascending or descending sort direction
     * @param String search_query       Search term against title and keywords
     * @param String video_limit        Number of videos to return per page
     * @param String index              Video offset index (ex. 5 videos per page would have video indexes: 0, 5, 10 etc)
     */
    public String getDestinationVideos(String studio_uid, String destination_uid, String sort_order, String sort_direction, String search_query, String video_limit, String index) {
        String body;
        String resource = '/api/v2/studios/' + studio_uid + '/destinations/' + destination_uid + '/videos';
        String uQuery = search_query.length() > 0 ? '&query=' + search_query: '';
        String uOrder = sort_order.length() > 0 ? '&order=' + sort_order + ':' + sort_direction: '';
        String uLimit = video_limit.length() > 0 ? '&limit=' + video_limit: '';
        String uIndex = index.length() > 0 ? '&index=' + index: '';
        String url = ENDPOINT + resource + TOKEN + uQuery + uOrder + uLimit + uIndex;

        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod('GET');

        try {
            Http http = new Http();
            HttpResponse response = http.send(req);
            System.debug('#### Response: ' + response);
            if (response.getStatusCode() != 200) {
                String errorMessage = getHttpResponseErrorMessage(response);
                System.debug('#### ' + errorMessage);
            } else {
                body = response.getBody();
                System.debug('#### Response Body: ' + body);
            }
        } catch (Exception e) {
            System.debug('#### Exception: ' + e);
        }
        return body;
    }

    /**
     * Get available destinations for the given studio and video
     *
     * @param String studio_uid         Studio ID
     * @param String video_uid          Video ID
     */
    public String getVideoDestinations(String studio_uid, String video_uid) {
        String body;
        String resource = '/api/v2/studios/' + studio_uid + '/videos/' + video_uid + '/destinations';
        String url = ENDPOINT + resource + TOKEN;

        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod('GET');

        try {
            Http http = new Http();
            HttpResponse response = http.send(req);
            System.debug('#### Response: ' + response);
            if (response.getStatusCode() != 200) {
                String errorMessage = getHttpResponseErrorMessage(response);
                System.debug('#### ' + errorMessage);
            } else {
                body = response.getBody();
                System.debug('#### Response Body: ' + body);
            }
        } catch (Exception e) {
            System.debug('#### Exception: ' + e);
        }
        return body;
    }

    /**
     * Return a formatted error message on response error.
     */
    private String getHttpResponseErrorMessage(HttpResponse response) {
        Map<String, Object> body = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        return body.get('code') + ' - ' + body.get('error') + '. ' + body.get('message');
    }
}