global virtual with sharing class ocms_StockFeed extends cms.ContentTemplateController {
	global ocms_StockFeed() { }

	global ocms_StockFeed(cms.CreateContentController cc) {
		super(cc);
	}

	global ocms_StockFeed(cms.GenerateContent gc) {
		super(gc);
	}

	global virtual override String getHTML() { return ''; }

	public static final String CURRENT_RECORD_TYPE_NAME = 'Stock Price Current';
	public static final String DEFAULT_STOCK_COUNTRY = 'Canada';

	public class StockFeed {
		public String directionClass {get; set;}
		public Decimal currentPrice {get; set;}
		public Decimal percent {get; set;}
		public Decimal currentChange {get; set;}
		public DateTime asOf {get; set;}
		public String currencyLabel {get; set;}
		public String currencySymbol {get; set;}
		public String exchange {get; set;}
		public String symbol {get; set;}

		public StockFeed (Feed_Data__c stockPrice) {
			if (stockPrice.Current_Change__c == 0) {
				this.directionClass = 'ev';
			} else if (stockPrice.Current_Change__c > 0) {
				this.directionClass = 'up';
			} else {
				this.directionClass = 'dn';
			}

			this.percent = (stockPrice.Current_Trade__c / (stockPrice.Current_Trade__c - stockPrice.Current_Change__c) - 1) * 100;
			this.percent = percent.setScale(2, RoundingMode.HALF_UP);

			this.currentPrice = stockPrice.Current_Trade__c;
			this.currentChange = stockPrice.Current_Change__c;
			this.asOf = stockPrice.LastModifiedDate;
		}
	}

	/**
	 * @description Gets the stock widget markup based on the logged in users country.
	 * @return String The full markup for the Stock Widget.
	 */
    public String getMFCStockWidget() {
    	User currentUser = getCurrentUserInformation();
    	String widgetHtml = '';

    	StockFeed stock = getStockFeed('MFC', currentUser.MFC_Country__c);

    	if (stock != null) {
	        widgetHtml = '<div class="widget stocks-widget">' +
	        	'<div class="inner">' +
	        		'<h3>' + this.title + '</h3>' +
	        		'<div class="widget-content">' +
	        			'<div class="v-align">' +
	        				'<div class="inner">' +
	        					'<div class="t">' +
	        						'<span><sup>' + stock.currencySymbol + '</sup>' + stock.currentPrice + '<sub>' + stock.currencyLabel + '</sub></span>' +
	        					'</div>' +
	        					'<div class="b">' +
	        						'<span class="dir ' + stock.directionClass + '"></span> ' + stock.currentChange + ' ' + stock.percent + '%' +
	        					'</div>' +
	        				'</div>' +
	        			'</div>' +
	        		'</div>' +

	        		'<footer class="widget-footer">' +
	        			this.timeText + '<span id = "widget-stocks-time"> ' + stock.asOf.format('h:mm a') + '</span>' +
	        		'</footer>' +
	        	'</div>' +
	        '</div>';
    	}

        return widgetHtml;
    }

    /**
     * @description Get a StockFeed object based on the siteName and given country.  The code will attempt to read a custom setting called Stock_Market_Location__c
     *              to retrieve information about the desired market for the given country.  If we cannot find a Stock_Market_Location__c record for the given information
     *              it will attempt to find the default information found at the DEFAULT_STOCK_COUNTRY variable.  This will then create a StockFeed object which resolves
     *              the retrieved information into useful stock information.
     * @param  siteName The name of the site that you are getting the information for. Use acronyms such as MFC or MLI.  This is based on the site in the Stock_Market__c
     *                  object.
     * @param  country  The country in which you want to retrived the stock information for.
     * @return          StockFeed A StockFeed object with relavant stock information.
     */
	public StockFeed getStockFeed(String siteName, String country) {
		List<Stock_Market_Location__c> stockMarket = Database.query('SELECT Symbol__c, Exchange__c, Currency_Label__c, Currency_Symbol__c FROM Stock_Market_Location__c WHERE Site__c = :siteName AND Country__c = :country LIMIT 1');

		if (stockMarket.isEmpty()) {
			stockMarket = Database.query('SELECT Symbol__c, Exchange__c, Currency_Label__c, Currency_Symbol__c FROM Stock_Market_Location__c WHERE Site__c = :siteName AND Country__c = :DEFAULT_STOCK_COUNTRY LIMIT 1');
		}

		String stockMarketSymbol = stockMarket[0].Symbol__c;
		String stockMarketExchange = stockMarket[0].Exchange__c;
		String recordTypeId = getCurrentStockPriceRecordTypeId();

		List<Feed_Data__c> stockPrices = Database.query('SELECT Id, Current_Change__c, Current_Trade__c, LastModifiedDate FROM Feed_Data__c WHERE RecordType.Id = :recordTypeId AND Exchange__c = :stockMarketExchange AND Symbol__c = :stockMarketSymbol LIMIT 1');

		StockFeed stock = null;

		if (!stockPrices.isEmpty()) {
			stock = new StockFeed(stockPrices[0]);

			stock.currencyLabel = stockMarket[0].Currency_Label__c;
			stock.currencySymbol = stockMarket[0].Currency_Symbol__c;
		}

		return stock;
	}

	public List<StockFeed> getMLIStockFeed(String siteName) {

		List<StockFeed> stockList = new List<StockFeed>();
		List<Stock_Market_Location__c> locationList = Database.query('SELECT Symbol__c, Exchange__c, Currency_Label__c, Currency_Symbol__c FROM Stock_Market_Location__c WHERE Site__c = :siteName');
		String recordTypeId = getCurrentStockPriceRecordTypeId();

		if (!locationList.isEmpty()) {

			for (Stock_Market_Location__c location : locationList){

				String stockMarketSymbol = location.Symbol__c;
				String stockMarketExchange = location.Exchange__c;

				List<Feed_Data__c> stockPrices = Database.query('SELECT Id, Current_Change__c, Current_Trade__c, LastModifiedDate FROM Feed_Data__c WHERE RecordType.Id = :recordTypeId AND Exchange__c = :stockMarketExchange AND Symbol__c = :stockMarketSymbol LIMIT 1');

				StockFeed stock = null;

				if (!stockPrices.isEmpty()) {

					stock = new StockFeed(stockPrices[0]);
					stock.currencyLabel = location.Currency_Label__c;
					stock.currencySymbol = location.Currency_Symbol__c;
					stock.symbol = stockMarketSymbol;
					stock.exchange = stockMarketExchange;
					stockList.add(stock);

				}
			}
		}

		return stockList;

	}

	/**
	 * @description Gets the record type Id for the current stock type.
	 * @return The ID of the record type ID for the current stock type
	 */
	private String getCurrentStockPriceRecordTypeId() {
		RecordType rt = Database.query('SELECT Id FROM RecordType WHERE SObjectType = \'Feed_Data__c\' AND Name = :CURRENT_RECORD_TYPE_NAME LIMIT 1');

		return rt.Id;
	}

	/**
	 * @description Gets the current logged in users information
	 *
	 * @return The user object of the user logged in
	 */
	private User getCurrentUserInformation() {
		String userId = UserInfo.getUserId();

		return Database.query('SELECT MFC_Country__c FROM User WHERE Id = :userId LIMIT 1');
	}

	/** MFC Attributes */

	/**
	 * @description attribute title - required
	 */
	public String title {
	    get {
	        return getProperty('title');
	    }
	    set;
	}

	/**
	 * @description attribute timeText - required
	 */
	public String timeText {
	    get {
	        return getProperty('timeText');
	    }
	    set;
	}

	/** MLI Attributes */
}