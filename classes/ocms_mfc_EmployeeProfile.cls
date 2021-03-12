global with sharing class ocms_mfc_EmployeeProfile extends cms.ContentTemplateController {
	
	public ocms_mfc_EmployeeProfile() { super(); }

	global ocms_mfc_EmployeeProfile(cms.GenerateContent gc) { super(gc); }

	public override String getHTML() {
		String html = '';

		html += '<div class = "related-block employee-profile-tile">';
		html += 	'<div class="related-thumb">';

		if (String.isNotEmpty(image)) {
			html += '<img src="'+ image +'" alt ="'+ name + '"/>';
		}

		html += 	'</div>';
		html += 	'<div class="related-info">';

		if (String.isNotBlank(name)) {
			System.debug(link);
			if (link.link != null) {
				link.setClasses('related-title');
				html += link.render(name);
			} else {
				html += '<p class="related-title">' + name + '</p>';
			}
		}

		if (String.isNotBlank(description) && description != '{description}') {
			String result = description.replaceAll('<br/>', '\n').replaceAll('<br />', '\n');
			// compile the pattern     
			Pattern myPattern = pattern.compile('<.*?>');
			// get your matcher instance
			Matcher myMatcher = myPattern.matcher(result);
			// remove the tags     
			result = myMatcher.replaceAll('');

			html += '<p class="related-desc ellipsis-2">'+ result +'</p>';
		}

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

	public cms.Link link {
		get {
			return new cms.Link(getProperty('link'));
		}
	}
}