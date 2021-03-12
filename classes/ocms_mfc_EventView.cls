global virtual without sharing class ocms_mfc_EventView extends cms.ContentTemplateController implements cms.ServiceInterface {

	global ocms_mfc_EventView () {}

	global ocms_mfc_EventView (cms.GenerateContent gc) {
		super(gc);
	}

	global ocms_mfc_EventView (cms.CreateContentController cc) {
		super(cc);
	}

	public System.Type getType(){
		return ocms_mfc_EventView.class;
	}

	global String executeRequest (Map <String, String> request) {
		return '';
	}

	global virtual override String getHTML() {
		String html = '';
		try {
			String recurrenceSuffix = '';
			String buttonText = 'RSVP To Event';
			PageReference page = ApexPages.currentPage ();
			System.debug('in event view, the current page is ' + page);
			Id eventId = page.getParameters ().get ('eventId');
			Map <Id, String> attachments = new Map <Id, String> ();
			Event evt = [SELECT e.Subject, e.StartDateTime, e.Location, e.EndDateTime, e.DurationInMinutes, e.Description, e.RelatedLink__c, e.RecurrenceActivityId,
			             			 e.ContactName__c, e.ContactTitle__c, e.ContactPhone__c, e.ContactEmail__c,
									 (select name from attachments)
									 From Event e WHERE e.id = :eventId];
			if (evt.RecurrenceActivityId != null) {
				recurrenceSuffix = ' (recurring)';
				buttonText = 'RSVP To Series';
				Event parentEvent = [SELECT Id, (select name from attachments) From Event e WHERE e.Id = :evt.RecurrenceActivityId];
				for (Attachment attach : parentEvent.Attachments) {
					attachments.put(attach.Id, attach.Name);
				}
			}

			for (Attachment attach : evt.Attachments) {
				attachments.put(attach.Id, attach.Name);
			}

			System.debug(ApexPages.currentPage().getHeaders());
			System.debug('page origin is ' + ApexPages.currentPage().getHeaders().get('origin'));
			System.debug('salesforce instance is ' + ApexPages.currentPage().getHeaders().get('X-Salesforce-Forwarded-To'));

			/* this is the new event markup
			<div class="article-content event-detail-view layout-sidebar"><div class="inner"><div id="article-header"><h1>Manulife Toastmasters Information Session</h1>
			<div class="global-flag"><a href="#flag-content" class="modal-flag cboxElement"></a><div style="display: none;"><div id="flag-content"><h3>Report an error on this page</h3>
			<textarea placeholder="Type your message here..."></textarea><a href="#">Submit</a></div></div></div></div><div class="article-body"><div class="event-type event-date">
			<div><p>Tuesday November 8, <nobr>12:15pm - 1:15pm EST</nobr></p></div></div><div class="event-type event-location"><div><p>200 Bloor Street East, Toronto, ON</p>
			</div></div><div class="event-type event-calendar"><div><p><a href="#">Corporate Event Calendar</a></p></div></div><div class="event-type event-description">
			<div><p>Etiam porta sem malesuada magna mollis euismod. Cras mattis consectetur purus sit amet fermentum. Nulla vitae elit libero, a pharetra augue. Cras justo odio, dapibu</p>
			</div></div><div class="event-type event-link"><div><p><a href="#">Manulife Toastmaster Association</a></p></div></div><div class="event-type event-download">
			<div><p><a href="#">Introduction.pptx</a></p></div></div></div><div class="article-sidebar"><div id="article-author"><div class="author-thumb">
			<img src="../img/drawer-avatar.png" alt=" "></div><div class="author-info"><a class="author-name" href="#">Abigail Hewitt</a><p class="author-title">VP, Communications</p>
			</div></div><div class="article-widget article-contact"><p class="title">Contact Information</p><div class="contact-phone">ext. 824853</div>
			<div class="contact-email"><a href="example@mfc.com">example@mfc.com</a></div></div><div class="clear"></div></div><div class="clear"></div></div></div>*/

			html += '<div class="article-content event-detail-view layout-sidebar">';
			html += 	'<div class="inner">';
			html += 		'<div id="article-header">';
			html += 			'<h1>' + evt.Subject + '</h1>';
			html += 			'<div class="global-flag">';
			html += 				'<a href="mailto: ' + sitePreferences.get('reportButtonEmail') + '?Subject=' + evt.Subject + ' (' + evt.Id + ') Detail Page"></a>';
			//html += 				'<a href="#flag-content" class="modal-flag cboxElement"></a>'; //commented out because it's unclear what this is
			//html +=					'<div style="display:none"><div id="flag-content"><a href="mailto: ' + sitePreferences.get('reportButtonEmail') + '">Submit</a></div></div>';
			html += 			'</div>'; //global-flag
			html += 		'</div>'; //article-header
			html += 		'<div class="article-body">';
			html += 			'<div class="event-type event-date">';
			html += 				'<div>';
			html += 					'<p>' + ManulifeHelper.formatTheDate(evt.StartDateTime,getServiceAPI().getRenderLanguage()) + ', <nobr>' + getTime(evt.StartDateTime.time()) + ' - ' + getTime(evt.EndDateTime.time()) + '</nobr></p>';
			html += 				'</div>';
			html += 			'</div>'; //event-type event-date
			if (evt.Location != null) {
				html += 			'<div class="event-type event-location">';
				html += 				'<div>';
				html += 					'<p>' + evt.Location + '</p>';
				html += 				'</div>';
				html += 			'</div>'; //event-type event-location
			}
			/*html += 			'<div class="event-type event-calendar">';
			html += 				'<div>';
			html += 					'<p><a href="#">Corporate Event Calendar</a></p>';
			html += 				'</div>';
			html += 			'</div>';*/ //the event calendar link is commented out because it's not clear what this is
			if (evt.Description != null) {
				html += 			'<div class="event-type event-description">';
				html += 				'<div>';
				html += 					'<p>' + evt.Description + '</p>';
				html += 				'</div>';
				html += 			'</div>'; //event-type event-description
			}
			if (evt.RelatedLink__c != null) {
				html += 		'<div class="event-type event-link">';
				html += 			'<div>';
				if (evt.RelatedLink__c.length() > 3 && evt.RelatedLink__c.substring(0,4) == 'http')
					html += 				'<p>' + '<a href="' + evt.RelatedLink__c + '">' + evt.RelatedLink__c + '</a></p>';
				else
					html += 				'<p>' + '<a href="http://' + evt.RelatedLink__c + '">' + evt.RelatedLink__c + '</a></p>';
				html += 			'</div>';
				html += 		'</div>'; //event-type event-link
			}
			for (Id attach : attachments.keySet()) {
				html += 		'<div class="event-type event-download">';
				html += 			'<div>';
				html += 				'<p><a href="' + ocms_mfc_Utility.protocolAndHost + '/servlet/servlet.FileDownload?file=' + attach + '">' + attachments.get(attach) + '</a></p>';
				html += 			'</div>';
				html += 		'</div>'; //event-type event-download
			}
			//html += '<input type="button" class="btnRsvp" value="' + buttonText + '" style="background-color:powderblue; cursor:pointer;"/><br/><br/>'; no more rsvp button for now
			html += 		'</div>'; //article-body
			html += 		'<div class="article-sidebar">';
			html += 			'<div id="article-author">';
			/*html += 				'<div class="author-thumb">';
			html += 					'<img src="blahblah" alt="" >';
			html += 				'</div>';*/ //author-thumb is commented out because there's no way to do it
			html += 				'<div class="author-info">';
			html += evt.ContactName__c != null ? '<p class="author-name">' + evt.ContactName__c + '</p>' : '<p class="author-name"></p>';
			html += evt.ContactTitle__c != null ? '<p class="author-title">' + evt.ContactTitle__c + '</p>' : '<p class="author-title"></p>';
			html += 				'</div>'; //author-info
			html += 			'</div>'; //article-author
			html += 		'<div class="article-widget article-contact">';
			html += 			'<p class="title">' + sitePreferences.get('uiLabelArtContactInformation') + '</p>';
			html += evt.ContactPhone__c != null ? '<div class="contact-phone">' + evt.ContactPhone__c + '</div>' : '<div class="contact-phone"></div>';
			html += evt.ContactEmail__c != null ? '<div class="contact-email">' + evt.ContactEmail__c + '</div>' : '<div class="contact-email"></div>';
			html += 		'</div>'; //article-widget article-contact
			html += 		'<div class="clear"></div>';
			html += 		'</div>'; //article-sidebar
			html += 		'<div class="clear"></div>';
			html += 	'</div>'; //inner
			html += '</div>'; //article-content event-detail-view layout-sidebar
			/*html += '<p><strong>' + evt.Subject + recurrenceSuffix + '</strong></p><br/>';
			html += '<p>' + evt.Location + '</p></br/>';
			html += '<p>' + evt.StartDateTime.format('EEEE MMMM dd, YYYY') + '</p><br/>';
			html += '<p>' + evt.StartDateTime.format('h:mm a') + ' - ' + evt.EndDateTime.format('h:mm a') + '</p><br/><br/>';
			html += '<p>' + evt.Description + '</p><br/></br/>';
			html += '<p>' + evt.RelatedLink__c + '</p><br/><br/>';
			html += '<input type="button" class="btnRsvp" value="' + buttonText + '" style="background-color:powderblue; cursor:pointer;"/><br/><br/>';
			html += '<div class="message"></div>';*/

			/* the below snippet was for the rsvp button that is no longer part of the scope
			 * keeping the code around in case it comes back in scope someday
			 */

			/*html += '<script>';
			html += '$(".btnRsvp").bind("click", (function () { \n';
			html += '\t $.orchestracmsRestProxy.doAjaxServiceRequest("ocms_mfc_EventService", {action: "rsvp", ';
			html += 'event: "' + evt.Id + '"';
			html += '}, \n';
			html += '\t\t function callBack(status, response) {\n ';
			html += '\t\t\t $(\'.message\').html(response.html); \n';
			html += '\t\t } \n';
			html += '\t ); \n';
			html += '}));';
			html += '//# sourceURL=tempRsvp.js';
			html += '</script>';*/
		}
		catch (QueryException ex) {
			return '<p style="font-size: 22px">We could not find any information for this event!</p>';
		}
		catch (Exception ex) {
			return '<p style="font-size: 22px">A problem has occurred. Please contact your system administrator for further assistance.</p>';
		}

		return html;
	}

    public Map<String, String> sitePreferences {
        get {
            if (sitePreferences == null) {
                sitePreferences = ocms_mfc_SitePreferences.getSitePreferences(pm, getServiceAPI().getRenderLanguage());
            }

            return sitePreferences;
        } set;
    }


	private String getTime (Time t) {
		String timeFormatted = '';
		String suffix;

		if (t.hour() == 0) {
			timeFormatted += '12';
			suffix = 'am';
		}
		else if (t.hour() > 0 && t.hour() < 10) {
			timeFormatted += '0' + t.hour();
			suffix = 'am';
		}
		else if (t.hour() >= 10 && t.hour() < 12) {
			timeFormatted += t.hour();
			suffix = 'am';
		}
		else if (t.hour() == 12) {
			timeFormatted += t.hour();
			suffix = 'pm';
		}
		else { //1pm to 11pm
			Integer displayedHour = t.hour() - 12;
			timeFormatted += displayedHour;
			suffix = 'pm';
		}

		if (t.minute() < 10) {
			timeFormatted += ':0' + t.minute();
		}
		else { //greater than 10
			timeFormatted += ':' + t.minute();
		}

		return timeFormatted + suffix;
	}
}