/*
The controller class for the Knowledge List LWC components
*/
public with sharing class ASKHR_KnowledgeListController {    

    /**
     * Description: Method getKnowledgeNewsArticlesForNewsPage
     * 
     * This method returns List of News Knowledge Articles
     *
     * @return List<Knowledge__kav> - Returns List of News Knowledge Articles
     */
    @AuraEnabled(Cacheable=true)
    public static List<Knowledge__kav> getKnowledgeNewsArticlesForNewsPage(String langCode) {
        /*
        // Remap language codes. ex: en-US to en_US
        if (langCode != null) {
            langCode = langCode.replace('-', '_');
        }
        */
        // Use user language instead of what we get from the component
        langCode = getLanguageCode();

        List<Knowledge__kav> listNews = [SELECT Id, UrlName, Title, LastPublishedDate, General_Purpose_Content__c, Image__c 
            FROM Knowledge__kav 
            WHERE RecordType.DeveloperName = 'AskHR_News'
            AND PublishStatus = 'Online'
            AND Language = :langCode
            AND Active__c = true
            AND ((Online_From__c != null AND Online_From__c <= TODAY) OR (Online_From__c = null))
            AND ((Online_To__c != null AND Online_To__c >= TODAY) OR (Online_To__c = null))
            ORDER BY LastPublishedDate DESC];
        
        return listNews;
    }  

    /**
     * Description: Method getKnowledgeNewsArticlesForCarousel
     * 
     * This method returns List of News Knowledge Articles that are shown in Carousel
     *
     * @return List<Knowledge__kav> - Returns List of News Knowledge Articles that are shown in Carousel
     */
    @AuraEnabled(Cacheable=true)
    public static List<Knowledge__kav> getKnowledgeNewsArticlesForCarousel(String langCode) {
        /*
        // Remap language codes. ex: en-US to en_US
        if (langCode != null) {
            langCode = langCode.replace('-', '_');
        }
        */
        // Use user language instead of what we get from the component
        langCode = getLanguageCode();

        // pick records with Promote_to_Home_Page__c = true
        List<Knowledge__kav> listNews = [SELECT Id, UrlName, Title, LastPublishedDate, Summary, General_Purpose_Content__c, Image__c 
            FROM Knowledge__kav 
            WHERE RecordType.DeveloperName = 'AskHR_News'
            AND PublishStatus = 'Online'
            AND Language = :langCode
            AND Active__c = true
            AND Promote_to_Home_Page__c = true
            AND ((Online_From__c != null AND Online_From__c <= TODAY) OR (Online_From__c = null))
            AND ((Online_To__c != null AND Online_To__c >= TODAY) OR (Online_To__c = null))
            ORDER BY LastPublishedDate DESC
            LIMIT 3];
        
        return listNews;
    }  

    /**
     * Description: Method getNewsCarouselSettings
     * 
     * This method returns the settings for Carousel from metadata ASKHR_News_Carousel_Setting__mdt
     *
     * @return ASKHR_News_Carousel_Setting__mdt - Returns metadata ASKHR_News_Carousel_Setting__mdt
     */
    @AuraEnabled(Cacheable=true)
    public static ASKHR_News_Carousel_Setting__mdt getNewsCarouselSettings() {

        ASKHR_News_Carousel_Setting__mdt setting = null;
        
        // pick records with Promote_to_Home_Page__c = true
        List<ASKHR_News_Carousel_Setting__mdt> listSettings = [SELECT Id, Scroll_Duration__c
            FROM ASKHR_News_Carousel_Setting__mdt LIMIT 1];
        
            if (listSettings.size() > 0) {
                setting = listSettings[0];
            }
        return setting;
    }

    /**
     * Description: Method getKnowledgeAlertArticles
     * 
     * This method returns List of Alert Knowledge Articles
     *
     * @return List<Knowledge__kav> - Returns List of Alert Knowledge Articles
     */
    @AuraEnabled(Cacheable=true)
    public static List<Knowledge__kav> getKnowledgeAlertArticles(String langCode) {
        /*
        // Remap language codes. ex: en-US to en_US
        if (langCode != null) {
            langCode = langCode.replace('-', '_');
        }
        */
        // Use user language instead of what we get from the component
        langCode = getLanguageCode();

        List<Knowledge__kav> listKnowledgeArticles = [SELECT Id, UrlName, Title, LastPublishedDate, General_Purpose_Content__c
            FROM Knowledge__kav 
            WHERE RecordType.DeveloperName = 'AskHR_Alert'
            AND PublishStatus = 'Online'
            AND Language = :langCode
            AND Active__c = true
            AND ((Online_From__c != null AND Online_From__c <= TODAY) OR (Online_From__c = null))
            AND ((Online_To__c != null AND Online_To__c >= TODAY) OR (Online_To__c = null))];
        
        return listKnowledgeArticles;
    }

    /**
     * Description: Method getKnowledgeContactUsArticle
     * 
     * This method returns Contact us Knowledge Article
     *
     * @return List<Knowledge__kav> - Returns one  Contact us Knowledge Article
     */
    @AuraEnabled(Cacheable=true)
    public static Knowledge__kav getKnowledgeContactUsArticle(String langCode) {
        /*
        // Remap language codes. ex: en-US to en_US
        if (langCode != null) {
            langCode = langCode.replace('-', '_');
        }
        */
        // Use user language instead of what we get from the component
        langCode = getLanguageCode();

        Knowledge__kav knowledgeArticle = null;

        // Added Extension field also - 07-07-2020
        List<Knowledge__kav> listKnowledgeArticles = [SELECT Id, UrlName, Title, LastPublishedDate, Image__c,
            Contact_Us_Name__c, Contact_Us_Phone__c, Contact_Us_Internal_Extension__c, Contact_Us_Hours__c
            FROM Knowledge__kav 
            WHERE RecordType.DeveloperName = 'AskHR_Contact_Us'
            AND PublishStatus = 'Online'
            AND Language = :langCode
            AND Active__c = true
            AND UrlName != 'AskHR-Contact-Center-List'
            LIMIT 2];

        if (listKnowledgeArticles.size() == 1) {
            knowledgeArticle = listKnowledgeArticles[0];
        }
        
        return knowledgeArticle;
    }
    

    /**
     * Description: Method getKnowledgeGlobalContactUsArticle
     * 
     * This method returns Global Contact us Knowledge Article identified by URL Name 'AskHR-Contact-Center-List'
     *
     * @return List<Knowledge__kav> - Returns one  Global Contact us Knowledge Article
     */
    @AuraEnabled(Cacheable=true)
    public static Knowledge__kav getKnowledgeGlobalContactUsArticle(String langCode) {
        /*
        // Remap language codes. ex: en-US to en_US
        if (langCode != null) {
            langCode = langCode.replace('-', '_');
        }
        */
        // Use user language instead of what we get from the component
        langCode = getLanguageCode();

        Knowledge__kav knowledgeGlobalContactUsArticle = null;

        List<Knowledge__kav> listKnowledgeArticles = [SELECT Id, UrlName, Title, LastPublishedDate, Image__c,
            General_Purpose_Content__c,
            Contact_Us_Name__c, Contact_Us_Phone__c, Contact_Us_Hours__c
            FROM Knowledge__kav 
            WHERE RecordType.DeveloperName = 'AskHR_Contact_Us'
            AND PublishStatus = 'Online'
            AND Language = :langCode
            AND Active__c = true
            AND UrlName = 'AskHR-Contact-Center-List'
            LIMIT 1];

        if (listKnowledgeArticles.size() > 0) {
            knowledgeGlobalContactUsArticle = listKnowledgeArticles[0];
        } else {
            // SJC = 08-17-2020 - Fetch English (en_US) version of Global Contact Us if translation in user's current
            // language selection is not found
            List<Knowledge__kav> listKnowledgeArticlesEnglish = [SELECT Id, UrlName, Title, LastPublishedDate, Image__c,
                    General_Purpose_Content__c,
                    Contact_Us_Name__c, Contact_Us_Phone__c, Contact_Us_Hours__c
                FROM Knowledge__kav
                WHERE RecordType.DeveloperName = 'AskHR_Contact_Us'
                AND PublishStatus = 'Online'
                AND Language = 'en_US'
                AND Active__c = true
                AND UrlName = 'AskHR-Contact-Center-List'
                LIMIT 1];

            if (listKnowledgeArticlesEnglish.size() ==  1) {
                knowledgeGlobalContactUsArticle = listKnowledgeArticlesEnglish[0];
            }
        }

        return knowledgeGlobalContactUsArticle;
    } 

    private static String getLanguageCode() {
        User usr = [SELECT Id, LanguageLocaleKey  FROM User WHERE Id = :UserInfo.getUserId()];
        return usr.LanguageLocaleKey;
    }
}