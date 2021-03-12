public with sharing class ASKHR_SurveyManagerController {
    private ApexPages.StandardController stdControl;
    public Boolean editCSS;
    
    public Boolean getEditCSS(){
        return editCSS;
    } 
    
    public ASKHR_SurveyManagerController(ApexPages.StandardController stdController){
        this.stdControl = stdController;
        
        List<User> res = [SELECT Profile.PermissionsAuthorApex FROM User WHERE id=:Userinfo.getUserId()];
        User u = res[0];
        this.editCSS = false;
        if(u.Profile.PermissionsAuthorApex){
            this.editCSS = true;
        }
    }
}