@isTest
public class AskHR_DeleteArticlePSApproversTest {
    
    @isTest(SeeAllData = true)
    static void testArticles(){
        
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        Id csrProfileId = [Select Id from Profile where Name = 'CSR'].Id;
        User testUser1 = new User(FirstName='tst',LastName='testuser1',email='test.user1@manulife.com', employee_Id__c = 'tstuser1testing',Pay_Country__c='CAN',LanguageLocaleKey='en_US',profileId = csrProfileId); 
    	insert testUser1;
        system.runAs(thisUser){
            
            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Label = :System.Label.AskHR_Knowledge_Permission];
            insert new PermissionSetAssignment(AssigneeId = testUser1.id, PermissionSetId = ps.Id);
            AskHR_DeleteArticlePSApprovers job = new AskHR_DeleteArticlePSApprovers();
            job.execute(null);
        }
    }
    
}