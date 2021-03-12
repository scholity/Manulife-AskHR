global with sharing class ocms_mli_FooterMenuItem extends cms.ContentTemplateController {

    global ocms_mli_FooterMenuItem() {}

    global ocms_mli_FooterMenuItem(cms.GenerateContent gc) {
        super(gc);
    }

    global ocms_mli_FooterMenuItem(cms.CreateContentController cc) {
        super(cc);
    }

    public String strLabel {
        get { return getProperty('strLabel'); }
    }

    public String strLink {
        get { return getProperty('strLink'); }
    }

    private cms.Link objLink {
        get { return new cms.Link(strLink); }
    }

    public String accLabel {
        get { return getProperty('accLabel'); }
    }

    global override String getHTML() {

        String html = '';

        html += '<!-- >>> ocms_mli_FooterMenuItem.getHTML(...) -->' + // to fix any jQuery parsing issues, see: https://pl5.projectlocker.com/Stantive/PSTools/trac/wiki/gotcha/OCMSCachingMissingMarkup
                '<li>' +
                    '<a onclick=\'' + ocms_mli_Utility.getLinkScript(objLink.javascript) + '\' href="' + ocms_mli_Utility.getLinkHref(objLink.targetPage) + '" target="' + ocms_mli_Utility.getLinkTarget(objLink.target) + '" title="' + accLabel + '">' +
                        strLabel +
                        '<span class="accessible">' + accLabel + '</span>' +
                    '</a>' +
                '</li>' +
                '<!-- <<< ocms_mli_FooterMenuItem.getHTML(...) -->';

        return html;

    }

}