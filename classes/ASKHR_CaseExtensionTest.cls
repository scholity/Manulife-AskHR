/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
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
@isTest
public class ASKHR_CaseExtensionTest {


    static testMethod void doCloseTest() {
        /*Case testCase = new Case(External_Contact_Name__c = 'TEST EXTERNAL NAME', 
                                Secondary_Country_of_Reference__c = 'USA', 
                                RecordTypeId=ASKHR_TestUtility.GetRecordTypeID(ASKHR_TestUtility.CASE_RECORD_TYPE_NAME_GENERAL_HR));*/
        Case testCase = new Case(External_Contact_Name__c = 'TEST EXTERNAL NAME', 
                                Secondary_Country_of_Reference__c = 'USA', 
                                RecordTypeId=ASKHR_TestUtility.GetRecordTypeID(ASKHR_Common.CASE_RECORD_TYPE_NAME_GENERAL_HR));
        insert testCase;
        
        List<Case> selectedCases = new List<Case>();
        selectedCases.add(testCase);
        
        PageReference returnPage = new PageReference('/'+testCase.Id);
        
        ApexPages.currentPage().getParameters().put('id', testCase.Id);
        ApexPages.StandardController stdController = new ApexPages.StandardController(testCase);
        
        ASKHR_CaseExtension stdControllerExtension = new ASKHR_CaseExtension(stdController);
        
        List<SelectOption> caseCloseReasons = stdControllerExtension.getCaseCloseReasons();
        System.assert(!caseCloseReasons.isEmpty());
        String caseCloseReason = ((SelectOption)caseCloseReasons.get(0)).getValue();
        
        stdControllerExtension.caseCloseComment = 'TEST CASE CLOSE COMMENT';
        stdControllerExtension.caseCloseReason = caseCloseReason;
        
        PageReference doCloseReturnPage = stdControllerExtension.doCaseClose();
        System.assertEquals(returnPage.getURL(), doCloseReturnPage.getURL());
        
        testCase = [Select Id, status from Case where id = :testCase.id ];
        System.assertEquals('Closed', testCase.status);
        
        CaseComment cc = [Select Id from CaseComment where ParentId = :testCase.Id and CommentBody = 'TEST CASE CLOSE COMMENT'];
        System.assertNotEquals(null, cc);
        
        ApexPages.currentPage().getParameters().put('retURL', testCase.Id);
        
        doCloseReturnPage = stdControllerExtension.doCaseClose();
        System.assertEquals(null, doCloseReturnPage);
        
    }
   

    static testMethod void doAcceptTest() {
        List<Case> selectedCases = new List<Case>();

        /*Case testCase = new Case(Status = 'New', ownerId = Userinfo.getUserId(), 
                                    Secondary_Country_of_Reference__c = 'USA', 
                                    External_Contact_Name__c = 'TEST EXTERNAL NAME', 
                                    RecordTypeId=ASKHR_TestUtility.GetRecordTypeID(ASKHR_TestUtility.CASE_RECORD_TYPE_NAME_GENERAL_HR));*/
        
        Case testCase = new Case(Status = 'New', ownerId = Userinfo.getUserId(), 
                                    Secondary_Country_of_Reference__c = 'USA', 
                                    External_Contact_Name__c = 'TEST EXTERNAL NAME', 
                                    RecordTypeId=ASKHR_TestUtility.GetRecordTypeID(ASKHR_Common.CASE_RECORD_TYPE_NAME_GENERAL_HR));
                                    
        selectedCases.add(testCase);
        insert selectedCases;       
        
        PageReference returnPage = new PageReference('/'+testCase.Id);
        
        ApexPages.currentPage().getParameters().put('retURL', testCase.Id);
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(selectedCases);
        stdSetController.setSelected(selectedCases);
        ASKHR_CaseExtension stdSetControllerExtension = new ASKHR_CaseExtension(stdSetController);
        
        PageReference doAcceptReturnPage = stdSetControllerExtension.doAccept();
        //System.assertEquals(returnPage.getURL(), doAcceptReturnPage.getURL());      
    }    



