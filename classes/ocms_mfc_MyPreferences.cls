global with sharing class ocms_mfc_MyPreferences extends cms.ContentTemplateController implements cms.ServiceInterface {

	// Start of required methods and constructor

	global ocms_mfc_MyPreferences () {}

	global ocms_mfc_MyPreferences (cms.GenerateContent gc) {
		super(gc);
	}

	global ocms_mfc_MyPreferences (cms.CreateContentController cc) {
		super(cc);
	}

	public System.Type getType() {
		return ocms_mfc_MyPreferences.class;
	}

	global String executeRequest (Map <String, String> request) {
		String response = '{"success": false, "message" : "Action is not supported"}';

		if (request.get('action') == 'savePreferences') {
			ocms_mfc_PlatformCache.removeNewsStreamCache();
			return '{"success": ' + json.serialize(savePreferences(request.get('primaryLanguage'), request.get('dailyDigest'), request.get('newsCategories'), UserInfo.getUserId())) + '}';
		} else if (request.get('action') == 'changeLanguage') {
			ocms_mfc_PlatformCache.removeNewsStreamCache();
			return '{"success": ' + json.serialize(saveNewLanguage(request.get('newLanguage'), UserInfo.getUserId())) + '}';
		} else if (request.get('action') == 'getUserPreferences') {
			return '{"success" : true, "userPrefs" : ' + JSON.serialize(getUserPreferences()) + '}';
		} else if (request.get('action') == 'getAllLanguages') {
			Set<String> allLanguages = new Set<String>();
			Set<string> allLangCodes = new Set<String>();
			for(cms__Language__c language : [SELECT cms__Language__c, cms__Language_Code__c FROM cms__Language__c
			WHERE cms__Sites__r.cms__Site_Name__c = 'MFC_Employee_Community' AND cms__Active__c = true]
			) {
				allLanguages.add(language.cms__Language__c);
				allLangCodes.add(language.cms__Language_Code__c);
			}
			return '{"success" : true, "allLanguages" : ' + JSON.serialize(allLanguages) + ', "allLangCodes": ' + JSON.serialize(allLangCodes) + '}';
		}

		return null;
	}

	global override String getHTML() {
		List <cms.TaxonomyNodeInfo> newsCategories = new List <cms.TaxonomyNodeInfo> ();
		Map<String, String> optionalPathsMap = new Map<String, String>();
		Set<String> mandatoryPaths = new Set<String>();

		// getServiceApi().getLanguageOptions(); will return inactive languages - direct query instead
		List <Map <String, String>> languages = new List <Map <String, String>>();
		for(cms__Language__c language : [SELECT cms__Language__c, cms__Language_Code__c FROM cms__Language__c
			WHERE cms__Sites__r.cms__Site_Name__c = :site_name AND cms__Active__c = true]
		) {
			languages.add(new Map<String, String> { language.cms__Language_Code__c => language.cms__Language__c });
		}

		System.debug(languages);

		Map<String, String> sitePreferences = ocms_mfc_SitePreferences.getSitePreferences(pm, getServiceAPI().getRenderLanguage());
		String mandatoryPathsJSON = sitePreferences.get('mandatoryNewsPaths');
		Map<String, Object> mandatoryPathsMap = new Map<String, Object>();

		if (mandatoryPathsJSON != null) {
			mandatoryPathsMap = (Map<String, Object>) JSON.deserializeUntyped(mandatoryPathsJSON);

			for (Object path : mandatoryPathsMap.values()) {
				mandatoryPaths.add((String)path);
			}
		}

		System.debug(mandatoryPaths);

		if (!Test.isRunningTest()) {
			String newsNodePath = sitePreferences.get ('newsCategoryTaxonomy');
			newsCategories = ocms_mfc_Taxonomy.getChildNodes (getServiceApi(), newsNodePath);
		} else { // only used for test mode
			newsCategories = new List <cms.TaxonomyNodeInfo> ();
			mandatoryPaths.add('blah');
			optionalPathsMap.put('blah', 'blah');
		}

		for (cms.TaxonomyNodeInfo category : newsCategories) {
			String pathName = '/' + category.getParentPath() + '/' + category.getName();
			if (!mandatoryPaths.contains(pathName)) {
				optionalPathsMap.put(pathName, category.getNodeId());
			}
		}

		String html = '';

		html += '<div id="userPrefs" class="article-content preference-content">';
		html += 	'<div class="inner">';
		html += 		'<div class="preference pref-news-streams">';
		html += 			'<div class="profile-detail">';
		html += 				'<div class="detail-group">';
		html += 					'<div class="label-wrapper">';
		html += 						'<span>' + labelLanguage + '</span>';
		html += 					'</div>'; // label-wrapper
		html += 					'<div class="input-wrapper">';
		html += 						'<div class="global-input-select langDropdown">';
		html += 							'<input type="text" value="English">';
		html += 							'<div class="input">';

		String languageHTML = '';
		String currentLanguage = '';

		for (Map <String, String> languageMap : languages) {
			List <String> singleKey = new List <String> ();
			singleKey.addAll(languageMap.keySet());
			List <String> singleValue = new List <String> ();
			singleValue.addAll(languageMap.values());

			languageHTML +=	'<div class="item" data-mfc-name="' + singleValue[0] + '" data-mfc-value="' + singleKey[0] + '">' + singleValue[0] + '</div>';
		}

		html += 								'<span>' + currentLanguage + '</span>';
		html += 								'<div class="arrow"></div>'; //arrow
		html += 								'<div class="drop">';
		html +=									languageHTML;
		html += 								'</div>'; //drop
		html += 							'</div>'; //input
		html += 						'</div>'; //global-input-select
		html += 					'</div>'; //input-wrapper
		html += 				'</div>'; //detail-group
		/* as per B5: Daily digest email link doesn't do anything and they not have a daily digest email (no requirements).
		html += 				'<div class="detail-group">';
		html += 					'<div class="label-wrapper">';
		html += 						'<span>' + labelEmail + '</span>';
		html += 					'</div>'; //label-wrapper
		html += 					'<div class="input-wrapper">';
		html += 						'<div class="global-input-checkbox dailyDigestCheckbox">';
		html += 							'<input type="checkbox" value="">';
		html += 							'<div class="input">';
		html += 								'<div class="checkbox">';
		html += 									'<span class="icon disable"></span>';
		html += 								'</div>';
		html += 								'<span class="label" data-mfc-on="' + (labelDailyDigestOn != null ? labelDailyDigestOn : '') + '" data-mfc-off="' + (labelDailyDigestOff != null ? labelDailyDigestOff : '') + '"></span>';
		html += 							'</div>'; //input on-off-toggle
		html += 						'</div>'; //global-input-checkbox
		html += 					'</div>'; //input-wrapper
		html += 				'</div>'; //detail-group
		*/
		html += 				'<div class="detail-group">';
		html += 					'<div class="label-wrapper">';
		html += 						'<span>' + (labelFontSize  == null ? '' : labelFontSize) + '</span>';
		html += 					'</div>'; // label-wrapper
		html +=						'<div class="input-wrapper">';
		html +=							'<div class="settings-layer selected">';
		html +=								'<ul>';
		html +=									'<li class="resize">';
		html +=										'<div class="sizes">';
		html +=											'<a data-mfc-size="sm" class="sm" href="">Aa</a>';
		html +=											'<a data-mfc-size="md" class="md selected" href="">Aa</a>';
		html +=											'<a data-mfc-size="lg" class="lg" href="">Aa</a>';
		html +=										'</div>';
		html +=									'</li>';
		html +=								'</ul>';
		html +=							'</div>';
		html +=						'</div>'; // label wrapper
		html +=					'</div>'; // detail-group
		html += 				'<hr/>';


		html += '<script>';
		html +=		'MFC.myPreferences = {};';
		html +=		'MFC.myPreferences.langChanged = false;';
		html +=		'MFC.myPreferences.targetPage = "' + (new cms.Link(link).targetPage == null ? '' : new cms.Link(link).targetPage) + '";';
		html +=		'MFC.fMyPreferencesSetup();';
		html += '</script>';

		/*
		//html += '<div class="tab-content"><div class="pref-news-streams"><h4 class="subhead">' + labelDefaultNews + '</h4>';
		html += 				'<h4 class="subhead">' + labelDefaultNews + '</h4>';

		Integer pathCounter = 0;
		for (String path : mandatoryPaths) {
			String modPath = path.removeEnd('/').substringAfterLast('/');
			if (Math.mod(pathCounter, 2) == 0) {
				html += '<div class="checkbox-group">';
			}

			html += 				'<div class="col">';
			html += 					'<div class="global-input-checkbox">';
			html += 						'<input type="checkbox" value="' + modPath + '">';
			html += 						'<div class="input">';
			html += 							'<div class="checkbox">';
			html += 								'<span class="icon disable"></span>';
			html += 							'</div>'; // checkbox
			html += 							'<span class="label newsCheckbox selected">' + modPath + '</span>';
			html += 						'</div>'; // input
			html += 					'</div>'; // global-input-checkbox
			html += 				'</div>'; // col
			//each checkbox group has two columns, two checkboxes

			if (Math.mod(pathCounter, 2) != 0) {
				html += '</div>'; //checkbox-group
			}

			pathCounter ++;
		}

		if (Math.mod(mandatoryPaths.size(), 2) != 0) {
			html += 			'</div>'; // close last checkbox-group if there was an odd number of checkboxes
		}

		html += 				'<hr/>';


		html += 				'<h4 class="subhead">' + labelOtherNews + '</h4>';
		pathCounter = 0;
		for (String path : optionalPathsMap.keySet()) {
			String modPath = path.removeEnd('/').substringAfterLast('/');

			if (Math.mod(pathCounter, 2) == 0) {
				html += 		'<div class="checkbox-group">';
			}

			html += 				'<div class="col">';
			html += 					'<div class="global-input-checkbox">';
			html += 						'<input type="checkbox" data-mfc-node-id="' + optionalPathsMap.get(path) + '" value="' + modPath + '">';
			html += 						'<div class="input">';
			html += 							'<div class="checkbox">';
			html += 								'<span class="icon"></span>';
			html += 							'</div>'; // checkbox
			html += 							'<span class="label newsCheckbox">' + modPath + '</span>';
			html += 						'</div>'; // input
			html += 					'</div>'; // global-input-checkbox
			html += 				'</div>'; // col

			if (Math.mod(pathCounter, 2) != 0) {
				html += '		</div>'; // checkbox-group
			}

			pathCounter ++;
		}

		if (Math.mod(optionalPathsMap.keySet().size(), 2) != 0) {
			html += 			'</div>'; // close last checkbox-group if there was an odd number of checkboxes
		}
*/
		html += 				'<div class="edit-button">';
		html += 					'<a href="#"><span>' + labelSubmit + '</span></a>';
		html += 				'</div>'; //edit-button
		html += 			'</div>'; //profile-detail
		html += 		'</div>'; //pref-news-streams
		html += 	'</div>'; //inner
		html += '</div>'; //article-content preference-content NEW

		return html;
	}

	public Map<String, String> getUserPreferences() {

		Map<String, String> prefMap = new Map <String, String> ();
		prefMap.put('PrimaryLanguage', '');
		prefMap.put('DailyDigest', 'false');
		prefMap.put('Subscriptions', '');
		prefMap.put('CurrentLanguage', UserInfo.getLanguage());

		for(Schema.PicklistEntry p : User.LanguageLocaleKey.getDescribe().getPicklistValues()) {
			if(p.getValue() == UserInfo.getLanguage()) {
				prefMap.put('CurrentLanguageName', p.getLabel());
			}
		}

		RecordType prefRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'MFC_Community_Object__c' AND DeveloperName = 'My_Preferences'];
		List<MFC_Community_Object__c> existingPreferences = [SELECT PrimaryLanguage__c, DailyDigest__c, Subscriptions__c FROM MFC_Community_Object__c p WHERE User__r.Id = :UserInfo.getUserId() AND RecordTypeId = :prefRecordType.Id];

		Boolean langChanged = false;

		if (existingPreferences.size() >= 1) {
			prefMap.put('PrimaryLanguage', existingPreferences[0].PrimaryLanguage__c);
			prefMap.put('DailyDigest', String.valueOf(existingPreferences[0].DailyDigest__c));
			prefMap.put('Subscriptions', existingPreferences[0].Subscriptions__c);
		} else {
			prefMap.put('LanguageChanged', 'true');
		}

		return prefMap;
	}

	public Boolean saveNewLanguage(String newLanguage, String userId) {
		try {
			cms.ServiceApi sApi = getServiceAPI();
			User u = new User();
			u.Id = userId;
			u.LanguageLocaleKey = newLanguage;
			ocms_mfc_Utility.bypassUserLanguageTrigger();
			update u;

			RecordType prefRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'MFC_Community_Object__c' AND DeveloperName = 'My_Preferences'];
			List<MFC_Community_Object__c> userPreferences = [SELECT PrimaryLanguage__c, DailyDigest__c, Subscriptions__c FROM MFC_Community_Object__c p WHERE User__r.Id = :userId AND RecordTypeId = :prefRecordType.Id];
			List<String> newSubscriptions = new List<String>();
			if (userPreferences.size() >= 1) {
				delete(userPreferences[0]);
			}

			return true;
		} catch (Exception ex) {
			return false;
		}
	}

	public static Boolean savePreferences (String primaryLanguage, String strDailyDigest, String strNewsCategories, String userId) {
		try {
			MFC_Community_Object__c pref = new MFC_Community_Object__c ();
			RecordType prefRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'MFC_Community_Object__c' AND DeveloperName = 'My_Preferences'];
			List<MFC_Community_Object__c> preferences = [SELECT PrimaryLanguage__c, DailyDigest__c, Subscriptions__c FROM MFC_Community_Object__c p WHERE User__r.Id = :userId AND RecordTypeId = :prefRecordType.Id];

			if (preferences.size() > 0) {
				pref = preferences[0];
			}

			Boolean dailyDigest = pref.DailyDigest__c;

			if (String.isNotEmpty(strDailyDigest)){
				pref.DailyDigest__c = Boolean.valueOf(strDailyDigest);
			}

			pref.Name = UserInfo.getUserName();
			pref.User__c = userId;

			if (String.isNotEmpty(primaryLanguage)) {
				pref.PrimaryLanguage__c = primaryLanguage;
			} else {
				primaryLanguage = pref.PrimaryLanguage__c;
			}

			if (String.isNotEmpty(strNewsCategories)) {
				pref.Subscriptions__c = strNewsCategories;
			}

			pref.RecordTypeId = prefRecordType.Id;

			upsert pref;

			User u = new User();
			u.Id = userId;
			u.LanguageLocaleKey = primaryLanguage;
			ocms_mfc_Utility.bypassUserLanguageTrigger();

			update u;

			return true;
		} catch (Exception ex) {
			System.debug(ex.getMessage());
			return false;
		}
	}

	@future
	public static void saveDefaultPreferences (String userId, String newsCategories) {
		User u = [SELECT LanguageLocaleKey FROM User WHERE Id = :userId];
		savePreferences(u.LanguageLocaleKey, 'true', newsCategories, userId);
	}

	/*@future
	private static void deleteMultiplePreferences (List <Id> prefIds) {
		List <MFC_Community_Object__c> preferences = [SELECT Id FROM MFC_Community_Object__c WHERE Id IN :prefIds];
		delete preferences;
	}*/

	public String labelLanguage {
		get {
			return getProperty('labelLanguage');
		} set;
	}

	public String labelEmail {
		get {
			return getProperty('labelEmail');
		} set;
	}

	public String labelDailyDigestOn {
		get {
			return getProperty('labelDailyDigestOn');
		} set;
	}

	public String labelDailyDigestOff {
		get {
			return getProperty('labelDailyDigestOff');
		} set;
	}

	public String labelFontSize {
		get {
			return getProperty('labelFontSize');
		} set;
	}

	public String labelDefaultNews {
		get {
			return getProperty('labelDefaultNews');
		} set;
	}

	public String labelOtherNews {
		get {
			return getProperty('labelOtherNews');
		} set;
	}

	public String labelSubmit {
		get {
			return getProperty('labelSubmit');
		} set;
	}

	public String link {
		get {
			return this.getProperty('link');
		}
		set;
	}
}