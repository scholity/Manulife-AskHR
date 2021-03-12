/**
 * Definition and markup generation for Manulife.com Droplist textarea  (C28A).
 *
 * @author  Saloni Mittal
 * @date    2015-May-19
 *
 */
global with sharing class ocms_mli_DroplistContent extends cms.ContentTemplateController {

    // Constructor for the execute request
    global ocms_mli_DroplistContent() {}

    // Constructor for the content editor VF page
    global ocms_mli_DroplistContent(cms.GenerateContent gc) {
        super(gc);
    }

    // Constructor for generator
    global ocms_mli_DroplistContent(cms.CreateContentController cc) {
        super(cc);
    }

    /**
     * @description  Used for droplist text
     */
    public String sDroplistText {
        get { return getProperty('sDroplistText'); }
    }

    /**
     * @description  Used for droplist accessible text
     */
    public String sDroplistAccessible {
        get { return getProperty('sDroplistAccessible'); }
    }

    /**
     * @description  Used for droplist textarea link text.
     */
    public String sLinkText {
        get { return getProperty('sLinkText'); }
    }

    /**
     * @description  Used for droplist textarea link.
     */
    public String sLink {
        get { return getProperty('sLink'); }
    }

    private cms.Link objLink {
        get { return new cms.Link(sLink); }
    }

    /**
     * @description  Generates mark-up for droplist textarea content.
     * @return  String  A string of mark-up used to generate the content.
     */
    global override String getHTML() {

        String sDroplistTextHtml = '';

        sDroplistTextHtml += '<!-- >>> ocms_mli_DroplistContent.getHTML(...) -->' // to fix any jQuery parsing issues, see: https://pl5.projectlocker.com/Stantive/PSTools/trac/wiki/gotcha/OCMSCachingMissingMarkup
                          +  '<div class="jsDroplistItem hidden">'
                          +      '<div class="droplistTextArea">'
                          +          ((this.sDroplistText != null) ? this.sDroplistText : '');
        if (this.sLinkText != null && objLink.targetPage != null) {
            sDroplistTextHtml +=         '<div class="jumper">'
                              +              '<a href="' + ocms_mli_Utility.getLinkHref(objLink.targetPage) + '" target="' + ocms_mli_Utility.getLinkTarget(objLink.target) + '">'
                              +                  '<span class="title">'
                              +                      '<span class="accessible">' + ((this.sDroplistAccessible != null) ? this.sDroplistAccessible : '') + '</span>'
                              +                       this.sLinkText
                              +                  '</span>'
                              +              '</a>'
                              +          '</div>';
        }
        sDroplistTextHtml +=     '</div>'
                          +  '</div>'
                          +  '<!-- <<< ocms_mli_DroplistContent.getHTML(...) -->';
        return sDroplistTextHtml;
    }
}