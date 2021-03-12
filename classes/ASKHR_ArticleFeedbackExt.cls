/**
* @author Mohamad Ammar Amran <mohamadammar_amran@manulife.com>
* @description 
*/
public class ASKHR_ArticleFeedbackExt {
    
    public ASKHR_ArticleFeedback__c articleFeedback { get; set; }
    private List<ASKHR_ArticleFeedback__c> articleFeedbacks;
    private List<ASKHR_ArticleFeedback__c> shorlistedArticleFeedbacks = new List<ASKHR_ArticleFeedback__c> ();
    private ApexPages.StandardController stdController;
    private ApexPages.Standardsetcontroller stdSetController;
    
    public String mEmployeeName { get { if (employee != null) return employee.FirstName; else return ''; } private set; }
    public String mArticleName { get; set; }
    public boolean feedbackSubmitted { get; set; }
    public String description { get; set; }
    public Id mArticleId { get; set; }
    public String mLanguage { get; set; }
    private User employee;
    
    public Id mFeedbackId { get; set; }
    public Id mEmployeeId { get { return employee.Id; } private set; }
    public Id mParentOwner { get; set; }
    public Id mParentUser { get; set; }
    public Id mCommentRecordTypeId { get { return recordTypeId('Comment'); } private set; }
    public Id mFeedbackRecordTypeId { get { return recordTypeId('Feedback'); } private set; }
    public boolean mIsError { get { return this.articleFeedback == null ? true : false; } private set; }
    public boolean mIsAllowComment { get; set; }
    
    //constructor
    public ASKHR_ArticleFeedbackExt() {
        
        this.articleFeedback = new ASKHR_ArticleFeedback__c();
        this.articleFeedback.Status__c = 'Open';
        this.articleFeedback.RecordTypeId = mFeedbackRecordTypeId;
        this.employee = [Select FirstName, LastName from User where Id = :UserInfo.getUserId()];
        this.articleFeedback.Article_Feedback_User__c = employee.Id;
        
    }
    //constructor
    public ASKHR_ArticleFeedbackExt(ApexPages.StandardController stdController)
    {
        try {
            this.stdController = stdController;
            this.articleFeedback = (ASKHR_ArticleFeedback__c) stdController.getRecord();
            this.employee = [Select FirstName, LastName, User_License__c from User where Id = :UserInfo.getUserId()];
            
            if (this.articleFeedback.Id != null) {
                this.articleFeedback = [Select Id, Name, Owner.Name, Status__c, CreatedDate, Description__c, Answer__c, Article_Feedback_User__c from ASKHR_ArticleFeedback__c where Id = :this.articleFeedback.Id];
                mParentOwner = this.articleFeedback.OwnerId;
                mParentUser = this.articleFeedback.Article_Feedback_User__c;
                //only allow comment if the employee owns the feedback and if it still in review
                if (!this.employee.User_License__c.contains('Salesforce'))
                {
                    mIsAllowComment = (this.employee.Id != this.mParentUser || (this.articleFeedback.Status__c.equals('Closed') || this.articleFeedback.Status__c.equals('Archived'))) ? false : true;
                } else {
                    //if the owner still Queue. no comment is allowed
                    mIsAllowComment = !String.isBlank(this.articleFeedback.OwnerId) && ((String) this.articleFeedback.OwnerId).startsWith('00G') ? false : true;
                }
            } else {
                throw new ArticleFeedbackException();
            }
        } catch(Exception ex) {
            this.articleFeedback = null;
        }
    }
    
    //constructor
    public ASKHR_ArticleFeedbackExt(ApexPages.Standardsetcontroller stdSetController)
    {
        this.stdSetController = stdSetController;
        this.articleFeedbacks = (List<ASKHR_ArticleFeedback__c>) stdSetController.getSelected();
        this.shorlistedArticleFeedbacks = [Select owner.type, ownerId, Status__c from ASKHR_ArticleFeedback__c where Id in :articleFeedbacks and Status__c != 'Assigned'];
        system.debug(articleFeedbacks);
    }
    
