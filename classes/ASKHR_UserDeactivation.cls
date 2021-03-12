/**
  * @author Rahul Singh <rahul_singh@manulife.com>
  * @description Schedulable class for User Deactivation. The class will handle querying and deactivating users who have not logged in since 30 Days.
  * Created for Plan View number 0016474 - SSO Enablement project
*/
public with sharing class ASKHR_UserDeactivation implements Schedulable {
    
    public static List<ASKHR_UserLicenseSetting__mdt> settings = [Select Profile_Name__c from ASKHR_UserLicenseSetting__mdt where Active__c = true];
    public set<String> excludeProfiles = new set<String>();
    public static string groupName = 'AskHR_User_License_Reporting';
    
    public void execute(SchedulableContext sc) {
        performOperation();
    }
    /**
    * @description Perform the operation by querying the active Users.
    * @return void 
    */
    private void performOperation() {
        excludeProfiles = getExcludedProfiles();
        system.debug('excludeProfiles'+excludeProfiles);
        Datetime myDateTime = Datetime.now();
        Datetime newDateTime = myDateTime.addDays(-30);
        system.debug('newDateTime'+newDateTime);
        List<User> usersToDeactivate = new List<User>();
        if(!Test.isRunningTest()){
            //Modify the query to get the users with login date null
            /*usersToDeactivate = [Select Id, IsActive,
                                 Name,
                                 Profile.Name,
                                 LastLoginDate,
                                 LastModifiedDate,
                                 Employee_ID__c,
                                 FederationIdentifier,
                                 LastModifiedBy.Name
                                 FROM User
                                 WHERE IsActive = TRUE
                                 AND LastLoginDate <= :newDateTime
                                 AND Profile.Name NOT IN :excludeProfiles limit 1000];*/
            usersToDeactivate = [Select Id, IsActive,
                                 Name,
                                 Profile.Name,
                                 LastLoginDate,
                                 CreatedDate,
                                 LastModifiedDate,
                                 Employee_ID__c,
                                 FederationIdentifier,
                                 LastModifiedBy.Name
                                 FROM User
                                 WHERE IsActive = TRUE
                                 AND (LastLoginDate <= :newDateTime OR (LastLoginDate = null AND CreatedDate < LAST_N_DAYS:30))
                                 AND Profile.Name NOT IN :excludeProfiles
                                 AND Name NOT IN ('Platform Integration User','Automated Process') limit 1000];
        }
        else{
            usersToDeactivate = [Select Id, IsActive,
                                 Name,
                                 Profile.Name,
                                 LastLoginDate,
                                 CreatedDate,
                                 LastModifiedDate,
                                 Employee_ID__c,
                                 FederationIdentifier,
                                 LastModifiedBy.Name
                                 FROM User
                                 WHERE IsActive = TRUE
                                 AND Profile.Name NOT IN :excludeProfiles limit 1];
        }
        system.debug('usersToDeactivate '+usersToDeactivate.size());
        
        if (!usersToDeactivate.isEmpty()) {
            for (User user : usersToDeactivate) {
                user.IsActive = false;
            }
            
            Database.SaveResult[] results = Database.update(usersToDeactivate, false);
            List<String> operationResults = new List<String> ();
            operationResults.add(createHTMLTable());
            
            Integer loopIndex = 0;
            Integer countFailedOperation = 0;
            for (loopIndex = 0; loopIndex < results.size(); loopIndex++) {
                Database.SaveResult sr = results.get(loopIndex);
                User currUser = usersToDeactivate.get(loopIndex);
                String operationResult;
                
                operationResult = '<tr><td>' + currUser.Id + '</td>' +
                    '<td>' + currUser.Name + '</td>' +
                    '<td>' + currUser.Employee_ID__c + '</td>' +
                    '<td>' + currUser.Profile.Name + '</td>' +
                    '<td>' + currUser.LastLoginDate + '</td>' + 
                    '<td>' + currUser.CreatedDate + '</td>' +
                    '<td>' + currUser.LastModifiedBy.Name + '</td>';
                
                if (!sr.isSuccess()) {
                    operationResult += '<td>Failed-';
                    for (Database.Error err : sr.getErrors()) {
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
            
            operationResults.add('</table>');
            if (!operationResults.isEmpty()) {
                Integer successOperation = results.size() - countFailedOperation;
                operationResults.add(0, '<b>ASKHR- User Deactivation Operation Result: </b><br/>' +
                                     'Success: ' + successOperation + '<br/>' +
                                     'Fail: ' + countFailedOperation + '<br/><br/>');
                system.debug('Sending Email---');
                sendHTMLEmailNotification('ASKHR- User Deactivation Job ', string.join(operationResults, '\n'));
                system.debug('Email sent---');
            }
        }
    }
    
    public string createHTMLTable() {
        return '<table border="1"><tr><th>Id</th><th>Name</th><th>Employee Id</th><th>Profile</th><th>Last Login Date</th><th>Created Date</th><th>Last Modified By</th><th>Result</th></tr>';
    }
    
    /**
	*@description this method used to send HTML email notification
	*@param String action receives action to do 
	*@param String htmlMessage receives error HTMLMessage
	*/
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
    
    /**
	*@description this method gets user email addresses
	*@param 
	*@return List<String> of email addresses
	*/
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
    
    /**
	*@description this method used to send the email
	*@param List<String> addresses receives list of email address
	*@param String action receives action
	*@param String message receives error message
	*@param Boolean isHTML receives true or false to set the email body
	*/
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
    
    /**
	*@description this method gets Sandbox name
	*@return string sandbox name
	*/
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
    
    /**
	*@description this method gets List of profiles excluded for this job
	*@return string List of profiles
	*/
    public static set<String> getExcludedProfiles() {
        set<String> profileList = new set<String>();
        for(ASKHR_UserLicenseSetting__mdt setting : settings){
            
            profileList.add(setting.Profile_Name__c);        
        }
        return profileList;
    }
    
    public class NotificationUtilException extends Exception{}
}