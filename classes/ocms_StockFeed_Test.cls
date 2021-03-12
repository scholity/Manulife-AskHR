@isTest
public with sharing class ocms_StockFeed_Test {

    public static testMethod void testGetMFCStockWidget() {
    	Test.setMock(HTTPCalloutMock.class, new ocms_StockFeedUpdateCurrentTests.CurrentFeedSuccessMock());
		ocms_StockFeedUpdateCurrent stockFeedUpdateCurrent = new ocms_StockFeedUpdateCurrent();

		stockFeedUpdateCurrent.fetchAndStore();

    	// Create the Stock_Market_Location__C custom setting.
    	Stock_Market_Location__c testStartMarketLocation = new Stock_Market_Location__c();
    	testStartMarketLocation.Name = 'Canada';
    	testStartMarketLocation.Country__c = 'Canada';
    	testStartMarketLocation.Exchange__c = 'TSX';
    	testStartMarketLocation.Site__c = 'MFC';
    	testStartMarketLocation.Symbol__c = 'MFC.TO';
    	testStartMarketLocation.Currency_Label__c = 'CAD';
    	testStartMarketLocation.Currency_Symbol__c = '$';

    	insert testStartMarketLocation;

    	String testStartMarketLocationId = testStartMarketLocation.Id;

    	testStartMarketLocation = [SELECT Symbol__c, Exchange__c, Currency_Label__c FROM Stock_Market_Location__c WHERE Name = 'Canada'];

		RecordType rt = Database.query('SELECT Id FROM RecordType WHERE SObjectType = \'Feed_Data__c\' AND Name = \'Stock Price Current\' LIMIT 1');
		String recordTypeId = rt.Id;

		String stockMarketSymbol = testStartMarketLocation.Symbol__c;
		String stockMarketExchange = testStartMarketLocation.Exchange__c;

		System.debug(Database.query('SELECT Id FROM Feed_Data__c'));
		System.debug(Database.query('SELECT Id, Current_Change__c, Current_Trade__c, LastModifiedDate, Exchange__c, RecordType.Id, Symbol__c FROM Feed_Data__c'));

        List<Feed_Data__c> stockPrices = Database.query('SELECT Id, Current_Change__c, Current_Trade__c, LastModifiedDate FROM Feed_Data__c WHERE RecordType.Id = :recordTypeId AND Exchange__c = :stockMarketExchange AND Symbol__c = :stockMarketSymbol');
        Feed_Data__c stockPrice = new Feed_Data__c();

        // We need to create the stock feed just in case the database didnt create it.
        if (stockPrices.isEmpty()) {
            // Ensure that there is no data
            List<Feed_Data__c> stockFeedDataPurge = [SELECT Id FROM Feed_Data__c];

            delete stockFeedDataPurge;

            stockPrice.Current_Change__c = 20.00;
            stockPrice.Current_Trade__c = 25.00;
            stockPrice.RecordTypeId = recordTypeId;
            stockPrice.Exchange__c = stockMarketExchange;
            stockPrice.Symbol__c = stockMarketSymbol;

            insert stockPrice;

            String strockPriceId = stockPrice.Id;

            stockPrice = Database.query('SELECT Id, Current_Change__c, Current_Trade__c, LastModifiedDate FROM Feed_Data__c WHERE Id = :strockPriceId');
        } else {
            stockPrice = stockPrices[0];
        }

    	ocms_mfc_StockWidget StockFeedController = new ocms_mfc_StockWidget();

    	String widgetHTML = StockFeedController.getHTML();
    	System.debug(widgetHTML);

    	String expectedCurrencyLabelMarkup = '<sub>' + testStartMarketLocation.Currency_Label__c + '</sub>';
    	System.assert(widgetHTML.contains(expectedCurrencyLabelMarkup), 'Expected to find: ' + expectedCurrencyLabelMarkup + ' in the markup.');

    	String expectedStockPriceMarkup = stockPrice.Current_Trade__c + '<sub>';
        System.debug(widgetHTML);
    	System.assert(widgetHTML.contains(expectedStockPriceMarkup), 'Expected to find: ' + expectedStockPriceMarkup + ' in the markup.');
    }

    public static testMethod void testGetMLIStockWidget() {
        //Test.setMock(HTTPCalloutMock.class, new ocms_StockFeedUpdateCurrentTests.CurrentFeedSuccessMock());
        ocms_StockFeedUpdateCurrent stockFeedUpdateCurrent = new ocms_StockFeedUpdateCurrent();

        stockFeedUpdateCurrent.fetchAndStore();

        // Create the Stock_Market_Location__C custom setting.
        Stock_Market_Location__c testStartMarketLocation = new Stock_Market_Location__c();
        testStartMarketLocation.Name = 'Canada';
        testStartMarketLocation.Country__c = 'CAN';
        testStartMarketLocation.Exchange__c = 'TSX';
        testStartMarketLocation.Site__c = 'MFC';
        testStartMarketLocation.Symbol__c = 'MFC.TO';
        testStartMarketLocation.Currency_Label__c = 'CAD';
        testStartMarketLocation.Currency_Symbol__c = '$';

        insert testStartMarketLocation;

        String testStartMarketLocationId = testStartMarketLocation.Id;

        testStartMarketLocation = [SELECT Symbol__c, Exchange__c, Currency_Label__c FROM Stock_Market_Location__c WHERE Name = 'Canada'];

        RecordType rt = Database.query('SELECT Id FROM RecordType WHERE SObjectType = \'Feed_Data__c\' AND Name = \'Stock Price Current\' LIMIT 1');
        String recordTypeId = rt.Id;

        String stockMarketSymbol = testStartMarketLocation.Symbol__c;
        String stockMarketExchange = testStartMarketLocation.Exchange__c;

        System.debug(Database.query('SELECT Id FROM Feed_Data__c'));
        System.debug(Database.query('SELECT Id, Current_Change__c, Current_Trade__c, LastModifiedDate, Exchange__c, RecordType.Id, Symbol__c FROM Feed_Data__c'));

        List<Feed_Data__c> stockPrices = Database.query('SELECT Id, Current_Change__c, Current_Trade__c, LastModifiedDate FROM Feed_Data__c WHERE RecordType.Id = :recordTypeId AND Exchange__c = :stockMarketExchange AND Symbol__c = :stockMarketSymbol');
        Feed_Data__c stockPrice = new Feed_Data__c();

        // We need to create the stock feed just in case the database didnt create it. 
        if (stockPrices.isEmpty()) {
            // Ensure that there is no data
            List<Feed_Data__c> stockFeedDataPurge = [SELECT Id FROM Feed_Data__c];

            delete stockFeedDataPurge;

            stockPrice.Current_Change__c = 20.00;
            stockPrice.Current_Trade__c = 25.00;
            stockPrice.RecordTypeId = recordTypeId;
            stockPrice.Exchange__c = stockMarketExchange;
            stockPrice.Symbol__c = stockMarketSymbol;

            insert stockPrice;

            String strockPriceId = stockPrice.Id;
            
            stockPrice = Database.query('SELECT Id, Current_Change__c, Current_Trade__c, LastModifiedDate FROM Feed_Data__c WHERE Id = :strockPriceId');
        } else {
            stockPrice = stockPrices[0];
        }

        ocms_StockFeed stockFeed = new ocms_StockFeed();
        List<ocms_StockFeed.StockFeed> stockFeedList = new List<ocms_StockFeed.StockFeed>();
        stockFeedList = stockFeed.getMLIStockFeed('MFC');
    }

    public static testMethod void testCoverageConstrucotrs() {
    	ocms_StockFeed StockFeedController = new ocms_StockFeed();
    	StockFeedController.getHTML();

    	ocms_TestContentHelper tch = new ocms_TestContentHelper();
    	tch.createContent(new List<Map<String, String>>(), 'testing');

    	StockFeedController = new ocms_StockFeed(tch.gc);
    }
}