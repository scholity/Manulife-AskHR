/**
	* @author Mohamad Ammar Amran <mohamadammar_amran@manulife.com>
	* @description contains statis reusable method for handling ASKHR Case operations
	*/
public without sharing class ASKHR_CaseService
{
    private static ASKHR_Communities_User__c communitiesUserSettings = ASKHR_Communities_User__c.getInstance(System.Userinfo.getProfileId());
	private static List<CaseTeamTemplate> caseTeamTemplates = [select Id,Name from CaseTeamTemplate];    
    /** 
     * @description gets the Contact Id of the logged in User if the User is a Employee Commmunities User    
     * @return contact Id of the Logged in Community User
     */
    public static Id getContactForCommunitiesUser(){
        try{
            Contact con = [select Id from contact where User__c =: System.Userinfo.getUserId()];
            return con.Id;
        }catch(Exception e){
            return null;
        }
    }
    
    /**
    * @description this method gets map of Case Team Roles by name
    * @return Map<String, Id> of caseTeamRoles
    */
    public static Map<String,Id> getCaseTeamRolesByName(){
        Map<String, Id> caseTeamRoles = new Map<String, Id>();
        for (CaseTeamRole ctr : [select Id, Name from CaseTeamRole]) {                  
            caseTeamRoles.put(ctr.name, ctr.Id);
        }
        return caseTeamRoles;
    }
	 
    /**
    * @description this method gets the case Team Template ID 
    * @param caseTeamName Case team name 
    * @return Id Id of the Case team template
    */
    public static Id getPredefinedCaseTeamId(String caseTeamName){
        try{
            for(CaseTeamTemplate ctm : caseTeamTemplates){
				if(ctm.Name.trim().Equals(caseTeamName)){
					return ctm.Id;
				}
			} 
        }catch(Exception e){
            
        }
		return null;
    }
     
    /**
    * @description this method gets the map of cases contact user
    * @param cases 
    * @return Map<Id, Id> 
    */
    public static Map<Id,Id> getUsersForCasesContacts(Map<Id, SObject> cases){
        try{
            
            Map<Id,Id> caseIdsByContactIds = new Map<Id,Id>();
            for (SObject so : cases.values())
            {
                Case c = (Case)so;
                caseIdsByContactIds.put(c.ContactId,c.Id);
            }
                              
            List<Contact> contacts = [select Id,User__c from Contact where Id in :caseIdsByContactIds.keySet()];
            
            Map<Id,Id> userIdsByCaseIds = new Map<Id,Id>();
            for (Contact con: contacts){
                userIdsByCaseIds.put(caseIdsByContactIds.get(con.Id),con.User__c);
            }
            
            return userIdsByCaseIds;
        }
        catch(Exception e){
            return null;
        }
    }
    
     /** 
     * @description this method gets whether the user is community manager or not     
     * @return boolean check the user is community manager from custom setting communitiesusersetting 
    */ 
    public static boolean isCommunitiesManager(){
        if(communitiesUserSettings!=null){
            return communitiesUserSettings.Is_Communities_Manager__c;
        }else{
            return false;
        }   
    }
    /** 
     * @description this method gets whether the user is community user or not     
     * @return boolean check the user is community user from the custom setting communitiesusersetting 
    */ 
    public static boolean isCommunitiesUser(){
        if(communitiesUserSettings!=null){
            return communitiesUserSettings.Is_Communities_User__c;
        }else{
            return false;
        }   
    }
	
     /** 
     * @description this method do the case reassignment for the received list of caseid's and it runs in future     
     * @param caseList receives list of caseid's for reassignment
     */ 
    
    @future 
    public static void triggerCaseAutoAssignmentRule(List<String> caseList){
        List<Case> cases = [select id from Case where id IN :caseList];
        system.debug('@@@: inside future before if : ');
        if(cases!=null && !cases.isEmpty()){
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.assignmentRuleHeader.useDefaultRule = true;
            //dmo.emailHeader.triggerUserEmail = true;
            for(Case cs : cases){
                cs.setOptions(dmo);
            }
            system.debug('@@@: inside future before update : ');
            TriggerUtils.setBypassCaseTrigger();
            update cases;
        }
    }
    
    /** 
     * @description this method is doing the case reassignment for the received list of caseid's
     * @param caseList receives list of caseid's for reassignment
    */ 
    public static void triggerCaseAutoAssignmentRuleNow(List<String> caseList){
        List<Case> cases = [select id from Case where id IN :caseList];
        
        if(cases!=null && !cases.isEmpty()){
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.assignmentRuleHeader.useDefaultRule = true;
            //dmo.emailHeader.triggerUserEmail = true;
            for(Case cs : cases){
                cs.setOptions(dmo);
            }
            TriggerUtils.setBypassCaseTrigger();
            update cases;
        }
    }
    
    /** 
     * @description this method used to Checks if User is already a member of the case team which is the case team role, if so, return the instance,
     * @param Id caseID
     * @param Id teamRoleId
     * @return case team member instance or null
    */ 
    public static CaseTeamMember IsUserAlreadyCaseTeamMember(Id caseID, Id userId, Id teamRoleId)
    {
        CaseTeamMember[] existingCTMs;
        if(teamRoleId != null){
            existingCTMs = [Select Id, MemberId, TeamRoleId, ParentId from 
                                         CaseTeamMember where ParentId = :caseID 
                                         AND  TeamRoleId = :teamRoleId];  
        }else{
            existingCTMs = [Select Id, MemberId, TeamRoleId, ParentId from CaseTeamMember where ParentId = :caseID];             
        }
        
        for(CaseTeamMember ctm :existingCTMs)
        {
            if(userId == null){
                return ctm;
            }else{
                if(ctm.MemberId == userId){
                    System.debug('User ' + userId + ' is already a member of this case team.');
                    return ctm;                          
                }
            }
        }
        return null;            
    }
    
    /** @description this method used to Checks owner is user or queue
     * @param Id userID
     * @return boolean user 
    */ 
    public static boolean IsUserQueue(Id userId){
        return string.valueOf(userId).startsWith('00G');
    }
    //unused code -commented on 18 oct 2016
   /* public static boolean IsUserEmployeeCommunity(Id userId){
        try{
            String userLicense = [Select User_License__c from User where Id=:userId].User_License__c;
            return !userLicense.equalsIgnoreCase('Salesforce');
        }catch(Exception ex){
            return true;
        }
    }*/
    
    /** @description this method used to Check the profile
     * @param Id userID
     * @param string profileName
     * @return boolean profile
    */
    public static boolean isUserProfileEquals(Id userId, String profileName){
        User user = [Select Profile.Name from User where Id = :userId];
        if(user != null && user.Profile.Name != null){
            return user.Profile.Name.equalsIgnoreCase(profileName);
        }else{
            return false;
        }
            
    }
    
   
    /** 
     * @description this method used to Checks if User is already a member of the case team template which is the predefined case team , if so, return the instance,
     * @param Id userId
     * @param Id teamTemplateId
       @param Id teamRoleId
     * @return case team member instance or null
    */ 
    public static CaseTeamTemplateMember IsUserAlreadyCaseTeamTemplateMember(Id userId, Id teamTemplateId, Id teamRoleId)
    {
        CaseTeamTemplateMember[] existingCTMs;
        existingCTMs = [Select MemberId, TeamRoleId, TeamTemplateId from 
                                         CaseTeamTemplateMember where TeamTemplateId = :teamTemplateId 
                                         AND  TeamRoleId = :teamRoleId];  
                
        for(CaseTeamTemplateMember ctm :existingCTMs)
        {
            if(ctm.MemberId == userId){
                    System.debug('User ' + userId + ' is already a member of this predefined case team.');
                    return ctm;                          
            }
            
        }
        return null;            
    }
    
    public static Map<Id, String> getEmployeeCountryMap(List<Case> cases){
        
        Set<Id> employeeIdList = new Set<Id>();
        List<Contact> employeeList = new List<Contact>();
        Map<Id, String> employeeCountryMap = new Map<Id, String>();
        
        for(Case c : cases){
            
            if(c.Employee_of_Record__c != null){
                
                employeeIdList.add(c.Employee_of_Record__c);
            }
        }
        if(employeeIdList != null){
            
            employeeList = [Select Id, Pay_Country__c from Contact where Id in :employeeIdList];
            
        }
        if(employeeList != null){
            for(Contact con :employeeList){
                
                if(con.Pay_Country__c != null){
                    employeeCountryMap.put(con.Id, con.Pay_Country__c);
                }
            }
        }
        
        
        return employeeCountryMap;
    }
}