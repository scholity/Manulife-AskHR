@isTest
private class ocms_mfc_LocationContent_Test {
	
	public static testmethod void ocms_mfc_LocationContent_Test() {
		ocms_mfc_LocationContent LocationContentController = new ocms_mfc_LocationContent();

		ocms_TestContentHelper tch = new ocms_TestContentHelper();
		List<Map<String,String>> attr_map = new List<Map<String, String>>();

        Map<String, String> am = new Map<String, String>();       
        am.put('name', 'additionallinktext');
        am.put('value', 'additionallinktext');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'description');
        am.put('value', 'description');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'email');
        am.put('value', 'email');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'floorplantext');
        am.put('value', 'floorplantext');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'image');
        am.put('value', 'image');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'locationname');
        am.put('value', 'locationname');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'phone');
        am.put('value', 'phone');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'floorplanlink');
        am.put('value', 'floorplanlink');
        am.put('type', 'Link');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'locationlink');
        am.put('value', 'locationlink');
        am.put('type', 'Link');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'additionallink');
        am.put('value', 'additionallink');
        am.put('type', 'Link');
        attr_map.add(am);

        tch.createContent(attr_map, 'Test');

        LocationContentController = new ocms_mfc_LocationContent(tch.gc);
        LocationContentController.getHTML();
	}
}