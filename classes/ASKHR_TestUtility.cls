/**
 	*@author
	*@description This class contains unit tests for validating the behavior of Apex classes
 	* and triggers. Unit tests are class methods that verify whether a particular piece
 	* of code is working properly. Unit test methods take no arguments,
 	* commit no data to the database, and are flagged with the testMethod
 	* keyword in the method definition.
 	*
 	* All test methods in an organization are executed whenever Apex code is deployed
 	* to a production organization to confirm correctness, ensure code
 	* coverage, and prevent regressions. All Apex classes are
 	* required to have at least 75% code coverage in order to be deployed
 	* to a production organization. In addition, all triggers must have some code coverage.
 	* 
 	* The @isTest class annotation indicates this class only contains test
 	* methods. Classes defined with the @isTest annotation do not count against
 	* the organization size limit for all Apex scripts.
 	*
 	* See the Apex Language Reference for more information about Testing and Code Coverage.
	*/ 	

	/*History:       
	*@author Kavitha     
	*@date  	19 Oct 2016	  
	*@description Removed duplicated method for creating Test Manager Account createSFAccount()
	*Moved public static String CASE_RECORD_TYPE_NAME declarations for the recordtypes under ASKHR_Common class
	*/

	@isTest
	public class ASKHR_TestUtility {

    public static Map<String, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Case.getRecordTypeInfosByName();
    private static Map<String, Schema.RecordTypeInfo> rtMapContact = Schema.SObjectType.Contact.getRecordTypeInfosByName();
    /** 
     * @Description Retrieves RecordType id based on recordtype name      
     * @return Id of recordtype name
     */
    public static Id GetRecordTypeID(String RecordTypeName)
    {
        return rtMap.get(RecordTypeName).getRecordTypeId();
    }
    
     /** 
     * @Description gets or creates account named Manulife      
     * @return new or existing account 
     */

    static Account createAccount()
    {
        List<Account> newAccounts = [SELECT name, id FROM Account WHERE Name = 'Manulife' LIMIT 1 ];
        if (newAccounts.size() == 0)
        {
            Account newAccount = new Account();
            newAccount.Name = 'Manulife';
            newAccounts.add(newAccount);
            insert newAccounts;
        }       
        return newAccounts[0];          
    }
    
    /** 
     * @Description creates test contact      
     * @return new contact 
     */
    public static Contact createContact()
    {
        Contact newContact = new Contact();
        newContact.FirstName = 'Test';
        newContact.LastName = 'Contact';
        newContact.Employee_Number__c = '12' + system.currentTimeMillis();
        newContact.AccountId = createAccount().Id;
        newContact.Email = newContact.Employee_Number__c + '@manulife.com'; 
        newContact.RecordTypeId= rtMapContact.get(ASKHR_Common.ASKHR_RECORDTYPE).getRecordTypeId();
        insert newContact;
        return newContact;        
    }
    
    /** 
     * @Description creates manager account      
     * @return new or existing account 
     */
    static Account createManagerAccount()
    {
        List<Account> mgrAccounts = [SELECT name, id FROM Account WHERE Name = 'Test Manager Account' LIMIT 1 ];
        if (mgrAccounts.size() == 0)
        {
            Account mgrAccount = new Account();
            mgrAccount.Name = 'Test Manager Account';
            mgrAccounts.add(mgrAccount);
            insert mgrAccounts;
        }       
        return mgrAccounts[0];
    }

    /** 
     * @Description creates manager contact      
     * @return returns new manager contact 
     */
    public static Contact createManagerContact()
    {
        Contact manager = new Contact();
        manager.FirstName = 'Manager';
        manager.LastName = 'Test';
        manager.Employee_Number__c = '20000';
        manager.Employee_Status__c = 'Active';
        manager.Email = 'test@manulife.com';
        manager.AccountId = createManagerAccount().Id;
        manager.RecordTypeId= rtMapContact.get(ASKHR_Common.ASKHR_RECORDTYPE).getRecordTypeId();
        insert manager;
        return manager;
    }
   
    /** 
     * @Description creates ER contact      
     * @return new ER contact 
     */
    
    public static Contact createERContact()
    {
        Contact newContact = new Contact();
        newContact.FirstName = 'ER';
        newContact.LastName = 'ER Contact';
        newContact.Employee_Number__c = '6789'+ system.currentTimeMillis();
        newContact.Email = 'someaddress@email.com';
        newContact.AccountId = createAccount().Id;      
        newContact.RecordTypeId= rtMapContact.get(ASKHR_Common.ASKHR_RECORDTYPE).getRecordTypeId();
        insert newContact;
        return newContact;        
    }   

    /** 
     * @Description creates ER Termination contact      
     * @return returns ER Termination contact 
     */
    public static Case createERTerminationCase()
    {
        Case erTerminationCase = new Case(RecordTypeId=rtMap.get(ASKHR_Common.CASE_RECORD_TYPE_NAME_ER_TERMINATION).getRecordTypeId(),         
                                    Subject = 'TEST ER TERMINATION CASE',
                                    Status = 'New',
                                    Geography__c = 'Canada',
                                    Request_Type__c = 'Estimate',
                                    Termination_Type__c = 'Performance',
                                    ParentId = createERCase().Id,
                                    Termination_Date__c = Date.Today(),
                                    OwnerId =  Userinfo.getUserId());
        
        erTerminationCase.ContactId = createERContact().Id;
        insert erTerminationCase;
        return erTerminationCase;                                    
    }

    /** 
     * @Description creates ER case      
     * @return new ER case 
     */
    public static Case createERCase()
    {
        Contact c = createERContact();
        Case erCase = new Case(RecordTypeId=rtMap.get(ASKHR_Common.CASE_RECORD_TYPE_NAME_ER_CASE).getRecordTypeId(),        
            Subject = 'TEST ER CASE',
            Status = 'New',
            OwnerId =  Userinfo.getUserId(),
            Priority = 'Medium',
            Origin = 'Email',
            Type = 'Performance',
            Category__c = 'Absenteeism',            
            Contact_Relationship__c = 'Employee',
            Employee_of_Record__c = c.Id );
        erCase.ContactId = c.Id;
        insert erCase;
        return erCase;
    }
    
    /** 
     * @Description creates General HR Case      
     * @return new General HR Case  
     */
    public static Case createGeneralHRCase()
    { 
        Contact c = createContact();
        Case ghrCase = new Case(Type='Enhancement', 
                                Related_System__c = 'Other', 
                                Related_Case_Number__c = 'Not Applicable',
                                Origin = 'Ask HR',
                                Secondary_Country_of_Reference__c = 'CAN',
                                RecordTypeId=rtMap.get(ASKHR_Common.CASE_RECORD_TYPE_NAME_GENERAL_HR).getRecordTypeId());
        
        ghrCase.ContactId = c.Id;
        insert ghrCase;
        return ghrCase;
    }
    
    /** 
     * @Description creates function case     
     * @return new function case 
     */
     public static Case createFunctionCase()
    { 
        Contact c = createContact();
       Case functionCase = new Case(
                                Type = 'Vendor Enhancement', 
                                Related_System__c = 'Salesforce',
                                Origin = 'Other', 
                                Function__c = 'Security',
                                Requesting_Area__c = 'Non HR',
                                RecordTypeId=rtMap.get(ASKHR_Common.CASE_RECORD_TYPE_NAME_FUNCTION).getRecordTypeId());
       
        functionCase.ContactId = c.Id;
        insert functionCase;
        return functionCase;
    }

    /** 
     * @Description creates Custom Reschedule Settings      
     * @param  integer waitTime
     * @param  integer rescheduleThreshold
     * @return  Contact_Reports_To_Resync_Wait_Time__c 
     */
    public static Contact_Reports_To_Resync_Wait_Time__c CreateCustomRescheduleSettings(integer waitTime, integer rescheduleThreshold)
    {

        if(Contact_Reports_To_Resync_Wait_Time__c.getInstance('Default') == null)
        {
            insert new Contact_Reports_To_Resync_Wait_Time__c(Name='Default', Resync_Wait_Time__c=waitTime, Reschedule_Threshold_Time__c = rescheduleThreshold);
        }
        else
        {
            Contact_Reports_To_Resync_Wait_Time__c setting = Contact_Reports_To_Resync_Wait_Time__c.getInstance('Default');
            setting.Resync_Wait_Time__c = waitTime;
            setting.Reschedule_Threshold_Time__c = rescheduleThreshold;
            update setting;             
        }   
        return  Contact_Reports_To_Resync_Wait_Time__c.getInstance('Default');      
    }   
    
}