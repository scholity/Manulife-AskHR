global with sharing class ocms_mfc_NotificationWidget extends ocms_mfc_Notification {
	global ocms_mfc_NotificationWidget(cms.CreateContentController cc) {
		super(cc);
	}
	
	global ocms_mfc_NotificationWidget(cms.GenerateContent gs) {
		super(gs); 
	}

	global ocms_mfc_NotificationWidget(){
	}
	
	public String heading {
		get {
			return this.getProperty('heading');
		}
		set;
	}
	
	public String countText {
		get {
			return this.getProperty('countText');
		}
		set;
	}
	
	global override String getHTML() {
		String cliId = '';
		if (this.content_layout_instance != null) {
			cliId = content_layout_instance.Id;
		}
		
		String widgetCountText = countText;
		widgetCountText = widgetCountText.replace('[count]', '<span id="widget-notifications-count"></span>');
		
		String html = '';
		html += '<div class="widget notifications-widget" data-coid="' + versionOriginId + '">';
		html += 	'<div class="inner">';
		html += 		'<h3>' + heading + '</h3>';
		html += 		'<div class="widget-content">';
		html += 			'<div class="v-align">';
		html += 				'<div class="inner">';
		html +=						'<span></span>'; 
		html += 				'</div>';	
		html += 			'</div>';
		html += 		'</div>';
		html +=			'<footer class="widget-footer">';
		html +=				'<strong>';
		html +=					widgetCountText;
		html +=				'</strong>';
		html +=			'</footer>';
		html += 	'</div>';
		html += '</div>';
	
		return html;
	}
}