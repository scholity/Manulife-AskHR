@isTest
private class ocms_mfc_CareersMap_Test {
	static testMethod void testGetHTML() {
        ocms_TestContentHelper tch = new ocms_TestContentHelper();
        // Test the default controller
        ocms_mfc_CareersMap careersMapController = new ocms_mfc_CareersMap();
        List<Map<String,String>> attr_map = new List<Map<String, String>>();

	    Map<String, String> am = new Map<String, String>();
	    am = new Map<String, String>();
	    am.put('name', 'chinaText');
	    am.put('value', 'chinaText');
	    am.put('type', 'text');
	    attr_map.add(am);

	    am = new Map<String, String>();
	    am.put('name', 'hongKongText');
	    am.put('value', 'hongKongText');
	    am.put('type', 'text');
	    attr_map.add(am);

	    am = new Map<String, String>();
	    am.put('name', 'vietnamText');
	    am.put('value', 'vietnamText');
	    am.put('type', 'text');
	    attr_map.add(am);

	    am = new Map<String, String>();
	    am.put('name', 'thailandText');
	    am.put('value', 'thailandText');
	    am.put('type', 'text');
	    attr_map.add(am);

	    am = new Map<String, String>();
	    am.put('name', 'cambodiaText');
	    am.put('value', 'cambodiaText');
	    am.put('type', 'text');
	    attr_map.add(am);

	    am = new Map<String, String>();
	    am.put('name', 'malaysiaText');
	    am.put('value', 'malaysiaText');
	    am.put('type', 'text');
	    attr_map.add(am);

	    am = new Map<String, String>();
	    am.put('name', 'singaporeText');
	    am.put('value', 'singaporeText');
	    am.put('type', 'text');
	    attr_map.add(am);

	    am = new Map<String, String>();
	    am.put('name', 'indonesiaText');
	    am.put('value', 'indonesiaText');
	    am.put('type', 'text');
	    attr_map.add(am);

	    am = new Map<String, String>();
	    am.put('name', 'philippinesText');
	    am.put('value', 'philippinesText');
	    am.put('type', 'text');
	    attr_map.add(am);

	    am = new Map<String, String>();
	    am.put('name', 'taiwanText');
	    am.put('value', 'taiwanText');
	    am.put('type', 'text');
	    attr_map.add(am);

	    am = new Map<String, String>();
	    am.put('name', 'japanText');
	    am.put('value', 'japanText');
	    am.put('type', 'text');
	    attr_map.add(am);

	    am = new Map<String, String>();
	    am.put('name', 'unitedStatesText');
	    am.put('value', 'unitedStatesText');
	    am.put('type', 'text');
	    attr_map.add(am);

	    am = new Map<String, String>();
	    am.put('name', 'canadaText');
	    am.put('value', 'canadaText');
	    am.put('type', 'text');
	    attr_map.add(am);

	    am = new Map<String, String>();
	    am.put('name', 'chinaLink');
	    am.put('value', 'chinaLink');
	    am.put('type', 'text');
	    attr_map.add(am);

	    am = new Map<String, String>();
	    am.put('name', 'hongKongLink');
	    am.put('value', 'hongKongLink');
	    am.put('type', 'text');
	    attr_map.add(am);

	    am = new Map<String, String>();
	    am.put('name', 'vietnamLink');
	    am.put('value', 'vietnamLink');
	    am.put('type', 'text');
	    attr_map.add(am);

	    am = new Map<String, String>();
	    am.put('name', 'thailandLink');
	    am.put('value', 'thailandLink');
	    am.put('type', 'text');
	    attr_map.add(am);

	    am = new Map<String, String>();
	    am.put('name', 'cambodiaLink');
	    am.put('value', 'cambodiaLink');
	    am.put('type', 'text');
	    attr_map.add(am);

	    am = new Map<String, String>();
	    am.put('name', 'malaysiaLink');
	    am.put('value', 'malaysiaLink');
	    am.put('type', 'text');
	    attr_map.add(am);

	    am = new Map<String, String>();
	    am.put('name', 'singaporeLink');
	    am.put('value', 'singaporeLink');
	    am.put('type', 'text');
	    attr_map.add(am);

	    am = new Map<String, String>();
	    am.put('name', 'indonesiaLink');
	    am.put('value', 'indonesiaLink');
	    am.put('type', 'text');
	    attr_map.add(am);

	    am = new Map<String, String>();
	    am.put('name', 'philippinesLink');
	    am.put('value', 'philippinesLink');
	    am.put('type', 'text');
	    attr_map.add(am);

	    am = new Map<String, String>();
	    am.put('name', 'taiwanLink');
	    am.put('value', 'taiwanLink');
	    am.put('type', 'text');
	    attr_map.add(am);

	    am = new Map<String, String>();
	    am.put('name', 'japanLink');
	    am.put('value', 'japanLink');
	    am.put('type', 'text');
	    attr_map.add(am);

	    am = new Map<String, String>();
	    am.put('name', 'unitedStatesLink');
	    am.put('value', 'unitedStatesLink');
	    am.put('type', 'text');
	    attr_map.add(am);

	    am = new Map<String, String>();
	    am.put('name', 'canadaLink');
	    am.put('value', 'canadaLink');
	    am.put('type', 'text');
	    attr_map.add(am);

	    tch.createContent(attr_map, 'CareersMap');
		careersMapController = new ocms_mfc_CareersMap(tch.gc);

    	System.assertEquals(careersMapController.canadaLink, 'canadaLink');
	    System.assertEquals(careersMapController.unitedStatesLink, 'unitedStatesLink');
	    System.assertEquals(careersMapController.japanLink, 'japanLink');
	    System.assertEquals(careersMapController.taiwanLink, 'taiwanLink');
	    System.assertEquals(careersMapController.philippinesLink, 'philippinesLink');
	    System.assertEquals(careersMapController.indonesiaLink, 'indonesiaLink');
	    System.assertEquals(careersMapController.singaporeLink, 'singaporeLink');
		System.assertEquals(careersMapController.malaysiaLink, 'malaysiaLink');
	    System.assertEquals(careersMapController.cambodiaLink, 'cambodiaLink');
	    System.assertEquals(careersMapController.thailandLink, 'thailandLink');
	    System.assertEquals(careersMapController.vietnamLink, 'vietnamLink');
	    System.assertEquals(careersMapController.hongKongLink, 'hongKongLink');
	    System.assertEquals(careersMapController.chinaLink, 'chinaLink');
	    System.assertEquals(careersMapController.canadaText, 'canadaText');
	    System.assertEquals(careersMapController.unitedStatesText, 'unitedStatesText');
	    System.assertEquals(careersMapController.japanText, 'japanText');
	    System.assertEquals(careersMapController.taiwanText, 'taiwanText');
	    System.assertEquals(careersMapController.philippinesText, 'philippinesText');
	    System.assertEquals(careersMapController.indonesiaText, 'indonesiaText');
	    System.assertEquals(careersMapController.singaporeText, 'singaporeText');
		System.assertEquals(careersMapController.malaysiaText, 'malaysiaText');
	    System.assertEquals(careersMapController.cambodiaText, 'cambodiaText');
	    System.assertEquals(careersMapController.thailandText, 'thailandText');
	    System.assertEquals(careersMapController.vietnamText, 'vietnamText');
	    System.assertEquals(careersMapController.hongKongText, 'hongKongText');
	    System.assertEquals(careersMapController.chinaText, 'chinaText');

	    List<Feed_Data__c> feedDataList = new List<Feed_Data__c>();
	    Integer counter = 0;
	    List<String> countryCodes = new List<String> {
			'Canada',
			'United States',
			'Japan',
			'China',
			'Taiwan',
			'Thailand',
			'Singapore',
			'Vietnam',
			'Malaysia',
			'Philippines',
			'Indonesia',
			'Hong Kong',
			'Cambodia'
		};

		RecordType recordType = new RecordType(name='Job Count');

		for(String countryCode :countryCodes) {
			feedDataList.add(new Feed_Data__c(Country__c=countryCode, SumNumberToHire__c=counter, RecordType=recordType));
    		counter++;
		}

		feedDataList.add(new Feed_Data__c(Country__c='ASD', SumNumberToHire__c=-6, RecordType=recordType));

		insert feedDataList;

		String html = careersMapController.getHTML();

	}
}