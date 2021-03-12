@isTest
private class ocms_mfc_Bookmark_Test {
	static List<MFC_Community_Object__c> testBookmarks;

	static void createTestObjects() {
		RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType = 'MFC_Community_Object__c' AND DeveloperName = 'Bookmark'];
		String bookmarkRecordType = rt.Id;

		testBookmarks = new List<MFC_Community_Object__c>();

		testBookmarks.add(new MFC_Community_Object__c(
			RecordTypeId = bookmarkRecordType,
			User__c = UserInfo.getUserId(),
			URL__c = 'testURL1',
			Label__c = 'testLabel1'
		));

		testBookmarks.add(new MFC_Community_Object__c(
			RecordTypeId = bookmarkRecordType,
			User__c = UserInfo.getUserId(),
			URL__c = 'testURL2',
			Label__c = 'testLabel2'
		));

		testBookmarks.add(new MFC_Community_Object__c(
			RecordTypeId = bookmarkRecordType,
			User__c = UserInfo.getUserId(),
			URL__c = 'testURL3',
			Label__c = 'testLabel3'
		));

		testBookmarks.add(new MFC_Community_Object__c(
			RecordTypeId = bookmarkRecordType,
			URL__c = 'testURL4',
			Label__c = 'testLabel4'
		));

		insert testBookmarks;
	}

	static Boolean isValidJSON(String str) {
		JSONParser parser = JSON.createParser(str);
		try {
			while(parser.nextToken() != null) {}
		} catch(Exception e) {
			return false;
		}

		return true;
	}

	static testmethod void testType() {
		ocms_mfc_BookmarkContentServiceLayout service = new ocms_mfc_BookmarkContentServiceLayout();
		System.assertEquals(service.getType(), ocms_mfc_BookmarkContentServiceLayout.class);
	}

	static testmethod void testGet() {
		createTestObjects();

		ocms_mfc_BookmarkContentServiceLayout service = new ocms_mfc_BookmarkContentServiceLayout();

		// Test list version of get
		List<ocms_mfc_BookmarkContentServiceLayout.Bookmark> bookmarks = service.getBookmarks(UserInfo.getUserId(), 'prev');
		System.assertEquals(bookmarks.size(), 3);

		// Test JSON version of get
		String bookmarksJSON = service.getBookmarksJSONResponse(UserInfo.getUserId(), 'prev');
		System.assert(isValidJSON(bookmarksJSON));
		System.assert(bookmarksJSON.contains(JSON.serialize(bookmarks)));

		// Test service response
		Map<String, String> serviceParams = new Map<String, String>();
		serviceParams.put('action', 'get');
		String serviceResponse = service.executeRequest(serviceParams);
		System.assertEquals(serviceResponse, bookmarksJSON);

		// Test getHtml return value
		System.assertEquals(service.getHTML(), '');

		// Test getItems
		List<SelectOption> options = new List<SelectOption>(); 
		options = service.getItems();
		System.assertEquals(options.size(), 2);
	}

	static testmethod void testExceptionThrown() {
		createTestObjects();

		ocms_mfc_BookmarkContentServiceLayout service = new ocms_mfc_BookmarkContentServiceLayout();

		Id fakeUserId = '50130000000014c';

		String deleteJSON = service.deleteBookmarkJSONResponse(fakeUserId, testBookmarks[1].Id);
		System.assert(isValidJSON(deleteJSON));
	}

	static testmethod void testDelete() {
		createTestObjects();

		ocms_mfc_BookmarkContentServiceLayout service = new ocms_mfc_BookmarkContentServiceLayout();

		// Delete bookmark 0
		service.deleteBookmark(UserInfo.getUserId(), testBookmarks[0].Id);
		System.assertEquals(service.getBookmarks(UserInfo.getUserId(), 'prev').size(), 2);

		// Delete non-owned bookmark
		Boolean caughtException = false;
		try {
			service.deleteBookmark(UserInfo.getUserId(), testBookmarks[3].Id);
		} catch(Exception e) {
			caughtException = true;
		}
		System.assert(caughtException);

		// Test JSON version of delete
		String deleteJSON = service.deleteBookmarkJSONResponse(UserInfo.getUserId(), testBookmarks[1].Id);
		System.assertEquals(service.getBookmarks(UserInfo.getUserId(), 'prev').size(), 1);
		System.assert(isValidJSON(deleteJSON));

		// Test service response
		Map<String, String> serviceParams = new Map<String, String>();
		serviceParams.put('action', 'delete');
		serviceParams.put('id', testBookmarks[2].Id);
		String serviceResponse = service.executeRequest(serviceParams);
		System.assertEquals(service.getBookmarks(UserInfo.getUserId(), 'prev').size(), 0);
	}

	static testmethod void testPut() {
		createTestObjects();

		ocms_mfc_BookmarkContentServiceLayout service = new ocms_mfc_BookmarkContentServiceLayout();

		// Add a new bookmark
		ocms_mfc_BookmarkContentServiceLayout.Bookmark putBookmark = service.putBookmark(UserInfo.getUserId(), 'PutBookmarkURL', 'PutBookmarkLabel', 'prev');
		System.assertNotEquals(putBookmark.Id, null);

		// Add a new bookmark JSON version
		String putBookmarkJSON = service.putBookmarkJSONResponse(UserInfo.getUserId(), 'PutBookmarkURL2', 'PutBookmarkLabel2', 'prev');
		System.assert(isValidJSON(putBookmarkJSON));

		// Add a new bookmark service response
		Map<String, String> serviceParams = new Map<String, String>();
		serviceParams.put('action', 'put');
		serviceParams.put('url', 'PutBookmarkURL3');
		serviceParams.put('label', 'PutBookmarkLabel3');
		String serviceResponse = service.executeRequest(serviceParams);
		System.assertEquals(service.getBookmarks(UserInfo.getUserId(), 'prev').size(), 6);

		// Duplicate not inserted
		String duplicateBookmark = service.putBookmarkJSONResponse(UserInfo.getUserId(), 'PutBookmarkURL', 'PutBookmarkLabel', 'prev');
		System.assertEquals(service.getBookmarks(UserInfo.getUserId(), 'prev').size(), 6);
	}

	static testmethod void testGenerateConstructor() {
		// squeezing out code coverage
		//cms__Sites__c site = ocms_TestContentHelper.createTestSiteAndContext();
		//ocms_TestContentHelper tch = new ocms_TestContentHelper(site);
		ocms_TestContentHelper tch = new ocms_TestContentHelper();
		tch.createContent(new List<Map<String, String>>(), 'Bookmark');
		ocms_mfc_BookmarkContentServiceLayout bc = new ocms_mfc_BookmarkContentServiceLayout(tch.gc);

		// Test getters from editor
		System.assertEquals('Add Bookmark', bc.AddBookmarkName);
		System.assertEquals('Remove Bookmark', bc.RemoveBookmarkName);
		System.assertEquals('10', bc.NumberOfBookmarks);
		System.assertEquals('My Bookmarks', bc.BookmarkListTitle);
		System.assertEquals('no', bc.AllowBookmarkOrder);
	}
}