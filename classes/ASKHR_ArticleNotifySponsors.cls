/**
 	*@author
 	*@description this class is used to notify the article sponsors
	*when the articles review date is reached today's date
 	*/

	public with sharing class ASKHR_ArticleNotifySponsors implements Schedulable {

    /**
 	*@description execution part of send email and process the email result 
	*@param sc SchedulableContext
 	*/
    public void execute(SchedulableContext sc) {
        try {

            //List<Standard_Tab_Layout__kav> articles = [SELECT ID, Review_Date__c, Sponsor__c FROM Standard_Tab_Layout__kav WHERE PublishStatus = 'Online' and Language = 'en_US' AND Review_Date__c != null AND Sponsor__c != null AND Review_Date__c = TODAY];
			List<Knowledge__kav> articles = [SELECT ID, Review_Date__c, AskHR_Article_Sponsor__c FROM Knowledge__kav WHERE
                                             PublishStatus = 'Online' and Language = 'en_US' AND Review_Date__c != null 
                                             AND AskHR_Article_Sponsor__c != null AND Review_Date__c = TODAY
                                            AND RecordType.Name = :System.Label.AskHR_Article];
            
            if (!articles.isEmpty()) {
                EmailTemplate[] emailTemplates = [Select Id, Name, DeveloperName from EmailTemplate where DeveloperName = 'ASKHR_ArticleNotifySponsor'];
                if (!emailTemplates.isEmpty()) {
                    List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage> ();
                    OrgWideEmailAddress owa = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'AskHR'];
                    Id owaId = null;
                    if (owa != null) {
                        owaId = owa.Id;
                    }

                    for (Knowledge__kav article : articles)
                    {
                        emailsToSend.add(EmailToSend(article, owaId, emailTemplates[0].Id));
                    }

                    Messaging.SendEmailResult[] results;
                    results = Messaging.sendEmail(emailsToSend);
                    processSendEmailResult(results);                    
                }

            }
        } catch(Exception ex) { }
    }

     /**
 	*@description this method is used to process sent email result
	*@param results Messaging.SendEmailResult[]
 	*/
    private void processSendEmailResult(Messaging.SendEmailResult[] results) {
        String emailErrorReport = 'No Error';
        List<Messaging.SendEmailError> errors = new List<Messaging.SendEmailError> ();
        for (Messaging.SendEmailResult currentResult : results) {
            errors = currentResult.getErrors();
            if (null != errors) {
                emailErrorReport = '';
                for (Messaging.SendEmailError currentError : errors) {
                    emailErrorReport += '(' + currentError.getStatusCode() + ') ' + currentError.getMessage() + '\r';
                }
            }
        }

        System.debug('ASKHR Article Notifier- Send Email Errors: ' + emailErrorReport);
    }

     /**
 	*@description this method is used to set the email to send
	*@param sponsor Standard_Tab_Layout__kav
	*@paramowaId Id
	*@param templateId Id
	*@return Messaging.SingleEmailMessage EmailToSend
 	*/
    private Messaging.SingleEmailMessage EmailToSend(Knowledge__kav sponsor, Id owaId, Id templateId)
    {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

        //System.Debug('sending email target ID (contact): ' + recipient.Id + ' what Id (case) ' + survey.Case__c + ' template id ' + templateId);

        if (owaId != null)
        {
            email.setOrgWideEmailAddressId(owaId);
        }

        //for user object. set this to false -  saveAsActivity must be false when sending mail to users
        email.setSaveAsActivity(false);
        email.setTargetObjectId(sponsor.AskHR_Article_Sponsor__c);
        email.setWhatId(sponsor.Id);
        email.setTemplateId(templateId);

        return email;
    }

}