@isTest
private class ocms_mli_Table_Test {

	static testMethod void createTable() {

		ocms_mli_Table TableController = new ocms_mli_Table();

        ocms_TestContentHelper tch = new ocms_TestContentHelper();
        List<Map<String,String>> attr_map = new List<Map<String, String>>();

        Map<String, String> am = new Map<String, String>();
        am.put('name', 'sMobileInstructionText');
        am.put('value', 'sMobileInstructionText');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'sTableDetail');
        am.put('value', 'sTableDetail');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'sNoteText');
        am.put('value', 'sNoteText');
        am.put('type', 'text');
        attr_map.add(am);

        tch.createContent(attr_map, 'MLITable');
        TableController = new ocms_mli_Table(tch.gc);

        String getHTML = TableController.getHTML();

        System.assertEquals('sMobileInstructionText', TableController.sMobileInstructionText, 'Expected sMobileInstructionText got: ' + TableController.sMobileInstructionText);
        System.assertEquals('sTableDetail', TableController.sTableDetail, 'Expected sTableDetail got: ' + TableController.sTableDetail);
        System.assertEquals('sNoteText', TableController.sNoteText, 'Expected sNoteText got: ' + TableController.sNoteText);
	}

}