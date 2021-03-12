@isTest
private class ocms_mfc_ArticleMeta_Test {

	static testMethod void testGetters() {
        // Test the default controller
        ocms_mfc_ArticleMeta ArticleMetaController = new ocms_mfc_ArticleMeta();
         
        List<Map<String,String>> testAttributes = new List<Map<String, String>>();

        List<String> attrNames = new List<String>{
            'articleAuthor',
            'articleTitle'
        };

        ocms_TestContentHelper tch = new ocms_TestContentHelper();
        ocms_TestContentHelper.addToAttributesFromList(testAttributes, attrNames);
        
        tch.createContent(testAttributes, '');
        
        ArticleMetaController = new ocms_mfc_ArticleMeta(tch.gc);
        ArticleMetaController.getHTML();
        
        ocms_TestContentHelper.testAttributeValuesFromList(attrNames, ArticleMetaController);
	}
}