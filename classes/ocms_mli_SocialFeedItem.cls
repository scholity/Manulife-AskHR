global with sharing class ocms_mli_SocialFeedItem extends cms.ContentTemplateController {

    global ocms_mli_SocialFeedItem() {}

    global ocms_mli_SocialFeedItem(cms.GenerateContent gc) {
        super(gc);
    }

    global ocms_mli_SocialFeedItem(cms.CreateContentController cc) {
        super(cc);
    }

    public String strSocialMedia {
        get { return ocms_mli_Utility.noNull(getProperty('strSocialMedia')); }
    }

    public String strLink {
        get { return getProperty('strLink'); }
    }

    private cms.Link objLink {
        get { return new cms.Link(strLink); }
    }

    public String accLinkTitle {
        get { return ocms_mli_Utility.noNull(getProperty('accLinkTitle')); }
    }

    public String accDescription {
        get { return ocms_mli_Utility.noNull(getProperty('accDescription')); }
    }

    private String analyticsClass {
        get {
            String rtrnVal = '';

            if (strSocialMedia == 'facebook'){
                rtrnVal = 'analyticsFacebook';
            } else if (strSocialMedia == 'instagram'){
                rtrnVal = 'analyticsInstagram';
            } else if (strSocialMedia == 'twitter'){
                rtrnVal = 'analyticsTwitter';
            } else if (strSocialMedia == 'linkedin'){
                rtrnVal = 'analyticsLinkedIn';
            } else if (strSocialMedia == 'youtube'){
                rtrnVal = 'analyticsYouTube';
            }

            return rtrnVal;
        }
    }

    global override String getHTML() {
        return '<li>' +
                    '<a class="' + analyticsClass + '" onclick=\'' + ocms_mli_Utility.getLinkScript(objLink.javascript) + '\' href="' + ocms_mli_Utility.getLinkHref(objLink.targetPage) + '" target="' + ocms_mli_Utility.getLinkTarget(objLink.target) + '" title="' + accLinkTitle + '">' +
                        '<span class="icon icon-' + strSocialMedia + '"></span>' +
                        '<span class="accessible">' + accDescription + '</span>' +
                    '</a>' +
                '</li>';
    }

}