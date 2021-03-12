/**
 * Definition and markup generation for Manulife.com Archive Secondary content (C19B).
 *
 * @author  Saloni Mittal
 * @date    2015-June-24
 *
 */
global with sharing class ocms_mli_ArchiveSecondary extends cms.ContentTemplateController {

    // Constructor for the execute request
    global ocms_mli_ArchiveSecondary() {}

    // Constructor for the content editor VF page
    global ocms_mli_ArchiveSecondary(cms.GenerateContent gc) {
        super(gc);
    }

    // Constructor for generator
    global ocms_mli_ArchiveSecondary(cms.CreateContentController cc) {
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
     * @description  Used for Archive item file.
     */
    public String sArchiveItemFile {
        get {
            return getProperty('sArchiveItemFile');
        }
        set;
    }

    /**
     * @description  Used for Archive item body.
     */
    public String sArchiveSectionBody1 {
        get {
            return getProperty('sArchiveSectionBody1');
        }
        set;
    }

    /**
     * @description  Used for Archive section button label.
     */
    public String sArchiveSectionButton1 {
        get {
            return getProperty('sArchiveSectionButton1');
        }
        set;
    }

    /**
     * @description  Used for Archive section button link.
     */
    public String sArchiveSectionButtonLink1 {
        get {
            return getProperty('sArchiveSectionButtonLink1');
        } set;
    }

    private cms.Link objLink1 {
        get { return new cms.Link(sArchiveSectionButtonLink1); }
    }

    /**
     * @description  Used for Archive item file.
     */
    public String sArchiveItemFile1 {
        get {
            return getProperty('sArchiveItemFile1');
        }
        set;
    }

    /**
     * @description  Generates mark-up for archive main content.
     * @return  String  A string of mark-up used to generate the content.
     */
    global override String getHTML() {

        String sArchiveSecondaryHtml = '';

        sArchiveSecondaryHtml += '<!-- >>> ocms_mli_ArchiveSecondary.getHTML(...) -->' // to fix any jQuery parsing issues, see: https://pl5.projectlocker.com/Stantive/PSTools/trac/wiki/gotcha/OCMSCachingMissingMarkup
                              +  '<div class="genericContentContainer">'
                              +      '<div class="genericIconTitle genericIconTitleAlt">'
                              +          '<h3 class="title';
        if (this.sArchiveSectionIcon == null) {
            sArchiveSecondaryHtml +=         ' genericIconTitle__title--noIcon';
        }
        sArchiveSecondaryHtml +=         '">';
        if (this.sArchiveSectionIcon != null) {
            sArchiveSecondaryHtml +=         '<span class="image-icon">'
                                  +              '<img src="' + this.sArchiveSectionIcon + '" alt="' + ((this.sArchiveSectionTitle != null) ? this.sArchiveSectionTitle : '') + '">'
                                  +          '</span>';
        }
        sArchiveSecondaryHtml +=             '<span class="text">' + ((this.sArchiveSectionTitle != null) ? this.sArchiveSectionTitle : '') + '</span>'
                              +          '</h3>'
                              +      '</div>'
                              +      '<section class="archiveSecondary">'
                              +          '<div class="archiveItem">'
                              +              '<div class="description">'
                              +                  '<div class="content">'
                              +                      ((this.sArchiveSectionBody != null) ? this.sArchiveSectionBody : '');
        if (this.sArchiveSectionButton != null && objLink.targetPage != null) {
            sArchiveSecondaryHtml +=                 '<ul><li>'
                                  +                      '<a onclick=\'' + ocms_mli_Utility.getLinkScript(objLink.javascript) + '\' href="' + ocms_mli_Utility.getLinkHref(objLink.targetPage) + '" target="' + ocms_mli_Utility.getLinkTarget(objLink.target) + '">'
                                  +                          '<span class="accessible">[' + ((this.sArchiveSectionTitle != null) ? this.sArchiveSectionTitle : '') + ']:</span>'
                                  +                          this.sArchiveSectionButton
                                  +                      '</a>'
                                  +                  '</li></ul>';
        }
        sArchiveSecondaryHtml +=                 '</div>'
                              +              '</div>';
        if (this.sArchiveItemFile != null) {
            sArchiveSecondaryHtml +=             '<div class="files"><div class="content">'
                                  +                  this.sArchiveItemFile
                                  +              '</div></div>';
        }
        sArchiveSecondaryHtml +=         '</div>'
                              +          '<div class="archiveItem">'
                              +              '<div class="description">'
                              +                  '<div class="content">'
                              +                      ((this.sArchiveSectionBody1 != null) ? this.sArchiveSectionBody1 : '');
        if (this.sArchiveSectionButton1 != null && objLink1.targetPage != null) {
            sArchiveSecondaryHtml +=                 '<ul><li>'
                                  +                      '<a onclick=\'' + ocms_mli_Utility.getLinkScript(objLink1.javascript) + '\' href="' + ocms_mli_Utility.getLinkHref(objLink1.targetPage) + '" target="' + ocms_mli_Utility.getLinkTarget(objLink.target) + '">'
                                  +                          '<span class="accessible">[' + this.sArchiveSectionTitle + ']:</span>'
                                  +                          this.sArchiveSectionButton1
                                  +                      '</a>'
                                  +                  '</li></ul>';
        }
        sArchiveSecondaryHtml +=                 '</div>'
                              +              '</div>';
        if (this.sArchiveItemFile1 != null) {
            sArchiveSecondaryHtml +=             '<div class="files"><div class="content">'
                                  +                  this.sArchiveItemFile1
                                  +              '</div></div>';
        }
        sArchiveSecondaryHtml +=         '</div>'
                              +      '</section>'
                              +  '</div>'
                              +  '<!-- <<< ocms_mli_ArchiveSecondary.getHTML(...) -->';
        return sArchiveSecondaryHtml;

    }
}