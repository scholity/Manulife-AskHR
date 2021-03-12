/**
 * Definition and markup generation for Manulife.com generic content (C18E).
 * This can also be used to generate markup for
 * - [C13] Graph and Chart
 * - [C18B] Shareholder Services
 * - [C18C] Quarterly and Annual Report
 *
 * @author  Saloni Mittal
 * @date    2015-Jun-16
 *
 */
global with sharing class ocms_mli_GenericContent extends cms.ContentTemplateController {

    // Constructor for the execute request
    global ocms_mli_GenericContent() {}

    // Constructor for the content editor VF page
    global ocms_mli_GenericContent(cms.GenerateContent gc) {
        super(gc);
    }

    // Constructor for generator
    global ocms_mli_GenericContent(cms.CreateContentController cc) {
        super(cc);
    }

    /**
     * @description  Used for content section icon.
     */
    public String sGenericContentIcon {
        get {
            return getProperty('sGenericContentIcon');
        }
        set;
    }

    /**
     * @description  Used for content section title.
     */
    public String sGenericContentTitle {
        get {
            return getProperty('sGenericContentTitle');
        }
        set;
    }

    /**
     * @description  Used for content section heading.
     */
    public String sGenericContentHeading {
        get {
            return getProperty('sGenericContentHeading');
        }
        set;
    }

    /**
     * @description  Used for content section body content.
     */
    public String sGenericContentBody {
        get {
            return getProperty('sGenericContentBody');
        }
        set;
    }

    /**
     * @description  Used for content image positioning.
     */
    public String sGenericContentImagePosition {
        get {
            return getProperty('sGenericContentImagePosition');
        }
        set;
    }

    /**
     * @description  Used for content image.
     */
    public String sGenericContentImage {
        get {
            return getProperty('sGenericContentImage');
        }
        set;
    }

    /**
     * @description  Used for content image for mobile.
     */
    public String sGenericContentImageMobile {
        get {
            return getProperty('sGenericContentImageMobile');
        }
        set;
    }

    /**
     * @description  Used for content image alt text.
     */
    public String sGenericContentImageAlt {
        get {
            return getProperty('sGenericContentImageAlt');
        }
        set;
    }

    /**
     * @description  Used for footer link label.
     */
    public String sLinkTitle {
        get { return getProperty('sLinkTitle'); }
    }

    /**
     * @description  Used for footer link.
     */
    public String sLink {
        get { return getProperty('sLink'); }
    }

    private cms.Link objLink {
        get { return new cms.Link(sLink); }
    }

    /**
     * @description  Generates mark-up for generic content.
     * @return  String  A string of mark-up used to generate the content.
     */
    global override String getHTML() {

        String sGenericContentHtml = '';

        sGenericContentHtml += '<!-- >>> ocms_mli_GenericContent.getHTML(...) -->' // to fix any jQuery parsing issues, see: https://pl5.projectlocker.com/Stantive/PSTools/trac/wiki/gotcha/OCMSCachingMissingMarkup
                            +  '<div class="landingWidget">';

        // don't generate the header widget if it is null or empty
        if (this.sGenericContentTitle != null && this.sGenericContentTitle != '') {
		    sGenericContentHtml +=      '<div class="widgetHeader">'
		                        +          '<h3 class="widgetHeading';
		    if (this.sGenericContentIcon == null) {
		        sGenericContentHtml +=     ' widgetHeading--noIcon';
		    }
		    sGenericContentHtml +=         '">';
		    if (this.sGenericContentIcon != null) {
		        sGenericContentHtml +=         '<span class="image-icon">'
		                            +              '<img src="' + ((this.sGenericContentIcon != null) ? this.sGenericContentIcon : '') + '" alt="' + ((this.sGenericContentTitle != null) ? this.sGenericContentTitle : '') + '">'
		                            +          '</span>';
		    }
		    sGenericContentHtml +=             ((this.sGenericContentTitle != null) ? this.sGenericContentTitle : '')
		                        +          '</h3>'
		                        +      '</div>';
        }

        sGenericContentHtml +=      '<div class="widgetContent">'
                            +          '<div class="widgetContentBlock';
        if (this.sGenericContentImage != null && this.sGenericContentImageMobile != null) {
            if (this.sGenericContentImagePosition == 'left') {
                sGenericContentHtml +=     ' widgetContentBlock--leftImage';
            } else {
                sGenericContentHtml +=     ' widgetContentBlock--rightImage';
            }
        }
        sGenericContentHtml +=         '">';
        if (this.sGenericContentImage != null && this.sGenericContentImageMobile != null) {
            sGenericContentHtml +=         '<div class="widgetContentBlock__decor">'
                                +            '<div class="widgetContentBlock__decorWrapper">'
                                +              '<img class="tabletUp" src="' + this.sGenericContentImage + '" alt="' + ((this.sGenericContentImageAlt != null) ? this.sGenericContentImageAlt : '') + '"/>'
                                +              '<img class="mobileOnly" src="' + this.sGenericContentImageMobile + '" alt="' + ((this.sGenericContentImageAlt != null) ? this.sGenericContentImageAlt : '') + '"/>'
                                +            '</div>'
                                +          '</div>';
        }
        sGenericContentHtml +=             '<div class="widgetContentBlock__content">'
                            +                  '<div class="widgetContentBlock__contentWrapper">';
        if (this.sGenericContentHeading != null) {
            sGenericContentHtml +=                 '<h4 class="widgetContentBlock__heading">' + this.sGenericContentHeading + '</h4>';
        }
        if (this.sGenericContentBody != null) {
            sGenericContentHtml +=                 this.sGenericContentBody;
        }
        sGenericContentHtml +=                 '</div>'
                            +              '</div>'
                            +          '</div>'
                            +      '</div>';
        if (this.sLinkTitle != null && objLink.targetPage != null) {
            sGenericContentHtml += '<div class="widgetFooter">'
                                +     '<a class="jumper" onclick=\'' + ocms_mli_Utility.getLinkScript(objLink.javascript) + '\' href="' + ocms_mli_Utility.getLinkHref(objLink.targetPage) + '" target="' + ocms_mli_Utility.getLinkTarget(objLink.target) + '">'
                                +         '<span class="title">'
                                +             '<span class="accessible">['
                                +                 this.sGenericContentTitle
                                +             ']:</span>'
                                +             this.sLinkTitle
                                +         '</span>'
                                +     '</a>'
                                +  '</div>';
        }
        sGenericContentHtml += '</div>'
                            +  '<!-- <<< ocms_mli_GenericContent.getHTML(...) -->';
        return sGenericContentHtml;

    }
}