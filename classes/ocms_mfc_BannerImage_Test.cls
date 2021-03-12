@isTest
public class ocms_mfc_BannerImage_Test {
	
	public static testmethod void testBannerImageMarkup() {
		ocms_mfc_BannerImage BannerImageController = new ocms_mfc_BannerImage();
		ocms_TestContentHelper tch = new ocms_TestContentHelper();
		List<Map<String,String>> attr_map = new List<Map<String, String>>();

		Map<String, String> am = new Map<String, String>();
		am.put('name', 'ctcBanImg');
		am.put('value', 'ctcBanImg');
		am.put('type', 'text');
		attr_map.add(am);

		tch.createContent(attr_map, 'Test');

		BannerImageController = new ocms_mfc_BannerImage(tch.gc);

		BannerImageController.getHTML();
	}
}