public with sharing class ml_mli_ReportAttachmentController {
    
    public mli_Quarterly_Report__c mReport { get; set; }
    public Integer mCount { get; set; }
    public Attachment mAttachment { get; set; } //used in Replace page
    public boolean mHaveError { get; set; }
    public String mFileName {get;set;}
    public Blob fileBody {get;set;}    
    public String mDescription { get; set; }
    public String mContentType { get; set; }
    private Attachment[] attachments; //used in Report page
    
    /*
	*	Initializing the class when opened from other page
	*/
    public ml_mli_ReportAttachmentController(){
        try{
            Id attachmentId = ApexPages.currentPage().getParameters().get('attachmentId');        
            if(attachmentId != null){
                mAttachment = [Select Id, ParentId, body, Name, Description, ContentType from Attachment where Id= :attachmentId];
                mHaveError = false;
            }else{
                throw new ReportException();
            }
        }catch(Exception ex){
            mHaveError = true;
        } 
    }
    
    /*
	*	Initializing the class when embedded inside the Report view
	*/
    public ml_mli_ReportAttachmentController(ApexPages.StandardController stdController){
        mReport=  (mli_Quarterly_Report__c)stdController.getRecord();          
        attachments = [Select Id,body,name,ContentType,Description,ParentId,LastModifiedDate,LastModifiedBy.Name from Attachment where parentId = :mReport.Id ORDER BY LastModifiedDate DESC];
        mCount = attachments.size();   
        mHaveError = false;
    }
    
    public List<Attachment> getAttachments(){
        return attachments;       
    }    
    
    /**
    * Replace process is:
    *  1. Get existing attachment for the Report Attachment 
    *  2. Update the Blob
    **/
    public PageReference processReplace() {
        try {            
            Database.SaveResult attachmentResult = updateExistingAttachment();
            
            if (attachmentResult == null || !attachmentResult.isSuccess()) {                         
                throw new ReportException('Could not save attachment.');
            }        
        } catch (Exception e) {
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                                                           e.getMessage()));  
            return null;
        }
        
        return new PageReference('/'+ mAttachment.ParentId);
    }
    
    //update the existing Attachment record for the MLI_QReport_Attachment__c
    private Database.SaveResult updateExistingAttachment() {
        Database.SaveResult result;      
        
        mAttachment.name = this.mFileName;
        mAttachment.body = this.fileBody; 
        mAttachment.Description = this.mDescription;
        mAttachment.ContentType = this.mContentType;
        // insert the attahcment
        result = Database.update(mAttachment);
        // reset the file for the view state
        //fileBody = Blob.valueOf(' ');
        return result;
    }
    
    public PageReference back() {
		this.fileBody = Blob.valueOf(' ');
        return new PageReference('/'+mAttachment.ParentId);
    }   

	public class ReportException extends Exception {}      
}