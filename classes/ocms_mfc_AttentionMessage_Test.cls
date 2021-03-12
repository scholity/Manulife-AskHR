@isTest
public class ocms_mfc_AttentionMessage_Test {
        public static testMethod void testGeneration() {
                // Test the default construction
                ocms_mfc_AttentionMessage AttentionMessageController = new ocms_mfc_AttentionMessage();

                ocms_TestContentHelper tch = new ocms_TestContentHelper();
                List<Map<String,String>> attr_map = new List<Map<String, String>>();

                Map<String, String> am = new Map<String, String>();
                am.put('name', 'text');
                am.put('value', 'sample text');
                am.put('type', 'text');
                attr_map.add(am);

                tch.createContent(attr_map, 'Test');

                AttentionMessageController = new ocms_mfc_AttentionMessage(tch.gc);
                AttentionMessageController.getHTML();
        }
}