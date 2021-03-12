global with sharing class ocms_mli_ArticleNews extends ocms_mli_Article {
	global override String getHtml() {
		return this.getNewsArticleDetailHTML();
	}
}