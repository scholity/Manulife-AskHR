global with sharing class ocms_SearchIndexPageExecutor implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
	private Map<String, String> contextParams {get; set;}
	private String siteName {get; set;}
	private DateTime now {get; set;}
	private DateTime lastIndexDate {get; set;}
	private Boolean rebuild {get; set;}

	private Boolean urlRewritingEnabled;
	private String sitePrefix;

	private String languageId;

	private Map<String, String> langToIdMap = new Map<String, String>();
	private Map<String, String> idToLangMap = new Map<String, String>();

	global ocms_SearchIndexPageExecutor(Map<String, String> contextParams, Boolean rebuild, ocms_Search_Index_Settings__c setting) {
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

		initSiteLanguages();

		languageId = langToIdMap.get(contextParams.get('ocmsLang'));
	}

	private void initSiteLanguages() {
		langToIdMap = new Map<String, String>();
		idToLangMap = new Map<String, String>();

		for(cms__Language__c l : [SELECT Id, cms__Language_Code__c FROM cms__Language__c WHERE cms__Sites__r.cms__Site_Name__c = :siteName]) {
			langToIdMap.put(l.cms__Language_Code__c, l.Id);
			idToLangMap.put(l.Id, l.cms__Language_Code__c);
		}
	}

	private class SIException extends Exception {
		public String faultCode {get; set;}
	}

	global database.QueryLocator start(Database.BatchableContext BC) {
		// One of three conditions:
		// - Page expired between last index and now (first section)
		// - Page was published between last index and now (second section)
		// - PCLI was modified since last index and page is not expired (third section)
		cms__Page_Content_Layout_Instance__c[] pclis = [select Id, cms__Page__c from cms__Page_Content_Layout_Instance__c where
			cms__Page__r.cms__Sites__r.cms__Site_Name__c = :siteName
			AND cms__Page__r.cms__Published__c = true
			AND cms__Page__r.cms__IsMaster__c = false
			AND (
				(
					cms__Page__r.cms__Published_Start_Date__c <= :lastIndexDate
					AND cms__Page__r.cms__Published_End_Date__c > :lastIndexDate
					AND cms__Page__r.cms__Published_End_Date__c <= :now
				) or (
					cms__Page__r.cms__Published_Start_Date__c > :lastIndexDate
					AND cms__Page__r.cms__Published_Start_Date__c <= :now
					AND (
						cms__Page__r.cms__Published_End_Date__c = NULL
						OR cms__Page__r.cms__Published_End_Date__c > :now
					)
				) or (
					LastModifiedDate > :lastIndexDate
					AND cms__Page__r.cms__Published_End_Date__c > :now
				)
			)];

		Set<Id> pageIds = new Set<Id>();

		for(cms__Page_Content_Layout_Instance__c pcli : pclis) {
			pageIds.add(pcli.cms__Page__c);
		}
		/*
        *   SR-48 - Retrieve cms__Version_Latest_Published__c from page record.
        */
		String query = 'SELECT Id, cms__Version_Origin__c, cms__Available_Languages__c, cms__Published_Start_Date__c, cms__Published_End_Date__c, cms__Version_Latest_Published__c,'
		             + '   (SELECT cms__Simple_Name__c, cms__Simple_Value__c, cms__Meta_Page_Description__c, cms__Meta_Page_Keywords__c, cms__Meta_Page_Name__c, cms__Meta_Page_Title__c, cms__Language__c'
		             + '      FROM cms__Attributes__r'
		             + '      WHERE cms__Language__c = :languageId'
		             + '        OR (RecordType.Name=\'Url\' AND cms__Simple_Name__c=\'seo_name\')'
		             + '   )'
		             + ' FROM cms__Page__c'
		             + ' WHERE Id IN :pageIds AND cms__IsMaster__c = false'
		             + ' ORDER BY cms__Published_Start_Date__c';

		try {
			if(query != null) {
				return Database.getQueryLocator(query);
			} else {
				throw new SIException('Invalid query: ' + query);
			}
		} catch(QueryException qe) {
			throw new SIException(qe.getMessage() + ' : ' + query);
		}

		return null;
	}

	global void execute(Database.BatchableContext BC, List<SObject> scope) {
		System.debug('Indexing ' + contextParams.get('ocmsLang') + ' pages');

		List<OCMS_Content_Search_Index__c> csiList = new List<OCMS_Content_Search_Index__c>();
		cms__Page__c[] pScope = (cms__Page__c[])scope;

		String urlPrefix = String.isBlank(sitePrefix) ? '/' : '/' + sitePrefix + '/';

		List<String> cacheIds = new List<String>();
		String cacheType = String.isBlank(sitePrefix) ? '1' : '0';
        
        
        /*
        *   SR-48 - Modify recording of Index records to upsert existing index records rather than create a new entry for each publish/expire event.  This is
        *   for the Coveo implementation.
        */
        Set<Id> versionOriginIds = new Set<Id>();
        
        for(cms__Page__c p : pScope) {
            System.debug('page id in scope: ' + p.Id);
            versionOriginIds.add(p.cms__Version_Origin__c == null ? p.Id : p.cms__Version_Origin__c );
			cacheIds.add(p.Id + ':' + contextParams.get('ocmsLang') + ':' + cacheType);
        }
        
        /*
        *   SR-48 - Modify recording of Index records to upsert existing index records rather than create a new entry for each publish/expire event.  This is
        *   for the Coveo implementation.
        */
        Set<Id> versionLatestPublishedIds = new Set<Id>();
        for (cms__Page__c pg : [SELECT Id, cms__Version_Latest_Published__c FROM cms__Page__c WHERE Id IN :versionOriginIds]) {
            versionLatestPublishedIds.add(pg.cms__Version_Latest_Published__c == null ? pg.Id : pg.cms__Version_Latest_Published__c );
        }
        
        cms__Cache__c[] caches = [SELECT cms__Page__c, cms__Cache_Long__c from cms__Cache__c where cms__CSKey__c in :cacheIds AND cms__Page__c in :pScope];
		Map<String, String> cacheMap = new Map<String, String>();
		for(cms__Cache__c cache : caches) {
			cacheMap.put(cache.cms__Page__c, cache.cms__Cache_Long__c);
		}

		List<String> attachmentRequired = new List<String>();
		for(cms__Page__c p : pScope) {
			if(!cacheMap.containsKey(p.Id)) {
				attachmentRequired.add(p.Id);
			}
		}

		String attachmentTitle = String.isBlank(sitePrefix)
			? 'NoPrefixPageCache/' + contextParams.get('ocmsLang')
			: 'PageCache/' + contextParams.get('ocmsLang');
		Attachment[] attachmentCaches = [SELECT ParentId, Body FROM Attachment WHERE ParentId IN :attachmentRequired AND Name = :attachmentTitle];
		for(Attachment cache : attachmentCaches) {
			cacheMap.put(cache.ParentId, cache.Body.toString());
		}

        System.debug('version latest published ids: ' + versionLatestPublishedIds);
		for(cms__Page__c p : pScope) {
            
            // SR-48 - Only process content records which are the latest published version.  if the id fo the current
            // content record is not a latest published id, then skip to next iteration in loop.
            System.debug('page id: ' + p.id);
            
            if (!versionLatestPublishedIds.contains(p.Id)) {
                continue;
            }
            
			if(p.cms__Available_Languages__c == null || p.cms__Available_Languages__c.indexOf(contextParams.get('ocmsLang')) == -1) {
				System.debug('Page ID ' + p.Id + ' not translated into ' + contextParams.get('ocmsLang'));
				continue;
			}
			String originId = (p.cms__Version_Origin__c == null ? p.Id : p.cms__Version_Origin__c);
			String title = '';
			String description = '';
			String keywords = '';
			String url = urlPrefix;
			String name = '';

			Boolean expired = p.cms__Published_End_Date__c <= now;

			cms__Attribute__c urlAttribute = null;
			for(cms__Attribute__c a : p.cms__Attributes__r) {
				if(a.cms__Simple_Name__c == 'seo_name') {
					if(a.cms__Language__c != languageId && urlAttribute == null) {
						urlAttribute = a;
					} else if(a.cms__Language__c == languageId) {
						urlAttribute = a;
					}
				} else {
					if(!String.isBlank(a.cms__Meta_Page_Title__c)) title = a.cms__Meta_Page_Title__c;
					if(!String.isBlank(a.cms__Meta_Page_Description__c)) description = a.cms__Meta_Page_Description__c;
					if(!String.isBlank(a.cms__Meta_Page_Keywords__c)) keywords = a.cms__Meta_Page_Keywords__c;
					if(!String.isBlank(a.cms__Meta_Page_Name__c)) name = a.cms__Meta_Page_Name__c;
				}
			}

			if(urlRewritingEnabled) {
				url = urlPrefix + urlAttribute.cms__Simple_Value__c;
			} else {
				url = urlPrefix + 'cms__Main?name=' + urlAttribute.cms__Simple_Value__c;
			}

			String pageBody = cacheMap.get(p.Id);
			if(pageBody == null) continue;
			Integer headEnd = pageBody.indexOf('</head>');
			Integer bodyStart = pageBody.indexOf('<body', headEnd);
			if(bodyStart == -1) {
				System.debug('No body found for ID ' + p.Id);
				continue;
			}
			pageBody = pageBody.substring(bodyStart);

			Map<String, String> pageSearchAttributes = new Map<String, String> {
				'title' => title,
				'keywords' => keywords,
				'description' => description,
				'url' => url,
				'body' => pageBody
			};

			String serializedPageSearchAttributes = JSON.serialize(pageSearchAttributes);

			if(serializedPageSearchAttributes.length() > 131000) {
				Integer newBodyLength = pageBody.length() - (serializedPageSearchAttributes.length() - 131000);
				pageSearchAttributes.put('body', pageBody.substring(0, newBodyLength));
				serializedPageSearchAttributes = JSON.serialize(pageSearchAttributes);
			}

			OCMS_Content_Search_Index__c csi = new OCMS_Content_Search_Index__c();
			csi.Title__c = floorString(title, 255);
			csi.Description__c = floorString(description, 1000);
			csi.Content_Attribute_Names__c = '["body"]';
			csi.Documents__c = '[]';
			csi.TagPath__c = '[]';
			csi.Facets__c = '[]';
			csi.Thumbnail_URL__c = '';
			csi.Name__c = floorString(name, 255);
			csi.Attributes__c = serializedPageSearchAttributes;
			csi.Index_Key__c = originId + ':' + contextParams.get('ocmsLang');
			csi.PublishStartDate__c = p.cms__Published_Start_Date__c;
			csi.PublishEndDate__c = p.cms__Published_End_Date__c;
			csi.Status__c = expired ? 'expired' : 'new';
			csi.Type__c = 'Page';
			csi.Site_Name__c = this.siteName;
			csi.Language__c = contextParams.get('ocmsLang');
			csi.URL__c = floorString(url, 1000);
			if(this.siteName.contains('Employee_Community')) {
				csi.Location__c = 'MFCentral';
			} else {
				csi.Location__c = 'Manulife.com';
			}

			csiList.add(csi);
            System.debug('added csi record: ' + csi);
		}
		/*
        *   SR-48 - change insert to upsert to ensure we only have 1 index record per page/language combination.
        */
		upsert csiList Index_Key__c;
	}

	private String floorString(String str, Integer length) {
    	if(str == null) return null;
    	if(str.length() < length) return str;
    	return str.substring(0, length);
    }

	global void finish(Database.BatchableContext BC) {}
}