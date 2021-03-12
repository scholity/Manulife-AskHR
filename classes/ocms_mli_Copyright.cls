global with sharing class ocms_mli_Copyright extends cms.ContentTemplateController {

    // Constructor for the execute request
    global ocms_mli_Copyright() {}

    // Constructor for the content editor VF page
    global ocms_mli_Copyright(cms.GenerateContent gc) {
        super(gc);
    }

    // Constructor for the generator
    global ocms_mli_Copyright(cms.CreateContentController cc) {
        super(cc);
    }

    /**
     * @description Label text for the copyright link
     */
    public String strLabel {
        get { return getProperty('strLabel'); }
    }

    /**
     * @description Link for the copyright content
     */
    public String strLink {
        get { return getProperty('strLink'); }
    }

    /**
     * @description Link as an object
     */
    private cms.Link objLink {
        get { return new cms.Link(strLink); }
    }

    /**
     * @description Accessibility feature label
     */
    public String accLabel {
        get { return getProperty('accLabel'); }
    }

    global override String getHTML() {

        String html = '';

        html += '<!-- >>> ocms_mli_Copyright.getHTML(...) -->' + // to fix any jQuery parsing issues, see: https://pl5.projectlocker.com/Stantive/PSTools/trac/wiki/gotcha/OCMSCachingMissingMarkup
                '<p class = "copyright">' +
                    '<a onclick=\'' + ocms_mli_Utility.getLinkScript(objLink.javascript) + '\' href="' + ocms_mli_Utility.getLinkHref(objLink.targetPage) + '" target="' + ocms_mli_Utility.getLinkTarget(objLink.target) + '" title="' + accLabel + '">' +
                        strLabel +
                        '<span class="accessible">' + accLabel + '</span>' +
                    '</a>' +
                '</p>' +
                '<!-- <<< ocms_mli_Copyright.getHTML(...) -->';

        return html;

    }
}