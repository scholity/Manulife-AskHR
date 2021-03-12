global with sharing class ocms_mfc_Listing extends cms.ContentTemplateController {
	
	public ocms_mfc_Listing() { super(); }

	global ocms_mfc_Listing(cms.GenerateContent gc) { super(gc); }

	public override String getHTML() {
		String html = '';
		String sTitle = title == null ? '' : title;
		if (!Test.isRunningTest()) {
			html += '<div class="listing ctListing ocmsCI" data-coid="'+ versionOriginId +'" >';
		}

		html += 	'<div class="list-wrapper">';
		html += 		'<div class="inner">';

		if (String.isNotBlank(thumbnail)) {
			html += 		'<div class="img-wrapper">';
			html += 			'<img src="' + thumbnail + '" alt="">';
			html += 		'</div>';
		}

		html += 			'<div class="gradient-overlay"></div>';
		html += 			'<div class="info-wrapper">';
		html += 				'<div class="info-header">';
		
		if (String.isNotBlank(title)) {
			html += 				'<h3 class="ellipsis-2">' + title + '</h3>';
		}

		html += 				'</div>';
		html += 				'<div class="desc">';
		html += 					'<div>';

		if (String.isNotBlank(text)) {
			String result = text.replaceAll('<br/>', '\n').replaceAll('<br />', '\n');
			// compile the pattern     
			Pattern myPattern = pattern.compile('<.*?>');
			// get your matcher instance
			Matcher myMatcher = myPattern.matcher(result);
			// remove the tags     
			result = myMatcher.replaceAll('');

			html += '<p class="ellipsis-4">'+ result +'</p>';
		}

		html += 					'</div>';
		html += 				'</div>';
		html += 			'</div>';

		if (link.link != null) {
			html += 		'<a class="link-overlay has-hover" href="'+ link.targetPage +'"></a>';
		}
 
 		if (Boolean.valueOf(showLike) ||  Boolean.valueOf(showShare)) {
			html += 			'<div class="share-wrapper">';

			if (Boolean.valueOf(showLike)) {
				html += 			'<a class="like" href="#"></a>';
			}

			if (Boolean.valueOf(showShare) == true && link.link != null && String.isNotBlank(sTitle)) {
				sTitle=sTitle.escapeHtml4().replace('%26','&amp;');
				sTitle=sTitle.escapeHtml4().replace('%','%25').replace('&quot;','%22').replace(',','%2C').replace('&#94;','%5E').replace('&amp;#39;','%27').replace('&amp;','%26').replace('%26amp;','%26');
				sTitle=sTitle.escapeHtml4().replace('&#33;','%21').replace('&#36;','%24').replace('&#37;','%25').replace('&middot;','%B7').replace('(','%28').replace('`','%60').replace('%26rsquo;','’').replace('%26lsquo;','‘').replace('%26acute;','´').replace('middot;','·').replace('%26ldquo;','“');
				sTitle=sTitle.escapeHtml4().replace(')','%29').replace('*','%2A').replace('+','%2B').replace('-','%2D').replace('.','%2E').replace('@','%40').replace('#','%23').replace('^','%5E').replace('%26lt;','%3C').replace('%26gt;','%3E');
				if (link.linkType == 'Internal') {
					html +=			'<a class="share" href="mailto:?subject='+ sitePreferences.get('shareEmailSubject') +'&amp;body='+ sTitle +' '+ '{urlPlaceholder}' + link.targetPage.escapeHtml4() +'" title="Share by Email" ></a>';
				} else {				
					html +=			'<a class="share" href="mailto:?subject='+ sitePreferences.get('shareEmailSubject') +'&amp;body='+ sTitle +' '+ link.targetPage.escapeHtml4() +'" title="Share by Email" ></a>';
				}
			}

			html += 			'</div>';
		}

		html += 		'</div>';
		html += 	'</div>';
		html += '</div>';

		return html;
	}

	public String versionOriginId {
		get {
			versionOriginId = content.Id;
			if (content.cms__Version_Origin__c != null) {
        		versionOriginId = content.cms__Version_Origin__c;
        	}
        	return versionOriginId;
		} set;
	}

	public Map<String, String> sitePreferences {
	    get {
	        if (sitePreferences == null) {
	            sitePreferences = ocms_mfc_SitePreferences.getSitePreferences(pm, getServiceAPI().getRenderLanguage());
	        }

	        return sitePreferences;
	    } set;
	}
	
    public String showLike {
    	get { return (getProperty('showLike') != null) ? getProperty('showLike') : '';}
    }

    public String showShare {
    	get { return (getProperty('showShare') != null) ? getProperty('showShare') : '';}
    }

    public String text {
    	get { return (getProperty('text') != null) ? getProperty('text') : '';}
    }

    public String thumbnail {
    	get { return (getProperty('thumbnail') != null) ? getProperty('thumbnail') : '';}
    }

    public String title {
    	get { return (getProperty('title') != null) ? getProperty('title') : '';}
    }

    public cms.Link link {
    	get { 
    		return new cms.Link(getProperty('link'));
    	}
    }
}