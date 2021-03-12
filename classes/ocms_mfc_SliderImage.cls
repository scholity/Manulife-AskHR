global with sharing class ocms_mfc_SliderImage extends cms.ContentTemplateController {
	
	public ocms_mfc_SliderImage() { super(); }

	global ocms_mfc_SliderImage(cms.GenerateContent gc) { super(gc); }

	public override String getHTML() {	
		String html = '<a href="' + image + '" title="' + title + '" class="global-app mob-size-s tab-size-m dsk-size-m image-box cboxElement">';
	
		html += 	'<div class="icon">';
		html += 		'<img alt="' + altText + '" src="' + thumbnail +'">';
		html += 	'</div>';
		html += 	'<span class="name"></span>';
		html += 	'<span class="category"></span>';
		html += 	'<span class="description"></span>';
		html += 	'<div class="clear"></div>';
		html += '</a>';

		return html;
	}

	public String title {
		get { return getProperty('title'); }
	}

	public String thumbnail {
		get { return getProperty('thumbnail'); }
	}

	public String image {
		get { return getProperty('image'); }
	}

	public String altText {
		get { return getProperty('altText'); }
	}
}