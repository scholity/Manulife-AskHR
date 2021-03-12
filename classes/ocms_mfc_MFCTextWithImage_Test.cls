@isTest
public class ocms_mfc_MFCTextWithImage_Test {

	public static testmethod void testMFCTextWithImageMarkup() {
		ocms_mfc_MFCTextWithImage MFCTextWithImageController = new ocms_mfc_MFCTextWithImage();
		ocms_TestContentHelper tch = new ocms_TestContentHelper();
		List<Map<String,String>> attr_map = new List<Map<String, String>>();

		Map<String, String> am = new Map<String, String>();
		am.put('name', 'text');
		am.put('value', 'text');
		am.put('type', 'text');
		attr_map.add(am);

		tch.createContent(attr_map, 'Test');

		MFCTextWithImageController = new ocms_mfc_MFCTextWithImage(tch.gc);
		MFCTextWithImageController.getHTML();
	}
}