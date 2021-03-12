global with sharing class ocms_mfc_AppDetail extends ocms_mfc_App {
	global ocms_mfc_AppDetail() { super(); }

	// constructor for generator
	global ocms_mfc_AppDetail(cms.GenerateContent gc) {
	     super(gc);
	}	

	public Map<String, List<String>> categories {
		get {
			if (categories == null) {
				cms.ServiceAPI sApi = getServiceAPI();
				ocms_TaxonomyAPI TaxonomyHelper = new ocms_TaxonomyAPI(sApi);
				ocms_mfc_Taxonomy mfcTaxonomy = new ocms_mfc_Taxonomy(sApi);

				categories = TaxonomyHelper.getTagsAtAncestryNode(content.Id, mfcTaxonomy.getAppCategories());
			}

			return categories;
		} set;
	}

	global override String getHTML() {
		String appDetailHTML = '';
		String linkItemHTML = '';

		appDetailHTML = '<div id="app-detail">';
		appDetailHTML +=     '<div class="inner">';
		appDetailHTML +=         '<div class="app-header">';
		appDetailHTML +=             '<div class="logo">';
		appDetailHTML +=                 '<img src="' + getSiteURLForMedia(imageIcon) + '" alt=""/>';
		appDetailHTML +=             '</div>';
		appDetailHTML +=             '<div class="app-title">';
		appDetailHTML +=                 '<h2>' + title + '</h2>';
		appDetailHTML +=                 '<p class="category">';

		String categoryMarkup = '';

		if (!categories.isEmpty()) {        
		    for (String categoryName : categories.get(content.Id)) {
		         categoryMarkup += '<br>' + categoryName;
		    }
		}

		appDetailHTML +=                categoryMarkup.removeStart('<br>');
		appDetailHTML +=                 '</p>';
		appDetailHTML +=             '</div>';
		appDetailHTML +=             '<div class="app-links">';

		linkItemHTML += '<a class="launch-app" data-coid="' + versionOriginId + '" href="' + link.targetPage + '"';

		if (link.target == '_blank') {
		    linkItemHTML += ' target="_blank"';
		} else if (String.isNotEmpty(link.javascript)) {
		    linkItemHTML += ' onclick="' + link.javascript.escapeHtml4() + '"';
		}

		linkItemHTML += '>';
		linkItemHTML += '{Launch App}<span class="launch"></span></a>';

		appDetailHTML +=                 linkItemHTML;
		appDetailHTML +=             '</div>';
		appDetailHTML +=             '<div class="app-desc">';
		appDetailHTML +=                 '<p>' + summary + '</p>';
		appDetailHTML +=             '</div>';
		appDetailHTML +=             '<div class="clear"></div>';
		appDetailHTML +=         '</div>';
		appDetailHTML +=         '<div class="app-body">';
		
		if (String.isNotBlank(tutorial) || String.isNotBlank(embedLink)) {
			appDetailHTML +=          '<h3>{Tutorial}</h3>';
		}
				
		if (String.isNotBlank(embedLink)) {		
			appDetailHTML +=             '<div class="video-wrapper">';
			appDetailHTML +=                 '<div class="inner">';
			appDetailHTML +=					embedLink;
			appDetailHTML +=                 '</div>';
			appDetailHTML +=             '</div>';
		}

		appDetailHTML +=             '<div class="app-desc">';
		appDetailHTML +=                 tutorial;
		appDetailHTML +=             '</div>';
		appDetailHTML +=         '</div>';
		appDetailHTML +=     '</div>';
		appDetailHTML += '</div>';

		appDetailHTML += '<script>';
		appDetailHTML += '$(document).ready(function() {';
		appDetailHTML +=      'MFC.app = {};';
		appDetailHTML +=      'MFC.app.addToLaunchpadLabel = "{Add to Launchpad}";';
		appDetailHTML +=      'MFC.app.subscribedLabel = "{Subscribed App}";';
		appDetailHTML +=      'MFC.fSetupAppDetail();';
		appDetailHTML += '})';
		appDetailHTML += '</script>';

		return appDetailHTML;
	}
}