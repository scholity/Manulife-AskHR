/**
	*@author
	*@description this class is used as an extention for CaseCommunication page
	*/
public class ASKHR_CaseCommunicationExt {

    public Id mCommentRecordTypeId { get { return recordTypeId('Case Comment'); } private set; }
    public Boolean mIsError { get; Set; }
    public Boolean mIsAllowComment { get; Set; }
	
    //constructor
    public ASKHR_CaseCommunicationExt(ApexPages.StandardController stdController) {
        Case caseComm = (Case) stdController.getRecord();

        mIsError = true;
        if (caseComm.Id != null) {
            System.debug('case comm id :'+ caseComm.Id);
            caseComm = [SELECT ContactId, OwnerId, Status, OwnerIsUser__c from Case WHERE Id = :caseComm.Id];
            User employee = [Select FirstName, LastName, User_License__c from User where Id = :UserInfo.getUserId()];
            Contact[] employeeContact = [Select Id from Contact where User__c = :employee.Id];
            boolean employeeIsContact = false;
            System.debug('case comm employee id :'+ employee.Id);
            System.debug('case comm contact id :'+ caseComm.ContactId);
            
             
            if(!employeeContact.isEmpty()){
                employeeIsContact = true;
                //if the current user is case contact. allow comment
                if(caseComm.ContactId != null){
                    employeeIsContact = employeeContact[0].Id == caseComm.ContactId;
                }                             
            }

            //only allow comment if the employee owns the feedback and if it still in review
            mIsAllowComment = caseComm.OwnerIsUser__c && !caseComm.Status.equals('Closed') ? true : false;
         
            mIsError = (employee.Id == caseComm.OwnerId || employeeIsContact) ? false : true;
        } 
    }
	/**
	*@description this method gets the record type id 
	*@return Id recordTypeid 
	*/
    private Id recordTypeId(String type) {
        return Schema.SObjectType.ASKHR_ArticleFeedback__c.getRecordTypeInfosByName().get(type).getRecordTypeId();
    }
}