/**
* Created by joe zhong on 2018-08-24.
* Class to handle the server side rendering of BrandHub Widget
*/

global with sharing virtual class ocms_mfc_BrandHubWidget Extends ocms_ps_Content {
    global ocms_mfc_BrandHubWidget(cms.CreateContentController cc) {
        super(cc);
    }
    
    global ocms_mfc_BrandHubWidget(cms.GenerateContent gs) {
        super(gs);
    }
    
    global ocms_mfc_BrandHubWidget(){
    }
    
    public String title{
        get{
            return getProperty('title');
        }
        set;
    }
    public String hubImage{
        get{
            return getProperty('hubImage');
        }
        set;
    }
    
    public String hubLink{
        get{
            return getProperty('hubLink');
        }
        set;
    }
    
    public String hubHoverText{
        get{
            return getProperty('hubHoverText');
        }
        set;
    }
    
    global override String getHTML(){
        String html =
            '<div class="widget brandhub-widget">' +
            '<div class="inner">' +
            '<h3>' + this.title + '</h3>' +
            '<div class="widget-content">' +
            '<a href="' + this.hubLink +'"><img class="brandhubImage" src="' + this.hubImage + '" Title= "'+ this.hubHoverText +'">' +
            '</a>' +
            '</div>' +
            '</div>' +
            '</div>';
        
        return html;
    }
    
}