public with sharing class ocms_SearchConfig {
	private static final String searchFieldList =
		'cms__Name__c,' +
		'Include_In_Search_Index__c,' +
		'Search_Content_Attributes__c,' +
		'Search_Description_Attribute__c,' +
		'Search_Document_Attributes__c,' +
		'Search_Indexable_Attributes__c,' +
		'Search_Thumbnail_Attribute__c,' +
		'Search_Title_Attribute__c,' +
		'Search_Detail_Page_Attributes__c,' +
		'Search_Detail_Page_Name__c';

	public static void configureContentTypes(String resourceName) {
		configureContentTypes(resourceName, null);
	}

	public static void configureContentTypes(String resourceName, Map<String, String> siteMapping) {
		if(siteMapping == null) siteMapping = new Map<String, String>();

		String resourceContents = '{}';
		if(!Test.isRunningTest()) {
			resourceContents = [select Body from StaticResource where Name=:resourceName limit 1].Body.toString();
		}

		Map<String, Object> data = (Map<String, Object>)JSON.deserializeUntyped(resourceContents);

		configureContentTypes(data, siteMapping);
	}

	@TestVisible
	private static void configureContentTypes(Map<String, Object> data, Map<String, String> siteMapping) {
		List<SObject> typesToUpdate = new List<SObject>();

		for(String mappedSiteName : data.keySet()) {
			Map<String, Object> typeConfigs = (Map<String, Object>)data.get(mappedSiteName);
			String siteName = siteMapping.containsKey(mappedSiteName) ? siteMapping.get(mappedSiteName) : mappedSiteName;

			Set<String> contentTypeNames = typeConfigs.keySet();
			String query = 'select ' + searchFieldList + ' from cms__Content_Type__c ' +
				'where cms__Sites__r.cms__Site_Name__c=:siteName ' +
					'and cms__Name__c in :contentTypeNames';

			List<SObject> siteContentTypes = Database.query(query);

			for(SObject contentType : siteContentTypes) {
				String typeName = (String)contentType.get('cms__Name__c');
				Map<String, Object> typeConfig = (Map<String, Object>)typeConfigs.get(typeName);

				for(String fieldName : typeConfig.keySet()) {
					String fieldValue = (String)typeConfig.get(fieldName);
					contentType.put(fieldName + '__c', fieldValue);
				}

				contentType.put('Include_In_Search_Index__c', true);

				typesToUpdate.add(contentType);
			}
		}

		update typesToUpdate;
	}
}