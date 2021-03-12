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
private class UserHandlerTest {
    
	@isTest(SeeAllData = true) static void testUserCore() {
		List<User> testUsers = new List<User> ();
		Id employeeCommunityProfileId = [Select Id from Profile where Name = 'Employee Communities User'].Id;
		Map<String, User_Country_Code_Based_Config__c> countryCodeBasedConfigs = ASKHR_UserService.getUserCountryCodeBasedConfigs();
		Map<String, User_Language_Based_Config__c> languageBasedConfigs = ASKHR_UserService.getUserLanguageBasedConfigs();
		User testUser1 = new User(FirstName = 'tst', LastName = 'testuser1', email = 'test.user1@manulife.com', employee_Id__c = 'tstuser1testing', Pay_Country__c = 'CAN', LanguageLocaleKey = 'en_US', profileId = employeeCommunityProfileId, Country__c = 'CAN', Division__c = 'IDIS', FederationIdentifier = 'tstuser1testing', Username = 'tstuser1testing.' + UserHandler.m_TimeInMilli + '.test.user1@manulife.com', Alias = 'ttest', CommunityNickname = 'tstuser1te.tst.testuser1', TimeZoneSidKey = countryCodeBasedConfigs.get('CAN').TimeZoneSidKey__c, LocaleSidKey = countryCodeBasedConfigs.get('CAN').LocaleSidKey__c, EmailEncodingKey = languageBasedConfigs.get('en_US').EmailEncodingKey__c, MFC_Country__c = 'Canada');
		testUsers.add(testUser1);

		User testUser2 = new User(LastName = 'testuser2', email = 'test.user2@manulife.com', employee_Id__c = 'tstuser2testing', Pay_Country__c = 'XYZ', LanguageLocaleKey = 'en_US', profileId = employeeCommunityProfileId, Country__c = 'US', Division__c = 'JH', Username = '25123236496.meivira_srihanoki@manulife.com.deploymfc', Alias = 'test', CommunityNickname = 'tstuser2te.testuser2', TimeZoneSidKey = countryCodeBasedConfigs.get('USA').TimeZoneSidKey__c, LocaleSidKey = countryCodeBasedConfigs.get('USA').LocaleSidKey__c, EmailEncodingKey = languageBasedConfigs.get('en_US').EmailEncodingKey__c);
		testUsers.add(testUser2);

		User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
		// Insert account as current user
		System.runAs(thisUser) {
			Test.startTest();
			insert testUsers;
			Test.stopTest();
		}

		testUsers = [Select Id, FirstName, LastName, email, employee_id__c, FederationIdentifier, Pay_Country__c, LanguageLocaleKey,
		             Alias, CommunityNickname, Username, EmailEncodingKey, LocaleSidKey, TimeZoneSidKey, ProfileId from User where Id in(:testUser1.Id, :testUser2.Id)];

		Set<Id> userIds = new Set<Id> ();
		for (User usr : testUsers) {
			if (usr.Id == testUser1.Id) {
				testUser1 = usr;
			} else if (usr.Id == testUser2.Id) {
				testUser2 = usr;
			}
			userIds.add(usr.Id);
		}

		Map<Id, List<PermissionSetAssignment>> permissionSetAssignmentsByUserIds = ASKHR_UserService.getPermissionSetAssignmentsByUserIds(userIds);
		System.assert(!permissionSetAssignmentsByUserIds.isEmpty());
		System.assertEquals(2, permissionSetAssignmentsByUserIds.keySet().size());


		System.assert(!languageBasedConfigs.isEmpty());


		System.assert(!countryCodeBasedConfigs.isEmpty());


		System.assertEquals('tstuser1te.tst.testuser1', testUser1.CommunityNickname);
		System.assertEquals('ttest', testUser1.Alias);
		System.assertEquals('tstuser1testing.' + UserHandler.m_TimeInMilli + '.test.user1@manulife.com', testUser1.Username);
		System.assertEquals(languageBasedConfigs.get('en_US').EmailEncodingKey__c, testUser1.EmailEncodingKey);
		System.assertEquals(countryCodeBasedConfigs.get('CAN').LocaleSidKey__c, testUser1.LocaleSidKey);
		System.assertEquals(countryCodeBasedConfigs.get('CAN').TimeZoneSidKey__c, testUser1.TimeZoneSidKey);
		System.assertEquals('tstuser1testing', testUser1.FederationIdentifier);




		System.assertEquals('tstuser2te.testuser2', testUser2.CommunityNickname);
		System.assertEquals('test', testUser2.Alias);
		//country XYZ and language en_CA should default to USA and en_US respectively
		System.assertEquals(languageBasedConfigs.get('en_US').EmailEncodingKey__c, testUser2.EmailEncodingKey);
		System.assertEquals(countryCodeBasedConfigs.get('USA').LocaleSidKey__c, testUser2.LocaleSidKey);
		System.assertEquals(countryCodeBasedConfigs.get('USA').TimeZoneSidKey__c, testUser2.TimeZoneSidKey);



		//Prepare for update users      
		testUser1.Pay_Country__c = 'XYZ';
		testUser1.LastName = 'testuser1_modifiedlastname';
		testUser1.LanguageLocaleKey = 'en_US';
		testUser1.Employee_ID__c = 'tstuser1testing_modified';

		testUser2.LastName = 'testuser2_modifiedlastname';
		testUser2.LanguageLocaleKey = 'fr';

		update testUsers;

		testUsers = [Select Id, FirstName, LastName, email, employee_id__c, FederationIdentifier, Pay_Country__c, LanguageLocaleKey,
		             Alias, CommunityNickname, Username, EmailEncodingKey, LocaleSidKey, TimeZoneSidKey, ProfileId, MFC_Country__c, MFC_Division__c from User where Id in(:testUser1.Id, :testUser2.Id)];
		for (User usr : testUsers) {
			if (usr.Id == testUser1.Id) {
				testUser1 = usr;
			} else if (usr.Id == testUser2.Id) {
				testUser2 = usr;
			}
		}

		permissionSetAssignmentsByUserIds = ASKHR_UserService.getPermissionSetAssignmentsByUserIds(userIds);
		System.assert(!permissionSetAssignmentsByUserIds.isEmpty());
		System.assertEquals(2, permissionSetAssignmentsByUserIds.keySet().size());

		//country XYZ and language en_CA should default to USA and en_US respectively
		System.assertEquals(languageBasedConfigs.get('en_US').EmailEncodingKey__c, testUser1.EmailEncodingKey);
		//System.assertEquals(countryCodeBasedConfigs.get('USA').LocaleSidKey__c, testUser1.LocaleSidKey);
		//System.assertEquals(countryCodeBasedConfigs.get('USA').TimeZoneSidKey__c, testUser1.TimeZoneSidKey);
		//System.assertEquals('Canada', testUser1.MFC_Country__c);
		//System.assertEquals('Investments', testUser1.MFC_Division__c);

		System.assertEquals(languageBasedConfigs.get('fr').EmailEncodingKey__c, testUser2.EmailEncodingKey);
		System.assertEquals(countryCodeBasedConfigs.get('USA').LocaleSidKey__c, testUser2.LocaleSidKey);
		System.assertEquals(countryCodeBasedConfigs.get('USA').TimeZoneSidKey__c, testUser2.TimeZoneSidKey);
		//System.assertEquals('United States', testUser2.MFC_Country__c);
		//System.assertEquals('John Hancock', testUser2.MFC_Division__c);

	}

