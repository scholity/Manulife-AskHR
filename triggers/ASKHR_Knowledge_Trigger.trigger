trigger ASKHR_Knowledge_Trigger on Knowledge__kav (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    if(!TriggerUtils.bypassKnowledgeTrigger()){
      if(Trigger_Setting__c.getInstance('Knowledge') != null){
        if(!Trigger_Setting__c.getInstance('Knowledge').Bypass__c){
            TriggerFactory.createHandler(Knowledge__kav.sObjectType);
        }
    }
  }
}