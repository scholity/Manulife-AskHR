global with sharing class ocms_mfc_Clear extends cms.ContentTemplateController {
	
	public ocms_mfc_Clear() { super(); }

	global ocms_mfc_Clear(cms.GenerateContent gc) { super(gc); }

	public override String getHTML() {
		return '<div class="clear"></div>';
	}
}