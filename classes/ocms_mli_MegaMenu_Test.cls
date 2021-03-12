@isTest
private class ocms_mli_MegaMenu_Test {
	
	@isTest static void instantiate() {

        ocms_TestContentHelper tch = new ocms_TestContentHelper();
        ocms_mli_MegaMenu megaMenu = new ocms_mli_MegaMenu();
        List<Map<String,String>> attr_map = new List<Map<String,String>>();

        Map<String, String> am = new Map<String, String>();
        
        am.put('value', 'Skip to');
        am.put('type', 'Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'strDataMsgOpen');
        am.put('value', 'Click to expand the submenu');
        am.put('type', 'Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'strDataMsgClose');
        am.put('value', 'Click to close the submenu');
        am.put('type', 'Text');
        attr_map.add(am);

        tch.createContent(attr_map, 'MegaMenu');
        megaMenu = new ocms_mli_MegaMenu(tch.gc);

        System.Debug('**** strDataMsgOpen: ' + megaMenu.strDataMsgOpen);
        System.Debug('**** strDataMsgClose: ' + megaMenu.strDataMsgClose);

        megaMenu.getHTML();

        megaMenu.test_pm = 'prev';

        megaMenu.getHTML();

        Test.setCurrentPageReference(new PageReference('/apex/cms__CreateContent'));
        System.currentPageReference().getParameters().put('sname', 'manulife');
        System.currentPageReference().getParameters().put('content', tch.gc.content.Id);

        cms.CreateContentController ccc = new cms.CreateContentController();
        megaMenu = new ocms_mli_MegaMenu(ccc);

    }
    
    @isTest static void oneLevelMenu() {
        ocms_TestContentHelper tch = new ocms_TestContentHelper();
        ocms_mli_MegaMenu megaMenu = new ocms_mli_MegaMenu();
         List<Map<String,String>> attr_map = new List<Map<String,String>>();

        Map<String, String> am = new Map<String, String>();
        //
        am.put('value', 'Skip to');
        am.put('type', 'Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'strDataMsgOpen');
        am.put('value', 'Click to expand the submenu');
        am.put('type', 'Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'strDataMsgClose');
        am.put('value', 'Click to close the submenu');
        am.put('type', 'Text');
        attr_map.add(am);

        tch.createContent(attr_map, 'MegaMenu');
        megaMenu = new ocms_mli_MegaMenu(tch.gc);
        System.Debug('**** content properties: ' + tch.content_properties[0].cms__Content__c);
        String megaMenuContentId = tch.content_properties[0].cms__Content__c;

        cms__Content_Type__c nodeType = new cms__Content_Type__c(
            cms__Name__c = 'MenuItem',
            cms__Site_Name__c = 'manulife'
        );
        insert nodeType;

        cms__Content__c node1 = new cms__Content__c(
            //need to add cms__Parent__c with id to content we created.
            cms__Parent__c               = megaMenuContentId,
            cms__Ancestor__c             = megaMenuContentId,
            cms__Content_Type__c         = nodeType.Id,
            cms__Name__c                 = 'level1',
            cms__Description__c          = 'Testing',
            cms__Preview__c              = true,
            cms__Published__c            = false,
            cms__Published_Start_Date__c = System.now(),
            cms__Site_Name__c            = 'manulife',
            cms__Revision_Number__c      = 0,
            cms__Revision_Origin__c      = null,
            cms__Version_Number__c       = 1,
            cms__Version_Origin__c       = null,
            cms__Version_Original__c     = true,
            cms__Version_Parent__c       = null,
            cms__Depth__c                = 1
        );
        insert node1;       

        megaMenu.getHTML();
    }

    @isTest static void twoLevelMenu() {
        
        ocms_TestContentHelper tch = new ocms_TestContentHelper();
        ocms_mli_MegaMenu megaMenu = new ocms_mli_MegaMenu();
         List<Map<String,String>> attr_map = new List<Map<String,String>>();

        Map<String, String> am = new Map<String, String>();
        
        am.put('value', 'Skip to');
        am.put('type', 'Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'strDataMsgOpen');
        am.put('value', 'Click to expand the submenu');
        am.put('type', 'Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'strDataMsgClose');
        am.put('value', 'Click to close the submenu');
        am.put('type', 'Text');
        attr_map.add(am);

        tch.createContent(attr_map, 'MegaMenu');
        megaMenu = new ocms_mli_MegaMenu(tch.gc);
        System.Debug('**** content properties: ' + tch.content_properties[0].cms__Content__c);
        String megaMenuContentId = tch.content_properties[0].cms__Content__c;

        cms__Content_Type__c nodeType = new cms__Content_Type__c(
            cms__Name__c = 'MenuItem',
            cms__Site_Name__c = 'manulife'
        );
        insert nodeType;

        cms__Content__c node1 = new cms__Content__c(
            //need to add cms__Parent__c with id to content we created.
            cms__Parent__c               = megaMenuContentId,
            cms__Ancestor__c             = megaMenuContentId,
            cms__Content_Type__c         = nodeType.Id,
            cms__Name__c                 = 'level1',
            cms__Description__c          = 'Testing',
            cms__Preview__c              = true,
            cms__Published__c            = false,
            cms__Published_Start_Date__c = System.now(),
            cms__Site_Name__c            = 'manulife',
            cms__Revision_Number__c      = 0,
            cms__Revision_Origin__c      = null,
            cms__Version_Number__c       = 1,
            cms__Version_Origin__c       = null,
            cms__Version_Original__c     = true,
            cms__Version_Parent__c       = null,
            cms__Depth__c                = 1
        );
        insert node1;

        cms__Content__c node2 = new cms__Content__c(
            cms__Parent__c               = node1.Id,
            cms__Ancestor__c             = megaMenuContentId,
            cms__Ancestor1__c            = node1.Id,
            cms__Content_Type__c         = nodeType.Id,
            cms__Name__c                 = 'level2',
            cms__Description__c          = 'Testing',
            cms__Preview__c              = true,
            cms__Published__c            = false,
            cms__Published_Start_Date__c = System.now(),
            cms__Site_Name__c            = 'manulife',
            cms__Revision_Number__c      = 0,
            cms__Revision_Origin__c      = null,
            cms__Version_Number__c       = 1,
            cms__Version_Origin__c       = null,
            cms__Version_Original__c     = true,
            cms__Version_Parent__c       = null,
            cms__Depth__c                = 2
        );
        insert node2;        

        megaMenu.getHTML();

    }

    @isTest static void threeLevelMenu() {

        ocms_TestContentHelper tch = new ocms_TestContentHelper();
        ocms_mli_MegaMenu megaMenu = new ocms_mli_MegaMenu();
         List<Map<String,String>> attr_map = new List<Map<String,String>>();

        Map<String, String> am = new Map<String, String>();
        
        am.put('value', 'Skip to');
        am.put('type', 'Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'strDataMsgOpen');
        am.put('value', 'Click to expand the submenu');
        am.put('type', 'Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'strDataMsgClose');
        am.put('value', 'Click to close the submenu');
        am.put('type', 'Text');
        attr_map.add(am);

        tch.createContent(attr_map, 'MegaMenu');
        megaMenu = new ocms_mli_MegaMenu(tch.gc);
        System.Debug('**** content properties: ' + tch.content_properties[0].cms__Content__c);
        String megaMenuContentId = tch.content_properties[0].cms__Content__c;

        cms__Content_Type__c nodeType = new cms__Content_Type__c(
            cms__Name__c = 'MenuItem',
            cms__Site_Name__c = 'manulife'
        );
        insert nodeType;

        cms__Content__c node1 = new cms__Content__c(
            //need to add cms__Parent__c with id to content we created.
            cms__Parent__c               = megaMenuContentId,
            cms__Ancestor__c             = megaMenuContentId,
            cms__Content_Type__c         = nodeType.Id,
            cms__Name__c                 = 'level1',
            cms__Description__c          = 'Testing',
            cms__Preview__c              = true,
            cms__Published__c            = false,
            cms__Published_Start_Date__c = System.now(),
            cms__Site_Name__c            = 'manulife',
            cms__Revision_Number__c      = 0,
            cms__Revision_Origin__c      = null,
            cms__Version_Number__c       = 1,
            cms__Version_Origin__c       = null,
            cms__Version_Original__c     = true,
            cms__Version_Parent__c       = null,
            cms__Depth__c                = 1
        );
        insert node1;

        cms__Content__c node2 = new cms__Content__c(
            cms__Parent__c               = node1.Id,
            cms__Ancestor__c             = megaMenuContentId,
            cms__Ancestor1__c            = node1.Id,
            cms__Content_Type__c         = nodeType.Id,
            cms__Name__c                 = 'level2',
            cms__Description__c          = 'Testing',
            cms__Preview__c              = true,
            cms__Published__c            = false,
            cms__Published_Start_Date__c = System.now(),
            cms__Site_Name__c            = 'manulife',
            cms__Revision_Number__c      = 0,
            cms__Revision_Origin__c      = null,
            cms__Version_Number__c       = 1,
            cms__Version_Origin__c       = null,
            cms__Version_Original__c     = true,
            cms__Version_Parent__c       = null,
            cms__Depth__c                = 2
        );
        insert node2;

        cms__Content__c node3 = new cms__Content__c(
            cms__Parent__c               = node2.Id,
            cms__Ancestor__c             = megaMenuContentId,
            cms__Ancestor1__c            = node1.Id,
            cms__Ancestor2__c            = node2.Id,
            cms__Content_Type__c         = nodeType.Id,
            cms__Name__c                 = 'level3',
            cms__Description__c          = 'Testing',
            cms__Preview__c              = true,
            cms__Published__c            = false,
            cms__Published_Start_Date__c = System.now(),
            cms__Site_Name__c            = 'manulife',
            cms__Revision_Number__c      = 0,
            cms__Revision_Origin__c      = null,
            cms__Version_Number__c       = 1,
            cms__Version_Origin__c       = null,
            cms__Version_Original__c     = true,
            cms__Version_Parent__c       = null,
            cms__Depth__c                = 3
        );
        insert node3;        

        megaMenu.getHTML(); 
    }


    
}