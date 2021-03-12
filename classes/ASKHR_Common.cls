/**
* @author kavitha kannan
* @description: used to store all the public static final variables which is referenced from other class
*/
public class ASKHR_Common 
{
    public static final String ASKHR_RECORDTYPE = 'ASKHR';

     //used in ASKHR_ArticleDataCategoryUtil
    public static final String ARTICLE_TYPE = 'KnowledgeArticleVersion'; 
           
    //used in ASKHR_CaseHandler Class
    public static final String CASE_TEAM_ROLE_CASE_CONTACT = 'Case Contact';
    public static final String CASE_TEAM_ROLE_CASE_OWNER = 'Case Owner';
    public static final String CASE_TEAM_ROLE_CASE_TIER1 = 'CSR Tier 1 Visibility to GHRBS';
    //HRSALEFOR-244
    public static final String CASE_TEAM_ROLE_CASE_CREATOR = 'Case Creator';

    //case team for child case owner in parent case
    public static final String CASE_TEAM_ROLE_CHILD_CASE_CONTACT = 'Child Case Contact';
    public static final String CASE_TEAM_TEMPLATE_GHRBS_TEAM = 'GHRBS Team';
    public static final String CASE_TEAM_TEMPLATE_CCB_TEAM = 'CCB Team';
    public static final String CASE_TEAM_TEMPLATE_CSR_TEAM = 'CSR Team';
    public static final String CASE_ORIGIN_COMMUNITIES_USERS = 'Ask HR';
    //
    //User Role
    public static final String USER_ROLE_GHRBS_ANALYST = 'GHRBS Analyst';
    //
    
    //Case Origin
    public static final String CASE_ORIGIN_WORKDAY_SUPPORT_EMAIL = 'Workday Support Email';
    public static final String CASE_ORIGIN_EMAIL_TO_CASE = 'Email to Case';
    public static final String CASE_ORIGIN_EMAIL = 'Email';
    
    //Queue
    public static final String QUEUE_GHRBS_SUPPORT='GHRBS Support';
    
    //License
    public static Final String USER_LICENSE_SALESFORCE = 'Salesforce';
    
    //used in UserHandler class
    public static String SYSTEM_INTEGRATION_PROFILE_NAME = 'System Integration';
    public static String DEFAULT_PAY_COUNTRY = 'USA';  // this constant is not seems to be used anywhere other than declaration
    // new default value based on Country - replace Pay Country
    public static String DEFAULT_COUNTRY = 'USA';
    public static String DEFAULT_LANGUAGE_LOCALE_KEY = 'en_US';
    public static String DEFAULT_TIMEZONE = 'America/New_York';
        
    //used in ASKHR_ContactService
    public static String MANULIFE_ACCOUNT_NAME = 'Manulife';
   
    //used in ASKHR_TestUtility
    public static String CASE_RECORD_TYPE_NAME_GENERAL_HR = 'General HR Case';
    public static String CASE_RECORD_TYPE_NAME_ER_TERMINATION = 'ER Termination Documents';
    public static String CASE_RECORD_TYPE_NAME_ER_CASE = 'ER Case';
    public static String CASE_RECORD_TYPE_NAME_FUNCTION = 'Function';
    public static String CASE_RECORD_TYPE_NAME_OHS_INCIDENT = 'OHS Incident';
    public static String CASE_RECORD_TYPE_NAME_CHANGE_CONTROL ='Change Control';
    public static String CASE_RECORD_TYPE_NAME_TRANSLATION_KNOWLEDGE_Policy ='Translation, Knowledge and Policy Management';
    public static String CASE_RECORD_TYPE_NAME_HR_SYSTEMS_ACCESS = 'HR Systems Access';
    public static String CASE_RECORD_TYPE_NAME_HR_SYSTEMS_SUPPORT ='HR Systems Support';

}