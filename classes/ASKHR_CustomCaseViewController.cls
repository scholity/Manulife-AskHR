/**
*@description the test class is located in ASKHR_CommunityHeadControllerTest.doUsrLicense
*   1. This class is to get the value of isRenderedStyle by looking at the user.User_License__c. If it is equal to 'Salesforce', set to false. 
*   2. isRenderedStyle will pass back to ASKHR_CustomCaseView 
*/
public without sharing class ASKHR_CustomCaseViewController {
    public Boolean isRenderedStyle { get; set;} 
    //constructor
    public ASKHR_CustomCaseViewController(){
        try{
            String license = [Select User_License__c from User where Id =:UserInfo.getUserId()].User_License__c;
            isRenderedStyle = !String.isBlank(license) && license.equalsIgnoreCase('Salesforce') ? false : true;
        }catch(Exception ex){ isRenderedStyle = true;
        }
    }
}