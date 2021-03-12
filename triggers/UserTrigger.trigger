trigger UserTrigger on User (after insert,  
after update, before insert, before update) {
    if(!TriggerUtils.bypassUserTrigger()){
        TriggerFactory.createHandler(User.sObjectType);
    }
    if(Trigger.isUpdate && Trigger.isAfter)
    {        
        ASKHR_UserHandlerHR.operationHRValInc(Trigger.oldmap, Trigger.new, 'update');
    }
}