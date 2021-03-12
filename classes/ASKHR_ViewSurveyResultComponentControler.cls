public with sharing class ASKHR_ViewSurveyResultComponentControler {

public String surveyId {get;set;}


public String reportId {get;set;}
public PageReference results;

public ASKHR_ViewSurveyResultComponentControler()
{
    ReportFinderUtil rfu = new ReportFinderUtil();
    reportId = rfu.findReportId('Survey with Questions and Responses'); 

}


public pageReference getResults()
{
    surveyId = surveyId.substring(0,15);
    return new PageReference('/' + reportId + '?pv0=' + surveyId);
}

private static testmethod void testResultController()
{
    Survey__c mySurvey = new Survey__c();
    mySurvey.Submit_Response__c = 'empty';  
    insert mySurvey;
    
    ASKHR_ViewSurveyResultComponentControler vsr = new ASKHR_ViewSurveyResultComponentControler();
    vsr.surveyId = mySurvey.Id;
    
    String mySurveyId = mySurvey.Id;
    PageReference pageRef = new PageReference ('/' + vsr.reportId + '?pv0=' + mySurveyId.substring(0,15));
    System.assertEquals(pageRef.getURL(),vsr.getResults().getURL());
    
}

}