global with sharing class ocms_mfc_ArticleDetail extends ocms_mfc_Article {
	global override String getHtml() {
		return this.getArticleDetailHTML();
	}
}