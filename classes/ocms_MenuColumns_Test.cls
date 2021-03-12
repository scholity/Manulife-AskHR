/**
 *  ocms_MenuColumns_Test.cls
 *
 *  2015-May-16 Bill Lucas
 *              Original, but cloned from ocms_mli_SiteMap_Test.cls; added tests for addtional method generateMarkupFromMenuNode();
 *              also, we note that at present this is actually more of a coverage class than a test class
 */

@isTest
private class ocms_MenuColumns_Test {
	
	static final String SITENAME = 'MFCentral';


	@isTest static void instantiate() {
        ocms_TestContentHelper tch = new ocms_TestContentHelper();
        ocms_MenuColumns siteMap = new ocms_MenuColumns();
        List<Map<String, String>> attr_map = new List<Map<String,String>>();

        tch.createContent(attr_map, 'siteMap');
        siteMap = new ocms_MenuColumns(tch.gc);

        Test.setCurrentPageReference(new PageReference('/apex/cms__CreateContent'));
        System.currentPageReference().getParameters().put('sname', SITENAME);
        System.currentPageReference().getParameters().put('content', tch.gc.content.Id);

        cms.CreateContentController ccc = new cms.CreateContentController();
        siteMap = new ocms_MenuColumns(ccc);
	}

	
	@isTest static void oneLevelMenu() {
		
        ocms_TestContentHelper tch = new ocms_TestContentHelper();
        ocms_MenuColumns siteMap = new ocms_MenuColumns();
        List<Map<String, String>> attr_map = new List<Map<String, String>>();

        // Not a real attribute, but createContent needs something to work with.
        Map<String, String> am = new Map<String, String>();
        am.put('name', 'test');
        am.put('value', 'test');
        am.put('type', 'Text');
        attr_map.add(am);

        tch.createContent(attr_map, 'siteMap');
        siteMap = new ocms_MenuColumns(tch.gc);
        String siteMapId = tch.content_properties[0].cms__Content__c;

        cms__Content_Type__c nodeType = new cms__Content_Type__c(
            cms__Name__c = 'MenuItem',
            cms__Site_Name__c = SITENAME
        );
        insert nodeType;

        cms__Content__c node1 = new cms__Content__c(

            cms__Parent__c               = siteMapId,
            cms__Ancestor__c             = siteMapId,
            cms__Content_Type__c         = nodeType.Id,
            cms__Name__c                 = 'level1',
            cms__Description__c          = 'Testing',
            cms__Preview__c              = true,
            cms__Published__c            = false,
            cms__Published_Start_Date__c = System.now(),
            cms__Site_Name__c            = SITENAME,
            cms__Revision_Number__c      = 0,
            cms__Revision_Origin__c      = null,
            cms__Version_Number__c       = 1,
            cms__Version_Origin__c       = null,
            cms__Version_Original__c     = true,
            cms__Version_Parent__c       = null,
            cms__Depth__c                = 1

        );
        insert node1;

        siteMap.getHTML();
	}


