/**
*@description this class is used in ASKHR_SendSurveyController
*/
public without sharing class ASKHR_SendSurvey {
    
    public List<Survey_Sent__c> mRecipients;
    
    private SObject mSObject;   
    private EmailTemplate mTemplate;
    private ASKHR_ISendSurvey_Responder mResponder;
    private Id mEmployeeOfRecordId;

	//constructor    
    public ASKHR_SendSurvey(SObject so, ASKHR_ISendSurvey_Responder responder){
        this.mSObject = so;
        this.mResponder = responder;         
    }
    /**
    *@description this method assigns template
	*/
    public void setTemplate(EmailTemplate template){
        this.mTemplate = template;
    }  
    /**
    *@description this method assigns employee of record
	*/
    public void setEmployeeOfRecords(Id employee){
        this.mEmployeeOfRecordId = employee;
    }    
    /**
    *@description this method assigns recipients
	*/
    public void setRecipient(List<Survey_Sent__c> recipients){
        this.mRecipients = recipients;
    }
    /**
    *@description this method is used to send survey
	*return boolean the survey is successfully sent or not
	*/
    public boolean SendSurvey()
    {    
        boolean surveysSuccessfullySent = false;
        integer num = this.mRecipients.size() -1;
        // Gather all Survey Sent objects that have a contact.
        for(integer i = num; i >= 0; i--)
        {                 
            if(mRecipients[i].Contact__c == null || mRecipients[i].Case__c == null)
            {
                mRecipients.remove(i);
            }                 
        }
        
        if(IsValid(mRecipients))
        {
            SendSurvey(mRecipients); //include the recordtype parameter at here
            surveysSuccessfullySent = true;
            
        }
        
        if(surveysSuccessfullySent){
            mResponder.SendSuccess();
            
            if(mSObject instanceof Case){
                mSObject.put('Survey_Is_Sent__c', true);
                mSObject.put('Display_Alert__c', false);
                update mSObject;
            }
        }
        
        return surveysSuccessfullySent;
    }
    /**
     *@description this method is used to check validity to send the survey to recipients
	*/
    private boolean IsValid(List<Survey_Sent__c> surveys)
    {
        boolean isValid = true;
        
        if(surveys.size() == 0)
        {
            //  Recipient1.Contact__c.addError();
            mResponder.SendFail('Must have at least one survey recipient.', 'Validation');
            isValid = false;
        }
        
        
        List<Id> contacts = new List<Id>();
        //get the contact email first
        for(Survey_Sent__c s :surveys){
            contacts.add(s.Contact__c);
        }
        //this is used for verifications whether the recipient email is exist or not
        //not checking for valid email here because is handled in Contact during adding email address
        List<Contact> contactsEmails = [Select Id,Email from Contact where Id IN :contacts];  
        
        // None of the recipients can be the Case's Employee of Record (EOR)
        for(Survey_Sent__c s :surveys)
        {
            
            if(mEmployeeOfRecordId != null && mEmployeeOfRecordId == s.Contact__c)
            {
                s.Contact__c.addError('Employee of Record cannot be a recipient of this survey.');
                isValid = false;
            }
            
            for(Contact c : contactsEmails){
                if(c.Id == s.Contact__c && String.isBlank(c.Email)){
                    
                    s.Contact__c.addError('Recipient must have valid email.');
                    isValid = false;
                }
            }
        }       
        
        return isValid;
    }
    /**
     *@description this method used to send email to the valid recipients
	*/
    private void SendSurvey(List<Survey_Sent__c> surveysToSend) 
    {
        if(surveysToSend.size() > 0)
        {
            
            if(mTemplate.Id != null){
                List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
                OrgWideEmailAddress owa = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'AskHR'];
                Id owaId = null;
                if(owa != null){
                    owaId = owa.Id;
                }
                
                for(Survey_Sent__c s :surveysToSend)
                {
                    if(s.Contact__c != null && s.Case__c != null){
                        emailsToSend.add(EmailToSend(s, owaId, mTemplate.Id));
                    }
                }
                
                if(!Test.isRunningTest()){
                    Messaging.sendEmail(emailsToSend); 
                }
            }
            
            
            insert surveysToSend;
        }
    }
    /**
     *@description 
	 *@return Messaging.SingleEmailMessage email 
	 */
    private Messaging.SingleEmailMessage EmailToSend(Survey_Sent__c survey, Id owaId, Id templateId) 
    {
        Contact recipient = [SELECT Id, Language__c FROM Contact WHERE Id = :survey.Contact__c]; 
        
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        
        System.Debug('sending email target ID (contact): ' + recipient.Id + ' what Id (case) ' + survey.Case__c + ' template id ' + templateId);
        
        if(owaId != null)
        {
            email.setOrgWideEmailAddressId(owaId);
        }
        
        email.setTargetObjectId(recipient.Id);
        email.setWhatId(survey.Case__c);
        email.setTemplateId(templateId);
        
        return email;
    }
    
    public class EmailTemplateNotFoundException extends Exception {}    
    
}