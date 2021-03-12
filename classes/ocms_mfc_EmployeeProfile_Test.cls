@isTest
public class ocms_mfc_EmployeeProfile_Test {
	
	public static testMethod void testWithLink() {
		ocms_mfc_EmployeeProfile EmployeeProfileController = new ocms_mfc_EmployeeProfile();

		ocms_TestContentHelper tch = new ocms_TestContentHelper();
		List<Map<String,String>> attr_map = new List<Map<String, String>>();

        Map<String, String> am = new Map<String, String>();
        am.put('name', 'image');
        am.put('value', 'image');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'name');
        am.put('value', 'name');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'description');
        am.put('value', 'description');
        am.put('type', 'text');
        attr_map.add(am);


        am = new Map<String, String>();
        am.put('name', 'link');
        am.put('value', 'link');
        am.put('type', 'Link');
        attr_map.add(am);

        tch.createContent(attr_map, 'EmployeeProfile');

        EmployeeProfileController = new ocms_mfc_EmployeeProfile(tch.gc);
        EmployeeProfileController.getHTML();
	}

	public static testMethod void testWithoutLink() {
		ocms_TestContentHelper tch = new ocms_TestContentHelper();
		List<Map<String,String>> attr_map = new List<Map<String, String>>();

        Map<String, String> am = new Map<String, String>();
        am.put('name', 'image');
        am.put('value', 'image');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'name');
        am.put('value', 'name');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'description');
        am.put('value', 'description');
        am.put('type', 'text');
        attr_map.add(am);

        tch.createContent(attr_map, 'EmployeeProfile');

        ocms_mfc_EmployeeProfile EmployeeProfileController = new ocms_mfc_EmployeeProfile(tch.gc);
        EmployeeProfileController.getHTML();
	}
}