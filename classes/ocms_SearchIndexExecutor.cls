global class ocms_SearchIndexExecutor implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts{

	private Map<String, String> contextParams {get; set;}
	private String siteName {get; set;}
	private DateTime now  {get; set;}
	private DateTime lastIndexDate {get; set;}
	private Boolean urlRewritingEnabled;
	private String sitePrefix;
	private cms.ServiceAPI theAPI {get; set;}
	private Boolean rebuild {get; set;}
	private String siteDefaultLanguage;
	private Map<String, List<String>> contentTypeIndexableAttributes;
	private Boolean useRevisionOriginDates = false;

	global ocms_SearchIndexExecutor(Map<String, String> contextParams, Boolean rebuild, ocms_Search_Index_Settings__c setting)
	{
		this.now = DateTime.now();
		this.contextParams = contextParams;
		this.siteName = contextParams.get('sname');
		this.rebuild = rebuild;

		//If last index date is null, set to arbitrary early start date - Unix EPOC time.
		if (setting.Last_Index_Date__c == null){
			this.lastIndexDate = DateTime.newInstance(0L);
		} else{
			this.lastIndexDate = setting.Last_Index_Date__c;
		}
		this.urlRewritingEnabled = setting.URL_Rewriting_Enabled__c;
		this.sitePrefix = setting.Site_Prefix__c;
		this.useRevisionOriginDates = setting.Use_Revision_Origin_Dates__c;
	}

	private cms.ServiceAPI getServiceAPI()
	{
		if (this.theAPI == null)
		{
			//  Initialize context outside of cms
			this.theAPI = (cms.ServiceAPI)cms.ServiceEndpoint.getService('cms.ServiceAPI', contextParams );
		}
		return this.theAPI;
	}

	global Database.QueryLocator start(Database.BatchableContext BC)
	{
		return startBuildContentIndex(BC);
	}

	private class SIException extends Exception
	{
		public String faultCode {get; set;}
	}

	private Database.QueryLocator startBuildContentIndex(Database.BatchableContext BC) {

		//  Get the list of searchable content types
		List<String> contentTypes = new List<String>();
		contentTypeIndexableAttributes = new Map<String, List<String>>();
		for (cms__Content_Type__c ct : [SELECT cms__Name__c, Search_Indexable_Attributes__c FROM cms__Content_Type__c
		WHERE cms__Sites__r.cms__Site_Name__c = :this.siteName
		AND   Include_In_Search_Index__c = true])
		{
			contentTypes.add(ct.cms__Name__c);
			try {
				contentTypeIndexableAttributes.put(ct.Id, (List<String>)JSON.deserialize(ct.Search_Indexable_Attributes__c, List<String>.class));
			} catch(Exception e) {} // Deal with this during content processing
		}

		//System.debug('CONTENT TYPES ==> ' + JSON.serialize(contentTypes));
		//System.debug('LAST INDEX DATE ==> ' + lastIndexDate);
		//System.debug('SITE ==> ' + siteName);
		//System.debug('NOW ==> ' + now);

		//  Build the content filtering on date and content type
		String query = 'SELECT Id, cms__Access_Level__c, cms__Actual_Preview_Start_Date__c, cms__Actual_Published_Start_Date__c, cms__All_Shared_With_Guest__c, cms__All_Shared_With_Portal__c, cms__Am_Latest_Preview__c, cms__Am_Latest_Published__c, cms__Ancestor__c, cms__Ancestor1__c, cms__Ancestor2__c, cms__Ancestor3__c, cms__Ancestor4__c, cms__Ancestor5__c, cms__Ancestor6__c, cms__Approval__c, cms__Available_Languages__c, cms__Content_Layout__c, cms__Content_Type__c, cms__Depth__c, cms__Description__c, cms__Dirty_Date__c, cms__Exclude_Search__c, cms__External_Id__c, cms__External_Id2__c, cms__Index__c, cms__IndexCount__c, cms__Is_Not_Targeted__c, cms__Language__c, cms__Last_Order__c, cms__Locked__c, cms__LockedForEdit__c, cms__LockedForEditBy__c, cms__LockedForEditDate__c, cms__Name__c, cms__Object_Start_Date__c, cms__Order__c, cms__Original_Preview_Start_Date__c, cms__Original_Published_Start_Date__c, cms__Parent__c, cms__Parent_Origin__c, cms__Preview__c, cms__Preview_End_Date__c, cms__Preview_Start_Date__c, cms__Priority__c, cms__Priority_Duration__c, cms__Priority_End_Date__c, cms__Priority_Preview__c, cms__Priority_Weight__c, cms__Published__c, cms__Published_End_Date__c, cms__Published_Start_Date__c, cms__Revision_Number__c, cms__Revision_Origin__c, cms__Site_Name__c, cms__Sites__c, cms__SubTree__c, cms__Tag_Definition__c, cms__TagFilter__c, cms__TagFilter1__c, cms__TagFilter2__c, cms__TagFilter3__c, cms__TagFilter4__c, cms__TagFilter5__c, cms__TagFilter6__c, cms__TargetFilter__c, cms__TargetFilter1__c, cms__TargetFilter10__c, cms__TargetFilter11__c, cms__TargetFilter12__c, cms__TargetFilter13__c, cms__TargetFilter14__c, cms__TargetFilter15__c, cms__TargetFilter16__c, cms__TargetFilter17__c, cms__TargetFilter18__c, cms__TargetFilter19__c, cms__TargetFilter2__c, cms__TargetFilter3__c, cms__TargetFilter4__c, cms__TargetFilter5__c, cms__TargetFilter6__c, cms__TargetFilter7__c, cms__TargetFilter8__c, cms__TargetFilter9__c, cms__TargetFilterAll__c, cms__TargetFilterAll1__c, cms__TargetFilterAll10__c, cms__TargetFilterAll11__c, cms__TargetFilterAll12__c, cms__TargetFilterAll13__c, cms__TargetFilterAll14__c, cms__TargetFilterAll15__c, cms__TargetFilterAll16__c, cms__TargetFilterAll17__c, cms__TargetFilterAll18__c, cms__TargetFilterAll19__c, cms__TargetFilterAll2__c, cms__TargetFilterAll3__c, cms__TargetFilterAll4__c, cms__TargetFilterAll5__c, cms__TargetFilterAll6__c, cms__TargetFilterAll7__c, cms__TargetFilterAll8__c, cms__TargetFilterAll9__c, cms__Targets__c, cms__Title__c, cms__Translated_Languages__c, cms__Version_Latest__c, cms__Version_Latest_Published__c, cms__Version_Name__c, cms__Version_Number__c, cms__Version_Origin__c, cms__Version_Original__c, cms__Version_Parent__c,'
				+ 'cms__Sites__r.cms__Site_Name__c, cms__Content_Type__r.cms__Name__c, cms__Content_Type__r.cms__hasChildren__c, cms__Content_Type__r.Search_Indexable_Attributes__c,'
				+ 'cms__Content_Type__r.Search_Title_Attribute__c, cms__Content_Type__r.Search_Description_Attribute__c, cms__Content_Type__r.Search_Content_Attributes__c,'
				+ 'cms__Content_Type__r.Search_Thumbnail_Attribute__c, cms__Content_Type__r.Search_Document_Attributes__c,'
				+ 'cms__Content_Type__r.Search_Detail_Page_Attributes__c, cms__Content_Type__r.Search_Detail_Page_Name__c,'
				+ 'cms__Revision_Origin__r.cms__Published_Start_Date__c,'
				+ '(SELECT Id, cms__Is_Simple__c, cms__Name__c, cms__Value__c, cms__Simple_Name__c, cms__Simple_Value__c, cms__Language__c FROM cms__Attributes__r)'
				+ ' FROM cms__Content__c'
				+ ' WHERE cms__Published__c = true'
				+ ' AND cms__Sites__r.cms__Site_Name__c = :siteName'
				+ ' AND cms__Content_Type__r.cms__Name__c IN :contentTypes'
				+ ' AND ((cms__Published_Start_Date__c > :lastIndexDate'
				+ ' AND cms__Published_Start_Date__c <= :now'
				+ ' AND (cms__Published_End_Date__c = NULL OR cms__Published_End_Date__c > :now))'
				+ ' OR (cms__Published_Start_Date__c <= :lastIndexDate'
				+ ' AND cms__Published_End_Date__c > :lastIndexDate AND cms__Published_End_Date__c <= :now))'
				+ ' ORDER BY cms__Published_Start_Date__c';

		try {
			if(query != null) {
				return Database.getQueryLocator(query);
			} else {
				throw new SIException('Invalid query: ' + query);
			}
		} catch(System.QueryException qe) {
			throw new SIException(qe.getMessage() + ' : ' + query);
		}

		return null;
	}

	global void execute(Database.BatchableContext BC, List<SObject> scope) {

		getServiceAPI();

		//  Create a map of languages to ID for the attributes lookup
		Map<String, String> langToIdMap = new Map<String, String>();
		Map<String, String> idToLangMap = new Map<String, String>();
		for (cms__Language__c l : [SELECT Id, cms__Language_Code__c FROM cms__Language__c WHERE cms__Sites__r.cms__Site_Name__c = :siteName])
		{
			langToIdMap.put(l.cms__Language_Code__c, l.Id);
			idToLangMap.put(l.Id, l.cms__Language_Code__c);
		}

		//  Now that we have the content, separate it based on language
		List<OCMS_Content_Search_Index__c> csiList = new List<OCMS_Content_Search_Index__c>();
		List<cms__Content__c> cScope = (List<cms__Content__c>)scope;

		//  Create a map of content to URL based on preview page in content template relationship and default
		//  Create a couple of lists to feed the get generated content method
		Map<String, String> contentURLMap = new Map<String, String>();
		List<cms__Content__c> contentWithDefaultLayouts = new List<cms__Content__c>();
		List<String> associatedLayouts = new List<String>();

		//  While we are building the content -> layout -> url structures, populate a list of all content to be used for tags
		List<String> allContentIds = new List<String>();
		Map<String, String> originToCurrent = new Map<String, String>();
		Map<String, Map<String, List<String>>> contentToAdHocTags = new Map<String, Map<String, List<String>>>();

		Map<String, DefaultLayoutAndUrl> ctLayoutAndURLMap = getContentTypeDefaultLayouts();
		//System.debug('DEFAULT CONTENT URL/LAYOUT MAP ==> ' + JSON.serialize(ctLayoutAndURLMap));

		for (cms__Content__c c : cScope)
		{
			String originId = (c.cms__Version_Origin__c == null ? c.Id : c.cms__Version_Origin__c);
			allContentIds.add(c.Id);
			originToCurrent.put(
					originId,
					c.Id
			);
			contentToAdHocTags.put(originId, new Map<String, List<String>>());

			String contentType = (String)c.getSObject('cms__Content_Type__r').get('cms__Name__c');
			DefaultLayoutAndUrl dlu = ctLayoutAndURLMap.get(contentType);
			if(dlu != null) {
				if (String.isNotBlank(dlu.layout))
				{
					//  Create the lists to be used with getGeneratedContent
					contentWithDefaultLayouts.add(c);
					associatedLayouts.add(dlu.layout);
				}
				if (String.isNotBlank(dlu.url))
				{
					//  Create the map to get the default URL for the content
					contentURLMap.put(c.Id,dlu.url);
				}
			}
		}

		/*
        *   SR-48 - Modify recording of Index records to upsert existing index records rather than create a new entry for each publish/expire event.  This is
        *   for the Coveo implementation.
        */
		Set<Id> latestPublishedIds = new Set<Id>();
		for (cms__Content__c c : [SELECT Id, cms__Version_Latest_Published__c FROM cms__Content__c WHERE Id IN :originToCurrent.keySet()]) {
			latestPublishedIds.add(c.cms__Version_Latest_Published__c == null ? c.Id : c.cms__Version_Latest_Published__c);
		}


		List<Ad_Hoc_Tag__c> adHocTags = [select Name, Content__c, Language__c from Ad_Hoc_Tag__c where Content__c in :originToCurrent.keySet()];

		for(Ad_Hoc_Tag__c tag : adHocTags) {
			Map<String, List<String>> contentMap = contentToAdHocTags.get(tag.Content__c);
			List<String> languageList = contentMap.get(tag.Language__c);
			if(languageList == null) languageList = new List<String>();
			languageList.add(tag.Name);
			contentMap.put(tag.Language__c, languageList);
		}

		//System.debug('CONTENT URL MAP ==> ' + JSON.serialize(contentURLMap));
		//System.debug('CONTENT TO RENDER ==>' + JSON.serialize(contentWithDefaultLayouts));
		//System.debug('ASSOCIATED LAYOUTS ==> ' + JSON.serialize(associatedLayouts));
		//System.debug('# OF CONTENT ITEMS ==> ' + contentWithDefaultLayouts.size());
		//System.debug('# OF LAYOUTS ==> ' + associatedLayouts.size());

		//  Get the renderings to be added as generated content to the index
		//Map<Id, String> renderings = this.theAPI.getGeneratedContentHaveLatest(contentWithDefaultLayouts, associatedLayouts);

		//  Get a map of content -> map of language -> set of tags
		Map<String, Map<String, Set<String>>> contentTagMap = new Map<String, Map<String, Set<String>>>();
		for (cms__Content_Tag_Index__c cti : [SELECT cms__Content__c, cms__Language__c, cms__Full_Path__c FROM cms__Content_Tag_Index__c
		WHERE cms__Content__c IN :allContentIds
		ORDER BY cms__Content__c, cms__Language__c])
		{
			Map<String, Set<String>> langToTagMap = contentTagMap.get(cti.cms__Content__c);
			if (langToTagMap == null)  //  haven't created a map for this content yet
			{
				langToTagMap = new Map<String, Set<String>>();
			}

			String langCode = idToLangMap.get(cti.cms__Language__c);
			Set<String> tagList;
			if (String.isNotBlank(langCode))
			{
				tagList = langToTagMap.get(langCode);
			}
			else continue;

			if (tagList == null) // haven't created a list for this language yet
			{
				tagList = new Set<String>();
			}

			tagList.add(cti.cms__Full_Path__c);  // add the tag to the tag list
			langToTagMap.put(langCode, tagList);  // add the tag list to the language map
			contentTagMap.put(cti.cms__Content__c, langToTagMap);  // add the map of language to tags to the content map
		}

		String urlPrefix = String.isBlank(sitePrefix) ? '' : '/' + sitePrefix;

		for (cms__Content__c c : cScope)
		{
			// SR-48 - Only wish to process content records which are the latest published version.  if the id fo the current
			// content record is not a latest published id, then skip to next iteration in loop.
			if (!latestPublishedIds.contains(c.Id)) {
				continue;
			}

			Boolean indexThisContent = true;

			String originId = (c.cms__Version_Origin__c == null ? c.Id : c.cms__Version_Origin__c);

			String als = c.cms__Available_Languages__c;
			//System.debug ('AVAILABLE LANGUAGES==> ' + als);

			// If there are no available languages, assume site default language
			// This condition should never occur.
			if (String.isBlank(als)) als = getSiteDefaultLanguage();

			List<String> alList = als.split(';');
			//Create a set to make use of Contains
			Set <String> alSet = new Set<String>(alList);
			//System.debug ('AVAILABLE LANGUAGES SET==> ' + alSet);


			String tls = c.cms__Translated_Languages__c;
			//  If there are no translated languages, assume site default language
			if (String.isBlank(tls)) tls = getSiteDefaultLanguage();

			List<String> tlList = tls.split(';');

			// Remove any translated language which is not listed in the content's available language list
			List<String> validatedTLList = new List<String>();

			//System.debug ('TRANSLATED LANGUAGES LIST==> ' + tlList);

			for (String lang: tlList){
				//System.debug ('\nLANGUAGE TO CHECK ==> ' + lang);
				If(alSet.contains(lang)){
					//System.debug ('\nLANGUAGE IN SET==> ' + lang);
					// translated language is an available language; add to validated language list.
					validatedTLList.add(lang);
				}
			}
			//System.debug ('VALIDATED LANGUAGES LIST==> ' + validatedTLList);


			for (String lang : validatedTLList)
			{
				cms__Content_Type__c contentTypeObject = (cms__Content_Type__c)c.getSObject('cms__Content_Type__r');
				//System.debug(contentTypeObject);
				String contentType = (String)c.getSObject('cms__Content_Type__r').get('cms__Name__c');
				Datetime startDate;
//				if(this.useRevisionOriginDates) {
//					startDate = c.cms__Revision_Origin__r.cms__Published_Start_Date__c;
//					if(startDate == null) {
//						startDate = c.cms__Published_Start_Date__c;
//					}
//				} else {
//					startDate = c.cms__Published_Start_Date__c;
//				}

                // This is the origin version
                if (null == c.cms__Version_Origin__c){
                    startDate = c.cms__Published_Start_Date__c;
                }else{ // Get published date from origin version
                    cms__Content__c originalContent =
                    [SELECT cms__Published_Start_Date__c from cms__Content__c where ID =:c.cms__Version_Origin__c];
                    startDate = originalContent.cms__Published_Start_Date__c;
                }

				Datetime endDate = c.cms__Published_End_Date__c;
				String status = 'new';

				if (endDate > this.lastIndexDate && endDate <= this.now)
				{
					status = 'expired';
				}
				// SR-48 Modify our index key to only use origin Id and language.
				String key = originId + ':' + lang;
				Map<String, String> attMap = getAttributes(c.cms__Attributes__r, langToIdMap.get(lang));
				Map<String, Object> indexableAttMap = getIndexableAttributes(c.cms__Content_Type__c, attMap);

				//When generating the urls, use the origin ID; this will facilitate analytics tracking viewing of different versions of articles but won't affect which version of
				//the article is rendered to the user (current production version is rendered).
				String url;
				if(c.cms__Content_Type__r.Search_Detail_Page_Attributes__c != null) {
					List<String> detailAttributes = (List<String>)JSON.deserialize(c.cms__Content_Type__r.Search_Detail_Page_Attributes__c, List<String>.class);
					for(String detailAttribute : detailAttributes) {
						String detailPageCsv = attMap.get(detailAttribute);
						cms.Link detailPage = new cms.Link(detailPageCsv);

						// Block DailyClippings, newsOnMC and socialPost content
						if(attMap.get('contentFlavor') == 'newsItem' || attMap.get('contentFlavor') == 'MCTrend' || attMap.get('contentFlavor') == 'socialPost') {
							indexThisContent = false;
						} else if(detailPage.linkType == 'Internal') {
							// TODO: Decide whether or not to pass the content_id parameter into configuration -
							//       this condition is stopgap
							if(siteName.contains('MFC') || siteName.contains('AskHR')) {
								if(urlRewritingEnabled) {
									//url = urlPrefix + '/' + detailPage.link.get('TargetSEOName') + '?content_id=' + c.Id;
									url = urlPrefix + '/' + detailPage.link.get('TargetSEOName');
								} else {
									//url = urlPrefix + '/' + '?name=' + detailPage.link.get('TargetSEOName') + '&content_id=' + c.Id;
									url = urlPrefix + '/' + 'cms__Main?name=' + detailPage.link.get('TargetSEOName');
								}
							} else {
								if(urlRewritingEnabled) {
									//url = urlPrefix + '/' + detailPage.link.get('TargetSEOName') + '?content_id=' + c.Id;
									url = urlPrefix + '/' + detailPage.link.get('TargetSEOName') + '?content_id=' + originId;
								} else {
									//url = urlPrefix + '/' + '?name=' + detailPage.link.get('TargetSEOName') + '&content_id=' + c.Id;
									url = urlPrefix + '/' + 'cms__Main?name=' + detailPage.link.get('TargetSEOName') + '&content_id=' + originId;
								}
							}

							indexThisContent = true;
						} else if(detailPage.linkType == 'Media') {
							url = detailPage.link.get('TargetId');
							if(url.startsWith('/')) {
								url = urlPrefix + url;
							} else {
								url = urlPrefix + '/' + url;
							}

							indexThisContent = true;
						}

						if(!String.isBlank(url)) break;
					}
				}

				if(url == null && c.cms__Content_Type__r.Search_Detail_Page_Name__c != null) {
					if(urlRewritingEnabled) {
						url = urlPrefix + '/' + c.cms__Content_Type__r.Search_Detail_Page_Name__c;
						if(c.cms__Content_Type__r.Search_Detail_Page_Name__c.indexOf('?') != -1) {
							url += '&';
						} else {
							url += '?';
						}
						//url += '&content_id=' + c.Id;
						url += '&content_id=' + originId;
					} else {
						//url = urlPrefix + '/' + 'cms__Main?name=' + c.cms__Content_Type__r.Search_Detail_Page_Name__c + '&content_id=' + c.Id;
						url = urlPrefix + '/' + 'cms__Main?name=' + c.cms__Content_Type__r.Search_Detail_Page_Name__c + '&content_id=' + originId;
					}
				}

				if(!String.isBlank(contentType) && contentType == 'PolicyFormOrProcess'){
					String link = attMap.get('webLink');

					if(!String.isBlank(link) && link.contains('External')){
						String[] linkArr = link.split(',+');

						if (link.contains('CurrentWindow') || link.contains('NewWindow'))
							url = linkArr[2];
						else
							url = linkArr[1];
					}
				}

				//String rendering = '';
				//if (status == 'new') rendering = renderings.get(c.Id);

				OCMS_Content_Search_Index__c csi = new OCMS_Content_Search_Index__c();

				Map<String, Set<String>> langToTagMap = contentTagMap.get(c.Id);
				List<String> tagList = new List<String>();
				csi.TagPath__c = '[]';
				csi.Facets__c = '[]';
				if (langToTagMap != null)
				{
					Set<String> tagSet = langToTagMap.get(lang);
					if (tagSet != null && tagSet.size() > 0)
					{
						tagList = new List<String>(tagSet);
						csi.TagPath__c = JSON.serialize(tagList);
						csi.Facets__c = JSON.serialize(getContentFacets(contentType, tagList));
					}
				}
				csi.Location__c = getContentLocation(contentType, tagList);

				// Ad Hoc Tags
				List<String> contentAdHocTags = contentToAdHocTags.get(originId).get(langToIdMap.get(lang));
				if(contentAdHocTags == null) contentAdHocTags = new List<String>();
				String serializedTags = String.join(contentAdHocTags, ',');
				indexableAttMap.put('adHocTags', String.join(contentAdHocTags, ','));
				indexableAttMap.put('taxonomyTags', String.join(tagList, ','));

				String attrs = JSON.serialize(indexableAttMap);

				String thumbnailUrl = attMap.get(contentTypeObject.Search_Thumbnail_Attribute__c);
				if(!String.isBlank(thumbnailUrl)) {
					thumbnailUrl = urlPrefix + thumbnailUrl;
				}

				csi.Title__c = floorString(attMap.get(contentTypeObject.Search_Title_Attribute__c), 255);
				csi.Description__c = floorString(attMap.get(contentTypeObject.Search_Description_Attribute__c), 1000);
				csi.Content_Attribute_Names__c = contentTypeObject.Search_Content_Attributes__c;
				csi.Documents__c = JSON.serialize(getContentAttachmentIds(contentTypeObject.Search_Document_Attributes__c, attMap));
				csi.Thumbnail_URL__c = floorString(thumbnailUrl, 255);
				csi.Name__c = floorString(c.cms__Name__c, 255);
				csi.Attributes__c = attrs;
				csi.Index_Key__c = key;
				csi.PublishStartDate__c = startDate;
				csi.PublishEndDate__c = endDate;
				csi.Status__c = status;
				csi.Type__c = contentType;
				csi.Site_Name__c = this.siteName;
				csi.Language__c = lang;
				csi.URL__c = floorString(url, 1000);
				csi.Tags__c = serializedTags;
				//csi.GeneratedContent__c = rendering;

				if(indexThisContent) {
					//System.debug ('==> INDEX CONTENT <== ');
					csiList.add(csi);
				}
			}
		}

		if (csiList.size() > 0)
		{
//          // SR-48 : Change from insert to Upsert using external id.
			upsert csiList Index_Key__c;
		}
	}

	private String floorString(String str, Integer length) {
		if(str == null) return null;
		if(str.length() < length) return str;
		return str.substring(0, length);
	}

	private Map<String, String> getAttributes(List<cms__Attribute__c> att, String lang)
	{
		Map<String, String> attMap = new Map<String, String>();
		for (cms__Attribute__c a : att)
		{
			if (a.cms__Language__c == lang)
			{
				if (a.cms__Is_Simple__c == true)
				{
					attMap.put(a.cms__Simple_Name__c, a.cms__Simple_Value__c);
				}
				else
				{
					attMap.put(a.cms__Name__c, a.cms__Value__c);
				}
			}
		}
		return attMap;
	}

	private Map<String, Object> getIndexableAttributes(String typeId, Map<String, String> att)
	{
		List<String> indexableAttributes = this.contentTypeIndexableAttributes.get(typeId);
		Map<String, Object> attMap = new Map<String, Object>();

		for(String attName : att.keySet()) {
			Boolean isIndexable = false;
			for(String indexableName : indexableAttributes)
			{
				if(indexableName == attName)
				{
					attMap.put(attName, att.get(attName));
				}
			}
		}

		return attMap;
	}

	private List<String> getContentFacets(String contentType, List<String> tags)
	{
		if(contentType == 'News') return new List<String>{'News'};
		if(contentType == 'CEOMessage') return new List<String>{'CEO Message'};

		return new List<String>();
	}

	private static Map<String, String> taxonomyContentLocations;

	static {
		taxonomyContentLocations = new Map<String, String> {
				'/Notification Taxonomy/News category/' => 'News > ',
				'/Notification Taxonomy/Article Categories/' => 'Articles > '
		};
	}

	private String getContentLocation(String contentType, List<String> tags)
	{
		// TODO: Refactor into the Search Indexer Settings custom setting
		if(contentType != 'MLIArticle') return 'MFCentral';
		return 'Manulife.com';
	}

	private static Pattern attachmentIdPattern
	{
		get
		{
			if(attachmentIdPattern == null)
			{
				String attachmentPrefix = '00P';

				// Match both 18 and 15-character IDs
				attachmentIdPattern = Pattern.compile('.*(' + attachmentPrefix + '([a-zA-Z0-9]{15}|[a-zA-Z0-9]{12})).*');
			}

			return attachmentIdPattern;
		}
		set;
	}

	private String getAttachmentId(String value)
	{
		Matcher m = attachmentIdPattern.matcher(value);

		if(!m.matches()) return null;

		return m.group(1);
	}

	private List<String> getContentAttachmentIds(String attributeNamesJson, Map<String, String> attributes)
	{
		List<String> idList = new List<String>();
		try {
			List<String> attributeNames = (List<String>)JSON.deserialize(attributeNamesJson, List<String>.class);

			for(String attributeName : attributeNames)
			{
				String attachmentId = getAttachmentId(attributes.get(attributeName));

				if(attachmentId != null)
				{
					idList.add(attachmentId);
				}
			}
		} catch(Exception e) {}

		return idList;
	}

	private class DefaultLayoutAndUrl {
		String layout;
		String url;

		private DefaultLayoutAndUrl(String sn, String layoutId, String layoutName, String u, cms.ServiceAPI sAPI)
		{
			this.layout = layoutName;
		}
	}

	private Map<String, DefaultLayoutAndUrl> getContentTypeDefaultLayouts()
	{
		Map<String, DefaultLayoutAndUrl> ctrMap = new Map<String, DefaultLayoutAndUrl>();
		for (cms__Content_Template_Relationship__c ctr : [SELECT cms__Content_Type__r.cms__Name__c,
				cms__Content_Layout__r.cms__Name__c,
				cms__Preview_Page__r.cms__Search_Optimized_Name__c
		FROM cms__Content_Template_Relationship__c
		WHERE cms__Content_Type__r.cms__Sites__r.cms__Site_Name__c = :this.siteName
		AND   cms__Default__c = true
		AND   cms__Content_Type__r.Include_In_Search_Index__c = true])
		{
			String ctName = (String)ctr.getSObject('cms__Content_Type__r').get('cms__Name__c');
			String clId = (String)ctr.getSObject('cms__Content_Layout__r').get('Id');
			String clName = (String)ctr.getSObject('cms__Content_Layout__r').get('cms__Name__c');
			String pp = '';
			SObject pp_r = (SObject)ctr.getSObject('cms__Preview_Page__r');
			if (pp_r != null) pp = (String)pp_r.get('cms__Search_Optimized_Name__c');
			DefaultLayoutAndUrl dlu = new DefaultLayoutAndUrl(this.siteName, clId, clName, pp, this.theAPI);
			ctrMap.put(ctName, dlu);
		}
		return ctrMap;
	}

	private String getSiteDefaultLanguage()
	{
		if (this.siteDefaultLanguage == null)
		{
			cms__Sites__c s = [SELECT Id, cms__Site_Name__c, cms__Default_Language__c FROM cms__Sites__c WHERE cms__Site_Name__c = :this.siteName];
			this.siteDefaultLanguage = (s.cms__Default_Language__c == null ? 'en_US' : s.cms__Default_Language__c);
		}
		return this.siteDefaultLanguage;
	}

	global void finish(Database.BatchableContext BC) {
	}
}