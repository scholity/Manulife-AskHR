trigger ContactTrigger on Contact (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    if(!TriggerUtils.bypassContactTrigger()){
	    TriggerFactory.createHandler(Contact.sObjectType);
    }
}