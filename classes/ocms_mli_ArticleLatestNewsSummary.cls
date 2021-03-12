global with sharing class ocms_mli_ArticleLatestNewsSummary extends ocms_mli_Article {
	global override String getHtml() {
		return this.getArticleLatestNewsSummaryHTML();
	}
}