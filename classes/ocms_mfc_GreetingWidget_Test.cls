@isTest
public with sharing class ocms_mfc_GreetingWidget_Test {
	public static testMethod void testGetGreetingWidget() {
		ocms_TestContentHelper tch = new ocms_TestContentHelper();
        
        List<Map<String,String>> attr_map = new List<Map<String, String>>();
        tch.createContent(attr_map, 'Article');
        
		User testUser = tch.createAndInsertUser(new Map<String, String>{
			'City' => 'Kingston',
			'Country' => 'Canada',
			'Username' => 'shawn.wilderr@stantive.com.devcms',
            'FirstName' => 'DevenderThareja'
		});

        String htmlCode='';
        System.runAs(testUser) {
			ocms_mfc_GreetingWidget GreetingWidgetController = new ocms_mfc_GreetingWidget();
			htmlCode=GreetingWidgetController.getHTML();
		}
        System.debug(htmlCode);
        System.assert(htmlCode.contains('DevenderThareja'), true);
	}

	public static testMethod void getGetters() {
		List<Map<String,String>> testAttributes = new List<Map<String, String>>();

		List<String> attrNames = new List<String>{
			'morningGreeting',
			'afternoonGreeting',
			'eveningGreeting'
		};
		
		ocms_TestContentHelper tch = new ocms_TestContentHelper();
		ocms_TestContentHelper.addToAttributesFromList(testAttributes, attrNames);

        tch.createContent(testAttributes, '');
        
        ocms_mfc_GreetingWidget GreetingWidgetController = new ocms_mfc_GreetingWidget(tch.gc);

        System.debug(GreetingWidgetController.afternoonGreeting);
        System.debug(GreetingWidgetController.eveningGreeting);
        System.debug(GreetingWidgetController.morningGreeting);
	}
    
}