/**
* @author Mohamad Ammar Amran <mohamadammar_amran@manulife.com>
* @description Trigger handler for Action Step
*/
public class ASKHR_ActionStepHandler implements ITrigger
{
    /**
     * Update the latest action taken for the Case
     * @param Action object (Inserted, Updated or Deleted)
     */
    @TestVisible
    private void updateLatestAction(Action_Step__c action)
    {
        //Get the action item with the latest date 
        String caseId=action.Step_Taken__c;

        List<Action_Step__c> latestActions=new List<Action_Step__c>(); 
            /*changing for Shield Encrytion 
			 Sequencing by latest Action created and not by Date_Time_of_Action__c */                                                                                        
        latestActions =[select Id,case__c, Sequence__c, Date_Time_of_Action__c, Step_Taken__c FROM Action_Step__c WHERE Case__c  = :action.Case__c ORDER BY Sequence__c DESC]; 

     

        //Retrieve the parent Case object
        Case caseObject = [
            SELECT Id, Latest_Action_Step__c, Latest_Action_Taken__c, Latest_Action_Date__c
            FROM Case
            WHERE Id = :action.Case__c
            LIMIT 1
        ];

        Action_Step__c latestAction;
        
        if(latestActions.size() > 0)
            latestAction = latestActions[0];
        else
        {
            latestAction = new Action_Step__c();
            latestAction.Sequence__c = null;
            latestAction.Step_Taken__c = 'Delete';
            latestAction.Date_Time_of_Action__c = DateTime.now();
        }
            
        //Modify the action fields
        caseObject.Latest_Action_Step__c = latestAction.Sequence__c;
        caseObject.Latest_Action_Taken__c = latestAction.Step_Taken__c;
        caseObject.Latest_Action_Date__c = latestAction.Date_Time_of_Action__c;

        update caseObject;
    }

    public void bulkBefore()
    {
    }

    public void bulkAfter()
    {
    }

    public void beforeInsert(SObject so)
    {
        
    }

    public void beforeUpdate(SObject oldSo, SObject so)
    {
         
    }

    public void beforeDelete(SObject so)
    {
        
    }

    public void afterInsert(SObject so)
    {
        updateLatestAction((Action_Step__c)so);
    }

    public void afterUpdate(SObject oldSo, SObject so)
    {
        updateLatestAction((Action_Step__c)so);
    }

    public void afterDelete(SObject so)
    {
        updateLatestAction((Action_Step__c)so);
    }

    public void andFinally()
    {
    }
}