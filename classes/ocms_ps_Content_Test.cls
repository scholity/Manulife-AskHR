//	ocms_ps_Content_Test

@isTest

private class ocms_ps_Content_Test {
	public ocms_ps_Content_Test() {
		
	}

	static testMethod void testgetSiteURLForMedia () {
		ocms_ps_Content cHelperNoPrefix = new ocms_ps_Content();

		// array of an array of strings; in the inner array, the first value is the input url, the second the expected output
		List<String> testURLs = new List<String>{
			'',
			'not a /servlet url',
			'/servlet/servlet.FileDownload?=ABC456GHI012345'
		};	

		// there will be no site prefix!
		// expect the same out as what went in
		for (String inURL : testURLs) {
			System.AssertEquals(inURL, cHelperNoPrefix.getSiteURLForMedia(inURL), 'Unexpected result from getSiteURLForMedia() for ' + inURL);
		}


		final String PREFIX = '/myTestPrefix';
		ocms_ps_Content cHelperWithPrefix = new ocms_ps_Content(PREFIX);

		System.AssertEquals(		 testURLS[0], cHelperWithPrefix.getSiteURLForMedia(testURLS[0]), 'Unexpected result from getSiteURLForMedia() with prefix for ' + testURLS[0]);
		System.AssertEquals( 		 testURLS[1], cHelperWithPrefix.getSiteURLForMedia(testURLS[1]), 'Unexpected result from getSiteURLForMedia() with prefix for ' + testURLS[1]);
		System.AssertEquals(PREFIX + testURLS[2], cHelperWithPrefix.getSiteURLForMedia(testURLS[2]), 'Unexpected result from getSiteURLForMedia() with prefix for ' + testURLS[2]);


		String throwAwayMarkup = cHelperWithPrefix.getHTML();
		// we don’t really care about what this markup is, we're just making this call for test coverage stats
		System.Assert(throwAwayMarkup.contains('override me!'), '• Unexpected value of getHTML(): ' + throwAwayMarkup);
	}
}	// <c ocms_ps_Content_Test>