@isTest
private class ocms_mli_StockPrice_Test {
    
    @isTest static void instantiation() {

        Test.setMock(HTTPCalloutMock.class, new ocms_StockFeedUpdateCurrentTests.CurrentFeedSuccessMock());
        ocms_StockFeedUpdateCurrent stockFeedUpdateCurrent = new ocms_StockFeedUpdateCurrent();

        stockFeedUpdateCurrent.fetchAndStore();

        Stock_Market_Location__c testStartMarketLocation = new Stock_Market_Location__c();
        testStartMarketLocation.Name = 'Canada';
        testStartMarketLocation.Country__c = 'CAN';
        testStartMarketLocation.Exchange__c = 'TSX';
        testStartMarketLocation.Site__c = 'MFC';
        testStartMarketLocation.Symbol__c = 'MFC.TO';
        testStartMarketLocation.Currency_Label__c = 'CAD';
        testStartMarketLocation.Currency_Symbol__c = '$';

        insert testStartMarketLocation;

        ocms_TestContentHelper tch = new ocms_TestContentHelper();
        ocms_mli_StockPrice stockPrice = new ocms_mli_StockPrice();
        List<Map <String, String>> attr_map = new List<Map <String, String>>();
        
        Map<String, String> am = new Map<String, String>();
        am.put('name', 'strTitle');
        am.put('value', 'Stocks');
        am.put('type', 'Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'strIcon');
        am.put('value', 'http://imgur.com/gallery/I8qRYof');
        am.put('type', 'Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'strLinkText');
        am.put('value', 'Read More');
        am.put('type', 'Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'strLink');
        am.put('value', 'External,,NewWindow,,,,http://www.google.ca');
        am.put('type', 'Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'accStock');
        am.put('value', 'Stock');
        am.put('type', 'Text');
        attr_map.add(am);
        
        am = new Map<String, String>();
        am.put('name', 'accStockPrice');
        am.put('value', 'Stock Price');
        am.put('type', 'Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'accIncrease');
        am.put('value', 'Increase');
        am.put('type', 'Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'accDecrease');
        am.put('value', 'Decrease');
        am.put('type', 'Text');
        attr_map.add(am);

        tch.createContent(attr_map, 'stockPrice');
        stockPrice = new ocms_mli_StockPrice(tch.gc);
        
        stockPrice.getHTML();
        
        Test.setCurrentPageReference(new PageReference('/apex/cms__CreateContent'));
        System.currentPageReference().getParameters().put('sname','manulife');
        System.currentPageReference().getParameters().put('content',tch.gc.content.Id);
        
        cms.CreateContentController ccc = new cms.CreateContentController();
        stockPrice = new ocms_mli_StockPrice(ccc);

    }
}