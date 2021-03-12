trigger EmailMessageTrigger on EmailMessage (
	after delete, after insert, after undelete, after update,
	before delete, before insert, before update)
{
	if(!TriggerUtils.bypassEmailMessageTrigger())
		TriggerFactory.createHandler(EmailMessage.sObjectType);
}