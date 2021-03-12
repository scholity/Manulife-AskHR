global without sharing class ocms_mfc_ToolLibrary extends ocms_ps_Content {
	global ocms_mfc_ToolLibrary() { }

	global ocms_mfc_ToolLibrary(cms.CreateContentController cc) {
	    super(cc);
	}

	global ocms_mfc_ToolLibrary(cms.GenerateContent gc) {
	     super(gc);
	} 

	global override String getHTML() {
		String toolLibraryHTML = '';

		cms.ServiceAPI sApi = getServiceAPI();
        	ocms_mfc_Taxonomy mfcTaxonomy = new ocms_mfc_Taxonomy(sApi);
		String categoryPath = mfcTaxonomy.getAppCategories();

		List<String> categories = new List<String>();

        if (!Test.isRunningTest()) {
        	cms.TaxonomyNodeInfo categoryNode = ocms_mfc_Taxonomy.getTaxonomyNodeInfoAtPath(sApi, '/' + categoryPath.removeStart('/').removeEnd('/') + '/');
	        for (cms.TaxonomyNodeInfo childNode : categoryNode.getChildren()) {
	            categories.add(childNode.getName());
	        }
        } else {
        	categories = new List<String>{'Test Category 1', 'Test Category 2'};
        }

		toolLibraryHTML += '<div id="tool-library-content">';
		toolLibraryHTML +=      '<div class="tab-block">';
		toolLibraryHTML +=          '<div class="inner">';
		toolLibraryHTML +=              '<div class="global-content-tabs">';
		toolLibraryHTML +=                  '<a class="tab selected" href="#">' + myToolsHeader + '</a>';
		toolLibraryHTML +=                  '<a class="tab" href="#">' + allToolsHeader + '</a>';
                        toolLibraryHTML +=                  '<a class="tab" href="#">' + myBookmarksHeader + '</a>';
		toolLibraryHTML +=              '</div>';	
		toolLibraryHTML +=          '</div>';
		toolLibraryHTML +=      '</div>';
		toolLibraryHTML +=      '<div class="tab-content-container">';
                        toolLibraryHTML +=          '<div class="tab-content my-tools selected">';
                                        if (myToolsMessage != null){
                                            toolLibraryHTML +=          '<div class="tab-content-message my-tools-message">';
                                            toolLibraryHTML +=              myToolsMessage;
                                            toolLibraryHTML +=          '</div>';
                                        } 
                        toolLibraryHTML +=              '<div class="tools">';       
                        toolLibraryHTML +=              '</div>';
                        toolLibraryHTML +=          '</div>';        
		toolLibraryHTML +=          '<div class="tab-content all-tools">';
                        if (allToolsMessage != null){
                            toolLibraryHTML +=      '<div class="tab-content-message all-tools-message">';
                            toolLibraryHTML +=          allToolsMessage;
                            toolLibraryHTML +=      '</div>';
                        }
		toolLibraryHTML +=              '<div class="tools">';
		for (String categoryName : categories) {
			toolLibraryHTML +=          	'<div class="app-section category-' + categoryName.replace('&','').replace(' ', '') + '">';
			toolLibraryHTML +=          	    '<h2>' + categoryName + ' <a href=" ' + appendQueryStringsToSitePreferences('categoryDetail', new Map<String, String>{'category' => categoryName}) + '">' + viewGlobalText + '</a></h2>';
			toolLibraryHTML +=          	    '<div class="touch-slider">'; 
			toolLibraryHTML +=          	        '<div class="inner">';
			toolLibraryHTML +=          	        '</div>';
			toolLibraryHTML +=          	    '</div>';
			toolLibraryHTML +=          	'</div>';
		} 

		toolLibraryHTML +=              '</div>';
		toolLibraryHTML +=          '</div>';
		toolLibraryHTML +=          '<div class="tab-content bookmarks-tab">';
                        if (myBookmarksMessage != null){
                            toolLibraryHTML +=              '<div class="tab-content-message my-bookmarks-message">';
                            toolLibraryHTML +=                 myBookmarksMessage;
                            toolLibraryHTML +=              '</div>';
                        }        
		toolLibraryHTML +=              '<div class="bookmarks bookmarks-list bookmarks-loading">';	
		toolLibraryHTML +=              '</div>';		
		toolLibraryHTML +=          '</div>';		
		toolLibraryHTML +=      '</div>';
		toolLibraryHTML += '</div>';

		toolLibraryHTML += '<script>';
		toolLibraryHTML += '$(document).ready(function() {';
		toolLibraryHTML += 		'MFC.toolLibraryEditor = ' + editorLabels + ';';
		toolLibraryHTML += 		'MFC.fSetupToolLibrary();';
		toolLibraryHTML += '})';
		toolLibraryHTML += '</script>';

		return toolLibraryHTML;
	}

	private String editorLabels {
		get {
			Map<String, String> editorLabelsMap = new Map<String, String>();
			
			editorLabelsMap.put('allToolsHeader', allToolsHeader);
			editorLabelsMap.put('myToolsHeader', myToolsHeader);
			editorLabelsMap.put('removeButtonText', removeButtonText);
			editorLabelsMap.put('viewGlobalText', viewGlobalText);
			editorLabelsMap.put('myBookmarksHeader',myBookmarksHeader);
                                    editorLabelsMap.put('myBookmarksToolTip', myBookmarksToolTip);

			return JSON.serialize(editorLabelsMap);
		} set;
	}

	/**
	 * @description attribute allToolsHeader - required
	 */
	public String allToolsHeader {
		get {
			return getProperty('allToolsHeader');
		} set;
	}

	/**
	 * @description attribute myToolsHeader - required
	 */
	public String myToolsHeader {
		get {
			return getProperty('myToolsHeader');
		} set;
	}

	/**
	 * @description attribute removeButtonText - required
	 */
	public String removeButtonText {
		get {
			return getProperty('removeButtonText');
		} set;
	}

	/**
	 * @description attribute viewGlobalText - required
	 */
	public String viewGlobalText {
		get {
			return getProperty('viewGlobalText');
		} set;
	}

            /**
             * @description attribute myBookmarksHeader - required
             */
            public String myBookmarksHeader {
                get {
                    return getProperty('myBookmarksHeader');
                } set;
            }

            /**
             * @description attribute allToolsMessage 
             */
            public String allToolsMessage {
                get {
                    return getProperty('allToolsMessage');
                } set;
            }

            /**
             * @description attribute myToolsMessage
             */
            public String myToolsMessage {
                get {
                    return getProperty('myToolsMessage');
                } set;
            }

            /**
             * @description attribute myBookmarksMessage
             */
            public String myBookmarksMessage {
                get {
                    return getProperty('myBookmarksMessage');
                } set;
            }  

            /**
             * @description attribute myBookmarksToolTip
             */
            public String myBookmarksToolTip {
                get {
                    return getProperty('myBookmarksToolTip');
                } set;
            }                                             
}