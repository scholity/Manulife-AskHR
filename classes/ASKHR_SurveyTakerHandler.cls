public without sharing class ASKHR_SurveyTakerHandler implements ITrigger {

    
    public void bulkBefore()
    {
    }

    public void bulkAfter()
    {
        
        Set<Id> caseIDs;
        if(Trigger.isDelete)
        {
            caseIDs = GetDistinctCaseIDs(Trigger.old);
        }
        else if(Trigger.isInsert)
        {
            caseIDs = GetDistinctCaseIDs(Trigger.new);
        }
        if(caseIDs != null)
        {
            UpdateSurveyTakerCount(caseIDs);
        }
    }
    
    private Set<ID> GetDistinctCaseIDs(List<SurveyTaker__c> surveyTakers)
    {
        Set<Id> caseIDs = new Set<Id>();
        for(SurveyTaker__c s :surveyTakers)
        {
            if(s.Case__c != null)
            {
                System.Debug('Recalculating Survey Taken Count for Case: ' + s.Case__c);
                caseIDs.add(s.Case__c);
            }
        }
        return caseIDs;
    }
    
    private void UpdateSurveyTakerCount(Set<Id> caseIds)
    {
        
        AggregateResult[] groupedResults = [SELECT COUNT(Id) cnt, Case__c FROM SurveyTaker__c WHERE Case__c = :caseIDs GROUP BY Case__c];
        List<Case> casesToUpdate = [SELECT Id, Surveys_Taken_Count__c FROM Case WHERE Id = :caseIds];
        

        for(Case c :casesToUpdate)
        {
            boolean foundCase = false;
            for(AggregateResult ard :groupedResults)
            {
                if(c.Id == ard.get('Case__c'))
                {
                    System.Debug('Survey Taken Count ' + Integer.valueOf(ard.get('cnt')) + ' for Case ' + ard.get('Case__c') );
                    c.Surveys_Taken_Count__c = Integer.valueOf(ard.get('cnt'));
                    foundCase = true;
                    break;
                }
            }
            if(foundCase==false)
            {
                // If case was not found in aggregate result, then that means last survey taken record was deleted.
                c.Surveys_Taken_Count__c = 0;
            }
        }
        update casesToUpdate;
        
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