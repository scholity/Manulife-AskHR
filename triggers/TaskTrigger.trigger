trigger TaskTrigger on Task (Before Delete)
{
    List<String> profiles = new List<String>();
    List<AskHR_Restrict_Task_Delete__mdt> profileSettings = [Select ProfileId__c from AskHR_Restrict_Task_Delete__mdt];
    
    if(!profileSettings.isEmpty()){
        for(AskHR_Restrict_Task_Delete__mdt setting : profileSettings){
            
            profiles.add(setting.ProfileId__c);
        }
    }
    
    String profileId = UserInfo.getProfileId(); 
    String profileId15 = String.valueOf(profileId).substring(0, 15);
    
    for (Task a : Trigger.old)      
    {            
        if (profiles.contains(profileId15))
        {
            a.addError('You are not allowed to delete this record');
        }
    }          
    
}