    /**
* @description retrieves a part of article title name 
* @return String of location 
*/
    private String getLocation(String articleName) {
        try {
            String str = articleName.substring(articleName.indexOf('(') + 1, articleName.indexOf(')'));
            return str;
        } catch(Exception ex) {
            return '';
        }
    }
    
    /**
* @description method to update article
*@return pagereference and redirects to the Visual force page
*/
    public PageReference save() {
        try {
            this.articleFeedback.RecordTypeId = mFeedbackRecordTypeId;
            
            if (!String.isEmpty(this.articleFeedback.Description__C)) {
                
                Id id = mArticleId; //ApexPages.currentPage().getParameters().get('id');//get the knowledge Id
                if (id != null) {
                    
                    String query = 'SELECT Id, title, Full_URL__c, UrlName, LastPublishedDate, KnowledgeArticleId, LastModifiedById' +
                        // '(SELECT dataCategoryGroupName,DataCategoryName FROM DataCategorySelections) ' +
                        ' from Knowledge__kav where (PublishStatus =\'Online\' AND Language= \'' + mLanguage + '\' ) AND Id =\'' + id + '\' AND RecordType.Name =\'' + System.Label.AskHR_Article + '\'';
                    Knowledge__kav article = Database.query(query);
                    
                    this.articleFeedback.Article_Name__c = article.title;
                    this.articleFeedback.ArticleId__c = article.KnowledgeArticleId;
                    this.articleFeedback.Article_Link__c = article.Full_URL__c;
                    this.articleFeedback.Location__c = getLocation(article.title);
                }
                
                ApexPages.StandardController sc = new ApexPages.StandardController(articleFeedback);
                return sc.save();
            } else {
                throw new ArticleFeedbackException('Description is empty');
            }
        } catch(Exception ex) {
            system.debug('error-' + ex.getMessage());
            return null;
        }
    }
    /**
	*@description method to accept single feedback
	*@return pagereference and redirects to the Visual force page
	*/
    
    public PageReference doAccept() {
        if (articleFeedback != null) {
            articleFeedback.Status__c = 'In Review';
            articleFeedback.OwnerId = UserInfo.getUserId();
            update articleFeedback;
        }
        
        return stdController.save();
    }
    
    /**
* @description method to accept multiple feedback in list view
* @return pagereference and redirects to the Visual force page 
*/
    
    public PageReference doAccepts() {
        String retURL = ApexPages.currentPage().getParameters().get('retURL');
        PageReference redirectPage;
        // Update records   
        List<ASKHR_ArticleFeedback__c> feedbackToUpdates = new List<ASKHR_ArticleFeedback__c> ();
        for (ASKHR_ArticleFeedback__c feedbackToUpdate : shorlistedArticleFeedbacks)
        {
            feedbackToUpdate.Status__c = 'In Review';
            feedbackToUpdate.OwnerId = UserInfo.getUserId();
            feedbackToUpdates.add(feedbackToUpdate);
        }
        
        update feedbackToUpdates;
        redirectPage = new PageReference('/' + retURL);
        return new ApexPages.Action('{!List}').invoke();
        //return redirectPage;
    }
    
    /**
* @description method to update archived articles
* @return pagereference and redirects to the Visual force page
*/
    
    public PageReference doArchive() {
        if (articleFeedback != null) {
            articleFeedback.Status__c = 'Archived';
            articleFeedback.Public__c = false;
            update articleFeedback;
        }
        return stdController.save();
    }
    /**
* @description method to retrieve record typeid of given type
* @return id of record type 
*/
    private Id recordTypeId(String type) {
        return Schema.SObjectType.ASKHR_ArticleFeedback__c.getRecordTypeInfosByName().get(type).getRecordTypeId();
    }
    
    public class ArticleFeedbackException extends Exception {}
    
}