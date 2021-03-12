global with sharing class ocms_mfc_EventService implements cms.ServiceInterface {

    global String executeRequest (Map <String, String> request) {
        String response = '{success: false}';
        if (request.get('action') == 'rsvp') {
            response = '{"success": true, "html": ' + json.serialize(addEventToUserCalendar(request.get('event'))) + '}';
        }
        return response;
    }

    public System.Type getType(){
        return ocms_mfc_EventService.class;
    }

    private String addEventToUserCalendar (Id eventId) {
        //check if they have already rsvp'd to this event first

        try {
            /*Event evt = [SELECT e.Subject, e.StartDateTime, e.RelatedLink__c, e.OwnerId, e.Location, e.EndDateTime, e.DurationInMinutes, e.Description, e.City__c, e.ActivityDateTime, e.ActivityDate, e.RecurrenceActivityId
                         FROM Event e
                         WHERE Id = :eventId];*/

            Event evt = [SELECT e.Subject, e.StartDateTime, e.RelatedLink__c, e.OwnerId, e.Location, e.EndDateTime, e.DurationInMinutes, e.Description, e.City__c, e.ActivityDateTime, e.ActivityDate, e.RecurrenceActivityId,
                            (SELECT Id, relationid, eventid, status FROM EventRelations WHERE RelationId = :UserInfo.getUserId())
                         FROM Event e
                         WHERE Id = :eventId];

            if (evt == null) {
                return 'There was a problem with your request. Please contact your administrator for further assistance';
            }

            if (evt.eventrelations.size () > 0) {
                return 'You have already RSVP\'d to this event';
            }

            if (evt.RecurrenceActivityId != null) {
                evt = [SELECT e.Subject, e.StartDateTime, e.RelatedLink__c, e.OwnerId, e.Location, e.EndDateTime, e.DurationInMinutes, e.Description, e.City__c, e.ActivityDateTime, e.ActivityDate, e.RecurrenceActivityId
                       FROM Event e
                       WHERE Id = :evt.RecurrenceActivityId];
            }

            //Salesforce auto creates an Event object for you when you create an EventRelation object
            /*Event userEvent = new Event ();
            userEvent.Subject = evt.Subject;
            userEvent.StartDateTime = evt.StartDateTime;
            userEvent.RelatedLink__c = evt.RelatedLink__c;
            userEvent.OwnerId = UserInfo.getUserId();
            userEvent.Location = evt.Location;
            //userEvent.IsChild = true; //Apex gives an error here saying "Field is not writeable"
            userEvent.EndDateTime = evt.EndDateTime;
            userEvent.DurationInMinutes = evt.DurationInMinutes;
            userEvent.Description = evt.Description;
            userEvent.City__c = evt.City__c;
            userEvent.AddToFeed__c = null;
            userEvent.ActivityDateTime = evt.ActivityDateTime;
            userEvent.ActivityDate = evt.ActivityDate;
            insert userEvent;*/

            /*
             * Relevant fields on EventRelation object -
             *      Status - (picklist) with possible values: "New", "Declined", or "Accepted"
             *      Response - (string) optional text the user can enter when responding
             *      RespondedDate - (datetime) when the user "most recently" responded
             *      RelationId - (reference) Id of user responding to event (can't be changed once specified)
             *      EventId - (reference) Id of the event (can't be changed once specified)
             */

            EventRelation relation = new EventRelation ();
            relation.Status = 'Accepted';
            relation.RespondedDate = Datetime.now();
            Relation.RelationId = UserInfo.getUserId();
            Relation.EventId = evt.id;
            insert relation;
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
        }

        return 'Your response has been recorded and the event has been added to your personal calendar.';
    }
}