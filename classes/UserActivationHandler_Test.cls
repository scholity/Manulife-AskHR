@isTest(SeeAllData = true)
public class UserActivationHandler_Test {

    @isTest static void testUpdateUserJIT() {
        Id employeeCommunityProfileId = [Select Id from Profile where Name = 'Employee Communities User'].Id;
        User testUser1 = new User(isActive = false, FirstName = 'tst', LastName = 'testuser1', email = 'test.user1@manulife.com', employee_Id__c = 'tstuser1testing', Pay_Country__c = 'CAN', LanguageLocaleKey = 'en_US', profileId = employeeCommunityProfileId, Country__c = 'CAN', Division__c = 'IDIS', FederationIdentifier = 'tstuser1testing', Username = 'tstuser1testing.' + UserHandler.m_TimeInMilli + '.test.user1@manulife.com', Alias = 'ttest', CommunityNickname = 'tstuser1te.tst.testuser1', TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US', EmailEncodingKey = 'ISO-8859-1', MFC_Country__c = 'Canada');   	
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        System.runAs(thisUser) {
            insert testUser1;
        }
        Map<String, String> attributes = new Map<String, String>();
        attributes.put('User.IsActive','true');
        
        UserActivationHandler handler = new UserActivationHandler();
        handler.updateUser(testUser1.Id, null , null, null,
    null, attributes, null);
        User u = [Select Id, isActive from user where Id = :testUser1.Id];
		System.assertEquals(true, u.IsActive);
    }
    }