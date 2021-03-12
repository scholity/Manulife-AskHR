/**
*@description this class is controller class for vf component used in email template
*/

public without sharing class ASKHR_EmailTemplateVFCompController {
    public String mRelatedToId { get; set; }
    public String mRecipientId { get; set; }
    
    public String mInput { get;set; }
    public String mOutput { get{return replaceField(); } set; }
    public ASKHR_EmailTemplateVFCompController(){
        
    }
    
    /**
	*@description 
	*1. Search this pattern, {!SObject.fieldname} from the input( in this case is the custom label).
	*2. The system only accept 4 SObject which are "recipient", "contact", "relatedTo" and "case". 
	*3. "recipient" and "contact" are categorize as contact; "relatedTo" and "case" are categorize as case
	*4. Compare the fieldName with the all available field name of the object, if exists add into FieldForQuery...
	*5. Start to query the value from the FieldForQuery... and replace the {!SObject.fieldName} with the value from the query.
	*/
    
    public String replaceField(){
        Set<String> toReplace = new Set<String>();
        Set<String> fieldsForQueryForCase = new Set<String>();
        Set<String> fieldsForQueryForContact = new Set<String>(); 
        
        DescribeSObjectResult contactField = Contact.SObjectType.getDescribe();
        Set<String> allContactFields = new Set<String>(contactField.fields.getMap().keySet()); //get all available fields to ensure the Get method work
        
        DescribeSObjectResult caseField = Case.SObjectType.getDescribe();
        Set<String> allCaseFields = new Set<String>(caseField.fields.getMap().keySet());
        
        String mydata = mInput;
         //replace link
        mydata = !String.isBlank(mRelatedToId) ? mydata.replace('<surveylink>', replaceSurveyURL()) : mydata;
        
        Pattern myPattern = Pattern.compile('(?m)\\{(.+?)\\}'); //regex pattern for "{!SOBJECT.FIELDNAME}"
        Matcher myMatcher = myPattern.matcher(mydata);
        
        while (myMatcher.find())
        {
            string mergeField = myMatcher.group();  //return the value of {!SOBJECT.FIELDNAME}
            if (!toReplace.contains(mergeField))
            {
                toReplace.add(myMatcher.group());
                
                if (mergeField.containsIgnoreCase('recipient') || mergeField.containsIgnoreCase('Contact'))
                {
                    String fieldName = mergeField.substringBetween('.','}'); 
                    if (allContactFields.contains(fieldName.toLowerCase()))
                    {
                        if(!fieldsForQueryForContact.contains(fieldName.toLowerCase())){ 
                            fieldsForQueryForContact.add(fieldName.toLowerCase());
                        }
                    }
                }
                else if (mergeField.containsIgnoreCase('relatedTo') || mergeField.containsIgnoreCase('Case'))
                {
                    String fieldName = mergeField.substringBetween('.','}');
                    if (allCaseFields.contains(fieldName.toLowerCase()) || fieldName.containsIgnoreCase('owner'))
                    {
                        if(!fieldsForQueryForCase.contains(fieldName.toLowerCase())){
                            fieldsForQueryForCase.add(fieldName.toLowerCase());
                        }
                    }
                }
            }           
        }
        
        if (!String.isBlank(mRecipientId) && fieldsForQueryForContact.size() >= 1)
        {
            String queryContact = 'SELECT ' + String.join(new List<String>(fieldsForQueryForContact), ', ') + ' FROM Contact WHERE Id=:mRecipientId';
            Contact co = Database.query(queryContact);
            
            for (string str: toReplace)
            {
                if (str.containsIgnoreCase('recipient') || str.containsIgnoreCase('Contact')){
                    String fieldName = str.substringBetween('.','}');
                    fieldName = fieldName.trim();
                    if (allContactFields.contains(fieldName.toLowerCase()))
                    {
                        Object c = co.get(fieldName);
                        String value = String.valueOf(c);
                        value = String.isBlank(value)? '': value;
                        mydata = mydata.replace( str, value);
                    }   
                }
            }
            
        }
        if(!String.isBlank(mRelatedToId) && fieldsForQueryForCase.size() >= 1)
        {
            String queryCase= 'SELECT ' + String.join(new List<String>(fieldsForQueryForCase), ', ') + ' FROM Case WHERE Id=:mRelatedToId';
            Case ca = Database.query(queryCase);
            
            for (string str: toReplace)
            {
                if (str.containsIgnoreCase('relatedTo') || str.containsIgnoreCase('Case')){
                    String fieldName = str.substringBetween('.','}');
                    fieldName = fieldName.trim();
                    if (allCaseFields.contains(fieldName.toLowerCase()))
                    {
                        Object c = ca.get(fieldName);
                        String value = String.valueOf(c);
                        value = String.isBlank(value)? '': value;
                        mydata = mydata.replace( str, value);
                    }
                    else if (fieldName.containsIgnoreCase('owner'))
                    {
                        String[] splitOwner = fieldName.split('\\.');
                        String owner = (String) ca.getSobject(splitOwner[0]).get(splitOwner[1]);
                        
                        mydata = mydata.replace( str, owner);
                    }   
                }
            }
            
        }        
        
       
        return mydata;           
    }    
    /**
    *@description this method is used to replace the survey URL
	*@return string of survey url
	*/
    private String replaceSurveyURL(){
        String surveyURL = '';
        DescribeSObjectResult d = Case.SObjectType.getDescribe();
        List<String> fields = new List<String>(d.fields.getMap().keySet());//get all available fields to ensure the Get method work
        //remove date fields to resolve encryption issues with shield
            for(integer i=fields.size()-1;i>0;--i){
                if(fields[i].contains('date') || fields[i].contains('trigger_5__c'))
                {  
                    fields.remove(i);
                }      
            }
        String query = 'Select RecordType.Name, RecordType.DeveloperName,' + String.join(fields, ', ') + ' from Case where Id =:mRelatedToId';
        Case co = Database.query(query);       
        
        if (co != null)
        {
            ASKHR_Send_Survey_Email_Setting__mdt[] surveySettings = [Select Field_Name__c, Field_Value__c, 
                                                                     Survey_URL_Sandbox__c, Survey_URL__c, Sandbox__c 
                                                                     from ASKHR_Send_Survey_Email_Setting__mdt 
                                                                     where Active__c = true AND Case_Record_Type__c=:co.RecordType.Name];
            
            if(surveySettings.size() == 1){                     
                surveyURL = surveySettings[0].Sandbox__c ? surveySettings[0].Survey_URL_Sandbox__c : surveySettings[0].Survey_URL__c ;
            }else if(surveySettings.size() > 1){
                for(ASKHR_Send_Survey_Email_Setting__mdt setting : surveySettings){
                    if(!String.isBlank(setting.Field_Name__c) && !String.isBlank(setting.Field_Value__c)){
                        Object c = co.get(setting.Field_Name__c);
                        String value = String.valueOf(c);
                        if(!String.isBlank(value) && setting.Field_Value__c.contains(value) ){
                           surveyURL = setting.Sandbox__c ? setting.Survey_URL_Sandbox__c : setting.Survey_URL__c ;
                        }
                    }else{
                        surveyURL = setting.Sandbox__c ? setting.Survey_URL_Sandbox__c : setting.Survey_URL__c ;
                    }
                }
            }   
        }
        
        return surveyURL;
    }
}