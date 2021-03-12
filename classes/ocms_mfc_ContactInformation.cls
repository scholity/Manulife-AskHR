global with sharing class ocms_mfc_ContactInformation extends cms.ContentTemplateController {
	
	public ocms_mfc_ContactInformation() { super();}

	global ocms_mfc_ContactInformation(cms.GenerateContent gc) { super(gc); }

	public override String getHTML() {
		String html = '<div class="contact-block">';
	
		if (String.isNotBlank(blocktitle)) {
			html += '<h4 class="subhead">'+ blocktitle +'</h4>';
		}

		if (String.isNotBlank(name1) || String.isNotBlank(title1) || 
			String.isNotBlank(phone1) || String.isNotBlank(email1)) {
			html += 	'<div class="contact-details">';
			html += 		'<div class="contact-info">';

			if (String.isNotBlank(name1)) {
				html += 			'<p class="contact-name">'+ name1 +'</p>';
			}

			if (String.isNotBlank(title1)) {
				html += 			'<p class="contact-title">'+ title1 +'</p>';
			}

			html += 		'</div>';
			html += 		'<div class="contact-wrapper">';

			if (String.isNotBlank(phone1)) {
				html += '<div class="contact-phone">'+ phone1 +'</div>';
			}

			if (String.isNotBlank(email1)) {
				html += '<div class="contact-email"><a href="mailto:'+ email1 +'">';

				if (String.isNotBlank(emailtitle1)) {
					html += emailtitle1 + '</a></div>';
				} else {
					html += email1 +'</a></div>';
				}

			}

			html += 		'</div>'; // contact-info
			html += 	'</div>'; // contact-details
		}

		if (String.isNotBlank(name2) || String.isNotBlank(title2) || 
			String.isNotBlank(phone2) || String.isNotBlank(email2)) {

			html += 	'<div class="contact-details">';
			html += 		'<div class="contact-info">';

			if (String.isNotBlank(name2)) {
				html += 			'<p class="contact-name">'+ name2 +'</p>';
			}

			if (String.isNotBlank(title2)) {
				html += 			'<p class="contact-title">'+ title2 +'</p>';
			}

			html += 		'</div>';
			html += 		'<div class="contact-wrapper">';

			if (String.isNotBlank(phone2)) {
				html += '<div class="contact-phone">'+ phone2 +'</div>';
			}

			if (String.isNotBlank(email2)) {
				html += '<div class="contact-email"><a href="mailto:'+ email2 +'">';

				if (String.isNotBlank(emailtitle2)) {
					html += emailtitle2 + '</a></div>';
				} else {
					html += email2 +'</a></div>';
				}
			}

			html += 		'</div>';
			html += 	'</div>';
		}

		if (String.isNotBlank(name3) || String.isNotBlank(title3) || 
			String.isNotBlank(phone3) || String.isNotBlank(email3)) {
			html += 	'<div class="contact-details">';
			html += 		'<div class="contact-info">';

			if (String.isNotBlank(name3)) {
				html += 			'<p class="contact-name">'+ name3 +'</p>';
			}

			if (String.isNotBlank(title3)) {
				html += 			'<p class="contact-title">'+ title3 +'</p>';
			}

			html += 		'</div>';
			html += 		'<div class="contact-wrapper">';

			if (String.isNotBlank(phone3)) {
				html += '<div class="contact-phone">'+ phone3 +'</div>';
			}

			if (String.isNotBlank(email3)) {
				html += '<div class="contact-email"><a href="mailto:'+ email3 +'">';

				if (String.isNotBlank(emailtitle3)) {
					html += emailtitle3 + '</a></div>';
				} else {
					html += email3 +'</a></div>';
				}
			}
			
			html += 		'</div>';
			html += 	'</div>';
		}

		html += '</div>';

	    return html;
	}
	
    public String blocktitle {
    	get { return (getProperty('blocktitle') != null) ? getProperty('blocktitle') : '';}
    }

    public String email1 {
    	get { return (getProperty('email1') != null) ? getProperty('email1') : '';}
    }

    public String email2 {
    	get { return (getProperty('email2') != null) ? getProperty('email2') : '';}
    }

    public String email3 {
    	get { return (getProperty('email3') != null) ? getProperty('email3') : '';}
    }

    public String emailtitle1 {
    	get { return (getProperty('emailtitle1') != null) ? getProperty('emailtitle1') : '';}
    }

    public String emailtitle2 {
    	get { return (getProperty('emailtitle2') != null) ? getProperty('emailtitle2') : '';}
    }

    public String emailtitle3 {
    	get { return (getProperty('emailtitle3') != null) ? getProperty('emailtitle3') : '';}
    }

    public String name1 {
    	get { return (getProperty('name1') != null) ? getProperty('name1') : '';}
    }

    public String name2 {
    	get { return (getProperty('name2') != null) ? getProperty('name2') : '';}
    }

    public String name3 {
    	get { return (getProperty('name3') != null) ? getProperty('name3') : '';}
    }

    public String phone1 {
    	get { return (getProperty('phone1') != null) ? getProperty('phone1') : '';}
    }

    public String phone2 {
    	get { return (getProperty('phone2') != null) ? getProperty('phone2') : '';}
    }

    public String phone3 {
    	get { return (getProperty('phone3') != null) ? getProperty('phone3') : '';}
    }

    public String title1 {
    	get { return (getProperty('title1') != null) ? getProperty('title1') : '';}
    }

    public String title2 {
    	get { return (getProperty('title2') != null) ? getProperty('title2') : '';}
    }

    public String title3 {
    	get { return (getProperty('title3') != null) ? getProperty('title3') : '';}
    }

}