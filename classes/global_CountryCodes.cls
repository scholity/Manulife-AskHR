public class global_CountryCodes {
    
  public static string GetMFCCountry(string externalName)
    {
        string mfcCountry = '';
        Country_Codes__c country = FindCountryCodeByExternalName(externalName);
        
        if(country != null)
        {
            mfcCountry = country.MFC_Country__c;
        }       
        
        return mfcCountry;
    }

  public static string GetTwoCharacterCountry(string externalName)
    {
        string mfcCountry = '';
        Country_Codes__c country = FindCountryCodeByExternalName(externalName);
        
        if(country != null)
        {
            mfcCountry = country.Country_Code_2__c;
        }       
        
        return mfcCountry;
    }    
    
    private static Country_Codes__c FindCountryCodeByExternalName(string externalName)
    {
        // Find setting whose external country code matches.
        Map<String, Country_Codes__c> codes = Country_Codes__c.getAll();
        Country_Codes__c c;
        
        System.debug('Search for Country Code using External Name: ' + externalName);
        for(Country_Codes__c code :codes.values())
        {
            List<string> externalNames = code.External_Names__c.split(';');
            for(string e :externalNames)
            {
                if(e.trim().equals(externalName))
                {
                    System.debug('Found Country Code: ' + code.Name);
                    return code;                   
                }
            }
           
        }
        return null;
    }
}