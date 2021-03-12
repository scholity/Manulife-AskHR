/*
Test class for ASKHR_ArticleFeedbackController 
*/
@isTest(SeeAlldata=false)
public class ASKHR_ArticleFeedbackControllerTest {

    // Method to create test data
    @testSetup
    static void setupTestData() {
        // Insert custom settings
        ArticleFeedbackDomain__c afd = new ArticleFeedbackDomain__c();
        afd.Name = 'Default';
        afd.PlatformURL__c = 'https://test.salesforce.com/';
        afd.CommunityURL__c = 'https://community.salesforce.com/';
        insert afd;
        
        // Use DeeloperName instead of Record type Label.
        //Id kRecordTypeId = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByName().get('AskHR_Article').getRecordTypeId();
        Id kRecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Knowledge__kav' AND DeveloperName = 'AskHR_Article'].Id;
        
        Knowledge__kav article1 = new Knowledge__kav(
            Title = 'Test Article 1',
            UrlName = 'testing-article-1-asdflkjh',
            Language = 'en_US',
            Review_Date__c = Date.today(),
            RecordTypeId = kRecordTypeId);
        
        Knowledge__kav article2 = new Knowledge__kav(
            Title = 'Test Article 2 (America)',
            UrlName = 'testing-article-2-asdflkjh',
            Language = 'en_US',
            Review_Date__c = Date.today(),
            RecordTypeId = kRecordTypeId);
            
        insert new List<Knowledge__kav>{article1, article2};
        
        
        List<Knowledge__kav> listArticles = [SELECT Id, KnowledgeArticleId FROM Knowledge__kav WHERE Id IN (:article1.Id, :article2.Id)];
        
        // Publish the Articles 
        for(Knowledge__kav article : listArticles) { 
            KbManagement.PublishingService.publishArticle(article.KnowledgeArticleId, true);
        }
    }
    
    @isTest
    static void testGetInitData() {
        Knowledge__kav article1 = [SELECT Id, KnowledgeArticleId FROM Knowledge__kav WHERE UrlName = 'testing-article-1-asdflkjh' LIMIT 1];
        
        Boolean result = ASKHR_ArticleFeedbackController.getInitData(article1.Id);
        
        List<ASKHR_Global_Setting__mdt> ratePopupSettings = [Select Enable_Rating_Popup__c, Enable_Later__c, Enable_Feedback__c, Popup_interval__c, Popup_interval_later__c, Randomize__c from ASKHR_Global_Setting__mdt where Active__c = true];
        Boolean expectedValue = true;
        
        if(!ratePopupSettings.isEmpty()){
            expectedValue = ratePopupSettings[0].Enable_Feedback__c;
        }
        
        // Since we created a proper article, we just need to compare with the boolean in the metadata
        
        System.assertEquals(expectedValue, result);
    }
    
    @isTest
    static void testSaveFeedbachHelpful() {
        Knowledge__kav article1 = [SELECT Id, KnowledgeArticleId FROM Knowledge__kav WHERE UrlName = 'testing-article-1-asdflkjh' LIMIT 1];
        
        Boolean result = ASKHR_ArticleFeedbackController.saveFeedback(article1.Id, null, true);
        
        List<ASKHR_ArticleFeedback__c> articleFeedbacks = [SELECT Id, IsArticleHelpful__c FROM ASKHR_ArticleFeedback__c WHERE ArticleId__c = :article1.KnowledgeArticleId];
        
        System.assertEquals(1, articleFeedbacks.size());
        System.assertEquals(true, articleFeedbacks[0].IsArticleHelpful__c);

    }
    
    @isTest
    static void testSaveFeedbachNotHelpful() {
        Knowledge__kav article2 = [SELECT Id, Title, KnowledgeArticleId FROM Knowledge__kav WHERE UrlName = 'testing-article-2-asdflkjh' LIMIT 1];
        
        Boolean result = ASKHR_ArticleFeedbackController.saveFeedback(article2.Id, 'My Description', false);
        
        List<ASKHR_ArticleFeedback__c> articleFeedbacks = [SELECT Id, Article_Name__c, Description__c, Location__c, IsArticleHelpful__c FROM ASKHR_ArticleFeedback__c WHERE ArticleId__c = :article2.KnowledgeArticleId];
        
        System.assertEquals(1, articleFeedbacks.size());
        System.assertEquals(false, articleFeedbacks[0].IsArticleHelpful__c);
        System.assertEquals(article2.Title, articleFeedbacks[0].Article_Name__c);
        System.assertEquals('My Description', articleFeedbacks[0].Description__c);
        System.assertEquals('America', articleFeedbacks[0].Location__c);

    }
}