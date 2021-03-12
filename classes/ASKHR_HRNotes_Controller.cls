/** 
 *description this method is used to create HRnotes of cases
*/
public class ASKHR_HRNotes_Controller{
   
    public Private_Notes__c newHRNote ;
    Public Id caseId {get;set;} 
    public boolean cancellNote {get; set;}
    public boolean newNote {get; set;}
    
  
    private ApexPages.StandardController stdController {get; set;}
    //constructor
    public ASKHR_HRNotes_Controller(ApexPages.StandardController Controller)
    {
        stdController = Controller;             
        caseId= ApexPages.currentPage().getParameters().get('CaseId');  
        newHRNote = (Private_Notes__c)stdController.getRecord();  
    }     
 
   /**
	*@description method to create HRNote
	*@return pagereference and redirects to the Visual force page
	*/
   public PageReference save() 
   {    
       String retURL = ApexPages.currentPage().getParameters().get('retURL');
       PageReference redirectPage;
       if(retURL != null)
           redirectPage = new PageReference('/' + retURL);
       else if(caseId != null)
           redirectPage = new PageReference('/' + caseId);
          try
          {
              if (newHRNote.comments__c != null)
              {
                  newHRNote.case__c= caseId; 
                  insert newHRNote;
                  newNote = true;
                  //newNote = true;
             }                    
          } 
          catch (Exception e)
          {
              System.debug('Error:' + e.getMessage());
          }

       return redirectPage; 
    }
    /**
	*@description method to close the window and redirects to Visual force page
	*@return pagereference and redirects to the Visual force page
	*/ 
    public PageReference Cancel() 
    {
        PageReference redirectPage = new PageReference('/' + caseId);
        cancellNote = true;
        return redirectPage;
     } 
    
    /**
	*@description method to Save the new HR notes
	*@return Boolean
	*/ 
    @AuraEnabled
    public static Boolean saveHRNotes (Id recordId, String notes){
        
        Boolean success = false;
        
        if(recordId != null && !String.isBlank(notes)){
            
            Private_Notes__c note = new Private_Notes__c();
            note.Case__c = recordId;
            note.Comments__c = notes;
            
            insert note;
            success = true;
        }
        
        
        return success;
    }
}