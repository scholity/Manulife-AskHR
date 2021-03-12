public with sharing class LanguageAPIRequest extends APIRequest {


    // List of Actions
    public static String ADD_LANGUAGE = 'addLanguage';
    public static String EDIT_LANGUAGE = 'editLanguage';
    public static String ADD_DEFAULT_LANGUAGE = 'addDefaultLanguage';
    public static String SET_DEFAULT_LANGUAGE = 'setDefaultLanguage';
    public static String DISABLE_LANGAUGE = 'disableLanguage';
    public static String ENABLE_LANGUAGE = 'enableLanguage';
    public static String GET_AVAILABLE_LANGUAGES = 'getAvailableLanguages';
    public static String SET_TRANSLATION_GROUP = 'setTranslationGroup';
    public static String ADD_USERS_TO_TRANSLATION_GROUP = 'addUsersToTranslationGroup';
    public static String REMOVE_USERS_FROM_TRANSLATION_GROUP = 'removeUsersFromTranslationGroup';
    public static String GET_TRANSLATION_GROUPS = 'getTranslationGroups';
    public static String SET_SITE_LANGUAGE_FLAGS = 'setSiteLanguageFlags';
    public static String GET_SALESFORCE_LANGUAGES = 'getSalesforceLanguages';
    public static String GET_UNUSED_SALESFORCE_LANGUAGES = 'getUnusedSalesforceLanguages';

    // parameters allowed
    public static String ID = 'id';
    public static String NAME = 'name';
    public static String LABEL = 'label';
    public static String CODE = 'code';
    public static String DESCRIPTION = 'description';
    public static String PRIORITY = 'priority';
    public static String groupId = 'groupId';

    // listparameters allowed
    public static String IDS = 'ids';
    public static String USER_IDS = 'userIds';
    public static String CODES = 'codes';

    //requestFlags allowed keys
    public static String ADD_USER_TO_GROUP = 'addUserToGroup';
    public static String ALLOW_FALLBACK = 'allowfb';
    public static String USER_USER_LANGUAGE = 'useUserLanguage';
    public static String ENABLE_COOKIE = 'enableCookie';

    public LanguageAPIRequest(){
        super();
    }
}