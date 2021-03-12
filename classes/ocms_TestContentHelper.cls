/**
 *  ocms_TestContentHelper.cls
 *
 *  2014-Mar-?? Richard Collins? Shawn Wilder? both? others?
 *              Original, modified for OrchestraCMS Winter 15 from other projects
 *
 *  2014-Apr-15 Bill Lucas
 *              changed site_name used by default constructor; added constructor that accepts a site name; added helper methods:
 *              makeTextAttributeMap(), addToAttributesFromList(), and testAttributeValuesFromList()
 *
 *              Sample use
 *              ocms_TestContentHelper tch = new ocms_TestContentHelper(SITENAME);
 *              List<Map<String,String>> testAttributes = new List<Map<String, String>>();
 *              List<String> attrNames = new List<String>{'AttrName1', 'Burford,Stacey', 'AttributeName3,Sample value for attr #3', …}
 *
 *              ocms_TestContentHelper.addToAttributesFromList(testAttributes, attrNames);
 *              tch.createContent(testAttributes, 'SitePreferences');
 *              sitePreferencesController = new ocms_mfc_SitePreferences(tch.gc);
 *              ocms_TestContentHelper.testAttributeValuesFromList(attrNames, sitePreferencesController);
 *
 */

@isTest
public with sharing class ocms_TestContentHelper {

    public String site_name {get;set;}
    public List<cms__Attribute__c> content_properties {get; set;}
    public cms.GenerateContent gc {get; set;}

    public ocms_TestContentHelper(String siteName) {
        this.site_name = siteName;
    }

    public ocms_TestContentHelper() {
        this.site_name = 'MyTestSite';
    }

    /**
     * returns a Map suitable for adding to createContent()
     * @param  name  String - attribute name
     * @param  value String - attribute value
     * @return new Map<String, String>{'name' => name, 'value' => value, 'type' => 'text'};
     */
    public static Map<String, String> makeTextAttributeMap (String name, String value) {
        return new Map<String, String>{'name' => name, 'value' => value, 'type' => 'text'};
    }

    /**
     * - add one OCMS attribute to the given list for every attribute name in the given list of strings
     * - attribute values are optional specified by what follows the first comma in the attribute name
     * - if the string does not contain a value part, the attribute name is used as its value
     * @param attrList  List<Map<String, String>> - each map entry in this list defines a content attribute
     * @param attrNames String - a list of attribute names, each of which may have a value component in it following a comma
     */
    public static void addToAttributesFromList (List<Map<String, String>> attrList, List<String> attrNames) {
        String [] keyAndValue;
        String attrValue;

        for (String name : attrNames) {
            keyAndValue = name.split(',', 2);
            name = keyAndValue[0];
            attrValue = keyAndValue.size() == 1 ? name : keyAndValue[1];

            attrList.add(makeTextAttributeMap(name, attrValue));
        }
    }   // addToAttributesFromList


    /**
     * - for each attribute name in the given list, compare its value retrieved from the given controller to
     *   its value as derived from its name, which may optionally include a comma separated value as described
     *   in addToAttribteMapFromList()
     * - System.assertEquals() is used to compare values
     * - System.Debug() always writes the retrieved value to the log for test confirmation purposes
     * @param attrNames  String - a list of attribute names, each of which may have a value component in it following a comma,
     *                   as given to addAttributeMapFromList
     * @param controller cms.ContentTemplateController (and extension thereof) - getProperty(attributeName) will be used
     *                   to retrieve the attribute’s value for comparison
     */
    public static void testAttributeValuesFromList (List<String> attrNames, cms.ContentTemplateController controller) {
        String [] keyAndValue;
        String attrValue;

        for (String name : attrNames) {
            keyAndValue = name.split(',', 2);
            name = keyAndValue[0];
            attrValue = keyAndValue.size() == 1 ? name : keyAndValue[1];

            String actualValue = controller.getProperty(name);
            System.Debug('Attribute (name, retrieved value): (' + name + ', ' + actualValue + ')');
            System.AssertEquals(actualValue, attrValue, 'Unexpected value for “' + name + '”: “' + attrValue + '”');
        }
    }   // testAttributeValuesFromList


    public void createContent(List<Map<String, String>> attr_map, String contentTypeName, Boolean createSite, String pageMode) {
        cms__Language__c theLanguage = null;

        if (createSite) {
            // Setup context; required as of OrchestraCMS 6.11
            Map<String, String> contextProperties = new Map<String, String>{'runtime' => 'Intranet', 'page_mode' => pageMode};
            cms__Sites__c site = cms.TestExtensionFixtures.InitiateTest(site_name, contextProperties);

            // get the default language info
            Id defaultLang = site.cms__Default_Language__c;
            theLanguage = [SELECT id, cms__Language_Code__c FROM cms__Language__c Where Id = :defaultLang LIMIT 1];
        } else {
            theLanguage = [SELECT id, cms__Language_Code__c FROM cms__Language__c  LIMIT 1];
        }

        String type_name = 'TestType';
        String page_name = 'TestPage';

        if (contentTypeName != null && String.isNotEmpty(contentTypeName)) {
            type_name = contentTypeName;
        }

        cms__Content_Type__c ct = new cms__Content_Type__c(cms__Name__c = type_name, cms__Site_Name__c = site_name);
        List<cms__Sites__c> theSites = [SELECT Id FROM cms__Sites__c WHERE cms__Site_Name__c = :site_name];
        if (theSites.size() == 1) {
            ct.cms__Sites__c = theSites[0].Id;
        }
        insert ct;

        cms__Content__c txc = new cms__Content__c(
            cms__Content_Type__c         = ct.Id,
            cms__Name__c                 = 'TestContent',
            cms__Description__c          = 'Testing',
            cms__Preview__c              = true,
            cms__Published__c            = false,
            cms__Published_Start_Date__c = System.now(),
            cms__Site_Name__c            = site_name,
            cms__Revision_Number__c      = 0,
            cms__Revision_Origin__c      = null,
            cms__Version_Number__c       = 1,
            cms__Version_Origin__c       = null,
            cms__Version_Original__c     = true,
            cms__Version_Parent__c       = null,
            cms__Depth__c                = 0
        );
        if (theSites.size() == 1) {
            txc.cms__Sites__c = theSites[0].Id;
        }
        insert txc;

        cms__Content_Layout__c cl = new cms__Content_Layout__c(cms__Name__c = 'TestLayout');
        insert cl;

        cms__Page__c page = new cms__Page__c(cms__Name__c = page_name, cms__Site_Name__c = site_name);
        insert page;

        String PAGE_ID = page.Id;


        cms__Content_Layout_Instance__c cli = new cms__Content_Layout_Instance__c(cms__Content__c = txc.Id, cms__Content_Layout__c = cl.Id);
        insert cli;

        cms__Page_Content_Layout_Instance__c pcli = new cms__Page_Content_Layout_Instance__c(cms__Content_Layout_Instance__c=cli.Id,cms__Page__c=page.Id);
        insert pcli;

        this.content_properties = new List<cms__Attribute__c>();

        if (attr_map.size() > 0) {
            for (Map<String, String> am : attr_map) {
                String name = am.get('name');
                String atype = am.get('type');
                String value = am.get('value');

                cms__Attribute__c attr = new cms__Attribute__c();
                attr.cms__Content__c = txc.Id;
                attr.cms__Page_Content_Layout_Instance__c = pcli.Id;

                attr.cms__Language__c = theLanguage.Id;
                attr.cms__Index_Key__c = txc.id + ':' + theLanguage.Id;

                if (atype == 'Link' || atype == 'LongText') {
                    attr.cms__Is_Simple__c = false;
                    attr.cms__Name__c = name;
                } else {
                    attr.cms__Is_Simple__c = true;
                    attr.cms__Simple_Name__c = name;
                }

                if (atype == 'Link') {
                    attr.cms__Value__c = 'Internal,' + PAGE_ID + ',,' + page_name + ',,,';
                } else if (atype == 'LongText') {
                    attr.cms__Value__c = value;
                } else {
                    attr.cms__Simple_Value__c = value;
                }

                this.content_properties.add(attr);
            }

            insert this.content_properties;
        }

        cms.API anAPI = new cms.API(null, 'prev');
        anAPI.site_name = site_name;

        System.currentPageReference().getParameters().put('ecms', anAPI.getSerialize());
        System.currentPageReference().getParameters().put('content_id', txc.Id);
        System.currentPageReference().getParameters().put('cli_id', cli.Id);
        System.currentPageReference().getParameters().put('pcli_id', pcli.Id);

        //  Create generate content for generator constructor
        this.gc = new cms.GenerateContent();
        this.gc.content = txc;
        this.gc.cli = cli;
        this.gc.pcli = pcli;
    }


    public void createContent(List<Map<String, String>> attr_map, String contentTypeName) {
        createContent(attr_map, contentTypeName, true, 'prod');
    }

    public void createContent(List<Map<String, String>> attr_map, String contentTypeName, Boolean createSite) {
        createContent(attr_map, contentTypeName, createSite, 'prod');
    }

    public void createContent(List<Map<String, String>> attr_map, String contentTypeName, String pageMode){
        createContent(attr_map, contentTypeName, true, pageMode);
    }

    public User createAndInsertUser(Map<String, String> overrideSettings) {

        TriggerUtils.setBypassUserTrigger();

        User newUser = new User();

        if (overrideSettings.containsKey('ProfileName')) {
            String profileName = overrideSettings.get('ProfileName');
            Profile profile = [SELECT Id FROM Profile WHERE Name = :profileName];

            newUser.ProfileId = profile.Id;
        } else {
            Profile profile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
            newUser.ProfileId = profile.Id;
        }

        if (overrideSettings.containsKey('Username')) {
            newUser.Username = overrideSettings.get('Username');
        } else {
            newUser.Username = generateRandomString(5) + '@stantive.com';
        }

        if (overrideSettings.containsKey('FirstName')) {
            newUser.FirstName = overrideSettings.get('FirstName');
        } else {
            newUser.FirstName = generateRandomString(8);
        }

        if (overrideSettings.containsKey('LastName')) {
            newUser.LastName = overrideSettings.get('LastName');
        } else {
            newUser.LastName = generateRandomString(8);
        }

        if (overrideSettings.containsKey('Email')) {
            newUser.Email = overrideSettings.get('Email');
        } else {
            newUser.Email = generateRandomString(5) + '@stantive.com';
        }

        if (overrideSettings.containsKey('Alias')) {
            newUser.Alias = overrideSettings.get('Alias');
        } else {
            newUser.Alias = generateRandomString(6);
        }

        if (overrideSettings.containsKey('Street')) {
            newUser.Street = overrideSettings.get('Street');
        } else {
            newUser.Street = '123' + generateRandomString(6);
        }

        if (overrideSettings.containsKey('Country')) {
            newUser.Country = overrideSettings.get('Country');
        } else {
            newUser.Country = generateRandomString(6);
        }

        if (overrideSettings.containsKey('City')) {
            newUser.City = overrideSettings.get('City');
            newUser.City__c = overrideSettings.get('City');
        } else {
            newUser.City = generateRandomString(6);
        }

        if (overrideSettings.containsKey('Street')) {
            newUser.Street = overrideSettings.get('Street');
        } else {
            newUser.Street = '123' + generateRandomString(6);
        }

        if (overrideSettings.containsKey('ContactId')) {
            newUser.ContactId = overrideSettings.get('ContactId');
        }

        newUser.LocaleSidKey = 'en_US';
        newUser.LanguageLocaleKey = 'en_US';
        newUser.TimeZoneSidKey = 'America/New_York';
        newUser.EmailEncodingKey = 'UTF-8';
        newUser.Pay_Country__c = 'CAN';

        insert newUser;

        return newUser;
    }


    public static String generateRandomString(Integer len) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';

        String randStr = '';

        while (randStr.length() < len) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), 52);
            randStr += chars.substring(idx, idx + 1);
        }

        return randStr;
    }


