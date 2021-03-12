public with sharing class ASKHR_CaseUpdatedVFController{
    
    public Id mCaseId { get; set;}
    public String mInput { get; set;}
    public String mOutput { get { return replaceField(); } set; }
    
    public ASKHR_CaseUpdatedVFController(){
        
    }
    
    public String replaceField(){
        
        String result = mInput;
        
        if(mInput == null)mInput = '';       
        
        if(mCaseId != null ){
            Case updatedCase = [Select Id, CaseNumber, Subject from Case where Id = :mCaseId];
            String subject = updatedCase.Subject != null ? updatedCase.Subject : '';
            String history = getLatestHistory();
            
            result = mInput.replace('{!Case.Id}', updatedCase.Id)
                .replace('{!Case.Subject}', subject)
                .replace('{!Case.CaseNumber}', updatedCase.CaseNumber)
                .replace('{!recentHistory}', history);
        }else{
            result = mInput;
        }
        return result;
    }
    
    private List<CaseHistory> getCaseHistories(){
        List<CaseHistory> caseHistories = new List<CaseHistory>();
        
        if(!Test.isRunningTest()){
            caseHistories = [Select CreatedById, CreatedDate, OldValue, NewValue, Field, IsDeleted from CaseHistory where CaseId = :mCaseId Order By Id Desc];
        }
        return caseHistories;
    }
    
    private String getLatestHistory(){
        List<CaseHistory> caseHistories = getCaseHistories();
        Map<DateTime, List<CaseHistory>> chMap = new Map<DateTime, List<CaseHistory>>();
        System.debug('Case Histories: ' + caseHistories.size());
        for(CaseHistory ch : caseHistories){
            List<CaseHistory> listCh = new List<CaseHistory>();
            if(chMap.containsKey(ch.CreatedDate)){
                listCh = chMap.get(ch.CreatedDate);
            }
            
            listCh.add(ch);
            chMap.put(ch.CreatedDate, listCh);            
        }
        
        List<DateTime> latests = new List<DateTime>();        
        DateTime tmpLatest = null;
        
        //get the latest history only
        for(DateTime key : chMap.keySet()){
            system.debug('key :' +key);
            if(tmpLatest == null || tmpLatest < key){
                tmpLatest = key;
            }
        }
        
        if(tmpLatest != null)latests.add(tmpLatest);
        
        for(DateTime key : chMap.keySet()){
            if(key != tmpLatest && isDateWithin15Minutes(tmpLatest, key)){
                latests.add(key);
            }
        }
        
        String createdDate;
        String name;
        Id userId;
        String history = '';        
        String tmpName= '';
        
        for(DateTime latest : latests){
            List<CaseHistory> latestCH = chMap.get(latest);   
            tmpName= '';
            for(CaseHistory ch : latestCH){                
                if(userId == null || !userId.equals(ch.CreatedById)){
                    userId = ch.CreatedById;
                    User chUser = [Select FirstName, LastName from User where Id = :ch.CreatedById];
                    name = chUser.FirstName + ' ' + chUser.LastName;
                    createdDate = ch.CreatedDate.format('dd/MM/yyyy HH:mm');
                }
                
                tmpName = !tmpName.equals(name) ? name : ''; 
                String field = ch.Field != null ? ((string)ch.Field).replace('__c', ''): '';
                String oldValue = ch.OldValue != null ? (String)ch.OldValue : '';
                String newValue = ch.NewValue != null ? (String)ch.NewValue : '';
                String description = !ch.IsDeleted ? 'Changed' : 'Deleted';
                
                if(!skipIdsValue(newValue,oldValue)){            
                    if(!String.isBlank(tmpName)){
                        history += '(' + createdDate + ') Modified by: '+ tmpName + '\n';
                    }            
                    
                    history += description + ' ' + field;
                    if(!String.isBlank(oldValue)){
                        history += ' from ' + oldValue;
                    }
                    
                    if(!String.isBlank(newValue)){
                        history += ' to ' + newValue; 
                    }
                    
                    history += '\n';
                }else{
                    userId = null;
                    tmpName = 'none';
                }
            }
            
            history += '\n';
        }
        
        return history;
    }
    
    private boolean skipIdsValue(String value1, String value2){
        boolean result = false;
        if(value1.startsWith('003') || value1.startsWith('00G') || value1.startsWith('005'))
            result = true;
        
        if(value2.startsWith('003') || value2.startsWith('00G') || value2.startsWith('005'))
            result = true;
        
        return result;
    }
    
    private boolean isDateWithin15Minutes(DateTime latest, DateTime date1){
        Double minutes = Math.Floor((latest.getTime() - date1.getTime())/ (1000.0*60.0));
        if(minutes < 15){ //get changes within 15 minutes
            return true;
        }else
            return false;
    }
}