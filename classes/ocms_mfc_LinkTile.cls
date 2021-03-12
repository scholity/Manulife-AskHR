global virtual with sharing class ocms_mfc_LinkTile extends ocms_ps_Content {
	
	global ocms_mfc_LinkTile() {}

	global ocms_mfc_LinkTile (cms.GenerateContent gc) { super(gc); }

	global ocms_mfc_LinkTile (cms.CreateContentController cc) { super(cc); }

	public System.Type getType() { return ocms_mfc_LinkTile.class; }

	global override virtual String getHTML() { 
		String html = '';
		html += '<div id="cboxContent">';
		html += '	<div id="cboxLoadedContent" >';
		if (linkImage != null) {
			html += '		<img class="cboxPhoto" src="'+ linkImage +'" />';
		}
		html += '	</div>';
		if (linkText != null) {
			html += '	<div id="cboxTitle">'+ linkText +'</div>';
		}
		if (link.targetPage != null) {
			html += '	<a class="linkOverlay" href="'+ link.targetPage +'"></a>';
		}
		html += '</div>';

		return html;	
	}

	public String linkImage {
		get {
			return getProperty('linkImage');
		}
	}

	public String linkText {
		get {
			return getProperty('linkText');
		}
	}

	public String linkAsData {
		get {
			return this.getProperty('link');
		} set;
	}

	public cms.Link link {
		get {
			return new cms.Link(linkAsData);
		}
	}


}