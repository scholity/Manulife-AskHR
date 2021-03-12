global with sharing class ocms_mli_CountryMenuPromo extends cms.ContentTemplateController {

    // Constructor for the execute request
    global ocms_mli_CountryMenuPromo() {}

    // Constructor for the content editor VF page
    global ocms_mli_CountryMenuPromo(cms.GenerateContent gc) {
        super(gc);
    }

    // Constructor for generator
    global ocms_mli_CountryMenuPromo(cms.CreateContentController cc) {
        super(cc);
    }

    /**
     * @description Not to be confused with the Actual content id, this is the id
     *              selected by the content author for purposes of DOM manipulation.
     */
    public String strContentId {
        get { return this.getProperty('strContentId'); }
    }

    /**
     * @description A brief summary included in the promo item.
     */
    public String strSummary {
        get { return this.getProperty('strSummary'); }
    }

    /**
     * @description The link used when the promo item is clicked.
     */
    public String strLink {
        get { return this.getProperty('strLink'); }
    }

    /**
     * @description The object form of the aforementioned link.
     */
    private cms.Link objLink {
        get { return new cms.Link(strLink); }
    }

    /**
     * @description Label applied to the anchor tag
     */
    public String strLinkTitle {
        get { return this.getProperty('strLinkTitle'); }
    }

    /**
     * @description Text contained within anchor tag
     */
    public String strLinkText {
        get { return this.getProperty('strLinkText'); }
    }

    /**
     * @description URL of the image supplied.
     */
    public String strImage {
        get { return this.getProperty('strImage'); }
    }

    /**
     * @description Alt text for accessibility.
     */
    public String strPromoImageAlt {
        get { return this.getProperty('strPromoImageAlt'); }
    }

    /**
     * @description Some additional accessibility text.
     */
    public String accText {
        get { return this.getProperty('accText'); }
    }

    global override String getHTML() {

        String html = '<!-- >>> ocms_mli_CountryMenuPromo.getHTML(...) -->\n'; //  to fix any jQuery parsing issue and it's a good design pattern, see: https://pl5.projectlocker.com/Stantive/PSTools/trac/wiki/gotcha/OCMSCachingMissingMarkup
        html += '<div class="mastheadPromo" id="' + ((strContentId != null) ? strContentId : '') + '">' +
                    '<img src="' + strImage + '" alt="' + strPromoImageAlt + '" />' +
                    '<p>' + strSummary + '</p>' +
                    '<a onclick=\'' + ocms_mli_Utility.getLinkScript(objLink.javascript) + '\' href="' + ocms_mli_Utility.getLinkHref(objLink.targetPage) + '" target="' + ocms_mli_Utility.getLinkTarget(objLink.target) + '" title="' + strLinkTitle + '">' +
                        strLinkText +
                        '<span class="accessible">' +
                            accText +
                        '</span>' +
                    '</a>' +
                 '</div>';

        html += '<!-- <<< ocms_mli_CountryMenuPromo.getHTML(...) -->\n'; //  to fix any jQuery parsing issue and it's a good design pattern, see: https://pl5.projectlocker.com/Stantive/PSTools/trac/wiki/gotcha/OCMSCachingMissingMarkup

        return html;
    }

}