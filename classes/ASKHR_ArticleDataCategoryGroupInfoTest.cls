@isTest
private class ASKHR_ArticleDataCategoryGroupInfoTest {
    static testMethod void validateDataCategoryGroupInfoObject(){
        ASKHR_ArticleDataCategoryInfo[] structure = new ASKHR_ArticleDataCategoryInfo[1];
        structure[0] = new ASKHR_ArticleDataCategoryInfo('Product','Product__c','Product__c');
        ASKHR_ArticleDataCategoryGroupInfo dataCategoryGroupInfo = new
            ASKHR_ArticleDataCategoryGroupInfo('Product','Product__c','Test DataCategoryInfoClass',structure);
        System.assertEquals('Product', dataCategoryGroupInfo.getName());
        System.assertEquals('Product__c', dataCategoryGroupInfo.getLabel());
        System.assertEquals('Test DataCategoryInfoClass', dataCategoryGroupInfo.getDescription());
        System.assertEquals(structure.size(),dataCategoryGroupInfo.getGroupStructure().size());
    }
}