/**
 	*@author
 	*@description this class implementes Queueable interface
	*Auto publish the article once they are approved 
	*during HRSS Approval Process
 	*/
public class AskHR_AutoPublishArticles implements Queueable {
    
    List<Knowledge__kav> kavMap = new List<Knowledge__kav>();
    List<Knowledge__kav> kavToUpdate = new List<Knowledge__kav>();
    
    public  AskHR_AutoPublishArticles(List<Knowledge__kav> kavMap){
        
        this.kavMap = kavMap;
    }
    
    /**
 	*@description publish the article
	*@param  QueueableContext
 	*/
    public void execute(QueueableContext context) {
        
        for(Knowledge__kav kId : kavMap){
            
            system.debug('Publishing articles ===');
            KbManagement.PublishingService.publishArticle(kId.KnowledgeArticleId, false);
            system.debug('Article published==');
            kavToUpdate.add(kId);
            sendEmailNotification(kavToUpdate);
        }
        
    }
    /**
 	*@description Send Email notification once article are published
	*@param  List<HRSS_SOP__kav>
 	*/
    public void sendEmailNotification(List<Knowledge__kav> kav){
        
        if(!kav.isEmpty()) {
            EmailTemplate[] emailTemplates = [Select Id, Name, DeveloperName from EmailTemplate where DeveloperName = 'AskHR_Article_Publish_Notification'];
            
            List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage> ();
            OrgWideEmailAddress owa = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'AskHR' limit 1];
            Id owaId = null;
            if (owa != null) {
                owaId = owa.Id;
            }
            for (Knowledge__kav article : kav){
                
                
                emailsToSend.add(EmailToSendReviewer(article, owaId, emailTemplates[0].Id));
                emailsToSend.add(EmailToSendOwner(article, owaId, emailTemplates[0].Id));
            }
            Messaging.SendEmailResult[] results;
            results = Messaging.sendEmail(emailsToSend);
            system.debug('Email sent===');
            
        }
    }
     /**
 	*@description this method is used to set the email to send
	*for the approver
	*@param HRSS_SOP__kav
	*@paramowaId Id
	*@param templateId Id
	*@return Messaging.SingleEmailMessage EmailToSend
 	*/
    public Messaging.SingleEmailMessage EmailToSendReviewer(Knowledge__kav article, Id owaId, Id templateId){
        
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        
        if (owaId != null){
            
            email.setOrgWideEmailAddressId(owaId);
        }
        email.setSaveAsActivity(false);
        email.setTargetObjectId(article.LastModifiedbyId);
        email.setWhatId(article.Id);
        email.setTemplateId(templateId);
        
        return email;
    }
     /**
 	*@description this method is used to set the email to send
	*for the OwnerId
	*@param article HRSS_SOP__kav
	*@paramowaId Id
	*@param templateId Id
	*@return Messaging.SingleEmailMessage EmailToSend
 	*/
    public Messaging.SingleEmailMessage EmailToSendOwner(Knowledge__kav article, Id owaId, Id templateId){
        
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        
        if (owaId != null){
            
            email.setOrgWideEmailAddressId(owaId);
        }
        email.setSaveAsActivity(false);
        email.setTargetObjectId(article.OwnerId);
        email.setWhatId(article.Id);
        email.setTemplateId(templateId);
        
        return email;
    }
    
}