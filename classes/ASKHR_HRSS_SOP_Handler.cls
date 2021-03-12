/**
* Class ASKHR_HRSS_SOP_Handler
*
* Trigger Handler for the HRSS SOP Article type. This class implements the ITrigger
* interface to help ensure the trigger code is bulkified and all in one place.
*/
public without sharing class ASKHR_HRSS_SOP_Handler implements ITrigger {
    
    Set<Id> submitedArtciles = new Set<Id>();
    Set<Id> autoPublishArticles = new Set<Id>();
    //List<Knowledge__kav> kavList = new List<Knowledge__kav>();
    String psName = System.Label.AskHR_Knowledge_Permission;
    Id psId = [Select Id from PermissionSet where Label = :psName limit 1].id;
    Id recTypeIdHRSOP = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByName().get(System.Label.HR_SOP).getRecordTypeId();
    
    
    public ASKHR_HRSS_SOP_Handler(){
        
    }
    
    public void bulkBefore(){
        
    }
    
    
    public void bulkAfter(){
        
    }
    
    public void beforeInsert(SObject so){
        
    }
    
    public void beforeUpdate(SObject oldSo, SObject so){
        
        Knowledge__kav kav = (Knowledge__kav) so;
        Knowledge__kav oldkav = (Knowledge__kav) oldSo;
        
        
    }
    
    public void beforeDelete(SObject so){
        
    }
    
    public void afterInsert(SObject so){
        
        
    }
    
    public void afterUpdate(SObject oldSo, SObject so){
        
        Knowledge__kav kav = (Knowledge__kav) so;
        Knowledge__kav oldkav = (Knowledge__kav) oldSo;
        //system.debug('submitedArtciles'+submitedArtciles);
        //system.debug('Approval_Status__c'+kav.Approval_Status__c+oldkav.Approval_Status__c);
        if(kav.RecordTypeId == recTypeIdHRSOP){
        
        if(kav.HR_SOP_Approval_Status__c != oldkav.HR_SOP_Approval_Status__c){
            
            if(kav.HR_SOP_Approval_Status__c == 'Submitted'){
                
                system.debug('If 0==');
                submitedArtciles.add(kav.Id);
            }
        }
        
        /*if(oldkav.HR_SOP_Approval_Status__c == 'Submitted' && kav.HR_SOP_Approval_Status__c == 'Approved' ){
            
            kavList.add(kav);
        }*/
        
        
        system.debug('submitedArtciles'+submitedArtciles);
        
        }   
        
    }
    
    public void afterDelete(SObject so){
        
        
    }
    
    /**
* @description This method is called once all records have been processed by the trigger. Use this 
* method to accomplish any final operations such as creation or updates of other records.
*/
    public void andFinally(){
        
        handlePermissionSetAssignment();
        
        //Using Quequable Interface to auto publish the articles and send email notification to the article owner and reviewer
        /*system.debug('kavList'+kavList);
        if(kavList != null){
           Id jobID = System.enqueueJob(new AskHR_AutoPublishArticles(kavList));
        }*/
        
        
    }
    public void handlePermissionSetAssignment(){
        
        UsersToInsertPS(psId, submitedArtciles);
        
    }
    /**
* @description This method assigns the permission sets to the user
* once the article is submitted for approval
* @param Id
* @param Set<Id>
*/
    @future
    public Static void UsersToInsertPS(Id psId, Set<Id> submitedArtciles){
        ProcessInstance[] piPending = [Select Id,TargetObjectid, Status
                                       FROM ProcessInstance 
                                       WHERE TargetObjectId in :submitedArtciles
                                       AND Status in ('Started', 'Pending')];
        system.debug('piPending ++'+piPending);
        
        List<ProcessInstanceWorkitem> workItem = new List<ProcessInstanceWorkitem>();
        
        if(!piPending.isEmpty()){
            workItem = [SELECT CreatedById,CreatedDate,ElapsedTimeInDays,ElapsedTimeInHours,
                        ElapsedTimeInMinutes,Id,IsDeleted,OriginalActorId,ProcessInstanceId,
                        ActorId,SystemModstamp FROM ProcessInstanceWorkitem where ProcessInstanceId= :piPending[0].Id];
            system.debug('workItem'+workItem);
        }
        system.debug('workItem++'+workItem);
        Set<Id> usersForPS = new Set<Id>();
        //if(Step != null && step[0].StepStatus == 'Started'){
        if(workItem != null){
            for(ProcessInstanceWorkitem wi : workItem){
                
                usersForPS.add(wi.ActorId);
            }
            system.debug('usersForPS'+usersForPS);
        }
        usersForPS.removeAll(checkForDuplicate(usersForPS, psId));
        //return usersForPS;
        assignPermissionSet(usersForPS, psId);
        
    }   
    
    public static void assignPermissionSet(Set<Id> usrs, Id psId){
        
        try{
        List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>();
        for(Id u : usrs){
            
            PermissionSetAssignment psa = new PermissionSetAssignment();
            psa.AssigneeId = u;
            psa.PermissionSetId = psId;
            psaList.add(psa);
        }
        system.debug('Insert psaList'+psaList);
        if(!psaList.isEmpty()){
            upsert psaList;
            
        }
        updateKnowledgeUserPermission(usrs, true);
        }catch(Exception e){
            
            system.debug('Exception '+e.getMessage());
        }
    }
    
    /**
* @description This method updates the Knowledge User Permission for the user
* @param Set<Id>
* @param Boolean
*/
    public static void updateKnowledgeUserPermission(Set<Id> usrs, Boolean flag){
        
        try{
        List<User> usrList = [Select Id, UserPermissionsKnowledgeUser from User
                              Where Id in : usrs];
        for(User u : usrList){
            u.UserPermissionsKnowledgeUser = flag;
        }
        update usrList;
        }catch(Exception e){
            
            system.debug('Exception '+e.getMessage());
        }
        
    }
    /**
* @description This method checks for the duplicate permission
* @param Set<Id>
* @param Id
*/
    public Static set<Id> checkForDuplicate(Set<Id> users, Id psId){
        Set<Id> usrs = new Set<Id>();
        List<PermissionSetAssignment> psa = [Select Id, AssigneeId, PermissionSetId from PermissionSetAssignment
                                             where AssigneeId in :users
                                             and PermissionSetId = :psId];
        If(psa != null){
            for(PermissionSetAssignment ps :psa){
                usrs.add(ps.AssigneeId);
            }
        }
        return usrs;
    }  
}