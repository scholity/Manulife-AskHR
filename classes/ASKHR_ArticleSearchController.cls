/**
	* @author Mohamad Ammar Amran <mohamadammar_amran@manulife.com>
	* @description Article search controller for handling searching article in the custom Article List page
	*/
public with sharing class ASKHR_ArticleSearchController {

    //public String language { get{ return selectedLanguage; } set;}
    public boolean isShowNoResultFound { get; set; }
    //Page Size
    //private Static Final Integer PAGE_NUMBER = 10;
    //Search String used in ArticleList tag
    public String searchString { get; set; }
    //Is new List reqd
    private boolean isRefRequired = true;
    //Exclude filter criteria for UI only
    private static final String EXCLUDE_CRITERIA_FILTER = 'All';
    //Keeps track of current page & max size of article list
    Integer currentPage = 1;
    Integer maxSize = 1;
    public Integer mPageSize { get; set; } //value that will change

    public Id mFeedbackRecordTypeId { get { return recordTypeId('Feedback'); } private set; }
    public String selectedLanguage { get; set; } // This will hold the selected value, the id in here
    public String selectedTopic { get; set; }
    public String mTopicParam { get; set; }
    public String selectedGeography { get; set; }
    public String notFoundMessage { get { return Label.ASKHR_ArticleNotFoundLabel + ' <br />' + Label.ASKHR_ArticleNotFoundLabel_2; } private set; }

    public String mUserLanguage { get { return UserInfo.getLanguage(); } set; }
    private List<ASKHR_ArticleFeedback__c> mFeedbacks;
    public Boolean initFeedback { get; set; }
    public Boolean mHasFAQ { get { return mFeedbacks != null && mFeedbacks.size() > 0 ? true : false; } Set; }

    //contstructor
    public ASKHR_ArticleSearchController() {
        isShowNoResultFound = false;
        initFeedback = false;
        //default language 
        selectedLanguage = mUserLanguage;
        
        //set default value, global setting will overwrite this value
        mPageSize = 20;
        
        setGlobalSetting();
        
        PageReference pageRef = ApexPages.currentPage();
        String searchParam = pageRef.getParameters().get('search');
        String topicParam = pageRef.getParameters().get('topic');
        if(!string.isBlank(searchParam)){
            searchString = searchParam;
        }
        
        mTopicParam = null;
        if(!string.isBlank(topicParam)){
            mTopicParam = topicParam;
        } 
    } 

    private void setGlobalSetting(){
        List<ASKHR_Global_Setting__mdt> settings = [Select Article_Max_Size__c from ASKHR_Global_Setting__mdt limit 1];
        if(!settings.isEmpty()){
            ASKHR_Global_Setting__mdt setting = settings[0];
        	mPageSize = (integer)setting.Article_Max_Size__c;
        }
    }
    /**
     *@description this method used to retrieve data category group info
     *@return String data category group info has been assigned to user, true - Yes, false - NO
	*/
    public String getDataCategoryGroupInfoAsJSON() {
        return JSON.serialize(ASKHR_ArticleDataCategoryUtil.getInstance().getAllCategoryGroups());
    }

    /**
	 *@description this method used to retrieve general feedback
     *@returns List<ASKHR_ArticleFeedback__c> List of general feedbacks
	*/
    public List<ASKHR_ArticleFeedback__c> getGeneralFeedbacks() {
        if (initFeedback) {
            //Get the General Feedbacks: limit to 50 feedback to be displayed
            mFeedbacks = [Select ArticleId__c, CreatedDate, Article_Feedback_User_Name__c, Description__c, Answer__c, Public__c, Status__c from ASKHR_ArticleFeedback__c where ArticleId__c = '' AND Public__c = true AND Status__c = 'Closed' AND RecordTypeId = :mFeedbackRecordTypeId LIMIT 50];
            return mFeedbacks;
        }else{
            return new List<ASKHR_ArticleFeedback__c>();
        }
    }
	/**
	 *@description this method used to retrieve catergory keyword required to filter articleList
     *@returns String of category keyword 
	*/
    public String getCategoryKeyword() {
        String categoryCondition = '';
        if (!String.isBlank(selectedTopic) && !selectedTopic.equals(Label.ASKHR_Article_NoFilter)) {
            categoryCondition = 'Topic:' + selectedTopic;
        }

        if (!String.isBlank(selectedGeography) && !selectedGeography.equals(Label.ASKHR_Article_NoFilter)) {
            if (String.isBlank(categoryCondition)) {
                categoryCondition = 'Geography:' + selectedGeography;
            } else {
                categoryCondition += ',Geography:' + selectedGeography;
            }
        }
         
        String categoryFilter = '';
        if (!String.isBlank(selectedTopic) && !selectedTopic.equals(Label.ASKHR_Article_NoFilter)) {
            categoryFilter = 'Topic__c ABOVE_OR_BELOW ' + selectedTopic + '__c';
        }

        if (!String.isBlank(selectedGeography) && !selectedGeography.equals(Label.ASKHR_Article_NoFilter)) {
            if (String.isBlank(categoryFilter)) {
                categoryFilter = 'Geography__c ABOVE_OR_BELOW ' + selectedGeography + '__c';
            } else {
                categoryFilter += ' AND Geography__c ABOVE_OR_BELOW ' + selectedGeography + '__c';
            }
        }

        try {
            if (categoryFilter.length() > 0) {
                if (searchString != null && searchString.length() > 0) {
                    String searchquery = 'FIND \'' + searchString + '*\' IN ALL FIELDS RETURNING KnowledgeArticleVersion(Id, title, UrlName, LastPublishedDate,LastModifiedById where PublishStatus =\'online\' and Language = \'' + selectedLanguage + '\') WITH DATA CATEGORY ' + categoryFilter;
                    List<List<SObject>> searchList = search.query(searchquery);
                    List<KnowledgeArticleVersion> articleList =
                    (List<KnowledgeArticleVersion>) searchList[0];
                    maxSize = articleList.size();
                } else {
                    String qryString = 'SELECT Id, title, UrlName, LastPublishedDate,LastModifiedById FROM KnowledgeArticleVersion WHERE (PublishStatus = \'online\' and Language = \'' + selectedLanguage + '\') WITH DATA CATEGORY ' + categoryFilter;
                    List<KnowledgeArticleVersion> articleList = Database.query(qryString);
                    maxSize = articleList.size();
                }
            } else {
                if (!string.isBlank(searchString)) {
                    String searchquery = 'FIND \'' + searchString + '*\' IN ALL FIELDS RETURNING KnowledgeArticleVersion(Id, title, UrlName, LastPublishedDate,LastModifiedById where PublishStatus =\'online\' and Language = \'' + selectedLanguage + '\')';
                    List<List<SObject>> searchList = search.query(searchquery);
                    List<KnowledgeArticleVersion> articleList = !searchList.isEmpty() ? (List<KnowledgeArticleVersion>) searchList[0] : new List<KnowledgeArticleVersion>();
                    maxSize = articleList.size(); 
                } else {
                    String qryString = 'SELECT Id, title, UrlName, LastPublishedDate,LastModifiedById FROM KnowledgeArticleVersion WHERE (PublishStatus = \'online\' and Language = \'' + selectedLanguage + '\')';
                    List<KnowledgeArticleVersion> articleList = Database.query(qryString);
                    maxSize = articleList.size();
                }                
            }

        } catch(Exception e) {
            Apexpages.addmessages(e);
        }
        if (categoryFilter == '') {
            categoryCondition = '';
        }
 
        isShowNoResultFound = maxSize == 0 ? true : false; 
        
        system.debug(categoryCondition);
        return categoryCondition;
    }

    /**
	 *@description this method used to refresh general FAQ
     *@returns PageReference
	*/
    public PageReference refreshGeneralFaq() {
        return null;
    }
    
    /**
	 *@description this method used to retrieve new list
     *@returns PageReference
	*/
    
    public PageReference refreshSearchResult() {
        maxSize = currentPage = 1;
        return null;
    }

    /**
	 *@description this method returns whether we need to see next button or not
     *@returns boolean next button true or false
	*/
        
    public boolean getNextRequired() {
        return mPageSize < maxSize;
    }
    
    /**
	 *@description this method returns current page number
     *@returns decimal current page number
	*/
    
    public Decimal getCurrentPageNumber() {
        //return this.currentPage;
        return currentPage;
    }

    /**
	 *@description this method is the action for the next click
     *@Returns pagereference
	*/
    
    public PageReference next() {
        mPageSize = mPageSize + 20; //increase page size by 10
        return null;
    }


    /**
	 *@description this method used to retrieve the record type id
     *@Returns Id of record type Id 
	*/
    private Id recordTypeId(String type) {
        return Schema.SObjectType.ASKHR_ArticleFeedback__c.getRecordTypeInfosByName().get(type).getRecordTypeId();
    }
}