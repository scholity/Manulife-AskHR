@isTest
public class ocms_mfc_MFCText_Test {
	
	public static testmethod void testMFCTextMarkup() {
		ocms_mfc_MFCText MFCTextController = new ocms_mfc_MFCText();
		ocms_TestContentHelper tch = new ocms_TestContentHelper();
		List<Map<String,String>> attr_map = new List<Map<String, String>>();

		Map<String, String> am = new Map<String, String>();
		am.put('name', 'text');
		am.put('value', 'text');
		am.put('type', 'text');
		attr_map.add(am);

		tch.createContent(attr_map, 'Test');

		MFCTextController = new ocms_mfc_MFCText(tch.gc);
		MFCTextController.getHTML();
	}
}