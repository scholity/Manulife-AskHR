/**
	*@author Mohamad Ammar Amran <mohamadammar_amran@manulife.com>
	*@description Termination Case follow up.
	*@date updated 1/11/2016 - to reflect changes on AHP-411, change to Create close the case
	*	   				     - update the sending email mechanism to avoid hitting governor limit
	*/
global without sharing class ASKHR_ER_Termination_Case_Follow_Up {
    
    
    @InvocableMethod(label = 'Remind Owner to Close Case' description = 'Check to see if the ER Termination Case has not been closed yet, if not, remind the owner to close it.')
    global static void RemindOwnerToCloseCase(List<ID> caseIDs)
    {
        try
        {
            List<Case> erTerminationCases = [SELECT Id, Status, CreatedById, CaseNumber,RecordType.Name FROM Case
                                             WHERE RecordType.Name = :ASKHR_Common.CASE_RECORD_TYPE_NAME_ER_TERMINATION AND Id in :caseIDs AND Status <> 'Closed'];
            
            if(!erTerminationCases.isEmpty()){
                List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage> ();
                Id owaId;
                OrgWideEmailAddress owa = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'AskHR'];
                if (owa != null)
                {
                    owaId = owa.Id;
                }
                
                // Go through each case, send an email to the owner, reminding them to close it.
                for (Case er : erTerminationCases)
                {
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    System.Debug('sending email to: ' + er.CreatedById + ' for ER Termination Case ' + er.Id);
                    
                    User recipient = [SELECT Id, Email FROM User Where Id = :er.CreatedById];
                    
                    email.setOrgWideEmailAddressId(owaId);
                    email.setSaveAsActivity(false);
                    email.setTargetObjectId(er.CreatedById);
                    email.setSubject('Please Close ER Termination Case# ' + er.CaseNumber);
                    email.setPlainTextBody('The ER Termination Case# ' + er.CaseNumber + ' has not been closed yet.  Please ensure you have received the requested termination letter, and close the case.\n\n' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + er.Id + '\n\nThis is a system generated email, please do not reply.');
                    emails.add(email);
                }
                
                Messaging.sendEmail(emails);
            }else{
                if(Test.isRunningTest()){
                    throw new ERTerminationException('No ER Termination cases available');
                }
            }
        }
        catch(Exception e) {
            System.Debug('Error sending email- error:' + e.getMessage());
        }
        
    }
    
    public class ERTerminationException extends Exception{}
}