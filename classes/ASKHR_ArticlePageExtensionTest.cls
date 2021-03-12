@isTest
private class ASKHR_ArticlePageExtensionTest {

    static testmethod void testArticlePage(){
        Knowledge__kav testArticle = new Knowledge__kav(
            Title = 'Test Article',
            UrlName = 'testing-article',
            Language = 'en_US',
            Review_Date__c = Date.today() 
        );

        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
            
        // Insert account as current user
        System.runAs (thisUser) {
            insert testArticle;
			testArticle = [Select KnowledgeArticleId from Knowledge__kav where Id = :testArticle.Id LIMIT 1]; 
            String articleId = testArticle.KnowledgeArticleId;
            KbManagement.PublishingService.publishArticle(articleId, true);
        }
        
        ApexPages.currentPage().getParameters().put('id', testArticle.Id);
        ApexPages.KnowledgeArticleVersionStandardController stdController = new ApexPages.KnowledgeArticleVersionStandardController(testArticle);
        ASKHR_ArticlePageExtension articleExtension = new ASKHR_ArticlePageExtension(stdController);
        	
        system.assertNotEquals(null, articleExtension.getArticleFeedbacks());
        system.assertNotEquals(null, articleExtension.mFeedbackIsEnable);
        system.assertNotEquals(null, articleExtension.mFeedbackSize);
        system.assertNotEquals(null, articleExtension.mRatePopupInterval);
        system.assertNotEquals(null, articleExtension.mRatePopupIntervalLater);
        system.assertNotEquals(null, articleExtension.mRatePopupIsEnable);
        system.assertNotEquals(null, articleExtension.mRatePopupIsRandom);
        system.assertNotEquals(null, articleExtension.mRatePopupLaterIsEnable);
        articleExtension.langRedirect();
        
    }
}