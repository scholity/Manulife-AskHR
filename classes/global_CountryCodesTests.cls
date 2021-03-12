@isTest
public class global_CountryCodesTests {

    @testSetup
    public static void AddCustomSettings()
    {
        
        List<Country_Codes__c> codes = new List<Country_Codes__c>();
        codes.add(MakeCountryCodeSetting('Canada', 'CA', 'CAN;Canada;CA','Canada','Canada'));
        codes.add(MakeCountryCodeSetting('USA', 'US', 'USA;United States;US','United States of America','United States'));
        insert codes;               
    }
    
    private static Country_Codes__c MakeCountryCodeSetting(string Name, string countryCode2, string externalNames, string fullName, string MFCCountry) 
    {
        Country_Codes__c code = new Country_Codes__c();
        code.Name = Name;
        code.Country_Code_2__c = countryCode2;
        code.External_Names__c = externalNames;
        code.Full_Name__c = fullName;
        code.MFC_Country__c = MFCCountry;
        return code;
    }
    
    public testMethod static void CountryCodes_GetMFCCountry_CountryFound()
    {
        Test.startTest();
        System.assertEquals('Canada', global_CountryCodes.GetMFCCountry('Canada'));
        Test.stopTest();
    }

    public testMethod static void CountryCodes_GetMFCCountry_CountryNotFound()
    {
        Test.startTest();
        System.assertEquals('', global_CountryCodes.GetMFCCountry('Cana'));
        Test.stopTest();
    }    

    public testMethod static void CountryCodes_Get2CharacterCountry_CountryFound()
    {
        Test.startTest();
        System.assertEquals('CA', global_CountryCodes.GetTwoCharacterCountry('Canada'));
        Test.stopTest();
    }

    public testMethod static void CountryCodes_Get2CharacterCountry_CountryNotFound()
    {
        Test.startTest();
        System.assertEquals('', global_CountryCodes.GetTwoCharacterCountry('Cana'));
        Test.stopTest();
    }      
}