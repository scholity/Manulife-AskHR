@isTest
public class ocms_mfc_AccordionItem_Test {
	
	public static testmethod void testAccordingItemExpanded() {
		ocms_TestContentHelper tch = new ocms_TestContentHelper();
		List<Map<String,String>> attr_map = new List<Map<String, String>>();

		Map<String, String> am = new Map<String, String>();
		am.put('name', 'title');
		am.put('value', 'title');
		am.put('type', 'text');
		attr_map.add(am);

		am = new Map<String, String>();
		am.put('name', 'expanded');
		am.put('value', 'true');
		am.put('type', 'text');
		attr_map.add(am);

		am = new Map<String, String>();
		am.put('name', 'content');
		am.put('value', 'content');
		am.put('type', 'text');
		attr_map.add(am);

		tch.createContent(attr_map, 'Test');

		ocms_mfc_AccordionItem AccordionItemController = new ocms_mfc_AccordionItem(tch.gc);

		AccordionItemController.getHTML();
	}


	public static testmethod void testAccordingItemNotExpanded() {
		// Test coverage on the default controlelr
		ocms_mfc_AccordionItem AccordionItemController = new ocms_mfc_AccordionItem();

		ocms_TestContentHelper tch = new ocms_TestContentHelper();
		List<Map<String,String>> attr_map = new List<Map<String, String>>();

		Map<String, String> am = new Map<String, String>();
		am.put('name', 'title');
		am.put('value', 'title');
		am.put('type', 'text');
		attr_map.add(am);

		am = new Map<String, String>();
		am.put('name', 'expanded');
		am.put('value', 'false');
		am.put('type', 'text');
		attr_map.add(am);

		am = new Map<String, String>();
		am.put('name', 'content');
		am.put('value', 'content');
		am.put('type', 'text');
		attr_map.add(am);

		tch.createContent(attr_map, 'Test');

		AccordionItemController = new ocms_mfc_AccordionItem(tch.gc);

		AccordionItemController.getHTML();
	}
}