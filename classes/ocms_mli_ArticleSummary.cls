global with sharing class ocms_mli_ArticleSummary extends ocms_mli_Article {
	global override String getHtml() {
		return this.getArticleSummaryHTML();
	}
}