    @isTest static void threeLevelMenu() {

        ocms_TestContentHelper tch = new ocms_TestContentHelper();
        ocms_MenuColumns siteMap = new ocms_MenuColumns();
        List<Map<String, String>> attr_map = new List<Map<String, String>>();

        // Not a real attribute, but createContent needs something to work with.
        Map<String, String> am = new Map<String, String>();
        am.put('name', 'test');
        am.put('value', 'test');
        am.put('type', 'Text');
        attr_map.add(am);

        tch.createContent(attr_map, 'siteMap');
        siteMap = new ocms_MenuColumns(tch.gc);
        String siteMapId = tch.content_properties[0].cms__Content__c;

        cms__Content_Type__c nodeType = new cms__Content_Type__c(
            cms__Name__c = 'MenuItem',
            cms__Site_Name__c = SITENAME
        );
        insert nodeType;

        cms__Content__c node1 = new cms__Content__c(

            cms__Parent__c               = siteMapId,
            cms__Ancestor__c             = siteMapId,
            cms__Content_Type__c         = nodeType.Id,
            cms__Name__c                 = 'level1',
            cms__Description__c          = 'Testing',
            cms__Preview__c              = true,
            cms__Published__c            = false,
            cms__Published_Start_Date__c = System.now(),
            cms__Site_Name__c            = SITENAME,
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
            cms__Ancestor__c             = siteMapId,
            cms__Ancestor1__c            = node1.Id,
            cms__Content_Type__c         = nodeType.Id,
            cms__Name__c                 = 'level2',
            cms__Description__c          = 'Testing',
            cms__Preview__c              = true,
            cms__Published__c            = false,
            cms__Published_Start_Date__c = System.now(),
            cms__Site_Name__c            = SITENAME,
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
            cms__Ancestor__c             = siteMapId,
            cms__Ancestor1__c            = node1.Id,
            cms__Ancestor2__c            = node2.Id,
            cms__Content_Type__c         = nodeType.Id,
            cms__Name__c                 = 'level2',
            cms__Description__c          = 'Testing',
            cms__Preview__c              = true,
            cms__Published__c            = false,
            cms__Published_Start_Date__c = System.now(),
            cms__Site_Name__c            = SITENAME,
            cms__Revision_Number__c      = 0,
            cms__Revision_Origin__c      = null,
            cms__Version_Number__c       = 1,
            cms__Version_Origin__c       = null,
            cms__Version_Original__c     = true,
            cms__Version_Parent__c       = null,
            cms__Depth__c                = 3

        );
        insert node3;

        siteMap.getHTML();
    }

    @isTest static void testMenuNodeMarkup () {

        ocms_TestContentHelper tch = new ocms_TestContentHelper(SITENAME);

		List<Map<String, String>> attributes = new List<Map<String, String>>();
		//Attribute__c[] attributes = [
		//];

		List<String> attrNames = new List<String>{
			'targetPage,http://useabill.org/quotable/',
			//'javascript',
			//'target',
			'name,Click me, click me not!'			// this is NOT working to set the menu item text (name)
		};

		ocms_TestContentHelper.addToAttributesFromList(attributes, attrNames);

		final String contentTypeName = 'MFCSiteMap';
		tch.createContent(attributes, contentTypeName);

        ocms_MenuColumns siteMap = new ocms_MenuColumns(tch.gc);

        String siteMapId = tch.content_properties[0].cms__Content__c;

        cms__Content_Type__c contentType = new cms__Content_Type__c(
            cms__Name__c = 'MenuItem',
            cms__Site_Name__c = SITENAME
        );
        insert contentType;

		cms__Content__c menuContent = new cms__Content__c(
            cms__Parent__c               = siteMapId,
            cms__Ancestor__c             = siteMapId,
            cms__Content_Type__c         = contentType.Id,
            cms__Name__c                 = 'level0',
            cms__Description__c          = 'Testing',
            cms__Preview__c              = true,
            cms__Published__c            = false,
            cms__Published_Start_Date__c = System.now(),
            cms__Site_Name__c            = SITENAME,
            cms__Revision_Number__c      = 0,
            cms__Revision_Origin__c      = null,
            cms__Version_Number__c       = 1,
            cms__Version_Origin__c       = null,
            cms__Version_Original__c     = true,
            cms__Version_Parent__c       = null,
            cms__Depth__c                = 1
		);


		final String pageMode = 'prod';
		final String previewParameters = '';
		final cms.MenuNode parentMenuNode = null;

		//	global MenuNode(Content__c mi, Attribute__c[] attribs, String pm, String sn, String pp, MenuNode p) {
		//		this(mi, attribs, pm, sn, pp, p, 0, null);
		//	}
    	//cms.MenuNode menuNode = new cms.MenuNode(menuContent, attributes, pageMode, siteName, previewParameters, parentMenuNode);
    	
    	System.debug('siteMap.content_attributes…');
    	System.debug(siteMap.content_properties);

    	cms.MenuNode menuNode = new cms.MenuNode(menuContent, siteMap.content_properties, pageMode, siteName, previewParameters, parentMenuNode);

    	String nodeMarkup = ocms_MenuColumns.generateMarkupFromMenuNode(menuNode);
    	System.debug(nodeMarkup);


    }
}	// <c ocms_MenuColumns_Test>