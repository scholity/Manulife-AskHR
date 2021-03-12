/**
  * @author Rahul Singh <rahul_singh@manulife.com>
  * @description Schedulable class Purging Case Attachments 14 days after Case is closed.
  * Created for JIRA HRSALEFOR-1068
*/
public with sharing class AskHR_PurgeCaseFiles implements Schedulable{
	
    public Set<Id> CaseId = new Set<Id>();
    public Map<Id, Case> caseDetails = new Map<Id, Case>();
    public static string groupName = 'AskHR_Purging_Case_Attachment_Group';
    public  List<ContentDocumentLink> attachmentList = new List<ContentDocumentLink>();
    public Map<Id, ContentDocumentLink> contentMap = new Map<Id, ContentDocumentLink>();
	public List<Id> CDID = new List<Id>();
    
    public void execute(SchedulableContext sc) {
        performOperation();
    }
    
    private void performOperation() {
        
        if(!Test.isRunningTest()){
            
            /*attachmentList = [SELECT ContentDocumentId, ContentDocument.Title, ContentDocument.FileType, LinkedEntityId  FROM ContentDocumentLink where 
                              LinkedEntityId in 
                              (Select Id from Case where Status = 'Closed'and ClosedDate < Last_N_Days:14
                               and Type = 'HR Reporting')
                              limit 1000];*/
             attachmentList = [SELECT ContentDocumentId, ContentDocument.Title, ContentDocument.FileType, LinkedEntityId  FROM ContentDocumentLink where 
                              LinkedEntityId in 
                              (Select Id from Case where Status = 'Closed' and Type = 'HR Reporting')
                              limit 1000];
        }
        else{
            
            attachmentList = [SELECT ContentDocumentId, ContentDocument.Title, ContentDocument.FileType, LinkedEntityId  FROM ContentDocumentLink where 
                              LinkedEntityId in 
                              (Select Id from Case where Status = 'Closed'and Type = 'HR Reporting')
                              limit 1000];
        }
        system.debug('attachmentList count ='+attachmentList.size());
        if (!attachmentList.isEmpty()) {
        //Get the Case detail
            for(ContentDocumentLink cdl : attachmentList){
                
                CaseId.add(cdl.LinkedEntityId);
                contentMap.put(cdl.ContentDocumentId, cdl);
				CDID.add(cdl.ContentDocumentId);
            }
        caseDetails = getCaseDetails(CaseId);
            
            Database.DeleteResult[] results = Database.delete(CDID, false);
            
            List<String> operationResults = new List<String> ();
            operationResults.add(createHTMLTable());
            //For=====
            Integer loopIndex = 0;
            Integer countFailedOperation = 0;
            
            for (loopIndex = 0; loopIndex < results.size(); loopIndex++) {
                Database.DeleteResult dr = results.get(loopIndex);
                Id CID = CDID.get(loopIndex);
                String operationResult;
                
                operationResult = '<tr><td>' + caseDetails.get(contentMap.get(CID).LinkedEntityId).CaseNumber + '</td>' +
                    '<td>' + caseDetails.get(contentMap.get(CID).LinkedEntityId).Owner.Name + '</td>' +
                    '<td>' + caseDetails.get(contentMap.get(CID).LinkedEntityId).Type + '</td>' +
                    '<td>' + caseDetails.get(contentMap.get(CID).LinkedEntityId).ClosedDate + '</td>' +
                    '<td>' + contentMap.get(CID).ContentDocument.Title + '</td>' +
                    '<td>' + contentMap.get(CID).ContentDocument.FileType + '</td>';
                
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
                operationResults.add(0, '<b>ASKHR- Purging Case Attachment Job Result: </b><br/>' +
                                     'Success: ' + successOperation + '<br/>' +
                                     'Fail: ' + countFailedOperation + '<br/><br/>' +
                                     'Please see below Files deleted from HR reporting cases closed 14 days ago,<br/><br/>');
                system.debug('Sending Email---');
                sendHTMLEmailNotification('ASKHR- Case File Purging Job ', string.join(operationResults, '\n'));
                system.debug('Email sent---');
            }
            
        } 
    }
    
    public string createHTMLTable() {
        return '<table border="1"><tr><th>CaseNumber</th><th>CaseOwner</th><th>CaseType</th><th>ClosedDate</th><th>FileName</th><th>FileType</th><th>Result</th></tr>';
    }
    
    
    private Map<Id, Case> getCaseDetails(Set<Id> ids){
        
       Map<Id, Case> caseMap = new Map<Id, Case>([Select Id, Type, CaseNumber,Owner.Name, ClosedDate from Case where Id in :ids]);
        return caseMap;
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