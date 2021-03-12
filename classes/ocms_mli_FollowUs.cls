/**
 * Definition and markup generation for Manulife.com follow us icons (C102).
 *
 * @author  Saloni Mittal
 * @date    2015-Jul-07
 *
 */
global with sharing class ocms_mli_FollowUs extends cms.ContentTemplateController{

    // Constructor for the execute request
    global ocms_mli_FollowUs() {}

    // Constructor for the content editor VF page
    global ocms_mli_FollowUs(cms.GenerateContent gc) {
        super(gc);
    }

    // Constructor for generator
    global ocms_mli_FollowUs(cms.CreateContentController cc) {
        super(cc);
    }

    /**
     * @description  Used for follow subtitle.
     */
    public String sFollowLabel {
        get { return getProperty('sFollowLabel'); }
    }

    /**
     * @description  Used for Follow label accessible text only for mobile.
     */
    public String sFollowAccessible {
        get { return getProperty('sFollowAccessible'); }
    }

    /**
     * @description  Used for accessible text
     */
    public String sAccessibleText {
        get { return getProperty('sAccessibleText'); }
    }

    /**
     * @description  Used for link title.
     */
    public String sLinkTitle {
        get { return getProperty('sLinkTitle'); }
    }

    /**
     * @description  Used for Facebook label.
     */
    public String sFBLabel {
        get { return getProperty('sFBLabel'); }
    }

    /**
     * @description  Used for facebook follow link.
     */
    public String sFBFollowLink {
        get { return getProperty('sFBFollowLink'); }
    }

    private cms.Link FBLink {
        get { return new cms.Link(sFBFollowLink); }
    }

    /**
     * @description  Used for Twitter label.
     */
    public String sTwitterLabel {
        get { return getProperty('sTwitterLabel'); }
    }

    /**
     * @description  Used for twitter follow link.
     */
    public String sTwitterFollowLink {
        get { return getProperty('sTwitterFollowLink'); }
    }

    private cms.Link twitterLink {
        get { return new cms.Link(sTwitterFollowLink); }
    }

    /**
     * @description  Used for Instagram label.
     */
    public String sInstagramLabel {
        get { return getProperty('sInstagramLabel'); }
    }

    /**
     * @description  Used for instagram follow link.
     */
    public String sInstagramFollowLink {
        get { return getProperty('sInstagramFollowLink'); }
    }

    private cms.Link instagramLink {
        get { return new cms.Link(sInstagramFollowLink); }
    }

    /**
     * @description  Used for LinkedIn label.
     */
    public String sLinkedInLabel {
        get { return getProperty('sLinkedInLabel'); }
    }

    /**
     * @description  Used for linkedIn follow link.
     */
    public String sLinkedInFollowLink {
        get { return getProperty('sLinkedInFollowLink'); }
    }

    private cms.Link linkedInLink {
        get { return new cms.Link(sLinkedInFollowLink); }
    }

    /**
     * @description  Used for Youtube label.
     */
    public String sYoutubeLabel {
        get { return getProperty('sYoutubeLabel'); }
    }

    /**
     * @description  Used for youtube follow link.
     */
    public String sYoutubeFollowLink {
        get { return getProperty('sYoutubeFollowLink'); }
    }

    private cms.Link youtubeLink {
        get { return new cms.Link(sYoutubeFollowLink); }
    }

    /**
     * @description  Used for RSS feed label.
     */
    public String sRssLabel {
        get { return getProperty('sRssLabel'); }
    }

    /**
     * @description  Used for RSS feed follow link.
     */
    public String sRssFollowLink {
        get { return getProperty('sRssFollowLink'); }
    }

    private cms.Link rssLink {
        get { return new cms.Link(sRssFollowLink); }
    }

    /**
     * @description  Used for other accessible text for other links.
     */
    public String sAccessibleOther {
        get { return getProperty('sAccessibleOther'); }
    }

    /**
     * @description  Used for other social media label.
     */
    public String sOtherSocialLabel {
        get { return getProperty('sOtherSocialLabel'); }
    }

    /**
     * @description  Used for other social media link.
     */
    public String sOtherSocialLink {
        get { return getProperty('sOtherSocialLink'); }
    }

    private cms.Link otherLink {
        get { return new cms.Link(sOtherSocialLink); }
    }


    /**
     * @description  Generates mark-up for follow us.
     * @return  String  A string of mark-up used to generate the share icon set.
     */
    global virtual override String getHTML() {

        String strHTML = '';

            strHTML +=      '<!-- >>> ocms_mli_FollowUs.getHTML(...) -->' // to fix any jQuery parsing issues, see: https://pl5.projectlocker.com/Stantive/
            +      '<div class="followUs" data-hw-module="module/FollowUs"'
            +      ' data-hw-options="'
            +          'selectors: {'
            +              'button: \'a.followUsShowHideTrigger\','
            +              'contentArea: \'.followUsShowHideArea\''
            +          '},'
            +          'classes: {'
            +                  'isOpen: \'is-open\''
            +          '},'
            +      '">'
            +          '<div class="followUsContainer">'
            +              '<div class="followUsButtonContainer mobileOnly">'
            +                  '<a href="#" class="followUsShowHideTrigger" aria-expanded="false">'
            +                      '<span>' + ((this.sFollowLabel != null) ? this.sFollowLabel : '') + '</span>'
            +                      '<span class="accessible">:' + ((this.sFollowAccessible != null) ? this.sFollowAccessible : '') + '</span>'
            +                  '</a>'
            +              '</div>'
            +              '<div class="followUsShowHideArea">'
            +                  '<div class="showHideAreaContent">'
            +                      '<span class="followUsShareSubtitle tabletUp">' + ((this.sFollowLabel != null) ? this.sFollowLabel : '') + '</span>'
            +                      generateIcons();
            if ( sOtherSocialLabel != null && sOtherSocialLink != null ){
                strHTML +=             '<div class="followUsButtonContainer tabletUp">'
                +                          '<a href="#" class="followUsShowHideTrigger accessibleLink" aria-expanded="false">'
                +                              '<span class="accessible">' + ((this.sAccessibleOther != null) ? this.sAccessibleOther : '')+ '</span>'
                +                          '</a>'
                +                      '</div>'
                +                      '<div class="otherManuLifeLink">'
                +                          '<span class="linkContent">'
                +                              '<a onclick="' + ocms_mli_Utility.getLinkScript(otherLink.javascript) + '" href="' + ocms_mli_Utility.getLinkHref(otherLink.targetPage)
                +                              '" target="' + ocms_mli_Utility.getLinkTarget(otherLink.target)
                +                              '" class="accessibleLink other-icon" title="' + ((this.sLinkTitle != null) ? this.sLinkTitle : '') + '">'
                +                                  ((this.sOtherSocialLabel != null) ? this.sOtherSocialLabel : '')
                +                                  '<span class="accessible">: ' + ((this.sLinkTitle != null) ? this.sLinkTitle : '') + '</span>'
                +                              '</a>'
                +                          '</span>'
                +                      '</div>';
            }
            strHTML +=         '</div>'
            +              '</div>'
            +          '</div>'
            +      '</div>'
            +      '<!-- <<< ocms_mli_FollowUs.getHTML(...) -->';
        return strHTML;

    }

    private String generateIcons(){

        List<FollowUs> followUsList = new List<FollowUs>();
        String html = '';

        if ( sFBLabel != null && sFBFollowLink != null ){
            FollowUs follow1 = new FollowUs(FBLink);
            follow1.label = sFBLabel;
            follow1.iconClass = 'facebook';
            follow1.analyticsClass = 'analyticsFacebook';
            followUsList.add(follow1);
        }

        if ( sTwitterLabel != null && sTwitterFollowLink != null ){
            FollowUs follow2 = new FollowUs(twitterLink);
            follow2.label = sTwitterLabel;
            follow2.iconClass = 'twitter';
            follow2.analyticsClass = 'analyticsTwitter';
            followUsList.add(follow2);
        }

        if ( sInstagramLabel != null && sInstagramFollowLink != null ){
            FollowUs follow3 = new FollowUs(instagramLink);
            follow3.label = sInstagramLabel;
            follow3.iconClass = 'instagram';
            follow3.analyticsClass = 'analyticsInstagram';
            followUsList.add(follow3);
        }

        if ( sLinkedInLabel != null && sLinkedInFollowLink != null ){
            FollowUs follow4 = new FollowUs(linkedInLink);
            follow4.label = sLinkedInLabel;
            follow4.iconClass = 'linkedin';
            follow4.analyticsClass = 'analyticsLinkedIn';
            followUsList.add(follow4);
        }

        if ( sYoutubeLabel != null && sYoutubeFollowLink != null ){
            FollowUs follow5 = new FollowUs(youtubeLink);
            follow5.label = sYoutubeLabel;
            follow5.iconClass = 'youtube';
            follow5.analyticsClass = 'analyticsYouTube';
            followUsList.add(follow5);
        }

        if ( sRssLabel != null && sRssFollowLink != null ){
            FollowUs follow6 = new FollowUs(rssLink);
            follow6.label = sRssLabel;
            follow6.iconClass = 'rss';
            follow6.analyticsClass = 'analyticsRSS';
            followUsList.add(follow6);
        }

        if (followUsList.size() > 0){
            html += '<ul>';
            for (FollowUs followUs : followUsList){
                html += '<li class="socialIconResize">'
                +         '<a onclick=\'' + followUs.javascript + '\' href="' + followUs.targetPage + '" target="' + followUs.target
                +         '" class="accessibleLink ' + followUs.iconClass + '-icon ' + followUs.analyticsClass + '" title="' + ((this.sLinkTitle != null) ? this.sLinkTitle : '') + '">'
                +         '<span class="accessible">' + ((this.sAccessibleText != null) ? this.sAccessibleText : '')
                +         ' </span>' + followUs.label
                +         '<span class="accessible">: ' + ((this.sLinkTitle != null) ? this.sLinkTitle : '') + '</span>'
                +         '</a>'
                +       '</li>';
            }
            html += '</ul>';
        }
        return html;

    }

    private class FollowUs {

        public String label;
        public String iconClass;
        public String javascript;
        public String targetPage;
        public String target;
        public String analyticsClass;

        public FollowUs(cms.Link link){
            this.javascript = ocms_mli_Utility.getLinkScript(link.javascript);
            this.targetPage = ocms_mli_Utility.getLinkHref(link.targetPage);
            this.target = ocms_mli_Utility.getLinkTarget(link.target);
        }
    }
}