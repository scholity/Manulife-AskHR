global with sharing virtual class ocms_mfc_Notification extends ocms_ps_Content {
	global ocms_mfc_Notification(cms.CreateContentController cc) {
		super(cc);
	}

	global ocms_mfc_Notification(cms.GenerateContent gs) {
		super(gs); 
	}

	global ocms_mfc_Notification(){
	}
	
	public String title {
		get {
			return this.getProperty('title');
		}
		set;
	}
	
	public String message {
		get {
			return this.getProperty('message');
		}
		set;
	}
	
	public String altText {
		get {
			return this.getProperty('altText');
		}
		set;
	}
	
	public String image {
		get {
			return this.getProperty('image');
		}
		set;
	}
	
	public String link {
		get {
			return this.getProperty('link');
		}
		set;
	}
	
	public cms.Link TargetPageObj {
		get {
			return new cms.Link(this.link, this.pm, this.sn);
		}	
	}
	public String versionOriginId {
		get {
			if (content != null) {
				versionOriginId = content.Id;
				if (content.cms__Version_Origin__c != null) {
			       	versionOriginId = content.cms__Version_Origin__c;
		       	}
			}
	       	 
	       	return versionOriginId;
		} set;
	}

    global virtual override String getHTML() {
    	validateSitePreferencesCache();
    	String cliId = '';
        if (this.content_layout_instance != null) {
            cliId = content_layout_instance.Id;
        }
    	
    	String mTitle = title == null ? '' : title;
    	String mMessage = message == null ? '' : message;
    	//Map<String, String> prefs = ocms_mfc_SitePreferences.getSitePreferences();
    	String html = '';
        html += '<div class="notification" data-coid="' + versionOriginId + '">';
		html += 	'<div class="notification-header">';
		html += 		'<div class="img-wrapper">';
		html += 			'<img alt="' + (this.altText == null ? '' : this.altText) + '" data-src="' + getSiteURLForMedia(this.image) + '" />';
		html += 		'</div>';
		html += 		'<div class="title-wrapper">';
		html += 			'<div class="title">';
		html += 				'<h3>' + mTitle + '</h3>';
		html += 			'</div>';
		html += 		'</div>';
		html += 	'</div>';
		html += 	'<div class="notification-body">';	
        html += 		'<p>' + mMessage + '</p>';

        if (this.TargetPageObj.targetPage != null && this.TargetPageObj.targetPage != '') {
        	Map<String, String> sitePreferences = ocms_mfc_SitePreferences.getSitePreferences(pm, getServiceAPI().getRenderLanguage());
        	String viewDetailsLabel = 'View Details';

        	if (sitePreferences.containsKey('uiLabelViewNotificationDetails') && String.isNotEmpty(sitePreferences.get('uiLabelViewNotificationDetails'))) {
        		viewDetailsLabel = sitePreferences.get('uiLabelViewNotificationDetails');
        	}

            html +=     '<a href="' + this.TargetPageObj.targetPage + '">' + viewDetailsLabel + '</a>';
        }

        
        html += 	'</div>';
        html += '</div>';

        return html;
    }	// getHTML
}