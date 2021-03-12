@isTest
public class global_DivisionCodesTests {
    
    @testSetup
    public static void AddCustomSettings()
    {
        
        List<Division_Codes__c> codes = new List<Division_Codes__c>();
        codes.add(MakeDivisionCodeSetting('Investments Division', 'ID;Investment Division;Investments', 'Investments'));
        codes.add(MakeDivisionCodeSetting('US Division', 'US;US Division;John Hancock', 'John Hancock'));
        insert codes;               
    }
    
    private static Division_Codes__c MakeDivisionCodeSetting(string Name, string externalNames, string MFCDivision) 
    {
        Division_Codes__c code = new Division_Codes__c();
        code.Name = Name;    
        code.External_Names__c = externalNames;
        code.MFC_Division__c = MFCDivision;
        return code;
    }
    
    public testMethod static void DivisionCodes_GetMFCDivision_DivisionFound()
    {
        Test.startTest();
        System.assertEquals('Investments', global_DivisionCodes.GetMFCDivision('Investment Division'));
        Test.stopTest();
    }

    public testMethod static void DivisionCodes_GetMFCDivision_DivisionNotFound()
    {
        Test.startTest();
        System.assertEquals('', global_DivisionCodes.GetMFCDivision('JH'));
        Test.stopTest();
    }        
        
    
}