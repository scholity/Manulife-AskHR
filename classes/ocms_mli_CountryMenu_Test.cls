@isTest
private class ocms_mli_CountryMenu_Test {
	
	@isTest static void instantiate() {

        ocms_TestContentHelper tch = new ocms_TestContentHelper();
        ocms_mli_CountryMenu countryMenu = new ocms_mli_CountryMenu();
        List<Map<String, String>> attr_map = new List<Map<String,String>>();

        Map<String, String> am = new Map<String, String>();
        am.put('name', 'lblCloseButton');
        am.put('value', 'Back');
        am.put('type', 'Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'accDescription');
        am.put('value', 'List of Manulife global websites: Has popup');
        am.put('type', 'Text');
        attr_map.add(am);

        
        am = new Map<String, String>();
        am.put('name', 'accPopupMsg');
        am.put('value', 'Opens in a popup');
        am.put('type', 'Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'accNewWindowMsg');
        am.put('value', 'Opens in a new window');
        am.put('type', 'Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'accSameWindowMsg');
        am.put('value', 'Opens in the same window');
        am.put('type', 'Text');
        attr_map.add(am);

        tch.createContent(attr_map, 'countryMenu');
        countryMenu = new ocms_mli_CountryMenu(tch.gc);

        System.Debug('**** lblCloseButton: ' + countryMenu.lblCloseButton);
        System.Debug('**** accDescription: ' + countryMenu.accDescription);
        System.Debug('**** accPopupMsg: ' + countryMenu.accPopupMsg);
        System.Debug('**** accNewWindowMsg: ' + countryMenu.accNewWindowMsg);
        System.Debug('**** accSameWindowMsg: ' + countryMenu.accSameWindowMsg);

        Test.setCurrentPageReference(new PageReference('/apex/cms__CreateContent'));
        System.currentPageReference().getParameters().put('sname', 'manulife');
        System.currentPageReference().getParameters().put('content', tch.gc.content.Id);

        cms.CreateContentController ccc = new cms.CreateContentController();
        countryMenu = new ocms_mli_CountryMenu(ccc);

	}
	
	@isTest static void oneLevelMenu() {
		
        ocms_TestContentHelper tch = new ocms_TestContentHelper();
        ocms_mli_CountryMenu countryMenu = new ocms_mli_CountryMenu();
        List<Map<String, String>> attr_map = new List<Map<String, String>>();

        // Not a real attribute, but createContent needs something to work with.
        Map<String, String> am = new Map<String, String>();
        am.put('name', 'test');
        am.put('value', 'test');
        am.put('type', 'Text');
        attr_map.add(am);

        tch.createContent(attr_map, 'countryMenu');
        countryMenu = new ocms_mli_CountryMenu(tch.gc);
        String countryMenuId = tch.content_properties[0].cms__Content__c;

        cms__Content_Type__c nodeType = new cms__Content_Type__c(
            cms__Name__c = 'MenuItem',
            cms__Site_Name__c = 'manulife'
        );
        insert nodeType;

        cms__Content__c node1 = new cms__Content__c(

            cms__Parent__c               = countryMenuId,
            cms__Ancestor__c             = countryMenuId,
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


        //These don't work yet... leave it for now.
        cms__Attribute__c privateURL = new cms__Attribute__c(

            cms__Name__c                 = 'PrivateUrl',
            cms__Simple_Name__c          = 'PrivateUrl',
            cms__Value__c                = 'http://www.google.ca',
            cms__Content__c              = node1.Name

        );
        insert privateURL;

        cms__Attribute__c publicURL = new cms__Attribute__c(

            cms__Name__c                 = 'PublicUrl',
            cms__Simple_Name__c          = 'PublicUrl',
            cms__Value__c                = 'http://www.google.ca',
            cms__Content__c              = node1.Name

        );
        insert publicURL;

        cms__Attribute__c target = new cms__Attribute__c(

            cms__Name__c                 = 'Target',
            cms__Simple_Name__c          = 'Target',
            cms__Value__c                = 'NewWindow',
            cms__Content__c              = node1.Name

        );
        insert target;

        countryMenu.getHTML();

	}
	
}