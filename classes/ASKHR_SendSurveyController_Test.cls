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
private class ASKHR_SendSurveyController_Test {
    static testMethod void doSendSurvey_ControllerPrefilledWithContact() {

        Contact manager = ASKHR_TestUtility.createContact();
        Case erCase = ASKHR_TestUtility.createERCase();
        
        // need to refresh the er case to get the case number
        Case refreshedCase = [SELECT Id, CaseNumber FROM Case WHERE Id = :erCase.Id];
        
        Test.setCurrentPageReference(new PageReference('Page.myPage'));
        System.currentPageReference().getParameters().put('CaseId', erCase.Id);
        System.currentPageReference().getParameters().put('ShowClose', 'false');
        
       
        ASKHR_SendSurveyController controller = new ASKHR_SendSurveyController();
        Test.startTest();
        System.assertEquals(erCase.ContactId, controller.Recipient1.Contact__c);
        System.assertEquals(refreshedCase.CaseNumber, controller.getCaseNumber());
        System.assert(controller.getCaseURL().contains(erCase.Id), 'Expecting URL to contain Case ID');
        Test.stopTest();
    }


    static testMethod void doSendSurvey_CancellingSend() {

        Contact manager = ASKHR_TestUtility.createContact();
        Case erCase = ASKHR_TestUtility.createERCase();
        
        Test.setCurrentPageReference(new PageReference('Page.myPage'));
        System.currentPageReference().getParameters().put('CaseId', erCase.Id);
        System.currentPageReference().getParameters().put('ShowClose', 'false');
        
       
        ASKHR_SendSurveyController controller = new ASKHR_SendSurveyController();
        Test.startTest();
        controller.Cancel();
        System.assertEquals(true, controller.Cancelling, 'Expecting Cancel to be true');        
        Test.stopTest();
    }    

    static testMethod void doSendSurvey_MustHaveAtLeastOneRecipient() {
        
        Contact manager = ASKHR_TestUtility.createContact();
        Case erCase = ASKHR_TestUtility.createERCase();
        
        PageReference testPage = new PageReference('Page.myPage');
        Test.setCurrentPageReference(testPage);
        System.currentPageReference().getParameters().put('CaseId', erCase.Id);
        System.currentPageReference().getParameters().put('ShowClose', 'false');
        
       
        ASKHR_SendSurveyController controller = new ASKHR_SendSurveyController();
        controller.Recipient1.Contact__c = null;
        Test.startTest();
        controller.SendSurvey();
        System.assertEquals(false, controller.SurveysSuccessfullySent, 'Expecting validation error on Recipient 1.');        
        Test.stopTest();
    }  
      
    static testMethod void doSendSurvey_RecipientCannotBeEmployeeOfRecord() {

        Contact manager = ASKHR_TestUtility.createContact();
        Case erCase = ASKHR_TestUtility.createERCase();
        
        PageReference testPage = new PageReference('Page.myPage');
        Test.setCurrentPageReference(testPage);
        System.currentPageReference().getParameters().put('CaseId', erCase.Id);
        System.currentPageReference().getParameters().put('ShowClose', 'false');
        
       
        ASKHR_SendSurveyController controller = new ASKHR_SendSurveyController();
        controller.Recipient1.Contact__c = erCase.Employee_of_Record__c;
        Test.startTest();
        controller.SendSurvey();
        System.assertEquals(false, controller.SurveysSuccessfullySent, 'Expecting validation error on Recipient 1.');        
        Test.stopTest();        
    }

    static testMethod void doSendSurvey_SingleSurveySent() {
        
        Contact manager = ASKHR_TestUtility.createContact();
        Case erCase = ASKHR_TestUtility.createERCase();
        
        Test.setCurrentPageReference(new PageReference('Page.myPage'));
        System.currentPageReference().getParameters().put('CaseId', erCase.Id);
        System.currentPageReference().getParameters().put('ShowClose', 'false');        
       
        ASKHR_SendSurveyController controller = new ASKHR_SendSurveyController();
        controller.Recipient1.Contact__c = manager.Id;      
        Test.startTest();
        Integer emailCountBefore = Limits.getEmailInvocations();
        controller.SendSurvey();
        System.assertEquals(true, controller.SurveysSuccessfullySent, 'Expecting surveys to be sent.');
        //System.assertEquals(emailCountBefore + 1, Limits.getEmailInvocations(), 'Expecting one email to get sent out.');
        
        //negative test
        manager.Email = '';
        update manager;
        Test.setCurrentPageReference(new PageReference('Page.myPage'));
        System.currentPageReference().getParameters().put('CaseId', erCase.Id);
        System.currentPageReference().getParameters().put('ShowClose', 'false');        
       
        controller = new ASKHR_SendSurveyController();
        controller.Recipient1.Contact__c = manager.Id;      
        controller.SendSurvey();
        Test.stopTest();        
    }
    
