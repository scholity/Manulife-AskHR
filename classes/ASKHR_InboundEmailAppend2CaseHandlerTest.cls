/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
global class ASKHR_InboundEmailAppend2CaseHandlerTest {

    private static Case m_TestCase;
    
    public static Case GetTestCase()
    { 
        if(m_TestCase == null)
        {
            Case testCase = ASKHR_TestUtility.createERCase();   
            m_TestCase = [SELECT Id, CaseNumber FROM Case Where Id = :testCase.Id];     
        }
        return m_TestCase;
    }
    
    static testMethod void doHandleIncomingEmailTest() {
          
          // create a new email and envelope object
          Messaging.InboundEmail email = new Messaging.InboundEmail() ;
          Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        
         User usr = [SELECT Id, Email FROM User Where Id = :Userinfo.getUserId()];
         
          // setup the data for the email
          email.subject = 'Test Email for Case';
          email.fromAddress = 'someaddress@email.com';  
          email.toAddresses =new List<string> {'somewhereelse@email.com'};  
          env.fromAddress = 'someaddress@email.com';
          env.toAddress = usr.Email;
        
          // add an attachment
          Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
          attachment.body = blob.valueOf('my attachment text');
          attachment.fileName = 'textfile.txt';
          attachment.mimeTypeSubType = 'text/plain';
        
          email.binaryAttachments =
            new Messaging.inboundEmail.BinaryAttachment[] { attachment };
        
          // call the email service class and test it with the data in the testMethod
          ASKHR_InboundEmailAppend2CaseHandler emailProcess = new ASKHR_InboundEmailAppend2CaseHandler();
          emailProcess.handleInboundEmail(email, env);
        
          // ensure email has been added with proper parent id.
          EmailMessage newEmail = [SELECT Id, Subject, FromAddress, ParentId FROM EmailMessage WHERE ParentId = :m_TestCase.Id];                 
        
          System.assertEquals('Test Email for Case',newEmail.Subject);
          System.assertEquals('someaddress@email.com', newEmail.FromAddress);        
        
        //attachment are moved to Case to fullfill requirement that Attachment should be display under Case
          // find the attachment
          //Attachment a = [select name from attachment where parentId = :newEmail.id];
          // System.assertEquals(a.name,'textfile.txt');
    }
}