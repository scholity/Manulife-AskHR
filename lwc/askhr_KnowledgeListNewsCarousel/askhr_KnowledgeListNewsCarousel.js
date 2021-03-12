import { LightningElement, wire } from 'lwc';

/*
 ASKHR_KnowledgeListController.getKnowledgeNewsArticlesForCarousel() Apex method 
*/
import getKnowledgeNewsArticlesForCarousel from '@salesforce/apex/ASKHR_KnowledgeListController.getKnowledgeNewsArticlesForCarousel';


/*
 ASKHR_KnowledgeListController.getNewsCarouselSettings() Apex method 
*/
import getNewsCarouselSettings from '@salesforce/apex/ASKHR_KnowledgeListController.getNewsCarouselSettings';

import userLanguage from '@salesforce/i18n/lang';
export default class Askhr_KnowledgeListNewsCarousel extends LightningElement {
    // Carousel scroll duration default to 5 seconds;
    scrollDuration = 5;

    listKnowledgeNewsArticles;
    // Set to true if there are records to show in carousel
    showCarousel = false;

    
    @wire(getNewsCarouselSettings)
    loadSettings(result) {
        if (result.error) {
            // do error handling, please
        } else if (result.data) {
            if (result.data != null) {
                console.log("Scroll Duration: " + result.data.Scroll_Duration__c);
                this.scrollDuration = result.data.Scroll_Duration__c;
            }
        }
    }

    @wire(getKnowledgeNewsArticlesForCarousel, {langCode :userLanguage})
    loadNewsList(result) {
        console.log('Result: ' + JSON.stringify(result));
        if (result.error) {
            // do error handling, please
        } else if (result.data) {
            if (result.data.length > 0) {
                this.showCarousel = true;
                this.listKnowledgeNewsArticles = result.data.map((knowledgeNewsArticle, index) => {
                    console.log('Knowledge Article Image: ' + knowledgeNewsArticle.Image__c);

                    // Get the src attribute from the img tag in field Image__c
                    var url = '';
                    if (knowledgeNewsArticle.Image__c != null) {
                        // split the string with before src=" and string after it
                        const srcValue = knowledgeNewsArticle.Image__c.split('src="');
                        if (srcValue.length > 1) {
                            url = srcValue[1].split('"')[0];
                            console.log('Knowledge Article Image src: ' + url);
                            // replace all occurances of &amp; with &
                            url = url.replace(/&amp;/g, '&');
                        }
                    }
                    console.log('Knowledge Article Image src: ' + url);
                    return {
                        record: knowledgeNewsArticle,

                        url: url,
                        articlUrl: 'article/'.concat(knowledgeNewsArticle.UrlName)
                    }
                });
            }
        }
    }
    
	connectedCallback() {
        getNewsCarouselSettings();
        console.log('calling getKnowledgeNewsArticlesForCarousel');
		getKnowledgeNewsArticlesForCarousel({langCode : this.userLanguage});
	}
}