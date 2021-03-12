/**
 *@author
 *@description this class is the extension method for CaseAuditViewRecorder
 */

public without sharing class ASKHR_CaseExtension {

    public String caseCloseReason
    {
        get;
        set;
    }

    public String caseCloseComment
    {
        get;
        set;
    }
       
        
    private Case m_Case;
    private List<Case> m_Cases;
    private List<Case> m_ShortListedCases = new List<Case>();
    private ApexPages.StandardController stdController;
    private ApexPages.Standardsetcontroller stdSetController;
    
	//constructor
    public ASKHR_CaseExtension(ApexPages.StandardController stdController)
    {
        this.stdController = stdController;
        this.m_Case = (Case) stdController.getRecord();     
        
    }
	//constructor
    public ASKHR_CaseExtension(ApexPages.Standardsetcontroller stdSetController)
    {
        this.stdSetController = stdSetController;
        this.m_Cases = (List<Case>) stdSetController.getSelected();
        m_ShortListedCases = [Select owner.type,RecordType.DeveloperName, ownerId, status from Case where Id in :m_Cases and status != 'Assigned' and isClosed=false];
    }
    /**
	*@description this method used to update list of cases
	*@return pagereference and redirects to the Visual force page
	*/
        
    public PageReference doAccept(){
        String retURL = ApexPages.currentPage().getParameters().get('retURL');
        PageReference redirectPage;
        // Update records   
        List<Case> casesToUpdate = new List<Case>();    
        for(Case selectedCase : m_ShortListedCases)
        {
            if(selectedCase.owner.type=='Queue'){
                
                // if ER Termination, change status to In Progress
                if (selectedCase.RecordType.DeveloperName == ASKHR_Common.CASE_RECORD_TYPE_NAME_ER_TERMINATION)
                {
                    if(selectedCase.Status == 'New')
                    {
                        selectedCase.Status = 'In Progress';
                    }   
                }

                else
                {
                    if (selectedCase.Status=='New' || selectedCase.Status=='Escalated'){
                        selectedCase.Status = 'Assigned';
                    }   
                }           
                
                selectedCase.OwnerId = UserInfo.getUserId();
                casesToUpdate.add(selectedCase);
            }
        }       
        
        update casesToUpdate;  
        
        //if(m_Cases.size()==1){
        //    redirectPage = new PageReference('/' + ((Case)m_Cases.get(0)).Id); 
        //}else{
                redirectPage = new PageReference('/' + retURL);
                //redirectPage = new PageReference('https://mfcentral--knowledgep.lightning.force.com/lightning/o/Case/list?filterName=00B50000007BH5lEAG');
        //}
        return new ApexPages.Action('{!List}').invoke();
        //return redirectPage;
    }
    
    /**
	*@description this method is used to close the case and creates the case note
	*@return pagereference and redirects to the Visual force page
	*/   
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
            m_Case.Reason = caseCloseReason;
           
                 
                        
            //to compare current recordtype developername with knowledge case record type developername if it matches then do not create case note
           
            if (m_Case.RecordType.DeveloperName != ASKHR_Common.CASE_RECORD_TYPE_NAME_TRANSLATION_KNOWLEDGE_POLICY)
            {
                createCaseNote();                
            }
            
            stdController.save();       
            return redirectPage;
        }
        else
        {
            ApexPages.Message pageMessage = new ApexPages.Message(ApexPages.Severity.ERROR,'Case is already in Closed status!');
            ApexPages.addMessage(pageMessage);
            return null;            
        }
    }

	/**
	*@decription method to create new case note/comment
	*/
    public void createCaseNote(){
        CaseComment cc = new CaseComment();
        cc.CommentBody = caseCloseComment;
        cc.ParentId = m_Case.Id;
        insert cc;
    }
	/**
	*@description method to add case close reason
	*@return list<SelectOption> list of case close reason
	*/
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
        return caseCloseReasons;
    }   
    
    /**
	*@description method to hide Informative/Warning message from user
	*@return pagereference and redirects to the Visual force page
	*/
    public PageReference DismissAlert()
    {
        // Hide Informative/Warning message from user.
        m_Case.Display_Alert__c = false;
        update m_Case;
        
        // referesh page
        PageReference pageRef = ApexPages.currentPage();
        //pageRef.setRedirect(true);
        return pageRef;
    }
    
    public boolean ActionStepAdded {get; set;}
    
    /**
	*@description method to add action steps
	*@return pagereference and redirects to the Visual force page
	*/
    public PageReference AddActionStep()
    {
          
        boolean isValid = true;
        String retURL = ApexPages.currentPage().getParameters().get('retURL');
        PageReference redirectPage;
        if(retURL != null)
            redirectPage = new PageReference('/' + retURL);
        else if(m_Case.ID != null)
            redirectPage = new PageReference('/' + m_Case.ID);
        
        // Ensure date, and action selected.
        if(m_Case.Step_Taken__c == null)
        {
            m_Case.Step_Taken__c.addError('Please select a Step.');         
            isValid = false;
        }
        if(m_Case.Date_Time_of_Action__c == null)
        {
            m_Case.Date_Time_of_Action__c.addError('Please enter a date.');
            isValid = false;
        }
        if(m_Case.Date_Time_of_Action__c > DateTime.Now())
        {
            m_Case.Date_Time_of_Action__c.addError('Please enter a date that is not in the future.');
            isValid = false;
        }
        
        if(isValid)
        {
            //Create a new action and refresh the page.
            Action_Step__c action = new Action_Step__c();
            action.Case__c = m_Case.ID;
            action.Date_Time_of_Action__c = m_Case.Date_Time_of_Action__c;
            action.Step_Taken__c = m_Case.Step_Taken__c;        
    
            // Get number of actions associated with case so far.       
            AggregateResult[] maxSequenceValue = [SELECT MAX(Sequence__c)seq FROM Action_Step__c WHERE Case__c = :m_Case.ID];
            integer maxValue;
            
            if(maxSequenceValue[0].get('seq') != null)
            {
                maxValue =  Integer.valueOf(maxSequenceValue[0].get('seq'));    
            }
            else
            {
                maxValue = 0;
            }
            
            action.Sequence__c = maxValue + 1;
            insert action;
            
            // clear out values in case.
            m_Case.Date_Time_of_Action__c = null;
            m_Case.Step_Taken__c = null;
            
            ActionStepAdded = true;
            return redirectPage;
        }
        else
        {
            ActionStepAdded = false;
            return redirectPage;
        }        
        
    }
    
    public boolean CaseViewAuditEventRecorded {get; set;}
    
    /**
	*@description method to record the user information for audit
	*@return pagereference and redirects to the Visual force page
	*/
    public PageReference RecordCaseViewAuditEvent()
    {
        
        if(CaseViewAuditEventRecorded == false || CaseViewAuditEventRecorded == null)
        {
            ASKHR_CaseAuditEventRecorder.RecordView(this.m_Case.Id, Id.valueOf(UserInfo.getUserId()));
            CaseViewAuditEventRecorded = true;
        }
        return null;
        
    }   
    
   
}