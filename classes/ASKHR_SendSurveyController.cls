/**
 	*@description Contoller for Visualforce Page ASKHR_SendSurvey
	*/

public with sharing class ASKHR_SendSurveyController implements ASKHR_ISendSurvey_Responder{

  private final Case m_Case;
    public final boolean ShowCaseClose {get; set;}
    
    public Survey_Sent__c Recipient1 {get; set;}
    public Survey_Sent__c Recipient2 {get; set;}
    public Survey_Sent__c Recipient3 {get; set;}
    public Survey_Sent__c Recipient4 {get; set;}
    
    public boolean Cancelling{get; set;}
    public boolean SurveysSuccessfullySent {get; set;}
    public string disableButton {get; set;}
    public string renderButton {get; set;}
    
    private ASKHR_SendSurvey mSurvey;
  //constructor 
  public ASKHR_SendSurveyController()
  {
      try 
      {
            m_Case = [SELECT Id, CaseNumber, ContactId, Supervisor_Name__c, Employee_of_Record__c FROM Case WHERE Id =:ApexPages.currentPage().getParameters().get('CaseId')];
            ShowCaseClose = Boolean.valueOf(ApexPages.currentPage().getParameters().get('ShowClose'));
            Recipient1 = new Survey_Sent__c(Case__c = m_Case.Id);
            Recipient2 = new Survey_Sent__c(Case__c = m_Case.Id);
            Recipient3 = new Survey_Sent__c(Case__c = m_Case.Id);
            Recipient4 = new Survey_Sent__c(Case__c = m_Case.Id);
            SurveysSuccessfullySent = false;
          
            PrefillRecipients();
            
            mSurvey = ASKHR_SurveyBuilder.createSurvey(m_Case, this);
            mSurvey.setEmployeeOfRecords(m_Case.Employee_Of_Record__c);
      }
      catch(Exception e){
                System.Debug(' error:' + e.getMessage());
                throw e;
            }
  }
    
   
  /**
   *@description this method used to prefill the recipents information
   */
  private void PrefillRecipients()
  {
    // Prefill Recipient 1 with the Case Contact.
    Recipient1.Contact__c = m_Case.ContactId;
    
  }
   /**
   *@description this method gets case numebr
	@returns String casenumber
   */
  public String getCaseNumber()
  {
    return m_Case.CaseNumber;
  }
  
    /**
   *@description this method gets case URL
	@returns String case URL
   */
  public String getCaseURL()
  {
    return new PageReference('/' + m_Case.Id).getURL();
  }
	/**
	*@description method send survey to  relevant recipients
	*@return pagereference redirects to  Visual force page
	*/
  public PageReference SendSurvey() //the "SendSurvery" button from the page layout
  {  
      mSurvey.setRecipient(new List<Survey_Sent__c> {Recipient1, Recipient2, Recipient3, Recipient4});
      SurveysSuccessfullySent = mSurvey.SendSurvey(); 
      return null;
  }
	/**
	*@description method cancel and redirects to visual force page
	*@return pagereference redirects to  Visual force page
	*/  
  public PageReference Cancel() //the "Cancel" button from the page layout
  {
    Cancelling = true;
    return null;
  }   
    /**
	*@description method assigns boolean to indicate the survey sent successful
	*/
    public void SendSuccess(){
        SurveysSuccessfullySent = true;
    }
    /**
	*@description method assigns boolean to indicate the survey sent unsuccessful
	*@param String errorMessage receives string of error message
	*@param String errorType receives string of error type
	*/    
    public void SendFail(String errorMessage, String errorType){        
        if(errorType == 'Validation'){
            Recipient1.Contact__c.addError(errorMessage);     
            
        }else if(errorType == 'Template'){
            disableButton = 'true';
            ApexPages.Message pageMsg = new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage);
            ApexPages.addMessage(pageMsg);
        }else
        {       
            
            renderButton = 'true';
            ApexPages.Message pageMsg = new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage);
            ApexPages.addMessage(pageMsg);
        } 
        SurveysSuccessfullySent = false;
    }
    
    
 
}