/**
 *@description this class is the extension class for Visualforce Page ASKHR_CustomChangeListCaseOwner
*/

public without sharing class ASKHR_CustomChangeCaseOwnerExtension {
    
    public String selectedUserType { get; set; } // This will hold the selected value, the id in here
    public String selectedGroup { get; set; }
    public String selectedUser { get; set; } 
    public boolean IsShowQueue { get; set; }
    public String IsShowUser { get; set; }
    public String caseNumbers { get; set; }
    
    //manually handling the field required error
    public String errorMessage { get; set; }
    public String IsShowError { get; set; } { IsShowError = 'none'; }
    public List<SelectOption> userTypeList { get; set; }
    public List<SelectOption> queueList { get; set; }
    private String mProfile;
    private String mRole;
    
    private static Id currentOwner;
    private ASKHR_CustomChangeCaseOwnerAdapter m_ControllerAdapter;   
    //constructor
    public ASKHR_CustomChangeCaseOwnerExtension (ApexPages.StandardController controller) {
        m_ControllerAdapter = ASKHR_CustomChangeCaseOwnerAdapter.adapt(controller);
        initiliazeComponents();         
    }
    //constructor
    public ASKHR_CustomChangeCaseOwnerExtension (ApexPages.StandardSetController controller) {         
        m_ControllerAdapter = ASKHR_CustomChangeCaseOwnerAdapter.adapt(controller);         
        initiliazeComponents();          
    }
    /**
     *@descritpion initialze components 
	*/
    private void initiliazeComponents(){
        Profile[] currUserProfile = [Select Name from Profile where Id =: UserInfo.getProfileId()];
        mProfile = currUserProfile.size() > 0 ? currUserProfile[0].Name : '';
        
        UserRole[] currUserRole = [Select Name from UserRole where Id =: UserInfo.getUserRoleId()];
        mRole = currUserRole.size() > 0 ? currUserRole[0].Name : '';
        
        userTypeList = getUserTypeList();
        queueList = getGroupsListFromCMT();  
        
        toggleField(true);
        selectedGroup = '';    
        selectedUserType = 'Queue';
        
        List<Case> cases = [Select Id, CaseNumber, OwnerId, Owner.Type from Case where Id in :m_ControllerAdapter.getSelected()];
        
        List<String> caseNumbers = new List<String>();
        for(Case tmpCase: cases){
            caseNumbers.add(tmpCase.CaseNumber);
        }
        this.caseNumbers = String.join(caseNumbers,', ');
    }
    
    /**
    *@descritpion this method is used to toggle to show queue and user
	*/
    private void toggleField(boolean isQueue){
        if(isQueue){ 
            IsShowQueue = true;
            IsShowUser = 'none'; 
        }else{ 
            IsShowQueue = false;
            ISShowUser = 'visible';
        }
    }
    /**
    *@description this method gets user type list
	*@return List<SelectOption> returns list of added options
	*/
    public List<SelectOption> getUserTypeList(){
        List<SelectOption> optns = new List<SelectOption>();
        optns.add(new SelectOption('User', 'User'));
        optns.add(new SelectOption('Queue', 'Queue'));
        return optns;
    } 
    /**
    *@description this method used to check wheather the profile that received in the admin list or not
	*@param String[] adminList list of admin list
	*@param String profile list of profiles
	*@return boolean of user existence
	*/
    private boolean containsProfile(String[] adminList, String profile){
        if(!String.isBlank(profile)){
            for(String admin : adminList){
                if(admin.trim().equalsIgnoreCase(profile)){
                    return true;
                }
            }
        }
        
        return false;
    }
    /**
	*@description method to change the owner
	*@return pagereference redirects to the Visual force page
	*/
    public PageReference doChangeOwner(){
        
        try{                       
            String id = '';
            String status;
            String name = '';
            //as per requirement AHP-275
            //Send To Queue = Escalated
            //Send to User = Assigned
            if(IsShowUser == 'visible'){
                id = ApexPages.currentPage().getParameters().get('newOwn_lkid');
                name = ApexPages.currentPage().getParameters().get('newOwn');
                status = 'Assigned';
            }else if(IsShowQueue){
                id = selectedGroup;
                status = 'Escalated';
                name = selectedGroup == null ? 'none' : selectedGroup;
            }          
            
            if(name == '' || name == 'none' || id == '' ){
                IsShowError = 'visible';
                errorMessage = System.Label.ASKHR_CaseSendTo_Required_Field;
                return null;
            }else{
                IsShowError = 'none';
                
                List<Case> cases = m_ControllerAdapter.getSelected();
                for(Case tmpCase : cases){
                    tmpCase.Status = status;
                    tmpCase.OwnerId = id;
                }
                update cases;
                PageReference redirectPage = m_ControllerAdapter.save();          
                
                return redirectPage;
            }      
        }catch(Exception ex){
			return null;
        }    
    }
   
    public void hideQueueInputOnChange()
    {
        if(selectedUserType == 'User') toggleField(false);
        else toggleField(true);       
        
        IsShowError = 'none';   
    } 
    /**
    *@description this method is used to get group list from Custom meta data
	*@return List<SelectOption> returns list of options of given type
	*/
    private List<SelectOption> getGroupsListFromCMT(){
        List<SelectOption> optns = new List<Selectoption>();
        
        String appendQuery = querySetting();
        
        String query = 'select Id,Name from Group where Type = \'Queue\' AND ' + appendQuery;
        System.debug('query:' + query);
        List<Group> groups = Database.query(query);
        
        optns.add(new SelectOption('none',''));
        
        // before getting here you must populate your queryResult list with required fields
        for(Group obj : groups){
            optns.add(new SelectOption(obj.Id, obj.Name));
        }            
        
        return optns;
    }
    /**
    *@description this method used to form a query filter based on role or profile settings from custom meta data type setting
	*@return String of query filter
	*/
    private String querySetting(){
        String filter = '';
        String query;
        Boolean isIncludeDefault = false;
        Boolean isByProfile = false;
        List<ASKHR_SendTo_Setting__mdt> settings = null;
        
        if(!String.isBlank(mRole)){
            query = 'Select Admin_Filter_List__c,Admin_List__c, Filter_List__c,Include_Default__c, Role_ToFilter__c ' +
                'from ASKHR_SendTo_Setting__mdt where ' + 
                'Active__c= true AND (Enable_Role_Filter__c = true AND Role_ToFilter__c Like \'%' + mRole + '%\')';
            settings = Database.query(query);
            
            if(settings.size() > 0){
                filter +='(';
                for(Integer i = 0; i < settings.size(); i++){
                    
                    ASKHR_SendTo_Setting__mdt setting = settings.get(i);
                    filter += getFilter(setting);
                    
                    if(setting.Include_Default__c){
                        isIncludeDefault = true;
                    }
                    
                    if(i < settings.size()-1){
                        filter += ' OR ';
                    }
                }
                
                if(isIncludeDefault){
                    filter += ' OR ' + queryDefault();
                }
                
                filter += ')';
            }else{
                isByProfile = true;
            }
        }else{
            isByProfile = true;
        }
        
        if(isByProfile){
            query = 'Select Admin_Filter_List__c,Admin_List__c, Filter_List__c,Include_Default__c, Role_ToFilter__c ' +
                'from ASKHR_SendTo_Setting__mdt where ' + 
                'Active__c= true AND (Enable_Role_Filter__c = true AND Admin_List__c Like \'%' + mProfile + '%\')';
            settings = Database.query(query);
            
            if(settings.size() > 0){
                filter +='(';
                for(Integer i = 0; i < settings.size(); i++){
                    
                    ASKHR_SendTo_Setting__mdt setting = settings.get(i);
                    filter += getFilter(setting);
                    
                    if(setting.Include_Default__c){
                        isIncludeDefault = true;
                    }
                    
                    if(i < settings.size()-1){
                        filter += ' OR ';
                    }
                }
                
                if(isIncludeDefault){
                    filter += ' OR ' + queryDefault();
                }
                
                filter += ')';
            }
            else{
                //get default
                filter = '(' + queryDefault() + ')';
            }
        }
        return filter;
    }
     /**
    *@description this method used to form a query filter with default setting
	*@return String of query filter
	*/
    private String queryDefault(){
        ASKHR_SendTo_Setting__mdt[] defaultSettings = [Select Admin_Filter_List__c, 
                                                       Admin_List__c, Filter_List__c from ASKHR_SendTo_Setting__mdt where Default_Filter__c = true and Active__c=true];
        
        String query = '';
        if(defaultSettings.size() > 0){
            ASKHR_SendTo_Setting__mdt defaultSetting = defaultSettings[0];
            String[] filters = defaultSetting.Filter_List__c.split(',');
            
            for(Integer row = 0; row < filters.size(); row++){
                query += ' Name LIKE \'' + String.escapeSingleQuotes(filters[row].trim()) + '\'';
                
                if(row < filters.size()-1) query += ' OR ';
            } 
            
            String[] adminList = defaultSetting.Admin_List__c != null ? defaultSetting.Admin_List__c.split(',') : new String[0];
            if(containsProfile(adminList, mProfile)){
                if(!String.isBlank(defaultSetting.Admin_Filter_List__c)){
                    String[] adminFilter = defaultSetting.Admin_Filter_List__c.split(',');              
                    
                    if(filters.size() > 0) query += ' OR ';
                    
                    for(Integer row = 0; row < adminFilter.size(); row++){                    
                        query += ' Name LIKE \'' + String.escapeSingleQuotes(adminFilter[row].trim()) + '\'';                    
                        if(row < adminFilter.size()-1) query += ' OR ';
                    }      
                }
            }            
            
        }              
        
        return query;
    }
    /**
    *@description gets the filter of the custom Metadata Type settings
	*@return String of query Filter
	*/
    private String getFilter(ASKHR_SendTo_Setting__mdt setting){
        String query = '';
        
        String[] filters = setting.Filter_List__c.split(',');
        
        for(Integer row = 0; row < filters.size(); row++){
            query += ' Name LIKE \'' + String.escapeSingleQuotes(filters[row].trim()) + '\'';
            
            if(row < filters.size()-1) query += ' OR ';
        } 
        
        String[] adminList = setting.Admin_List__c != null ? setting.Admin_List__c.split(',') : new String[0];
        if(containsProfile(adminList, mProfile)){
            if(!String.isBlank(setting.Admin_Filter_List__c)){
                String[] adminFilter = setting.Admin_Filter_List__c.split(',');              
                
                if(adminFilter.size() > 0) query += ' OR ';
                
                for(Integer row = 0; row < adminFilter.size(); row++){                    
                    query += ' Name LIKE \'' + String.escapeSingleQuotes(adminFilter[row].trim()) + '\'';                    
                    if(row < adminFilter.size()-1) query += ' OR ';
                }
            }
        }            
        
        return query; 
    }
}