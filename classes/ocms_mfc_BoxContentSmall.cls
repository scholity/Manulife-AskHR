global with sharing class ocms_mfc_BoxContentSmall extends cms.ContentTemplateController {
	
	public ocms_mfc_BoxContentSmall() { super(); }

	global ocms_mfc_BoxContentSmall(cms.GenerateContent gc) { super(gc); }

	public override String getHTML() {
		return '<div class="boxquote-s">' + text + '</div>';
	}

	public String text {
		get { return getProperty('text'); }
	}
}