global with sharing class ocms_mfc_NewsTile extends ocms_mfc_Article {
	global override String getHtml() {
		return this.getNewsTileHTML();
	}
}