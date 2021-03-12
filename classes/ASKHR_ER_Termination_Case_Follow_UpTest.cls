/**
* @author Mohamad Ammar Amran <mohamadammar_amran@manulife.com>
* @description Test class for ASKHR_ER_Termination_Case_Follow_Up, 
*			updated 1/11/2016 to reflect changes on AHP-411
*/
@isTest (SeeAllData=true)
private class ASKHR_ER_Termination_Case_Follow_UpTest {

    // make an ER Termination Case
    // Ensure status is set to Created
    // Call Function to test
    // Ensure email count went up
    // 
    
    private static final string ER_TERMINATION_CASE_STATUS = 'Created';
    static testMethod void doRemindOwnerToCloseCaseTest() 
    {
                
        Case erTerminationCase = ASKHR_TestUtility.createERTerminationCase();         
        erTerminationCase = [SELECT Id, Status FROM Case WHERE Id = :erTerminationCase.Id];                    
        
        Test.startTest();
        Integer emailCountBefore = Limits.getEmailInvocations();
        ASKHR_ER_Termination_Case_Follow_Up.RemindOwnerToCloseCase(new List<ID> {erTerminationCase.Id});
        system.assertNotEquals(emailCountBefore, Limits.getEmailInvocations());
        
        //negative test
        erTerminationCase.Status = ER_TERMINATION_CASE_STATUS; //when Case is set to Created, flow will update to Closed
        update erTerminationCase;
        emailCountBefore = Limits.getEmailInvocations();
        ASKHR_ER_Termination_Case_Follow_Up.RemindOwnerToCloseCase(new List<ID> {erTerminationCase.Id});
        system.assertEquals(emailCountBefore, Limits.getEmailInvocations());
       
        Test.stopTest();                
    }
}