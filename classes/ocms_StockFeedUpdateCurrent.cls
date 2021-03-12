public with sharing class ocms_StockFeedUpdateCurrent {
    //public static final String feedEndpointXML;
    public static final String feedEndpointJSON;
    public static final String recordTypeId;
    public static Map<String, String> mInstrumentMap;
    public static Map<String, String> mExchangetMap;

    static {
        //feedEndpointXML = 'https://xml.corporate-ir.net/irxmlclient.asp?compid=73017&reqtype=quotes';
        feedEndpointJSON = 'https://clientapi.gcs-web.com/data/1da609e5-d9c3-43e3-a585-046ee813a40b/quotes';
        recordTypeId = Schema.SObjectType.Feed_Data__c.getRecordTypeInfosByName().get('Stock Price Current').getRecordTypeId();
    }

    public ocms_StockFeedUpdateCurrent() {
    }

    public class StockFeedException extends Exception {
    }

    public void fetchAndStore() {
        try {
            String jsonResponse = fetchCurrentStockFeed();

            Feed_Data__c[] newPrices = getCurrentStockFeed(jsonResponse);
            Feed_Data__c[] oldPrices = [select Id from Feed_Data__c where RecordTypeId = :recordTypeId];

            delete oldPrices;
            insert newPrices;
        } catch (NullPointerException e) {
            if (!Test.isRunningTest()) {
                e.setMessage('We could not determine the error. It is possible that Salesforce IPs are not whitelisted by Nasdaq.');
                notifyErrorMessage(e);
            }
        } catch (Exception e) {
            if (!Test.isRunningTest()) {
                notifyErrorMessage(e);
            }
        }
    }

    public void ThrowException() {
        this.notifyErrorMessage(new StockFeedException());
    }

    private void notifyErrorMessage(Exception ex) {
        String groupName = '';

        try {
            Stock_Feed_Settings__c settings = [select Notify_Group__c from Stock_Feed_Settings__c limit 1];

            groupName = settings.Notify_Group__c;
        } catch (QueryException e) {
            throw new StockFeedException('No Stock_Feed_Settings instance was found when attempting to notify of a feed error.');
        }

        Group g;
        try {
            g = [select (select UserOrGroupId from GroupMembers) from Group where DeveloperName = :groupName];
        } catch (QueryException e) {
            throw new StockFeedException('Could not find the public group ' + groupName + ' when attempting to notify of a feed error.');
        }

        List<String> userIds = new List<String>();
        List<String> addresses = new List<String>();

        for (GroupMember gm : g.GroupMembers) {
            userIds.add(gm.UserOrGroupId);
        }

        User[] users = [select Email from User where Id in :userIds];

        for (User u : users) {
            addresses.add(u.Email);
        }

        //mmcg 2018-01-14:  Adding more information to the auto email to help us debug a persistent issue reading the NASDAQ feed.
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(addresses);
        mail.setSubject('MFCentral Stock Feed Update Failed');
        string body = '<p><strong>Line Number:</strong> ' + ex.getLineNumber() + '</p>';
        body += '<p><strong>Type:</strong> ' + ex.getTypeName() + '</p>';
        body += '<p><strong>Message:</strong> ' + ex.getMessage() + '</p>';
        body += '<p><strong>Stack trace:</strong> ' + ex.getStackTraceString() + '</p>';
        mail.setHtmlBody(body);

        Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.Email[]{
                mail
        }, false);

        for (Messaging.SendEmailResult result : results) {
            if (!result.isSuccess()) {
                System.debug(result.getErrors()[0].getMessage());
            }
        }
    }

    public String fetchCurrentStockFeed() {
        Http httpProtocol = new Http();

        // Create HTTP request to send.
        HttpRequest request = new HttpRequest();

        // Set the endpoint URL.
        String endpoint = feedEndpointJSON;

        request.setEndPoint(endpoint);

        // Set the HTTP verb to GET.
        request.setMethod('GET');

        // The response is in JSON format.
        HttpResponse response = httpProtocol.send(request);

        if (response.getStatusCode() != 200) {
            throw new StockFeedException('Fetching current feed failed with code ' + response.getStatusCode() + ': ' + response.getStatus());
        }

        return response.getBody();
    }


    /**
     * This method gets and parses the JSON response from NASDAQ
     *
     * @return array of interested symbol/exchange/price/change combinations
     */
    public Feed_Data__c[] getCurrentStockFeed(String JSONresponse) {
        Feed_Data__c[] prices = new Feed_Data__c[]{
        };

        // Parse JSON response to get all the totalPrice field values.
        JSONParser parser = JSON.createParser(JSONresponse);

        String symbol, exchange;
        Decimal lastTrade, change;
        Boolean shouldSave = false;

        while (parser.nextToken() != null) {
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME)) {
                //symbol
                if (parser.getText() == 'symbol') {
                    parser.nextToken();
                    symbol = parser.getText();
                    continue;
                }
                //exchange
                if (parser.getText() == 'exchange') {
                    parser.nextToken();
                    exchange = parser.getText();

                    if (exchange.equals('TSX') || exchange.equals('NYSE') || exchange.equals('HKEX')
                            || exchange.equals('NYSE Arca')) {
                        shouldSave = true;
                    } else {
                        shouldSave = false;
                    }
                    continue;
                }
                //last
                if (parser.getText() == 'lastTrade') {
                    parser.nextToken();
                    if (shouldSave)
                        lastTrade = parser.getDecimalValue().setScale(2, RoundingMode.HALF_UP); //keep 2 digits, round with half up
                    continue;
                }
                //change number
                if (parser.getText() == 'changeNumber') {
                    parser.nextToken();
                    if (shouldSave)
                        change = parser.getDecimalValue().setScale(2, RoundingMode.HALF_UP);
                    continue;
                }

                // Give this is the last useful info we need, we save here
                if (parser.getText() == 'isIndex') {
                    parser.nextToken();
                    Boolean isIndex = (parser.getText() == 'true'); // use "==" here to ignore case
                    shouldSave = shouldSave && !isIndex; // we don't want index
                    if (shouldSave) {
                        prices.add(new Feed_Data__c(
                                Symbol__c = symbol,
                                Exchange__c = exchange,
                                Current_Trade__c = lastTrade,
                                Current_Change__c = change,
                                RecordTypeId = recordTypeId
                        ));
                    }
                }
            }
        }
        return prices;
    }
}