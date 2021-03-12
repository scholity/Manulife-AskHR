public class global_DivisionCodes {

    
    public static string GetMFCDivision(string externalName)
    {
        string mfcDivision = '';
        Division_Codes__c division = FindDivisionCodeByExternalName(externalName);
        
        if(division != null)
        {
            mfcDivision = division.MFC_Division__c;
        }       
        
        return mfcDivision;
    }
    
    private static Division_Codes__c FindDivisionCodeByExternalName(string externalName)
    {
        // Find setting whose external division code matches.
        Map<String, Division_Codes__c> codes = Division_Codes__c.getAll();
        Division_Codes__c div;
        
        System.debug('Search for Division Code using External Name: ' + externalName);
        for(Division_Codes__c division :codes.values())
        {
            List<string> externalNames = division.External_Names__c.split(';');
            for(string e :externalNames)
            {
                if(e.trim().equalsIgnoreCase(externalName))
                //if(e.trim().equals(externalName))
                {
                    System.debug('Found Division Code: ' + division.Name);
                    return division;                    
                }
            }
           
        }
        return null;
    }
}