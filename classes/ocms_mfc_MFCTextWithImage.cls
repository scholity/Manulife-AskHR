global with sharing class ocms_mfc_MFCTextWithImage extends cms.ContentTemplateController {
	
	public ocms_mfc_MFCTextWithImage() { super(); }

	global ocms_mfc_MFCTextWithImage(cms.GenerateContent gc) { super(gc); }

	public override String getHTML() {
		String html = '<div class="content-anchor">';

		html += 	'<div class="anchor-info">' + text + '</div>';
		html += 	'<div class="content-image">';
		html += 		'<div class="img-wrapper"><img src="' + image + '" alt=""></div>';
		html += 	'</div>';
		html += 	'<div class="clear"></div>';
		html += '</div>';

		return html;
	}

	public String text {
		get { return getProperty('text'); }
	}

	public String image {
		get { return getProperty('image'); }
	}
}