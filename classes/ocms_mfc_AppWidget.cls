global with sharing class ocms_mfc_AppWidget extends ocms_mfc_App {
	global override String getHTML() {
		List<String> mostUsedApplications = getMostUsedApplications(UserInfo.getUserId(), false);

		String appWidgetHTML = '';

		appWidgetHTML += '<div class="widget apps-widget">';
		appWidgetHTML +=    '<div class="inner">';
		appWidgetHTML +=        '<h3 class="appWidgetTitle">' + appWidgetTitle + '</h3>';
		appWidgetHTML +=        '<div class="widget-content">';
		appWidgetHTML +=            '<div class="v-align">';
		appWidgetHTML +=                '<div class="inner">';
		                    
		for (String contentGeneration : mostUsedApplications) {
		    if (contentGeneration != null) {
		        contentGeneration = contentGeneration.replace('{mobileSize}', 'mob-size-s');
		        contentGeneration = contentGeneration.replace('{tabletSize}', 'tab-size-s');
		        contentGeneration = contentGeneration.replace('{desktopSize}', 'dsk-size-s');
		        
		        appWidgetHTML += contentGeneration;
		    }
		}

		appWidgetHTML +=                '</div>';
		appWidgetHTML +=            '</div>';
		appWidgetHTML +=        '</div>';
		appWidgetHTML +=    '</div>';
		appWidgetHTML += '</div>';

		return appWidgetHTML;
	}
}