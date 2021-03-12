global with sharing class ocms_mfc_LocationContent extends cms.ContentTemplateController {
	
	public ocms_mfc_LocationContent() { super(); }

	global ocms_mfc_LocationContent(cms.GenerateContent gc) { super(gc); }

	public override String getHTML() {
		String html = '';

		html += '<li class="result-location" id="{contentId}">';

		html += 	'<div class="t">';
		if (String.isNotBlank(locationname)) {
			html += '<h3><a href="'+ locationlink.targetPage + '">' + locationname + '</a></h3>';
		}

		if (String.isNotBlank(description) && description != '{description}') {
			String result = description.replaceAll('<br/>', '\n').replaceAll('<br />', '\n');

			// compile the pattern     
			Pattern myPattern = pattern.compile('<.*?>');
			// get your matcher instance
			Matcher myMatcher = myPattern.matcher(result);
			//remove the tags     
			result = myMatcher.replaceAll('');
			html += 	'<p>'+ result +'</p>';
		}

		html += 		'<ul>';
		
		if (String.isNotBlank(phone)) {
			html += 		'<li class="phone">'+ phone +'</li>';
		}

		if (String.isNotBlank(email)) {
			html += 		'<li class="email"><a href="mailto:'+ email +'">'+ email +'</a></li>';
		}

		html += 		'</ul>';
		html += 	'</div>';
		html += 	'<div class="b">';

		if (String.isNotBlank(floorplantext) && floorplanlink.link != null) {
			html += 	'<a href="'+ floorplanlink.targetPage +'" class="floorplan">'+ floorplantext +'</a>';
		}

		if (String.isNotBlank(additionallinktext) && additionallink.link != null) {
			html += 	'<a href="'+ additionallink.targetPage +'" class="menu">'+ additionallinktext +'</a>';
		}

		html += 	'</div>';

		if (String.isNotBlank(image)) {
			html += 	'<div class="img"><img src="'+ image +'" alt=""></div>';
		}

		html += '</li>';

		return html;
	}

	public String additionallinktext {
		get { return (getProperty('additionallinktext') != null) ? getProperty('additionallinktext') : '';}
	}

	public String description {
		get { return (getProperty('description') != null) ? getProperty('description') : '';}
	}

	public String email {
		get { return (getProperty('email') != null) ? getProperty('email') : '';}
	}

	public String floorplantext {
		get { return (getProperty('floorplantext') != null) ? getProperty('floorplantext') : '';}
	}

	public String image {
		get { return (getProperty('image') != null) ? getProperty('image') : '';}
	}

	public String locationname {
		get { return (getProperty('locationname') != null) ? getProperty('locationname') : '';}
	}

	public String phone {
		get { return (getProperty('phone') != null) ? getProperty('phone') : '';}
	}

	public cms.Link floorplanlink {
		get {
			return new cms.Link(getProperty('floorplanlink'));
		}
	}
	public cms.Link locationlink {
		get {
			return new cms.Link(getProperty('locationlink'));
		}
	}
	public cms.Link additionallink {
		get {
			return new cms.Link(getProperty('additionallink'));
		}
	}
}