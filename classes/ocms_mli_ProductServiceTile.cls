/**
 * Definition and markup generation for Manulife.com Products and Services Tile used within two column layout (C17B).
 *
 * @author  Saloni Mittal
 * @date    2015-May-15
 *
 */
global with sharing class ocms_mli_ProductServiceTile extends cms.ContentTemplateController {

    // Constructor for the execute request
    global ocms_mli_ProductServiceTile() {}

    // Constructor for the content editor VF page
    global ocms_mli_ProductServiceTile(cms.GenerateContent gc) {
        super(gc);
    }

    // Constructor for generator
    global ocms_mli_ProductServiceTile(cms.CreateContentController cc) {
        super(cc);
    }

    /**
     * @description  Used for icon image.
     */
    public String sTileImageIcon {
        get {
            return getProperty('sTileImageIcon');
        }
        set;
    }

    /**
     * @description  Used for icon image alt text.
     */
    public String sTileImageIconAlt {
        get {
            return getProperty('sTileImageIconAlt');
        }
        set;
    }

    /**
     * @description  Used for tile title.
     */
    public String sTileTitle {
        get {
            return getProperty('sTileTitle');
        }
        set;
    }

    /**
     * @description  Used for Tile Description.
     */
    public String sTileDescription {
        get {
            return getProperty('sTileDescription');
        } set;
    }

    /**
     * @description  Generates mark-up for Products and Services Tile with and without image.
     * @return  String  A string of mark-up used to generate the content.
     */
    global override String getHTML() {

        String sTileHtml = '';

        sTileHtml += '<!-- >>> ocms_mli_ProductServiceTile.getHTML(...) -->' // to fix any jQuery parsing issues, see: https://pl5.projectlocker.com/Stantive/PSTools/trac/wiki/gotcha/OCMSCachingMissingMarkup
                  +  '<section class="tile';
        // If there is no icon, add class noImageTile to tile section
        if (this.sTileImageIcon == null) {
            sTileHtml += ' noImageTile';
        }
        sTileHtml += '">';
        if (this.sTileImageIcon != null) {
            sTileHtml += '<div class="tileImage">'
                      +      '<img class="image-icon" src="' + this.sTileImageIcon + '" alt="' + ((this.sTileImageIconAlt != null) ? this.sTileImageIconAlt : '') + '">'
                      +  '</div>';
        }
        sTileHtml +=     '<div class="tileContent">'
                  +          '<h4>' + ((this.sTileTitle != null) ? this.sTileTitle : '') + '</h4>'
                  +          ((this.sTileDescription != null) ? this.sTileDescription : '')
                  +      '</div>'
                  +  '</section>'
                  +  '<!-- <<< ocms_mli_ProductServiceTile.getHTML(...) -->';
        return sTileHtml;
    }
}