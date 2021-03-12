@isTest
private class ASKHR_ArticleDataCategoryInfoTest {
    static testMethod void validateDataCategoryInfoObject() {
        ASKHR_ArticleDataCategoryInfo dataCategoryInfo = new ASKHR_ArticleDataCategoryInfo('Products__c', 'Products__c',
                                                                 'Products');
        System.assertEquals('Products__c',dataCategoryInfo.getName());
        System.assertEquals('Products__c',dataCategoryInfo.getLabel());
        System.assertEquals('Products',dataCategoryInfo.getDisplayName());
    }
}