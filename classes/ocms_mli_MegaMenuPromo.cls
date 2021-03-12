global with sharing class ocms_mli_MegaMenuPromo extends cms.ContentTemplateController{

	global ocms_mli_MegaMenuPromo() {}

    global ocms_mli_MegaMenuPromo(cms.GenerateContent gc) {
        super(gc);
    }

    global ocms_mli_MegaMenuPromo(cms.CreateContentController cc) {
        super(cc);
    }

    public String strLinkText {
        get { return this.getProperty('strLinkText'); }
    }

    public String strContentId {
        get { return this.getProperty('strContentId'); }
    }

    public String strLinkAccessibilityText {
        get { return this.getProperty('strLinkAccessibilityText'); }
    }

    public String strPromoImage {
        get { return this.getProperty('strPromoImage'); }
    }

    public String strImageHoverText {
        get { return this.getProperty('strImageHoverText'); }
    }

    public String strLink {
        get { return this.getProperty('strLink'); }
    }

    private cms.Link objLink {
        get {
            return new cms.Link(strLink);
        }
    }

    global override String getHTML() {
        String html = '';

        html += '<!-- >>> ocms_mli_MegaMenuPromo.getHTML(...) -->' +
                '<div class="mastheadPromo" id="' + ((strContentId != null) ? strContentId : '') + '">' +
                    '<a onclick=\'' + ocms_mli_Utility.getLinkScript(objLink.javascript) + '\' href="' + ocms_mli_Utility.getLinkHref(objLink.targetPage) + '" target="' + ocms_mli_Utility.getLinkTarget(objLink.target) + '" class="promoDownload" title="' + ((strImageHoverText != null) ? strImageHoverText : '') + '">' +
                        '<span><img src="' + ((strPromoImage != null) ? strPromoImage : '') + '" alt=""></span>' +
                        '<span class="description">' + ((strLinkText != null) ? strLinkText : '') + '</span>' +
                        '<span class="accessible">' + ((strLinkAccessibilityText != null) ? strLinkAccessibilityText : '') + '</span>' +
                    '</a>' +
                '</div>' +
                '<!-- <<< ocms_mli_MegaMenuPromo.getHTML(...) -->';

        return html;
    }
}