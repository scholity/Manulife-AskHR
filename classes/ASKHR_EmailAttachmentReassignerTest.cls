//* AHP:361: Attachment file size cannot be covered in Test Case. Known Salesforce Issue as file size is not adjustable/be set.  
@isTest
public class ASKHR_EmailAttachmentReassignerTest {
    static testmethod void attachmentTester() {
        Case c = new Case();
        insert c;
        
        EmailMessage em = new EmailMessage();
        em.parentId = c.id;
        em.MessageDate = Date.today();
        em.FromAddress = 'test@from.com';
        em.ToAddress = 'test@to.com';
        em.Subject = 'test subject';
        em.TextBody = 'heres a text body.';
        insert em;
        
        
        Attachment a = new Attachment();
        a.name = 'test attachment';
        a.body = blob.valueof('attachment body');
        a.ContentType = 'image/gif';
        a.parentid = em.id;
        insert a;   
        
        List<Attachment> attachments = [Select Id From Attachment Where parentId = :c.id];
        
        System.assert(attachments.size() == 1, 'Wrong number of attachments (( ' + attachments.size() );  
    }      
}