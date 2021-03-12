global with sharing class ocms_mfc_Boxquotes extends cms.ContentTemplateController {
	
	public ocms_mfc_Boxquotes() { super(); }

	global ocms_mfc_Boxquotes(cms.GenerateContent gc) { super(gc); }

	public override String getHTML() {
		return '<blockquote><p>"' + text + '"</p></blockquote>';
	}

	public String text {
		get { return getProperty('text'); }
	}
}