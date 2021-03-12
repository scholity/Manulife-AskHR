global with sharing class ocms_mfc_Tile extends ocms_mfc_Article {
	global override String getHtml() {
		return this.getArticleSummaryHTML();
	}
}