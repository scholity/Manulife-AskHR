@isTest
public with sharing class ocms_SearchConfigTest {
	public static testmethod void testSearchConfig() {
		String sname = 'TestSite';
		String ctName = 'TestCT';

		String config =
			'{' +
				'"' + sname + '":{' +
					'"' + ctName + '":{' +
						'"Search_Content_Attributes": "[\\"body\\"]",' +
						'"Search_Description_Attribute": "summary",' +
						'"Search_Indexable_Attributes": "[\\"title\\",\\"summary\\",\\"body\\",\\"author\\",\\"authorEmail\\",\\"authorTitle\\",\\"authorPhone\\"]",' +
						'"Search_Thumbnail_Attribute": "imageIcon",' +
						'"Search_Title_Attribute": "title",' +
						'"Search_Detail_Page_Attributes": "[\\"newsLink\\",\\"webLink\\",\\"socialLink\\"]"' +
					'}' +
				'}' +
			'}';


		cms__Sites__c s = new cms__Sites__c(
			cms__Site_Name__c = sname
		);
		insert s;

		cms__Content_Type__c ct = new cms__Content_Type__c(
			cms__Name__c = ctName,
			cms__Sites__c = s.Id,
			cms__Site_Name__c = sname
		);
		insert ct;

		ocms_SearchConfig.configureContentTypes('non-existant resource');

		ct = [select Id, Include_In_Search_Index__c from cms__Content_Type__c where Id = :ct.Id];
		System.assert(!ct.Include_In_Search_Index__c);

		ocms_SearchConfig.configureContentTypes(
			(Map<String, Object>)JSON.deserializeUntyped(config),
			new Map<String, String>()
		);

		ct = [select Id, Include_In_Search_Index__c from cms__Content_Type__c where Id = :ct.Id];
		System.assert(ct.Include_In_Search_Index__c);
	}
}