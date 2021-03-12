@isTest
public class ocms_mfc_LinkGroups_Test {
	
	public static testmethod void ocms_mfc_LinkGroups_Test() {
		ocms_mfc_LinkGroups LinkGroupsController = new ocms_mfc_LinkGroups();

		ocms_TestContentHelper tch = new ocms_TestContentHelper();
		List<Map<String,String>> attr_map = new List<Map<String, String>>();
		
		Map<String, String> am = new Map<String, String>();
		am.put('name', 'title');
		am.put('value', 'textValue');
		am.put('type','text');
		attr_map.add(am);

		am = new Map<String, String>();
		am.put('name', 'thumbnail');
		am.put('value', 'textValue');
		am.put('type','text');
		attr_map.add(am);

		am = new Map<String, String>();
		am.put('name', 'linkText1');
		am.put('value', 'textValue');
		am.put('type','text');
		attr_map.add(am);

		am = new Map<String, String>();
		am.put('name', 'linkText2');
		am.put('value', 'textValue');
		am.put('type','text');
		attr_map.add(am);

		am = new Map<String, String>();
		am.put('name', 'linkText3');
		am.put('value', 'textValue');
		am.put('type','text');
		attr_map.add(am);

		am = new Map<String, String>();
		am.put('name', 'linkText4');
		am.put('value', 'textValue');
		am.put('type','text');
		attr_map.add(am);

		am = new Map<String, String>();
		am.put('name', 'linkText5');
		am.put('value', 'textValue');
		am.put('type','text');
		attr_map.add(am);

		am = new Map<String, String>();
		am.put('name', 'linkText6');
		am.put('value', 'textValue');
		am.put('type','text');
		attr_map.add(am);

		am = new Map<String, String>();
		am.put('name', 'linkText7');
		am.put('value', 'textValue');
		am.put('type','text');
		attr_map.add(am);

		am = new Map<String, String>();
		am.put('name', 'linkText8');
		am.put('value', 'textValue');
		am.put('type','text');
		attr_map.add(am);

		am = new Map<String, String>();
		am.put('name', 'linkText9');
		am.put('value', 'textValue');
		am.put('type','text');
		attr_map.add(am);

		am = new Map<String, String>();
		am.put('name', 'linkText10');
		am.put('value', 'textValue');
		am.put('type','text');
		attr_map.add(am);

		am = new Map<String, String>();
		am.put('name', 'link1');
		am.put('value', 'www.google.ca');
		am.put('type', 'Link');
		attr_map.add(am);

		am = new Map<String, String>();
		am.put('name', 'link2');
		am.put('value', 'wwww.google.ca');
		am.put('type', 'Link');
		attr_map.add(am);

		am = new Map<String, String>();
		am.put('name', 'link3');
		am.put('value', 'wwww.google.ca');
		am.put('type', 'Link');
		attr_map.add(am);

		am = new Map<String, String>();
		am.put('name', 'link4');
		am.put('value', 'wwww.google.ca');
		am.put('type', 'Link');
		attr_map.add(am);

		am = new Map<String, String>();
		am.put('name', 'link5');
		am.put('value', 'wwww.google.ca');
		am.put('type', 'Link');
		attr_map.add(am);

		am = new Map<String, String>();
		am.put('name', 'link6');
		am.put('value', 'wwww.google.ca');
		am.put('type', 'Link');
		attr_map.add(am);

		am = new Map<String, String>();
		am.put('name', 'link7');
		am.put('value', 'wwww.google.ca');
		am.put('type', 'Link');
		attr_map.add(am);

		am = new Map<String, String>();
		am.put('name', 'link8');
		am.put('value', 'wwww.google.ca');
		am.put('type', 'Link');
		attr_map.add(am);

		am = new Map<String, String>();
		am.put('name', 'link9');
		am.put('value', 'wwww.google.ca');
		am.put('type', 'Link');
		attr_map.add(am);

		am = new Map<String, String>();
		am.put('name', 'link10');
		am.put('value', 'wwww.google.ca');
		am.put('type', 'Link');
		attr_map.add(am);

		tch.createContent(attr_map, 'Test');

		LinkGroupsController = new ocms_mfc_LinkGroups(tch.gc);
		LinkGroupsController.getHTML();
	}
}