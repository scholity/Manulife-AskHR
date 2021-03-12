@isTest
public class ml_mli_ReportAttachmentTest {

    static testMethod void testAttachmentList(){
        mli_Quarterly_Report__c testReport = createReport();
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(testReport);
        ml_mli_ReportAttachmentController reportAttachmentController = new ml_mli_ReportAttachmentController(stdController);
        
        Test.startTest();
        system.assertNotEquals(null, reportAttachmentController.getAttachments());
        system.assertEquals(false, reportAttachmentController.mHaveError);
        system.assertEquals(0, reportAttachmentController.mCount);
        
        createAttachment(testReport.Id);
        reportAttachmentController = new ml_mli_ReportAttachmentController(stdController);
        system.assertNotEquals(0, reportAttachmentController.mCount);
        
        Test.stopTest();
    } 
    
    static testMethod void testReplaceAttachment(){
		mli_Quarterly_Report__c testReport = createReport();        
        Attachment testAttachment = createAttachment(testReport.Id);
        
        Test.startTest();
        
        //negative test
        ml_mli_ReportAttachmentController reportAttachmentController = new ml_mli_ReportAttachmentController();
        
        ApexPages.currentPage().getParameters().put('attachmentId', testAttachment.Id);
        reportAttachmentController = new ml_mli_ReportAttachmentController();
               
       	reportAttachmentController.mFileName = 'Test Updated File';
        reportAttachmentController.mContentType = 'TestFile';
        reportAttachmentController.fileBody = Blob.valueOf('Unit Test Updated Attachment Body');
        reportAttachmentController.mDescription = 'Test Updated file';
        
        reportAttachmentController.processReplace();
        system.assertEquals('Test Updated File', reportAttachmentController.mAttachment.Name);
        system.assertNotEquals(0, reportAttachmentController.mCount);
        reportAttachmentController.back();
        
        //negative test
        reportAttachmentController.mAttachment = null;     
        reportAttachmentController.processReplace();
        
        Test.stopTest();        
    }
    
    private static mli_Quarterly_Report__c createReport(){
        mli_Quarterly_Report__c report = new mli_Quarterly_Report__c();
        report.Name = 'Test Quarterly Report';
        report.Document_Title__c = 'Test Document title';
        report.File_Type__c = 'PDF';
        report.Date__c = Date.today();
        report.Language__c = 'en_US';
        report.Report_Type__c = 'en_US::Annual Information Form';
        report.Quarter__c = 'en_US::Q1';
        report.Description__c = 'Test Report';
        insert report;
        return report;
    }
    
    private static Attachment createAttachment(Id parentId){
        Attachment att = new Attachment();
        att.Name = 'Test Attachment';
        att.Body = Blob.valueOf('Unit Test Attachment Body');
        att.ParentId = parentId;
        insert att;
        return att;
    }
}