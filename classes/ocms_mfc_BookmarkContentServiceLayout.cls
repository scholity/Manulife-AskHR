global virtual with sharing class ocms_mfc_BookmarkContentServiceLayout extends cms.ContentTemplateController implements cms.ServiceInterface {
	
	private cms.ServiceAPI sAPI;
	
	global ocms_mfc_BookmarkContentServiceLayout(){}
	
	public ocms_mfc_BookmarkContentServiceLayout(cms.CreateContentController cc) { // This is for the editor
		super(cc);
	}

	public ocms_mfc_BookmarkContentServiceLayout(cms.GenerateContent gc) { // This is for the generator
		super(gc);
	}

	public String AddBookmarkName {
		get {
			String s = this.getProperty('AddBookmarkName');
			if (s == null && this.getRenderLanguage() == 'en_US') {
				s = 'Add Bookmark';
			}

			return s;
		} set;
	}

	public String RemoveBookmarkName {
		get {
			String s = this.getProperty('RemoveBookmarkName');
			if (s == null && this.getRenderLanguage() == 'en_US') {
				s = 'Remove Bookmark';
			}

			return s;
		} set;
	}

	public String NumberOfBookmarks {
		get {
			return String.isNotBlank(this.getProperty('NumberOfBookmarks')) ? this.getProperty('NumberOfBookmarks') : '10';
		} set;
	}

	public String BookmarkListTitle {
		get {
			String s = this.getProperty('BookmarkListTitle');
			if (s == null && this.getRenderLanguage() == 'en_US') {
				s = 'My Bookmarks';
			}

			return s;
		} set;
	}

	public String AllowBookmarkOrder {
		get {
			return String.isNotBlank(this.getProperty('AllowBookmarkOrder')) ? this.getProperty('AllowBookmarkOrder') : 'no';
		} set;
	}

	public String DefaultLabel {
		get {
			String s = this.getProperty('DefaultLabel');
			if (s == null && this.getRenderLanguage() == 'en_US') {
				s = 'Showing';
			}

			return s;
		} set;
	}

	public String ShowAllLabel {
		get {
			String s = this.getProperty('ShowAllLabel');
			if (s == null && this.getRenderLanguage() == 'en_US') {
				s = 'Show All';
			}

			return s;
		} set;
	}

	public String bookmarkRecordType {
		get {
		 if (bookmarkRecordType == null) {
		 	RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType = 'MFC_Community_Object__c' AND DeveloperName = 'Bookmark'];
			bookmarkRecordType = rt.Id;
		 } 
		 return bookmarkRecordType;
		}  set; 	
    }

    public List<SelectOption> getItems() {
        List<SelectOption> options = new List<SelectOption>(); 
        options.add(new SelectOption('yes', 'true')); 
        options.add(new SelectOption('no', 'false')); 
        return options; 
    }

    public System.Type getType() {
		return ocms_mfc_BookmarkContentServiceLayout.class;
	}

	public virtual override String getHTML() { // For generated markup
		return '';
	}

	public class Bookmark {
		public String id;
		public String url;
		public String label;
		public String publishDate;
		public String summaryText;

		public Bookmark(MFC_Community_Object__c b) {
			this.id = b.Id;
			this.url = b.URL__c;
			this.label = b.Label__c;
			this.publishDate = string.valueOfGmt(b.Original_Publish_Date__c);
			this.summaryText = String.isBlank(b.Summary_Text__c) ? '' : b.Summary_Text__c.escapeHtml4();
		}
	}

	public class BookmarkException extends Exception {}

	public String executeRequest(Map<String, String> p) {
		String action = p.get('action');
		Id currentUser = UserInfo.getUserId();

		String response = '{"success":false,"message":"Action not supported."}';

		if(currentUser == null) return response;

		if(action == 'get') {
			String pm = p.get('pm');
			response = getBookmarksJSONResponse(currentUser, pm);
		} else if(action == 'delete') {
			system.debug('\n *** delete bookmark id: ' + p.get('id') + '\n');
			String id = p.get('id');
			response = deleteBookmarkJSONResponse(currentUser, id);
		} else if(action == 'put') {
			String url = p.get('url');
			String label = p.get('label');
			String pm = p.get('pm');
			response = putBookmarkJSONResponse(currentUser, url, label, pm);
		}

		return response;
	}

	public List<Bookmark> getBookmarks(Id userId, String pm) {
		List<Bookmark> bookmarks = new List<Bookmark>();
		//system.debug('getBookmarks entered');
		//system.debug('uid: ' + userId );
		//system.debug('pm: ' + pm);
		//system.debug('bookmark RecordType : ' + bookmarkRecordType );
		List<MFC_Community_Object__c> bookmarkSObjects = [SELECT Id, URL__c, Label__c, Original_Publish_Date__c, Summary_Text__c FROM MFC_Community_Object__c WHERE User__c=:userId AND (PageMode__c=:pm OR PageMode__c=null) AND RecordTypeId =:bookmarkRecordType ORDER BY Original_Publish_Date__c DESC LIMIT 100];
		//system.debug('retrieved bookmarks: ' + bookmarkSObjects);
		for(MFC_Community_Object__c currentBookmark : bookmarkSObjects) {
			bookmarks.add(new Bookmark(currentBookmark));
		}
		
		return bookmarks;
	}

	public String getBookmarksJSONResponse(Id userId, String pm) {
		List<Bookmark> bookmarks = getBookmarks(userId, pm);
		System.debug('JSON : ' + JSON.serialize(bookmarks));
		return '{"success":true,"bookmarks":'+JSON.serialize(bookmarks)+'}';
	}

	public void deleteBookmark(Id userId, String bookmarkId) {
		system.debug('\n *** calling deleteBookmark, userid: ' + userId + ' bookmarkid: ' + bookmarkId + '\n');
		MFC_Community_Object__c currentBookmark = [SELECT Id FROM MFC_Community_Object__c WHERE User__c=:userId AND Id=:bookmarkId AND RecordTypeId =:bookmarkRecordType];
		system.debug('\n *** currentBookmark : ' +currentBookmark + '\n');
		if(currentBookmark == null) throw new BookmarkException('Bookmark not found. It may have already been deleted.');

		delete currentBookmark;
	}

	public String deleteBookmarkJSONResponse(Id userId, String bookmarkId) {
		try {
			system.debug('\n *** calling deleteBookmarkJSONResponse, userid: ' + userId + ' bookmarkid: ' + bookmarkId + '\n');
			deleteBookmark(userId, bookmarkId);
		} catch(Exception e) {
			system.debug('\n *** exception calling deleteBookmarkJSONResposne:\n');
			return '{"success":false,"message":'+JSON.serialize(e.getMessage())+'}';
		}

		return '{"success":true}';
	}

	public Bookmark putBookmark(Id userId, String url, String label, String pm) {
		MFC_Community_Object__c currentBookmark = new MFC_Community_Object__c();
		currentBookmark.User__c = userId;
		currentBookmark.URL__c = url;
		currentBookmark.Label__c = label;
		currentBookmark.PageMode__c = pm;
		currentBookmark.RecordTypeId = bookmarkRecordType;
		currentBookmark.Original_Publish_Date__c = null;

		cms__Content__c contentToBookmark = null;

		//retrieve content_id from URL if present (Article Detail Page).
		//system.debug ('urlToBookmark: ' + url);
		
		PageReference pageToBookmark = new PageReference(url);
		String idToBookmark = pageToBookmark.getParameters().get('content_id');

		//system.debug ('idToBookmark: ' + idToBookmark);

		//***  The following code utilises ServiceAPI and direct object calls.  This should be refactored to use OrchestraCMS Rendering API calls  as soon as practical.
		if (!String.isEmpty(idToBookmark)){
			List<cms__Content__c> contents = new List<cms__Content__c>();
			Map<Id,List<cms__Attribute__c>> contentMap = new Map<Id,List<cms__Attribute__c>>();
			sAPI = getServiceAPI();	
			
			try {
				contentToBookmark = sAPI.getLatestContentVersion2( idToBookmark,  true);
				//in case the supplied ID is not the current version, use the id of the returned (current) version from this point on.
				idToBookmark = contentToBookmark.Id;
				contents.add(contentToBookmark);
				System.debug ('content: ' + contentToBookmark);
				currentBookmark.Original_Publish_Date__c = contentToBookmark.cms__Original_Published_Start_Date__c;
				//System.debug('originalPublishDate from content: ' + currentBookmark.Original_Publish_Date__c);
			}  catch (Exception e) {
		                     throw new BookmarkException('Error Retrieving Content from SerivceAPI : ' + e.getMessage());
		            }
			try {
				String attributeLang = sAPI.getRenderLanguage();
				String defaultSummary;
				System.debug('rendering for content: ' + idToBookmark);
				System.debug('render lang: ' + attributeLang);
				List<cms__Attribute__c> summaryAttributes = [SELECT Id, cms__Value__c, cms__Language__r.cms__Language_Code__c FROM cms__Attribute__c WHERE cms__Simple_Name__c = 'summary' AND cms__Content__c =: idToBookmark];
				if (summaryAttributes.size() >0 ) {
					for (cms__Attribute__c att : summaryAttributes){
						System.debug('attribue render lang: ' + att.cms__Language__r.cms__Language_Code__c);
						if (att.cms__Language__r.cms__Language_Code__c == attributeLang){
							//found matcing summary in render lang
							System.debug('summary in render lang found');
							currentBookmark.Summary_Text__c = att.cms__Value__c;
						} else {
							if (att.cms__Language__r.cms__Language_Code__c == 'en_US'){
								//assuming english is defualt lanugage 
								defaultSummary = att.cms__Value__c;
							}
						}
					}
					//if the assigned translated summary is empty, then assign the english summary if available, otherwise, set to null.
					if (String.isBlank(currentBookmark.Summary_Text__c)){
						System.debug('summary in render lang blank - assigning english version if available');
						system.debug('defaultSummary: ' + defaultSummary);
						system.debug('isEmpty return: ' + String.isEmpty(defaultSummary));
						if (!String.isBlank(defaultSummary)){
							currentBookmark.Summary_Text__c =  defaultSummary;
						}
					}
				}
			}  catch (Exception e) {
		                     throw new BookmarkException('Error Retrieving Content from SerivceAPI call#2 : ' + e.getMessage());
		            }		            
		}

		if (currentBookmark.Original_Publish_Date__c == null){
			currentBookmark.Original_Publish_Date__c = datetime.now();
		}

		MFC_Community_Object__c[] existingBookmark = [SELECT Label__c FROM MFC_Community_Object__c WHERE User__c=:userId AND URL__c=:url AND (PageMode__c=:pm OR PageMode__c=null) AND RecordTypeId =:bookmarkRecordType LIMIT 1];

		if(existingBookmark != null && existingBookmark.size() > 0) throw new BookmarkException('You have already bookmarked this page as '+existingBookmark[0].Label__c+'.');

		insert currentBookmark;

		return new Bookmark(currentBookmark);
	}

	public String putBookmarkJSONResponse(Id userId, String url, String label, String pm) {
		Bookmark insertedBookmark;

		try {
			insertedBookmark = putBookmark(userId, url, label, pm);
		} catch(Exception e) {
			return '{"success":false,"message":'+JSON.serialize(e.getMessage())+'}';
		}

		return '{"success":true,"bookmark":'+JSON.serialize(insertedBookmark)+'}';
	}

	global String getBookmarkBarHTML() {
		String strHTML = '';
		strHTML = '<div class="bookmarks bookmarks-currentPage bookmarks-loading">';
		strHTML += '<a href="#" class="bookmarks-currentPage-save">' + AddBookmarkName + '</a>';
		strHTML += '<a href="#" class="bookmarks-currentPage-delete">' + RemoveBookmarkName + '</a>';
		strHTML += '<div class="bookmarks-loader"></div>';
		strHTML += '</div>';
		strHTML += '<script>';
		strHTML += '$(document).ready(function() {';
		strHTML += '    MFC.fSetupBookmarkPageControl();';
		strHTML += '})';
		strHTML += '</script>';
		return strHTML;

	}
}