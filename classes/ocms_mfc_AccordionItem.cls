global with sharing class ocms_mfc_AccordionItem extends cms.ContentTemplateController {
	
	public ocms_mfc_AccordionItem() { super(); }

	global ocms_mfc_AccordionItem(cms.GenerateContent gc) { super(gc); }

	public override String getHTML() {
		
		String html = '';
		if (this.bExpanded == true) {
			html += '<div class="accordion-group">';
			html += 	'<div class="accordion-tab open">';
			html += 		'<span>'+ this.sTitle +'</span><div class="arrow"></div>';
			html += 	'</div>';
			html += 	'<div class="accordion-content  default" style="display:block;" >';
			html += 		'<p>'+ this.sContent +'</p>';
			html += 	'</div>';
			html += '</div>';
		} else {
			html += '<div class="accordion-group">';
			html += 	'<div class="accordion-tab">';
			html += 		'<span>'+ this.sTitle +'</span><div class="arrow"></div>';
			html += 	'</div>';
			html += 	'<div class="accordion-content  default" style="display:none;" >';
			html += 		'<p>'+ this.sContent +'</p>';
			html += 	'</div>';
			html += '</div>';
		}

		return html;
	}

	public Boolean bExpanded {
		get { return (getProperty('expanded') != null && getProperty('expanded') == 'true') ? true : false; }
	}

	public String sTitle {
		get { return (getProperty('title') != null) ? getProperty('title') : ''; }
	}

	public String sContent {
		get { return (getProperty('content') != null) ? getProperty('content') : ''; }
	}
}