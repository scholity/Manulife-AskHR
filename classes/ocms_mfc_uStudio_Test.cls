@isTest
public with sharing class ocms_mfc_uStudio_Test {

    private static String STUDIOS_BODY = '{"success": true}';
    private static String COLLECTIONS_BODY = '{"success": true}';
    private static String DESTINATIONS_BODY = '{"success": true}';
    private static String STUDIO_VIDEOS_BODY = '{"success": true}';
    private static String COLLECTION_VIDEOS_BODY = '{"success": true}';
    private static String DESTINATION_VIDEOS_BODY = '{"success": true}';

    private static String STUDIO_UID = 'stu';
    private static String COLLECTION_UID = 'col';
    private static String DESTINATION_UID = 'des';
    private static String VIDEO_UID = 'vid';



    @testSetup static void setup_api() {
        ocms_mfc_SiteSettings__c sitePreferenceCustomSetting = new ocms_mfc_SiteSettings__c();
        sitePreferenceCustomSetting.Name = 'Manulife Central';
        sitePreferenceCustomSetting.uStudio_MFC_Endpoint__c = 'https://app.ustudio.com';
        sitePreferenceCustomSetting.uStudio_MFC_Token__c = 'ef1b5c95885e4c228c165be321fd39a1';
        insert sitePreferenceCustomSetting;
    }

    @isTest static void test_content() {
        ocms_TestContentHelper tch = new ocms_TestContentHelper();
        List<Map<String,String>> attr_map = new List<Map<String, String>>();

        Map<String, String> am = new Map<String, String>();
        am.put('body', 'body');
        attr_map.add(am);
        tch.createContent(attr_map, 'Test');

        cms.CreateContentController ccc = new cms.CreateContentController();

        ocms_mfc_uStudio uStudio = new ocms_mfc_uStudio();
//        uStudio = new ocms_mfc_uStudio(ccc);
        uStudio = new ocms_mfc_uStudio(tch.gc);
        uStudio.getHTML();
    }

    @isTest static void test_type() {
        ocms_mfc_uStudioService service = new ocms_mfc_uStudioService();
        service.getType();
    }

    @isTest static void test_html() {
        ocms_mfc_uStudioService service = new ocms_mfc_uStudioService();
        service.getHTML();
    }

    @isTest static void test_user() {
        Map<String, String> params = new Map<String, String>();
        params.put('action', 'getUser');
        params.put('testName', 'test_user');
        executeRequest(params);
    }

    @isTest static void test_studio() {
        Map<String, String> params = new Map<String, String>();
        params.put('action', 'getStudio');
        params.put('testName', 'test_studio');
        executeRequest(params);
    }

    @isTest static void test_studios() {
        Map<String, String> params = new Map<String, String>();
        params.put('action', 'getStudios');
        params.put('testName', 'test_studios');
        executeRequest(params);
    }

    @isTest static void test_collections() {
        Map<String, String> params = new Map<String, String>();
        params.put('action', 'getCollections');
        params.put('uid', STUDIO_UID);
        params.put('testName', 'test_collections');
        executeRequest(params);
    }

    @isTest static void test_destinations() {
        Map<String, String> params = new Map<String, String>();
        params.put('action', 'getDestinations');
        params.put('uid', STUDIO_UID);
        params.put('testName', 'test_destinations');
        executeRequest(params);
    }

    @isTest static void test_studio_videos() {
        Map<String, String> params = new Map<String, String>();
        params.put('action', 'getVideos');
        params.put('studio_uid', STUDIO_UID);
        params.put('collection_uid', '');
        params.put('destination_uid', '');
        params.put('sort_order', 'created');
        params.put('sort_direction', 'desc');
        params.put('search_query', '');
        params.put('limit', '5');
        params.put('index', '0');
        params.put('testName', 'test_studio_videos');
        executeRequest(params);
    }

    @isTest static void test_collection_videos() {
        Map<String, String> params = new Map<String, String>();
        params.put('action', 'getCollectionVideos');
        params.put('studio_uid', STUDIO_UID);
        params.put('collection_uid', COLLECTION_UID);
        params.put('destination_uid', '');
        params.put('sort_order', 'created');
        params.put('sort_direction', 'desc');
        params.put('search_query', '');
        params.put('limit', '5');
        params.put('index', '0');
        params.put('testName', 'test_collection_videos');
        executeRequest(params);
    }

    @isTest static void test_destination_video() {
        Map<String, String> params = new Map<String, String>();
        params.put('action', 'getDestinationVideo');
        params.put('studio_uid', STUDIO_UID);
        params.put('destination_uid', DESTINATION_UID);
        params.put('video_uid', VIDEO_UID);
        params.put('testName', 'test_destination_video');
        executeRequest(params);
    }

    @isTest static void test_destination_videos() {
        Map<String, String> params = new Map<String, String>();
        params.put('action', 'getDestinationVideos');
        params.put('studio_uid', STUDIO_UID);
        params.put('collection_uid', '');
        params.put('destination_uid', DESTINATION_UID);
        params.put('sort_order', 'created');
        params.put('sort_direction', 'desc');
        params.put('search_query', '');
        params.put('limit', '5');
        params.put('index', '0');
        params.put('testName', 'test_destination_videos');
        executeRequest(params);
    }

    @isTest static void test_video_destinations() {
        Map<String, String> params = new Map<String, String>();
        params.put('action', 'getVideoDestinations');
        params.put('studio_uid', STUDIO_UID);
        params.put('video_uid', VIDEO_UID);
        params.put('testName', 'test_video_destinations');
        executeRequest(params);
    }

    public static String executeRequest(Map<String, String> params) {
        String testName = params.get('testName');

        Test.startTest();

        ocms_mfc_uStudioService service = new ocms_mfc_uStudioService();

        // Test erroneous http request (throws exception)
        String response = service.executeRequest(params);

        // Test unsuccessful response (status code error)
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseError());
        response = service.executeRequest(params);

        // Test successful response (200 status code)
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        response = service.executeRequest(params);

        System.debug(testName + ' response: ' + response);
        System.assert(response.contains('"success": true'), testName + ' was NOT successful');

        Test.stopTest();
        return response;
    }

    public class MockHttpResponse implements HttpCalloutMock {

        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody('{"success": true}');
            return res;
        }
    }

    public class MockHttpResponseError implements HttpCalloutMock {

        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(404);
            res.setBody('{"code": 404, "error": "Not Found", "message": "404 - Not Found"}');
            return res;
        }
    }
}