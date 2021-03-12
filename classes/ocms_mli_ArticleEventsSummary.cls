global with sharing class ocms_mli_ArticleEventsSummary extends ocms_mli_Article {
	global override String getHtml() {
		return this.getArticleEventsSummaryHTML();
	}
}