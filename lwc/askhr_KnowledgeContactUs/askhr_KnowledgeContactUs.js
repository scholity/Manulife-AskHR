import { LightningElement, wire, track } from 'lwc';

/*
 ASKHR_KnowledgeListController.getKnowledgeContactUsArticle() Apex method 
*/
import getKnowledgeContactUsArticle from '@salesforce/apex/ASKHR_KnowledgeListController.getKnowledgeContactUsArticle';

/*
 ASKHR_KnowledgeListController.getKnowledgeGlobalContactUsArticle() Apex method 
*/
import getKnowledgeGlobalContactUsArticle from '@salesforce/apex/ASKHR_KnowledgeListController.getKnowledgeGlobalContactUsArticle';

import userLanguage from '@salesforce/i18n/lang';

import askhr_contactus_image_static_resource from '@salesforce/resourceUrl/ASKHR_ContactUs_Image';

// 08/16/2020 Custom Labels
import closeLabel from '@salesforce/label/c.AskHR_Close';
import globalContactListLabel from '@salesforce/label/c.AskHR_Global_Contact_List';

export default class Askhr_KnowledgeContactUs extends LightningElement {
    knowledgeContacttUsArticle;
    imageURL;
    knowledgeGlobalContacttUsArticle;
    @track showGlobalContactUs = false;

    askhr_contactus_image = askhr_contactus_image_static_resource;

    // 08/16/2020 variable to use Custom Labels in html
    label = {
        closeLabel,
        globalContactListLabel
    }

    @wire(getKnowledgeContactUsArticle, {langCode : userLanguage})    
    loadContactUs(result) {
        console.log('Result: ' + JSON.stringify(result));
        if (result.error) {
            // do error handling, please
        } else if (result.data) {
            if (result.data != null) {
                this.knowledgeContacttUsArticle = result.data;
                
                console.log('Knowledge Article Image: ' + this.knowledgeContacttUsArticle.Image__c);

                // Get the src attribute from the img tag in field Image__c
                var url = '';
                if (this.knowledgeContacttUsArticle.Image__c != null) {
                    // split the string with before src=" and string after it
                    const srcValue = this.knowledgeContacttUsArticle.Image__c.split('src="');
                    if (srcValue.length > 1) {
                        url = srcValue[1].split('"')[0];
                        console.log('Knowledge Article Image src: ' + url);
                        // replace all occurances of &amp; with &
                        url = url.replace(/&amp;/g, '&');
                    }
                }
                console.log('Knowledge Article Image src: ' + url);
                this.imageURL = url;
            }
        }
    }
    
    @wire(getKnowledgeGlobalContactUsArticle, {langCode : userLanguage})    
    knowledgeGlobalContacttUsArticle;
    
	connectedCallback() {
        console.log('calling getKnowledgeContactUsArticle');
		getKnowledgeContactUsArticle({langCode : this.userLanguage});
    }
    
    openGlobalContacts() {
        // show the Global Contact Us
        this.showGlobalContactUs = true;
    }
    closeGlobalContacts() {
        // close the Global Contact Us
        this.showGlobalContactUs = false;
    }
}