	@isTest(SeeAllData = true) static void testUserRoleForCSR()
	{
		Id csrTierRoleId = [Select Id from UserRole where Name = 'CSR Tier 1 - China'].Id;
		Id csrMgrRoleId = [Select Id from UserRole where Name = 'CSR Manager'].Id;
		Id analystRoleId = [Select Id from UserRole where Name = 'GHRBS Analyst'].Id;
		Id profileId = [Select Id from Profile where Name = 'CSR'].Id;

		List<User> testUsers = new List<User> ();

		User testUser1 = new User(FirstName = 'tstcsr1', LastName = 'testcsruser1', email = 'tstcsr1.user1@manulife.com', employee_Id__c = 'tstcsruser1testing', Pay_Country__c = 'CAN', LanguageLocaleKey = 'en_US', ProfileId = profileId, UserRoleId = csrTierRoleId);
		testUsers.add(testUser1);

		User testUser2 = new User(FirstName = 'tstcsr2', LastName = 'testcsruser2', email = 'tstcsr2.user2@manulife.com', employee_Id__c = 'tstcsruser2testing', Pay_Country__c = 'XYZ', LanguageLocaleKey = 'en_US', ProfileId = profileId, UserRoleId = csrMgrRoleId);
		testUsers.add(testUser2);

		User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
		// Insert account as current user
		System.runAs(thisUser) {
			insert testUsers;
			List<CaseTeamTemplateMember> newMemberList1 = [Select Id FROM CaseTeamTemplateMember WHERE MemberId = :String.valueOf(testUser1.Id)];
			System.assertEquals(1, newMemberList1.size());

			List<CaseTeamTemplateMember> newMemberList2 = [Select Id FROM CaseTeamTemplateMember WHERE MemberId = :String.valueOf(testUser2.Id)];
			System.assertEquals(1, newMemberList2.size());

			testUser2.UserRoleId = csrTierRoleId;
			update testUser2;
			List<CaseTeamTemplateMember> newMemberList3 = [Select Id FROM CaseTeamTemplateMember WHERE MemberId = :String.valueOf(testUser2.Id)];
			System.assertEquals(1, newMemberList3.size());

			testUser2.UserRoleId = analystRoleId;
			update testUser2;
			List<CaseTeamTemplateMember> newMemberList4 = [Select Id FROM CaseTeamTemplateMember WHERE MemberId = :String.valueOf(testUser2.Id)];
			//System.assertEquals(1, newMemberList4.size());
		}
	}

