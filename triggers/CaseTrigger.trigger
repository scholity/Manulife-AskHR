trigger CaseTrigger on Case (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
   if(!TriggerUtils.bypassCaseTrigger()){
        TriggerFactory.createHandler(Case.sObjectType);
    
    }
}