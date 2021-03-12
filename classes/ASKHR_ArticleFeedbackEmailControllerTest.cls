@isTest
private class ASKHR_ArticleFeedbackEmailControllerTest {

    static testMethod void controllerTest(){
        ASKHR_ArticleFeedbackEmailController afec = new ASKHR_ArticleFeedbackEmailController();
        Test.startTest();
        afec.mArticleFeedbackId = 'Testing';
        afec.mArticleFeedbackName = 'Feedback Testing';
        afec.mRecipientName = 'Bill employee';
        system.assertNotEquals(null, afec.mSurveyLink);
        Test.stopTest();
    }
}