/*  private Map<String, cms__Content_Type__c> contentTypes {Get; Set;}
    private cms__Language__c theLanguage {Get; Set;}
    private static final String TAXONOMY_TYPE = 'Taxonomy';

    public void testTax() {
        cms__Content__c taxContent = createTaxonomyContent('Test Taxonomy');

        cms__Content__c cCanada = addToCategories('Canada', taxContent.Id);
        cms__Content__c cOntario = addToCategories('Ontario', cCanada.Id);
    }

    private cms__Content__c addToCategories(List<String> sCategories, Content__c parent, String langId) {
        List<cms__Tag_Definition__c> newTags = new List<cms__Tag_Definition__c>();
        Content__c kid = null;

        for (String category : sCategories) {
            // create Tag Definition
            cms__Tag_Definition__c newtd = new cms__Tag_Definition__c(cms__Name__c = sCategory, cms__Type__c = TAXONOMY_TYPE);
            //insert newtd;
            newTags.add(newtd);
        }

        insert (newTags);

        for (cms__Tag_Definition__c newtd : newTags) {
            String sCategory = newtd.cms__Name__c;

            parent.cms__Last_Order__c = parent.cms__Last_Order__c + 1;

            kid = new Content__c();
            kid.cms__Name__c = sCategory; // this.parameters.get('Name');
            kid.cms__Site_Name__c = site_name;
            kid.cms__Published_Start_Date__c = System.now();
            kid.cms__Preview__c = true;
            kid.cms__Published__c = true;
            kid.cms__Version_Number__c = 1;
            kid.cms__Revision_Number__c = 0;
            kid.cms__Revision_Origin__c = null;
            kid.cms__Version_Original__c = true;
            kid.cms__Version_Origin__c = null;
            kid.cms__Content_Type__c = contentTypes.get('TaxonomyItem').Id;
            kid.cms__Available_Languages__c = 'en_US'
            kid.cms__Language__c = '';

            // Set node parent and it's depth
            kid.cms__Parent__c = parent.Id;
            kid.cms__Parent_Origin__c = null;
            kid.cms__Version_Parent__c = null;
            kid.cms__Depth__c = parent.cms__Depth__c + 1;
            kid.cms__Order__c = parent.cms__Last_Order__c;

            kid.cms__Tag_Definition__c = newtd.Id;
            kid.cms__Tag_Definition__r = newtd;
            kids.add(kid);
        }

        insert (kids);
    }

    public cms__Content__c createTaxonomyContent(String taxonomyName) {
        // Setup context; required as of OrchestraCMS 6.11
        Map<String, String> contextProperties = new Map<String, String>{'runtime' => 'Intranet', 'page_mode' => 'prod'};
        cms__Sites__c site = cms.TestExtensionFixtures.InitiateTest(site_name, contextProperties);

        // Get the default language info
        Id defaultLang = site.cms__Default_Language__c;
        theLanguage = [SELECT id, cms__Language_Code__c FROM cms__Language__c Where Id = :defaultLang LIMIT 1];

        contentTypes = setupContentTypes(site_name, new List<String>{'Taxonomy', 'TaxonomyItem'});

        cms__Content_Type__c TaxonomyType = contentTypes.get('Taxonomy');

        cms__Content__c taxonomyContent = new cms__Content__c(
            cms__Content_Type__c         = TaxonomyType.Id,
            cms__Name__c                 = taxonomyName,
            cms__Description__c          = 'Taxonomy',
            cms__Language__c             = theLanguage.cms__Language_Code__c,
            cms__Available_Languages__c  = theLanguage.cms__Language_Code__c,
            cms__Preview__c              = true,
            cms__Published__c            = false,
            cms__Published_Start_Date__c = System.now().addDays(-1),
            cms__Site_Name__c            = site.cms__Site_Name__c,
            cms__Sites__c                = site.Id,
            cms__Revision_Number__c      = 0,
            cms__Revision_Origin__c      = null,
            cms__Version_Number__c       = 1,
            cms__Version_Origin__c       = null,
            cms__Version_Original__c     = true,
            cms__Version_Parent__c       = null,
            cms__Depth__c                = 0,
            cms__Tag_Definition__c       = null,
            cms__Parent__c               = null,
            cms__Ancestor__c             = null,
            cms__Ancestor1__c            = null,
            cms__Ancestor2__c            = null,
            cms__Ancestor3__c            = null,
            cms__Ancestor4__c            = null,
            cms__Ancestor5__c            = null
        );

        insert taxonomyContent;

        List<cms__Attribute__c> attrMap = new List<cms__Attribute__c>();

        cms__Attribute__c a1 = new cms__Attribute__c(
            cms__Name__c ='NotificationType',
            cms__Value__c = 'LEAF',
            cms__Type__c = 'Text',
            cms__Object_Type__c = 'Content__c',
            cms__Content__c = taxonomyContent.Id,
            cms__Index_Key__c = taxonomyContent.Id
        );
        attrMap.add(a1);

        cms__Attribute__c a2 = new cms__Attribute__c(
            cms__Name__c ='NotificationModel',
            cms__Value__c = 'ALERT',
            cms__Type__c = 'Text',
            cms__Object_Type__c = 'Content__c',
            cms__Content__c = taxonomyContent.Id,
            cms__Index_Key__c = taxonomyContent.Id
        );
        attrMap.add(a2);

        cms__Attribute__c a3 = new cms__Attribute__c(
            cms__Name__c ='PublicNotificationModel',
            cms__Value__c = 'true',
            cms__Type__c = 'Text',
            cms__Object_Type__c = 'Content__c',
            cms__Content__c = taxonomyContent.Id,
            cms__Index_Key__c = taxonomyContent.Id
        );
        attrMap.add(a3);

        cms__Attribute__c a4 = new cms__Attribute__c(
            cms__Name__c ='EmailSubscriptionClientVerificationPageLink',
            cms__Value__c = 'EmailSubscriptionClientVerificationPageLink',
            cms__Type__c = 'Text',
            cms__Object_Type__c = 'Content__c',
            cms__Content__c = taxonomyContent.Id,
            cms__Index_Key__c = taxonomyContent.Id
        );
        attrMap.add(a4);

        cms__Attribute__c a5 = new cms__Attribute__c(
            cms__Name__c ='TargetPageLink',
            cms__Value__c = 'TargetPageLink',
            cms__Type__c = 'Text',
            cms__Object_Type__c = 'Content__c',
            cms__Content__c = taxonomyContent.Id,
            cms__Index_Key__c = taxonomyContent.Id
        );
        attrMap.add(a5);

        cms__Attribute__c a6 = new cms__Attribute__c(
            cms__Name__c ='StartingLevel',
            cms__Value__c = '1',
            cms__Type__c = 'Integer',
            cms__Object_Type__c = 'Content__c',
            cms__Content__c = taxonomyContent.Id,
            cms__Index_Key__c = taxonomyContent.Id
        );
        attrMap.add(a6);

        cms__Attribute__c a7 = new cms__Attribute__c(
            cms__Name__c ='Depth',
            cms__Value__c = '3',
            cms__Type__c = 'Integer',
            cms__Object_Type__c = 'Content__c',
            cms__Content__c = taxonomyContent.Id,
            cms__Index_Key__c = taxonomyContent.Id
        );
        attrMap.add(a7);

        insert(attrMap);

        return taxonomyContent;
    }

    public Map<String, cms__Content_Type__c> setupContentTypes(String sName, List<String> content_types) {
        Map<String, cms__Content_Type__c> cts = new Map<String, cms__Content_Type__c>();
        List<cms__Content_Type__c> ctsToInsert = new List<cms__Content_Type__c>();

        for (String name : content_types) {
            cms__Content_Type__c ct = new cms__Content_Type__c();
            ct = new cms__Content_Type__c(cms__Name__c = name, cms__Label__c = name, cms__Site_Name__c = sName, cms__Object__c = 'Content__c');
            ctsToInsert.add(ct);

            cts.put(name, ct);
        }

        insert ctsToInsert;

        return cts;
    }*/
}   // <c ocmsTestContenHelper>