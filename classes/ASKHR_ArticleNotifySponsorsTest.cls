@isTest
public class ASKHR_ArticleNotifySponsorsTest { 

    @isTest (SeeAllData=true)
    static void notifySponsor(){

        Id knowledgeProfileId = [Select Id from Profile where Name = 'Knowledge Administrator'].Id;
        User testUser1 = new User(FirstName='tst',LastName='testuser1',email='test.user1@manulife.com', employee_Id__c = 'tstuser1testing',Pay_Country__c='CAN',LanguageLocaleKey='en_US',profileId = knowledgeProfileId);
        
        Id kRecordTypeId = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByName().get('AskHR Article').getRecordTypeId();
        Knowledge__kav testArticle = new Knowledge__kav(
            Title = 'Test Article',
            UrlName = 'testing-article',
            Language = 'en_US',
            Review_Date__c = Date.today(),
            RecordTypeId = kRecordTypeId
        );
				

        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
            
        // Insert account as current user
        System.runAs (thisUser) {
            insert testUser1;

            testArticle.AskHR_Article_Sponsor__c = testUser1.Id;
            insert testArticle;
			testArticle = [Select KnowledgeArticleId from Knowledge__kav where Id = :testArticle.Id LIMIT 1]; 
            String articleId = testArticle.KnowledgeArticleId;
            KbManagement.PublishingService.publishArticle(articleId, true);
        }
			
        Test.startTest();
        ASKHR_ArticleNotifySponsors sh1 = new ASKHR_ArticleNotifySponsors();
        String sch = '0 0 23 * * ?'; 
        system.schedule('ASKHR_ArticleNotifySponsors', sch, sh1); 

        Test.stopTest(); 

    
    }
}