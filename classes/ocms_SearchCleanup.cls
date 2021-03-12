global with sharing class ocms_SearchCleanup implements Database.Batchable<sObject> {
	private Datetime threshhold;
	private String siteName;

	global ocms_SearchCleanup(Datetime threshhold) {
		this.threshhold = threshhold;
	}

	global ocms_SearchCleanup(Datetime theshhold, String siteName) {
		this.threshhold = threshhold;
		this.siteName = siteName;
	}

	global database.QueryLocator start(Database.BatchableContext BC) {
		if(String.isBlank(siteName)) {
			return database.getQueryLocator('select Id from ocms_Content_Search_Index__c where SystemModStamp < :threshhold');
		} else {
			return database.getQueryLocator('select Id from ocms_Content_Search_Index__c where SystemModStamp < :threshhold and Site_Name__c = :siteName');
		}
	}

	global void execute(Database.BatchableContext BC, List<SObject> scope) {
		delete scope;
	}

	global void finish(Database.BatchableContext BC) {}
}