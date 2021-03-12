/**
 * Definition and markup generation for Manulife.com Archive Main content (C19A).
 *
 * @author  Saloni Mittal
 * @date    2015-June-15
 *
 */
global with sharing class ocms_mli_ArchiveMain extends cms.ContentTemplateController {

    // Constructor for the execute request
    global ocms_mli_ArchiveMain() {}

    // Constructor for the content editor VF page
    global ocms_mli_ArchiveMain(cms.GenerateContent gc) {
        super(gc);
    }

    // Constructor for generator
    global ocms_mli_ArchiveMain(cms.CreateContentController cc) {
        super(cc);
    }

    /* ARCHIVE SECTION */
    /**
     * @description  Used for icon associated with Section Title.
     */
    public String sArchiveSectionIcon {
        get {
            return getProperty('sArchiveSectionIcon');
        }
        set;
    }

    /**
     * @description  Used for Section Title.
     */
    public String sArchiveSectionTitle {
        get {
            return getProperty('sArchiveSectionTitle');
        }
        set;
    }

    /**
     * @description  Used for Archive item body.
     */
    public String sArchiveSectionBody {
        get {
            return getProperty('sArchiveSectionBody');
        }
        set;
    }

    /**
     * @description  Used for Archive section button label.
     */
    public String sArchiveSectionButton {
        get {
            return getProperty('sArchiveSectionButton');
        }
        set;
    }

    /**
     * @description  Used for Archive section button link.
     */
    public String sArchiveSectionButtonLink {
        get {
            return getProperty('sArchiveSectionButtonLink');
        } set;
    }

    private cms.Link objLink {
        get { return new cms.Link(sArchiveSectionButtonLink); }
    }

    /**
     * @description  Used for Archive item category.
     */
    public String sArchiveItemCategory {
        get {
            return getProperty('sArchiveItemCategory');
        }
        set;
    }

    /**
     * @description  Used for Archive item file.
     */
    public String sArchiveItemFile {
        get {
            return getProperty('sArchiveItemFile');
        }
        set;
    }

    /**
     * @description  Generates mark-up for archive main content.
     * @return  String  A string of mark-up used to generate the content.
     */
    global override String getHTML() {

        String sArchiveMainHtml = '';

        sArchiveMainHtml += '<!-- >>> ocms_mli_ArchiveMain.getHTML(...) -->' // to fix any jQuery parsing issues, see: https://pl5.projectlocker.com/Stantive/PSTools/trac/wiki/gotcha/OCMSCachingMissingMarkup
                         +  '<div class="genericContentContainer">'
                         +     '<div class="genericIconTitle genericIconTitleAlt">'
                         +          '<h3 class="title';
        if (this.sArchiveSectionIcon == null) {
            sArchiveMainHtml +=         ' genericIconTitle__title--noIcon';
        }
        sArchiveMainHtml +=         '">';
        if (this.sArchiveSectionIcon != null) {
            sArchiveMainHtml +=         '<span class="image-icon">'
                             +              '<img src="' + this.sArchiveSectionIcon + '" alt="' + ((this.sArchiveSectionTitle != null) ? this.sArchiveSectionTitle : '') + '">'
                             +          '</span>';
        }
        sArchiveMainHtml +=             '<span class="text">' + ((this.sArchiveSectionTitle != null) ? this.sArchiveSectionTitle : '') + '</span>'
                         +           '</h3>'
                         +      '</div>'
                         +      '<section class="archiveMain">'
                         +          '<div class="description">'
                         +              '<div class="content">'
                         +                  ((this.sArchiveSectionBody != null) ? this.sArchiveSectionBody : '');
        if (this.sArchiveSectionButton != null && objLink.targetPage != null) {
            sArchiveMainHtml +=             '<div class="action">'
                             +                  '<a class="button" onclick=\'' + ocms_mli_Utility.getLinkScript(objLink.javascript) + '\' href="' + ocms_mli_Utility.getLinkHref(objLink.targetPage) + '" target="' + ocms_mli_Utility.getLinkTarget(objLink.target) + '">'
                             +                      '<span class="accessible">[' + ((this.sArchiveSectionTitle != null) ? this.sArchiveSectionTitle : '') + ']:</span>'
                             +                      this.sArchiveSectionButton
                             +                  '</a>'
                             +              '</div>';
        }
        sArchiveMainHtml +=             '</div>'
                         +          '</div>'
                         +          '<div class="downloadArea">';
        if (this.sArchiveItemCategory != null) {
            sArchiveMainHtml +=             '<div class="category">'
                             +                  this.sArchiveItemCategory
                             +              '</div>';
        }
        if (this.sArchiveItemFile != null) {
            sArchiveMainHtml +=             '<div class="files"><div class="content">'
                             +                  this.sArchiveItemFile
                             +              '</div></div>';
        }
        sArchiveMainHtml +=         '</div>'
                         +      '</section>'
                         +  '</div>'
                         +  '<!-- <<< ocms_mli_ArchiveMain.getHTML(...) -->';
        return sArchiveMainHtml;

    }
}