@isTest
public class ocms_mfc_SliderImage_Test {

	public static testmethod void testSliderImageMarkup() {
		ocms_mfc_SliderImage SliderImageController = new ocms_mfc_SliderImage();
		ocms_TestContentHelper tch = new ocms_TestContentHelper();
		List<Map<String,String>> attr_map = new List<Map<String, String>>();

		Map<String, String> am = new Map<String, String>();
		am.put('name', 'title');
		am.put('value', 'title');
		am.put('type', 'text');
		attr_map.add(am);

		am = new Map<String, String>();
		am.put('name', 'thumbnail');
		am.put('value', 'thumbnail');
		am.put('type', 'text');
		attr_map.add(am);

		am = new Map<String, String>();
		am.put('name', 'image');
		am.put('value', 'image');
		am.put('type', 'text');
		attr_map.add(am);

		am = new Map<String, String>();
		am.put('name', 'altText');
		am.put('value', 'altText');
		am.put('type', 'text');
		attr_map.add(am);

		tch.createContent(attr_map, 'Test');

		SliderImageController = new ocms_mfc_SliderImage(tch.gc);
		SliderImageController.getHTML();
	}
}