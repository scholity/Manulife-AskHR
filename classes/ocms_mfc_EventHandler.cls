/**
 * Created by gorikbe on 05/03/2019.
 */

public with sharing class ocms_mfc_EventHandler {

    public ocms_mfc_EventHandler(){
    }
    /**
     * Create language specific events upon form submission
     *
     * @param triggeredEvent
     */
    public void createEvents(Event__c triggeredEvent){
        String languageString = triggeredEvent.Input_Languages__c;
            /* Make sure the below check/s are done only once upon event form submission*/
        if(triggerCount.getRunTimes()<1 ) {
            triggerCount.setRunTimes();

            /* Parse the languageString and create respective events */
            if(languageString.contains('EN')){
                Event__c event = new Event__c();

                event.name = triggeredEvent.Input_Title__c;
                if(event.name.length() > 80)// Name has a limit of 80 chars, exceeding length will cause insertion failure
                    event.name = event.name.substring(0, 79);

                event.Input_Description__c = triggeredEvent.Input_Description__c;
                event.Input_Title__c = triggeredEvent.Input_Title__c;
                event.Input_Languages__c = 'EN - English';
                prepareEvent(event, triggeredEvent);
            }
            if(languageString.contains('FR')){
                Event__c event = new Event__c();

                event.name = triggeredEvent.Input_Title_FR__c;
                if(event.name.length() > 80)
                    event.name = event.name.substring(0, 79);

                event.Input_Description_FR__c = triggeredEvent.Input_Description_FR__c;
                event.Input_Title_FR__c = triggeredEvent.Input_Title_FR__c;
                event.Input_Languages__c = 'FR - French';
                prepareEvent(event, triggeredEvent);
            }
            if(languageString.contains('Zh') ){
                Event__c event = new Event__c();

                event.name = triggeredEvent.Input_Title_Zh__c;
                if(event.name.length() > 80)
                    event.name = event.name.substring(0, 79);

                event.Input_Description_Zh__c = triggeredEvent.Input_Description_Zh__c;
                event.Input_Title_Zh__c = triggeredEvent.Input_Title_Zh__c;
                event.Input_Languages__c = 'Zh-Chinese Simpliefied';
                prepareEvent(event, triggeredEvent);
            }
            if(languageString.contains('ja')){
                Event__c event = new Event__c();

                event.name = triggeredEvent.Input_Title_ja__c;
                if(event.name.length() > 80)
                    event.name = event.name.substring(0, 79);

                event.Input_Description_ja__c = triggeredEvent.Input_Description_ja__c;
                event.Input_Title_ja__c = triggeredEvent.Input_Title_ja__c;
                event.Input_Languages__c = 'ja-Japanese';
                prepareEvent(event, triggeredEvent);
            }
            if(languageString.contains('Ind')){
                Event__c event = new Event__c();

                event.name = triggeredEvent.Input_Title_in__c;
                if(event.name.length() > 80)
                    event.name = event.name.substring(0, 79);

                event.Input_Description_in__c = triggeredEvent.Input_Description_in__c;
                event.Input_Title_in__c = triggeredEvent.Input_Title_in__c;
                event.Input_Languages__c = 'in-Indonesian';
                prepareEvent(event, triggeredEvent);
            }
        }
    }
    /**
     * Prepare and insert salesforce event record and initiate approval process     *
     * @param event
     * @param triggeredEvent
     */
    private void prepareEvent(Event__c event, Event__c triggeredEvent){

        event.Input_Duration__c =triggeredEvent.Input_Duration__c;
        event.Input_Recurrence__c = triggeredEvent.Input_Recurrence__c;
        event.Input_Time__c = triggeredEvent.Input_Time__c;
        event.Input_Timezone__c = triggeredEvent.Input_Timezone__c ;
        event.Input_Date__c = triggeredEvent.Input_Date__c;
        event.Input_City__c = triggeredEvent.Input_City__c;
        event.Input_AddToFeed__c = triggeredEvent.Input_AddToFeed__c;
        event.Input_RelatedLink__c = triggeredEvent.Input_RelatedLink__c;
        event.Input_ContactName__c = triggeredEvent.Input_ContactName__c;
        event.Input_ContactTitle__c = triggeredEvent.Input_ContactTitle__c;
        event.Input_ContactPhone__c = triggeredEvent.Input_ContactPhone__c;
        event.Input_ContactEmail__c = triggeredEvent.Input_ContactEmail__c;
        event.Input_Cities__c = triggeredEvent.Input_Cities__c;
        event.Input_EndDate__c = triggeredEvent.Input_EndDate__c;
        event.Input_Recurrence__c = triggeredEvent.Input_Recurrence__c;
        event.Input_Monthly_Recurrent_Type__c = triggeredEvent.Input_Monthly_Recurrent_Type__c;
        event.Input_RecurrenceDayOfMonthInterval__c = triggeredEvent.Input_RecurrenceDayOfMonthInterval__c;
        event.Input_RecurrenceDayOfWeek__c = triggeredEvent.Input_RecurrenceDayOfWeek__c;
        event.Input_RecurrenceWeekOfEveryMonth__c = triggeredEvent.Input_RecurrenceWeekOfEveryMonth__c;
        event.Input_RecurrenceDayOfWeekInterval__c = triggeredEvent.Input_RecurrenceDayOfWeekInterval__c;
        event.Input_RecurrenceDayOfMonth__c = triggeredEvent.Input_RecurrenceDayOfMonth__c;
        event.Input_RecurrenceDays__c = triggeredEvent.Input_RecurrenceDays__c;
        event.Input_Location__c = triggeredEvent.Input_Location__c;

        insert event;
        initiateApprovalProcess(event);
    }
    /**
     * Initiating the event approval process.
     *
     * @param event
     */
    private void initiateApprovalProcess(Event__c event){
        Approval.ProcessSubmitRequest request = new Approval.ProcessSubmitRequest ();
        request.setObjectId (event.Id);
        Approval.processResult result = Approval.process (request);
    }


}