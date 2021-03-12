/**
 * Definition and markup generation for Manulife.com Section Title used within two column layout in Products and Services page (C17B).
 *
 * @author  Saloni Mittal
 * @date    2015-May-20
 *
 */
global with sharing class ocms_mli_SectionTitle extends cms.ContentTemplateController {

    // Constructor for the execute request
    global ocms_mli_SectionTitle() {}

    // Constructor for the content editor VF page
    global ocms_mli_SectionTitle(cms.GenerateContent gc) {
        super(gc);
    }

    // Constructor for generator
    global ocms_mli_SectionTitle(cms.CreateContentController cc) {
        super(cc);
    }

    /**
     * @description  Used for section title image icon
     */
    public String sTitleImageIcon {
        get {
            return getProperty('sTitleImageIcon');
        }
        set;
    }

    /**
     * @description  Used for section title image icon alt text
     */
    public String sTitleImageAlt {
        get {
            return getProperty('sTitleImageAlt');
        }
        set;
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
     * @description  Generates mark-up for Section Title in Products and Services page.
     * @return  String  A string of mark-up used to generate the content.
     */
    global override String getHTML() {

        String sTitleHtml = '';

        sTitleHtml += '<!-- >>> ocms_mli_SectionTitle.getHTML(...) -->' // to fix any jQuery parsing issues, see: https://pl5.projectlocker.com/Stantive/PSTools/trac/wiki/gotcha/OCMSCachingMissingMarkup
                   +  '<div class="sectionTitle';
        if (this.sTitleImageIcon == null) {
            sTitleHtml += ' textAndImage__sectionTitle--noIcon';
        }
        sTitleHtml += '">'
                   +      '<h3>';
        if (this.sTitleImageIcon != null) {
            sTitleHtml +=     '<span class="image-icon">'
                       +          '<img src="' + this.sTitleImageIcon + '" alt="' + ((this.sTitleImageAlt != null) ? this.sTitleImageAlt : '') + '">'
                       +      '</span>';
        }
        sTitleHtml +=         '<span class="text">' + ((this.sTitleText != null) ? this.sTitleText : '') + '</span>'
                   +      '</h3>'
                   +  '</div>'
                   +  '<!-- <<< ocms_mli_SectionTitle.getHTML(...) -->';
        return sTitleHtml;
    }
}