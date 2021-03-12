@isTest
public class ocms_mfc_Calendar_Test {
	public static testMethod void test() {
		Profile p = [SELECT Id FROM profile WHERE name='System Administrator'];

		ocms_TestContentHelper helper = new ocms_TestContentHelper('Calendar Site');

		Map<String,String> attrMap = new Map<String,String>();
		List<Map<String,String>> attrList = new List<Map<String,String>>();
		attrList.add(attrMap);

		helper.createContent(attrList, 'Calendar');

		User u = new User(alias = 'standt', email='standarduser@manulife.com',
				emailencodingkey='UTF-8', lastname='waldo', languagelocalekey='en_US',
				localesidkey='en_US', profileid = p.Id, firstname='wheres',
				timezonesidkey='America/Los_Angeles', username='standarduserrr_Calendar@manulife.com',
				city = 'Kingston');
		TriggerUtils.setBypassUserTrigger(); // there is a trigger on user insert, this sets the flag so the trigger will bypass its logic check

		insert u;


		ocms_mfc_SitePreferences.preferencesMap = new Map<String, String>();
		ocms_mfc_SitePreferences.preferencesMap.put('eventPage', 'blah');

		System.runAs(u) {
			Event__c event = new Event__c();
			event.Input_Date__c = Date.today();
			event.Input_Time__c = '4:45 AM';
			event.Input_Cities__c = 'Kingston';
			event.Input_Description__c = 'this is the event description';
			event.Input_Duration__c = '45 Min';
			event.Input_Languages__c = 'EN - English';
			event.Input_Location__c = '45 Meadowview Crescent, Cornerbrook, NB';
			event.Input_Recurrence__c = 'Weekly';
			event.Input_EndDate__c = Date.today() + 15;
			event.Input_Timezone__c = 'GMT-08:00 Pacific Standard Time(America/Los_Angeles)';
			event.Input_Title__c = 'this is the event subject';
			event.Name = 'Unit Test Event';
			insert event;

			Calendar__c calendar = new Calendar__c();
			calendar.Name = 'Manulife Central';
			calendar.En__c = u.Id; //this is a way to fake the public calendar id - public calendars are not accessible via the API

			upsert calendar Name;

			event.IsApproved__c = true;

			update event;

			event = [SELECT Id, Event__c FROM Event__c WHERE Id = :event.Id];

			List<Event> createdEvents = [SELECT Id, Location FROM Event WHERE Id = :event.Event__c];

			if (!createdEvents.isEmpty()) {
				Event createdEvent = createdEvents[0];
				ocms_mfc_CalendarFull calFull = new ocms_mfc_CalendarFull();

				System.debug(calFull.getHTML());

				ocms_mfc_CalendarList calList = new ocms_mfc_CalendarList();

				String html = calList.getHTML();

				PageReference page = new PageReference('http://www.dummy.com');
				page.getParameters().put('eventId', createdEvent.Id);

				System.Test.setCurrentPage(page);

				ocms_mfc_EventView eventView = new ocms_mfc_EventView();
				html = eventView.getHTML();

				System.assert(html.contains('Meadowview Crescent'));

				eventView.executeRequest(new Map<String,String> {});

				ocms_mfc_EventService evtService = new ocms_mfc_EventService ();
				Map <String, String> request = new Map <String, String> ();
				request.put('action', 'rsvp');
				request.put('event', createdEvent.Id);
				evtService.executeRequest(request);
			}
		}

		// time to increase some code coverage testing non-essential logic
		ocms_mfc_Calendar myCalendar = new ocms_mfc_Calendar (helper.gc);
		myCalendar.getHTML();
		myCalendar.getListHtml();
		myCalendar.getFullHtml();
		myCalendar.getStringifiedDuration(45);
		myCalendar.getStringifiedDuration(60);
		myCalendar.getStringifiedDuration(90);
		myCalendar.getStringifiedDuration(120);
		myCalendar.getStringifiedDuration(150);
		ocms_mfc_Calendar myCalendar2 = new ocms_mfc_Calendar (helper.gc);
		System.Type myType = myCalendar.getType();
		myCalendar.executeRequest (new Map <String, String> ());
	}
}