trigger Event on Event__c (before update, before insert, after insert) {

    // On insert pragmatically submit the approval request

     if (Trigger.isInsert) {
             ocms_mfc_EventHandler eventHandler = new ocms_mfc_EventHandler();
             eventHandler.createEvents(Trigger.new.get(0));
     }
    /*  Above step creates language specific events + one generic event which is not initiated
        for approval process.
        Ideally the name of that event is same as that of its Id
        Below step identifies such events and captures the respective Ids.
     */

     List<Event__c> eventCObjects = [ SELECT Id from Event__c where Id_And_Name_Equal__c = 'TRUE' and OwnerId = :UserInfo.getUserId() order by CreatedDate desc ];

    // On update ensure the trigger was fired by the approval workflow, and if so create a corresponding record on the Event object
    if (Trigger.isUpdate) {

        for (Event__c proposedEvent : Trigger.old) {
            Event__c updatedProposedEvent = Trigger.newMap.get(proposedEvent.Id);
            if (proposedEvent.IsApproved__c == true || updatedProposedEvent.IsApproved__c == false) {
                continue; // ensure the event is created only once by checking that both Trigger.old and Trigger.new have false and true values, respectively, for the approved flag
            }

            Event event = new Event ();

            /* DurationInMinutes has been transformed to a picklist with various values, this will eventually have to be reconfigured to translate this to the appropriate integer */
            //event.DurationInMinutes = Integer.valueOf(proposedEvent.DurationInMinutes__c); /* my field is a number (4,0) but for some reason there is no way to explicitly set the field type as integer within the Salesforce UI */
            //event.IsVisibleInSelfService = proposedEvent.IsVisibleInSelfService__c; /* this field appears to be writeable but it is not visible through the api, likely should delete from custom object as there is no way to access this field */
            /* EDIT the above: It appears this field may be really important and there might be a way to enable field level readability on it for System Administrator, see: http://salesforce.stackexchange.com/questions/19433/customer-community-user-activity-event-access */
            /* EDIT AGAIN: They actually have a Company Community license which gives access to Events by default, so this field may be irrelevant after all, it's hard to tell for sure because the Salesforce documentation on this field may be out of date -
*               It says the field is available when Communities is enabled and you have Customer Portal or Partner Portal licenses, but those license types are long since deprecated */
            event.Location = proposedEvent.Input_Location__c;
            Timezone tz = Timezone.getTimeZone (proposedEvent.Input_Timezone__c.substringAfter('(').substringBefore(')'));
            Date theDate = proposedEvent.Input_Date__c;
            Integer offsetFromGMT = tz.getOffset (theDate) / 3600000; //offset is given to us in milliseconds, so we convert to hours
            Integer displayedHours = Integer.valueOf (proposedEvent.Input_Time__c.substringBefore(':'));
            Integer hours = 0;

            if (proposedEvent.Input_Time__c.contains('PM')) {
                if (displayedHours != 12) {
                    hours = displayedHours + 12;
                } else {
                    hours = displayedHours;
                }
            }

            else if (proposedEvent.Input_Time__c.contains('AM')) {
                if (displayedHours == 12) {
                    hours = 0;
                } else {
                    hours = displayedHours;
                }
            }

            if ((hours - offsetFromGMT) >= 24) {
                theDate += 1;
            }

            if ((hours - offsetFromGMT < 0)) {
                theDate -= 1;
            }

            //3.6 million (3600000) milliseconds in an hour
            Time theTime = Time.newInstance (Integer.valueOf(hours - offsetFromGmt), Integer.valueOf(proposedEvent.Input_Time__c.substringAfter(':').substring(0, 2)), 0, 0);
            Datetime theDateTime = Datetime.newInstanceGmt (theDate, theTime);

            event.ActivityDate = proposedEvent.Input_Date__c;
            /* ActivityDate is ALWAYS coerced into the date equivalent of the running user's time zone on create. There is no way around this that I have found
            * Therefore the ActivityDate field should be regarded as garbage data and should not be used for any rendering
            */
            event.ActivityDateTime = theDateTime;
            event.StartDateTime = theDateTime;
            event.City__c = proposedEvent.Input_City__c;
            event.AddToFeed__c = proposedEvent.Input_AddToFeed__c;
            event.RelatedLink__c = proposedEvent.Input_RelatedLink__c;
            event.ContactName__c = proposedEvent.Input_ContactName__c;
            event.ContactTitle__c = proposedEvent.Input_ContactTitle__c;
            event.ContactPhone__c = proposedEvent.Input_ContactPhone__c;
            event.ContactEmail__c = proposedEvent.Input_ContactEmail__c;
            event.Cities__c = proposedEvent.Input_Cities__c;
            event.isAllDayEvent = false;

            Integer durationValue = Integer.valueOf(proposedEvent.Input_Duration__c.substringBefore(' '));

            if (proposedEvent.Input_Duration__c.contains('Hr')) {
                durationValue *= 60;
            }

            event.DurationInMinutes = durationValue;

            if (proposedEvent.Input_Recurrence__c == 'Weekdays') { //if recurring
                event.IsRecurrence = true;
                event.RecurrenceType = 'RecursEveryWeekday';
                event.RecurrenceStartDateTime = theDateTime;
                event.RecurrenceEndDateOnly = proposedEvent.Input_EndDate__c != null && proposedEvent.Input_EndDate__c > proposedEvent.Input_Date__c ? proposedEvent.Input_EndDate__c : proposedEvent.Input_Date__c;
                event.RecurrenceDayOfWeekMask = 62;
            } else if (proposedEvent.Input_Recurrence__c == 'Weekly') {
                event.IsRecurrence = true;
                event.RecurrenceType = 'RecursWeekly';
                event.RecurrenceStartDateTime = theDateTime;
                event.RecurrenceEndDateOnly = proposedEvent.Input_EndDate__c != null && proposedEvent.Input_EndDate__c > proposedEvent.Input_Date__c ? proposedEvent.Input_EndDate__c : proposedEvent.Input_Date__c;
                event.RecurrenceDayOfWeekMask = getMask (new Set <String>{
                        theDateTime.format('EEEE')
                }); //only specifying one day here
                event.RecurrenceInterval = 1;
            } else if (proposedEvent.Input_Recurrence__c == 'Monthly') {
                event.IsRecurrence = true;
                event.RecurrenceStartDateTime = theDateTime;
                event.RecurrenceEndDateOnly = proposedEvent.Input_EndDate__c != null && proposedEvent.Input_EndDate__c > proposedEvent.Input_Date__c ? proposedEvent.Input_EndDate__c : proposedEvent.Input_Date__c;
                if ('A day in a month' == proposedEvent.Input_Monthly_Recurrent_Type__c) {
                    event.RecurrenceInterval = integer.valueOf(proposedEvent.Input_RecurrenceDayOfMonthInterval__c);
                    event.RecurrenceType = 'RecursMonthly';
                    event.RecurrenceDayOfMonth = integer.valueOf(proposedEvent.Input_RecurrenceDayOfMonth__c);
                } else {
                    event.RecurrenceType = 'RecursMonthlyNth';
                    event.RecurrenceDayOfWeekMask = proposedEvent.Input_RecurrenceDayOfWeek__c != null ? getMask (new Set <String> (proposedEvent.Input_RecurrenceDayOfWeek__c.split(';'))) : getMask (new Set <String>{
                            theDateTime.format('EEEE')
                    });
                    event.RecurrenceInstance = proposedEvent.Input_RecurrenceWeekOfEveryMonth__c;
                    event.RecurrenceInterval = integer.valueOf(proposedEvent.Input_RecurrenceDayOfWeekInterval__c);
                }
            } else if (proposedEvent.Input_Recurrence__c == 'Custom') {
                event.IsRecurrence = true;
                event.RecurrenceType = 'RecursWeekly';
                event.RecurrenceStartDateTime = theDateTime;
                event.RecurrenceEndDateOnly = proposedEvent.Input_EndDate__c != null && proposedEvent.Input_EndDate__c > proposedEvent.Input_Date__c ? proposedEvent.Input_EndDate__c : proposedEvent.Input_Date__c;
                event.RecurrenceDayOfWeekMask = proposedEvent.Input_RecurrenceDays__c != null ? getMask (new Set <String> (proposedEvent.Input_RecurrenceDays__c.split(';'))) : getMask (new Set <String>{
                        theDateTime.format('EEEE')
                });
                System.debug('mask is ' + event.RecurrenceDayOfWeekMask);
                event.RecurrenceInterval = 1;
            } else { //one time only
                event.IsRecurrence = false;
            }

            Calendar__c calendar = Calendar__c.getAll().get('Manulife Central');
            System.debug('calendar is ' + calendar);

            String inputLanguage = proposedEvent.Input_Languages__c;

            if (inputLanguage == 'EN - English') {
                event.Description = proposedEvent.Input_Description__c;
                event.Subject = proposedEvent.Input_Title__c;
                Event constructedEvent = constructEvent(event, calendar, 'en', proposedEvent);
                insertEvent(constructedEvent, updatedProposedEvent, proposedEvent);
            } else if (inputLanguage == 'FR - French') {
                event.Description = proposedEvent.Input_Description_fr__c;
                event.Subject = proposedEvent.Input_Title_FR__c;
                Event constructedEvent = constructEvent(event, calendar, 'fr', proposedEvent);
                insertEvent(constructedEvent, updatedProposedEvent, proposedEvent);
            } else if (inputLanguage == 'Zh-Chinese Simpliefied') {
                event.Description = proposedEvent.Input_Description_Zh__c;
                event.Subject = proposedEvent.Input_Title_Zh__c;
                Event constructedEvent = constructEvent(event, calendar, 'zh', proposedEvent);
                insertEvent(constructedEvent, updatedProposedEvent, proposedEvent);
            } else if (inputLanguage == 'ja-Japanese') {
                event.Description = proposedEvent.Input_Description_ja__c;
                event.Subject = proposedEvent.Input_Title_ja__c;
                Event constructedEvent = constructEvent(event, calendar, 'ja', proposedEvent);
                insertEvent(constructedEvent, updatedProposedEvent, proposedEvent);
            } else if (inputLanguage == 'in-Indonesian') {
                event.Description = proposedEvent.Input_Description_in__c;
                event.Subject = proposedEvent.Input_Title_in__c;
                Event constructedEvent = constructEvent(event, calendar, 'in', proposedEvent);
                insertEvent(constructedEvent, updatedProposedEvent, proposedEvent);
            }

            String xyz = 'Manulife Central ' + UserInfo.getLanguage().substring(0, 2);
            System.debug ('calendar is ' + xyz);

            /* NOTE: The rules on recurring events are that you can only create a maximum of 100 recurring events */

            /* Creating a recurring event for Wednesday May 6th to Wednesday May 13th from 14:00 to 15:00 GMT results in the following:
        * 7 Events - One appears to be the "parent" of the other 6 "real" events
        * All 7 Events have a RecurrenceActivityId of the parent event's Id
        * Parent Event has: RecurrenceType - RecursEveryWeekday, RecurrenceStartDateTime - start time of first event, RecurrenceEndDateOnly - date of last event,
        * RecurrenceDayOfWeekMask - 62, IsRecurrence - true, IsChild - false, EndDateTime, ActivityDateTime, ActivityDate - matches that of the first recurring event
        *
        *  "Real" Events have: same subject, their own start date times, all recurrence fields are blank except for RecurrenceActivityId, which is the Id of the "parent" event
        *  IsRecurrence - false, IsChild - false, their own EndDateTimes, their own ActivityDateTimes (matching StartDateTimes) and ActivityDates
        *
        *  When a person is invited to the event (or RSVP's, etc.), 6 new Events are created, one for each day
        *  They all have their own StartDateTimes, EndDateTimes, ActivityDates, and ActivityDateTimes
        *  The first event has RecurrenceType - RecursEveryWeekday, RecurrenceStartDateTime - start time of first event, RecurrenceEndDateOnly - date of last event,
        *  RecurrenceDayOfWeekMask - 62, RecurrenceActivityId - Id of first of the 6 events, OwnerId - Id of user, IsRecurrence - true, IsChild - true, DurationInMintues - 60
        *  Other five events - Same subject, description, durationinminutes, ownerid
        *  No recurrence fields except RecurrenceActivityId - Id of first of the 6 events, IsRecurrence - false, IsChild - true
        *
        *  It also creates 6 EventRelation objects, one for each event. They all have - Status - New, RelationId - Id of the user,
        *  EventId - the Id of the Event it maps to NOTE: It always maps to the event on the calendar it was created on. In the case of the first recurrence,
        *  it maps to the "parent" event of the 7. No EventRelation object is created for the mapping to the child event that occurs at the same time as the "parent" of the 7
        *
        *   When making an event that recurs every Sunday, Tuesday, and Thursday RecurrenceType is RecursWeekly and RecurrenceInterval is 1 (meaning every week?)
        *
        *   RecurrenceDayOfWeekMask
        *       Sunday - 1
        *       Monday - 2
        *       Tuesday - 4
        *       Wednesday - 8
        *       Thursday - 16
        *       Friday - 32
        *       Saturday - 64
        *           Every weekday would be 2 + 4+ 8 + 16 + 32 = 62
        *
        *   RecurrenceType Picklist Values
        *           Label                       Value
        *           Recurs Daily                RecursDaily
        *           Recurs Every Weekday        RecursEveryWeekday
        *           Recurs Monthly              RecursMonthly
        *           Recurs Monthly Nth          RecursMonthlyNth
        *           Recurs Weekly               RecursWeekly
        *           Recurs Yearly               RecursYearly
        *           Recurs Yearly Nth           RecursYearlyNth
        *
        *   Recurrence Fields on Custom Object
        *           Recurrence (picklist)       Input_Recurrence__c         One Time, Weekdays, Weekly, Custom
        *           End Date (Date)             Input_EndDate__c
        *           Recurrence Days (picklist)  Input_RecurrenceDays__c     Sunday, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday
        */
        }


    }

    private Event constructEvent(Event event,Calendar__c calendar,String language, Event__c proposedEvent){
        String fieldToRetrieve = language + '__c';
        Object fieldValue = calendar.get(fieldToRetrieve);
        event.OwnerId = String.valueOf(fieldValue);
        return event;
    }


    private void insertEvent(Event event,Event__c  updatedProposedEvent,Event__c proposedEvent){

        insert event;
        // create a soft lookup from the custom event to the standard event made from it
        // NOTE: Salesforce prevents lookups to Events. There is a new beta feature in Winter '15 to allow lookups from Events to custom objects, but you have to contact support to have it enabled and that will not likely happen.
        updatedProposedEvent.Event__c = event.Id;
        if (eventCObjects != null && eventCObjects.size() > 0) {
        List <Attachment> attachments = [SELECT Name, Body, BodyLength FROM Attachment WHERE ParentId = :eventCObjects.get(0).Id];
        List <Attachment> newAttachments = new List <Attachment> ();
            for (Attachment attach : attachments) {
                Attachment newAttach = new Attachment ();
                newAttach.Name = attach.Name;
                newAttach.Body = attach.Body;
                newAttach.ParentId = event.Id;
                newAttach.OwnerId = event.OwnerId;
                newAttachments.add(newAttach);
            }
            insert newAttachments;
        }

    }


    private Integer getMask(Set <String> daysOfWeek) {
        System.debug(daysOfWeek);
        System.debug(daysOfWeek.size());
        Integer mask = 0;
        if (daysOfWeek.contains('Sunday'))
            mask += 1;
        if (daysOfWeek.contains('Monday'))
            mask += 2;
        if (daysOfWeek.contains('Tuesday'))
            mask += 4;
        if (daysOfWeek.contains('Wednesday'))
            mask += 8;
        if (daysOfWeek.contains('Thursday'))
            mask += 16;
        if (daysOfWeek.contains('Friday'))
            mask += 32;
        if (daysOfWeek.contains('Saturday'))
            mask += 64;
        return mask;
    }



}