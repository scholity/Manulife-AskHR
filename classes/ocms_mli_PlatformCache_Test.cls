@isTest
public with sharing class ocms_mli_PlatformCache_Test {
	public static testmethod void testSALCache() {
		String[] testList = new String[] {
			'firstId',
			'secondId'
		};

		List<String> responseList;

		// Test cache begins empty
		responseList = ocms_mli_PlatformCache.getSALKey('type', 'layout', 'primary', 'secondary');
		System.assertEquals(null, responseList, 'Cache should begin empty');

		// Test setter
		ocms_mli_PlatformCache.setSALKey('type', 'layout', 'primary/path', 'secondary/path', testList);
		responseList = ocms_mli_PlatformCache.getSALKey('type', 'layout', 'primary/path', 'secondary/path');
		System.assertEquals(testList.size(), responseList.size(), 'Cache should return the set list');

		// Test reset for another type
		ocms_mli_PlatformCache.resetSALKeys('anotherType');
		responseList = ocms_mli_PlatformCache.getSALKey('type', 'layout', 'primary/path', 'secondary/path');
		System.assertEquals(testList.size(), responseList.size(), 'Cache reset should affect one content type only');

		// Test reset
		ocms_mli_PlatformCache.resetSALKeys('type');
		responseList = ocms_mli_PlatformCache.getSALKey('type', 'layout', 'primary/path', 'secondary/path');
		System.assertEquals(null, responseList, 'Cache reset should clear keys for a content type');
	}

	public static testmethod void testKeyWithSpaces() {
		try {
			ocms_mli_PlatformCache.setSALKey('type with spaces', 'layout with spaces', 'primary with spaces', 'secondary with spaces', new String[]{});
		} catch(Cache.InvalidParamException e) {
			System.assert(false, 'Exception: ' + e.getMessage());
		}
	}

	public static testmethod void testLongKey() {
		try {
			ocms_mli_PlatformCache.setSALKey('veryLongContentTypeName', 'veryLongContentLayoutName', 'veryLongPrimaryTagPath/path', 'veryLongSecondaryTagPath/path', new String[]{});
		} catch(Cache.Org.OrgCacheException e) {
			System.assert(false, 'Exception: ' + e.getMessage());
		}
	}
}