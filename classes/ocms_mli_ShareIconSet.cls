/**
 * Definition and markup generation for Manulife.com share icon set (C101).
 *
 * @author  Saloni Mittal
 * @date    2015-Jul-07
 *
 */
global with sharing class ocms_mli_ShareIconSet extends cms.ContentTemplateController{

    // Constructor for the execute request
    global ocms_mli_ShareIconSet() {}

    // Constructor for the content editor VF page
    global ocms_mli_ShareIconSet(cms.GenerateContent gc) {
        super(gc);
    }

    // Constructor for generator
    global ocms_mli_ShareIconSet(cms.CreateContentController cc) {
        super(cc);
    }

    /**
     * @description  Used for share subtitle.
     */
    public String sShareLabel {
        get { return getProperty('sShareLabel'); }
    }

    /**
     * @description  Used for Share label accessible text only for mobile.
     */
    public String sShareAccessible {
        get { return getProperty('sShareAccessible'); }
    }

    /**
     * @description  Used for Facebook like script.
     */
    public String sFBLikeScript {
        get { return getProperty('sFBLikeScript'); }
    }

    /**
     * @description  Used for Facebook share label.
     */
    public String sFBShareLabel {
        get { return getProperty('sFBShareLabel'); }
    }

    /**
     * @description  Used for Facebook share accessible text.
     */
    public String sFBShareAccessible {
        get { return getProperty('sFBShareAccessible'); }
    }

    /**
     * @description  Used for Twitter share label.
     */
    public String sTwitterShareLabel {
        get { return getProperty('sTwitterShareLabel'); }
    }

    /**
     * @description  Used for Twitter share accessible text.
     */
    public String sTwitterShareAccessible {
        get { return getProperty('sTwitterShareAccessible'); }
    }

    /**
     * @description  Used for LinkedIn share label.
     */
    public String sLinkedInShareLabel {
        get { return getProperty('sLinkedInShareLabel'); }
    }

    /**
     * @description  Used for LinkedIn share accessible text.
     */
    public String sLinkedInShareAccessible {
        get { return getProperty('sLinkedInShareAccessible'); }
    }

    /**
     * @description  Used for Print label text.
     */
    public String sPrintLabel {
        get { return getProperty('sPrintLabel'); }
    }

    /**
     * @description  Used for Print accessible text.
     */
    public String sPrintAccessible {
        get { return getProperty('sPrintAccessible'); }
    }

    /**
     * @description  Used for Email label text.
     */
    public String sEmailLabel {
        get { return getProperty('sEmailLabel'); }
    }

    /**
     * @description  Used for Email accessible text.
     */
    public String sEmailAccessible {
        get { return getProperty('sEmailAccessible'); }
    }

    /**
     * @description  Used for Email Address.
     */
    public String sEmailAddress {
        get { return getProperty('sEmailAddress'); }
    }

    /**
     * @description  Used for Email Subject.
     */
    public String sEmailSubject {
        get { return getProperty('sEmailSubject'); }
    }

     /**
     * @description  Used for Email Body.
     */
    public String sEmailBody {
        get { return getProperty('sEmailBody'); }
    }

    /**
     * @description  Generates mark-up for share icon set.
     * @return  String  A string of mark-up used to generate the share icon set.
     */
    global virtual override String getHTML() {

        String strHTML = '';

            strHTML +=      '<!-- >>> ocms_mli_ShareIconSet.getHTML(...) -->' // to fix any jQuery parsing issues, see: https://pl5.projectlocker.com/Stantive/
                    +       '<!--Share Icon Set-->'
                    +       ((this.sFBLikeScript != null) ? this.sFBLikeScript : '')
                    +       '<div class="contentSharing" data-hw-module="module/social/Sharing">'
                    +          '<div class="contentSharingContainer" data-hw-module="module/ShowHide" data-hw-options="'
                    +              'animationSpeed: 0,'
                    +              'selectors: {'
                    +                  'button: \'.contentSharingShare\','
                    +                  'contentArea: \'.contentSharingDropdown\''
                    +              '},'
                    +              'classes: {'
                    +                  'isOpen: \'is-active\''
                    +              '},'
                    +              'maxBreakpoint: \'mobile\''
                    +          '">'
                    +              '<!--Social sharing list for tablet up, hidden in mobile-->'
                    +              '<div class="tabletUpSocialSharingList tabletUp">';
        if (this.sShareLabel != null) {
            strHTML +=                  '<span class="subtitle">' + this.sShareLabel + '</span>';
        }
            strHTML +=                      '<ul>'
                    +                          '<li style="min-width: 89px" class="facebookLikes">'
                    +                              '<div class="fb-like" data-href="" data-layout="button_count" data-action="like" data-show-faces="true" data-share="false"></div>'
                    +                              '<span style="display: none" class="fbLikes"><img src="' + ocms_mli_Utility.getResourceURL('ocms_mli_pageSupport', 'css/images/white-square.gif') + '"  alt="loading" /></span>'
                                                   // added `display: none`  and changed to `button_count` layout for STI-6745
                    +                          '</li>'
                    +                          '<li>'
                    +                              '<a href="https://www.facebook.com/sharer/sharer.php" target="_blank"';
        if (this.sFBShareAccessible != null) {
            strHTML +=                              ' title="' + this.sFBShareAccessible + '"';
        }
            strHTML +=                              ' class="contentSharingFacebook fbShareBtn shareBtn">' + this.sFBShareLabel;
        if (this.sFBShareAccessible != null) {
            strHTML +=                                  '<span class="accessible">' + this.sFBShareAccessible + '</span>';
        }
            strHTML +=                              '</a>'
                    +                              '<span class="fbShares"><img src="' + ocms_mli_Utility.getResourceURL('ocms_mli_pageSupport', 'css/images/white-square.gif') + '"  alt="loading" /></span>'
                    +                          '</li>'
                    +                          '<li>'
                    +                              '<a href="https://twitter.com/share" target="_blank"';
        if (this.sTwitterShareAccessible != null) {
            strHTML +=                              ' title="' + this.sTwitterShareAccessible + '"';
        }
            strHTML +=                              ' class="contentSharingTwitter twitterShareBtn shareBtn">' + this.sTwitterShareLabel;
        if (this.sTwitterShareAccessible != null) {
            strHTML +=                                  '<span class="accessible">' + this.sTwitterShareAccessible + '</span>';
        }
            strHTML +=                              '</a>'
                    +                               '<span class="twitterShares"><img src="' + ocms_mli_Utility.getResourceURL('ocms_mli_pageSupport', 'css/images/white-square.gif') + '"  alt="loading" /></span>'
                    +                          '</li>'
                    +                          '<li>'
                    +                               '<a href="http://www.linkedin.com/shareArticle" target="_blank"';
        if (this.sLinkedInShareAccessible != null) {
            strHTML +=                              ' title="' + this.sLinkedInShareAccessible + '"';
        }
            strHTML +=                              ' class="contentSharingLinkedin linkedinShareBtn shareBtn">' + this.sLinkedInShareLabel;
        if (this.sLinkedInShareAccessible != null) {
            strHTML +=                                  '<span class="accessible">' + this.sLinkedInShareAccessible + '</span>';
        }
            strHTML +=                              '</a>'
                    +                               '<span class="linkedinShares"><img src="' + ocms_mli_Utility.getResourceURL('ocms_mli_pageSupport', 'css/images/white-square.gif') + '"  alt="loading" /></span>'
                    +                          '</li>'
                    +                      '</ul>'
                    +              '</div>'

                    +              '<!--Initial Sharing Button Options, dropdown hidden in tablet view up-->'
                    +              '<div class="contentSharingButtonList">'
                    +                  '<ul>';
        if (this.sShareLabel != null) {
            strHTML +=                      '<li class="sharingButtonDropdownArrow mobileOnly">'
                    +                          '<a href="#" class="contentSharingShare accessibleLink">' + this.sShareLabel
                    +                          '<span class="accessible">' + ((this.sShareAccessible != null) ? this.sShareAccessible : '') + '</span></a>'
                    +                      '</li>';
        }
            strHTML +=                      '<li class="tabletUp">'
                    +                          '<a href="javascript:window.print();" class="contentSharingButton accessibleLink contentSharingPrint"';
        if (this.sPrintAccessible != null) {
            strHTML +=                          ' title="' + this.sPrintAccessible + '"';
        }
            strHTML +=                          '>' + this.sPrintLabel
                    +                           '<span class="accessible">' + ((this.sPrintAccessible != null) ? this.sPrintAccessible : '') + '</span></a>'
                    +                      '</li>'
                    +                      '<li>'
                    +                           '<a href="#" onclick="fSendEmail(\'' + ((this.sEmailAddress != null) ? this.sEmailAddress : '') + '\', \''
                    +                           ((this.sEmailSubject != null) ? this.sEmailSubject : '') + '\', \''
                    +                           ((this.sEmailBody != null) ? this.sEmailBody : '') + '\');return false;"';
        if (this.sEmailAccessible != null) {
            strHTML +=                          ' title="' + this.sEmailAccessible + '"';
        }
            strHTML +=                          ' class="contentSharingButton accessibleLink contentSharingMail">' + this.sEmailLabel
                    +                           '<span class="accessible">' + ((this.sEmailAccessible != null) ? this.sEmailAccessible : '') + '</span></a>'
                    +                      '</li>'
                    +                  '</ul>'

                    +                  '<!--Share Drop Down Options, mobile only-->'
                    +                  '<div class="contentSharingDropdown">'
                    +                      '<ul>'
                    +                          '<li>'
                    +                              '<div class="fb-like" data-href="" data-layout="button_count" data-action="like" data-show-faces="true" data-share="false"></div>'
                    +                              '<span style="display: none" class="fbLikes"><img src="' + ocms_mli_Utility.getResourceURL('ocms_mli_pageSupport', 'css/images/white-square.gif') + '"  alt="loading" /></span>'
                                                   // added `display: none`  and changed to `button_count` layout for STI-6745
                    +                          '<li>'
                    +                              '<a href="https://www.facebook.com/sharer/sharer.php" target="_blank"';
        if (this.sFBShareAccessible != null) {
            strHTML +=                              ' title="' + this.sFBShareAccessible + '"';
        }
            strHTML +=                              ' class="contentSharingFacebook fbShareBtn shareBtn">' + this.sFBShareLabel;
        if (this.sFBShareAccessible != null) {
            strHTML +=                                  '<span class="accessible">' + this.sFBShareAccessible + '</span>';
        }
            strHTML +=                              '</a>'
                    +                               '<span class="fbShares"><img src="' + ocms_mli_Utility.getResourceURL('ocms_mli_pageSupport', 'css/images/white-square.gif') + '"  alt="loading" /></span>'
                    +                          '</li>'
                    +                          '<li>'
                    +                               '<a href="https://twitter.com/share" target="_blank"';
        if (this.sTwitterShareAccessible != null) {
            strHTML +=                              ' title="' + this.sTwitterShareAccessible + '"';
        }
            strHTML +=                              ' class="contentSharingTwitter twitterShareBtn shareBtn">' + this.sTwitterShareLabel;
        if (this.sTwitterShareAccessible != null) {
            strHTML +=                                  '<span class="accessible">' + this.sTwitterShareAccessible + '</span>';
        }
            strHTML +=                              '</a>'
                    +                               '<span class="twitterShares"><img src="' + ocms_mli_Utility.getResourceURL('ocms_mli_pageSupport', 'css/images/white-square.gif') + '"  alt="loading" /></span>'
                    +                          '</li>'
                    +                          '<li>'
                    +                              '<a href="http://www.linkedin.com/shareArticle" target="_blank"';
        if (this.sLinkedInShareAccessible != null) {
            strHTML +=                              ' title="' + this.sLinkedInShareAccessible + '"';
        }
            strHTML +=                              ' class="contentSharingLinkedin linkedinShareBtn shareBtn">' + this.sLinkedInShareLabel;
        if (this.sLinkedInShareAccessible != null) {
            strHTML +=                                  '<span class="accessible">' + this.sLinkedInShareAccessible + '</span>';
        }
            strHTML +=                              '</a>'
                    +                               '<span class="linkedinShares"><img src="' + ocms_mli_Utility.getResourceURL('ocms_mli_pageSupport', 'css/images/white-square.gif') + '"  alt="loading" /></span>'
                    +                          '</li>'
                    +                      '</ul>'
                    +                  '</div>'
                    +              '</div>'
                    +          '</div>'
                    +      '</div>'
                    +      '<!-- <<< ocms_mli_ShareIconSet.getHTML(...) -->';
        return strHTML;

    }
}