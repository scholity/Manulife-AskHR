/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class ASKHR_SurveyTakerTests {

    static testMethod void doCreateCaseSendSurveySubmitSurvey_SurveyTakenCountIncreases() {
          
        // Make the case
        Contact manager = ASKHR_TestUtility.createContact();
        Case erCase = ASKHR_TestUtility.createERCase();
        
        Test.setCurrentPageReference(new PageReference('Page.myPage'));
        System.currentPageReference().getParameters().put('CaseId', erCase.Id);
        System.currentPageReference().getParameters().put('ShowClose', 'false');
        
        // Send the survey
        ASKHR_SendSurveyController controller = new ASKHR_SendSurveyController();
        controller.Recipient1.Contact__c = manager.Id;
        
        controller.SendSurvey();
        System.assertEquals(true, controller.SurveysSuccessfullySent, 'Expecting surveys to be sent.');
        
        SurveyTaker__c surveyTaker = new SurveyTaker__c();
        surveyTaker.Case__c = erCase.Id;
        surveyTaker.Contact__c = manager.Id;
        
        Test.startTest();
        insert surveyTaker;
        erCase = [SELECT Id, Surveys_Taken_Count__c FROM Case WHERE Id = :erCase.Id];
        System.AssertEquals(1, erCase.Surveys_Taken_Count__c,'Expecting Survey Taken Count to be one.');
        
        // doing this for code coverage.
        surveyTaker = [SELECT Id FROM SurveyTaker__c WHERE Id = :surveyTaker.Id];
        update surveyTaker;
        Test.stopTest();
        
        
    }
    
    static testMethod void doDeleteSurveyTaken_SurveyTakenCountDecreases() {
        
        // Make the case
        Contact manager = ASKHR_TestUtility.createContact();
        Case erCase = ASKHR_TestUtility.createERCase();
        
        Test.setCurrentPageReference(new PageReference('Page.myPage'));
        System.currentPageReference().getParameters().put('CaseId', erCase.Id);
        System.currentPageReference().getParameters().put('ShowClose', 'false');
        
        // Send the survey
        ASKHR_SendSurveyController controller = new ASKHR_SendSurveyController();
        controller.Recipient1.Contact__c = manager.Id;
        
        controller.SendSurvey();
        System.assertEquals(true, controller.SurveysSuccessfullySent, 'Expecting surveys to be sent.');
        
        SurveyTaker__c surveyTaker = new SurveyTaker__c();
        surveyTaker.Case__c = erCase.Id;
        surveyTaker.Contact__c = manager.Id;
        
        Test.startTest();
        insert surveyTaker;
        erCase = [SELECT Id, Surveys_Taken_Count__c FROM Case WHERE Id = :erCase.Id];
        System.AssertEquals(1, erCase.Surveys_Taken_Count__c,'Expecting Survey Taken Count to be one.');
        
        // doing this for code coverage.
        surveyTaker = [SELECT Id FROM SurveyTaker__c WHERE Id = :surveyTaker.Id];
        delete surveyTaker;

        erCase = [SELECT Id, Surveys_Taken_Count__c FROM Case WHERE Id = :erCase.Id];
        System.AssertEquals(0, erCase.Surveys_Taken_Count__c,'Expecting Survey Taken Count to be zero.');        
        Test.stopTest();
    }    
}