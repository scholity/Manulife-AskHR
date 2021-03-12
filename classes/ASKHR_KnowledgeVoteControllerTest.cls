/*
Test class for ASKHR_KnowledgeVoteController.

Make sure the Record Types AskHR_News exist on Knowledge object.

Custom fields Active__c, General_Purpose_Content__c, Online_Date__c, Offline_Date__c exist on Knowledge object.
*/
@isTest(SeeAlldata=false)
public with sharing class ASKHR_KnowledgeVoteControllerTest {
    
    // Method to create test data
    @testSetup
    static void setupTestData() {
        
        Id kNewsRecordTypeId = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByName().get('AskHR News').getRecordTypeId();
        
        Knowledge__kav knowledgeArticle;
        List<Knowledge__kav> listKnowledgeArticles;

        listKnowledgeArticles = new List<Knowledge__kav>(); 
        
        // Add active news knowledgeArticle
        knowledgeArticle = new Knowledge__kav(
            Title = 'Test News 1',
            UrlName = 'testing-news-1-asdflkjhqwerty',
            Language = 'en_US',
            Active__c = true,
            General_Purpose_Content__c = 'News 1',
            RecordTypeId = kNewsRecordTypeId);
        listKnowledgeArticles.add(knowledgeArticle);

        insert listKnowledgeArticles;

        Set<Id> setIds = new Set<Id>();
        for(Knowledge__kav knowledgeArticle1 : listKnowledgeArticles) {
            setIds.add(knowledgeArticle1.Id);
        }

        // Get the KnowledgeArticleId of the Knowledg Article that we just created

        listKnowledgeArticles = [SELECT Id, KnowledgeArticleId FROM Knowledge__kav WHERE Id IN :setIds];
        
        // Publish the Knowledge Articles 
        for(Knowledge__kav knowledgeArticle1 : listKnowledgeArticles) { 
            KbManagement.PublishingService.publishArticle(knowledgeArticle1.KnowledgeArticleId, true);
        }
    }

    
    @isTest
    static void testGetVotes() {
        List<Knowledge__kav> listNews = ASKHR_KnowledgeListController.getKnowledgeNewsArticlesForNewsPage('en-US');
        Knowledge__kav knowledgeArticle = [SELECT Id, KnowledgeArticleId FROM Knowledge__kav WHERE UrlName = 'testing-news-1-asdflkjhqwerty'];
        
        ASKHR_KnowledgeVoteController.ParamsWrapper params = new ASKHR_KnowledgeVoteController.ParamsWrapper();
        params.knowledgeId = knowledgeArticle.Id;
        params.type = '1';

        // create a dislike vote
        ASKHR_KnowledgeVoteController.castMyVote(params);

        ASKHR_KnowledgeVoteController.VoteData vd = ASKHR_KnowledgeVoteController.getVotes(knowledgeArticle.Id);

        System.assertEquals('1', vd.myVote);
        System.assertEquals(1, vd.dislikeCount);
        System.assertEquals(0, vd.likeCount);

    }

    
    @isTest
    static void testCastMyVote() {
        List<Knowledge__kav> listNews = ASKHR_KnowledgeListController.getKnowledgeNewsArticlesForNewsPage('en-US');
        Knowledge__kav knowledgeArticle = [SELECT Id, KnowledgeArticleId FROM Knowledge__kav WHERE UrlName = 'testing-news-1-asdflkjhqwerty'];
        
        ASKHR_KnowledgeVoteController.ParamsWrapper params = new ASKHR_KnowledgeVoteController.ParamsWrapper();
        params.knowledgeId = knowledgeArticle.Id;
        params.type = '1';

        ASKHR_KnowledgeVoteController.castMyVote(params);

        // Change my Vote to like
        params.type = '5';

        ASKHR_KnowledgeVoteController.VoteData vd = ASKHR_KnowledgeVoteController.castMyVote(params);
        System.assertEquals('5', vd.myVote);
        System.assertEquals(0, vd.dislikeCount);
        System.assertEquals(1, vd.likeCount);
    }

}