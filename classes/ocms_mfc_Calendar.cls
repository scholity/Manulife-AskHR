global virtual without sharing class ocms_mfc_Calendar extends cms.ContentTemplateController implements cms.ServiceInterface {

	global ocms_mfc_Calendar () {}

	global ocms_mfc_Calendar (cms.GenerateContent gc) {
		super(gc);
	}

	global ocms_mfc_Calendar (cms.CreateContentController cc) {
		super(cc);
	}

	public System.Type getType(){
		return ocms_mfc_Calendar.class;
	}

	global String executeRequest (Map <String, String> request) {
		return '';
	}

	global virtual override String getHTML() {
		return '';
	}

	public String getListHtml () {
		Map <Date, List <Event>> eventMap = getCurrentEvents ();
		System.debug('events map ' + eventMap);
		List <Date> eventDates = new List <Date> ();
		eventDates.addAll(eventMap.keySet());
		eventDates.sort();

		String html = '<div class="top-bg"><a href="' + sitePreferences.get('calendarPage') + '"><h2>' + eventsText + '<span class="mfc-date">19</span></h2></a></div>'; //top-bg
		html += '<div class="events-block"><div class="inner">';

		for (Date eventDate : eventDates) {
			List <Event> events = eventMap.get(eventDate);
			html += '<div class="day';

			if (eventDate == eventDates[0])
				html += ' selected';

			html += '">';
			html += '<div class="title">';

			if (eventDate == eventDates[0]) {
				html += '<strong>' + todayText + '</strong> - ';
			}

			html +=	'<span class="mfc-current-event-date" data-mfc-day-time="' + eventDate + '"></span>';//getMonth(eventDate.month()) + ' ' + eventDate.day() + ', ' + eventDate.year() + '
			html += '</div><div class="content-outer"><div class="content"><div class="inner">';

			for (Event evt : events) {
				html += '<div class="event">';
				html += '<div class="time" data-time="' + evt.StartDateTime.time() + '"></div>'; //<sub>est</sub> can't appear - no way to get timezone in that short value string
				html += '<div class="details">';

				if (sitePreferences.get('eventPage').contains('?'))
					html += '<strong>' + '<a href="' + sitePreferences.get('eventPage') + '&eventId=' + evt.Id + '">' + evt.Subject;
				else
					html += '<strong>' + '<a href="' + sitePreferences.get('eventPage') + '?eventId=' + evt.Id + '">' + evt.Subject;
				html += evt.RecurrenceActivityId == null ? '' : '&nbsp;<i class="fa fa-refresh"></i>';
				html += '</a></strong>'; //(1hr) or (30mins) is very difficult to do here, but let's give it a shot on the next line
				html += getStringifiedDuration (evt.DurationInMinutes) != '' ? '&nbsp;&nbsp;(' + getStringifiedDuration (evt.DurationInMinutes) + ')' : '';
				html += evt.Location != null ? '<sub>' + evt.Location + '</sub>' : '<sub></sub>';
				html += '</div></div>'; //details and event
			}

			html += '</div></div>'; //inner and content
			html += '<a href="#" class="day-arrow arrow-up">Up</a>';
			html += '<a href="#" class="day-arrow arrow-dn">Down</a>';
			html += '</div></div>'; //content-outer and day
		}

		html += '</div>'; //inner
		html += '<div class="top-underlap"></div>';
		html += '<div class="top-overlap">';
		html += '<div class="top-overlap-1"></div><div class="top-overlap-2"></div><div class="top-overlap-3"></div><div class="top-overlap-4"></div>';
		html += '</div>'; //top-overlap
		html += '<a href="#" class="arrow arrow-prev">Previous</a><a href="#" class="arrow arrow-next">Next</a>';
		html += '</div>'; //events-block

		html += '<script>';
	    html += '$(document).ready(function(){';
		html +=		'MFC.events = {};';
		html +=		'MFC.fLoadEventList();';
    	html += '})';
		html += '</script>';

		return html;
	}

	public String getFullHtml () {
		List <Event> events = getAllEvents ();
		System.debug(events);
		String eventsAsJson = '';
		JSONGenerator gen = JSON.createGenerator (true);
		String urlAppend;
		String detailPageUrl;
        // FullCalendar localization .js files where the language code is longer than 2 characters are named in the format
        // aa-bb.  We need to convert the longer SF language codes to this format.  Example change 'zh_TW' to 'zh-tw'.
		String renderLang = getServiceAPI().getRenderLanguage().replace('_','-').toLowerCase();
        // Salesforce uses 'in' as Indonesian language code; ISO is 'id' or 'in' and lang js files use id.  Check for 'in'
        // and change to 'id'
        renderLang = renderLang == 'in' ? 'id' : renderLang;

		if (!Test.isRunningTest()) {
			detailPageUrl = sitePreferences.get('eventPage');
		}
		else {
			detailPageUrl = 'blah';
		}
		if (detailPageUrl.contains('?'))
			urlAppend = '&';
		else
			urlAppend = '?';

		gen.writeStartArray ();

		for (Event event: events) {
			gen.writeStartObject ();
			gen.writeStringField ('title', event.Subject);
			gen.writeStringField ('start', String.valueOf(event.StartDateTime.date()).substringBefore(' ') + 'T' + event.StartDateTime.time());
			gen.writeStringField ('end', String.valueOf(event.EndDateTime.date()).substringBefore(' ') + 'T' + event.EndDateTime.time());
			gen.writeStringField ('url', detailPageUrl + urlAppend + 'eventId=' + event.Id);
			gen.writeEndObject ();

			/*EventListing listing = new EventListing ();
			listing.title = event.Subject;
			listing.start = String.valueOf(event.StartDateTime.date()).substringBefore(' ') + 'T' + event.StartDateTime.time();
			listing.end = String.valueOf(event.EndDateTime.date()).substringBefore(' ') + 'T' + event.EndDateTime.time();
			listing.url = sitePreferences.get('eventPage') + '&eventId=' + event.Id;

			JSON.Serialize(listing);
			eventsAsJson += JSON.Serialize(listing);*/
			/*eventsAsJson += '{title: \'' + event.Subject + '\', start: \'' + String.valueOf(event.StartDateTime.date()).substringBefore(' ') + 'T' + event.StartDateTime.time() + '\',';
			eventsAsJson += 'end: \'' + String.valueOf(event.EndDateTime.date()).substringBefore(' ') + 'T' + event.EndDateTime.time() + '\',';
			eventsAsJson += 'url: \'' + sitePreferences.get('eventPage') + '&eventId=' + event.Id + '\'}, '; //depends on yyyy-mm-dd*/
		}
		//TODO: url is a parameter for an event,
		gen.writeEndArray ();

		String dummyJson = '{title: \'dummy\', start: \'2015-04-27T12:00:00\'},{title: \'dummy2\', start: \'2015-04-16T13:00:00\'}';

		//eventsAsJson = eventsAsJson.substringBeforeLast (','); //strip out the last comma as IE would have a problem with it
		System.debug('json is ' + gen.getAsString ());
		eventsAsJson = gen.getAsString ();

		//return eventsAsJson;

		String calStylesCss = ocms_mfc_utility.getResourceURL('ocms_mfc_calendar') + '/fullcalendar-2.3.1/fullcalendar.css';
		String calCalendarJs = ocms_mfc_utility.getResourceURL('ocms_mfc_calendar') + '/fullcalendar-2.3.1/fullcalendar.js';
		String calLocalization = ocms_mfc_utility.getResourceURL('ocms_mfc_calendar') + '/fullcalendar-2.3.1/lang/'+ renderLang +'.js';

		String html = '';
		html += '<div id="calendar-view-content"><div id="calendar" class="calendar"></div></div>';
		html += '<link rel="stylesheet" href="' + calStylesCss + '"type=\"text/css\"/>';
		html += '<script src="' + calCalendarJs + '"></script>';
		//include localization script only if renderLang is valid and not engligsh (english is default, and en_US is not recognized).
		if (!String.isBlank(renderLang) && renderLang != 'en_US') {
			html += '<script src="' + calLocalization + '"></script>';
		}
		html += '<script>';
	    html += '$(document).ready(function(){';
		html +=		'MFC.events = {};';
		html +=		'MFC.events.eventsAsJson = ' + eventsAsJson + ';';
		html +=		'MFC.events.todayText = "' + todayText + '";';
		html += 	'MFC.fLoadFullEventList();';
//        html += 	'$(\'.content-wrap.main-article\').prepend(\'<div id="breadcrumb"><div class="back"><a href="#"><span>Back</span></a></div><div class="breadcrumb-title"><span class="inner">' + calendarText + '</span></div><div class="breadcrumb-create"><a href="' + sitePreferences.get('eventFormPage') + '"><span>' + createEventText + '</span></a></div></div>\');';
        html += '$(\'#breadcrumb\').append(\'<div class="breadcrumb-create"><a href="' + sitePreferences.get('eventFormPage') + '"><span>' + createEventText + '</span></a></div>\')';
		html += '})';
		html += '</script>';
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

	private List <Event> getAllEvents () {
		Calendar__c calendar = Calendar__c.getAll ().get ('Manulife Central');
		String languageDesignator = getServiceAPI().getRenderLanguage().substring(0,2);
		String fieldToRetrieve = languageDesignator + '__c';
		Object fieldValue = calendar.get(fieldToRetrieve);
		String calendarToSearch = String.valueOf(fieldValue);
		User u = [SELECT City__c FROM User WHERE Id = :UserInfo.getUserId()];
		//List <Event> events = [SELECT Subject, StartDateTime, EndDateTime, Description From Event];
		List <Event> events = [SELECT Subject, StartDateTime, EndDateTime, Description From Event WHERE OwnerId = :calendarToSearch AND ((City__c = :u.City__c OR City__c = 'Global') OR ((Cities__c INCLUDES(:u.City__c)) OR (Cities__c INCLUDES ('Global')))) AND IsRecurrence = false];
		return events;
	}

	private Map <Date, List <Event>> getCurrentEvents () {
		Calendar__c calendar = Calendar__c.getAll ().get ('Manulife Central');
		String languageDesignator = getServiceAPI().getRenderLanguage().substring(0,2);
		String fieldToRetrieve = languageDesignator + '__c';
		Object fieldValue = calendar.get(fieldToRetrieve);
		String calendarToSearch = String.valueOf(fieldValue);
//		Object fieldValue = calendar.get(fieldToRetrieve);
//		event.OwnerId = String.valueOf(fieldValue);
		/* We need to find events from today to today + 7, however the only pure date field on Event is ActivityDate, and it is coerced into the ActivityDate in the context of the running user, with no way to change that
		 * So ActivityDate is essentially garbage data but it is the only thing we can use to filter our query. So we expand our date band by one on either side to ensure we have everything we might need, and then filter it further from there
		 */
		List <Event> eventsToReturn = new List <Event> ();
		Date startRange = Date.Today() - 1;
		Date endRange = Date.Today() + 8;
		Date realStartRange = Date.Today();
		Date realEndRange = Date.Today() + 7;
		System.debug('start range is ' + startRange);
		System.debug('end range is ' + endRange);
		System.debug('real start range is ' + realStartRange);
		System.debug('real end range is ' + realEndRange);
		User u = [SELECT City__c FROM User WHERE Id = :UserInfo.getUserId()];
		//List <Event> events = [SELECT Subject, StartDateTime, Location, DurationInMinutes FROM Event WHERE ActivityDate <= :endRange AND ActivityDate >= :startRange AND City__c = :u.City ORDER BY StartDateTime];
		List <Event> events = [SELECT Subject, StartDateTime, Location, DurationInMinutes, RecurrenceActivityId FROM Event WHERE OwnerId = :calendarToSearch AND ActivityDate <= :endRange AND ActivityDate >= :startRange AND ((City__c = :u.City__c OR City__c = 'Global') OR ((Cities__c INCLUDES( :u.City__c)) OR (Cities__c INCLUDES ('Global')))) AND IsRecurrence = false ORDER BY StartDateTime];
		System.debug('events list is ' + events);
		for (Event evt : events) {
			if (evt.StartDateTime.date() <= realEndRange && evt.StartDateTime.date() >= realStartRange) {
				eventsToReturn.add(evt);
			}
		}
		System.debug('events to return is ' + eventsToReturn);

		List <Date> currentDates = new List <Date> ();
		for (Integer i = 0; i < 8; i++) {
			currentDates.add(Date.Today() + i);
		}

		List <Event> tempList = new List <Event> ();
		Map <Date, List <Event>> returnMap = new Map <Date, List <Event>> ();

		for (Date theDate : currentDates) {
			for (Event evt : eventsToReturn) {
				if (evt.StartDateTime.date() < theDate)
					continue;
				else if (evt.StartDateTime.date() > theDate)
					break;
				else
					tempList.add(evt);
			}
			returnMap.put(theDate, tempList);
			tempList = new List <Event> ();
		}

		/*Date currentDate = realStartRange;

		for (Event evt : eventsToReturn) {
			if (currentDate == evt.StartDateTime.date()) {
				tempList.add (evt);
			}
			else {
				returnMap.put(currentDate, tempList);
				tempList.clear();
				currentDate += 1;
			}
		}*/
		return returnMap;
	}

	private Map <String, String> requestParameters;

	/*private String getMonth (Integer month) {
		if (month == 1)
			return 'January';
		if (month == 2)
			return 'February';
		if (month == 3)
			return 'March';
		if (month == 4)
			return 'April';
		if (month == 5)
			return 'May';
		if (month == 6)
			return 'June';
		if (month == 7)
			return 'July';
		if (month == 8)
			return 'August';
		if (month == 9)
			return 'September';
		if (month == 10)
			return 'October';
		if (month == 11)
			return 'November';
		if (month == 12)
			return 'December';
		return '';
	}

	private String getTime (Time t) {
		String timeFormatted = '';
		String suffix;

		if (t.hour() == 0) {
			timeFormatted += '12';
			suffix = 'AM';
		}
		else if (t.hour() > 0 && t.hour() < 10) {
			timeFormatted += '0' + t.hour();
			suffix = 'AM';
		}
		else if (t.hour() >= 10 && t.hour() < 12) {
			timeFormatted += t.hour();
			suffix = 'AM';
		}
		else if (t.hour() == 12) {
			timeFormatted += t.hour();
			suffix = 'PM';
		}
		else { //1pm to 11pm
			Integer displayedHour = t.hour() - 12;
			timeFormatted += displayedHour;
			suffix = 'PM';
		}

		if (t.minute() < 10) {
			timeFormatted += ':0' + t.minute();
		}
		else { //greater than 10
			timeFormatted += ':' + t.minute();
		}

		return timeFormatted + suffix;
	}*/

	public String getStringifiedDuration (Integer duration) {
		if (duration < 60)
			return pluralMinuteText != null ? (String.valueOf(duration) + pluralMinuteText) : '';
		if (duration >= 60)
			if (Math.mod(duration,60) == 0)
				if (duration == 60)
					return singularHourText != null ? ('1' + singularHourText) : '';
				else
					return pluralHourText != null ? (String.valueOf(duration / 60) + pluralHourText) : '';
			else
				if (duration < 120)
					return pluralMinuteText != null ? (String.valueOf(duration / 60) + singularHourText + ' ' + String.valueOf(Math.mod(duration,60)) + pluralMinuteText) : '';
				else
					return (pluralHourText != null && pluralMinuteText != null) ? (String.valueOf(duration / 60) + pluralHourText + ' ' + String.valueOf(Math.mod(duration,60)) + pluralMinuteText) : '';
		return '';
	}

	public String todayText {
		get {
			return getProperty('todayText');
		} set;
	}

	public String eventsText {
		get {
			return getProperty('eventsText');
		} set;
	}

	public String calendarText {
		get {
			return getProperty('calendarText');
		} set;
	}

	public String createEventText {
		get {
			return getProperty('createEventText');
		} set;
	}

	public String pluralHourText {
		get {
			return getProperty('pluralHourText');
		} set;
	}

	public String singularHourText {
		get {
			return getProperty('singularHourText');
		} set;
	}

	public String pluralMinuteText {
		get {
			return getProperty('pluralMinuteText');
		} set;
	}
}