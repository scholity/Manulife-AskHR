@isTest
private class ocms_mfc_AppLauncher_Test {

	private static ocms_mfc_AppLauncher setup() {
        List<Map<String,String>> testAttributes = new List<Map<String, String>>();
        List<String> attrNames = new List<String>{'title, imageIcon, link'};

        ocms_TestContentHelper tch = new ocms_TestContentHelper();

        // Create an application
        ocms_TestContentHelper.addToAttributesFromList(testAttributes, attrNames);
        tch.createContent(testAttributes, 'App', true);
        String appId = tch.gc.content.Id;

        // Create our app launcher content
        testAttributes = new List<Map<String, String>>();
        attrNames = new List<String>{'tutorialheader', 'alreadySubscribed', 'launchpadAdd', 'launchApp'};

        ocms_TestContentHelper.addToAttributesFromList(testAttributes, attrNames);
        tch.createContent(testAttributes, 'AppPage', false);

        // Test out the default constructor
		ocms_mfc_AppLauncher AppLauncherController = new ocms_mfc_AppLauncher();
		AppLauncherController = new ocms_mfc_AppLauncher(tch.gc);

		System.debug(AppLauncherController);

		ocms_TestContentHelper.testAttributeValuesFromList(attrNames, AppLauncherController);

		return AppLauncherController;
	}

	static testMethod void testAppLauncher() {
		ocms_mfc_AppLauncher AppLauncherController = ocms_mfc_AppLauncher_Test.setup();
		AppLauncherController.appContentRenderings = 'tetsing markup';

		System.debug(AppLauncherController);

		AppLauncherController.getHTML();
	}
}