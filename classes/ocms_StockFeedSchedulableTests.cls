@isTest
public with sharing class ocms_StockFeedSchedulableTests {
    public static testmethod void testExecute() {
        Test.startTest();

        // String jobId = System.schedule('stock feed 2', '0 0 * * * ?', new ocms_StockFeedSchedulable('test_stock_price_update'));

        Test.stopTest();

        // Original job should be gone after one execution
        //System.assertEquals(0, [select Id from CronTrigger where Id=:jobId].size(), 'Original job should be cancelled');
    }
}