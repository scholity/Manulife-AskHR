trigger ActionStepTrigger on Action_Step__c (before insert, before update, before delete,
											after insert, after update, after delete)
{
	if(!TriggerUtils.bypassActionStepTrigger())
		TriggerFactory.createHandler(Action_Step__c.sObjectType);
}