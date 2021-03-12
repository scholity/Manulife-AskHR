/**
  * @author Rahul Singh <rahul_singh@manulife.com>
  * @description Batch class for Audit Trail Log record creation. The class will handle querying and Store the Audit Trail data in to Custom Object
*/
global class AskHR_AuditBatchClass implements Database.Batchable<sObject>, Database.Stateful{
    
    AuditTrail__c atc = AuditTrail__c.getInstance('Main');
    List<String> excludeUsers = new List<String>(); 
    Datetime dts = atc.Last_Batch_Run__c;
    public static List<AuditTrail_Exclude_User__c> settings = [Select User_Name__c from AuditTrail_Exclude_User__c where Active__c = true];
    
    List<Audit_Trail__c> ATILoad = new List<Audit_Trail__c>();
    Boolean updateSyncBatch = false;
    String query,query1;
    String errorMsg = null;
    public static string groupName = 'AskHR_GFIT_Team_Error_Notification';
    
    
    global AskHR_AuditBatchClass(){
       excludeUsers = getExcludedUsers();
        if(!Test.isRunningTest()){
            query = 'SELECT Id,Action,CreatedById,CreatedDate,Display,Section,DelegateUser FROM SetupAuditTrail where CreatedBy.Name NOT IN :excludeUsers' ;
            query1 = 'SELECT Id,Action, CreatedById,CreatedDate,Display,Section,DelegateUser FROM SetupAuditTrail where CreatedDate >: dts and CreatedBy.Name NOT IN :excludeUsers';
            
        }
        else{
            query = 'SELECT Id,Action,CreatedById,CreatedDate,Display,Section,DelegateUser FROM SetupAuditTrail Limit 200';
            query1 = 'SELECT Id,Action, CreatedById,CreatedDate,Display,Section,DelegateUser FROM SetupAuditTrail where CreatedDate >: dts Limit 200';
        }
        //List<SetupAuditTrail> abce = [SELECT Id,Action,CreatedById,CreatedDate,Display,Section,DelegateUser FROM SetupAuditTrail where CreatedBy.Name NOT IN :excludeUsers];
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        if(atc.Batch_Sync__c){
            if(atc.Last_Batch_Run__c==null){
                return Database.getQueryLocator(query);
            }
            else
                return Database.getQueryLocator(query1);
        }else
            return null;
    }
    global void execute(Database.BatchableContext BC, List<SetupAuditTrail> scope){
        for(SetupAuditTrail sat: scope){
            Audit_Trail__c at = new Audit_Trail__c();
            if(sat.Action != null)
            at.Action__c = sat.Action;
            if(sat.Section != null)
            at.Section__c = sat.Section;
            at.CreatedDate__c = sat.CreatedDate;
            if(sat.DelegateUser != null)
            at.DelegateUser__c = sat.DelegateUser;
            if(sat.Display != null)
            at.Display__c = sat.Display;
            at.Audit_Id__c = sat.Id;
            at.Audit_Rec_User__c = sat.CreatedById;
            ATILoad.add(at);
        }
        if(ATILoad.size() > 0){
            
             try{
                upsert ATILoad;
                
                updateSyncBatch = true;
                
            }catch(Exception e){
                
                
                system.debug('Error = '+e.getMessage());
                errorMsg = e.getMessage();
                system.debug('errorMsg'+errorMsg);
            }
        }
    }
    global void finish(Database.BatchableContext BC){
        
        system.debug('errorMsg2== '+errorMsg);
        system.debug('updateSyncBatch== '+updateSyncBatch);
        if(updateSyncBatch){
            atc.Last_Batch_Run__c = system.now();
            update atc;
            system.debug('Last_Batch_Run__c Updated');
        }
        AsyncApexJob a = [Select Id, Status,ExtendedStatus,NumberOfErrors, JobItemsProcessed,
                          TotalJobItems, CreatedBy.Email
                          from AsyncApexJob where Id =:BC.getJobId()];
        system.debug('a' + a );
        system.debug('Sending Email ===');
        if(errorMsg != null){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            //String[] toAddresses = new String[] {a.CreatedBy.Email};
            String[] toAddresses = getAddresses();
            system.debug('toAddresses'+toAddresses);
                mail.setToAddresses(toAddresses);
            mail.setSubject('AskHR_AuditBatchScheduleJob Failed');
            //mail.setHTMLBody('<b>AskHR_AuditBatchClass Job Result : </b> ' + a.TotalJobItems +
                                 // ' batches with '+ a.NumberOfErrors + ' failures.</br></br>'+
                                 //'<b>Error Message : </b>'+errorMsg);
            mail.setHTMLBody('<b>AskHR_AuditBatchClass Job failed to complete due to below error,</br></br>'+
                             '<b>Error Message : </b>'+errorMsg);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            system.debug('Email sent ===');
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
            system.debug('addresses'+addresses);
            return addresses;
            
        }
    }
    
    public static List<String> getExcludedUsers() {
        List<String> userList = new List<String>();
        for(AuditTrail_Exclude_User__c setting : settings){
            
            userList.add(setting.User_Name__c);        
        }
        return userList;
    }
    
    public class NotificationUtilException extends Exception{}
}