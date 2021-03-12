@isTest
private with sharing class ocms_mfc_IPUtility_Test {

	// @!TODO!
	// ideally, with time, we'd iterate through arrays of good test data (or other techniques)
	// until then, most of these test methods are only giving us test coverage, not thorough test cases


	public static testmethod void testMiscellaneous() {
		String ipNow = ocms_mfc_IPUtility.getUserIPAddress();
		System.Debug('Current IP address: ' + ipNow);


		final String TEST_IP = '167.92.59.0';
		// without being executed from a page context, this method will not return an IP
		System.AssertEquals(TEST_IP, ipNow, 'ip address unexpectedly NOT the fake test result I expected! ' + ipNow);


		// @!TODO!
		// better simulation of page context like:
		// 		PageReference page = new PageReference('http://www.dummy.com');
		//		page.getParameters().put('eventId', createdEvent.Id);
		//		System.Test.setCurrentPage(page);


		// try once without any records for test coverage
		ocms_mfc_IPUtility.updateIPRangeValues();

		Internal_IP_Ranges__c testRange = new Internal_IP_Ranges__c();
		testRange.Name = 'testRange';
		testRange.CIDR__c = '167.92.59.0/24';
		insert testRange;

		ocms_mfc_IPUtility.updateIPRangeValues();

		System.Assert(ocms_mfc_IPUtility.isInternalIP(TEST_IP), '•• IP unexpectedly not considerd internal!');
		System.Assert(!ocms_mfc_IPUtility.isInternalIP('222.0.0.0'), '•• IP unexpectedly considerd internal!');
	}	// testMiscellaneous


	public static testmethod void testIPConversions() {
		String kStringIP = '167.92.59.0';
		Long kLongIP = 2807839488L;

		System.AssertEquals(ocms_mfc_IPUtility.stringIPToLong(kStringIP), kLongIP, 'stringIPToLong failed!');
		System.AssertEquals(ocms_mfc_IPUtility.longToIPOctets(kLongIP), kStringIP, 'longToIPOctets failed!');
	}	// testIPConversions


	public static testmethod void testCIDRConversion() {
		String cidr = '167.92.59.0/24';
		Long startIP = 2807839488L;
		Long endIP = 2807839743L;

		ocms_mfc_IPUtility.ipIntRange intRange = ocms_mfc_IPUtility.ipRangeFromCIDR(cidr);

		System.AssertEquals(intRange.startIP, startIP, 'Converted startIP as integer value incorrect: ' + intRange.startIP);
		System.AssertEquals(intRange.endIP, endIP, 'Converted endIP as integer value incorrect: ' + intRange.endIP);
	}	// testCIDRConversion
}