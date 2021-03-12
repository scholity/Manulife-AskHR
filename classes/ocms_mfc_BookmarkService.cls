global with sharing class ocms_mfc_BookmarkService implements cms.ServiceInterface {
	global ocms_mfc_BookmarkService() {}
	
	public System.Type getType() {
		return ocms_mfc_BookmarkService.class;
	}

	public class Bookmark {
		public String id;
		public String url;
		public String label;

		public Bookmark(MFC_Community_Object__c b) {
			this.id = b.Id;
			this.url = b.URL__c;
			this.label = b.Label__c;
		}
	}

	public class BookmarkException extends Exception {}

	public String executeRequest(Map<String, String> p) {
		String action = p.get('action');
		Id currentUser = UserInfo.getUserId();

		String response = '{"success":false,"message":"Action not supported."}';

		if(currentUser == null) return response;

		if(action == 'get') {
			response = getBookmarksJSONResponse(currentUser);
		} else if(action == 'delete') {
			String id = p.get('id');
			response = deleteBookmarkJSONResponse(currentUser, id);
		} else if(action == 'put') {
			String url = p.get('url');
			String label = p.get('label');
			response = putBookmarkJSONResponse(currentUser, url, label);
		}

		return response;
	}

	public List<Bookmark> getBookmarks(Id userId) {
		RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType = 'MFC_Community_Object__c' AND DeveloperName = 'Bookmark'];
		String bookmarkRecordType = rt.Id;

		List<Bookmark> bookmarks = new List<Bookmark>();
		List<MFC_Community_Object__c> bookmarkSObjects = [SELECT Id, URL__c, Label__c FROM MFC_Community_Object__c WHERE User__c=:userId AND RecordTypeId =:bookmarkRecordType];

		for(MFC_Community_Object__c currentBookmark : bookmarkSObjects) {
			bookmarks.add(new Bookmark(currentBookmark));
		}

		return bookmarks;
	}

	public String getBookmarksJSONResponse(Id userId) {
		List<Bookmark> bookmarks = getBookmarks(userId);

		return '{"success":true,"bookmarks":'+JSON.serialize(bookmarks)+'}';
	}

	public void deleteBookmark(Id userId, String bookmarkId) {
		RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType = 'MFC_Community_Object__c' AND DeveloperName = 'Bookmark'];
		String bookmarkRecordType = rt.Id;

		MFC_Community_Object__c currentBookmark = [SELECT Id FROM MFC_Community_Object__c WHERE User__c=:userId AND Id=:bookmarkId AND RecordTypeId =:bookmarkRecordType];

		if(currentBookmark == null) throw new BookmarkException('Bookmark not found. It may have already been deleted.');

		delete currentBookmark;
	}

	public String deleteBookmarkJSONResponse(Id userId, String bookmarkId) {
		try {
			deleteBookmark(userId, bookmarkId);
		} catch(Exception e) {
			return '{"success":false,"message":'+JSON.serialize(e.getMessage())+'}';
		}

		return '{"success":true}';
	}

	public Bookmark putBookmark(Id userId, String url, String label) {
		RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType = 'MFC_Community_Object__c' AND DeveloperName = 'Bookmark'];
		String bookmarkRecordType = rt.Id;

		MFC_Community_Object__c currentBookmark = new MFC_Community_Object__c();
		currentBookmark.User__c = userId;
		currentBookmark.URL__c = url;
		currentBookmark.Label__c = label;
		currentBookmark.RecordTypeId = bookmarkRecordType;

		MFC_Community_Object__c[] existingBookmark = [SELECT Label__c FROM MFC_Community_Object__c WHERE User__c=:userId AND URL__c=:url AND RecordTypeId =:bookmarkRecordType LIMIT 1];

		if(existingBookmark != null && existingBookmark.size() > 0) throw new BookmarkException('You have already bookmarked this page as '+existingBookmark[0].Label__c+'.');

		insert currentBookmark;

		return new Bookmark(currentBookmark);
	}

	public String putBookmarkJSONResponse(Id userId, String url, String label) {
		Bookmark insertedBookmark;

		try {
			insertedBookmark = putBookmark(userId, url, label);
		} catch(Exception e) {
			return '{"success":false,"message":'+JSON.serialize(e.getMessage())+'}';
		}

		return '{"success":true,"bookmark":'+JSON.serialize(insertedBookmark)+'}';
	}
}