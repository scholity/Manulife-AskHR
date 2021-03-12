/**
 *@description this class method is used in ASKHR_SendSurveyController
*/

public without sharing class ASKHR_SurveyBuilder
{
    /**
    *@description this method is used to create survey
	*/
    public static ASKHR_SendSurvey createSurvey(SObject so, ASKHR_ISendSurvey_Responder responder)
    {
        string mSOQLTemplate = 'No match';//set default name so that will return 0
        Boolean isCaseClose = false;
        
        ASKHR_SendSurvey survey = new ASKHR_SendSurvey(so, responder);
        
        if(so instanceof Case){   
            DescribeSObjectResult d = Case.SObjectType.getDescribe();
            System.debug('==RESULT===' + d);
            List<String> fields = new List<String>(d.fields.getMap().keySet());//get all available fields to ensure the Get method work
            //remove date fields to resolve encryption issues with shield
            for(integer i=fields.size()-1;i>0;--i){
                if(fields[i].contains('date') || fields[i].contains('trigger_5__c'))
                {  
                    fields.remove(i);
                }      
            }
            String query = 'Select RecordType.Name, RecordType.DeveloperName,' + String.join(fields, ', ') + ' from Case where Id = \'' + so.Id + '\'';
            Case co = Database.query(query);
            if (co != null)
            {
                ASKHR_Send_Survey_Email_Setting__mdt[] surveySettings = [Select Case_Record_Type__c, Email_Template_Name__c, Field_Name__c, Field_Value__c, Close_Case__c 
                                                                         from ASKHR_Send_Survey_Email_Setting__mdt 
                                                                         where Active__c = true AND Case_Record_Type__c=:co.RecordType.Name];
                
                if(surveySettings.size() == 1){                     
                     mSOQLTemplate = surveySettings[0].Email_Template_Name__c;
                     isCaseClose = surveySettings[0].Close_Case__c;                    
                }else if(surveySettings.size() > 1){
                    for(ASKHR_Send_Survey_Email_Setting__mdt setting : surveySettings){
                        if(!String.isBlank(setting.Field_Name__c) && !String.isBlank(setting.Field_Value__c)){
                            Object c = co.get(setting.Field_Name__c);
                            String value = String.valueOf(c);
                            if(!String.isBlank(value) && setting.Field_Value__c.contains(value) ){
                                mSOQLTemplate = setting.Email_Template_Name__c; 
                                isCaseClose = setting.Close_Case__c;                
                            }
                        }else{
                            mSOQLTemplate = setting.Email_Template_Name__c;
                            isCaseClose = setting.Close_Case__c; 
                        }
                    }
                }   
                if (isCaseClose && !co.Status.equals('Closed') )
                {
                    responder.SendFail('The survey only can be sent after the case is Closed', 'Template'); 
                }           
            }            
        }
        
        EmailTemplate[] emailTemplates = [Select Id, Name, DeveloperName from EmailTemplate where DeveloperName = :mSOQLTemplate];               
        
        if(emailTemplates.size() > 0){              
            System.debug('Email Template Name-' + emailTemplates[0].Name);
            survey.setTemplate(emailTemplates[0]);                  
        }else{
             responder.SendFail('No template is found. Please contact your administrator.', 'Template');
        }
        
        return survey;
    }
    
}