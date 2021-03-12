/**
 * Definition and markup generation for Manulife.com (C3) Table Content
 *
 * @author    Jialin Guo
 * @date    2015-June-19
 *
 *    2015-June-23    Jialin Guo
 *        Class created
 *
 */

global virtual with sharing class ocms_mli_Table extends cms.ContentTemplateController{

    private final cms.CreateContentController CCC; // convenience reference to the CreateContentController instance use when Editing content
    private final cms.GenerateContent GC; // convenience reference to the GenerateContent instance used when rendering or ajax end point?
    private final Map<String, String> oPageParametersMap; // will hold `ApexPages.currentPage().getParameters()`

    // Default constructor invoked through `executeRequest` (where AJAX parameters become POST/GET page parameters) or
    // in OrchestraCMS cache generation
    // NOTE: if your content is cachable you must ensure that `getHTML` has dependecny on `ApexPages` (POST/GET parameters, cookies, etc)
    public ocms_mli_Table() { /* no need the `Layout` in the name word as we are extending ContentTemplateController */
        this.oPageParametersMap = ApexPages.currentPage() != null ?  ApexPages.currentPage().getParameters() : new Map<String,String>{};
                                  // during cache generation `ApexPages.currentPage()` is null so we fallback to empty map.
    }

    global ocms_mli_Table (cms.GenerateContent gc) {
        super(gc);
        this.oPageParametersMap = ApexPages.currentPage().getParameters();
    }

    global ocms_mli_Table(cms.CreateContentController cc) {
        super(cc);
        this.oPageParametersMap = ApexPages.currentPage().getParameters();
    }

    global virtual override String getHTML() { // For generated markup
    	String sHTML = '';

    	sHTML += '<div class="genericContentContainer">';
    	sHTML += 	'<div class="basicTable">';
        if (this.sMobileInstructionText != null) {
    	   sHTML +=     '<p class="instruction mobileOnly">' + this.sMobileInstructionText + '</p>';
        }
    	sHTML += 		'<div class="basicTableContainer">';
        if (this.sTableDetail != null) {
    	   sHTML += 			'<div class="tableContent">';
    	   sHTML += 				this.sTableDetail;
    	   sHTML += 			'</div>';
        }
        if (this.sNoteText != null) {
    	   sHTML += 			'<div class="note">';
    	   sHTML += 				'<p>';
    	   sHTML += 					this.sNoteText;
    	   sHTML += 				'</p>';
		   sHTML += 			'</div>';
        }
    	sHTML += 		'</div>';
    	sHTML += 	'</div>';
    	sHTML += '</div>';
    	return sHTML;
    }

    public String sMobileInstructionText {
        get {
            return getProperty('sMobileInstructionText');
        }
        set;
    }

    public String sTableDetail {
        get {
            return getProperty('sTableDetail');
        }
        set;
    }

    public String sNoteText {
        get {
            return getProperty('sNoteText');
        }
        set;
    }
}