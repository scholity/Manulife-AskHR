/*
Test class for AskHR_KnowledgeCustomTabs
*/
@isTest(SeeAlldata=false)
public class AskHR_KnowledgeCustomTabsTest {

    // Method to create test data
    @testSetup
    static void setupTestData() {
        
        Id kRecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Knowledge__kav' AND DeveloperName = 'AskHR_Article'].Id;
        
        Knowledge__kav article1 = new Knowledge__kav(
            Title = 'Test Article 1',
            UrlName = 'testing-article-1-asdflkjh',
            Language = 'en_US',
            Review_Date__c = Date.today(),
            RecordTypeId = kRecordTypeId);
        insert article1;
        
        
        List<Knowledge__kav> listArticles = [SELECT Id, KnowledgeArticleId FROM Knowledge__kav WHERE Id IN (:article1.Id)];
        
        // Publish the Articles 
        for(Knowledge__kav article : listArticles) { 
            KbManagement.PublishingService.publishArticle(article.KnowledgeArticleId, true);
        }
    }
    
    @isTest
    static void testGetArticleDataForCommunity() {
        Knowledge__kav article1 = [SELECT Id, KnowledgeArticleId FROM Knowledge__kav WHERE UrlName = 'testing-article-1-asdflkjh' LIMIT 1];
        
        List<AskHR_KnowledgeCustomTabs.Section> result = AskHR_KnowledgeCustomTabs.getArticleDataForCommunity(article1.Id);
        System.assertNotEquals(null, result);
    }
    
    @isTest
    static void testGetArticleDataForPlatform() {
        Knowledge__kav article1 = [SELECT Id, KnowledgeArticleId FROM Knowledge__kav WHERE UrlName = 'testing-article-1-asdflkjh' LIMIT 1];
        
        List<AskHR_KnowledgeCustomTabs.Section> result = AskHR_KnowledgeCustomTabs.getArticleDataForPlatform(article1.Id);
        System.assertNotEquals(null, result);
    }
}