/**
 * Created by rhyanmitchell on 2017-02-13.
 */

global with sharing class ocms_mfc_uStudio extends cms.ContentTemplateController {

    global ocms_mfc_uStudio() {}

    global ocms_mfc_uStudio(cms.CreateContentController cc) { super(cc); }

    global ocms_mfc_uStudio(cms.GenerateContent gc) {
        super(gc);
    }

    // For generated markup, we are overriding this to support multiple templates
    global override virtual String getHTML() {
        return this.body;
    }

    public String body {
        get {
            return getProperty('body');
        } set;
    }

}