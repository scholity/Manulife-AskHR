@isTest
private class ASKHR_ArticleDataCategoryUtilTest {
    @isTest(SeeAllData = true) static void testGetAll() {

        Datacategorygroupsobjecttypepair pair = new Datacategorygroupsobjecttypepair();
        pair.setSobject('KnowledgeArticleVersion');
        pair.setDataCategoryGroupName('Geography');
        DescribeDataCategoryGroupStructureResult[] results = Schema.describeDataCategoryGroupStructures(new Datacategorygroupsobjecttypepair[]
                                                                                                        { pair }, false);
        system.debug('results:' + results);
        system.debug('results 0 : ' + results[0]);
        for (Integer i = 0; i < results[0].getTopCategories().size(); i++)
        {
            DataCategory root = results[0].getTopCategories() [i];
            DataCategory[] yetToBeProcessed = root.getChildCategories();
            system.debug('YTBP:' + yetToBeProcessed);
        }
    }

    static testMethod void validateCategoryGroups() {
        String[] objTypes = new String[] { 'KnowledgeArticleVersion' };
        Describedatacategorygroupresult[] datacategorygroupresult =
        Schema.describeDataCategoryGroups(objTypes);
        ASKHR_ArticleDataCategoryGroupInfo[] dataCategoryGroupInfo =
        ASKHR_ArticleDataCategoryUtil.getInstance().getAllCategoryGroups();
        System.assertEquals(datacategorygroupresult.size(), dataCategoryGroupInfo.size());
    }
    static testMethod void validateCategoryGroupsResults() {
        ASKHR_ArticleDataCategoryGroupInfo[] dataCategoryGroupInfo =
        ASKHR_ArticleDataCategoryUtil.getInstance().getAllCategoryGroups();
        String[] objTypes = new String[] { 'KnowledgeArticleVersion' };
        Describedatacategorygroupresult[] datacategorygroupresult =
        Schema.describeDataCategoryGroups(objTypes);
        for (Integer i = 0; i < dataCategoryGroupInfo.size(); i++) {
            System.assertEquals(dataCategoryGroupInfo[i].getName(), datacategorygroupresult[i].getName());
            System.assertEquals(dataCategoryGroupInfo[i].getLabel(), datacategorygroupresult[i].getLabel());
            System.assertEquals(dataCategoryGroupInfo[i].getDescription(), datacategorygroupresult[i].getDescription());
        }
    }
}