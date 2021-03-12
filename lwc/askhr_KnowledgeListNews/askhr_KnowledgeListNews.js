import { LightningElement, wire } from 'lwc';

/*
 ASKHR_KnowledgeListController.getKnowledgeNewsArticlesForNewsPage() Apex method 
*/
import getKnowledgeNewsArticlesForNewsPage from '@salesforce/apex/ASKHR_KnowledgeListController.getKnowledgeNewsArticlesForNewsPage';


import userLanguage from '@salesforce/i18n/lang';
export default class Askhr_KnowledgeListNews extends LightningElement {
    listKnowledgeNewsArticles;

    @wire(getKnowledgeNewsArticlesForNewsPage, {langCode :userLanguage})
    loadNewsList(result) {
        //console.log('Result: ' + JSON.stringify(result));
        if (result.error) {
            // do error handling, please
        } else if (result.data) {
            this.listKnowledgeNewsArticles = result.data.map((knowledgeNewsArticle, index) => {
                console.log('Knowledge News Article: ' + JSON.stringify(knowledgeNewsArticle));
                return {
                    record: knowledgeNewsArticle,
                    url: 'article/'.concat(knowledgeNewsArticle.UrlName)
                }
            })
        }
    }
    
	connectedCallback() {
        console.log('calling getKnowledgeNewsArticlesForNewsPage');
		getKnowledgeNewsArticlesForNewsPage({langCode : this.userLanguage});
	}
}