global with sharing class ocms_mfc_BannerImage extends cms.ContentTemplateController {
	
	public ocms_mfc_BannerImage() { super(); }

	global ocms_mfc_BannerImage(cms.GenerateContent gc) { super(gc); }

	public override String getHTML() {
		String html = '<div class="article-banner" id="' + content.Id + '">';
		
		html += 	'<div class="img-wrapper">';
		html += 		'<img src="' + ctcBanImg + '" alt="" />';
		html +=		'</div>';
		html +=	'</div>';
		html += '<script>';
		html +=	'var $bannerImage = $("#' + content.Id + ' img");';
		html +=	'$(document).ocmsDynamicLoadFinished(function _bannerRemoveNoImage() {';
		html +=		'if ($bannerImage.attr("src").indexOf("ctcBanImg") >= 0 ) {';
		html +=	   		'$bannerImage.remove();';
		html +=	 	'}';
		html +=	 '});';
		html += '</script>';

		return html;
	}

	public String ctcBanImg {
		get { return getProperty('ctcBanImg'); }
	}
}