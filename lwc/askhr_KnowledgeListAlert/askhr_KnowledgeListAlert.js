import { LightningElement, wire } from 'lwc';

/*
 ASKHR_KnowledgeListController.getKnowledgeAlertArticles() Apex method 
*/
import getKnowledgeAlertArticles from '@salesforce/apex/ASKHR_KnowledgeListController.getKnowledgeAlertArticles';
import userLanguage from '@salesforce/i18n/lang';

export default class Askhr_KnowledgeListAlert extends LightningElement {
    listKnowledgeAlertArticles;

    @wire(getKnowledgeAlertArticles, {langCode : userLanguage})
    listKnowledgeAlertArticles;
}