/*
Test class for ASKHR_KnowledgeListController.

Make sure the Record Types AskHR_News and AskHR_Alert exist on Knowledge object.

Custom fields Active__c, General_Purpose_Content__c, Online_Date__c, Offline_Date__c exist on Knowledge object.
*/
@isTest(SeeAlldata=false)
public with sharing class ASKHR_KnowledgeListControllerTest {

    // Method to create test data
    @testSetup
    static void setupTestData() {
        
        Id kNewsRecordTypeId = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByName().get('AskHR News').getRecordTypeId();
        
        Id kAlertRecordTypeId = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByName().get('AskHR Alert').getRecordTypeId();
        
        Id kContactUsRecordTypeId = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByName().get('AskHR Contact Us').getRecordTypeId();
        
        Knowledge__kav knowledgeArticle;
        List<Knowledge__kav> listKnowledgeArticles;

        listKnowledgeArticles = new List<Knowledge__kav>(); 
        
        // Add active news knowledgeArticle
        knowledgeArticle = new Knowledge__kav(
            Title = 'Test News 1',
            UrlName = 'testing-news-1-asdflkjh',
            Language = 'en_US',
            Active__c = true,
            General_Purpose_Content__c = 'News 1',
            RecordTypeId = kNewsRecordTypeId);
        listKnowledgeArticles.add(knowledgeArticle);
        
        // Add in active news knowledgeArticle
        knowledgeArticle = new Knowledge__kav(
            Title = 'Test News 2',
            UrlName = 'testing-news-2-asdflkjh',
            Language = 'en_US',
            Active__c = false,
            General_Purpose_Content__c = 'News 2',
            RecordTypeId = kNewsRecordTypeId);
        listKnowledgeArticles.add(knowledgeArticle);
        
        // Add  active news knowledgeArticle with Promote_to_Home_Page__c set to true
        knowledgeArticle = new Knowledge__kav(
            Title = 'Test News 3',
            UrlName = 'testing-news-3-asdflkjh',
            Language = 'en_US',
            Active__c = true,
            General_Purpose_Content__c = 'News 3',
            Promote_to_Home_Page__c = true,
            RecordTypeId = kNewsRecordTypeId);
        listKnowledgeArticles.add(knowledgeArticle);
        
        // Add active alert knowledgeArticle with null dates
        knowledgeArticle = new Knowledge__kav(
            Title = 'Test Alert 1',
            UrlName = 'testing-alert-1-asdflkjh',
            Language = 'en_US',
            Active__c = true,
            General_Purpose_Content__c = 'Alert 1',
            RecordTypeId = kAlertRecordTypeId);
        listKnowledgeArticles.add(knowledgeArticle);
        
        // Add active alert knowledgeArticle within date range
        knowledgeArticle = new Knowledge__kav(
            Title = 'Test Alert 2',
            UrlName = 'testing-alert-2-asdflkjh',
            Language = 'en_US',
            Active__c = true,
            Online_From__c = Date.today().addDays(-5),
            Online_To__c = Date.today().addDays(+5),
            General_Purpose_Content__c = 'Alert 2',
            RecordTypeId = kAlertRecordTypeId);
        listKnowledgeArticles.add(knowledgeArticle);
        
        // Add inactive alert knowledgeArticle
        knowledgeArticle = new Knowledge__kav(
            Title = 'Test Alert 3',
            UrlName = 'testing-alert-3-asdflkjh',
            Language = 'en_US',
            Active__c = false,
            General_Purpose_Content__c = 'Alert 3',
            RecordTypeId = kAlertRecordTypeId);
        listKnowledgeArticles.add(knowledgeArticle);
        
        // Add contact us knowledgeArticle
        knowledgeArticle = new Knowledge__kav(
            Title = 'Test Contact Us 1',
            UrlName = 'testing-contactus-1-asdflkjh',
            Language = 'en_US',
            Active__c = true,
            RecordTypeId = kContactUsRecordTypeId);
        listKnowledgeArticles.add(knowledgeArticle);
        
        insert listKnowledgeArticles;

        Set<Id> setIds = new Set<Id>();
        for(Knowledge__kav knowledgeArticle1 : listKnowledgeArticles) {
            setIds.add(knowledgeArticle1.Id);
        }

        listKnowledgeArticles = [SELECT Id, KnowledgeArticleId FROM Knowledge__kav WHERE Id IN :setIds];
        
        // Publish the Knowledge Articles 
        for(Knowledge__kav knowledgeArticle1 : listKnowledgeArticles) { 
            KbManagement.PublishingService.publishArticle(knowledgeArticle1.KnowledgeArticleId, true);
        }
    }

    @isTest
    static void testGetKnowledgeNewsArticlesForNewsPage() {
        List<Knowledge__kav> listNews = ASKHR_KnowledgeListController.getKnowledgeNewsArticlesForNewsPage('en-US');
        
        System.assertEquals(2, listNews.size());
    }

    @isTest
    static void testGetKnowledgeNewsArticlesForCarousel() {
        List<Knowledge__kav> listNews = ASKHR_KnowledgeListController.getKnowledgeNewsArticlesForCarousel('en-US');
        
        System.assertEquals(1, listNews.size());
    }

    @isTest
    static void testGetNewsCarouselSettings() {
        ASKHR_News_Carousel_Setting__mdt setting = ASKHR_KnowledgeListController.getNewsCarouselSettings();
    }

    @isTest
    static void testGetKnowledgeAlertArticles() {
        List<Knowledge__kav> listAlerts = ASKHR_KnowledgeListController.getKnowledgeAlertArticles('en-US');
        
        System.assertEquals(2, listAlerts.size());
    }

    @isTest
    static void testGetKnowledgeContactUsArticle() {
        Knowledge__kav knowledgeArticle = ASKHR_KnowledgeListController.getKnowledgeContactUsArticle('en-US');
        
        System.assertNotEquals(null, knowledgeArticle);
    }

    @isTest
    static void testGetKnowledgeGlobalContactUsArticle() {
        Knowledge__kav knowledgeArticle = ASKHR_KnowledgeListController.getKnowledgeGlobalContactUsArticle('en-US');
        
        System.assertEquals(null, knowledgeArticle);
    }
        
}