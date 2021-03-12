/**
* @name Class UserHandler
* @description Trigger Handler for the User SObject. This class implements the ITrigger
* interface to help ensure the trigger code is bulkified and all in one place.
*
* History
*	Ammar 5.27.2016: For for JIRA issues AHP-435, AHP-431 and AHP-406
*	Rahul 8.1.2018 : For Pivotal Tracker Story 2165141/157407372
*/

public without sharing class UserHandler implements ITrigger {
    
    private static Map<String, User_Language_Based_Config__c> m_UserLanguageBasedConfigs = new Map<String, User_Language_Based_Config__c> ();
    private static Map<String, User_Country_Code_Based_Config__c> m_UserCountryCodeBasedConfigs = new Map<String, User_Country_Code_Based_Config__c> ();
    private static Map<String, Communities_Profile_Role_Mapping__c> m_CommunitiesProfileRoleMapping = new Map<String, Communities_Profile_Role_Mapping__c> ();
    private static String m_UserProfileName = ''; //to avoid null pointer error
    
    private Map<String, Id> m_PermissionSetIdsByName = new Map<String, Id> (); 
    private List<PermissionSetAssignment> m_PermissionSetAssignmentsToBeDeleted = new List<PermissionSetAssignment> ();
    private Map<Id, List<PermissionSetAssignment>> m_PermissionSetAssignmentsByUserId = new Map<Id, List<PermissionSetAssignment>> ();
    private Map<String, Contact> m_ContactsByEmployeeIds = new Map<String, Contact> ();
    private Map<String, Map<String, String>> m_CountryStateTimeZoneMapping = new Map<String, Map<String, String>> ();
    private List<Contact> m_Contacts = new List<Contact> ();
    private static List<Id> m_UserToReconcile = new List<Id> ();
    private static List<User> m_UserToUpdatePermSets = new List<User> ();
    private static Map<Id, String> m_ProfileIdMapping = new Map<Id, String>();
    private static Map<Id, String> m_RoleIdMapping = new Map<Id, String>();
    
    private static Map<String, Schema.RecordTypeInfo> rtMapContact = Schema.SObjectType.Contact.getRecordTypeInfosByName();
    
    @TestVisible private static Long m_TimeInMilli = system.currentTimeMillis();
    
    // Constructor
    public UserHandler() {
        m_UserLanguageBasedConfigs = ASKHR_UserService.getUserLanguageBasedConfigs();
        m_UserCountryCodeBasedConfigs = ASKHR_UserService.getUserCountryCodeBasedConfigs();
        m_CommunitiesProfileRoleMapping = ASKHR_UserService.getCommunitiesProfileRoleMapping();
        m_CountryStateTimeZoneMapping = ASKHR_UserService.getCountryStateTimeZoneMapping();
        m_ProfileIdMapping = ASKHR_UserService.getProfileIdMapping();
        m_RoleIdMapping = ASKHR_UserService.getRoleIdMapping();
    }
    
    /**
* @Description This method is called prior to execution of a BEFORE trigger. Use this to cache
* any data required into maps prior execution of the trigger.
*/
    public void bulkBefore() {
        m_UserProfileName = [Select Id, Name from Profile where Id = :System.Userinfo.getProfileId()].Name;
    }
    
    /**
* @description This method is called prior to execution of a AFTER trigger. Use this to cache
* any data required into maps prior execution of the trigger.
*/
    public void bulkAfter() {
        m_PermissionSetIdsByName = ASKHR_UserService.getPermissionSetIdsByName();
        if (Trigger.isUpdate) {
            m_PermissionSetAssignmentsByUserId = ASKHR_UserService.getPermissionSetAssignmentsByUserIds(Trigger.newMap.keySet());
        }
        
        /* if (Trigger.isInsert) {
            m_ContactsByEmployeeIds = ASKHR_UserService.getContactsByEmployeeIds(Trigger.new);
        }*/
        m_ContactsByEmployeeIds = ASKHR_UserService.getContactsByEmployeeIds(Trigger.new);
	
    }
    
    /**
* @description This method is called prior to insertion 
*/
    public void beforeInsert(SObject so)
    {
        User usr = (User) so;
        if (m_UserProfileName.equals(ASKHR_Common.SYSTEM_INTEGRATION_PROFILE_NAME) || Test.isRunningTest()) {
            User_Language_Based_Config__c userLanguageBasedConfig = m_UserLanguageBasedConfigs.get(usr.LanguageLocaleKey);
            if (userLanguageBasedConfig == null) {
                usr.LanguageLocaleKey = ASKHR_Common.DEFAULT_LANGUAGE_LOCALE_KEY;
                userLanguageBasedConfig = m_UserLanguageBasedConfigs.get(ASKHR_Common.DEFAULT_LANGUAGE_LOCALE_KEY);
            }
            
            // Changed to Country from Pay Country
            User_Country_Code_Based_Config__c userCountryCodeBasedConfig = m_UserCountryCodeBasedConfigs.get(usr.Country__c);
            //To Do: Check if Country to be inserted is in the CountryCodeBaseConfig table - if not exception will be thrown
            //To Do: Could be because Country__c is blank or Country__c doesn't match a value in the Custom Setting
            if (userCountryCodeBasedConfig == null) {
                // Use Country to set config default - used below to set LocalSidKey....
                userCountryCodeBasedConfig = m_UserCountryCodeBasedConfigs.get(ASKHR_Common.DEFAULT_COUNTRY);
            }
            
            // Set value for Pay Country so that HR Case won't have issues
            if (usr.Pay_Country__c == null && usr.Country != null) {
                usr.Pay_Country__c = usr.Country;
            }
            
            if (usr.FirstName != null) {
                usr.Alias = usr.FirstName.left(1) + usr.LastName.left(4);
                usr.CommunityNickname = usr.Employee_ID__c.left(10) + '.' + usr.FirstName.left(9) + '.' + usr.LastName.left(19);
            } else {
                usr.Alias = usr.LastName.left(4);
                usr.CommunityNickname = usr.Employee_ID__c.left(10) + '.' + usr.LastName.left(29);
                
            }
            
            Communities_Profile_Role_Mapping__c communitiesProfileRoleMapping = m_CommunitiesProfileRoleMapping.get(usr.profileId);
            if (communitiesProfileRoleMapping != null) {
                usr.UserRoleId = communitiesProfileRoleMapping.Role_ID__c;
            }
            
            usr.Username = usr.Employee_ID__c + '.' + m_TimeInMilli + '.' + usr.Email;
            usr.EmailEncodingKey = userLanguageBasedConfig.EmailEncodingKey__c;
            usr.LocaleSidKey = userCountryCodeBasedConfig.LocaleSidKey__c;
            usr.FederationIdentifier = usr.Employee_ID__c;
            
            //Use Country here to set user.TimeZoneSidKey
            //Map<String,String> stateTimeZoneMapping = m_CountryStateTimeZoneMapping.get(usr.Pay_Country__c);
            Map<String, String> stateTimeZoneMapping = m_CountryStateTimeZoneMapping.get(usr.Country__c);
            String timeZone = ASKHR_Common.DEFAULT_TIMEZONE;
            
            if (stateTimeZoneMapping != null) {
                String tempTimeZone = stateTimeZoneMapping.get('ALL');
                if (tempTimeZone == null) {
                    tempTimeZone = stateTimeZoneMapping.get(usr.State__c);
                }
                if (tempTimeZone != null) {
                    timeZone = tempTimeZone;
                }
            }
            usr.TimeZoneSidKey = timeZone;
        }	
        // Update MFC Attributes.
        mfc_UpdateUserAttributes.UpdateMFCAttributes(usr);
    }
    /**
* @description This method is called prior to updation 
* @param oldSo SObject
* @param so SObject
*/
    public void beforeUpdate(SObject oldSo, SObject so)
    {
        User oldUser = (User) oldSo;
        User newUser = (User) so;
        
        if ((m_UserProfileName.equals(ASKHR_Common.SYSTEM_INTEGRATION_PROFILE_NAME) || Test.isRunningTest()) && newUser.ProfileId != oldUser.ProfileId) {
            Communities_Profile_Role_Mapping__c oldCommunitiesProfileRoleMapping = m_CommunitiesProfileRoleMapping.get(oldUser.profileId);
            if (oldCommunitiesProfileRoleMapping == null) {
                newUser.ProfileId = oldUser.ProfileId;
            } else {
                Communities_Profile_Role_Mapping__c newCommunitiesProfileRoleMapping = m_CommunitiesProfileRoleMapping.get(newUser.profileId);
                if (newCommunitiesProfileRoleMapping != null) {
                    newUser.UserRoleId = newCommunitiesProfileRoleMapping.Role_ID__c;
                }
            }
        }
        
        User_Language_Based_Config__c userLanguageBasedConfig = m_UserLanguageBasedConfigs.get(newUser.LanguageLocaleKey);
        if (userLanguageBasedConfig == null) {
            newUser.LanguageLocaleKey = ASKHR_Common.DEFAULT_LANGUAGE_LOCALE_KEY;
            userLanguageBasedConfig = m_UserLanguageBasedConfigs.get(ASKHR_Common.DEFAULT_LANGUAGE_LOCALE_KEY);
        }
        
        //Use Country to set user variables
        //User_Country_Code_Based_Config__c userCountryCodeBasedConfig = m_UserCountryCodeBasedConfigs.get(newUser.Pay_Country__c);
        User_Country_Code_Based_Config__c userCountryCodeBasedConfig = m_UserCountryCodeBasedConfigs.get(newUser.Country__c);
        if (userCountryCodeBasedConfig == null) {
            //Ok to have a blank Pay_Country__c
            //newUser.Pay_Country__c = DEFAULT_PAY_COUNTRY;
            //Get CountryCodeBasedConfig using Country
            userCountryCodeBasedConfig = m_UserCountryCodeBasedConfigs.get(ASKHR_Common.DEFAULT_COUNTRY);
        }
        
        if (newUser.LanguageLocaleKey != oldUser.LanguageLocaleKey) {
            newUser.EmailEncodingKey = userLanguageBasedConfig.EmailEncodingKey__c;
        }
        
        // Use Country to set new LocalSidKey
        //if (newUser.Pay_Country__c!=oldUser.Pay_Country__c){
        if (newUser.Country__c != oldUser.Country__c) {
            newUser.LocaleSidKey = userCountryCodeBasedConfig.LocaleSidKey__c;
        }
        
        //Map field based on Country__c
        //Map<String,String> stateTimeZoneMapping = m_CountryStateTimeZoneMapping.get(newUser.Pay_Country__c);
        Map<String, String> stateTimeZoneMapping = m_CountryStateTimeZoneMapping.get(newUser.Country__c);
        String timeZone = ASKHR_Common.DEFAULT_TIMEZONE;
        
        if (stateTimeZoneMapping != null) {
            String tempTimeZone = stateTimeZoneMapping.get('ALL');
            if (tempTimeZone == null) {
                tempTimeZone = stateTimeZoneMapping.get(newUser.State__c);
            }
            if (tempTimeZone != null) {
                timeZone = tempTimeZone;
            }
        }
        newUser.TimeZoneSidKey = timeZone;
        
        if (oldUser.Country__c <> newUser.Country__c || (newUser.MFC_Country__c == null || newUser.MFC_Country__c == ''))
        {
            // Update MFC Country.
            mfc_UpdateUserAttributes.UpdateMFCCountry(newUser);
        }
        
        /*
        if (oldUser.Division__c <> newUser.Division__c || (newUser.MFC_Division__c == null || newUser.MFC_Division__c == ''))
        {
            // Update MFC Division.
            mfc_UpdateUserAttributes.UpdateMFCDivision(newUser);
        }*/
    }
    /**
* @description This method is called prior to deletion
* @param so SObject
*/
    public void beforeDelete(SObject so)
    {
    }
    
    /**
* @description This method is called after insertion 
* @param so SObject
*/
    public void afterInsert(SObject so)
    {
        User usr = (User) so;
        System.debug('afterInsert');
        
        if (usr.IsActive) {
            if (m_UserProfileName.equals(ASKHR_Common.SYSTEM_INTEGRATION_PROFILE_NAME) || Test.isRunningTest()) {
                
                // Don't set permission if Pay Country is null 
                if (usr.Pay_Country__c != null) {
                    System.debug('Assign new permission for new user based on Pay Country');
                    m_UserToUpdatePermSets.add(usr);
                }
                
            }
            
            ASKHR_UserService.addUserToPredefineCaseTeam(usr, m_RoleIdMapping.get(usr.UserRoleId));
        }
        
        Contact con = m_ContactsByEmployeeIds.get(usr.Employee_ID__c);
        if (con == null) {
            con = new Contact();
            con.User__c = usr.Id;
            con.FirstName = usr.FirstName;
            con.LastName = usr.LastName;
            con.Email = usr.Email;
            con.Title = usr.Title;
            con.Employee_Number__c = usr.Employee_ID__c;
            con.Language__c = m_UserLanguageBasedConfigs.get(usr.LanguageLocaleKey).Language__c;
            con.Pay_Country__c = usr.Pay_Country__c;
            con.Country__c = usr.Country__c;
            con.RecordTypeId = rtMapContact.get(ASKHR_Common.ASKHR_RECORDTYPE).getRecordTypeId();
            m_Contacts.add(con);
        } else {
            con.User__c = usr.Id;
            con.RecordTypeId = rtMapContact.get(ASKHR_Common.ASKHR_RECORDTYPE).getRecordTypeId();
            m_Contacts.add(con);
        }
    }
    /**
* @description This method is called after updation 
* @param so SObject
*/
    public void afterUpdate(SObject oldSo, SObject so)
    {
        User oldUser = (User) oldSo;
        User newUser = (User) so;
        system.debug('After update');
        if (newUser.IsActive) {
            // Add new permission when pay country change only if system integration is running this
            if (m_UserProfileName.equals(ASKHR_Common.SYSTEM_INTEGRATION_PROFILE_NAME) || Test.isRunningTest()) {
                if (newUser.Pay_Country__c != oldUser.Pay_Country__c) {
                    System.debug('afterUpdate value of Pay Country newUser Pay Country: ' + newUser.Pay_Country__c + ' oldUser Pay Country ' + oldUser.Pay_Country__c);
                    
                    if (newUser.Pay_Country__c != Null) {
                        m_UserToUpdatePermSets.add(newUser);
                    }
                    
                    if (oldUser.Pay_Country__c != Null) {
                        System.debug('afterUpdate: Building permission set to be deleted now....');
                        List<PermissionSetAssignment> psasForUser = m_PermissionSetAssignmentsByUserId.get(newUser.Id);
                        for (PermissionSetAssignment psaForUser : psasForUser) {
                            User_Country_Code_Based_Config__c userCountryBasedConfig = m_UserCountryCodeBasedConfigs.get(oldUser.Pay_Country__c);
                            if (userCountryBasedConfig != null && psaForUser.PermissionSetId == m_PermissionSetIdsByName.get(userCountryBasedConfig.PermissionSetName__c)) {
                                System.debug('afterUpdate: List of Permission sets to be delete ' + userCountryBasedConfig.PermissionSetName__c);
                                m_PermissionSetAssignmentsToBeDeleted.add(psaForUser);
                            }
                        }
                    }
                } else {
                    //check if the permission set is missing and readd the permission set. 
                    //this will overwrite any manual permission set deletion done by Admin
                    if (oldUser.Pay_Country__c != Null) {
                        m_UserToUpdatePermSets.add(oldUser);
                    }
                }
                
                /* Perform action for user who coming from leave
                *
                */
                if (!oldUser.IsActive) { 
                    if (ASKHR_CaseTeamReassignment.isProfileUpdatable(m_ProfileIdMapping.get(newUser.ProfileId)))
                    {
                        m_UserToReconcile.add(newUser.Id);
                    }
                }
            }
            system.debug('after update');
            ASKHR_UserService.editUserToPredefineCaseTeam(newUser, oldUser, m_RoleIdMapping.get(newUser.UserRoleId), m_RoleIdMapping.get(oldUser.UserRoleId));
        }
        //PT-2165141-157407372 Associate Contact with the User record
        User usr = (User) so;
        Contact con = m_ContactsByEmployeeIds.get(usr.Employee_ID__c);
        if (con != null){
            if(con.User__c != usr.id){
            con.User__c = usr.Id;
            m_Contacts.add(con);
            }
        }
        
    }
    /**
* @description This method is called after deletion 
* @param so SObject
*/
    public void afterDelete(SObject so)
    {
    }
    
    /**
* @description This method is called once all records have been processed by the trigger. Use this 
* method to accomplish any final operations such as creation or updates of other records.
*/
    public void andFinally()
    {
        if (!m_UserToUpdatePermSets.isEmpty()) {
            ASKHR_UserHandlerPermissionSetAssignment.checkAndAddPermissionSet(JSON.serialize(m_UserToUpdatePermSets));
        }
        
        if (!m_PermissionSetAssignmentsToBeDeleted.isEmpty()) {
            ASKHR_UserService.deletePermissionSets(m_PermissionSetAssignmentsToBeDeleted);
        }
        
        if (!m_Contacts.isEmpty()) {
            ASKHR_UserService.upsertContacts(JSON.serialize(m_Contacts));
        }
        
        if(!m_UserToReconcile.isEmpty()){
            ASKHR_CaseTeamReassignment.performCaseTeamUpdate(JSON.serialize(m_UserToReconcile));
        }
    }
    
}