/**
 * Definition and markup generation for Manulife.com Social Feed - Linkedin component (C105).
 *
 * @author  Saloni Mittal
 * @date    2015-Jun-18
 *
 */
global with sharing class ocms_mli_SocialFeedLinkedIn extends cms.ContentTemplateController {

    // Constructor for the execute request
    global ocms_mli_SocialFeedLinkedIn() {}

    // Constructor for the content editor VF page
    global ocms_mli_SocialFeedLinkedIn(cms.GenerateContent gc) {
        super(gc);
    }

    // Constructor for generator
    global ocms_mli_SocialFeedLinkedIn(cms.CreateContentController cc) {
        super(cc);
    }

    /**
     * @description  Used to check whether the component is added separately or in tabbed panel.
     */
    public String sTabCheck {
        get {
            return getProperty('sTabCheck');
        }
        set;
    }

    /**
     * @description  Used for Feed Area Tab sequence.
     */
    public String sFeedAreaTabId {
        get {
            return getProperty('sFeedAreaTabId');
        }
        set;
    }

    /**
     * @description  Used for Feed Area Title.
     */
    public String sFeedAreaTitle {
        get {
            return getProperty('sFeedAreaTitle');
        }
        set;
    }

    /**
     * @description  Used for Feed Area Accessible Text.
     */
    public String sAccessibleText {
        get {
            return getProperty('sAccessibleText');
        }
        set;
    }

    /**
     * @description  Used for Feed Area Content Image.
     */
    public String sFeedAreaImage {
        get {
            return getProperty('sFeedAreaImage');
        }
        set;
    }

    /**
     * @description  Used for Feed Area Content Image Alt Text.
     */
    public String sFeedAreaImageAltText {
        get {
            return getProperty('sFeedAreaImageAltText');
        }
        set;
    }

    /**
     * @description  Used for Feed Area Message.
     */
    public String sFeedAreaMessage {
        get {
            return getProperty('sFeedAreaMessage');
        }
        set;
    }

    /**
     * @description  Used for Feed Area Sign In Link Text.
     */
    public String sFeedAreaSignInLinkText {
        get { return getProperty('sFeedAreaSignInLinkText'); }
    }

    /**
     * @description  Used for Used for Feed Area Sign In Link
     */
    public String sFeedAreaSignInLink {
        get { return getProperty('sFeedAreaSignInLink'); }
    }

    private cms.Link objLink {
        get { return new cms.Link(sFeedAreaSignInLink); }
    }

    /**
     * @description  Used for Feed Area Follow Us Link Text.
     */
    public String sFeedAreaFollowLinkText {
        get { return getProperty('sFeedAreaFollowLinkText'); }
    }

    /**
     * @description  Used for Feed Area Follow Us Link.
     */
    public String sFeedAreaFollowLink {
        get { return getProperty('sFeedAreaFollowLink'); }
    }

    private cms.Link objLink1 {
        get { return new cms.Link(sFeedAreaFollowLink); }
    }

    /**
     * @description  Used for Feed Area Supplier Text.
     */
    public String sFeedAreaSupplierText {
        get {
            return getProperty('sFeedAreaSupplierText');
        }
        set;
    }

    /**
     * @description  Generates mark-up for social feeds linkedin content.
     * @return  String  A string of mark-up used to generate the content.
     */
    global override String getHTML() {

        String sHTML = '';

        // we don't want to bleed potential vector of attack info, so we only output our debug in prev mode
        sHTML += '<!-- >>> ocms_mli_SocialFeedLinkedIn.getHTML(...) -->'; //  `>>>` - entering comment, `===` execution comment, `<<<` exiting comment, to fix any jQuery parsing issue and it's a good design pattern, see: https://pl5.projectlocker.com/Stantive/PSTools/trac/wiki/gotcha/OCMSCachingMissingMarkup


        if(this.sTabCheck == 'true') {
            sHTML += '<div role="tabpanel" id="socialFeedsTab' + this.sFeedAreaTabId + '" class="socialMediaTab tabSection sectionLinkedin hidden';
            if (this.sFeedAreaTabId == '1') {
                sHTML += ' is-active';
            }
            sHTML += '">'
                                  +      '<div class="tabContent">';
        } else {
            sHTML += '<div class="socialFeeds">'
                                  +     '<div class="sectionLinkedin">';
        }
        if (this.sFeedAreaTitle != null) {
            sHTML +=         '<div class="feedAreaHeader">'
                                  +             '<h3 class="feedAreaTitle">'
                                  +                 '<span class="accessible">' + this.sAccessibleText + ': </span>'
                                  +                 this.sFeedAreaTitle
                                  +             '</h3>'
                                  +          '</div>';
        }
        sHTML +=         '<div class="feedAreaContent">';
        if (this.sFeedAreaImage != null) {
            sHTML +=         '<p><img src="' + this.sFeedAreaImage + '" alt="' + ((this.sFeedAreaImageAltText != null) ? this.sFeedAreaImageAltText : '') + '"/></p>';
        }
        if (this.sFeedAreaMessage != null) {
            sHTML +=         '<div class="message">' + this.sFeedAreaMessage + '</div>';
        }
        if (this.sFeedAreaSignInLinkText != null && objLink.targetPage != null) {
            sHTML +=         '<p class="action">'
                                  +             '<a onclick=\'' + ocms_mli_Utility.getLinkScript(objLink.javascript) + '\' href="'
                                  +             ocms_mli_Utility.getLinkHref(objLink.targetPage) + '" target="' + ocms_mli_Utility.getLinkTarget(objLink.target) + '">'
                                  +             this.sFeedAreaSignInLinkText +'</a>'
                                  +         '</p>';
        }
        if (this.sFeedAreaFollowLinkText != null && objLink1.targetPage != null) {
            sHTML +=         '<p class="action">'
                                  +            '<a onclick=\'' + ocms_mli_Utility.getLinkScript(objLink1.javascript) + '\' href="'
                                  +             ocms_mli_Utility.getLinkHref(objLink1.targetPage) + '" target="' + ocms_mli_Utility.getLinkTarget(objLink1.target) + '">'
                                  +             this.sFeedAreaFollowLinkText +'</a>'
                                  +          '</p>';
        }
        if (this.sFeedAreaSupplierText != null) {
            sHTML +=         '<div class="supplier">' + this.sFeedAreaSupplierText + '</div>';
        }
        sHTML +=         '</div>'
                              +     '</div>'
                              + '</div>';


        // we don't want to bleed potential vector of attack info, so we only output our debug in prev mode
        sHTML += '<!-- <<< ocms_mli_SocialFeedLinkedIn.getHTML(...) -->\n'; //  to fix any jQuery parsing issue and it's a good design pattern, see: https://pl5.projectlocker.com/Stantive/PSTools/trac/wiki/gotcha/OCMSCachingMissingMarkup

        return sHTML;
    }
}