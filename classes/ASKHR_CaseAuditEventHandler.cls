/**
	* @author 
	* @description Trigger Handler for the Case SObject. This class implements the ITrigger
	*			   interface to help ensure the trigger code is bulkified and all in one place.
	*/

public with sharing class ASKHR_CaseAuditEventHandler implements ITrigger {
    
	private static String m_UserProfileName = ''; //to avoid null pointer error

    /**
	 *@description this method is called prior to execution of a BEFORE trigger. Use this to cache
	 * any data required into maps prior execution of the trigger.
	 */
    public void bulkBefore()
    {
        m_UserProfileName = [Select Id, Name from Profile where Id = :System.Userinfo.getProfileId()].Name;
    }
	
    public void bulkAfter()
    {
    }
    
    public void beforeInsert(SObject so)
    {
    }

    /**
	 * @description This method is called before the execution of a before update trigger. 
	 */
    public void beforeUpdate(SObject oldSo, SObject so)
    {
        if(!m_UserProfileName.equals('System Administrator')){
			System.debug('Preventing user from editing a case audit event.');
			// cannot Update Case Audit Events.
			so.addError('Cannot update a Case Audit Event.');
		}
    }
	/**
	 * @description This method is called before the execution of a before delete trigger. 
	 */
    public void beforeDelete(SObject so)
    {
        System.debug('Preventing user from deleting a case audit event.');
        // cannot Delete Case Audit Events.
        so.addError('Cannot delete a Case Audit Event.');
    }

    public void afterInsert(SObject so)
    {        
    }

    public void afterUpdate(SObject oldSo, SObject so)
    {        
    }

    public void afterDelete(SObject so)
    {       
    }

    public void andFinally()
    {
    }
}