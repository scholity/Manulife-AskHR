/**
* @author Mohamad Ammar Amran <mohamadammar_amran@manulife.com>
* @description Unit test class for Action Step Handler
*/
@isTest
private class ASKHR_ActionStepHandlerTest
{
    /**
     * Insert an ActionStep object with latest Action Date.
     */
    static testmethod void testPushActionStep()
    {
        Case testCaseObj = ASKHR_TestUtility.createERCase();
        Action_Step__c action = new Action_Step__c(
                Case__c = testCaseObj.Id,
                Sequence__c = 1,
                Date_Time_of_Action__c = DateTime.now() - 1,
                Step_Taken__c = '001'
        );

        Test.startTest();
        insert action;
        Test.stopTest();

        // Retrieve the Case again, with refreshed values.
        testCaseObj = [
            SELECT Id, Latest_Action_Step__c, Latest_Action_Taken__c, Latest_Action_Date__c
            FROM Case
            WHERE Id = :testCaseObj.Id
        ];

        //Do assertEquals
        system.assert(testCaseObj.Latest_Action_Date__c != null);
        system.assertEquals(1, testCaseObj.Latest_Action_Step__c);
       // system.assertEquals('001', testCaseObj.Latest_Action_Taken__c);
    }

    static testmethod void testUpdateActionStep()
    {
        Case testCaseObj = ASKHR_TestUtility.createERCase();
        Action_Step__c action = new Action_Step__c(
                Case__c = testCaseObj.Id,
                Sequence__c = 1,
                Date_Time_of_Action__c = DateTime.now() - 1,
                Step_Taken__c = '001'
        );

        Test.startTest();
        insert action;
        
        action.Step_Taken__c = '002';
        action.Date_Time_of_Action__c = DateTime.now();
        update action;
        Test.stopTest();

        // Retrieve the Case again, with refreshed values.
        testCaseObj = [
            SELECT Id, Latest_Action_Step__c, Latest_Action_Taken__c, Latest_Action_Date__c
            FROM Case
            WHERE Id = :testCaseObj.Id
        ];

        //Do assertEquals
        system.assert(testCaseObj.Latest_Action_Date__c != null);
        system.assertEquals(1, testCaseObj.Latest_Action_Step__c);
        system.assertEquals('002', testCaseObj.Latest_Action_Taken__c);
    }
    
     static testmethod void testDeleteActionStep()
    {
        Case testCaseObj = ASKHR_TestUtility.createERCase();
        Action_Step__c action = new Action_Step__c(
                Case__c = testCaseObj.Id,	
                Sequence__c = 1,
                Date_Time_of_Action__c = DateTime.now() - 1,
                Step_Taken__c = '001'
        );

        Test.startTest();
        insert action;
        delete action;
        Test.stopTest();

        // Retrieve the Case again, with refreshed values.
        testCaseObj = [
            SELECT Id, Latest_Action_Step__c, Latest_Action_Taken__c, Latest_Action_Date__c
            FROM Case
            WHERE Id = :testCaseObj.Id
        ];

        //Do assertEquals
        system.assert(testCaseObj.Latest_Action_Date__c != null);
    }
    
    static testmethod void testBulkPushActionStep()
    {
        Case testCaseObj = ASKHR_TestUtility.createERCase();
        
        List<Action_Step__c> actions = new List<Action_Step__c>();
        
        for(integer i = 0; i< 3; i++)
        {
            Action_Step__c action = new Action_Step__c(
                    Case__c = testCaseObj.Id,
                    Sequence__c = (i+1),
                    Date_Time_of_Action__c = DateTime.now() - 1,
                    Step_Taken__c = '00' + (i+1)
            );
            actions.add(action);
        }

        Test.startTest();
        insert actions;
        Test.stopTest();

        // Retrieve the Case again, with refreshed values. 
        testCaseObj = [
            SELECT Id, Latest_Action_Step__c, Latest_Action_Taken__c, Latest_Action_Date__c
            FROM Case
            WHERE Id = :testCaseObj.Id
        ];

        //Do assertEquals
        system.assert(testCaseObj.Latest_Action_Date__c != null);
        
        system.assertEquals(3, testCaseObj.Latest_Action_Step__c);
        system.assertEquals('003', testCaseObj.Latest_Action_Taken__c);
    }
}