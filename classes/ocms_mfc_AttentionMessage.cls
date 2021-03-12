global with sharing class ocms_mfc_AttentionMessage extends cms.ContentTemplateController {
	
	public ocms_mfc_AttentionMessage() { super(); }

	global ocms_mfc_AttentionMessage(cms.GenerateContent gc) { super(gc); }

	public override String getHTML() {
		String html ='';
		html += '<div class="alert">';
		if (String.isNotBlank(text) && text != '{text}') {
			String result = text.replaceAll('<br/>', '\n').replaceAll('<br />', '\n');
			// Compile the pattern
			Pattern myPattern = pattern.compile('<.*?>');
			// Get your matcher instance
			Matcher myMatcher = myPattern.matcher(result);
			// Remove the tags
			result = myMatcher.replaceAll('');

    		html += '<span>'+ result +'</span>';
		}

		html += '</div>';

		return html;
	}

	public String text {
		get { return (getProperty('text') != null) ? getProperty('text') : '';}
	}
}