@isTest
public class ocms_mfc_Clear_Test {
	
	public static testmethod void testClearMarkup() {
		ocms_mfc_Clear ClearController = new ocms_mfc_Clear();
		ocms_TestContentHelper tch = new ocms_TestContentHelper();
		List<Map<String,String>> attr_map = new List<Map<String, String>>();

		Map<String, String> am = new Map<String, String>();
		am.put('name', 'text');
		am.put('value', 'text');
		am.put('type', 'text');
		attr_map.add(am);

		tch.createContent(attr_map, 'Test');

		ClearController = new ocms_mfc_Clear(tch.gc);
		ClearController.getHTML();
	}
}