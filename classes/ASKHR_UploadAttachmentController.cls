/**
 *@description this class is used to upload attachments
*/
public without sharing class ASKHR_UploadAttachmentController {
    
    private Case m_case {get;set;} 
    public String fileName {get;set;}
    public Blob fileBody {get;set;}
    public boolean mCaseClosed { get; set; }    
    //constructor
    public ASKHR_UploadAttachmentController(ApexPages.StandardController controller) { 
        this.m_case = (Case)controller.getRecord();
        
        this.m_case = [Select Status from Case where Id =:m_case.Id];
        if(m_case != null){
            if(!String.isBlank(this.m_case.Status) && this.m_case.Status.equals('Closed'))
                mCaseClosed = true;
            else
                mCaseClosed = false;
        }
    }   
    
    /**
	*@description create an actual Attachment record with the Case as parent
	*@param Id parentId
	*return Database.SaveResult
	*/
    private Database.SaveResult saveStandardAttachment(Id parentId) {
        try{
            Database.SaveResult result;
            
            Attachment attachment = new Attachment();
            attachment.body = this.fileBody;
            attachment.name = this.fileName;
            attachment.parentId = parentId;
            // insert the attahcment
            result = Database.insert(attachment);
            // reset the file for the view state
            fileBody = Blob.valueOf(' ');
            return result;
        }catch (Exception ex){
            return null;
        }
    }
    /** 
    *@description this method is used to attach the file
	*@return PageReference redirects to visual force page
	*/
    public PageReference processUpload() {
        try {
            
            Database.SaveResult attachmentResult = saveStandardAttachment(m_case.Id);
            
            if (attachmentResult == null || !attachmentResult.isSuccess()) {
                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                                                           'Could not save attachment.'));            
                return null;
            } 
        } catch (Exception e) {
            ApexPages.AddMessages(e);
            return null;
        }
        
        return new PageReference('/'+m_case.Id);
    }
    /** 
    *@description this method is used to back to the visual force page
	*@return PageReference redirects to visual force page
	*/
    public PageReference back() {
        return new PageReference('/'+m_case.Id);
    }     
}