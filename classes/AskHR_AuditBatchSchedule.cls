global class AskHR_AuditBatchSchedule implements Schedulable {
    
    global void execute(SchedulableContext SC) {
        AskHR_AuditBatchClass job = new AskHR_AuditBatchClass();
        Database.executeBatch(job, 200);
    }
    
}