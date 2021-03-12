global with sharing class ocms_mfc_PollVote extends cms.ContentTemplateController implements cms.ServiceInterface {

	// Start of required methods and constructor

	global ocms_mfc_PollVote () {}

	global ocms_mfc_PollVote (cms.GenerateContent gc) {
		super(gc);
	}

	global ocms_mfc_PollVote (cms.CreateContentController cc) {
		super(cc);
		thisContentId = this.getOriginId();
	}

	public System.Type getType(){
		return ocms_mfc_PollVote.class;
	}

	global String executeRequest (Map <String, String> request) {
		requestParameters = request;

		/* We need to remove the empty string values from the map, the reason for this is the edit page (unlike the rendering page) fills in empty values
		 * This means that unless we remove the keys with empty values from the map, it goes into the showResults method, and checks if the option is null, which goes
		 * into the getter, which checks if the requestParameters map is null (which it isn't because we went through executeRequest) so the getter then returns the
		 * value corresponding to the option key in the requestParameters map, which is an empty string because the text field on the edit page sent it in that way
		 * and then what gets output is an empty string with the value "0" for votes. But if we remove this key from the map then the getter will check if requestParameters
		 * is null, find it isn't, and return the value corresponding to the key in the map, which is null because we have now removed the key from the map, whic means
		 * the showResults method will indeed return null and it will not output empty values for the results on the edit page
		 */
		for (String requestParameterKey : requestParameters.keySet()) {
			if (requestParameters.get(requestParameterKey).length () == 0)
				requestParameters.remove(requestParameterKey);
		}

		String response = '{"success": false}';

		if (request.get('action') == 'recordChoice') {
			if (request.get('choice') == null) {
				return response;
			}

			refresh = true;

			response = '{"success": true, "html": ' + json.serialize(recordChoice(request.get('poll'), request.get('choice'))) + '}';
		}

		if (request.get('action') == 'getResults') {
			if (request.get('title') == null) { // this is invoked when the edit page is first loaded on a brand new piece of content - we do not want to output null for title in this circumstance
				requestParameters.put('title', '');
			}
			response = '{"success": true, "results": ' + json.serialize(showResults(request.get('thisContentId'), true)) + '}';
		}
		return response;
	}

	private String recordChoice (String content, String choice) {
		RecordType pollRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'MFC_Community_Object__c' AND DeveloperName = 'Poll_Vote'];
		MFC_Community_Object__c pollVote = new MFC_Community_Object__c (User__c = UserInfo.getUserId(), Content__c = content, VoteIndex__c = choice, RecordTypeId = pollRecordType.Id);
		/* apex forces us to put our results into a list even when we only expect to receive 0 or 1 results -- 0 results does not actually return null, but rather an empty list */
		List <MFC_Community_Object__c> pollVotes = [SELECT Id FROM MFC_Community_Object__c WHERE User__c = :UserInfo.getUserId() AND Content__c = :content];

		if (!pollVotes.isEmpty()) { /* this user has already voted on this poll */
			//TODO: Add some kind of error here saying they have already voted? Or this might not be necessary as the front end will see they have voted and they can't vote again
			return showResults (content, false);
		}
		insert pollVote;

		return showResults (content, false);
	}

	// For generated markup
	global override String getHTML() {
		Id userId = UserInfo.getUserId();
		List <MFC_Community_Object__c> pollVotes = [SELECT Id FROM MFC_Community_Object__c WHERE User__c = :userId AND Content__c = :this.getOriginId()];
		if (!pollVotes.isEmpty()) { /* this user has already voted on this poll */
			String html = showResults (this.getOriginId(), false);
			return html;
		}

		return showPoll ();
	}

	private String showResults (String content, Boolean editPageContext) {
		/*Map to capture poll vote %*/
		Map <Integer, Integer> pollTotals = new Map <Integer, Integer> ();
		/*Map to capture poll vote count*/
		Map <Integer, Integer> pollCounts = new Map <Integer, Integer> ();
		for(Integer i=0;i<7;i++){
			pollTotals.put(i,0);
			pollCounts.put(i,0);
		}
		List <AggregateResult> results = [SELECT VoteIndex__c opt, COUNT(Id) cnt FROM MFC_Community_Object__c WHERE Content__c = :content GROUP BY ROLLUP(VoteIndex__c)];
		Integer total;
		Integer totalCount = 0;
		for (AggregateResult result : results) {
			if (result.get('opt') == null) {
				total = Integer.valueOf(result.get('cnt'));
				totalCount += Integer.valueOf(result.get('cnt'));
			}
		}
		for (AggregateResult result : results) {
			Double percentage = Double.valueOf(result.get('cnt')) / total * 100.0;
			pollTotals.put(Integer.valueOf(result.get('opt')), Math.round(percentage));
			pollCounts.put(Integer.valueOf(result.get('opt')), Integer.valueOf(result.get('cnt')));
		}
		/*System.debug('results are ' + results);
		System.debug('pollTotals are ' + pollTotals);
		System.debug('showVoteCount is ' + showVoteCount);*/

		String[] optionsArr = new String[]{option1,option2,option3,option4,option5,option6,option7};

		if (editPageContext == true) {
			String html = '<p style="font-weight:bold;">' + title + '</p><br/>';
			html += '<table>';
			for(Integer i=0;i<7;i++){
				html += optionsArr[i] != null ? '<tr><td>' + optionsArr[i] + '</td><td>' + pollTotals.get(i) + '% - ' + pollCounts.get(i) + ' votes</td></tr>' : '';
			}
			html += '</table>';
			html += '<table><tr><td></td></tr><tr><td>' + totalCount + ' participants in total</td></tr></table>';
			return html;
		}

		String html = refresh == true ? '' : '<div class="tile type-poll type-poll-result">';
		html += '<div class="inner">';
		html += 	'<div class="content">';
		html += 		'<div class="v-align">';
		html += 			'<div class="inner">';
		html += 				'<h3 class="title">' + title + '</h3>';
//		html += 				'<p class="description"></p>';
		html += 			'</div>'; // inner
		html += 		'</div>';
		html += 	'</div>'; // content
		html += 	'<div class="bg">';
		html += 		'<img src="" alt="">';
		html += 		'<div class="shadow">';
		html += 		'</div>'; // shadow
		html += 	'</div>'; // bg
		html += 	'<div class="news-category">';
		html += 		'Canadian News';
		html += 	'</div>';
		html += 	'<div class="news-share">';
		html += 		'<div class="inner">';
		html += 			'<div class="likes">';
		html += 				' likes';
		html += 			'</div>'; // likes
		html += 			'<span class="s-like">';
		html += 				'Like';
		html += 			'</span>';
		html += 			'<span class="s-share">';
		html += 				'Share';
		html += 			'</span>';
		html += 		'</div>'; // inner
		html += 	'</div>'; // news-share
		html += 	'<div class="link-footer">';
		html += 		'<a href="#">';
		html += 			'<i class="icon icon-external">';
		html += 				'External Link';
		html += 			'</i>';
		html += 		'</a>';
		html += 	'</div>'; // link-footer
		html += 	'<div class="social-icon icon-">';
		html += 	'</div>'; // social-icon icon
		html += 	'<div class="custom-html">';
		if(showVoteCount == 'checked'){
			for(Integer i=0;i<7;i++){
				html += optionsArr[i] != null ? '<div class="option"><div class="perc"><div class="v-align"><div class="inner">' + pollTotals.get(i) + '% - ' + pollCounts.get(i) + ' votes' + '</div></div></div><div style="margin-left: 70px; min-height: 19px; padding-top: 3px">' + optionsArr[i] + '</div></div>' : '';
			}
			html += '<div style="margin-left: 15px;color: #fff;font-size: 120%;font-family: sans-serif ">' + totalCount + ' participants in total</div>';
		}else{
			for(Integer i=0;i<7;i++){
				html += optionsArr[i] != null ? '<div class="option"><div class="perc"><div class="v-align"><div class="inner">' + pollTotals.get(i) + '%' + '</div></div></div><div class="text">' + optionsArr[i] + '</div></div>' : '';
			}
		}
		html += 	'</div>'; // custom-html
		html += '</div>'; // inner
		html += refresh == true ? '' : '</div>'; //type-poll poll-results;

		return html;
	}

	private String showPoll () {
		String[] optionsArr = new String[]{option1,option2,option3,option4,option5,option6,option7};
		String html = '<div class="tile type-poll uninitialized">';
		html += '<div class="inner"><div class="content"><div class="v-align"><div class="inner">';
		html += title != null ? '<h3 class="title">' + title + '</h3>' : '<h3 class="title"></h3>';
//		html += '<p class="description"></p>'; //display:none /* this was previously display:none but is now used to render a "description" in addition to title. Removing it from the dom so it doesn't render empty space
		html += '</div></div></div>'; //inner v-align and content
		html += '<div class="bg"><img src="" alt=""><div class="shadow"></div></div>'; //shadow and bg display:none
		html += '<div class="news-category">Canadian News</div>'; //display:none
		html += '<div class="news-share"><div class="inner"><div class="likes"> likes</div><span class="s-like">Like</span><span class="s-share">Share</span></div></div>'; //inner and news-share display:none
		html += '<div class="link-footer"><a id="' + this.getOriginId() + '" href="#">';
		html += submitText != null ? submitText : '';
		html += '<i class="icon icon-external">External Link</i></a></div>'; //link-footer
		html += '<div class="social-icon icon-"></div>'; //social-icon display:none
		html += '<div class="custom-html">';
		//div class="option"><input id="poll-option-1" type="radio" name="dash-poll" value="1"><label for="poll-option-1">Option #1</label></div>
		for(Integer i=1;i<8;i++){
			html += optionsArr[i-1] != null ? '<div class="option"><input id="poll-option-'+i+'"type="radio" name="dash-poll" value="'+(i-1)+'"><label for="poll-option-'+i+'">' + optionsArr[i-1] + '</label></div>' : '';
		}
		html += '<div class="clear"></div>'; //clear
		html += '</div></div>'; //custom-html inner and tile type-poll
		html += '<script>';
		html += 	'$("#' + this.getOriginId() + '").bind("click", (function (evt) {';
		html += 		'evt.preventDefault();';
		html += 		'var thisPoll = $(this).closest(\'.tile.type-poll\');';
		html += 		'var pollChoiceIndex = $(this).closest(\'.tile.type-poll\').find(\'label.checked\').parent().find(\'input\').val();';
		html += 		'$.orchestracmsRestProxy.doAjaxServiceRequest("ocms_mfc_PollVote", {"action": "recordChoice", "choice": pollChoiceIndex';
		html += 				', "poll": "' + this.getOriginId() + '"';
		html += 				', "title": "' + title + '"';
		for(Integer i=1;i<8;i++){
			html += 				optionsArr[i-1] != null ? ', "option'+i+'": "' + optionsArr[i-1] + '"' : '';
		}
		html += 				showVoteCount != null ? ', "showVoteCount": "' + showVoteCount + '"' : '';
		html += 			'},';
		html += 			'function callBack(status, response) {';
		html += 				'if (response.success) {';
		html += 					'thisPoll.html(response.html);';
		html += 					'thisPoll.addClass(\'type-poll-result\');';
		html += 				'}';
		html += 			'}';
		html += 		');';
		html += 	'}));';
		html += 	'//# sourceURL=tempPoll' + this.getOriginId() + '.js';
		html += '</script></div>';

		return html;
	}
	/**
	 * Splitting the return statement for below reasons
	 * 1. To handle NullPointerException(during article creation)
	 * 2. To handle the styles applied to Poll Content
	 */

	public String title {
		get {
			String tVal = requestParameters == null ? getProperty('title') : requestParameters.get('title');
			if(tVal == null || tVal == ''){
				return getProperty('title');
			}else{
				return tVal.replace('\"','\'');
			}
		} set;
	}

	public String option1 {
		get {
			String option1Val = requestParameters == null ? getProperty('option1') : requestParameters.get('option1');
			if(option1Val == null || option1Val == ''){
				return getProperty('option1');
			}else{
				return option1Val.replace('\"','\'');
			}
		} set;
	}

	public String option2 {
		get {
			String option2Val = requestParameters == null ? getProperty('option2') : requestParameters.get('option2');
			if(option2Val == null || option2Val == ''){
				return getProperty('option2');
			}else{
				return option2Val.replace('\"','\'');
			}
		} set;
	}

	public String option3 {
		get {
			String option3Val = requestParameters == null ? getProperty('option3') : requestParameters.get('option3');
			if(option3Val == null || option3Val == ''){
				return getProperty('option3');
			}else{
				return option3Val.replace('\"','\'');
			}
		} set;
	}

	public String option4 {
		get {
			String option4Val = requestParameters == null ? getProperty('option4') : requestParameters.get('option4');
			if(option4Val == null || option4Val == ''){
				return getProperty('option4');
			}else{
				return option4Val.replace('\"','\'');
			}
		} set;
	}

	public String option5 {
		get {
			String option5Val = requestParameters == null ? getProperty('option5') : requestParameters.get('option5');
			if(option5Val == null || option5Val == ''){
				return getProperty('option5');
			}else{
				return option5Val.replace('\"','\'');
			}
		} set;
	}

	public String option6 {
		get {
			String option6Val = requestParameters == null ? getProperty('option6') : requestParameters.get('option6');
			if(option6Val == null || option6Val == ''){
				return getProperty('option6');
			}else{
				return option6Val.replace('\"','\'');
			}
		} set;
	}

	public String option7 {
		get {
			String option7Val = requestParameters == null ? getProperty('option7') : requestParameters.get('option7');
			if(option7Val == null || option7Val == ''){
				return getProperty('option7');
			}else{
				return option7Val.replace('\"','\'');
			}
		} set;
	}

	public String showVoteCount{
		get {
			return (requestParameters == null ? getProperty('showVoteCount') : requestParameters.get('showVoteCount'));
		} set;
	}

	public String submitText {
		get {
			return getProperty('submitText');
		} set;
	}

	public String thisContentId {get; private set;}

	private Map <String, String> requestParameters;

	private Boolean refresh;
}