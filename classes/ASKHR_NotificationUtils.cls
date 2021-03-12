/**
*@description this class have utility methods to send email notification
*/
public without sharing class ASKHR_NotificationUtils {
    private static List<ASKHR_Global_Setting__mdt> settings = [Select Enable_Reporting__c, Reporting_Group__c from ASKHR_Global_Setting__mdt where Active__c = true LIMIT 1];
    
    /**
	*@description this method used to send email notification
	*@param String action receives action to do 
	*@param String message receives error message
	*/
    public static void sendEmailNotification(String action, String message) {
        try {
            if (settings != null && !settings.isEmpty()) {
                if(String.isEmpty(action) || String.isEmpty(message)){
                    throw new NotificationUtilException('Action or Email message is empty');
                }
                
                ASKHR_Global_Setting__mdt setting = settings.get(0);
                if (setting.Enable_Reporting__c == true) {
                    emailOperation(getAddresses(setting), action, message, false);
                }
            }
            
        } catch(Exception e) {
            System.debug('Error occur when attempting to notify error:' + e.getMessage());
        }
    }
    /**
	*@description this method used to send HTML email notification
	*@param String action receives action to do 
	*@param String htmlMessage receives error HTMLMessage
	*/
    public static void sendHTMLEmailNotification(String action, String htmlMessage) {
        try {
            if (settings != null && !settings.isEmpty()) {
                if(String.isEmpty(action) || String.isEmpty(htmlMessage)){
                    throw new NotificationUtilException('Action or Email message is empty');
                }
                
                ASKHR_Global_Setting__mdt setting = settings.get(0);
                if (setting.Enable_Reporting__c == true) {
                    emailOperation(getAddresses(setting), action, htmlMessage, true);
                }
            }
        } catch(Exception e) {
            System.debug('Error occur when attempting to notify html error:' + e.getMessage());
        }
    }
     /**
	*@description this method gets user email addresses
	*@param ASKHR_Global_Setting__mdt setting
	*@return List<String> of email addresses
	*/
    private static List<String> getAddresses(ASKHR_Global_Setting__mdt setting) {
        List<Group> groups = [select(select UserOrGroupId from GroupMembers) from Group where DeveloperName = :setting.Reporting_Group__c];
        
        if(groups.isEmpty()){
            throw new NotificationUtilException('Could not find the public group ' + setting.Reporting_Group__c + ' when attempting to notify error.');
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
    private static void emailOperation(List<String> addresses, String action, String message, Boolean isHTML) {
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
    private static String getSandboxName() {
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