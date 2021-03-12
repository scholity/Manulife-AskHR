/**
 * Definition and markup generation for Manulife.com Page Title
 *
 * @author  Saloni Mittal
 * @date    2015-Jul-13
 *
 */
global with sharing class ocms_mli_PageTitle extends cms.ContentTemplateController {

    // Constructor for the execute request
    global ocms_mli_PageTitle() {}

    // Constructor for the content editor VF page
    global ocms_mli_PageTitle(cms.GenerateContent gc) {
        super(gc);
    }

    // Constructor for generator
    global ocms_mli_PageTitle(cms.CreateContentController cc) {
        super(cc);
    }

    /**
     * @description  Used for section title.
     */
    public String sTitleText {
        get {
            return getProperty('sTitleText');
        }
        set;
    }

    /**
     * @description  Generates mark-up for Page Title
     * @return  String  A string of mark-up used to generate the content.
     */
    global override String getHTML() {

        String sTitleHtml = '';

        sTitleHtml += '<!-- >>> ocms_mli_PageTitle.getHTML(...) -->' // to fix any jQuery parsing issues, see: https://pl5.projectlocker.com/Stantive/PSTools/trac/wiki/gotcha/OCMSCachingMissingMarkup
                   +  '<h2 class="pageTitle">'
                   +    ((this.sTitleText != null) ? this.sTitleText : '')
                   +  '</h2>'
                   +  '<!-- <<< ocms_mli_PageTitle.getHTML(...) -->';
        return sTitleHtml;
    }
}