@isTest
public with sharing class ASKHR_ContactUpdaterTest {


    
        
    @IsTest
    public static void ScheduleContactUpdaterJob_JobScheduled()
    {
        
        // Insert a new contact, ensure job is scheduled.
        
        // create the setting.
        Contact_Reports_To_Resync_Wait_Time__c settings = ASKHR_TestUtility.CreateCustomRescheduleSettings(10,1);
        
        Contact employee = ASKHR_TestUtility.createContact();
        Contact manager = ASKHR_TestUtility.createManagerContact();             
        employee.Manager_Employee_Number__c = manager.Employee_Number__c;
        
        Test.startTest();

        update employee;            
        
        Test.stopTest();
        
        // Ensure job is scheduled.
        ASKHR_ContactBulkUpdaterBatchScheduler scheduler = new ASKHR_ContactBulkUpdaterBatchScheduler();
        System.Assert(scheduler.IsScheduled(), 'Batch should be scheduled');
    }
    
    @IsTest
    public static void ScheduleContactUpdaterJobTwice_JobNotRescheduled()
    {
        
        // Insert a new contact, ensure job is scheduled.
        // update another contact, make sure the job did not get rescheduled.
    
        // create the setting.
        Contact_Reports_To_Resync_Wait_Time__c settings = ASKHR_TestUtility.CreateCustomRescheduleSettings(10,1);
        Id jobId;
        
        Contact employee = ASKHR_TestUtility.createContact();
        Contact manager = ASKHR_TestUtility.createManagerContact();             
        employee.Manager_Employee_Number__c = manager.Employee_Number__c;
        
        Test.startTest();

        update employee;            
        
        // Ensure job is scheduled.
        ASKHR_ContactBulkUpdaterBatchScheduler scheduler = new ASKHR_ContactBulkUpdaterBatchScheduler();
        System.Assert(scheduler.IsScheduled(), 'Batch should be scheduled');                
        jobId = scheduler.GetActiveJobIds()[0];
        
        // create another contact.
        Contact employee2 = ASKHR_TestUtility.createContact();
        employee2.Manager_Employee_Number__c = manager.Employee_Number__c;
        update employee2;
        
        scheduler = new ASKHR_ContactBulkUpdaterBatchScheduler();
        System.Assert(scheduler.IsScheduled(), 'Batch should be scheduled');    
        System.AssertEquals(jobId, scheduler.GetActiveJobIds()[0], 'Job ID should not have changed. Not within Threshold yet.');
        Test.stopTest();
    }

    @IsTest
    public static void ScheduleContactUpdaterJobWithinThreshold_JobRescheduled()
    {
        
        // Insert a new contact, ensure job is scheduled.
        // update another contact, make sure the job did not get rescheduled.
    
        // create the setting.
        Contact_Reports_To_Resync_Wait_Time__c settings = ASKHR_TestUtility.CreateCustomRescheduleSettings(5,10);
        Id jobId;
        
        Contact employee = ASKHR_TestUtility.createContact();
        Contact manager = ASKHR_TestUtility.createManagerContact();             
        employee.Manager_Employee_Number__c = manager.Employee_Number__c;
        
        Test.startTest();

        update employee;            
        
        // Ensure job is scheduled.
        ASKHR_ContactBulkUpdaterBatchScheduler scheduler = new ASKHR_ContactBulkUpdaterBatchScheduler();
        System.Assert(scheduler.IsScheduled(), 'Batch should be scheduled');                
        jobId = scheduler.GetActiveJobIds()[0];
        
        // create another contact.
        Contact employee2 = ASKHR_TestUtility.createContact();
        employee2.Manager_Employee_Number__c = manager.Employee_Number__c;
        update employee2;
        
        scheduler = new ASKHR_ContactBulkUpdaterBatchScheduler();
        System.Assert(scheduler.IsScheduled(), 'Batch should be scheduled');    
        System.AssertNotEquals(jobId, scheduler.GetActiveJobIds()[0], 'Job ID should have changed. Within Threshold.');
        Test.stopTest();
    }   

    @IsTest
    public static void ScheduleContactUpdaterJob_ReportingHiearchyUpdated()
    { 
        // create the setting.
        Contact_Reports_To_Resync_Wait_Time__c settings = ASKHR_TestUtility.CreateCustomRescheduleSettings(10,1);
         
        // Insert a few contacts, with their Manager Employee Number updated
        // ensure reports to field gets updated.
        Contact employee = ASKHR_TestUtility.createContact();
        Contact manager = ASKHR_TestUtility.createManagerContact();
        
        
        System.Assert(manager.ReportsToId == null, 'Manager should not have a reports to');
        System.Assert(employee.ReportsToId == null, 'Employee should not have a reports to yet');
        
        employee.Manager_Employee_Number__c = manager.Employee_Number__c;
        
        Test.startTest();

        update employee;                
        employee = [SELECT Id, ReportsToId, Reports_To_Requires_Resync__c FROM Contact WHERE Id = :employee.Id];
        System.Assert(employee.Reports_To_Requires_Resync__c, 'Resync flag should be on');

        // Start update process.
        ASKHR_ContactBulkUpdaterBatchDispatcher.StartBatch();

        Test.stopTest();
        
        employee = [SELECT Id, ReportsToId, Reports_To_Requires_Resync__c FROM Contact WHERE Id = :employee.Id];
        System.Assert(employee.Reports_To_Requires_Resync__c == false, 'Resync flag should be off');
        
        // Resynchronization job should be scheduled and executed on stopTest, check contact to see if reports to is supdated.
        System.Assert(employee.ReportsToId == manager.Id, 'Employee Reports To should point to Manager');
        
    }       
    
    @IsTest
    public static void ScheduleContactUpdaterJob_EmployeeUsingSelfForManagerID_ReportToCleared()
    { 
        // create the setting.
        Contact_Reports_To_Resync_Wait_Time__c settings = ASKHR_TestUtility.CreateCustomRescheduleSettings(10,1);
         
        // Insert a few contacts, with their Manager Employee Number updated
        // ensure reports to field gets updated.
        Contact employee = ASKHR_TestUtility.createContact();
        Contact manager = ASKHR_TestUtility.createManagerContact();
        
        
        System.Assert(manager.ReportsToId == null, 'Manager should not have a reports to');
        System.Assert(employee.ReportsToId == null, 'Employee should not have a reports to yet');
        
        employee.Manager_Employee_Number__c = employee.Employee_Number__c;
        
        Test.startTest();

        update employee;                
        employee = [SELECT Id, ReportsToId, Reports_To_Requires_Resync__c FROM Contact WHERE Id = :employee.Id];
        System.Assert(employee.Reports_To_Requires_Resync__c, 'Resync flag should be on');

        // Start update process.
        ASKHR_ContactBulkUpdaterBatchDispatcher.StartBatch();

        Test.stopTest();
        
        employee = [SELECT Id, ReportsToId, Reports_To_Requires_Resync__c FROM Contact WHERE Id = :employee.Id];
        System.Assert(employee.Reports_To_Requires_Resync__c == true, 'Resync flag should be on');
        
        // Resynchronization job should be scheduled and executed on stopTest, check contact to see if reports to is supdated.
        System.Assert(employee.ReportsToId == null, 'Employee Reports To should be null');
        
    }   
        
    @IsTest
    public static void ScheduleContactUpdaterJob_CircularRef_ReportToClearedForOne()
    { 
        // create the setting.
        Contact_Reports_To_Resync_Wait_Time__c settings = ASKHR_TestUtility.CreateCustomRescheduleSettings(10,1);
         
        // Insert a few contacts, with their Manager Employee Number updated
        // ensure reports to field gets updated.
        Contact employee = ASKHR_TestUtility.createContact();
        Contact manager = ASKHR_TestUtility.createManagerContact();
        
        
        System.Assert(manager.ReportsToId == null, 'Manager should not have a reports to');
        System.Assert(employee.ReportsToId == null, 'Employee should not have a reports to yet');
        
        employee.Manager_Employee_Number__c = manager.Employee_Number__c;
        manager.Manager_Employee_Number__c = employee.Employee_Number__c;
        
        Test.startTest();

        update new List<Contact> {employee, manager};   
                    
        employee = [SELECT Id, ReportsToId, Reports_To_Requires_Resync__c FROM Contact WHERE Id = :employee.Id];
        System.Assert(employee.Reports_To_Requires_Resync__c, 'Employee Resync flag should be on');

        manager = [SELECT Id, ReportsToId, Reports_To_Requires_Resync__c FROM Contact WHERE Id = :manager.Id];
        System.Assert(manager.Reports_To_Requires_Resync__c, 'Manager Resync flag should be on');

        // Start update process.
        ASKHR_ContactBulkUpdaterBatchDispatcher.StartBatch();

        Test.stopTest();
        
        employee = [SELECT Id, ReportsToId, Reports_To_Requires_Resync__c FROM Contact WHERE Id = :employee.Id];
        manager = [SELECT Id, ReportsToId, Reports_To_Requires_Resync__c FROM Contact WHERE Id = :manager.Id];
        
        System.AssertNotEquals(employee.Reports_To_Requires_Resync__c, manager.Reports_To_Requires_Resync__c, 'Resync flag should not be the same, on for only one.');
        System.AssertNotEquals(employee.ReportsToId, manager.ReportsToId, 'Reports To should not be the same.');
    }       
    
    @IsTest
    public static void ScheduleContactUpdaterJob_ManagerCannotBeFound_ReportsToCleared()
    { 
        // create the setting.
        Contact_Reports_To_Resync_Wait_Time__c settings = ASKHR_TestUtility.CreateCustomRescheduleSettings(10,1);
         
        // Insert a few contacts, with their Manager Employee Number updated
        // ensure reports to field gets updated.
        Contact employee = ASKHR_TestUtility.createContact();
        Contact manager = ASKHR_TestUtility.createManagerContact();
        
        
        System.Assert(manager.ReportsToId == null, 'Manager should not have a reports to');
        System.Assert(employee.ReportsToId == null, 'Employee should not have a reports to yet');
        
        employee.Manager_Employee_Number__c = manager.Employee_Number__c + '111';
        
        Test.startTest();

        update employee;                
        employee = [SELECT Id, ReportsToId, Reports_To_Requires_Resync__c FROM Contact WHERE Id = :employee.Id];
        System.Assert(employee.Reports_To_Requires_Resync__c, 'Resync flag should be on');

        // Start update process.
        ASKHR_ContactBulkUpdaterBatchDispatcher.StartBatch();

        Test.stopTest();
        
        employee = [SELECT Id, ReportsToId, Reports_To_Requires_Resync__c FROM Contact WHERE Id = :employee.Id];
        System.Assert(employee.Reports_To_Requires_Resync__c == true, 'Resync flag should still be on');
        
        // Resynchronization job should be scheduled and executed on stopTest, check contact to see if reports to is supdated.
        System.Assert(employee.ReportsToId == null, 'Employee Reports To should be blank');
        
    }       
            
}