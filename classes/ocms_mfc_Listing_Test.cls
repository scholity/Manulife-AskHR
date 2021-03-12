@isTest
public class ocms_mfc_Listing_Test {

	public static testmethod void ocms_mfc_Listing_Test() {
		ocms_mfc_Listing ListingController = new ocms_mfc_Listing();
		ocms_TestContentHelper tch = new ocms_TestContentHelper();
		List<Map<String,String>> attr_map = new List<Map<String, String>>();

        Map<String, String> am = new Map<String, String>();
        am.put('name', 'showLike');
        am.put('value', 'true');
        am.put('type', 'text') ;
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'showShare');
        am.put('value', 'true');
        am.put('type', 'text') ;
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'text');
        am.put('value', 'text');
        am.put('type', 'text') ;
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'thumbnail');
        am.put('value', 'thumbnail');
        am.put('type', 'text') ;
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'title');
        am.put('value', 'title');
        am.put('type', 'text') ;
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'link');
        am.put('value', 'www.google.ca');
        am.put('type', 'Link');
        attr_map.add(am);

		tch.createContent(attr_map, 'Test');

        ListingController = new ocms_mfc_Listing(tch.gc); 
        ListingController.getHTML();
	}
}