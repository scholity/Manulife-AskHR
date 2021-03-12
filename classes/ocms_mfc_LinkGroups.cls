global with sharing class ocms_mfc_LinkGroups extends cms.ContentTemplateController {
	
	public ocms_mfc_LinkGroups() { super(); }

	global ocms_mfc_LinkGroups(cms.GenerateContent gc) { super(gc); }

	public override String getHTML() {
		String html ='';

		html += '<div class="link-block">';

		System.debug(thumbnail);
		if (String.isNotBlank(thumbnail)) {
		    html += 		'<div class="link-thumb">';
			html += 			'<img src="'+ thumbnail +'" alt="">';
		    html += 		'</div>';
		    html += 		'<div class="link-info">';
		} else {
			html += 		'<div class="link-info" style="margin-left:0px">';	
		}

		System.debug(title);
	    if (String.isNotBlank(title)) {
	    	html += '<h3 class="link-title">'+ title +'</h3>';
	    }

	    html += 	'<ul class="link-list">';

		System.debug(linkText1);
		System.debug(link1);
		System.debug(link1.link);
	    if (String.isNotBlank(linkText1) && link1.link != null) {
	    	html += '<li>' + link1.render(linkText1) + '</a></li>';
	    }

	    if (String.isNotBlank(linkText2) && link2.link != null) {
	    	html += '<li>' + link2.render(linkText2) + '</a></li>';
	    }

	    if (String.isNotBlank(linkText3) && link3.link != null) {
	    	html += '<li>' + link3.render(linkText3) + '</a></li>';
	    }

	    if (String.isNotBlank(linkText4) && link4.link != null) {
	    	html += '<li>' + link4.render(linkText4) + '</a></li>';
	    }

	    if (String.isNotBlank(linkText5) && link5.link != null) {
	    	html += '<li>' + link5.render(linkText5) + '</a></li>';
	    }

	    if (String.isNotBlank(linkText6) && link6.link != null) {
	    	html += '<li>' + link6.render(linkText6) + '</a></li>';
	    }

	    if (String.isNotBlank(linkText7) && link7.link != null) {
	    	html += '<li>' + link7.render(linkText7) + '</a></li>';
	    }

	    if (String.isNotBlank(linkText8) && link8.link != null) {
	    	html += '<li>' + link8.render(linkText8) + '</a></li>';
	    }

	    if (String.isNotBlank(linkText9) && link9.link != null) {
	    	html += '<li>' + link9.render(linkText9) + '</a></li>';
	    }

	    if (String.isNotBlank(linkText10) && link10.link != null) {
	    	html += '<li>' + link10.render(linkText10) + '</a></li>';
	    }

	    html += 		'</ul>';
	    html += 		'</div>';
		html += '</div>';

		return html;
	}

	public String thumbnail {
		get { return (getProperty('thumbnail') != null) ? getProperty('thumbnail') : ''; }
	}

	public String title {
		get { return (getProperty('title') != null) ? getProperty('title') : ''; }
	}

	public String linkText1 {
		get { return (getProperty('linkText1') != null) ? getProperty('linkText1') : ''; }
	}

	public String linkText2 {
		get { return (getProperty('linkText2') != null) ? getProperty('linkText2') : ''; }
	}

	public String linkText3 {
		get { return (getProperty('linkText3') != null) ? getProperty('linkText3') : ''; }
	}

	public String linkText4 {
		get { return (getProperty('linkText4') != null) ? getProperty('linkText4') : ''; }
	}

	public String linkText5 {
		get { return (getProperty('linkText5') != null) ? getProperty('linkText5') : ''; }
	}

	public String linkText6 {
		get { return (getProperty('linkText6') != null) ? getProperty('linkText6') : ''; }
	}

	public String linkText7 {
		get { return (getProperty('linkText7') != null) ? getProperty('linkText7') : ''; }
	}

	public String linkText8 {
		get { return (getProperty('linkText8') != null) ? getProperty('linkText8') : ''; }
	}

	public String linkText9 {
		get { return (getProperty('linkText9') != null) ? getProperty('linkText9') : ''; }
	}

	public String linkText10 {
		get { return (getProperty('linkText10') != null) ? getProperty('linkText10') : ''; }
	}

	public cms.Link link1 {
		get {
			return new cms.Link(getProperty('link1'));
		}
	}

	public cms.Link link2 {
		get {
			return new cms.Link(getProperty('link2'));
		}
	}

	public cms.Link link3 {
		get {
			return new cms.Link(getProperty('link3'));
		}
	}

	public cms.Link link4 {
		get {
			return new cms.Link(getProperty('link4'));
		}
	}

	public cms.Link link5 {
		get {
			return new cms.Link(getProperty('link5'));
		}
	}

	public cms.Link link6 {
		get {
			return new cms.Link(getProperty('link6'));
		}
	}

	public cms.Link link7 {
		get {
			return new cms.Link(getProperty('link7'));
		}
	}

	public cms.Link link8 {
		get {
			return new cms.Link(getProperty('link8'));
		}
	}

	public cms.Link link9 {
		get {
			return new cms.Link(getProperty('link9'));
		}
	}

	public cms.Link link10 {
		get {
			return new cms.Link(getProperty('link10'));
		}
	}
}