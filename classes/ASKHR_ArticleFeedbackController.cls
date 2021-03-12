/*
The controller class for the Lightning Component ASKHR_ArticleFeedback
*/
public with sharing class ASKHR_ArticleFeedbackController {

    /**
     * Description: Method getInitData
     * 
     * This method returns true/false by checking the field Enable_Feedback__c of metadata ASKHR_Global_Setting__mdt
     *
     * @param  recordId Id  - The Id of the Knowledge Article, the user is viewing.
     *
     * @return Boolean - Returns true if the feedback should be visible
     */
    @AuraEnabled
    public static Boolean getInitData(Id recordId) {
        List<ASKHR_Global_Setting__mdt> ratePopupSettings = [Select Enable_Rating_Popup__c, Enable_Later__c, Enable_Feedback__c, Popup_interval__c, Popup_interval_later__c, Randomize__c from ASKHR_Global_Setting__mdt where Active__c = true];
        Boolean mFeedbackIsEnable = true;
        
        if(!ratePopupSettings.isEmpty()){
            mFeedbackIsEnable = ratePopupSettings[0].Enable_Feedback__c;
        }
        
        
        return mFeedbackIsEnable;
    }
   
    /**
     * Description: Method saveFeedback
     * 
     * This method creates a new Article Feedback record with the given description and isArticleHelpful checkbox.
     *
     * @param  recordId         Id       - The Id of the Knowledge Article, for which the feedback is being created.
     * @param  description      String   - The feedback comment entered by the user.
     * @param  isArticleHelpful Boolean  - true/false based on whether the article was useful to the user or not..
     *
     * @return Boolean - Returns true if the feedback is successfully created.
     */
    @AuraEnabled
    public static Boolean saveFeedback(Id recordId, String description, Boolean isArticleHelpful) {
    
        // Check again if the Article is still in same state and also get other fields required to save feedback.
        
        // Feedback is saved only for Artcles with record type AskHR_Article
        //String recordTypeName = System.Label.AskHR_Article;
        List<Knowledge__kav> listKA = [SELECT Id, Title, URLName, KnowledgeArticleId FROM Knowledge__kav WHERE Id = :recordId AND PublishStatus = 'Online'];
        
        Boolean success = false;
        if (listKA.size() > 0) {
        
            // Get Domain Name from Custom Setting 
            ArticleFeedbackDomain__c afd = ArticleFeedbackDomain__c.getValues('Default');
            String domain = '';
            if (UserInfo.getUserType() == 'Standard') {
                domain = afd.PlatformURL__c;
            }
            else {
                domain = afd.CommunityURL__c;
            }
            
            Knowledge__kav article = listKA[0];
            
            // Create the ASKHR_ArticleFeedback__c record;
            ASKHR_ArticleFeedback__c articleFeedback = new ASKHR_ArticleFeedback__c();
            articleFeedback.Knowledge__c = article.Id;
            articleFeedback.Description__c = description;
            articleFeedback.IsArticleHelpful__c = isArticleHelpful;
            
            // When user pressed Yes, the Status should be Closed
            if (isArticleHelpful == true) {
                articleFeedback.Status__c = 'Closed';
            }
            else {
                articleFeedback.Status__c = 'Open';
            }
            // Record Type is 'Feedback'
            articleFeedback.RecordTypeId = Schema.SObjectType.ASKHR_ArticleFeedback__c.getRecordTypeInfosByName().get('Feedback').getRecordTypeId(); // ;
            articleFeedback.Article_Feedback_User__c = UserInfo.getUserId();
            articleFeedback.Article_Name__c = article.Title;
            articleFeedback.ArticleId__c = article.KnowledgeArticleId;
            
            //articleFeedback.Article_Link__c = article.Full_URL__c;
            
            //Note: Based on User coming from community or an internal SF user the Article's Url Link is dynamically formed,
            articleFeedback.Article_Link__c = domain + '/' + article.URLName; //article.Full_URL__c;
            articleFeedback.Location__c = getLocation(article.Title);
            
            insert articleFeedback;
            success = true;
        }
        
        return success;
    }
 
    /**
     * Description: Method getLocation
     * 
     * This method returns the string between ( and ) in the given article title
     *
     * @param  articleNamr String  - The article name.
     *
     * @return String - Returns the string between ( and ) in the input string.
     */
    private static String getLocation(String articleName) {
        try {
            String str = articleName.substring(articleName.indexOf('(') + 1, articleName.indexOf(')'));
            return str;
        } catch(Exception ex) {
            return '';
        }
    }
   
}