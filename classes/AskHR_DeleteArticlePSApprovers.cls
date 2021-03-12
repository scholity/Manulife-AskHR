/**
 	*@author
 	*@description this class is used to remove the knowledge permissions
	*assigned to the user during HRSS SOP Approval process
 	*/
public class AskHR_DeleteArticlePSApprovers implements Schedulable {
    
    //String psName = 'AskHR Knowledge Approval - Assigned Dynamically by System';
    String psName = System.Label.AskHR_Knowledge_Permission;
    Id pId = [Select Id from Permissionset where Label = : psName].Id;
    Id userId = null;
    public void execute(SchedulableContext sc) {
        performOperation();
        
    }
    private void performOperation() {
        
        try{
        system.debug('Batch operation ---');
        
        Map<Id, PermissionSetAssignment> psMap = new Map<Id, PermissionSetAssignment>();
        List<PermissionSetAssignment> psToRetain = new List<PermissionSetAssignment>();
        List<PermissionSetAssignment> psa = [Select Id, AssigneeId, PermissionSetId from PermissionSetAssignment
                                             where PermissionSetId = :pId Limit 1000];
        system.debug('psa'+psa);
        Set<Id> users = new Set<Id>();
        Set<Id> usersForPS = new Set<Id>();
        if(!psa.isEmpty()){
            for(PermissionSetAssignment ps : psa){
                
                users.add(ps.AssigneeId);
                psMap.put(ps.AssigneeId, ps);
            }
        }
        system.debug('users'+users);
        system.debug('psMap'+psMap);
        List<ProcessInstanceWorkitem> workItems = [Select Id,ActorId from ProcessInstanceWorkitem
                                                   where ActorId in :users];
        system.debug('workItems'+workItems);
        if(!workItems.isEmpty()){
            
            for(ProcessInstanceWorkitem wi : workItems){
                
                usersForPS.add(wi.ActorId);
            }
        }
        system.debug('usersForPS'+usersForPS);
        if(!usersForPS.isEmpty()){
            for(Id userId : usersForPS){
                
                psMap.remove(userId);
            }
            
        }
        system.debug('psMap'+psMap);
        If(!psMap.isEmpty()){
            
            delete psMap.values();
            updateKnowledgePermisson(psMap.keySet());
            
        }
        }catch(Exception e){
            
            system.debug('Exception'+e.getMessage());
        }
        
    }
    
    
    
    private void updateKnowledgePermisson(Set<Id> userId){
        
        try{
        List<User> users = [Select Id, UserPermissionsKnowledgeUser from User where Id in :userId];
        For(User u : users){
            
            u.UserPermissionsKnowledgeUser = false;
        }
        update users;
        }
        catch(Exception e){
            
            system.debug('Exception'+e.getMessage());
        }
        
    }
    
}