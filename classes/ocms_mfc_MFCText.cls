global with sharing class ocms_mfc_MFCText extends cms.ContentTemplateController {
	
	public ocms_mfc_MFCText() { super(); }

	global ocms_mfc_MFCText(cms.GenerateContent gc) { super(gc); }

	public override String getHTML() {
		return text;
	}

	public String text {
		get { return getProperty('text'); }
	}
}