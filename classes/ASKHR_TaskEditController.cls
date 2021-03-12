/**
*@description this class is the controller class for Visualforce Page ASKHR_Task_Edit
*/
public without sharing class ASKHR_TaskEditController {

    public Attachment attachment {get;set;}
    public Task task {get;set;}
    public User user {get;set;}
    public List <Attachment> attachmentList {get;set;}
    public boolean display {get;set;}
    public Id ownerId {get;set;}
    public Integer rowCounter {get;set;}
	
    //constructor
    public ASKHR_TaskEditController (ApexPages.StandardController stdController) {
       
        task = (Task)stdController.getRecord();
        ownerId = task.OwnerId;
        user = new User ();  
        attachment = new Attachment();
        attachmentList  = new List <Attachment> ();
        display = false;
        rowCounter = 0;
    }
    /**
	*@description this method is used to create task
	*@return pagereference redirects to the Visual force page
	*/
    public Pagereference doSave()
    {     
        if(attachmentList != null && !attachmentList.isEmpty()) {
            if(task.OwnerId.equals(ownerId)) {  
                upsert task;
                for(Attachment a : attachmentList)
                insert a;
            
                attachmentList = new List <Attachment> ();
                display = false;                
            }
            else {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'To Upload Attachment, Owner Id must be same with Parent Task Owner Id.'));
            }
       }
       else {
             upsert task;          
       }
        String theId = ApexPages.currentPage().getParameters().get('id');
        PageReference p = new PageReference('/' + theId);
        p.setRedirect(true);    
        return p;
    }   
    /**
	*@description this method is used to create task and continue to create another new task
	*@return pagereference redirects to the Visual force page
	*/
    public Pagereference doSaveAndNew()
    {
        if(attachmentList != null && !attachmentList.isEmpty()) {
            if(task.OwnerId.equals(ownerId)) {
                upsert task;                
                for(Attachment a : attachmentList)
                insert a;
            
                attachmentList = new List <Attachment> ();
                display = false;                 
            }
            else {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'To Upload Attachment, Owner Id must be same with Parent Task Owner Id.'));
                return null;
            }
       }
       else{
             upsert task;         
        }

        String s = '/' + ('' + task.get('Id')).subString(0, 3) + '/e?';
        ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Info, s));
        return new Pagereference(s);
    }  
    /**
	*@description this method is used to do upload process
	*@return pagereference redirects to the Visual force page
	*/
    public PageReference processUpload() {
        String accid = System.currentPagereference().getParameters().get('id');

        Attachment a = new Attachment(parentId = accid, name=attachment.Name, body = attachment.Body); 
        
        if( a!= null){
            attachmentList.add(a);
            display = true;
        }
        return NULL;
    }
    /**
	*@description this method is used to remove the attachment
	*@return pagereference redirects to the Visual force page
	*/

    public PageReference processRemove()
    {
        String accid = System.currentPagereference().getParameters().get('id');

        if(attachmentList != null && !attachmentList.isEmpty()){
           attachmentList.remove(rowCounter);            
        }
        
        if(attachmentList.size() == 0)
             display = false;
        
        return NULL;
    }

}