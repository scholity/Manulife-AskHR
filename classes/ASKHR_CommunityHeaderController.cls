/**
 *@description this class is the controller for Visualforce Page ASKHR_CommunityHeader
*/
public without sharing class ASKHR_CommunityHeaderController {

    public string headerDetailsJSON { get; private set; }
    //constructor
    public ASKHR_CommunityHeaderController(){
        CommunityUserDetails cuDetails = getDetails();
        
        headerDetailsJSON = 'jsonCallback(' + JSON.serialize(cuDetails) + ');';
    }
    /**
     *@description gets community user details
	 *@return CommunityDetails of community user
     */
    private CommunityUserDetails getDetails(){
        User communityUser = [Select Name, Id, SmallPhotoUrl, Email, Country__c
                             From User
                             where ID = :UserInfo.getUserId()];
        
        CommunityUserDetails cud = new CommunityUserDetails();
        cud.isLoggedIn = false;
        if(communityUser != null){
            cud.isLoggedIn = true;
            cud.fullName = communityUser.Name;
            cud.Email = communityUser.Email;
            cud.profilePicUrl = communityUser.SmallPhotoUrl;
            cud.callCenterLocation = communityUser.Country__c;
            cud.userId = communityUser.Id;
            cud.profileOverviewUrl = '/_ui/core/userprofile/UserProfilePage?u=' + communityUser.Id + '&tab=sfdc.ProfilePlatformOverview';
            cud.quickLinksLabel = System.Label.ASKHR_ComHeader_QuickLinksLabel;
            cud.callCenterLabel = System.Label.ASKHR_ComHeader_CallCenterLabel;
            cud.logoutLabel = System.Label.ASKHR_ComHeader_LogoutLabel;
            cud.mySettingLabel = System.Label.ASKHR_ComHeader_MySettingLabel;
            cud.globalNumberLabel = System.Label.ASKHR_ComHeader_GlobalNumber;
            cud.callCenters = getCallCenterDetails();
            cud.quickLinks = getQuickLinks();
        }
        
        return cud;
    }
    /**
     *@description gets call center details
	 *@return List<CallCenterDetails> list of call center
	*/
    private List<CallCenterDetails> getCallCenterDetails(){
        
        List<ASKHR_CallCenter__mdt> callCentersMdt = [Select Country_Code__c, Active__c, 
                                                      Internal_Number__c, Int_Num_Remarks__c, 
                                                      Language__c, Live_Phone_Support__c, 
                                                      Location__c, Location_Remarks__c, 
                                                      Remarks__c, TFN_Remarks__c, 
                                                      Toll_Free_Number__c from ASKHR_CallCenter__mdt where Active__c = true];
        
        List<CallCenterDetails> callCenters = new List<CallCenterDetails>();
        
        for(ASKHR_CallCenter__mdt cc : callCentersMdt){
            CallCenterDetails ccd = new CallCenterDetails();
            ccd.location = cc.Location__c;
            ccd.internalNumber = cc.Internal_Number__c;
            ccd.tollFreeNumber = cc.Toll_Free_Number__c;
            ccd.livePhoneSupport = cc.Live_Phone_Support__c;
            ccd.languageSpoken = cc.Language__c;
            ccd.remarks = !String.isBlank(cc.Remarks__c) ? cc.Remarks__c : '';
            ccd.countryCode = cc.Country_Code__c;
            ccd.locRemarks = !String.isBlank(cc.Location_Remarks__c) ? cc.Location_Remarks__c : '' ;
            ccd.tfnRemarks = !String.isBlank(cc.TFN_Remarks__c) ? cc.TFN_Remarks__c : '';
            ccd.inRemarks = !String.isBlank(cc.Int_Num_Remarks__c) ? cc.Int_Num_Remarks__c : '';
             
            callCenters.add(ccd);            
        }
        
        return callCenters;
    }
    /**
     *@description gets quick links
	 *@return List<QuickLink> list of quick links
	*/
    private List<QuickLink> getQuickLinks(){
        List<ASKHR_ComHeader_QuickLink__mdt> qlinks = [Select DeveloperName, MasterLabel, URL__c from ASKHR_ComHeader_QuickLink__mdt where Active__c = true];
        
        List<QuickLink> quickLinks = new List<QuickLink>();
        for(ASKHR_ComHeader_QuickLink__mdt ql : qlinks){
            QuickLink quickLink = new QuickLink();
            quickLink.name = ql.MasterLabel;
            quickLink.url = ql.URL__c;
            quickLinks.add(quickLink);
        }
        
        return quickLinks;
    }
    /**
     * @description class for Community User Details
     */
    public class CommunityUserDetails{
        public string fullName;
        public string email;
        public string userId;
        public boolean isLoggedIn;
        public string profilePicUrl;
        public string callCenterLocation;
        public string profileOverviewUrl;
        
        public string quickLinksLabel;
        public string callCenterLabel;
        public string mySettingLabel;
        public string logoutLabel;
        public string globalNumberLabel;
        public List<CallCenterDetails> callCenters;
        public List<QuickLink> quickLinks;
    }
    /**@description class for Call Center Details
     */
    public class CallCenterDetails{
        public string location;
        public string internalNumber;
        public string tollFreeNumber;
        public string livePhoneSupport;
        public string languageSpoken;
        public string remarks;
        public string locRemarks;
        public string tfnRemarks;
        public string inRemarks;
        public string countryCode;
    }
    /**@description class for quick links
     */
    public class QuickLink{
        public string name;
        public string url;
    }
}