public class mfc_UpdateUserAttributes {

    public static void UpdateMFCAttributes(User u)
    {
        UpdateMFCCountry(u);
      //UpdateMFCDivision(u);
    }
    
    public static void UpdateMFCCountry(User u)
    {        
        System.debug('Updating user: ' + u.Id + ' MFC Country code using country ' + u.Country__c);
        u.MFC_Country__c = global_CountryCodes.GetMFCCountry(u.Country__c);
    }
    
    //HRSALEFOR-983
    /*
    public static void UpdateMFCDivision(User u)
    {
        System.debug('Updating user: ' + u.Id + ' MFC Division using division ' + u.Division__c);
       u.MFC_Division__c = global_DivisionCodes.GetMFCDivision(u.Division__c);
    }*/
    
  
}