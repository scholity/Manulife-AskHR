global with sharing class ocms_mfc_AppSummary extends ocms_mfc_App { 

    global ocms_mfc_AppSummary() { }

    // constructor for generator
    global ocms_mfc_AppSummary(cms.GenerateContent gc) {
         super(gc);
    }   

	global override String getHTML() {
        String summaryHTML =  '';
        // IMPORTANT: changing the markup here might break calls to `contentHashes.add` in `ocms_mfc_App.cls`. 
        summaryHTML += '<a class="global-app ocmsCI {mobileSize} {tabletSize} {desktopSize}" data-coid="' + versionOriginId + '" data-nDisplayPriority="' + this.iDisplayPriority + '" href="' + link.targetPage + '"';

        if (link.target == '_blank') {
            summaryHTML += ' target="_blank"';
        } else if (String.isNotEmpty(link.javascript)) {
            summaryHTML += ' onclick="' + link.javascript.escapeHtml4() + '"';
        }

        String categoryMarkup = '';

        if (!categories.isEmpty()) {        
            for (String categoryName : categories.get(content.Id)) {
                 categoryMarkup += ', ' + categoryName;
            }
        }

        summaryHTML +=      '>';
        summaryHTML +=      '<div class="icon">';
        summaryHTML +=          '<img src="' + getSiteURLForMedia(imageIcon) + '" alt=""/>'; 
        summaryHTML +=      '</div>'; 
        summaryHTML +=      '<span class="name">' + title + '</span>';
        summaryHTML +=      '<span class="category">' + categoryMarkup.replaceFirst(', ', '') + '</span>';
        summaryHTML +=      '<span class="description"></span>';
        summaryHTML +=      '<div class="clear"></div>';
        summaryHTML +=  '</a>';

        return summaryHTML; 
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
}