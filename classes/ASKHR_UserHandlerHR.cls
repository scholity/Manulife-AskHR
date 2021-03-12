/**
 * @description  Trigger Handler for the User SObject to handle HR check box update. Makes 'HR' field on User Record compatible with Data Loader
 * Assigns PermissionSet Knowledge_and_Policy_maintenance to Users with 'HR' field = true. Unassigned if false.
 */

public class ASKHR_UserHandlerHR
{
    /**
	 * @description  
	 * @param triggerOld a list of the old versions of the user sObject records
	 * @param triggerNew a list of the new versions of the user sObject records
	 * @param action
	 */
    
    public static void operationHRValInc(map<id, User> triggerOld, list<User> triggerNew, String action)
    {
        if(triggerNew.size() == 1)
        {
            if((triggerOld.get(triggerNew[0].id).HR__c != triggerNew[0].HR__c) && triggerNew[0].isActive == false)
            {
                triggerNew[0].addError('You can not Edit HR field for inactive User');
            }
            else
            {
                ASKHR_UserHandlerHR.operationHR(triggerOld, triggerNew, action);
            }
        }  
        else
        {
            ASKHR_UserHandlerHR.operationHR(triggerOld, triggerNew, action);
        }      
    }
    
    /**
	 * @description  
	 * @param triggerOld a list of the old versions of the user sObject records
	 * @param triggerNew a list of the new versions of the user sObject records
	 * @param action
	 */
    public static void operationHR(map<id, User> triggerOld, list<User> triggerNew, String action)
    {
            map<Id, PermissionSetAssignment> mapPSAInsert = new map<Id, PermissionSetAssignment>(); 
            map<Id, PermissionSetAssignment> mapPSADelete = new map<Id, PermissionSetAssignment>();      
            list<User> Users = new list<User>();
            set<id> Usersid  = new set<id>();
            set<id> UsersidAll = new set<id>();
            for(User a: triggerNew)
            {
                UsersidAll.add(a.id);
            }
            list<User> UserIdActiveFromOrgList = [select id from User where isActive = true and ID IN: UsersidAll];
            for(User a: triggerNew)
            {
                for(User u: UserIdActiveFromOrgList)
                {
                    if(a.id == u.id)
                    {
                        Users.add(a);
                        Usersid.add(a.id);
                    }
                }
            }      
            list<PermissionSet> ps = new list<PermissionSet>();
            ps = [select id from PermissionSet where Name = 'Knowledge_and_Policy_maintenance'];
            if(ps.size() > 0)
            {                
                list<PermissionSetAssignment> psaAll = new list<PermissionSetAssignment>(); 
                psaAll = [select AssigneeId,  PermissionSetId from PermissionSetAssignment where AssigneeId IN: Usersid and PermissionSetId =: ps[0].id];
                set<Id> SusUser = new set<Id>();
                for(PermissionSetAssignment  a: psaAll)
                {
                    SusUser.add(a.AssigneeId);
                }
                if(action == 'update')
                {
                    for(User a: Users)
                    {
                        if(triggerOld.get(a.id).HR__c != a.HR__c)
                        {
                            if(a.HR__c == true)
                            {
                                if(!SusUser.contains(a.Id))
                                {
                                    PermissionSetAssignment psa = new PermissionSetAssignment();
                                    psa.AssigneeId = a.Id;
                                    psa.PermissionSetId = ps[0].id;  
                                    mapPSAInsert.put(a.id, psa);  
                                }                                                         
                            }
                            else
                            {
                                for(PermissionSetAssignment p: psaAll)
                                {
                                    if(p.AssigneeId == a.id)
                                    {
                                        mapPSADelete.put(p.id, p);
                                    }
                                }
                            }
                        }
                    }
                }
            }
            insert mapPSAInsert.values();
            delete mapPSADelete.values();
    }
}