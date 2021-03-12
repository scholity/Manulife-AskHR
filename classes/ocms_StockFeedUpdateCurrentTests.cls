@isTest
public with sharing class ocms_StockFeedUpdateCurrentTests {
    public static testmethod void testFetchAndStore() {
        ocms_StockFeedUpdateCurrent stockFeedUpdateCurrent = new ocms_StockFeedUpdateCurrent();
        Feed_Data__c[] prices;

        Test.setMock(HTTPCalloutMock.class, new CurrentFeedSuccessMock());

        stockFeedUpdateCurrent.fetchAndStore();
        prices = [select Id from Feed_Data__c];
        // System.assertEquals(1, prices.size(), 'There should be 1 stock price records after 1 calls');
    }


    public static testmethod void testFetchCurrentStockFeedSuccess() {
        Test.setMock(HTTPCalloutMock.class, new CurrentFeedSuccessMock());
        ocms_StockFeedUpdateCurrent stockFeedUpdateCurrent = new ocms_StockFeedUpdateCurrent();

        String response = stockFeedUpdateCurrent.fetchCurrentStockFeed();
        System.assertEquals(jsonResponse, response, 'fetchCurrentStockFeed should return the response body on success');
    }

    public static testmethod void testFetchCurrentSockFeedFailure() {
        Test.setMock(HTTPCalloutMock.class, new CurrentFeedFailureMock());
        ocms_StockFeedUpdateCurrent stockFeedUpdateCurrent = new ocms_StockFeedUpdateCurrent();

        try {
            stockFeedUpdateCurrent.fetchCurrentStockFeed();
        } catch (ocms_StockFeedUpdateCurrent.StockFeedException e) {
            return;
        }

        System.assert(false, 'Expected fetchCurrentStockFeed to throw a StockFeedException for non-ok responses');
    }

    public static testMethod void testParseCurrentJSONResponse() {
        ocms_StockFeedUpdateCurrent stockFeedUpdateCurrent = new ocms_StockFeedUpdateCurrent();
        Feed_Data__c[] parsedPrices = stockFeedUpdateCurrent.getCurrentStockFeed(jsonResponse);
        System.debug('pieces:' + parsedPrices.size());
        System.debug('current:' + parsedPrices[0].Current_Trade__c);
        System.assertEquals('MFC.TO', parsedPrices[0].Symbol__c, 'First price found should have symbol: MFC.TO');
        System.assertEquals('TSX', parsedPrices[0].Exchange__c, 'First price found should have exchange: TSX');
    }


    public class CurrentFeedSuccessMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            System.assertEquals('https://clientapi.gcs-web.com/data/1da609e5-d9c3-43e3-a585-046ee813a40b/quotes', req.getEndpoint());
            System.assertEquals('GET', req.getMethod(), 'HTTP request should use GET');

            // Fake success response
            HTTPResponse res = new HTTPResponse();
            res.setStatusCode(200);
            res.setHeader('Content-Type', 'application/json; charset=utf-8');
            res.setBody(jsonResponse);

            return res;
        }
    }

    public class CurrentFeedFailureMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Fake server error
            HTTPResponse res = new HTTPResponse();
            res.setStatusCode(500);

            return res;
        }
    }

    static String jsonResponse = '{"links":{"self":"https://clientapi.gcs-web.com/data/1da609e5-d9c3-43e3-a585-046ee813a40b/quotes"},"meta":{"executionDate":"2018-11-19T16:20:02","count":8},"data":[{"symbol":"MFC.TO","exchange":"TSX","exchangeShortCode":"TOR","lastTrade":21.77,"date":"2018-11-19T11:15:00","changeNumber":0.01,"changePercent":0.05,"bid":21.77,"bidSize":69,"askSize":37,"dayHigh":21.91,"dayLow":21.67,"volume":832302,"open":21.71,"previousClose":21.76,"52WeekHigh":27.77,"52WeekHighDate":"2018-01-15T00:00:00","52WeekLow":19.63,"52WeekLowDate":"2018-10-16T00:00:00","peRatio":14.91,"marketCap":43683630854.4,"sharesOutstanding":1984717440,"rollingEPS":1.45947,"isDefault":"true","isIndex":"false","class":"TOR","securityId":1060,"yield":4.6,"firstTradeDate":"1975-01-01T00:00:00"},{"symbol":"MFC.HK","exchange":"HKEX","exchangeShortCode":"HK","lastTrade":132.6,"date":"2018-11-19T02:54:56","changeNumber":0.289,"changePercent":0.22,"bid":132.6,"bidSize":800,"askSize":900,"dayHigh":133,"dayLow":132,"volume":2300,"open":132.3,"previousClose":132.311,"52WeekHigh":null,"52WeekHighDate":null,"52WeekLow":null,"52WeekLowDate":null,"peRatio":14.98,"marketCap":null,"sharesOutstanding":null,"rollingEPS":8.854,"isDefault":"false","isIndex":"false","class":"Common Stock","securityId":1057,"yield":4.514,"firstTradeDate":"1975-01-01T00:00:00"},{"symbol":"MFC.PS","exchange":"NYSE Arca","exchangeShortCode":"PSE","lastTrade":835,"date":"2018-11-16T02:30:00","changeNumber":0,"changePercent":0,"bid":830,"bidSize":50,"askSize":20,"dayHigh":835,"dayLow":835,"volume":0,"open":0,"previousClose":835,"52WeekHigh":1050,"52WeekHighDate":"2018-01-04T00:00:00","52WeekLow":770,"52WeekLowDate":"2018-10-12T00:00:00","peRatio":13.68,"marketCap":null,"sharesOutstanding":null,"rollingEPS":61.0356,"isDefault":"false","isIndex":"false","class":"Common Stock","securityId":1059,"yield":4.87,"firstTradeDate":"1975-01-01T00:00:00"},{"symbol":"MFC.PR.B","exchange":"TSX","exchangeShortCode":"TOR","lastTrade":20.12,"date":"2018-11-19T11:09:00","changeNumber":0,"changePercent":0,"bid":20.07,"bidSize":1,"askSize":11,"dayHigh":20.25,"dayLow":20.12,"volume":1705,"open":20.25,"previousClose":20.12,"52WeekHigh":23.21,"52WeekHighDate":"2017-11-30T00:00:00","52WeekLow":19.66,"52WeekLowDate":"2018-10-31T00:00:00","peRatio":0,"marketCap":null,"sharesOutstanding":null,"rollingEPS":0,"isDefault":"false","isIndex":"false","class":"Preferred Shares","securityId":1061,"yield":5.78,"firstTradeDate":"1975-01-01T00:00:00"},{"symbol":"MFC","exchange":"NYSE","exchangeShortCode":"NYSE","lastTrade":16.54,"date":"2018-11-19T11:15:00","changeNumber":0.0302,"changePercent":0.18,"bid":16.53,"bidSize":33,"askSize":45,"dayHigh":16.6,"dayLow":16.44,"volume":286119,"open":16.5,"previousClose":16.5098,"52WeekHigh":22.16,"52WeekHighDate":"2018-01-24T00:00:00","52WeekLow":14.99,"52WeekLowDate":"2018-10-29T00:00:00","peRatio":14.5972,"marketCap":33144781248,"sharesOutstanding":1984717440,"rollingEPS":1.131,"isDefault":"false","isIndex":"false","class":"NYSE","securityId":4296,"yield":4.6085,"firstTradeDate":"1975-01-01T00:00:00"},{"symbol":"NASDAQ","exchange":null,"exchangeShortCode":null,"lastTrade":7116.52,"date":"2018-11-19T16:16:26","changeNumber":-131.354,"changePercent":-1.81,"bid":null,"bidSize":null,"askSize":null,"dayHigh":7224.12,"dayLow":7098.58,"volume":163077100,"open":7217.24,"previousClose":7247.87,"52WeekHigh":8133.3,"52WeekHighDate":"2018-08-30T00:00:00","52WeekLow":6630.67,"52WeekLowDate":"2018-02-09T00:00:00","peRatio":null,"marketCap":null,"sharesOutstanding":null,"rollingEPS":null,"isDefault":"false","isIndex":"true","class":null,"securityId":1,"yield":null,"firstTradeDate":null},{"symbol":"OEX","exchange":null,"exchangeShortCode":null,"lastTrade":1201.55,"date":"2018-11-19T16:16:26","changeNumber":-12.18,"changePercent":-1,"bid":1201.36,"bidSize":null,"askSize":null,"dayHigh":1211.63,"dayLow":1200.06,"volume":null,"open":1210.98,"previousClose":1213.73,"52WeekHigh":1309.73,"52WeekHighDate":"2018-10-03T00:00:00","52WeekLow":1118.69,"52WeekLowDate":"2018-04-02T00:00:00","peRatio":null,"marketCap":null,"sharesOutstanding":null,"rollingEPS":null,"isDefault":"false","isIndex":"true","class":null,"securityId":2,"yield":null,"firstTradeDate":null},{"symbol":".SPX","exchange":null,"exchangeShortCode":null,"lastTrade":2709.16,"date":"2018-11-19T16:16:28","changeNumber":-27.11,"changePercent":-0.99,"bid":2708.58,"bidSize":null,"askSize":null,"dayHigh":2733.16,"dayLow":2705.76,"volume":null,"open":2730.74,"previousClose":2736.27,"52WeekHigh":2940.91,"52WeekHighDate":"2018-09-21T00:00:00","52WeekLow":2532.69,"52WeekLowDate":"2018-02-09T00:00:00","peRatio":null,"marketCap":null,"sharesOutstanding":null,"rollingEPS":null,"isDefault":"false","isIndex":"true","class":null,"securityId":6,"yield":null,"firstTradeDate":null}],"error":null}';


