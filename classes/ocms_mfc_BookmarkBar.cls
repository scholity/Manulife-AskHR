global with sharing class ocms_mfc_BookmarkBar extends ocms_ps_Content {
	
	public ocms_mfc_BookmarkBar() { super(); }

	global ocms_mfc_BookmarkBar(cms.GenerateContent gc) { super(gc); }

	public override String getHTML() {
		String html = '';

		if (hasBookmark) {
			html += '<div id="bookmark-bar" class="ocmsCI" data-pid="">';
		} else {
			html += '<div id="bookmark-bar" class="ocmsCI no-bookmark" data-pid="">';
		}	
		
		html += 	'<div class="align-right">';

		if (hasLike) {
			html += '<a class="like" href="#"><span class="likeCount">0</span></a>';
		}

		if (hasShare) {
			Map<String, String> paramMap = new Map<String, String>();
			if (content != null) {
				paramMap.put('content_Id', content.Id);
			} else {
				paramMap.put('content_Id', 'NOID');
			}
			html +='<a class="share" href="mailto:?subject='+ sitePreferences.get('shareEmailSubject') +'&amp;body={urlPlaceholder}" >'+ sitePreferences.get('uiLabelShare') +'</a>';
		}

		html +=     '</div>';
		html +=     '<div class="clear"></div>';
		html += '</div>';

	    return html;
	}

    public Boolean hasBookmark {
    	get { return (getProperty('bookmark') != null) ? Boolean.valueOf(getProperty('bookmark')) : false; }
    }

    public Boolean hasLike {
    	get { return (getProperty('like') != null) ? Boolean.valueOf(getProperty('like')) : false; }
    }

    public Boolean hasShare {
    	get { return (getProperty('share') != null) ? Boolean.valueOf(getProperty('share')) : false; }
    }
}