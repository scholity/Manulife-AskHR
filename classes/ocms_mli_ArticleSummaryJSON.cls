/* IMHO - this is a poor design pattern but this is the established approach for the Article 'Content Layout'. */
global with sharing class ocms_mli_ArticleSummaryJSON extends ocms_mli_Article {
    global override String getHtml() {
        return this.getArticleSummaryJSON();
    }
}