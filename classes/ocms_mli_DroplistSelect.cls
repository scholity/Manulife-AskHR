/**
 * Definition and markup generation for Manulife.com Droplist select box (C28A).
 *
 * @author  Saloni Mittal
 * @date    2015-May-19
 *
 */
global with sharing class ocms_mli_DroplistSelect extends cms.ContentTemplateController {

    // Constructor for the execute request
    global ocms_mli_DroplistSelect() {}

    // Constructor for the content editor VF page
    global ocms_mli_DroplistSelect(cms.GenerateContent gc) {
        super(gc);
    }

    // Constructor for generator
    global ocms_mli_DroplistSelect(cms.CreateContentController cc) {
        super(cc);
    }

    /**
     * @description  Used for droplist title
     */
    public String sDroplistTitle {
        get { return getProperty('sDroplistTitle'); }
    }

    /**
     * @description  Used for droplist accessible text
     */
    public String sDroplistAccessible {
        get { return getProperty('sDroplistAccessible'); }
    }

    /**
     * @description  Used for droplist json string
     */
    public String jsnDroplist {
        get { return getProperty('jsnDroplist'); }
    }

    /**
     * @description  Used for deserializing the droplist json string back into objects
     */
    private List<Droplist> lstDroplist {
        get {
            try {
                return (List<Droplist>)JSON.deserialize(jsnDroplist, List<Droplist>.class);
            }
            catch (Exception e) {
                return (new List<Droplist>{});
            }
        }
    }

    /**
     * @description  Used for droplist object to store deserialized json string content
     */
    public class Droplist {
        String sValue;
        String sLabel;
        public Droplist() {}
    }

    /**
     * @description  Generates mark-up for droplist select box.
     * @return  String  A string of mark-up used to generate the select box.
     */
    global override String getHTML() {

        String sDroplistHtml = '';

        sDroplistHtml += '<!-- >>> ocms_mli_DroplistSelect.getHTML(...) -->' // to fix any jQuery parsing issues, see: https://pl5.projectlocker.com/Stantive/PSTools/trac/wiki/gotcha/OCMSCachingMissingMarkup
                      +  '<div class="droplistContentBox" data-hw-module="module/ContentSelectGroup">'
                      +      '<div class="droplistTitleArea">'
                      +          '<h2 class="droplistTitle">' + ((this.sDroplistTitle != null) ? this.sDroplistTitle.escapeHtml4() : '') + '</h2>';
        if (!(lstDroplist.isEmpty())) {
            sDroplistHtml +=         '<div class="customSelect accessibleLink customSelectInverted" data-hw-module="module/SelectWithMenuAndCustomScrollbar" aria-label="'  + ((this.sDroplistAccessible != null) ? this.sDroplistAccessible.escapeHtml4() : '') + '">'
                          +              '<label class="accessible" for="droplistSelect">' + ((this.sDroplistAccessible != null) ? this.sDroplistAccessible.escapeHtml4() : '') + '</label>'
                          +               buildDroplist()
                          +          '</div>';
        }
        sDroplistHtml +=     '</div>'
                      +  '</div>'
                      +  '<!-- <<< ocms_mli_DroplistSelect.getHTML(...) -->';
        return sDroplistHtml;
    }

    /**
     * @description  Generates mark-up for select box.
     * @return  String  A string of mark-up used to generate the select box.
     */
    private String buildDroplist() {
        String html = '<select id="droplistSelect" >';
        for (Droplist deserializedDroplist : lstDroplist) {
            html += '<option value="';
            if (deserializedDroplist.sValue == '') {
                html += '';
            } else {
                html += String.valueof(Integer.valueOf(deserializedDroplist.sValue) - 1);
            }
            html += '">' + deserializedDroplist.sLabel;
            html += '</option>';
       }
       html += '</select>';
       return html;
    }
}