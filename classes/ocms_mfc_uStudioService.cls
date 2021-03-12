/**
 * Created by rhyanmitchell on 2017-02-06.
 */

global with sharing class ocms_mfc_uStudioService extends cms.ContentTemplateController implements cms.ServiceInterface {

//    private static final String ENDPOINT = 'https://app.ustudio.com';
//    private static final String TOKEN =  '?token=ef1b5c95885e4c228c165be321fd39a1';

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
     * @description required by cms.ServiceInterface
     * @return System.Type
     */
    public System.Type getType() {
        return ocms_mfc_uStudioService.class;
    }

    // For generated markup, we are overriding this to support multiple templates
    global override virtual String getHTML() { return '';	}

    public String executeRequest(Map<String, String> p) {
        String response = '{"success": false, "message": "Action not supported."}';

        if (p.containsKey('action')) {
            if (p.get('action') == 'getUser') {
                response = getUser();
            } else if (p.get('action') == 'getStudios') {
                response = getStudios();
            } else if (p.get('action') == 'getStudio') {
                response = getStudio(p.get('uid'));
            } else if (p.get('action') == 'getCollections') {
                response = getCollections(p.get('uid'));
            } else if (p.get('action') == 'getDestinations') {
                response = getDestinations(p.get('uid'));
            } else if (p.get('action') == 'getVideos') {
                response = getVideos(p);
            } else if (p.get('action') == 'getCollectionVideos') {
                response = getCollectionVideos(p);
            } else if (p.get('action') == 'getDestinationVideo') {
                response = getDestinationVideo(p);
            } else if (p.get('action') == 'getDestinationVideos') {
                response = getDestinationVideos(p);
            } else if (p.get('action') == 'getVideoDestinations') {
                response = getVideoDestinations(p);
            }
        }

        return response;
    }

   /**
     * Get this user based on auth token
     */
    private String getUser() {
        String response = '{"success": false, "message": "Action not supported."}';

        ocms_mfc_uStudioAPI uStudioAPI = new ocms_mfc_uStudioAPI();
        String user = uStudioAPI.getUser();

        response = '{"success": true, "user": ' + user + '}';
        return response;
    }

    /**
     * Get all the studios for this user
     */
    private String getStudios() {
        String response = '{"success": false, "message": "Action not supported."}';

        ocms_mfc_uStudioAPI uStudioAPI = new ocms_mfc_uStudioAPI();
        String studios = uStudioAPI.getStudios();

        response = '{"success": true, "studios": ' + studios + '}';
        return response;
    }

    /**
     * Get all the destinations for this studio (uid)
     */
    private String getCollections(String uid) {
        String response = '{"success": false, "message": "Action not supported."}';

        ocms_mfc_uStudioAPI uStudioAPI = new ocms_mfc_uStudioAPI();
        String collections = uStudioAPI.getCollections(uid);

        response = '{"success": true, "collections": ' + collections + '}';
        return response;
    }

    /**
     * Get all the destinations for this studio (uid)
     */
    private String getDestinations(String uid) {
        String response = '{"success": false, "message": "Action not supported."}';

        ocms_mfc_uStudioAPI uStudioAPI = new ocms_mfc_uStudioAPI();
        String destinations = uStudioAPI.getDestinations(uid);

        response = '{"success": true, "destinations": ' + destinations + ', "destination_id": "' + DESTINATION_ID + '"}';
        return response;
    }

    /**
     * Get all the studios for this user
     */
    private String getVideos(Map<String, String> p) {
        String response = '{"success": false, "message": "Action not supported."}';

        String studio_uid = p.get('studio_uid');
        String sort_order = p.get('sort_order');
        String sort_direction = p.get('sort_direction');
        String search_query = p.get('search_query');
        String video_limit = p.get('limit');
        String index = p.get('index');

        ocms_mfc_uStudioAPI uStudioAPI = new ocms_mfc_uStudioAPI();
        String videos = uStudioAPI.getVideos(studio_uid, sort_order, sort_direction, search_query, video_limit, index);

        response = '{"success": true, "videos": ' + videos + '}';
        return response;
    }

    private String getCollectionVideos(Map<String, String> p) {
        String response = '{"success": false, "message": "Action not supported."}';

        String studio_uid = p.get('studio_uid');
        String collection_uid = p.get('collection_uid');
        String sort_order = p.get('sort_order');
        String sort_direction = p.get('sort_direction');
        String search_query = p.get('search_query');
        String video_limit = p.get('limit');
        String index = p.get('index');

        ocms_mfc_uStudioAPI uStudioAPI = new ocms_mfc_uStudioAPI();
        String videos = uStudioAPI.getCollectionVideos(studio_uid, collection_uid, sort_order, sort_direction, search_query, video_limit, index);

        response = '{"success": true, "videos": ' + videos + '}';
        return response;
    }

    private String getDestinationVideo(Map<String, String> p) {
        String response = '{"success": false, "message": "Action not supported."}';

        String studio_uid = p.get('studio_uid');
        String destination_uid = p.get('destination_uid');
        String video_uid = p.get('video_uid');

        ocms_mfc_uStudioAPI uStudioAPI = new ocms_mfc_uStudioAPI();
        String video = uStudioAPI.getDestinationVideo(studio_uid, destination_uid, video_uid);

        response = '{"success": true, "video": ' + video + '}';
        return response;
    }

    private String getDestinationVideos(Map<String, String> p) {
        String response = '{"success": false, "message": "Action not supported."}';

        String studio_uid = p.get('studio_uid');
        String destination_uid = p.get('destination_uid');
        String sort_order = p.get('sort_order');
        String sort_direction = p.get('sort_direction');
        String search_query = p.get('search_query');
        String video_limit = p.get('limit');
        String index = p.get('index');

        ocms_mfc_uStudioAPI uStudioAPI = new ocms_mfc_uStudioAPI();
        String videos = uStudioAPI.getDestinationVideos(studio_uid, destination_uid, sort_order, sort_direction, search_query, video_limit, index);

        response = '{"success": true, "videos": ' + videos + '}';
        return response;
    }

    /**
     * Get studio
     */
    private String getStudio(String uid) {
        String response = '{"success": false, "message": "Action not supported."}';

        ocms_mfc_uStudioAPI uStudioAPI = new ocms_mfc_uStudioAPI();
        String studio = uStudioAPI.getStudio(uid);

        response = '{"success": true, "studio": ' + studio + '}';
        return response;
    }

    private String getVideoDestinations(Map<String, String> p) {
        String response = '{"success": false, "message": "Action not supported."}';

        String studio_uid = p.get('studio_uid');
        String video_uid = p.get('video_uid');

        ocms_mfc_uStudioAPI uStudioAPI = new ocms_mfc_uStudioAPI();
        String destinations = uStudioAPI.getVideoDestinations(studio_uid, video_uid);

        response = '{"success": true, "destinations": ' + destinations + ', "destination_id": "' + DESTINATION_ID + '"}';
        return response;

    }

}