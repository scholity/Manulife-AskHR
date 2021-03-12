/*
Test class for AskHR_DynamicCloseCaseController
*/
@isTest(SeeAlldata=false)
public class AskHR_DynamicCloseCaseControllerTest implements HttpCalloutMock {

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
        Case case1 = [SELECT Id FROM Case LIMIT 1];
        
        // Mock responce for the test class
        Test.setMock(HttpCalloutMock.class, new AskHR_DynamicCloseCaseControllerTest());
        
        Test.startTest();
        List<String> listFields = AskHR_DynamicCloseCaseController.getCloseCaseLayoutFields(case1.Id);
        Test.stopTest();
        System.assertNotEquals(null, listFields);
    }
}