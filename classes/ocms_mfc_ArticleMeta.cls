global virtual without sharing class ocms_mfc_ArticleMeta extends ocms_ps_Content {
	    // Constructor for the execute request
    global ocms_mfc_ArticleMeta() { }

    // Constructor for the content editor VF page
    global ocms_mfc_ArticleMeta(cms.CreateContentController cc) {
        super(cc);
    }

    // constructor for generator
    global ocms_mfc_ArticleMeta(cms.GenerateContent gc) {
         super(gc);
    } 
    
    // Allows the get HTML to be overriten for different templates.
    global virtual override String getHTML() { 
    	String html = '';

    	List<cms__Page_Content_Layout_Instance__c> pcli = [SELECT cms__Page__c, cms__Page__r.cms__Published_Start_Date__c FROM cms__Page_Content_Layout_Instance__c WHERE Id = :page_content_layout_instance.Id];
    	System.debug(pcli);

    	if (!pcli.isEmpty()) {
    		String pageId = pcli[0].cms__Page__c;
  
    		if (pageId != null && String.isNotBlank(pageId)) {
    			// Load Adobe analytics object
    			html += '<div class="articleMeta" style="display:none">';
    			html += 	'<span class="articleAuthor">' + articleAuthor + '</span>';	
    			html += 	'<span class="articleId">' + pageId + '</span>';	
    			html += 	'<span class="articleTitle">' + articleTitle + '</span>';
    			html += 	'<span class="articleDate">' + pcli[0].cms__Page__r.cms__Published_Start_Date__c + '</span>';
    			html += '</div>';
    		} else {
    			System.debug('Error getting page reference for analytics.');
    		}
    	} else {
    		System.debug('Error getting page reference for analytics.');
    	}

        return html;
    }

    public String articleAuthor { 
    	get {
    		return (String.isBlank(getProperty('articleAuthor')) ? '' : getProperty('articleAuthor'));
    	}
    	set;
    }

    public String articleTitle { 
    	get {
    		return (String.isBlank(getProperty('articleTitle')) ? '' : getProperty('articleTitle'));
    	}
    	set;
    }
}