//  static String xmlResponse;
//
//  static {
//    xmlResponse = '';
//    xmlResponse += '<?xml version="1.0" standalone="no"?><IRXML CorpMasterID="73017"><StockQuotes PubDate="20150305" PubTime="21:20:54">';
//    xmlResponse += '  <Stock_Quote PrimaryTicker="Yes" DisplayInDropdown="Yes" SecurityID="17534" Company="Manulife Financial Corporation" Ticker="MFC.TO" DisplayTicker="MFC.TO" Exchange="TSX" Currency="Canadian Dollar" CurrencyLabel="Can$" CurrencyLabelSuffix="" Type="COMPANY" Class="TOR" FirstTradeDate="" FinancialStatusIndicator="">';
//    xmlResponse += '    <Date Date="20150305" Time="16:00:00">Mar  5 2015  4:00PM</Date>';
//    xmlResponse += '    <Trade>21.27</Trade>';
//    xmlResponse += '    <Change>-0.09</Change>';
//    xmlResponse += '    <Bid>21.27</Bid>';
//    xmlResponse += '    <Ask>21.31</Ask>';
//    xmlResponse += '    <BidSize>30200</BidSize>';
//    xmlResponse += '    <AskSize>19900</AskSize>';
//    xmlResponse += '    <High>21.60</High>';
//    xmlResponse += '    <Low>21.23</Low>';
//    xmlResponse += '    <Volume>3617079</Volume>';
//    xmlResponse += '    <Open>21.48</Open>';
//    xmlResponse += '    <PreviousClose>21.36</PreviousClose>';
//    xmlResponse += '    <FiftyTwoWeekHigh>23.09</FiftyTwoWeekHigh>';
//    xmlResponse += '    <FiftyTwoWeekHighDate Date="20141205" Time="00:00:00">Dec  5 2014 12:00AM</FiftyTwoWeekHighDate>';
//    xmlResponse += '    <FiftyTwoWeekLow>18.91</FiftyTwoWeekLow>';
//    xmlResponse += '    <FiftyTwoWeekLowDate Date="20141016" Time="00:00:00">Oct 16 2014 12:00AM</FiftyTwoWeekLowDate>';
//    xmlResponse += '    <PERatio>11.8167</PERatio>';
//    xmlResponse += '    <MarketCap>41899666650.00</MarketCap>';
//    xmlResponse += '    <SharesOutstanding>1969895000</SharesOutstanding>';
//    xmlResponse += '    <RollingEPS>1.80</RollingEPS>';
//    xmlResponse += '    <DataProviderInfo>';
//    xmlResponse += '      <DataProvider>';
//    xmlResponse += '        <Name>MarketWatch</Name>';
//    xmlResponse += '        <Key>CA:MFC</Key>';
//    xmlResponse += '      </DataProvider>';
//    xmlResponse += '    </DataProviderInfo>';
//    xmlResponse += '  </Stock_Quote>';
//    xmlResponse += '  <Stock_Quote PrimaryTicker="No" DisplayInDropdown="Yes" SecurityID="-27807" Company="Manulife Financial Corporation" Ticker="MFC.TO" DisplayTicker="CA:MFC.PRA" Exchange="TSX" Currency="Canadian Dollar" CurrencyLabel="Can$" CurrencyLabelSuffix="" Type="COMPANY" Class="Preferred Shares" FirstTradeDate="" FinancialStatusIndicator="">';
//    xmlResponse += '    <Date Date="20150305" Time="15:27:00">Mar  5 2015  3:27PM</Date>';
//    xmlResponse += '    <Trade>25.21</Trade>';
//    xmlResponse += '    <Change>-0.01</Change>';
//    xmlResponse += '    <Bid>25.18</Bid>';
//    xmlResponse += '    <Ask>25.22</Ask>';
//    xmlResponse += '    <BidSize>1700</BidSize>';
//    xmlResponse += '    <AskSize>1700</AskSize>';
//    xmlResponse += '    <High>25.22</High>';
//    xmlResponse += '    <Low>25.21</Low>';
//    xmlResponse += '    <Volume>951</Volume>';
//    xmlResponse += '    <Open>25.22</Open>';
//    xmlResponse += '    <PreviousClose>25.22</PreviousClose>';
//    xmlResponse += '    <FiftyTwoWeekHigh>26.09</FiftyTwoWeekHigh>';
//    xmlResponse += '    <FiftyTwoWeekHighDate Date="20140506" Time="00:00:00">May  6 2014 12:00AM</FiftyTwoWeekHighDate>';
//    xmlResponse += '    <FiftyTwoWeekLow>25.12</FiftyTwoWeekLow>';
//    xmlResponse += '    <FiftyTwoWeekLowDate Date="20150302" Time="00:00:00">Mar  2 2015 12:00AM</FiftyTwoWeekLowDate>';
//    xmlResponse += '    <PERatio>0</PERatio>';
//    xmlResponse += '    <MarketCap>352940000.00</MarketCap>';
//    xmlResponse += '    <SharesOutstanding>14000000</SharesOutstanding>';
//    xmlResponse += '    <RollingEPS>0.00</RollingEPS>';
//    xmlResponse += '    <DataProviderInfo>';
//    xmlResponse += '      <DataProvider>';
//    xmlResponse += '        <Name>MarketWatch</Name>';
//    xmlResponse += '        <Key>CA:MFCPRA</Key>';
//    xmlResponse += '      </DataProvider>';
//    xmlResponse += '    </DataProviderInfo>';
//    xmlResponse += '  </Stock_Quote>';
//    xmlResponse += '</StockQuotes></IRXML>';
//  }
}