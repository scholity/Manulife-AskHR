@isTest
public class ocms_mfc_EmployeeTestimonial_Test {
	
	public static testmethod void testEmployeeTestimonialMarkup() {
		ocms_mfc_EmployeeTestimonial EmployeeTestimonialController = new ocms_mfc_EmployeeTestimonial();
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

		tch.createContent(attr_map, 'Test');

		EmployeeTestimonialController = new ocms_mfc_EmployeeTestimonial(tch.gc);
		EmployeeTestimonialController.getHTML();
	}
}