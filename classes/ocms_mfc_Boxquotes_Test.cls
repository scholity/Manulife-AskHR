@isTest
public class ocms_mfc_Boxquotes_Test {
	
	public static testmethod void testBoxquotesMarkup() {
		ocms_mfc_Boxquotes BoxquotesController = new ocms_mfc_Boxquotes();
		ocms_TestContentHelper tch = new ocms_TestContentHelper();
		List<Map<String,String>> attr_map = new List<Map<String, String>>();

		Map<String, String> am = new Map<String, String>();
		am.put('name', 'text');
		am.put('value', 'text');
		am.put('type', 'text');
		attr_map.add(am);

		tch.createContent(attr_map, 'Test');

		BoxquotesController = new ocms_mfc_Boxquotes(tch.gc);

		BoxquotesController.getHTML();
	}
}