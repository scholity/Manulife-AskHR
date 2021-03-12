public class ASKHR_ArticleFeedbackEmailController {
    public String mArticleFeedbackId { get; set; }
    public String mArticleFeedbackName { get; set; }
    public String mRecipientName { get; set; }
    public String mSurveyLink { get; set; }
    public Boolean mNewFeedback { get; set; }
    
    public ASKHR_ArticleFeedbackEmailController(){
        List<ASKHR_Global_Setting__mdt> settings = [Select Sandbox__c, Article_Feedback_Console_URL__c,Article_Feedback_Console_URL_Sandbox__c from ASKHR_Global_Setting__mdt where Active__c = true LIMIT 1];
        
        if (settings != null && !settings.isEmpty()) {
            ASKHR_Global_Setting__mdt setting = settings.get(0);
            mSurveyLink = setting.Article_Feedback_Console_URL__c;
            // mSurveyLink = 'https://mfcentral--c.na3.visual.force.com/console#https://mfcentral--c.na3.visual.force.com/'+mArticleFeedbackId;
            if (setting.Sandbox__c == true) {
                mSurveyLink = setting.Article_Feedback_Console_URL_Sandbox__c;
            }
        }
       
    }
    
}