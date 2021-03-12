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
public class ASKHR_ArticleFeedbackExtTest {

 
    static testMethod void validateFeedbackTest(){
        //TODO: Create article
        //TODO: Create feedback page
        ASKHR_ArticleFeedbackExt article = new ASKHR_ArticleFeedbackExt();
        article.description = 'test';
        article.mLanguage = 'en_US';    
         
        ASKHR_ArticleFeedback__c art = article.articleFeedback;
        insert art;     
        
        ApexPages.currentPage().getParameters().put('id', art.Id);
        ApexPages.StandardController stdController = new ApexPages.StandardController(article.articleFeedback);
        
        ASKHR_ArticleFeedbackExt articlePage = new ASKHR_ArticleFeedbackExt(stdController);
        articlePage.doAccept();
        articlePage.doArchive(); 
        
        System.assertEquals(null, articlePage.mArticleId);
        System.assertEquals(null,articlePage.mArticleName);
        system.assertEquals(null, articlePage.mFeedbackId);
        system.assertNotEquals(null, articlePage.mEmployeeId);
        system.assertNotEquals(null, articlePage.mIsError);
        system.assertNotEquals(null, articlePage.mCommentRecordTypeId);
        System.assertNotEquals(true,articlePage.feedbackSubmitted);
        System.assertNotEquals(null,articlePage.mEmployeeName);
        
    }
    
    static testMethod void validateFeedbackTestMultiple(){
        //TODO: Create article
        //TODO: Create feedback page
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        List<ASKHR_ArticleFeedback__c> arts = new List<ASKHR_ArticleFeedback__c>();
       
        ASKHR_ArticleFeedback__c art = new ASKHR_ArticleFeedback__c();  
        art.Description__c = 'test';
        art.Status__c = 'Open';
        art.OwnerId = thisUser.Id;
        arts.add(art);

        ASKHR_ArticleFeedback__c art2 = new ASKHR_ArticleFeedback__c();          
        art2.Description__c = 'test 2';
        art2.Status__c = 'Open';
        art2.OwnerId = thisUser.Id;
        arts.add(art2);
            
        // Insert account as current user
        System.runAs (thisUser) {            
        	insert arts; 
            ApexPages.Standardsetcontroller stdSetController = new ApexPages.Standardsetcontroller(arts);
            stdSetController.setSelected(arts);
            ASKHR_ArticleFeedbackExt articlePage = new ASKHR_ArticleFeedbackExt(stdSetController);
            articlePage.doAccepts(); 
        
        }       
        
    }
    
    @isTest
    static void validateFeedbackWithArticle(){
        
        Knowledge__kav testArticle = new Knowledge__kav(
            Title = '(Global) Test',
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
            
            Test.startTest();
            ASKHR_ArticleFeedbackExt article = new ASKHR_ArticleFeedbackExt();
            article.description = 'test';
            article.mLanguage = 'en_US';    
            article.mArticleId = testArticle.Id;
            article.articleFeedback.Description__c = 'Test';
            article.save();
            Test.stopTest();
        }
    }
    
    @isTest
    static void validateFeedbackWithArticleNegativeTest(){
        
        Knowledge__kav testArticle = new Knowledge__kav(
            Title = 'Test',
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
            
            Test.startTest();
            ASKHR_ArticleFeedbackExt article = new ASKHR_ArticleFeedbackExt();
            article.description = 'test';
            article.mLanguage = 'en_US';    
            article.mArticleId = testArticle.Id;  
            article.save();
            
            article.articleFeedback.Description__c = 'Test';
            article.save();
            
            ASKHR_ArticleFeedback__c afeedback = new ASKHR_ArticleFeedback__c();
            ApexPages.StandardController stdController = new ApexPages.StandardController(afeedback);
            article = new ASKHR_ArticleFeedbackExt(stdController);
            Test.stopTest();
        }
    }
}