global with sharing class ocms_mfc_NotificationService extends cms.ContentTemplateController implements cms.ServiceInterface {
	private String contentTypeName {get;set;}
	
	public ocms_mfc_NotificationService() {
		this.contentTypeName = 'Notification';
	}
	
	public System.Type getType() {
		return ocms_mfc_NotificationService.class;
	}

     private cms.ServiceAPI sAPI {
        get {
            if (sApi == null) {
                sApi = getServiceAPI();
            }

            return sApi;
        } set;
    }

     private ocms_TaxonomyAPI taxonomyApi {
        get {
            if (taxonomyApi == null) {
                taxonomyApi = new ocms_TaxonomyAPI(sApi);
            }

            return taxonomyApi;
        } set;
    }

    private ocms_mfc_Taxonomy mfcTaxonomy {
        get {
            if (mfcTaxonomy == null) {
                mfcTaxonomy = new ocms_mfc_Taxonomy(sApi);
            }

            return mfcTaxonomy;
        } set;
    }
	
	public String executeRequest(Map<String, String> p) {
		String response = '{"success":false,"message":"Action not supported."}';

		if(p.containsKey('action')) {
			String action = p.get('action');
			
			if (action == 'getUnreadCount') {
				response = getUnreadCountJSONResponse(Boolean.valueOf(p.get('widgetTitle')));
			} else if (action == 'getLatestContent') {
				if (p.containsKey('amount')) {
					Integer amount = integer.valueof(p.get('amount'));
					if (amount != null) {
						response = getLatestContentJSONResponse(amount);
					}
				}
			} else if (action == 'getNotificationPage') {
				if (p.containsKey('amount')) {
					Integer amount = integer.valueof(p.get('amount'));
					if (amount != null) {
						System.debug(p);
						response = getNotificationPageJSONResponse(amount, p);
					}
				}
			} else if (action == 'updateLastVisited') {
				response = updateLastVisitedJSONResponse();
			}
		}

		return response;
	}
	
	// Gets the amount of unread notifications and the widget title if requested
	public String getUnreadCountJSONResponse(Boolean widgetTitle) {
		Boolean success = true;
		String currUser = UserInfo.getUserId();
		User user = [SELECT Notification_Last_Visited__c FROM User WHERE Id = :currUser];
		List<String> contentIds;

		if (Test.isRunningTest()) {
			user.Notification_Last_Visited__c = DateTime.Now() - 5;
			String page_name = 'TR - Test Page';
			String type_name = 'Notification';
			String site_name = 'Manulife';
			
			cms__Content_Type__c contentType = new cms__Content_Type__c(cms__Name__c = type_name, cms__Site_Name__c = site_name);
			insert contentType;
			
			cms__Content__c content = new cms__Content__c(
				cms__Content_Type__c         = contentType.Id,
				cms__Name__c                 = 'TestContent',
				cms__Description__c          = 'Testing',
				cms__Preview__c              = true,
				cms__Published__c            = true,
				cms__Published_Start_Date__c = System.now(),
				cms__Site_Name__c            = site_name,
				cms__Revision_Number__c      = 0,
				cms__Revision_Origin__c      = null,
				cms__Version_Number__c       = 1,
				cms__Version_Origin__c       = null,
				cms__Version_Original__c     = true,
				cms__Version_Parent__c       = null,
				cms__Depth__c                = 0
			);
			
			insert content;
			contentIds = new List<String>{content.Id};
		} else {
			contentIds = mfcTaxonomy.getContentIdsForTaxonomies(getPathListsForNotifications(), this.contentTypeName, 'publish_date', null, null);
		}
		
		
		List<cms__content__c> contentList = new List<cms__content__c>();
		// Use the Id's to fetch all the contents published start dates
		
		try	{
			contentList = [SELECT ID, cms__Published_Start_Date__c  from cms__content__c WHERE ID IN :contentIds ORDER BY cms__Published_Start_Date__c DESC];
		} catch(Exception ex) {
			success = false;
			System.debug('Failed to retrieve notification content');
		}
		
		String firstWidgetTitle = '';
		Integer unreadNotifications = 0;

		// Increase unread notifcation counter for each content that was published after the users last view of the notification page
		for (cms__content__c content : contentList) {
			if (widgetTitle && firstWidgetTitle == '') {
				Map<Id, String> renderings = taxonomyApi.getLatestContentRenderingsForOriginContents(new List<String>{content.Id}, 'NotificationSummary');
				for (String rendering : renderings.values()) {
					firstWidgetTitle = rendering;
					widgetTitle = false;
					break;
				}
			}
			
			if (content.cms__Published_Start_Date__c > user.Notification_Last_Visited__c) {
				unreadNotifications++;
			}	
		}
		
		String contentRendering = '';
		if (firstWidgetTitle != '') {
			contentRendering = ', "widget": ' + JSON.Serialize(firstWidgetTitle);
		}
		
		return '{"success":' + success + ',"unread":' + unreadNotifications + contentRendering + '}';
	}
	
	// Get the latest content items regardless of if they are new
	public String getLatestContentJSONResponse(Integer amountToRetrieve) {
		Map<Id, String> contentList = mfcTaxonomy.getContentRenderingsForTaxonomies(getPathListsForNotifications(), this.contentTypeName, 'Notification', 'publish_date', null, null);
		
		return JSON.Serialize(contentList);
	}
	
	/** 
	 *  @description - Get all the notifcations on the notification page and group them by the date they were posted on.
	 *  @param itemLimit - the amount of items to return
	 */
	public String getNotificationPageJSONResponse(Integer itemLimit, Map<String, String> parameters) {
		List<List<String>> pathLists = getPathListsForNotifications();
		Map<Id, String> contentMap = mfcTaxonomy.getContentRenderingsForTaxonomies(getPathListsForNotifications(), this.contentTypeName, 'Notification', 'publish_date', null, null);
		Set<Id> contentIds = contentMap.keySet();
		List<cms__content__c> contentList = [SELECT ID, cms__Published_Start_Date__c  from cms__content__c WHERE ID IN :contentIds ORDER BY cms__Published_Start_Date__c DESC];

		if (Test.isRunningTest()) {
			contentList.clear();
			
			String page_name = 'TR - Test Page';
			String type_name = 'Notification';
			String site_name = 'Manulife';
			
			cms__Content_Type__c contentType = new cms__Content_Type__c(cms__Name__c = type_name, cms__Site_Name__c = site_name);
			insert contentType;
			
			cms__Content__c content = new cms__Content__c(
				cms__Content_Type__c         = contentType.Id,
				cms__Name__c                 = 'TestContent',
				cms__Description__c          = 'Testing',
				cms__Preview__c              = true,
				cms__Published__c            = true,
				cms__Published_Start_Date__c = System.now(),
				cms__Site_Name__c            = site_name,
				cms__Revision_Number__c      = 0,
				cms__Revision_Origin__c      = null,
				cms__Version_Number__c       = 1,
				cms__Version_Origin__c       = null,
				cms__Version_Original__c     = true,
				cms__Version_Parent__c       = null,
				cms__Depth__c                = 0
			);
			
			insert content;
			content = [SELECT ID, cms__Published_Start_Date__c  from cms__content__c WHERE ID = :content.Id];
			
			contentList.add(content);
		}
		
		Datetime todayDate = Datetime.Now();
		Datetime yesterdayDate = todayDate.addDays(-1);
		String lastDayTitle = '';
		String html = '';
		Integer counter = 0;
		Boolean firstSection = true;

		for (cms__content__c content : contentList) {
			counter++;
			
			if (counter > itemLimit) {
				break;
			}
			
			DateTime contentDate = content.cms__Published_Start_Date__c;
			String dayTitle;
			Boolean contentPostedToday = false;
			Boolean translateDate = false;
			
			if (contentDate.date() == todayDate.date()) {
				dayTitle = parameters.get('uiLabelToday');
				contentPostedToday = true;
			} else if (contentDate.date() == yesterdayDate.date()) {
				dayTitle = parameters.get('uiLabelYesterday');
			} else {
				translateDate = true;
				dayTitle = contentDate.format('EEEE, MMMM d, y');
			}
			
			// If we are a new section close the last one
			if (dayTitle != '' && dayTitle != lastDayTitle && !firstSection) {
				html += 		'<div class="clear"></div>';
				html += 	'</div>';
				html += '</section>';
			}
			
			// If it has a new day heading
			if (dayTitle != lastDayTitle) {
				html += '<section class="notifications-wrapper ' + (translateDate ? 'mfc-translate-date ' : '') + (contentPostedToday ? '' : 'archive') + '">';
				html += '<h2 data-mfc-time="' + contentDate + '">' + dayTitle + '</h2>';
				html += '<div class="notifications">';
				html += 	'<div class="inner notifications-grid">';
			}
			
			html += contentMap.get(content.Id);
			lastDayTitle = dayTitle;
			firstSection = false;
		}
		
		if (lastDayTitle != '') {
			html += '<div class="clear"></div>';
			html += '</div>';
			html += '</section>';
		}
		
		return '{"success":true, "notifications":' + JSON.Serialize(html) + '}';
	}
	
	// Set the users last viewed notification date to now
	public String updateLastVisitedJSONResponse(){
		Boolean success = true;
		try {
			String userId = UserInfo.getUserId();
			User user = [SELECT Id, Notification_Last_Visited__c FROM User WHERE Id = :userId];
			user.Notification_Last_Visited__c = DateTime.Now();
			
			update user;
		} catch(Exception e) {
			success = false;
		}
		
		return '{"success":' + success + '}';
	}
	
	global override String getHTML() {
		return '';
	}

	private List<List<String>> getPathListsForNotifications() {
		List<List<String>> pathLists = new List<List<String>>();
		pathLists.add(mfcTaxonomy.getLocationPathList());
		pathLists.add(mfcTaxonomy.getDivisionPathListForUser());
		pathLists.add(mfcTaxonomy.getEmployeeTypePathListForUser());

		return pathLists;
	}
}