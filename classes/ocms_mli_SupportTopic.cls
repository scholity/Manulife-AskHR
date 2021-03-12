global with sharing class ocms_mli_SupportTopic extends cms.ContentTemplateController {

    global ocms_mli_SupportTopic() {}

    global ocms_mli_SupportTopic(cms.GenerateContent gc) {
        super(gc);
    }

    global ocms_mli_SupportTopic(cms.CreateContentController cc) {
        super(cc);
    }

    global override String getHTML() {
        String html = '';

        html += '<script>' +
                    'MLI.analytics.page.supportTopic = "' + this.supportTopic.escapeEcmaScript() + '";' +
                '</script>';

        return html;
    }

    public String supportTopic {
        get {
            return getProperty('supportTopic');
        }
    }

}