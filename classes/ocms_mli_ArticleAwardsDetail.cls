global with sharing class ocms_mli_ArticleAwardsDetail extends ocms_mli_Article {
	global override String getHtml() {
		return this.getArticleAwardDetailHTML();
	}
}