 //   static testMethod void doERTerminationAcceptTest() {
//      List<Case> selectedCases = new List<Case>();
//
//      // assumes Employee Relations Queue is present.
//      List<Group> EmployeeRelationsQueueID = [SELECT Id FROM Group WHERE Name = 'Employee Relations' and Type = 'Queue' LIMIT 1];
//      
//      Case testCase = new Case(Status = 'New', ownerId =  EmployeeRelationsQueueID[0].Id, 
//                  ParentId = createERCase().Id,
//                  RecordTypeId=rtMap.get(CASE_RECORD_TYPE_NAME_ER_TERMINATION).getRecordTypeId());
//      
//      insert testCase;        
//      
//      testCase = [SELECT Id, OwnerId, Owner.Type FROM Case WHERE Id = :testCase.Id];
//  
//      System.assertEquals(EmployeeRelationsQueueID[0].Id, testCase.ownerId);
//      System.assertEquals('Queue', testCase.Owner.type);
//      
//      selectedCases.add(testCase);
//      ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(selectedCases);
//      stdSetController.setSelected(selectedCases);
//      ASKHR_CaseExtension stdSetControllerExtension = new ASKHR_CaseExtension(stdSetController);
//      
//      Test.startTest();
//      PageReference doAcceptReturnPage = stdSetControllerExtension.doAccept();
//      Test.stopTest();
//      
//      // Get Case, ensure it's status has been changed to In Progress.
//      Case updatedCase = [Select Id, Status From Case WHERE Id = :testCase.Id];
//      System.assertEquals('In Progress', updatedCase.Status);     
 //   }       
    
    static testMethod void doAddActionTest()
    {
        // Action - Written Warning issued.
        
        // Create an ER Request
        // Save it
        // Load it through controller, and run Add Action function
        // ensure action was added.
        Case ERCase = ASKHR_TestUtility.createERCase();

        // create standard controller
        ApexPages.StandardController stdController = new ApexPages.StandardController(ERCase);
        ASKHR_CaseExtension stdControllerExtension = new ASKHR_CaseExtension(stdController);
        
        ERCase.Step_Taken__c = 'Written Warning issued';
        ERCase.Date_Time_of_Action__c = DateTime.Now();
        
        Test.startTest();
        
        stdControllerExtension.AddActionStep();
        
        Test.stopTest();
        
        List<Action_Step__c> actions = [SELECT ID, Case__c FROM Action_Step__c WHERE Case__c = :ERCase.Id];
        System.assertEquals(1, actions.size());
    }

    static testMethod void doAddActionTest_AddMultipleSteps()
    {
        // Action - Written Warning issued.
        
        // Create an ER Request
        // Save it
        // Load it through controller, and run Add Action function
        // ensure action was added.
        Case ERCase = ASKHR_TestUtility.createERCase();

        // create standard controller
        ApexPages.StandardController stdController = new ApexPages.StandardController(ERCase);
        ASKHR_CaseExtension stdControllerExtension = new ASKHR_CaseExtension(stdController);
        
        ERCase.Step_Taken__c = 'Written Warning issued';
        ERCase.Date_Time_of_Action__c = DateTime.Now();
        List<Action_Step__c> actions;
        
        Test.startTest();
        
        stdControllerExtension.AddActionStep();                     

        ERCase.Step_Taken__c = 'Written Warning issued';
        ERCase.Date_Time_of_Action__c = DateTime.Now();
                
        stdControllerExtension.AddActionStep();
        
        Test.stopTest();
        
        actions = [SELECT ID, Case__c FROM Action_Step__c WHERE Case__c = :ERCase.Id];
        System.assertEquals(2, actions.size());     
    }
        
     static testMethod void doAddActionTest_StepRequired()
    {
        // Action - Written Warning issued.
        
        // Create an ER Request
        // Save it
        // Load it through controller, and run Add Action function
        // ensure action was not added.
        Case ERCase = ASKHR_TestUtility.createERCase();

        // create standard controller
        ApexPages.StandardController stdController = new ApexPages.StandardController(ERCase);
        ASKHR_CaseExtension stdControllerExtension = new ASKHR_CaseExtension(stdController);
        
        // Ensure step validation is working.
        //ERCase.Step_Taken__c = 'Written Warning issued';
        ERCase.Date_Time_of_Action__c = DateTime.Now();
        
        Test.startTest();
        
        stdControllerExtension.AddActionStep();
        
        Test.stopTest();
        
        List<Action_Step__c> actions = [SELECT ID, Case__c FROM Action_Step__c WHERE Case__c = :ERCase.Id];
        System.assertEquals(0, actions.size());
    }
   
