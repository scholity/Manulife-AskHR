@isTest
public class ocms_mfc_BoxContent_Test {
	
	public static testmethod void testBoxContentMarkup() {
		ocms_mfc_BoxContentLarge BoxContentLargeController = new ocms_mfc_BoxContentLarge();
		ocms_mfc_BoxContentSmall BoxContentSmallController = new ocms_mfc_BoxContentSmall();
		ocms_TestContentHelper tch = new ocms_TestContentHelper();
		List<Map<String,String>> attr_map = new List<Map<String, String>>();

		Map<String, String> am = new Map<String, String>();
		am.put('name', 'text');
		am.put('value', 'text');
		am.put('type', 'text');
		attr_map.add(am);

		tch.createContent(attr_map, 'Test');

		BoxContentLargeController = new ocms_mfc_BoxContentLarge(tch.gc);

		BoxContentLargeController.getHTML();

		BoxContentSmallController = new ocms_mfc_BoxContentSmall(tch.gc);

		BoxContentSmallController.getHTML();
	}
}