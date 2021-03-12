public with sharing class AskHR_PurgeAuditTrailRecords implements Schedulable{
    
    List<Audit_Trail__c> auditLogs = new List<Audit_Trail__c>();
    public static string groupName = 'AskHR_Purging_Case_Attachment_Group';
    
     public void execute(SchedulableContext sc) {
        performOperation();
    }
    
    private void performOperation() {
        
        //auditLogs = [Select Id, Name, CreatedDate, CreatedDate__c, Audit_Rec_User__c, Section__c, Audit_ID__c from Audit_Trail__c  where CreatedDate < Last_N_YEARS:1 limit 1000];
         auditLogs = [Select Id, Name, CreatedDate, CreatedDate__c, Audit_Rec_User__c, Section__c, Audit_ID__c from Audit_Trail__c where CreatedDate <= TODAY limit 1000];
        system.debug('auditLogs '+auditLogs.size());
        if (!auditLogs.isEmpty()) {
            
        Database.DeleteResult[] results = Database.delete(auditLogs, false);
            //
            
            List<String> operationResults = new List<String> ();
            operationResults.add(createHTMLTable());
            //For=====
            Integer loopIndex = 0;
            Integer countFailedOperation = 0;
            
            for (loopIndex = 0; loopIndex < results.size(); loopIndex++) {
                Database.DeleteResult dr = results.get(loopIndex);
                Audit_Trail__c log = auditLogs.get(loopIndex);
                String operationResult;
                
                operationResult = '<tr><td>' + log.Name + '</td>' +
                    '<td>' + log.CreatedDate + '</td>' +
                    '<td>' + log.CreatedDate__c + '</td>'+
                    '<td>' + log.Audit_Rec_User__c + '</td>' +
                    '<td>' + log.Section__c + '</td>' +
                    '<td>' + log.Audit_ID__c	+ '</td>';
                
                if (!dr.isSuccess()) {
                    operationResult += '<td>Failed-';
                    for (Database.Error err : dr.getErrors()) {
                        operationResult += 'Details: ' + err.getStatusCode() + '<br/>' + err.getMessage();
                    }
                    operationResult += '</td>';
                    countFailedOperation++;
                } else {
                    operationResult += '<td>Success</td>';
                }
                
                operationResult += '</tr>';
                operationResults.add(operationResult);
            }
            //End for========
            operationResults.add('</table>');
            system.debug('operationResult'+operationResults);
            if (!operationResults.isEmpty()) {
                Integer successOperation = results.size() - countFailedOperation;
                operationResults.add(0, '<b>ASKHR- Purging Audit Logs Job: </b><br/>' +
                                     'Success: ' + successOperation + '<br/>' +
                                     'Fail: ' + countFailedOperation + '<br/><br/>' +
                                     'Please see below Audit Log records created more than an year ago,<br/><br/>');
                system.debug('Sending Email---');
                sendHTMLEmailNotification('ASKHR- Purging Audit Logs Job ', string.join(operationResults, '\n'));
                system.debug('Email sent---');
            }
            
            //
            
            
    }
    }
    
    public string createHTMLTable() {
        
        return '<table border="1"><tr><th>Audit Name</th><th>CreatedDate</th><th>Audit Created Date</th><th>Audit Record User</th><th>Section</th><th>AuditId</th><th>Result</th></tr>';
    }
    
    public static void sendHTMLEmailNotification(String action, String htmlMessage) {
        try {
            
            if(String.isEmpty(action) || String.isEmpty(htmlMessage)){
                throw new NotificationUtilException('Action or Email message is empty');
            }
            
            emailOperation(getAddresses(), action, htmlMessage, true);
            
            
        } catch(Exception e) {
            System.debug('Error occur when attempting to notify html error:' + e.getMessage());
        }
    }
    
    
    public static List<String> getAddresses() {
        List<Group> groups = [select(select UserOrGroupId from GroupMembers) from Group where DeveloperName = :groupName];
        
        if(groups.isEmpty()){
            throw new NotificationUtilException('Could not find the public group ' + groupName + ' when attempting to notify error.');
        }else{
            
            List<String> userIds = new List<String> ();
            List<String> addresses = new List<String> ();
            Group g = groups.get(groups.size()-1);
            for (GroupMember gm : g.GroupMembers) {
                userIds.add(gm.UserOrGroupId);
            }
            
            User[] users = [select Email from User where Id in :userIds];
            
            for (User u : users) {
                addresses.add(u.Email);
            }
            return addresses;
        }
    }
    
    public static void emailOperation(List<String> addresses, String action, String message, Boolean isHTML) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(addresses);
        mail.setSubject(getSandboxName() + action);
        if (isHTML) {
            mail.setHTMLBody(message);
        } else {
            mail.setPlainTextBody(message);
        }
        //avoid sending emails in Unit Testing to governor limit error
        if (!Test.isRunningTest()) {
            Messaging.sendEmail(new Messaging.Email[] { mail }, false);
        }
    }
    
    public static String getSandboxName() {
        try {
            Organization org = [select id, IsSandbox from Organization];
            if (org.IsSandbox) {
                if (UserInfo.getUserName().substringAfterLast('.com') != null)
                    return '[' + UserInfo.getUserName().substringAfterLast('.').toUpperCase() + '] ';
            }
        } catch(Exception ex) {
        }
        
        return '';
    }
    
     public class NotificationUtilException extends Exception{}
    
}