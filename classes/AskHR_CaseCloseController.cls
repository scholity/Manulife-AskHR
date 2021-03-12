public without sharing class AskHR_CaseCloseController {
    
    public String caseCloseReason
    {
        get;
        set;
    }
    public String caseStatus
    {
        get;
        set;
    }
    public String caseCloseTopic
    {
        get;
        set;
    }
    public String resolution
    {
        get;
        set;
    }
     public String complexity
    {
        get;
        set;
    }
    public Boolean isFunction
    {
        get;
        set;
    }
    
     private Case m_Case;
    private ApexPages.StandardController stdController;
    
    public AskHR_CaseCloseController(ApexPages.StandardController stdController)
    {
        this.stdController = stdController;
        Case m_Case = (Case) stdController.getRecord();   
        this.m_Case = [Select Id, Status,RecordTypeId, Reason from Case where Id = :m_Case.Id];
        system.debug('m_Case.Status'+this.m_Case.Status);
        
        Id profileId=userinfo.getProfileId();
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
        if(profileName == 'ASK HR Administrator'|| profileName =='GHRBS Analyst' || profileName =='GHRBS Manager' || profileName == 'Reporting Analyst' ){
            isFunction = true;
        }
        
    }
    public PageReference doCaseClose()
    {        
        String retURL = ApexPages.currentPage().getParameters().get('retURL');
        String currentId = ApexPages.currentPage().getParameters().get('id');
        PageReference redirectPage;
        Id RecordTypeId;
        if(retURL != null)
            redirectPage = new PageReference('/' + retURL);
        else if(currentId != null)
            redirectPage = new PageReference('/' + currentId);
        
        if(m_Case.Status!='Closed')
        {
            m_Case.Status = 'Closed';
            if(!String.isBlank(caseCloseReason))
            m_Case.Reason = caseCloseReason;
            if(!String.isBlank(caseCloseTopic))
            m_case.Type = caseCloseTopic;
            if(!String.isBlank(resolution))
            m_case.Resolution__c = resolution;
            update m_Case;
            stdController.save();      
            //directPage.setRedirect(true);
            return redirectPage;
            
        }
        else
        {
            ApexPages.Message pageMessage = new ApexPages.Message(ApexPages.Severity.ERROR,'Case is already in Closed status!');
            ApexPages.addMessage(pageMessage);
            return null;            
        }
    }
    
       public List<SelectOption> getCaseCloseReasons() {
           List<SelectOption> caseCloseReasons = new List<SelectOption>();
           
           //<adnan.khan> This doesn't work right now for PickListValues based on record types. 
           //<adnan.khan> Use this when there is provision in Apex to dynamically populate the list.
           
           //Schema.DescribeFieldResult dfr = Case.Reason.getDescribe();
           //for (Schema.PicklistEntry ple : dfr.getPicklistValues()) {
           //    caseCloseReasons.add(new SelectOption(ple.getValue(), ple.getLabel(), !ple.isActive()));
           //}
           caseCloseReasons.add(new SelectOption('Resolved','Resolved'));
           caseCloseReasons.add(new SelectOption('Escalated','Escalated'));
           caseCloseReasons.add(new SelectOption('Duplicate','Duplicate'));
           caseCloseReasons.add(new SelectOption('Call Transferred','Call Transferred'));
           


        return caseCloseReasons;
    }  
    public List<SelectOption> getCaseStatusValues() {
        List<SelectOption> caseStatusValues = new List<SelectOption>();
        
        caseStatusValues.add(new SelectOption('Closed','Closed'));
        
        return caseStatusValues;
           }
    
    public List<SelectOption> getTopics(){
        
        List<SelectOption> caseCloseTopics = new List<SelectOption>();
        //Resolution__c
        Schema.DescribeFieldResult dfr = Case.Type.getDescribe();
        for (Schema.PicklistEntry ple : dfr.getPicklistValues()) {
            
            caseCloseTopics.add(new SelectOption(ple.getValue(), ple.getLabel(), !ple.isActive()));
        }
        return caseCloseTopics;
        
    }
    
     public List<SelectOption> getResolutions(){
        
        List<SelectOption> caseCloseResolutions = new List<SelectOption>();
        //Resolution__c
        Schema.DescribeFieldResult dfr = Case.Resolution__c.getDescribe();
        for (Schema.PicklistEntry ple : dfr.getPicklistValues()) {
            
            caseCloseResolutions.add(new SelectOption(ple.getValue(), ple.getLabel(), !ple.isActive()));
        }
        return caseCloseResolutions;
        
    }
    
    public List<SelectOption> getCaseComplexity(){
        
        List<SelectOption> caseComplexity = new List<SelectOption>();
        //Resolution__c
        Schema.DescribeFieldResult dfr = Case.Complexity__c.getDescribe();
        for (Schema.PicklistEntry ple : dfr.getPicklistValues()) {
            
            caseComplexity.add(new SelectOption(ple.getValue(), ple.getLabel(), !ple.isActive()));
        }
        return caseComplexity;
        
    }
    

}