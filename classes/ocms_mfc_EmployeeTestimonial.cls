global with sharing class ocms_mfc_EmployeeTestimonial extends cms.ContentTemplateController {
	
	public ocms_mfc_EmployeeTestimonial() { super(); }

	global ocms_mfc_EmployeeTestimonial(cms.GenerateContent gc) { super(gc); }

	public override String getHTML() {
		String html = '<div class="feed-block employee-testimonial-tile">';
	    html += 	'<div class="feed-thumb">';
	    html += 		'<img src="' + image + '" alt="' + name + '" />';
	    html += 	'</div>';
	    html += 	'<div class="feed-info">';
		html += 		'<h3 class="feed-title ellipsis-2">' + name  + '</h3>';
		html += 		'<p class="feed-desc ellipsis-2">' + description + '</p>';
		html += 	'</div>';
		html += '</div>';

		return html;
	}

	public String image { 
		get { return (getProperty('image') != null) ? getProperty('image') : ''; }
	}

	public String name { 
		get { return (getProperty('name') != null) ? getProperty('name') : ''; }
	}

	public String description { 
		get { return (getProperty('description') != null) ? getProperty('description') : ''; }
	}
}