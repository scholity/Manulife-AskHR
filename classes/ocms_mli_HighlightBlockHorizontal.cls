/**
 * Definition and markup generation for Manulife.com Highlight Block Horizontal content (C28B).
 *
 * @author  Saloni Mittal
 * @date    2015-May-13
 *
 */
global with sharing class ocms_mli_HighlightBlockHorizontal extends cms.ContentTemplateController {

    // Constructor for the execute request
    global ocms_mli_HighlightBlockHorizontal() {}

    // Constructor for the content editor VF page
    global ocms_mli_HighlightBlockHorizontal(cms.GenerateContent gc) {
        super(gc);
    }

    // Constructor for generator
    global ocms_mli_HighlightBlockHorizontal(cms.CreateContentController cc) {
        super(cc);
    }

    /**
     * @description  Used for horizontal block image.
     */
    public String blockImage {
        get {
            return getProperty('blockImage');
        }
        set;
    }

    /**
     * @description  Used for horizontal block image alt text.
     */
    public String sBlockImageAlt {
        get {
            return getProperty('sBlockImageAlt');
        }
        set;
    }

    /**
     * @description  Used for image positioning.
     */
    public String sImagePosition {
        get {
            return getProperty('sImagePosition');
        }
        set;
    }

    /**
     * @description  Used for horizontal block title.
     */
    public String sBlockTitle {
        get {
            return getProperty('sBlockTitle');
        }
        set;
    }

    /**
     * @description  Used for horizontal block description.
     */
    public String sBlockDescription {
        get {
            return getProperty('sBlockDescription');
        } set;
    }

    /**
     * @description  Used for horizontal block link text.
     */
    public String sLinkText {
        get { return getProperty('sLinkText'); }
    }

    /**
     * @description  Used for horizontal block link.
     */
    public String blockLink {
        get { return getProperty('blockLink'); }
    }

    private cms.Link objLink {
        get { return new cms.Link(blockLink); }
    }

    /**
     * @description  Generates mark-up for highlight block horizontal content.
     * @return  String  A string of mark-up used to generate the content.
     */
    global override String getHTML() {

        String sHighlightBlockHtml = '';

        sHighlightBlockHtml += '<!-- >>> ocms_mli_HighlightBlockHorizontal.getHTML(...) -->' // to fix any jQuery parsing issues, see: https://pl5.projectlocker.com/Stantive/PSTools/trac/wiki/gotcha/OCMSCachingMissingMarkup
                            +  '<div class="highlightBlock';
        // If there is no image, add class noMedia to the main div
        if (this.blockImage == null){
            sHighlightBlockHtml += ' noMedia';
        }
        if (this.sBlockTitle == null || this.sBlockTitle == '') {
            sHighlightBlockHtml += ' noBlockTitle';
        }
        sHighlightBlockHtml += '">'
                            +     '<div class="wrapper">'
                            +          '<div class="row">';
        if (this.blockImage != null) {
            sHighlightBlockHtml +=         '<div class="media';
            if (this.sImagePosition == 'right') {
                sHighlightBlockHtml +=     ' imageRight';
            }
            sHighlightBlockHtml +=         '">'
                                +             '<div class="mediaWrapper">'
                                +                 '<img src="' + ((this.blockImage != null) ? this.blockImage : '') + '" alt="' + ((this.sBlockImageAlt != null) ? this.sBlockImageAlt : '') + '">'
                                +             '</div>'
                                +          '</div>';
        }
        sHighlightBlockHtml +=             '<div class="content">';
        if (this.sBlockTitle != null && this.sBlockTitle != '') {
            sHighlightBlockHtml +=                '<h2 class="highlightBlockTitle">' + ((this.sBlockTitle != null) ? this.sBlockTitle : '') + '</h2>';

        }


        sHighlightBlockHtml +=                 ((this.sBlockDescription != null) ? this.sBlockDescription : '');

        if (this.sLinkText != null && objLink.targetPage != null) {
            sHighlightBlockHtml +=             '<div class="action">'
                                +                 '<a class="button" onclick=\'' + ocms_mli_Utility.getLinkScript(objLink.javascript) + '\' href="' + ocms_mli_Utility.getLinkHref(objLink.targetPage) + '" target="' + ocms_mli_Utility.getLinkTarget(objLink.target) + '">'
                                +                     this.sLinkText
                                +                 '</a>'
                                +              '</div>';
        }
        sHighlightBlockHtml +=             '</div>'
                            +          '</div>'
                            +      '</div>'
                            +  '</div>'
                            +  '<!-- <<< ocms_mli_HighlightBlockHorizontal.getHTML(...) -->';
        return sHighlightBlockHtml;

    }
}