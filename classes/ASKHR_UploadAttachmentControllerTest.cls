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
private class ASKHR_UploadAttachmentControllerTest {
    
    public static Map<String, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Case.getRecordTypeInfosByName();
    //private static String CASE_RECORD_TYPE_NAME_GENERAL_HR = 'General HR Case';

    static testMethod void processUploadTest() {
        Case testCase = new Case(Secondary_Country_of_Reference__c = 'USA', External_Contact_Name__c = 'TEST EXTERNAL NAME', RecordTypeId=rtMap.get(ASKHR_Common.CASE_RECORD_TYPE_NAME_GENERAL_HR).getRecordTypeId());
                
        //negative test
        PageReference returnPageNegativeTest = new PageReference('/');
        ApexPages.StandardController stdControllerNegativeTest = new ApexPages.StandardController(testCase);
        
        insert testCase;
        PageReference returnPage = new PageReference('/'+testCase.Id);
        ApexPages.StandardController stdController = new ApexPages.StandardController(testCase);

        ASKHR_UploadAttachmentController controllerExtension = new ASKHR_UploadAttachmentController(stdController);
        controllerExtension.fileBody = Blob.valueOf('TEST_BLOB');
        controllerExtension.fileName = 'TEST FILE NAME.txt';
        
        PageReference returnPageAfterProcessUpload = controllerExtension.processUpload();       
        System.assertEquals(returnPage.getURL(), returnPageAfterProcessUpload.getURL());
        
        Attachment newAttachment = [Select Id from Attachment where ParentId = :testCase.Id];
        System.assertNotEquals(null, newAttachment);

        PageReference returnPageAfterBack = controllerExtension.back();     
        System.assertEquals(returnPage.getURL(), returnPageAfterBack.getURL());
        
        controllerExtension.fileBody = Blob.valueOf('TEST_BLOB');
        controllerExtension.fileName = null;

        returnPageAfterProcessUpload = controllerExtension.processUpload();     
        System.assertEquals(null, returnPageAfterProcessUpload);
        
        //negative test
        controllerExtension = new ASKHR_UploadAttachmentController(stdControllerNegativeTest);
        controllerExtension.fileBody = Blob.valueOf('TEST_BLOB');
        controllerExtension.fileName = 'TEST FILE NAME.txt';
        
        PageReference returnPageAfterProcessUploadNegativeTest = controllerExtension.processUpload();       
        System.assertEquals(returnPageNegativeTest.getURL(), '/');
        
        PageReference returnPageAfterBackNegativeTest = controllerExtension.back();     
        System.assertEquals(returnPageNegativeTest.getURL(), '/');
        
        controllerExtension.fileBody = Blob.valueOf('TEST_BLOB');
        controllerExtension.fileName = null;

        returnPageAfterProcessUploadNegativeTest = controllerExtension.processUpload();     
        System.assertEquals(null, returnPageAfterProcessUploadNegativeTest);
    }
    
    static testMethod void processUploadCaseCloseTest() {
        Case testCase = new Case(Secondary_Country_of_Reference__c = 'USA', 
                                 External_Contact_Name__c = 'TEST EXTERNAL NAME', 
                                 RecordTypeId=rtMap.get(ASKHR_Common.CASE_RECORD_TYPE_NAME_GENERAL_HR).getRecordTypeId());        
        
        insert testCase;
        testCase.put('Status', 'Closed');
        update testCase;
        
        PageReference returnPage = new PageReference('/'+testCase.Id);
        ApexPages.StandardController stdController = new ApexPages.StandardController(testCase);

        ASKHR_UploadAttachmentController controllerExtension = new ASKHR_UploadAttachmentController(stdController);
        controllerExtension.fileBody = Blob.valueOf('TEST_BLOB');
        controllerExtension.fileName = 'TEST FILE NAME.txt';
        
        PageReference returnPageAfterProcessUpload = controllerExtension.processUpload();       
        System.assertEquals(returnPage.getURL(), returnPageAfterProcessUpload.getURL());
        
        Attachment newAttachment = [Select Id from Attachment where ParentId = :testCase.Id];
        System.assertNotEquals(null, newAttachment);

        PageReference returnPageAfterBack = controllerExtension.back();     
        System.assertEquals(returnPage.getURL(), returnPageAfterBack.getURL());
        
        controllerExtension.fileBody = Blob.valueOf('TEST_BLOB');
        controllerExtension.fileName = null;

        returnPageAfterProcessUpload = controllerExtension.processUpload();     
        System.assertEquals(null, returnPageAfterProcessUpload);        
    }
}