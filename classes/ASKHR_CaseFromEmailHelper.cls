public class ASKHR_CaseFromEmailHelper {

    /*
     * @author 
     * @description This class is Handling email for auto Case
     * 1. EmailToCase Handler
     *      a. update case contact
     *      b. update field value 
     *      c. add case description
     */
    
    /*    
     * @description this method is used in ASKHR_CaseHandler to prevent email from being created based on Criteria   
     * @param c case object to check email subject description etc.,
     */    
    public static void handleCasefromEmail(Case c) {
        try {
            //get the setting 
            ASKHR_EmailToCase_Setting__mdt[] settings = getEmailToCaseHandlerSettings(ASKHR_CaseHandler.rtMap.get(c.RecordTypeId).getName());
            
            for (ASKHR_EmailToCase_Setting__mdt setting : settings) {

                String filterValue = setting.Email_Contains__c != null ? setting.Email_Contains__c.replaceAll('\\s', '') : null;
                String[] filterText = filterValue != null ? filterValue.split(',') : null;
                filterValue = setting.Email_From__c != null ? setting.Email_From__c.replaceAll('\\s', '') : null;
                String[] filterSender = filterValue != null ? filterValue.split(',') : null;

                if (setting.Do_Not_Create_Case__c && (emailContains(c.Subject, c.Description, filterText, setting.Search_in_Body__c)
                                                      || emailFrom(c.SuppliedEmail, filterSender)))
                {
                    if (!Test.isRunningTest()) {
                        c.addError('Prevent Case Creation E2C');
                    } else {
                        System.debug('Prevent Case Creation E2C');
                    }
                    break; //stop loop if delete case
                }
            }

        } catch(Exception ex) {
            System.debug('ASKHR_EmailMessageHandler Error:' + ex.getMessage());
        }
    }

    /*
     * @description to be used in ASKHR_EmailMessageHandler to update existing Case with value from the Email
     * @param c case object
     * @param em email message object 
     */
    public static void handleCasefromEmail(Case c, EmailMessage em) {
        String senderDetails;

        String defaultValue = '';
        Map<String, TempSetting> mapDefaultValue = new Map<String, TempSetting> ();

        try {
            //get the setting 
            ASKHR_EmailToCase_Setting__mdt[] settings = getEmailToCaseHandlerSettings(ASKHR_CaseHandler.rtMap.get(c.RecordTypeId).getName());
            
            System.debug('ASKHR_CaseFromEmailHelper -- Html Body : ' + em.HtmlBody);
            for (ASKHR_EmailToCase_Setting__mdt setting : settings) {
                boolean useDefault = true;
                String filterValue = setting.Email_Contains__c != null ? setting.Email_Contains__c.replaceAll('\\s', '') : null;
                String[] filterText = filterValue != null ? filterValue.split(',') : null;
                filterValue = setting.Email_From__c != null ? setting.Email_From__c.replaceAll('\\s', '') : null;
                String[] filterSender = filterValue != null ? filterValue.split(',') : null;

                if (setting.Enable_Field_Value__c) {
                    TempSetting tmp;
                    //TODO: uncomment the hardcoded value and use the CMT
                    if (emailContains(em.Subject, em.TextBody, filterText, setting.Search_in_Body__c)
                        || emailFrom(em.FromAddress, filterSender))
                    {
                        String value = setting.Field_Value__c != null ? setting.Field_Value__c : '';
                        c.put(setting.Field_Name__c, setting.Field_Value__c);

                        useDefault = false;
                    } else if (setting.Default_Field_Value__c) {
                        defaultValue = setting.Field_Value__c;
                    }

                    if (!mapDefaultValue.containsKey(setting.Field_Name__c)) {
                        tmp = new TempSetting();
                    } else {
                        tmp = mapDefaultValue.get(setting.Field_Name__c);
                        useDefault = tmp.isDefault; //get the current value;
                    }

                    tmp.isDefault = useDefault;
                    tmp.name = setting.Field_Name__c;
                    tmp.value = defaultValue;

                    mapDefaultValue.put(setting.Field_Name__c, tmp);
                }
            }

            for (TempSetting tmp : mapDefaultValue.values()) {
                if (tmp.isDefault) {
                    c.put(tmp.name, tmp.value);
                }
            }

        } catch(Exception ex) {
            System.debug('EmailMessageHandler Error:' + ex.getMessage());
        }

        List<Contact> emailSenderContact = [select Id, Name, Email, User__c, User__r.User_License__c from Contact where Email = :em.FromAddress limit 1];

        if (emailSenderContact != null && emailSenderContact.size() > 0) {
            Contact sender = emailSenderContact[0];
            //only add if the contact is Salesforce user license
            if (sender.User__r.User_License__c != null && !sender.User__r.User_License__c.equalsIgnoreCase('Salesforce')) {
                senderDetails = sender.Name + ' (' + sender.Email + ')';
                c.Sender_Email_Address__c = senderDetails;
                c.ContactId = null;
            } else {
                c.Sender_Email_Address__c = sender.Email;
            }
        } else {
            senderDetails = em.FromName != null ? em.FromName + ' (' + em.FromAddress + ')' : em.FromAddress;
            c.Sender_Email_Address__c = senderDetails;
            c.ContactId = null;
        }

    }

    /*
     * @description to check the email contains the matching pattern
     * @param subject String receives subject 
     * @param body String receives body 
     * @param keywords array of string receives filtertext 
     * @param includebody boolean receives to check either to includebody or not
     * @return boolean iscontain the pattern is matched with the subject then return true otherwise false
     */
    
    private static boolean emailContains(String subject, String body, String[] keywords, boolean includeBody) {

        boolean isContain = false;

        if (keywords != null) {
            String item = subject;

            Pattern p = Pattern.compile('(?i)\\b(' + String.join(keywords, '|') + ')\\b');
            Matcher m = p.matcher(item);
            isContain = m.find();

            if (!isContain && includeBody) {
                item = body;
                m = p.matcher(item);
                isContain = m.find();
            }

        }

        return isContain;
    }

    /*
     * @description to check the sender
     * @param fromEmail String 
     * @param filterSenders array of string 
     * @return boolean emailFrom if the valid available sender then return true otherwise false
     */
    
    private static boolean emailFrom(String fromEmail, String[] filterSenders) {
        boolean isFrom = false;

        if (filterSenders != null) {
            String emailSender = fromEmail;
            if (emailSender != null || !emailSender.equals('')) {
                for (String filterSender : filterSenders) {
                    if (filterSender.startsWith('@')) {
                        String domain = emailSender.substring(emailSender.lastIndexOf('@'));
                        isFrom = domain.equalsIgnoreCase(filterSender);
                    } else {
                        isFrom = emailSender.equalsIgnoreCase(filterSender);
                    }

                    if (isFrom) break; //found matching, stop looping
                }
            }
        }

        return isFrom;
    }

    /*
     * @description to retrieve the email to case settings from metadata
     * @param caseRecordType String 
     * @return ASKHR_EmailToCase_Setting__mdt[] Email to case settings
     */
    
    private static ASKHR_EmailToCase_Setting__mdt[] getEmailToCaseHandlerSettings(String caseRecordType) {
        ASKHR_EmailToCase_Setting__mdt[] settings = [Select MasterLabel, DeveloperName, Case_Record_Type__c,
                                                     Do_Not_Create_Case__c, Email_Contains__c, Email_From__c,
                                                     Field_Value__c, Search_in_Body__c,
                                                     Field_Name__c, Default_Field_Value__c,
                                                     Enable_Field_Value__c from ASKHR_EmailToCase_Setting__mdt where Case_Record_Type__c = :caseRecordType AND Active__c = true];
        return settings;
    }

    /* Commented for future enhancement with email body
     * private static String getEmailBody(String body, String email){
      String str = body.substring(0, body.lastIndexOf(email));
      return str;
      }*/

    class TempSetting {
        public String name;
        public String value;
        public boolean isDefault;
    }

    /**
     * @author Pong Chee Hong
     * @description 
     *  This function is to remove the content of email that contains email signature
     *  Removal start from word: thank,regard or rgds and end at word: from
     * @param htmlbody string 
     * @return string of htmlbody text 
     */
    public static String CheckHTMLBody(String htmlBody)
    {
        
        String result = htmlbody;   
        List<String> tempHtmlbodyList = new list<String>();
        List<String> finalTempHtmlbodyList = new list<String>();
        String htmlbodyresult = result;
        
        if(htmlbodyresult!= null)
        {
            while(htmlbodyresult.indexOf('<p')>-1){          
         
             tempHtmlbodyList.add(htmlbodyresult.substring(0,htmlbodyresult.indexOf('</p>')+4));
             Integer count1 = htmlbodyresult.indexOf('</p>')+4;
             Integer count2 = htmlbodyresult.length();
             htmlbodyresult = htmlbodyresult.substring(count1,count2);    
        }
        
        for(String tempEmailBody: tempHtmlbodyList)
        {
            while(tempEmailBody.indexOf('<br>')>-1){        
                 finalTempHtmlbodyList.add(tempEmailBody.substring(0,tempEmailBody.indexOf('<br>')+4));
                 Integer count1 = tempEmailBody.indexOf('<br>')+4;
                 Integer count2 = tempEmailBody.length();
                 tempEmailBody = tempEmailBody.substring(count1,count2);    
            }
     
            finalTempHtmlbodyList.add(tempEmailBody);
        }
        
        boolean isRemove = false;
        htmlbodyresult = '';
        for(String emailBody: finalTempHtmlbodyList)
        {                         
            if(!isRemove)
                htmlbodyresult = htmlbodyresult + emailBody;
                      
            if(emailBody.containsIgnoreCase('thank') || emailBody.containsIgnoreCase('regard') || emailBody.containsIgnoreCase('rgds'))    
                isRemove = true;                                
            
            if (emailBody.indexOf('From:')>-1)
            {
                if(isRemove)
                    htmlbodyresult = htmlbodyresult + emailBody;
                isRemove = false;
            }   
        }
        
            if(!htmlbodyresult.equals(''))
                return htmlbodyresult + '</p></div>';
        }
      

        return result;
    }
}