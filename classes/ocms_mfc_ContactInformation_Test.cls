@isTest
public class ocms_mfc_ContactInformation_Test {
	
	public static testmethod void ocms_mfc_ContactInformation_Test() {
		ocms_mfc_ContactInformation ContactInformationController = new ocms_mfc_ContactInformation();
		ocms_TestContentHelper tch = new ocms_TestContentHelper();
		List<Map<String,String>> attr_map = new List<Map<String, String>>();

		Map<String, String> am = new Map<String, String>();
		am = new Map<String, String>();
		am.put('name','blocktitle');
		am.put('value', 'blocktitle');
		am.put('type','Text');
		attr_map.add(am);

		am = new Map<String, String>();
		am.put('name','email1');
		am.put('value', 'email1');
		am.put('type','Text');
		attr_map.add(am);

		am = new Map<String, String>();
		am.put('name','email2');
		am.put('value', 'email2');
		am.put('type','Text');
		attr_map.add(am);

		am = new Map<String, String>();
		am.put('name','email3');
		am.put('value', 'email3');
		am.put('type','Text');
		attr_map.add(am);

		am = new Map<String, String>();
		am.put('name','emailtitle1');
		am.put('value', 'emailtitle1');
		am.put('type','Text');
		attr_map.add(am);

		am = new Map<String, String>();
		am.put('name','emailtitle2');
		am.put('value', 'emailtitle2');
		am.put('type','Text');
		attr_map.add(am);

		am = new Map<String, String>();
		am.put('name','emailtitle3');
		am.put('value', 'emailtitle3');
		am.put('type','Text');
		attr_map.add(am);

		am = new Map<String, String>();
		am.put('name','name1');
		am.put('value', 'name1');
		am.put('type','Text');
		attr_map.add(am);

		am = new Map<String, String>();
		am.put('name','name2');
		am.put('value', 'name2');
		am.put('type','Text');
		attr_map.add(am);

		am = new Map<String, String>();
		am.put('name','name3');
		am.put('value', 'name3');
		am.put('type','Text');
		attr_map.add(am);

		am = new Map<String, String>();
		am.put('name','phone1');
		am.put('value', 'phone1');
		am.put('type','Text');
		attr_map.add(am);

		am = new Map<String, String>();
		am.put('name','phone2');
		am.put('value', 'phone2');
		am.put('type','Text');
		attr_map.add(am);

		am = new Map<String, String>();
		am.put('name','phone3');
		am.put('value', 'phone3');
		am.put('type','Text');
		attr_map.add(am);

		am = new Map<String, String>();
		am.put('name','title1');
		am.put('value', 'title1');
		am.put('type','Text');
		attr_map.add(am);

		am = new Map<String, String>();
		am.put('name','title2');
		am.put('value', 'title2');
		am.put('type','Text');
		attr_map.add(am);

		am = new Map<String, String>();
		am.put('name','title3');
		am.put('value', 'title3');
		am.put('type','Text');
		attr_map.add(am);

		tch.createContent(attr_map, 'Test');

		ContactInformationController = new ocms_mfc_ContactInformation(tch.gc);
		ContactInformationController.getHTML();
	}
}