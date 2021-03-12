@isTest
private class ocms_mfc_LinkTile_Test {
	
	static testMethod void testLinkTileProperties() {
		ocms_TestContentHelper tch = new ocms_TestContentHelper();
        List<Map<String,String>> attr_map = new List<Map<String, String>>();

        Map<String, String> am = new Map<String, String>();
        am.put('name', 'linkImage');
        am.put('value', 'linkImageTest');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'linkText');
        am.put('value', 'linkTextTest');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'link');
        am.put('value', 'linkTest');
        am.put('type', 'text');
        attr_map.add(am);

        tch.createContent(attr_map, 'Article');

        ocms_mfc_LinkTile lt = new ocms_mfc_LinkTile(tch.gc);

        // Code coverage the mandatory getHTML
        String getHTML = lt.getHTML();

		System.assertEquals(lt.linkImage, 'linkImageTest', 'Expected linkImageTest got: ' + lt.linkImage);
        System.assertEquals(lt.linkText, 'linkTextTest', 'Expected linkTextTest got: ' + lt.linkText);
        System.assertEquals(lt.linkAsData, 'linkTest', 'Expected linkTest got: ' + lt.linkAsData);        

	}
}