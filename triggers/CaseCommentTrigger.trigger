trigger CaseCommentTrigger on CaseComment (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
   if(!TriggerUtils.bypassCaseCommentTrigger()){
        TriggerFactory.createHandler(CaseComment.sObjectType);
    
    }
}