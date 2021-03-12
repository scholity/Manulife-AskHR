@isTest
public with sharing class ocms_UpdatePublishStartDatesTest {
    private static String siteName;
    private static Id siteId;

    private static String contentTypeName;
    private static Id contentTypeId;

    static {
        cms__Sites__c newSite = new cms__Sites__c(
            cms__Site_Name__c = 'testSite'
        );

        insert newSite;

        siteName = newSite.cms__Site_Name__c;
        siteId = newSite.Id;

        cms__Content_Type__c newType = new cms__Content_Type__c(
            cms__Sites__c = siteId,
            cms__Name__c = 'test name',
            cms__Site_Name__c = 'testSite'
        );

        insert newType;

        contentTypeName = newType.cms__Name__c;
        contentTypeId = newType.Id;
    }

    private static Id insertContent(Datetime publishStartDate, Id versionOrigin, Id revisionOrigin) {
        cms__Content__c newContent = new cms__Content__c(
            cms__Name__c = 'test content',
            cms__Published_Start_Date__c = publishStartDate,
            cms__Sites__c = siteId,
            cms__Site_Name__c = siteName,
            cms__Content_Type__c = contentTypeId,
            cms__Version_Origin__c = versionOrigin,
            cms__Revision_Origin__c = revisionOrigin
        );

        insert newContent;

        return newContent.Id;
    }

    private static Datetime getContentPublishDate(Id contentId) {
        return [SELECT cms__Published_Start_Date__c FROM cms__Content__c WHERE Id = :contentId].cms__Published_Start_Date__c;
    }

    public static testmethod void testOriginalStartDate() {
        Datetime now = Datetime.now();

        Id contentId = insertContent(now, null, null);

        ocms_UpdatePublishStartDates batch = new ocms_UpdatePublishStartDates(siteName, new String[] { contentTypeName });

        Test.startTest();
            Database.executeBatch(batch, 100);
        Test.stopTest();

        System.assertEquals(now, getContentPublishDate(contentId),
            'Publish date should be unchanged for a single piece of content');
    }

    public static testmethod void testRevisionOriginStartDate() {
        Datetime fiftyHoursAgo = Datetime.now().addHours(-50);
        Datetime tenHoursAgo = Datetime.now().addHours(-10);
        Datetime now = Datetime.now();

        Id v10 = insertContent(tenHoursAgo, null, null); // v1.0 published 10h ago
        Id v20 = insertContent(fiftyHoursAgo, v10, null); // v2.0 past-published 50h ago
        Id v21 = insertContent(now, v10, v20); // v2.1 published now

        System.debug(fiftyHoursAgo);
        System.debug(getContentPublishDate(v21));

        ocms_UpdatePublishStartDates batch = new ocms_UpdatePublishStartDates(siteName, new String[] { contentTypeName });

        Test.startTest();
            Database.executeBatch(batch, 100);
        Test.stopTest();

        System.debug(fiftyHoursAgo);
        System.debug(getContentPublishDate(v21));
        System.assertEquals(tenHoursAgo, getContentPublishDate(v10), 'v10 publish date should not change');
        System.assertEquals(fiftyHoursAgo, getContentPublishDate(v20), 'v20 publish date should not change');
        System.assertEquals(fiftyHoursAgo, getContentPublishDate(v21),
            'v21 publish date should be set to its revision origin (v20)');
    }

    public static testmethod void testVersionOriginStartDate() {
        Datetime tenHoursAgo = Datetime.now().addHours(-10);
        Datetime now = Datetime.now();

        Id v10 = insertContent(tenHoursAgo, null, null); // v1.0 published 10h ago
        Id v20 = insertContent(now, v10, null); // v2.0 published now

        ocms_UpdatePublishStartDates batch = new ocms_UpdatePublishStartDates(siteName, new String[] { contentTypeName });

        Test.startTest();
            Database.executeBatch(batch, 100);
        Test.stopTest();

        System.assertEquals(tenHoursAgo, getContentPublishDate(v10), 'v10 publish date should not change');
        System.assertEquals(tenHoursAgo, getContentPublishDate(v20),
            'v20 publish date should be set to its version origin (v10)');
    }

    public static testmethod void testAttributeMigratedDate() {
        // MFC article 'migratedDate' attribute
        Datetime tenHoursAgo = Datetime.now().addHours(-10);
        Datetime now = Datetime.now();

        Id contentId = insertContent(now, null, null);

        cms__Attribute__c migratedDate = new cms__Attribute__c(
            cms__Content__c = contentId,
            cms__Name__c = 'migratedDate',
            cms__Value__c = String.valueOf(tenHoursAgo)
        );

        insert migratedDate;

        ocms_UpdatePublishStartDates batch = new ocms_UpdatePublishStartDates(siteName, new String[] { contentTypeName });

        Test.startTest();
            Database.executeBatch(batch, 100);
        Test.stopTest();

        System.assertEquals(tenHoursAgo, getContentPublishDate(contentId),
            'Content publish date should be set to its migratedDate attribute value');
    }

    public static testmethod void testAttributeArticleDate() {
        // Manulife.com 'articleDate' attribute
        Datetime now = Datetime.now();

        // articleDate doesn't include seconds
        Datetime tenHoursAgo =
            Datetime.newInstance(now.year(), now.month(), now.day(), now.hour(), now.minute(), 0).addHours(-10);

        Id contentId = insertContent(now, null, null);

        cms__Attribute__c articleDate = new cms__Attribute__c(
            cms__Content__c = contentId,
            cms__Name__c = 'articleDate',
            cms__Value__c = tenHoursAgo.formatGmt('MM/dd/yyyy hh:mm')
        );

        insert articleDate;

        ocms_UpdatePublishStartDates batch = new ocms_UpdatePublishStartDates(siteName, new String[] { contentTypeName });

        Test.startTest();
            Database.executeBatch(batch, 100);
        Test.stopTest();

        System.debug(tenHoursAgo.formatGmt('MM/dd/yyyy hh:mm'));
        System.debug(articleDate.cms__Value__c);
        System.debug(getContentPublishDate(contentId).formatGmt('MM/dd/yyyy hh:mm'));

        System.assertEquals(tenHoursAgo.formatGmt('MM/dd/yyyy hh:mm'), getContentPublishDate(contentId).formatGmt('MM/dd/yyyy hh:mm'),
            'Content publish date should be set to its articleDate attribute value');
    }
}