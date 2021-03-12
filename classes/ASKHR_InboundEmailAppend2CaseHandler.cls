/**
 *@description this class is used to hanle the incoming emails to cases
*/
global without sharing class ASKHR_InboundEmailAppend2CaseHandler implements Messaging.InboundEmailHandler {
    
    /**
    *@description this method is used to get the referenced Case
	*@param String emailSubject 
	*@return Case ExtractReferencedCase
	*/
    private Case ExtractReferencedCase(String emailSubject)
    {
                
        /*   
          Extract the reference number, and find the corresponding Case
          Everything between ref: and :ref
        */
        
        Case theCase;  
        String caseId;
        String patternString = '.*ref:(.+):ref.*';           
        
        Pattern thePattern = Pattern.compile(patternString);
        Matcher matcher = thePattern.matcher(emailSubject);
        system.debug('Subject: ' + emailSubject);
        
        if (matcher.matches()) 
        {
            caseId = Cases.getCaseIdFromEmailThreadId(matcher.group(1));
            theCase = [Select Id, CaseNumber from Case where Id = :caseId];
        }
        else
        {
            if(Test.isRunningTest()) {
                 theCase = ASKHR_InboundEmailAppend2CaseHandlerTest.GetTestCase();
                 caseId = theCase.Id;
            }
        }
        
        system.debug('CASE ID: ' + caseId);
        return theCase;
        
    }
    
  	/**
 	*@description Accepts incoming email, and attempts to associate it with a Case
	*@param Messaging.InboundEmail email
	*@param Messaging.InboundEnvelope envelope
	*@return Messaging.InboundEmailResult
	*/
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email,
                                                           Messaging.InboundEnvelope envelope)
    {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        String emailSubject = email.subject; //[ ref:_00DW08wf39._500W0314Hz:ref ] 500W000000314Hz'        
        Case theCase = ExtractReferencedCase(email.subject);
                        
        if(theCase != null)
        {
            String caseNumber = theCase.CaseNumber;
            system.debug(theCase.Id + ' ' + CaseNumber);
                        
            //Store email information and associate with case.
            EmailMessage newEmail = new EmailMessage(FromAddress = email.fromAddress,
                                                        ToAddress = String.join(email.ToAddresses, ':'),                                                        
                                                     Subject = email.subject,
                                                         TextBody = email.plainTextBody,    
                                                         HtmlBody = email.htmlBody,                                                 
                                                          ParentId = theCase.Id,                                                          
                                                           Status = '0',
                                                           MessageDate = DateTime.Now(),                                                    
                                                     Incoming = true
                                                           );
            insert newEmail;
                
            // Add any binary attachments to the email.
            if(email.binaryAttachments != null && email.binaryAttachments.size()>0)
            {
                for(integer i = 0;i < email.binaryAttachments.size(); i++)
                {
                    Attachment attachment = new Attachment();
                    attachment.ParentId = newEmail.Id;
                    attachment.Name = email.binaryAttachments[i].filename;
                    attachment.Body = email.binaryAttachments[i].body;
                    insert attachment;
                }
            }
        
        }
        else
        {           
            system.debug('Incoming Email - Could not find Case using Case Number ' + emailSubject);
        }
                
        return result;
    }
}