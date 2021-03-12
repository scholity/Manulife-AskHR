@isTest
private class ASKHR_SurveyManagerControllerTest {

    static testMethod void generalControllerTest(){
        Survey__c survey = new Survey__c();
        survey.Name = 'Test Survey';
        survey.OwnerId = UserInfo.getUserId();
        survey.Submit_Response__c = 'Testing';
        insert survey;
        
        ApexPages.StandardController ctl = new ApexPages.StandardController(survey);
        ASKHR_SurveyManagerController controller = new ASKHR_SurveyManagerController(ctl);
		Test.startTest();
        System.assertNotEquals(null, controller.editCSS);
        system.assertEquals(controller.editCSS, controller.getEditCSS());
        Test.stopTest();
    }
}