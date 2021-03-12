@isTest
public class AskHR_AutoPublishArticlesTest {
    
    @isTest
    static void testAutoPublish(){
        
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        List<Knowledge__kav> artticleList = new List<Knowledge__kav>();
        Knowledge__kav article1 = new Knowledge__kav(
            Title = 'Test Article 1',
            UrlName = 'testing-article-1',
            Language = 'en_US',
            Review_Date__c = Date.today());
        artticleList.add(article1);
        insert artticleList;
        
        system.debug(artticleList[0].KnowledgeArticleId);
        system.debug(artticleList[0].Id);
        List<Knowledge__kav> newartticleList = [Select id, Title,KnowledgeArticleId,LastModifiedbyId, OwnerId from Knowledge__kav where id = :artticleList[0].Id];
        system.debug('newartticleList');
            
        system.runAs(thisUser){
            
            Test.startTest();        
            System.enqueueJob(new AskHR_AutoPublishArticles(newartticleList));
            Test.stopTest();
            
        }
        
    }

}