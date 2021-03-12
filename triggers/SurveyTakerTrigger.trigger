trigger SurveyTakerTrigger on SurveyTaker__c (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {

	if(!TriggerUtils.bypassSurveyTakerTrigger())
		TriggerFactory.createHandler(SurveyTaker__c.sObjectType);
}