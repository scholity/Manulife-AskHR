/*
Test class for AskHR_ToolingAPIUtils
*/
@isTest(SeeAlldata=false)
public class AskHR_ToolingAPIUtilsTest implements HttpCalloutMock {

    @testSetup
    private static void createTestData() {
        Case case1 = new Case(
                            Secondary_Country_of_Reference__c = 'USA', 
                            External_Contact_Name__c = 'TEST EXTERNAL NAME', 
                            RecordTypeId=Schema.SObjectType.Case.getRecordTypeInfosByName().get(ASKHR_Common.CASE_RECORD_TYPE_NAME_GENERAL_HR).getRecordTypeId()
                       );
        insert case1;
    }

    // Mock response for the test class
    public HTTPResponse respond(HttpRequest req){    
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200);
        res.setStatus('Ok');
        res.setBody('{"size" : 1, "done" : true, "records" : [ {"Layout" : {"FullName" : "CaseClose-Close Case Layout"} } ]}');
        return res;
    }
    
    @isTest
    static void testGetCloseCaseLayoutFields() {
        Case case1 = [SELECT Id, RecordTypeId FROM Case LIMIT 1];
        String recordTypeId = case1.RecordTypeId;
    
        // Get the profile Id of current user.
        String profileId = UserInfo.getProfileId();
        
        // Query to retrieve the current user's page layout.
        String query = 'SELECT Layout.FullName FROM ProfileLayout WHERE RecordTypeId = \'' + recordTypeId + '\' AND ProfileId = \'' + profileId + '\' AND Layout.TableEnumOrId = \'CaseClose\'';
    
        String responseBody = '';
        String pageLayout = '';
        
        // Mock responce for the test class
        Test.setMock(HttpCalloutMock.class, new AskHR_DynamicCloseCaseControllerTest());
        
        Test.startTest();
        responseBody = AskHR_ToolingAPIUtils.executeToolingAPIQuery(query);

        pageLayout = AskHR_ToolingAPIUtils.parseToolingAPIResponseAndGetLayoutName(responseBody);        
        
        List<String> listFields = AskHR_ToolingAPIUtils.getFieldsUsingMetadataAPI(pageLayout);        
        
        Test.stopTest();
        System.assertEquals('CaseClose-Close Case Layout', pageLayout);
        System.assertNotEquals(null, listFields);
    }
}