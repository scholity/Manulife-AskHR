@isTest
public class ocms_mfc_BookmarkBar_Test {

	public static ocms_TestContentHelper createContent(Map<String, String> singleAttribute) {
		ocms_TestContentHelper tch = new ocms_TestContentHelper();
		List<Map<String,String>> attr_map = new List<Map<String, String>>();

        attr_map.add(singleAttribute);

        tch.createContent(attr_map, 'BookmarkBar');

        return tch;
	}

	public static testmethod void testHasShare() {
		ocms_mfc_BookmarkBar BookmarkBarController = new ocms_mfc_BookmarkBar();

		Map<String, String> am = new Map<String, String>();
		am.put('name', 'share');
		am.put('value', 'true');
		am.put('type', 'text');

		BookmarkBarController = new ocms_mfc_BookmarkBar(ocms_mfc_BookmarkBar_Test.createContent(am).gc);

		List<Map<String,String>> testAttributes = new List<Map<String, String>>();
		ocms_TestContentHelper tch = new ocms_TestContentHelper();

		am = new Map<String, String>();
		am.put('name', 'mandatoryAppIDs');
		am.put('value', 'test');
		am.put('type', 'text');
		testAttributes.add(am);
		
		tch.createContent(testAttributes, 'SitePreferences', false);

		ocms_mfc_SiteSettings__c sitePreferenceCustomSetting = new ocms_mfc_SiteSettings__c();
		sitePreferenceCustomSetting.Name = 'Manulife Central';
		sitePreferenceCustomSetting.Site_Preferences_Id__c = tch.gc.content.Id;

		insert sitePreferenceCustomSetting;

		String html = BookmarkBarController.getHTML();
	}

	public static testmethod void testNotShare() {
		Map<String, String> am = new Map<String, String>();
		am.put('name', 'share');
		am.put('value', 'false');
		am.put('type', 'text');

		ocms_mfc_BookmarkBar BookmarkBarController = new ocms_mfc_BookmarkBar(ocms_mfc_BookmarkBar_Test.createContent(am).gc);
		String html = BookmarkBarController.getHTML();
	}

	public static testmethod void testHasLike() {
		Map<String, String> am = new Map<String, String>();
		am.put('name', 'like');
		am.put('value', 'true');
		am.put('type', 'text');

		ocms_mfc_BookmarkBar BookmarkBarController = new ocms_mfc_BookmarkBar(ocms_mfc_BookmarkBar_Test.createContent(am).gc);
		String html = BookmarkBarController.getHTML();
	}

	public static testmethod void testNotLike() {
		Map<String, String> am = new Map<String, String>();
		am.put('name', 'like');
		am.put('value', 'false');
		am.put('type', 'text');

		ocms_mfc_BookmarkBar BookmarkBarController = new ocms_mfc_BookmarkBar(ocms_mfc_BookmarkBar_Test.createContent(am).gc);
		String html = BookmarkBarController.getHTML();
	}

	public static testmethod void testHasBookmark() {
		Map<String, String> am = new Map<String, String>();
		am.put('name', 'bookmark');
		am.put('value', 'true');
		am.put('type', 'text');

		ocms_mfc_BookmarkBar BookmarkBarController = new ocms_mfc_BookmarkBar(ocms_mfc_BookmarkBar_Test.createContent(am).gc);
		String html = BookmarkBarController.getHTML();
	}

	public static testmethod void testNotBookmark() {
		Map<String, String> am = new Map<String, String>();
		am.put('name', 'bookmark');
		am.put('value', 'false');
		am.put('type', 'text');

		ocms_mfc_BookmarkBar BookmarkBarController = new ocms_mfc_BookmarkBar(ocms_mfc_BookmarkBar_Test.createContent(am).gc);
		String html = BookmarkBarController.getHTML();
	}
}