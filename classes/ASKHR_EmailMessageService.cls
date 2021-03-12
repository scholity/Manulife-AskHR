/**
	*@author
 	*@description provides finder methods for accessing data in the EmailMessage object.
 	*/

public without sharing class ASKHR_EmailMessageService {
    
    /**
    *@description this Method is to retrieve email queue map from custom setting �Email Routing Config�
	*@return Map<String,String> email routing configs
    */
    public static Map<String,String> getEmailRoutingConfigs(){
        List<Email_Routing_Config__c> emailRoutingConfigList = new List<Email_Routing_Config__c>();
        emailRoutingConfigList= Email_Routing_Config__c.getAll().values();
        Map<String,String> emailRoutingConfigMap = new Map<String,String>();
        for (Email_Routing_Config__c emailRoutingConfig : emailRoutingConfigList){
            emailRoutingConfigMap.put(emailRoutingConfig.Routing_Email_Address__c, emailRoutingConfig.Queue_Name__c);
        }
        return emailRoutingConfigMap;
    }
    /**
    *@description this Method is to retrieve owner ID by name
	*@return Map<String,Id> queues
    */     
   public static Map<String, Id> getOwnerIdByName(){
    
       Map<String,String>emrMap=getEmailRoutingConfigs();
       system.debug('***emrMap.values()'+emrMap.values());
       
       Map<String, Id> queues = new Map<String, Id>();
       for (Group queue: [select Id, Name from Group where Name in :emrMap.values()]){
            queues.put(queue.name, queue.Id);
       }
       system.debug('***queues'+queues);
       return queues;
   }
   
   /*
    *@description this method is to prepare the list of cases based on the newly created EmailMessage records.
    *    Step1. Remove the newer EmailMessage with same case id from the list of EmailMessage
    *    just inserted.  Compare created date, and replace later email with the earlier email. 
    *    Step2. Continue to validate if each email message is the first email related with the case.
    *    For the first email to case, update case owner based on the email �ToAdress� field, 
    *    only add the validated email address info and case to the list 
    *@param Map<Id, sObject> newEmailMap
	*@return List<Case> list of cases by email address
    */
   public static List<Case> getCasesByEmailAddresss(Map<Id, sObject> newEmailMap){
       
    List<Case> m_casesByEmailAddresss=new List<Case>();
    Map<Id, EmailMessage> sortedEmailsbyCaseId=new Map<Id, EmailMessage>();
    //sort the map by case id (ParentId) from Trigger.newMap by removing duplicated emails related to the same case.
    for(sObject emobj:newEmailMap.values()){
        EmailMessage em= (EmailMessage)emobj;

            if(sortedEmailsbyCaseId.size()!=0){
                if(sortedEmailsbyCaseId.containsKey(em.ParentId)){
                    //replace the later email with the earlier email to the case
                    if(sortedEmailsbyCaseId.get(em.ParentId).CreatedDate>=em.CreatedDate){
                        sortedEmailsbyCaseId.remove(em.ParentId);
                        sortedEmailsbyCaseId.put(em.ParentId, em);
                    }
                }else{
                    sortedEmailsbyCaseId.put(em.ParentId, em);
                }//end if map has the case id
            }else{
                    sortedEmailsbyCaseId.put(em.ParentId, em);
            }//end if em in the list.
 
        
    }
    //system.debug('***sortedEmailsbyCaseId.size()'+sortedEmailsbyCaseId.size());
    //system.debug('*** sortedEmailsbyCaseId, values is '+sortedEmailsbyCaseId.values()+' newEmailMap key set is '+newEmailMap.keySet());
    if(sortedEmailsbyCaseId.size()>0){
    //sort list from existing emailMessages in database
    
    string address;
    string newOwner;
    Case newCase = new Case();
    string queueName;
    boolean isTheOnlyEmail2Case=true;
    Map<String,String> emRoutingConfig= getEmailRoutingConfigs();
    Map<Id, Id> email2Case =new Map<Id, Id>();
    Map<Id, Id> caseIdOldEmailMap=new Map<Id, Id>();
    List<EmailMessage> oldEmailList=[select Id, ParentId from EmailMessage  where ParentId in :sortedEmailsbyCaseId.keySet() and Id Not in :newEmailMap.keySet()];
    for(EmailMessage oldem:oldEmailList){
        caseIdOldEmailMap.put(oldem.ParentId,oldem.Id);
    }
    Map<Id, Case> newCaseMap=new Map<Id, Case>();
    newCaseMap.putAll([select Id, OwnerId from case where id in :sortedEmailsbyCaseId.keySet()]);
   // system.debug('***newCaseMap '+newCaseMap);
   // system.debug('***sortedEmailsbyCaseId'+sortedEmailsbyCaseId);
    for(EmailMessage em:sortedEmailsbyCaseId.values()){
        
            /*Validate if this email is the first email related with the case. 
            * Because each case might have many emailMessages, 
            * for email routing for new case will only handle the first email to the case 
            */
            //system.debug('***caseIdOldEmailMap'+caseIdOldEmailMap);
            if (caseIdOldEmailMap.get(em.ParentId)==null){
                
                newCase=newCaseMap.get(em.ParentId);
                if(em.ToAddress != null)
                {
                    address=em.ToAddress.toLowerCase();
                    If ((String.isNotEmpty(address))&&(newCase!=null)){
                        queueName=emRoutingConfig.get(address);
                        //system.debug('***queueName'+queueName);
                        if(String.isNotEmpty(queueName)){
                            newOwner=ASKHR_EmailMessageService.getOwnerIdByName().get(queueName);
                            //system.debug('***newOwner'+newOwner);
                        }
    
                        if (String.isNotEmpty(newOwner)) {
                            newCase.OwnerId=newOwner;
                            m_casesByEmailAddresss.add(newCase);
                        }
                    }
                }
    
            }
        
    }
    }
  //  system.debug('***m_casesByEmailAddresss '+m_casesByEmailAddresss);
    return m_casesByEmailAddresss;
   }
   
   /*@description this future method will be used in ASKHR_EmailMessageHandler and Finally() 
   * to update the list of case owners to the defined queues in custom setting. 
   * @param String Cases_JSON format
   */
    @future
    public static void updateCase(String cases_JSON){
        List<Case> cases = (List<Case>) JSON.deserialize(cases_JSON, List<Case>.class);
        update cases;       
        
    }
}