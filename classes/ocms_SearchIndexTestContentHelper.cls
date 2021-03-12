public with sharing class ocms_SearchIndexTestContentHelper {

    public List<cms__Attribute__c> content_properties {get; set;}
    public cms.CreateContentController cc {get; set;}
    public cms.GenerateContent gc {get; set;}
    public cms__Sites__c theSite {get; set;}

    public ocms_SearchIndexTestContentHelper() {
    }

    public Id createContent(String contentName, List<Map<String, String>> attr_map, List<Map<String, String>> tag_map)
    {
        String site_name = 'TestSite';
        String type_name = 'TestContentType';
        String page_name = 'TestPage';

        //setContext(site_name);

        // get the default language info
        Id defaultLang = theSite.cms__Default_Language__c;
        cms__Language__c theLanguage = [SELECT id, cms__Language_Code__c FROM cms__Language__c Where Id = :defaultLang LIMIT 1];

        cms__Content_Type__c ct = new cms__Content_Type__c(cms__Name__c = type_name, cms__Site_Name__c = site_name, Search_Detail_Page_Attributes__c = '["detailPage"]');
        insert ct;

        cms__Content__c txc = new cms__Content__c(
                cms__Content_Type__c         = ct.Id,
                cms__Name__c                 = contentName,
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
        insert txc;

        cms__Content_Layout__c cl = new cms__Content_Layout__c(cms__Name__c = 'TestLayout');
        insert cl;

        cms__Page__c page = new cms__Page__c(
            cms__Name__c = page_name,
            cms__Available_Languages__c = 'en_US',
            cms__Published_Start_Date__c = System.now(),
            cms__Site_Name__c = site_name,
            cms__Sites__c = theSite.Id,
            cms__Published__c = true
        );
        insert page;
        String PAGE_ID = page.Id;

        cms__Attribute__c pageSeo = new cms__Attribute__c(
            cms__Page__c = PAGE_ID,
            cms__Simple_Name__c = 'seo_name',
            cms__Simple_Value__c = page_name,
            cms__Language__c = theLanguage.Id,
            RecordTypeId = [select Id from RecordType where Name='Url' and SObjectType='cms__Attribute__c' limit 1].Id
        );
        insert pageSeo;

        cms__Attribute__c pageMeta = new cms__Attribute__c(
            cms__Page__c = PAGE_ID,
            cms__Meta_Page_Description__c = 'TestDescription',
            cms__Meta_Page_Keywords__c = 'TestKeywords',
            cms__Meta_Page_Name__c = page_name,
            cms__Meta_Page_Title__c = 'TestTitle',
            cms__Language__c = theLanguage.Id
        );
        insert pageMeta;

        cms__Cache__c pageCache = new cms__Cache__c(
            cms__Page__c = PAGE_ID,
            cms__Cache_Long__c = '<body>Cache</body>',
            cms__CSKey__c = PAGE_ID + ':en_US:1',
            cms__ParentId__c = PAGE_ID
        );
        insert pageCache;

        cms__Content_Layout_Instance__c cli = new cms__Content_Layout_Instance__c(cms__Content__c = txc.Id, cms__Content_Layout__c = cl.Id);
        insert cli;

        cms__Page_Content_Layout_Instance__c pcli = new cms__Page_Content_Layout_Instance__c(cms__Content_Layout_Instance__c=cli.Id,cms__Page__c=page.Id);
        insert pcli;

        this.content_properties = new List<cms__Attribute__c>();

        if (attr_map.size() > 0)
        {
            for (Map<String, String> am : attr_map)
            {
                cms__Attribute__c attr = new cms__Attribute__c();
                attr.cms__Content__c = txc.Id;
                attr.cms__Page_Content_Layout_Instance__c = pcli.Id;
                attr.cms__Language__c = theLanguage.Id;
                attr.cms__Index_Key__c = txc.id + ':' + theLanguage.Id;

                String name = am.get('name');
                String atype = am.get('type');
                String value = am.get('value');
                if (atype == 'Link' || atype == 'LongText')
                {
                    attr.cms__Is_Simple__c = false;
                    attr.cms__Name__c = name;
                }
                else
                {
                    attr.cms__Is_Simple__c = true;
                    attr.cms__Simple_Name__c = name;
                }

                if (atype == 'Link')
                {
                    attr.cms__Value__c = 'Internal,' + PAGE_ID + ',,' + page_name + ',,,';
                }
                else if (atype == 'LongText')
                {
                    attr.cms__Value__c = value;
                }
                else  // simple value
                {
                    attr.cms__Simple_Value__c = value;
                }
                insert attr;
                this.content_properties.add(attr);
            }
        }

        // These tags aren't correctly generated. There's no ancestor relationships set.
        // Since WIRE's breadcrumbs don't use these values, this solution is acceptable. FYI.
        if (tag_map.size() > 0) {
            for (Map<String, String> tm : tag_map) {

                cms__Tag_Definition__c tagDef = new cms__Tag_Definition__c();
                tagDef.cms__Name__c = tm.get('name');
                tagDef.cms__Type__c = 'Public';
                insert tagDef;

                cms__Tag__c tag = new cms__Tag__c();
                tag.cms__Tag_Definition__c = tagDef.Id;
                tag.cms__Content__c = txc.Id;
                if (tm.get('visible') == 'true') {
                    tag.cms__Is_Visible__c = true;
                } else {
                    tag.cms__Is_Visible__c = false;
                }

                insert tag;



            }
        }

        cms.API anAPI = new cms.API(null, 'prev');
        anAPI.site_name = site_name;

        Test.setCurrentPage(new PageReference('/apex/cms__CreateContent'));

        System.currentPageReference().getParameters().put('ecms', anAPI.getSerialize());
        System.currentPageReference().getParameters().put('content_id', txc.Id);
        System.currentPageReference().getParameters().put('cli_id', cli.Id);
        System.currentPageReference().getParameters().put('pcli_id', pcli.Id);


        //  Create content controller for editor constructor
        this.cc = new cms.CreateContentController();
        this.cc.content = txc;
        this.cc.content_properties = content_properties;

        //  Create generate content for generator constructor
        //this.gc = new cms.GenerateContent();
        //this.gc.content=txc;
        //this.gc.cli= cli;
        //this.gc.pcli=pcli;

        return txc.Id;
    }

    public void setContext(String siteName) {
        // Setup context; required as of OrchestraCMS 6.11
        Map<String, String> contextProperties = new Map<String, String>{'runtime' => 'Intranet', 'page_mode' => 'prod'};
        this.theSite = cms.TestExtensionFixtures.InitiateTest(siteName, contextProperties);
    }

    public void createSitePreferences() {
        String siteName = 'TestSite';
        setContext(siteName);

        // get the default language info
        Id defaultLang = theSite.cms__Default_Language__c;
        cms__Language__c theLanguage = [SELECT id, cms__Language_Code__c FROM cms__Language__c Where Id = :defaultLang LIMIT 1];

        cms__Content_Type__c ct = new cms__Content_Type__c(cms__Name__c = 'SitePreferences', cms__Site_Name__c = siteName);
        insert ct;

        cms__Content__c txc = new cms__Content__c(
                cms__Content_Type__c         = ct.Id,
                cms__Name__c                 = 'newsDetail',
                cms__Description__c          = 'Testing',
                cms__Preview__c              = true,
                cms__Published__c            = false,
                cms__Published_Start_Date__c = System.now(),
                cms__Site_Name__c            = siteName,
                cms__Revision_Number__c      = 0,
                cms__Revision_Origin__c      = null,
                cms__Version_Number__c       = 1,
                cms__Version_Origin__c       = null,
                cms__Version_Original__c     = true,
                cms__Version_Parent__c       = null,
                cms__Depth__c                = 0
        );
        insert txc;

        cms__Content_Layout__c cl = new cms__Content_Layout__c(cms__Name__c = 'newsDetailCL');
        insert cl;

        cms__Page__c page = new cms__Page__c(cms__Name__c = 'homePage', cms__Site_Name__c = siteName);
        insert page;

        cms__Page__c pageNewsAreaFilterTest = new cms__Page__c(cms__Name__c = 'newsAreaFilterTestPage', cms__Site_Name__c = siteName);
        insert pageNewsAreaFilterTest;

        cms__Page__c pageNewsDetail = new cms__Page__c(cms__Name__c = 'newsDetailPage', cms__Site_Name__c = siteName);
        insert pageNewsDetail;

        cms__Page__c pageProfileEdit = new cms__Page__c(cms__Name__c = 'profileEditTestPage', cms__Site_Name__c = siteName);
        insert pageProfileEdit;

        cms__Page__c pageProfile = new cms__Page__c(cms__Name__c = 'profileTestPage', cms__Site_Name__c = siteName);
        insert pageProfile;

        cms__Content_Layout_Instance__c cli = new cms__Content_Layout_Instance__c(cms__Content__c = txc.Id, cms__Content_Layout__c = cl.Id);
        insert cli;

        cms__Page_Content_Layout_Instance__c pcli = new cms__Page_Content_Layout_Instance__c(cms__Content_Layout_Instance__c=cli.Id,cms__Page__c=page.Id);
        insert pcli;

        String value = 'Internal,' + page.Id + ',,newsPage,,,';
        String valueNewsAreaFilterTest = 'Internal,' + pageNewsAreaFilterTest.Id + ',,newsAreaFilterTestPage,,,';
        String valueNewsDetail = 'Internal,' + pageNewsDetail.Id + ',,newsDetailPage,,,';
        String valueProfileEdit = 'Internal,' + pageProfileEdit.Id + ',,profileEditTestPage,,,';
        String valueProfile = 'Internal,' + pageProfile.Id + ',,profileTestPage,,,';
        cms__Attribute__c attr = new cms__Attribute__c(
            cms__Content__c = txc.Id,
            cms__Page_Content_Layout_Instance__c = pcli.Id,
            cms__Is_Simple__c = true,
            cms__Simple_Name__c = 'newsPage',
            cms__Simple_Value__c = value,
            cms__Language__c = theLanguage.Id,
            cms__Index_Key__c = txc.id + ':' + theLanguage.Id
        );
        insert attr;

       cms__Attribute__c attr3 = new cms__Attribute__c(
            cms__Content__c = txc.Id,
            cms__Page_Content_Layout_Instance__c = pcli.Id,
            cms__Is_Simple__c = true,
            cms__Simple_Name__c = 'newsAreaPage',
            cms__Simple_Value__c = valueNewsAreaFilterTest,
            cms__Language__c = theLanguage.Id,
            cms__Index_Key__c = txc.id + ':' + theLanguage.Id
        );
        insert attr3;

        cms__Attribute__c attr4 = new cms__Attribute__c(
            cms__Content__c = txc.Id,
            cms__Page_Content_Layout_Instance__c = pcli.Id,
            cms__Is_Simple__c = true,
            cms__Simple_Name__c = 'newsDetail',
            cms__Simple_Value__c = valueNewsDetail,
            cms__Language__c = theLanguage.Id,
            cms__Index_Key__c = txc.id + ':' + theLanguage.Id
        );
        insert attr4;

        cms__Attribute__c attr5 = new cms__Attribute__c(
            cms__Content__c = txc.Id,
            cms__Page_Content_Layout_Instance__c = pcli.Id,
            cms__Is_Simple__c = true,
            cms__Simple_Name__c = 'profileEdit',
            cms__Simple_Value__c = valueProfileEdit,
            cms__Language__c = theLanguage.Id,
            cms__Index_Key__c = txc.id + ':' + theLanguage.Id
        );
        insert attr5;

        cms__Attribute__c attr6 = new cms__Attribute__c(
            cms__Content__c = txc.Id,
            cms__Page_Content_Layout_Instance__c = pcli.Id,
            cms__Is_Simple__c = true,
            cms__Simple_Name__c = 'profile',
            cms__Simple_Value__c = valueProfile,
            cms__Language__c = theLanguage.Id,
            cms__Index_Key__c = txc.id + ':' + theLanguage.Id
        );
        insert attr6;

        cms__Attribute__c attr7 = new cms__Attribute__c(
            cms__Content__c = txc.Id,
            cms__Page_Content_Layout_Instance__c = pcli.Id,
            cms__Is_Simple__c = true,
            cms__Simple_Name__c = 'tagPathCriticalGlobal',
            cms__Simple_Value__c = '/News Taxonomy/News/Critical Global',
            cms__Language__c = theLanguage.Id,
            cms__Index_Key__c = txc.id + ':' + theLanguage.Id
        );
        insert attr7;

        cms__Attribute__c attr8 = new cms__Attribute__c(
            cms__Content__c = txc.Id,
            cms__Page_Content_Layout_Instance__c = pcli.Id,
            cms__Is_Simple__c = true,
            cms__Simple_Name__c = 'tagPathGlobal',
            cms__Simple_Value__c = '/News Taxonomy/News/Global',
            cms__Language__c = theLanguage.Id,
            cms__Index_Key__c = txc.id + ':' + theLanguage.Id
        );
        insert attr8;

        cms__Attribute__c attr9 = new cms__Attribute__c(
            cms__Content__c = txc.Id,
            cms__Page_Content_Layout_Instance__c = pcli.Id,
            cms__Is_Simple__c = true,
            cms__Simple_Name__c = 'tagPathFunction',
            cms__Simple_Value__c = '/News Taxonomy/News/Function',
            cms__Language__c = theLanguage.Id,
            cms__Index_Key__c = txc.id + ':' + theLanguage.Id
        );
        insert attr9;

        cms__Attribute__c attr10 = new cms__Attribute__c(
            cms__Content__c = txc.Id,
            cms__Page_Content_Layout_Instance__c = pcli.Id,
            cms__Is_Simple__c = true,
            cms__Simple_Name__c = 'tagPathLocation',
            cms__Simple_Value__c = '/News Taxonomy/News/Location',
            cms__Language__c = theLanguage.Id,
            cms__Index_Key__c = txc.id + ':' + theLanguage.Id
        );
        insert attr10;

        cms__Attribute__c attr11 = new cms__Attribute__c(
            cms__Content__c = txc.Id,
            cms__Page_Content_Layout_Instance__c = pcli.Id,
            cms__Is_Simple__c = true,
            cms__Simple_Name__c = 'detailPage',
            cms__Simple_Value__c = 'External,,,,,,/detail',
            cms__Language__c = theLanguage.Id,
            cms__Index_Key__c = txc.id + ':' + theLanguage.Id
        );
        insert attr11;

        cms.API anAPI = new cms.API(null, 'prev');
        anAPI.site_name = siteName;

        System.currentPageReference().getParameters().put('ecms', anAPI.getSerialize());
        System.currentPageReference().getParameters().put('content_id', txc.Id);
        System.currentPageReference().getParameters().put('cli_id', cli.Id);
        System.currentPageReference().getParameters().put('pcli_id', pcli.Id);
    }
}