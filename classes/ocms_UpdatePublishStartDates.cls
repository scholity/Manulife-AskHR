/**
 * Batch job intended to set the publish start date of content to the earliest of:
 * - Its existing publish start date
 * - Its revision origin publish start date, if one exists
 * - Its version origin publish start date, if one exists
 * - The value of its 'migratedDate' attribute, if one exists
 */
public with sharing class ocms_UpdatePublishStartDates implements Database.Batchable<sObject> {
    public static final String[] MFC_CONTENT_TYPES = new String[] {
        'News',
        'CEOMessage',
        'PolicyFormOrProcess',
        'MFC Article',
        'App'
    };

    public static final String[] MLI_CONTENT_TYPES = new String[] {
        'MLIArticle'
    };

    private String siteName;
    private String[] contentTypes;

    public ocms_UpdatePublishStartDates(String siteName, String[] contentTypes) {
        this.siteName = siteName;
        this.contentTypes = contentTypes;
    }

    public Datetime getArticleDateAttributeValue(String dateString) {
        Integer year = 0, month = 0, day = 0, hours = 0, minutes = 0;

        if(dateString.length() >= 10) {
            year = Integer.valueOf(dateString.substring(6,10));
        }

        if(dateString.length() >= 2) {
            month = Integer.valueOf(dateString.substring(0,2));
        }

        if(dateString.length() >= 5) {
            day = Integer.valueOf(dateString.substring(3,5));
        }
        
        if(dateString.length() >= 13) {
            hours = Integer.valueOf(dateString.substring(11,13));
        }

        if(dateString.length() >= 16) {
            minutes = Integer.valueOf(dateString.substring(14,16));
        }

        try {
            return Datetime.newInstanceGmt(year, month, day, hours, minutes, 0);
        } catch(Exception e) {
            System.debug(e);
            return null;
        }
    }

    public class PublishStartDateException extends Exception {}

    public Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT cms__Published_Start_Date__c, cms__Revision_Origin__r.cms__Published_Start_Date__c,'
                    + ' cms__Version_Origin__r.cms__Published_Start_Date__c,'
                    + ' (SELECT cms__Name__c, cms__Simple_Name__c, cms__Value__c, cms__Simple_Value__c FROM cms__Attributes__r)'
                + ' FROM cms__Content__c'
                + ' WHERE cms__Site_Name__c = :siteName AND cms__Content_Type__r.cms__Name__c IN :contentTypes';

        System.debug(query);

        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<sObject> scope) {
        cms__Content__c[] toUpdate = new cms__Content__c[] {};

        for(cms__Content__c content : (List<cms__Content__c>)scope) {
            Datetime publishStartDate = content.cms__Published_Start_Date__c;

            Datetime revisionOriginStartDate = publishStartDate;
            if(content.cms__Revision_Origin__c != null) {
                revisionOriginStartDate = content.cms__Revision_Origin__r.cms__Published_Start_Date__c;
            }

            Datetime versionOriginStartDate = publishStartDate;
            if(content.cms__Version_Origin__c != null) {
                versionOriginStartDate = content.cms__Version_Origin__r.cms__Published_Start_Date__c;
            }

            Datetime attributePublishStartDate = publishStartDate;
            for(cms__Attribute__c a : content.cms__Attributes__r) {
                // MFC migrated content
                if(a.cms__Name__c == 'migratedDate' || a.cms__Simple_Name__c == 'migratedDate') {
                    attributePublishStartDate = Datetime.valueOf(a.cms__Value__c);
                    if(attributePublishStartDate == null) {
                        attributePublishStartDate = Datetime.valueOf(a.cms__Simple_Value__c);
                    }
                // Manulife.com Article
                } else if(a.cms__Name__c == 'articleDate' || a.cms__Simple_Name__c == 'articleDate') {
                    String attributeValue = a.cms__Value__c;
                    if(String.isBlank(attributeValue)) {
                        attributeValue = a.cms__Simple_Value__c;
                    }

                    try {
                        Datetime articleDate = getArticleDateAttributeValue(attributeValue);
                        if(articleDate != null) {
                            attributePublishStartDate = articleDate;
                        }
                    } catch(TypeException e) {
                        System.debug(content.Id + ' : ' + attributeValue);
                    }
                }
            }

            // Default to publish start date
            Datetime newPublishStartDate = publishStartDate;

            // Is revision origin date earlier?
            if(revisionOriginStartDate < newPublishStartDate) {
                newPublishStartDate = revisionOriginStartDate;
            }

            // Is version origin date earlier?
            if(versionOriginStartDate < newPublishStartDate) {
                newPublishStartDate = versionOriginStartDate;
            }

            // Is the attribute value earlier?
            if(attributePublishStartDate < newPublishStartDate) {
                newPublishStartDate = attributePublishStartDate;
            }

            if(newPublishStartDate != content.cms__Published_Start_Date__c) {
                content.cms__Published_Start_Date__c = newPublishStartDate;
                toUpdate.add(content);
            }
        }

        update toUpdate;
    }

    public void finish(Database.BatchableContext BC) {

    }
}