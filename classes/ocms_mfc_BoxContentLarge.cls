global with sharing class ocms_mfc_BoxContentLarge extends cms.ContentTemplateController {
	
	public ocms_mfc_BoxContentLarge() { super(); }

	global ocms_mfc_BoxContentLarge(cms.GenerateContent gc) { super(gc); }

	public override String getHTML() {
		return '<div class="boxquote-l">' + text + '</div>';
	}

	public String text {
		get { return getProperty('text'); }
	}
}