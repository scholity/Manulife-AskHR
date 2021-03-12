//This class provides logic for inbound just-in-time provisioning of single sign-on users in your Salesforce organization.
global class UserActivationHandler implements Auth.SamlJitHandler {
  private class JitException extends Exception{}
  
  private void handleUser(boolean create, User u, Map<String, String> attributes,
    String federationIdentifier, boolean isStandard) {

    System.Debug('#### Attributes that are passed: '+attributes);
    System.Debug('#### Checking if User.IsActive has been sent');
    if(attributes.containsKey('User.IsActive')) {
      System.Debug('#### User.IsActive sent!!!');
      String IsActiveVal = attributes.get('User.IsActive');
      u.IsActive = '1'.equals(IsActiveVal) || Boolean.valueOf(IsActiveVal);
    }
        
	
        if(checkForTerminatedContact(u.id)){
            
            throw new JitException('Employee Status is Terminated');
        }
        else if(!create) {
           update(u);
    }
  }

  private void handleJit(boolean create, User u, Id samlSsoProviderId, Id communityId, Id portalId,
    String federationIdentifier, Map<String, String> attributes, String assertion) {
      // update User - should only be IsActive attribute
      handleUser(create, u, attributes, federationIdentifier, true);
  }

  global User createUser(Id samlSsoProviderId, Id communityId, Id portalId,
    String federationIdentifier, Map<String, String> attributes, String assertion) {
    User u = new User();
    System.Debug('User is :***'+u);
    // don't do anything - can I change this to pass void back instead of a User??
    return u;
  }

  global void updateUser(Id userId, Id samlSsoProviderId, Id communityId, Id portalId,
    String federationIdentifier, Map<String, String> attributes, String assertion) {
    User u = [SELECT Id, FirstName, ContactId FROM User WHERE Id=:userId];
    System.Debug('User is #### before update:'+u);
    handleJit(false, u, samlSsoProviderId, communityId, portalId,
      federationIdentifier, attributes, assertion);
    System.Debug('User is #### after update:'+u);
  }
    // HRSALEFOR-208
    private Boolean checkForTerminatedContact(Id uId){
        
        Set<String> excludeProfile = getExcludedProfiles();
        Boolean isTerminated = false;
        Contact[] con = [Select Id, Employee_Status__c, User__r.Profile.Name 
                         from Contact 
                         where User__c = : uId
                         and User__r.Profile.Name NOT IN :excludeProfile limit 1];
        if(!con.isEmpty()){
            if(con[0].Employee_Status__c == 'Terminated'){
                
                isTerminated = true;
            }
        }
        return isTerminated;
    }
    //HRSALEFOR-208
    private Set<String> getExcludedProfiles(){
        
        Set<String> excludedProfiles = new Set<String>();
        List<ASKHR_UserLicenseSetting__mdt> settings = [Select Profile_Name__c from ASKHR_UserLicenseSetting__mdt where Active__c = true];
        for(ASKHR_UserLicenseSetting__mdt setting : settings){
            
            excludedProfiles.add(setting.Profile_Name__c);
        }
        return excludedProfiles;
    }
}