    static testMethod void doSendSurvey_SingleSurveySentNegativeTest() {
    	Contact manager = ASKHR_TestUtility.createContact();
        manager.Email = '';
        update manager;
        
        Contact employee = ASKHR_TestUtility.createContact();
        
        Case funcCase = ASKHR_TestUtility.createFunctionCase();
        funcCase.Employee_of_Record__c = employee.Id;
        update funcCase;
        
        Test.setCurrentPageReference(new PageReference('Page.myPage'));
        System.currentPageReference().getParameters().put('CaseId', funcCase.Id);
        System.currentPageReference().getParameters().put('ShowClose', 'false');        
       
        ASKHR_SendSurveyController controller = new ASKHR_SendSurveyController();
        controller.Recipient1.Contact__c = manager.Id;      
        controller.Recipient2.Contact__c = employee.Id;
        Test.startTest();
        controller.SendSurvey();
      
        Test.stopTest();        
    }
    
    static testMethod void doSendSurvey_SurveywithFilter() {
        
        Contact manager = ASKHR_TestUtility.createContact();
        Case functionCase = ASKHR_TestUtility.createFunctionCase();
        
        Test.setCurrentPageReference(new PageReference('Page.myPage'));
        System.currentPageReference().getParameters().put('CaseId', functionCase.Id);
        System.currentPageReference().getParameters().put('ShowClose', 'false');        
       
        ASKHR_SendSurveyController controller = new ASKHR_SendSurveyController();
        controller.Recipient1.Contact__c = manager.Id;      
        Test.startTest();
        Integer emailCountBefore = Limits.getEmailInvocations();
        controller.SendSurvey();
        System.assertEquals(true, controller.SurveysSuccessfullySent, 'Expecting surveys to be sent.');
        //System.assertEquals(emailCountBefore + 1, Limits.getEmailInvocations(), 'Expecting one email to get sent out.');
        Test.stopTest();        
    }
    
    static testMethod void doSendSurvey_FourSurveysSent() {
        
        Contact manager1 = ASKHR_TestUtility.createContact();
        Contact manager2 = ASKHR_TestUtility.createContact();
        Contact manager3 = ASKHR_TestUtility.createContact();
        Contact manager4 = ASKHR_TestUtility.createContact();
        
        // Set one with french.
        manager2.Language__c = 'French';
        update manager2;
        
        Case erCase = ASKHR_TestUtility.createERCase();
        
        Test.setCurrentPageReference(new PageReference('Page.myPage'));
        System.currentPageReference().getParameters().put('CaseId', erCase.Id);
        System.currentPageReference().getParameters().put('ShowClose', 'false');
        
       
        ASKHR_SendSurveyController controller = new ASKHR_SendSurveyController();
        
        controller.Recipient1.Contact__c = manager1.Id;
        controller.Recipient2.Contact__c = manager2.Id;
        controller.Recipient3.Contact__c = manager3.Id;
        controller.Recipient4.Contact__c = manager4.Id;
        
        Test.startTest();
        Integer emailCountBefore = Limits.getEmailInvocations();
        controller.SendSurvey();
        System.assertEquals(true, controller.SurveysSuccessfullySent, 'Expecting surveys to be sent.');
        //System.assertEquals(emailCountBefore + 4, Limits.getEmailInvocations(), 'Expecting four emails to get sent out.');
        erCase = [SELECT Id, Surveys_Sent_Count__c FROM Case WHERE Id = :erCase.Id];
        System.AssertEquals(4, erCase.Surveys_Sent_Count__c);        
        Test.stopTest();
    }    
    
    static testMethod void doSendSurvey_NoTemplate() {
        
        Contact manager = ASKHR_TestUtility.createContact();
        Case erCase = ASKHR_TestUtility.createERTerminationCase();
        
        Test.setCurrentPageReference(new PageReference('Page.myPage'));
        System.currentPageReference().getParameters().put('CaseId', erCase.Id);
        System.currentPageReference().getParameters().put('ShowClose', 'false');        
       
        ASKHR_SendSurveyController controller = new ASKHR_SendSurveyController();
        controller.Recipient1.Contact__c = manager.Id;      
        Test.startTest();
        Integer emailCountBefore = Limits.getEmailInvocations();
        System.assertEquals(false, controller.SurveysSuccessfullySent, 'No Template Found');
        Test.stopTest();
        
    }
}