	@isTest(SeeAllData = true) static void testUserChangeProfile() {
		Id employeeCommunityProfileId = [Select Id from Profile where Name = 'Employee Communities User'].Id;
		Id employeeCommunityManagerProfileId = [Select Id from Profile where Name = 'Employee Communities Manager'].Id;
		Id companyCommunityProfileId = [Select Id from Profile where Name = 'Company Communities User'].Id;
		User testUser1 = new User(FirstName = 'tst', LastName = 'testuser1', email = 'test.user1@manulife.com', employee_Id__c = 'tstuser1testing', Pay_Country__c = 'CAN', LanguageLocaleKey = 'en_US', profileId = employeeCommunityProfileId, Country__c = 'CAN', Division__c = 'IDIS', FederationIdentifier = 'tstuser1testing', Username = 'tstuser1testing.' + UserHandler.m_TimeInMilli + '.test.user1@manulife.com', Alias = 'ttest', CommunityNickname = 'tstuser1te.tst.testuser1', MFC_Country__c = 'Canada');

		User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
		// Insert account as current user
		System.runAs(thisUser) {
			Test.startTest();
			insert testUser1;
			Test.stopTest();
		}

		testUser1.ProfileId = employeeCommunityManagerProfileId;
		update testUser1;
		System.assertEquals(employeeCommunityManagerProfileId, testUser1.ProfileId);

		//Prepare for update user profiles      
		testUser1.ProfileId = companyCommunityProfileId;
		update testUser1;
		System.assertEquals(companyCommunityProfileId, testUser1.ProfileId);

		testUser1.ProfileId = employeeCommunityProfileId;
		update testUser1;

		System.assertEquals(employeeCommunityProfileId, testUser1.ProfileId);
		System.assertNotEquals(companyCommunityProfileId, testUser1.ProfileId);
	}

	@isTest(SeeAllData = true) static void testUserReAssignCaseTeam()
	{
		Map<String, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Case.getRecordTypeInfosByName();
		Id communityRoleId = [Select Id from UserRole where Name = 'Community Employee'].Id;
		Id communityProfileId = [Select Id from Profile where Name = 'Employee Communities User'].Id;

		User testUser = new User(FirstName = 'tstcsr1', LastName = 'testcsruser1', email = 'tstcsr1.user1@manulife.com', employee_Id__c = 'tstcsruser1testing', Pay_Country__c = 'CAN', LanguageLocaleKey = 'en_US', ProfileId = communityProfileId, UserRoleId = communityRoleId);

		Contact newContact = ASKHR_TestUtility.createContact();

		User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];

		// Insert account as current user
		System.runAs(thisUser) {
			insert testUser;
			newContact.User__c = testUser.Id;
			update newContact;


			Test.startTest();
			List<Case> testCases = new List<Case> ();
			Case testCase = new Case(Type = 'Benefits',
			                         Origin = 'Ask HR',
			                         Secondary_Country_of_Reference__c = 'CAN',
			                         RecordTypeId = rtMap.get(ASKHR_Common.CASE_RECORD_TYPE_NAME_GENERAL_HR).getRecordTypeId());
			testCase.ContactId = newContact.Id;
			testCases.add(testCase);
			Case testCase2 = new Case(Type = 'Benefits',
			                          Origin = 'Ask HR',
			                          External_Contact_Name__c = 'Test',
			                          Secondary_Country_of_Reference__c = 'CAN',
			                          RecordTypeId = rtMap.get(ASKHR_Common.CASE_RECORD_TYPE_NAME_GENERAL_HR).getRecordTypeId());
			testCases.add(testCase2);
			insert testCases;

			Map<String, Id> caseTeamRolesMap = ASKHR_CaseService.getCaseTeamRolesByName();
			CaseTeamMember newCtm = new CaseTeamMember();
			//Case Contact
			newCtm.ParentId = testCase2.Id;
			newCtm.MemberId = testUser.Id;
			newCtm.TeamRoleId = caseTeamRolesMap.get(ASKHR_Common.CASE_TEAM_ROLE_CASE_CONTACT);
			insert newCtm;

			testUser.IsActive = false;
			update testUser;

			testUser.IsActive = true;
			update testUser;

			Test.stopTest();
		}
	}

    static testMethod void longIdTest(){
        String testId = '0PSW00000000DvR';
        System.debug(testId);
        String resultId = ASKHR_UserHandlerPermissionSetAssignment.getLongId(testId);
        
        System.assertEquals(18, resultId.length(), 'Result length must be 18');
        
        testId = '0PSW00000000DVR';
        System.debug(testId);
        resultId = ASKHR_UserHandlerPermissionSetAssignment.getLongId(testId);
        
        System.assertEquals(18, resultId.length(), 'Result length must be 18');
        
        testId = '0PSW00000000DVRaaa';
        System.debug(testId);
        resultId = ASKHR_UserHandlerPermissionSetAssignment.getLongId(testId);
        
        System.assertEquals(18, resultId.length(), 'Result length must be 18');
    }
}