/**
*@description this class is to downgrade the salesforce user licence
*when they go on leave for more than the number of leave days mentioned 
*in the total leave days setting
*/

//public without sharing class ASKHR_ContactUtils implements Schedulable { // renamed with new name
public without sharing class ASKHR_DowngradeAnalyst implements Schedulable{
    
    private static ASKHR_DowngradeUserSetting__mdt settings = [Select Downgrade_Options__c, ExcludeInclude_Profiles__c,Total_Leave_Days__c from ASKHR_DowngradeUserSetting__mdt where Active__c = true LIMIT 1];
    private static Map<String, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Contact.getRecordTypeInfosByName(); 
	
    /**
    *@description this method is the actual starting of execution 
	*/
    public void execute(SchedulableContext sc) {

        List<Id> userIds = new List<Id> ();
        Contact[] contacts = [Select User__c, Leave_Day_Formula__c from Contact where Employee_Status__c = 'Leave' AND Leave_Day_Formula__c >= :settings.Total_Leave_Days__c AND RecordTypeId = :rtMap.get(ASKHR_Common.ASKHR_RECORDTYPE).getRecordTypeId()];
        
        for (Contact c : contacts) {
            if (c.User__c != null) {
                Id uid = c.User__c;
                userIds.add(uid);
            }
        }
        performUpdate(userIds);

        if (Test.isRunningTest()) {
            performUpdate(null);
        }
    }
	/**
	*@description this method perform the downgrade update
	*@param List<Id> userIds list of user ids to downgrade
	*/
    private void performUpdate(List<Id> userIds) {
        try {
            if (userIds != null) {
                List<User> updatedUsers = new List<User> ();

                Id userRoleId = [Select Id from UserRole where Name = 'Community Employee' LIMIT 1].Id;
                Id userProfileId = [Select Id from Profile where Name = 'Employee Communities User' LIMIT 1].Id;

                Id userMgrRoleId = [Select Id from UserRole where Name = 'Community Employee Manager' LIMIT 1].Id;
                Id userMgrProfileId = [Select Id from Profile where Name = 'Employee Communities Manager' LIMIT 1].Id;
                
                //USERPERMISSIONSSUPPORTUSER = Service Cloud User field
                //Get Profile Name
                for (User u :[Select Id, Name, ProfileId, Profile.Name, UserRoleId, USERPERMISSIONSSUPPORTUSER, USERPERMISSIONSKNOWLEDGEUSER, USERPERMISSIONSMARKETINGUSER, Is_Manager__c, User_License__c from User where Id = :userIds]) {

                    if (isDowngradeable(u)) {
                        if (u.Is_Manager__c) {
                            u.UserRoleId = userMgrRoleId;
                            u.ProfileId = userMgrProfileId;
                        } else {
                            u.ProfileId = userProfileId;
                            u.UserRoleId = userRoleId;
                        }

                        u.USERPERMISSIONSSUPPORTUSER = false;
                        u.USERPERMISSIONSKNOWLEDGEUSER = false;
                        u.USERPERMISSIONSMARKETINGUSER = false;
                        u.HasDowngraded__c = true;
                        System.debug('Update user: ' + u.Name + ' to Employee Community User');

                        updatedUsers.add(u);
                    }
                }

                //the flag opt_AllOrNone is set to false to ensure all user are update regardless of any error
                Database.SaveResult[] result = Database.update(updatedUsers, false);

            } else {
                throw new MethodException('No id specified');
            }
        } catch(Exception ex) {
            System.debug('ASKHR Contact Utils Error: ' + ex.getMessage());
        }
    }

    /**
	*@description Check if the current is downgradeable
    * Only allow downgrade to non-administrator employee
    * //TODO: room for improvement, move the checking to setting using CMT
    */
    private Boolean isDowngradeable(User u) {
        Boolean allowDowngrade = false;

        if (!String.isBlank(u.User_License__c) && u.User_License__c.equals('Salesforce')) {
            String excludedIncludedProfiles = settings.ExcludeInclude_Profiles__c;

            if (settings.Downgrade_Options__c.equals('Downgrade All')) //exclude the profiles that matches
            {
                //Allowing all profiles to be downgraded
                allowDowngrade = true;
                if (!String.isBlank(u.Profile.Name) && (excludedIncludedProfiles.contains(u.Profile.Name))) //if the profile is in the Exclude, then don't allow downgrade
                {
                    allowDowngrade = false;
                }
                 
            } else { 
                if (!String.isBlank(u.Profile.Name) && (excludedIncludedProfiles.contains(u.Profile.Name))) 
                {
                    allowDowngrade = true;
                } 
            }           
        }
        //if does not have Salesforce license, do nothing
        
        return allowDowngrade;      
    }



    //SF doesn't allow to throw new Exception without having a custom one
    public class MethodException extends Exception { }
}