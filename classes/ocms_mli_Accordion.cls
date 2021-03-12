/**
 * Definition and markup generation for Manulife.com Accordion with and without image (C10A, C10B).
 *
 * @author  Saloni Mittal
 * @date    2015-May-14
 *
 */
global with sharing class ocms_mli_Accordion extends cms.ContentTemplateController {

    // Constructor for the execute request
    global ocms_mli_Accordion() {}

    // Constructor for the content editor VF page
    global ocms_mli_Accordion(cms.GenerateContent gc) {
        super(gc);
    }

    // Constructor for generator
    global ocms_mli_Accordion(cms.CreateContentController cc) {
        super(cc);
    }

    /**
     * @description  Used for Accordion content image.
     */
    public String sAccordionImage {
        get {
            return getProperty('sAccordionImage');
        }
        set;
    }

    /**
     * @description  Used for Accordion content image alt text.
     */
    public String sAccordianImageAlt {
        get {
            return getProperty('sAccordianImageAlt');
        }
        set;
    }

    /**
     * @description  Used if detailed content needs to be shown in Accordion
     */
    public String sShowContent {
        get {
            return this.getProperty('sShowContent');
        }
    }

    /**
     * @description  Used if a particular Accordion content is first in the list
     */
    public String sFirstAccordion {
        get {
            return this.getProperty('sFirstAccordion');
        }
    }

    /**
     * @description  Used for Accordion content title.
     */
    public String sAccordianLinkTitle {
        get {
            return getProperty('sAccordianLinkTitle');
        }
        set;
    }

    /**
     * @description  Used for Accordian content summary.
     */
    public String sAccordianSummary {
        get {
            return getProperty('sAccordianSummary');
        } set;
    }

    /**
     * @description  Used for Accordion content detail.
     */
    public String sAccordianDetail {
        get {
            return getProperty('sAccordianDetail');
        } set;
    }

    /**
     * @description  Used for Accordion call to action text.
     */
    public String sCallToActionText {
        get { return getProperty('sCallToActionText'); }
    }

    /**
     * @description  Used for destination page link.
     */
    public String sAccordionDestLink {
        get { return getProperty('sAccordionDestLink'); }
    }

    private cms.Link objLink {
        get { return new cms.Link(sAccordionDestLink); }
    }

    /**
     * @description  Generates mark-up for Accordion content with and without image.
     * @return  String  A string of mark-up used to generate the content.
     */
    global override String getHTML() {

        String sAccordionHtml = '';

        sAccordionHtml += '<!-- >>> ocms_mli_Accordion.getHTML(...) -->' // to fix any jQuery parsing issues, see: https://pl5.projectlocker.com/Stantive/PSTools/trac/wiki/gotcha/OCMSCachingMissingMarkup
                       +  '<div class="groupArea">'
                       +    '<div class="accordionWithImage';
        // If there is no image, add class accordionNoImage to accordionWithImage div
        if (this.sAccordionImage == null) {
            sAccordionHtml += ' accordionNoImage';
        }
        // If a particular accordion is first in list, add class firstAccordion to accordionWithImage div
        if(this.sFirstAccordion == 'true') {
            sAccordionHtml += ' firstAccordion';
        }
        sAccordionHtml += '">'
                       +     '<div class="accordionWithImageContainer';
        // If accordion detail needs to be shown by default, add class is-active to accordionWithImageContainer div
        if(this.sShowContent == 'true') {
            sAccordionHtml += ' is-active';
        }
        sAccordionHtml +=     '" data-hw-module="module/ShowHide" '
                       +      'data-hw-options="selectors: {button: \'.accordionWithImageTrigger\'}, classes: {isOpen: \'is-active\'}">'
                       +         '<div class="accordionWithImageContainerInner">';
        if (this.sAccordionImage != null) {
            sAccordionHtml +=         '<div class="accordionImage tabletUp"><span>'
                           +          '<img src="' + this.sAccordionImage + '" alt="' + ((this.sAccordianImageAlt != null) ? this.sAccordianImageAlt : '') + '">'
                           +          '</span></div>';
        }
        sAccordionHtml +=             '<div class="accordionWithImageTextContainer">'
                       +                  '<a class="accordionWithImageTrigger" href="#">' + ((this.sAccordianLinkTitle != null) ? this.sAccordianLinkTitle : '') + '</a>'
                       +                  '<p class="accordionWithImageParagraph">' + ((this.sAccordianSummary != null) ? this.sAccordianSummary : '') + '</p>'
                       +              '</div>'
                       +              '<div class="contentArea">'
                       +                  '<div class="accordionWithImageFilter">'
                       +                      ((this.sAccordianDetail != null) ? this.sAccordianDetail : '');
        if (this.sCallToActionText != null && objLink.targetPage != null) {
            sAccordionHtml +=                     '<div class="action">'
                           +                          '<a class="button" onclick=\'' + ocms_mli_Utility.getLinkScript(objLink.javascript) + '\' href="'
                           +                           ocms_mli_Utility.getLinkHref(objLink.targetPage) + '" target="' + ocms_mli_Utility.getLinkTarget(objLink.target) + '">'
                           +                           this.sCallToActionText +'</a>'
                           +                      '</div>';
        }
        sAccordionHtml +=                 '</div>'
                       +              '</div>'
                       +          '</div>'
                       +      '</div>'
                       +    '</div>'
                       +  '</div>'
                       +  '<!-- <<< ocms_mli_Accordion.getHTML(...) -->';
        return sAccordionHtml;
    }
}