    static testMethod void doAddActionTest_DateRequired()
    {
        // Action - Written Warning issued.
        
        // Create an ER Request
        // Save it
        // Load it through controller, and run Add Action function
        // ensure action was not added.
        Case ERCase = ASKHR_TestUtility.createERCase();

        // create standard controller
        ApexPages.StandardController stdController = new ApexPages.StandardController(ERCase);
        ASKHR_CaseExtension stdControllerExtension = new ASKHR_CaseExtension(stdController);
        
        // Ensure step validation is working.
        ERCase.Step_Taken__c = 'Written Warning issued';
        //ERCase.Date_Time_of_Action__c = DateTime.Now();
        
        Test.startTest();
        
        stdControllerExtension.AddActionStep();
        
        Test.stopTest();
        
        List<Action_Step__c> actions = [SELECT ID, Case__c FROM Action_Step__c WHERE Case__c = :ERCase.Id];
        System.assertEquals(0, actions.size());
    } 
    
    static testMethod void doAddActionTest_DateInFuture()
    {
        // Action - Written Warning issued.
        
        // Create an ER Request
        // Save it
        // Load it through controller, and run Add Action function
        // ensure action was not added.
        Case ERCase = ASKHR_TestUtility.createERCase();

        // create standard controller
        ApexPages.StandardController stdController = new ApexPages.StandardController(ERCase);
        ASKHR_CaseExtension stdControllerExtension = new ASKHR_CaseExtension(stdController);
        
        // Ensure step validation is working.
        ERCase.Step_Taken__c = 'Written Warning issued';
        ERCase.Date_Time_of_Action__c = DateTime.Now().AddDays(1);
        
        Test.startTest();
        
        stdControllerExtension.AddActionStep();
        
        Test.stopTest();
        
        List<Action_Step__c> actions = [SELECT ID, Case__c FROM Action_Step__c WHERE Case__c = :ERCase.Id];
        System.assertEquals(0, actions.size());
    } 
    static testMethod void doDismissAlertTest()
    {
        
       /* Case testCase = new Case(Status = 'New', 
                            ownerId = Userinfo.getUserId(), 
                            Secondary_Country_of_Reference__c = 'USA', 
                            External_Contact_Name__c = 'TEST EXTERNAL NAME', 
                            RecordTypeId=ASKHR_TestUtility.GetRecordTypeID(ASKHR_TestUtility.CASE_RECORD_TYPE_NAME_GENERAL_HR));*/
        
        Case testCase = new Case(Status = 'New', 
                            ownerId = Userinfo.getUserId(), 
                            Secondary_Country_of_Reference__c = 'USA', 
                            External_Contact_Name__c = 'TEST EXTERNAL NAME', 
                            RecordTypeId=ASKHR_TestUtility.GetRecordTypeID(ASKHR_Common.CASE_RECORD_TYPE_NAME_GENERAL_HR));
                            
                            
        testCase.Type = 'Workplace Safety';
        testCase.Category__c = 'Workplace Injury';
                
        insert testCase;        
        
        // Pull case back out, ensure Display Alert flag is on.
        Case retrievedCase = [SELECT Id, Display_Alert__c FROM Case WHERE Id = :testCase.Id];
        System.assert(retrievedCase.Display_Alert__c, 'Expecting Display Alert to be true.');
        
        // create standard controller
        ApexPages.StandardController stdController = new ApexPages.StandardController(retrievedCase);
        ASKHR_CaseExtension stdControllerExtension = new ASKHR_CaseExtension(stdController);
        
        // Dismiss the alert.
        Test.startTest();
        PageReference dismissPage = stdControllerExtension.DismissAlert();
        Test.stopTest();
        
        // ensure case is no longer displaying alert.
        retrievedCase = [SELECT Id, Display_Alert__c FROM Case WHERE Id = :testCase.Id];
        System.assert(retrievedCase.Display_Alert__c == false, 'Expecting Display Alert to be false.');
        
        System.assertEquals(true, dismissPage.getRedirect(), 'Expecting to be redirected to same page.');   
        
    }
    
    static testMethod void doCaseView_EnsureAuditViewEventRecored()
    {
        
        // Create an ER Request
        // Save it
        // Load it through controller, and run Record Audit View
        // ensure audit event was saved.
        Case ERCase = ASKHR_TestUtility.createERCase();

        // create standard controller
        ApexPages.StandardController stdController = new ApexPages.StandardController(ERCase);
        ASKHR_CaseExtension stdControllerExtension = new ASKHR_CaseExtension(stdController);
                
        Test.startTest();
        
        stdControllerExtension.RecordCaseViewAuditEvent();
        
        Test.stopTest();
        
        Case_Audit_Event__c cae = [SELECT Id, User__c, Parent_Case__c, Event_Date_Time__c FROM Case_Audit_Event__c WHERE Parent_Case__c = :ERCase.Id AND User__c = :Userinfo.getUserId()];      
        System.assert(cae != null, 'Expecting Case Audit Event to exist.');
    }
  
}