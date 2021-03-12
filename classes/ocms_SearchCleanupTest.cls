@isTest
public with sharing class ocms_SearchCleanupTest {
	public static testmethod void testSearchCleanup() {
		OCMS_Content_Search_Index__c ind = new OCMS_Content_Search_Index__c();
		insert ind;

		Test.startTest();
			Database.executeBatch(new ocms_SearchCleanup(Datetime.now().addSeconds(10)));
		Test.stopTest();

		System.assertEquals(0, [select Id from OCMS_Content_Search_Index__c].size());
	}
}