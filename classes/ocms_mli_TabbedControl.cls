global with sharing class ocms_mli_TabbedControl extends cms.ContentTemplateController {

    global ocms_mli_TabbedControl() {}

    global ocms_mli_TabbedControl(cms.GenerateContent gc) {
        super(gc);
    }

    global ocms_mli_TabbedControl(cms.CreateContentController cc) {
        super(cc);
    }

    public String jsnTabList {
        get { return getProperty('jsnTabList'); }
    }

    private List<String> lstTabList {
        get {
            try {
                return (List<String>)JSON.deserialize(jsnTabList, List<String>.class);
            }
            catch (Exception e) { // should never end up here unless a property stored is malformed
                return new List<String>{};
                }
         }
    }

    global override String getHTML() {

        String html = '';

        html += '<!-- >>> ocms_mli_TabbedControl.getHTML(...) -->' + // to fix any jQuery parsing issues, see: https://pl5.projectlocker.com/Stantive/PSTools/trac/wiki/gotcha/OCMSCachingMissingMarkup
                '<div class="inPageTabsContainer">' +
                    buildTabs() +
                '</div>' +
                '<!-- <<< ocms_mli_TabbedControl.getHTML(...) -->';

        return html;

    }

    private String buildTabs() {

        Integer ctr = 1;
        String html = '<ul role="tablist">';

        for (String label : lstTabList) {
            html += '<li role="presentation">' +
                        '<a role="tab" aria-controls="tab' + ctr + '" href="#tab' + ctr + '">' +
                            '<span>' + label + '</span>' +
                        '</a>' +
                    '</li>';
            ctr++;
        }

        html += '</ul>';

        return html;

    }
}