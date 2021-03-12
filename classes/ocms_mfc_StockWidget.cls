global with sharing class ocms_mfc_StockWidget extends ocms_StockFeed {
	global override String getHTML() {
		return this.getMFCStockWidget();
	}
}