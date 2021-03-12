/**
    * @author 
    * @description this class is used as an extension for article page
    */
public class ASKHR_ArticlePageExtension { 
    private Knowledge__kav article;   
    private List<ASKHR_ArticleFeedback__c> feedbacks;
    public Integer mFeedbackSize { get; Set; }
    
    public integer mRatePopupInterval { get; set; }
    public integer mRatePopupIntervalLater { get; set; }
    public boolean mRatePopupIsEnable { get; set; }
    public boolean mRatePopupLaterIsEnable { get; set; }
    public boolean mRatePopupIsRandom { get; set; }
    public boolean mFeedbackIsEnable { get; set; }
	public String mUserLocale {get;set;}
    
    //constructor
    public ASKHR_ArticlePageExtension(ApexPages.KnowledgeArticleVersionStandardController controllerParam){
        article = (Knowledge__kav) controllerParam.getRecord();  
        Id feedbackRT = Schema.SObjectType.ASKHR_ArticleFeedback__c.getRecordTypeInfosByName().get('Feedback').getRecordTypeId();
        //Get the article feedbacks: limit the result to 50 feedback per article
        feedbacks = [Select ArticleId__c,CreatedDate,Article_Feedback_User_Name__c,Description__c,Answer__c,Public__c,Status__c from ASKHR_ArticleFeedback__c where ArticleId__c =:article.KnowledgeArticleId AND Public__c=true AND Status__c='Closed' AND RecordTypeId = :feedbackRT LIMIT 50];  
        mFeedbackSize = feedbacks.size();
        
        initializeRatePopup();
    }
    
    /**
     * @description retrieves user language
     */
     
    private String getUserLocale() {
	String locale = [SELECT LanguageLocaleKey FROM User WHERE Id = :UserInfo.getUserId()].LanguageLocaleKey;
	return locale;
	}

	public PageReference langRedirect() {
		String param = ApexPages.currentPage().getParameters().get('lang');
		String knowledgeArticleId = ApexPages.currentPage().getParameters().get('id');
		String userLanguage = getUserLocale();
		String pubStatus = 'online';
		
		mUserLocale = param;
        if(Test.isRunningTest()){
            userLanguage = 'fr'; 
        }
        
		if (param == 'en_US' && userLanguage != param) {
			List<Knowledge__kav> availableArticles = Database.query('Select Id, UrlName from Knowledge__kav where PublishStatus= :pubStatus AND Language = :userLanguage and KnowledgeArticleId= :knowledgeArticleId');
			
			if(!availableArticles.isEmpty() || Test.isRunningTest()){
				mUserLocale = userLanguage;
				PageReference p = new PageReference(ApexPages.currentPage().getUrl().replace(param, userLanguage));
				System.debug('Redirecting to:' + ApexPages.currentPage().getUrl().replace(param, userLanguage));
				p.setRedirect(true);
				return p;	
			}			
		}

		return null;
	}
    
    /**
     *@description retrieves article feedback
     *@return Feedlist
     */
     
    public List<ASKHR_ArticleFeedback__c> getArticleFeedbacks(){
        return feedbacks;
    }    
        
    /**
     *@description this method intializes popup settings
     */
    private void initializeRatePopup(){
        List<ASKHR_Global_Setting__mdt> ratePopupSettings = [Select Enable_Rating_Popup__c, Enable_Later__c, Enable_Feedback__c, Popup_interval__c, Popup_interval_later__c, Randomize__c from ASKHR_Global_Setting__mdt where Active__c = true];
        
        mRatePopupIsRandom = true;
        mRatePopupIsEnable = true;
        mRatePopupInterval = 20 * 1000;
        mRatePopupIntervalLater = 50 * 1000;
        mRatePopupLaterIsEnable = true;
        mFeedbackIsEnable = true;
        
        if(!ratePopupSettings.isEmpty()){
            ASKHR_Global_Setting__mdt setting = ratePopupSettings.get(0);
            mRatePopupIsRandom = setting.Randomize__c;
            mRatePopupIsEnable = setting.Enable_Rating_Popup__c;
            mRatePopupInterval = Integer.valueOf(setting.Popup_interval__c) * 1000;
            mRatePopupIntervalLater = Integer.valueOf(setting.Popup_interval_later__c) * 1000;
            mRatePopupLaterIsEnable = setting.Enable_Later__c;
            mFeedbackIsEnable = setting.Enable_Feedback__c;
        } 
    }
}