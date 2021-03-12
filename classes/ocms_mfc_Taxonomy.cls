global with sharing class ocms_mfc_Taxonomy {
	// Used for getting our default taxonomy name for notifications

	private cms.ServiceAPI sAPI;
	public static Map<String, cms.TaxonomyNodeInfo> taxonomyInfoNodes = new Map<String, cms.TaxonomyNodeInfo>();

	public static User user {
        get {
            if (user == null) {
            	user = [SELECT MFC_Country__c, State__c, City__c, Business_Unit__c, MFC_Division__c, Is_Manager__c FROM User WHERE Id = :UserInfo.getUserId()];
            }

            return user;
        } set;
    }

	public ocms_mfc_Taxonomy(cms.ServiceAPI serviceAPI) {
		sAPI = serviceAPI;
	}

	private static Set<String> userNewsSubscriptionPaths;


	/**
     * @description Get all content Ids for content that is tagged at every pathList
     *				Assume taxonomy: Main/Location/Kingston - Main/BusinessUnit
     *				The Pathlist we send is
     *					List {
 	 *							List{'Main/Location/Kingston', 'Main/Location/Ottawa'},
 	 *							List{'Main/BusinessUnit'}
 	 *					}
     *				If a content item is tagged at only Main/Location/Kingston, It will not be retrieved because it also needs to be tagged at Main/BusinessUnit
     *				If a content item is tagged at Main/Location/Kingston AND Main/BusinessUnit, it will be retrieved because it is in all path lists
     * @param pathLists - A list of lists of paths
     * @param contentType - The content type
     * @param order - sort order (date = Original Published Start Date)
     * @param maxItems - maximum number of items to retrieve
     * @param offset - the offset
     * @return List<String> – A list of content Ids
     */
	public List<String> getContentIdsForTaxonomies(List<List<String>> pathLists, String contentType, String order, Integer maxItems, Integer offset) {
		ocms_TaxonomyAPI taxonomyAPI = new ocms_TaxonomyAPI(sAPI);
		List<String> contentIds = new List<String>();

		if(pathLists.Size() == 1) {
			contentIds = taxonomyAPI.getContentIdsForPathList(pathLists[0], contentType, order, maxItems, offset);
		}
		else if(pathLists.Size() > 1) {
			contentIds = taxonomyAPI.getContentIdsFromMultiplePathLists(pathLists, contentType, order, maxItems, offset);
		}

		if (Test.isRunningTest()) {
			contentIds = new List<String>{'a0bW0000001Isq1','a0bW0000001Isq2','a0bW0000001Isq3','a0bW0000001Isq4','a0bW0000001Isq5','a0bW0000001Isq6','a0bW0000001Isq7'};
		}

		return contentIds;
	}

	/**
     * @description Get all content renderings for content that is tagged at every pathList
     *				Assume taxonomy: Main/Location/Kingston - Main/BusinessUnit
     *				The Pathlist we send is
     *					List {
 	 *							List{'Main/Location/Kingston', 'Main/Location/Ottawa'},
 	 *							List{'Main/BusinessUnit'}
 	 *					}
     *				If a content item is tagged at only Main/Location/Kingston, It will not be retrieved because it also needs to be tagged at Main/BusinessUnit
     *				If a content item is tagged at Main/Location/Kingston AND Main/BusinessUnit, it will be retrieved because it is in all path lists
     * @param pathLists - A list of lists of paths
     * @param contentType - The content type
     * @param contentLayout - The content layout for rendering
     * @param order - sort order (date = Original Published Start Date)
     * @return Map<Id, String> – Map of ContentIds and Renderings
     */
	public Map<Id, String> getContentRenderingsForTaxonomies(List<List<String>> pathLists, String contentType, String contentLayout, String order, Integer maxItems, Integer offset) {
		Map<Id, String> contentRenderings = new Map<Id, String>();
		ocms_TaxonomyAPI taxonomyAPI = new ocms_TaxonomyAPI(sAPI);

		return taxonomyAPI.getContentRenderingsFromMultiplePathLists(pathLists, contentType, contentLayout, order, maxItems, offset);
	}

	/* AJL - should this function be renamed to getLocationPathListForRunningUser? The fact the location path list is specific to the running user seems to be a critically important aspect so a rename would make it more obvious what this function does? */
	public List<String> getLocationPathList() {
		Map<String, String> sitePreferences = ocms_mfc_SitePreferences.getSitePreferences();
		ocms_TaxonomyAPI taxonomyAPI = new ocms_TaxonomyAPI(sAPI);

			return taxonomyAPI.buildPathFromPathToPath(
				sitePreferences.get('locationTaxonomy') + '/',
				sitePreferences.get('locationTaxonomy') + '/' + user.MFC_Country__c + '/' + user.City__c);
	}

	public List<String> getDivisionPathListForUser() {
		Map<String, String> sitePreferences = ocms_mfc_SitePreferences.getSitePreferences();
		ocms_TaxonomyAPI taxonomyAPI = new ocms_TaxonomyAPI(sAPI);

		return taxonomyAPI.buildPathFromPathToPath(
			sitePreferences.get('divisionTaxonomy') + '/',
			sitePreferences.get('divisionTaxonomy') + '/' + user.MFC_Division__c + '/' + user.Business_Unit__c + '/');
	}

	public String getEmployeeTypeAllPath() {
		Map<String, String> sitePreferences = ocms_mfc_SitePreferences.getSitePreferences();
		String allEmployeePath = sitePreferences.get('employeeTypeContributorTaxonomy');
		if (allEmployeePath != null) {
			allEmployeePath = allEmployeePath.removeEnd('/').substringBeforeLast('/').removeEnd('/');
		} else {
			allEmployeePath = '';
		}

		return allEmployeePath;
	}

	public List<String> getEmployeeTypePathListForUser() {
		Map<String, String> sitePreferences = ocms_mfc_SitePreferences.getSitePreferences();
		ocms_TaxonomyAPI taxonomyAPI = new ocms_TaxonomyAPI(sAPI);
		String allEmployeePath = sitePreferences.get('employeeTypeContributorTaxonomy');

		if (allEmployeePath != null) {
			allEmployeePath = allEmployeePath.removeEnd('/').substringBeforeLast('/').removeEnd('/');
		} else {
			return new List<String>();
		}

		return taxonomyAPI.buildPathFromPathToPath(
			allEmployeePath + '/',
			(user.Is_Manager__c ? sitePreferences.get('employeeTypePeopleManagerTaxonomy') : sitePreferences.get('employeeTypeContributorTaxonomy')) + '/');
	}

	public List<String> getAllNewsCategories() {
		//Map<String, String> sitePreferences = ocms_mfc_SitePreferences.getSitePreferences();

		//return getPathsForChildrenOfPath(sApi,  sitePreferences.get('newsCategoryTaxonomy'), false);

		List <String> defaultNewsPaths = new List <String> ();
		Map<String, String> sitePreferences = ocms_mfc_SitePreferences.getSitePreferences();
		String mandatoryPaths = sitePreferences.get('mandatoryNewsPaths');
		Map<String, Object> mandatoryPathsMap = new Map<String, Object>();

		if (mandatoryPaths != null) {
			mandatoryPathsMap = (Map<String, Object>) JSON.deserializeUntyped(mandatoryPaths);

			for (Object path : mandatoryPathsMap.values()) {
				defaultNewsPaths.add((String)path);
			}
		}

		return defaultNewsPaths;
	}

	public List<String> getAllMandatoryCategories() {
		List <String> defaultNewsPaths = new List <String> ();
		Map<String, String> sitePreferences = ocms_mfc_SitePreferences.getSitePreferences();
		String mandatoryPaths = sitePreferences.get('mandatoryNewsPaths');
		Map<String, Object> mandatoryPathsMap = new Map<String, Object>();

		if (mandatoryPaths != null) {
			mandatoryPathsMap = (Map<String, Object>) JSON.deserializeUntyped(mandatoryPaths);

			for (Object path : mandatoryPathsMap.values()) {
				defaultNewsPaths.add((String)path);
			}
		}

		return defaultNewsPaths;
	}

	public String getAppCategories() {
		Map<String, String> sitePreferences = ocms_mfc_SitePreferences.getSitePreferences();

		return sitePreferences.get('appCategoriesTaxonomy') + '/';
	}

	public List<String> getArticleCategories() {
		Map<String, String> sitePreferences = ocms_mfc_SitePreferences.getSitePreferences();

		return new List<String> {sitePreferences.get('articleCategoriesTaxonomy') + '/'};
	}

	public String getFeaturedPath() {
	    Map<String, String> sitePreferences = ocms_mfc_SitePreferences.getSitePreferences();

	    return '/' + sitePreferences.get('featuredItemTagPath');
	}

		/**
	 * @description - Gets all paths from the given path and it's immediate children (One Level Deeper) :)
	 *		given a structure of master/location/{Ontario, Quebec, Alberta}
	 *		if we sent the path of master/location/ it would return the paths
	 *			master/location/ontario
	 *			master/location/Alberta
	 *			master/location/Quebec
	 *		if includeParent is set to true it will include the following path as the first element in the list
	 *			master/location
	 * @param path - the path to start with
	 * @param includeParent - whether to include the path that was passed in as part of the result
	 * @return List<String> - The paths for the given node and it's immediate children
	 */
	public static List<String> getPathsForImmediateChildrenOfPath(cms.ServiceAPI sApi, String path, Boolean includeParent) {
		cms.TaxonomyNodeInfo taxonomyNodeInfo = getTaxonomyNodeInfoAtPath(sApi, path);
		List<String> pathList = new List<String>();

		if (taxonomyNodeInfo != null) {
			if (includeParent) {
				pathList.add('/' + taxonomyNodeInfo.getParentPath() + '/' + taxonomyNodeInfo.getName());
			}

			for(cms.TaxonomyNodeInfo taxonomyRootNodeChild : taxonomyNodeInfo.getChildren()) {
				pathList.add('/' + taxonomyRootNodeChild.getParentPath() + '/' + taxonomyRootNodeChild.getName());
			}
		}

		return pathList;
	}

	/**
	 * @description - Gets all paths from the given path and it's children
	 *		given a structure of /location/ontario/{Kingston, Toronto, Ottawa}
	 *		if we sent the path of /location/ontario it would return the paths
	 *			/location/ontario/Kingston
	 *			/location/ontario/Toronto
	 *			/location/ontario/Ottawa
	 *		if includeParent is set to true it will include the following path as the first element in the list
	 *			/location/ontario
	 * @param path - the path to start with
	 * @param includeParent - whether to include the path that was passed in as part of the result
	 * @return List<String> - The paths for the given node and all of its children
	 */
	public static List<String> getPathsForChildrenOfPath(cms.ServiceAPI sApi, String path, Boolean includeParent) {
		cms.TaxonomyNodeInfo taxonomyNodeInfo = getTaxonomyNodeInfoAtPath(sApi, path);
		List<String> pathList = new List<String>();

		if (taxonomyNodeInfo != null) {
			pathList.addAll(getPathsForChildrenOfTaxonomyNodeInfo(taxonomyNodeInfo, true));
		}

		if (!includeParent) {
			if (pathList.size() > 0) {
				pathList.remove(0);
			}
		}

		return pathList;
	}

		/**
	 * @description - Gets all paths from the given path and it's children
	 *		given a structure of /location/ontario/{Kingston, Toronto, Ottawa}
	 *		if we sent the path of /location/ontario it would return the paths
	 *			/location/ontario/Kingston
	 *			/location/ontario/Toronto
	 *			/location/ontario/Ottawa
	 *		if includeParent is set to true it will include the following path as the first element in the list
	 *			/location/ontario
	 * @param path - the path to start with
	 * @param includeParent - whether to include the path that was passed in as part of the result
	 * @return List<String> - The paths for the given node and all of its children
	 */
	public static List<String> getNodeNamesForChildrenOfPath(cms.ServiceAPI sApi, String path, Boolean includeParent) {
		cms.TaxonomyNodeInfo taxonomyNodeInfo = getTaxonomyNodeInfoAtPath(sApi, path);
		List<String> pathList = new List<String>();

		if (taxonomyNodeInfo != null) {
			pathList.addAll(getPathsForChildrenOfTaxonomyNodeInfo(taxonomyNodeInfo, false));
		}

		if (!includeParent) {
			if (pathList.size() > 0) {
				pathList.remove(0);
			}
		}

		return pathList;
	}

	/**
	 * @description - Gets all nodes that are immediate descendants of the node at the path specified
	 * @param sApi - instantiated serviceApi
	 * @param path - full path to the node whose descendants should be returned
	 */
	public static List <cms.TaxonomyNodeInfo> getChildNodes (cms.ServiceAPI sApi, String path) {
		cms.TaxonomyNodeInfo node = getTaxonomyNodeInfoAtPath (sApi, path);
		List <cms.TaxonomyNodeInfo> childNodes = new List<cms.TaxonomyNodeInfo>();

		if (node != null) {
			childNodes = node.getChildren();
		}
		
		return childNodes;
	}

	/**
	 * @description - Gets all paths from the given node and it's children
	 *		given a structure of /location/ontario/{Kingston, Toronto, Ottawa}
	 *		if we sent the node at the path of /location/ontario, we would get the following results
	 *			/location/ontario
	 *			/location/ontario/Kingston
	 *			/location/ontario/Toronto
	 *			/location/ontario/Ottawa
	 * @param taxonomyNode - the taxonomyNodeInfo to to start with
	 * @return List<String> - The paths for the given node and all of its children
	 */
	private static List<String> getPathsForChildrenOfTaxonomyNodeInfo(cms.TaxonomyNodeInfo taxonomyNode, Boolean getFullPath) {
		List<String> pathList = new List<String>();

		if (getFullPath) {
			pathList.add('/' + taxonomyNode.getParentPath() + '/' + taxonomyNode.getName());
		} else {
			pathList.add(taxonomyNode.getName());
		}

		if (taxonomyNode.hasChildren()) {
			for(cms.TaxonomyNodeInfo taxonomyRootNodeChild : taxonomyNode.getChildren()) {
				pathList.addAll(getPathsForChildrenOfTaxonomyNodeInfo(taxonomyRootNodeChild, getFullPath));
			}
		}

		return pathList;
	}

	/**
	 * @description Retrieves information for the last node in the given path
	 * @param path - the path to the final node
	 * @return cms.TaxonomyNodeInfo - information about the final node specified in the path
	 */
	public static cms.TaxonomyNodeInfo getTaxonomyNodeInfoAtPath(cms.ServiceAPI sApi, String path) {
	    if (path == null) {
	        return null;
	    }

		if (path.subString(0, 1) == '/') {
			path = path.substring(1);
		}

		if (taxonomyInfoNodes.containsKey(path)) {
			return taxonomyInfoNodes.get(path);
		}

		// Collection of all of the nodes from the root of the taxonomy
		cms.TaxonomyNodeInfo currentNode = getTaxonomyRootNode(sApi, path);

		if (currentNode != null) {
			List<String> tags = path.split('/');
			Integer currentTagCount = 1;

			// This will start at the children and go until we have no tags left
			while (currentTagCount < tags.Size()) {
				Boolean found = false;

				for (cms.TaxonomyNodeInfo child : currentNode.getChildren()) {
					if (child.getName() == tags[currentTagCount]) {
						currentNode = child;
						found = true;
						break;
					}
				}

				if (!found) {
					currentNode = null;
					break;
				}

				currentTagCount++;
			}

			if (currentNode != null) {
				taxonomyInfoNodes.put(path, currentNode);
			}
		}

		return currentNode;
	}

	/**
	 * @description - Gets the taxonomies root node based on a path
	 *		If we sent it /tr - test taxonomy/location/canada/ontario/kingston this would return the
	 *  	cms.TaxonomyNodeInfo object for 'tr - test taxonomy' and ignores all the tags after it (location/canada/...)
	 * @param sApi - Service API
	 * @param path - The path which contains the taxonomy name, ignores extra tags on the path
	 * @return cms.TaxonomyNodeInfo - The taxonomyNodeInfo of the root of the given path
	 */
	private static cms.TaxonomyNodeInfo getTaxonomyRootNode(cms.ServiceAPI sApi, String path) {
		cms.TaxonomyNodeInfo taxonomyNodeInfo = null;

		List<String> tags = path.startsWith('/') ? path.removeStart('/').split('/') : path.split('/');

		if (tags.Size() > 0) {
			String rootTag = tags[0];
			if (!taxonomyInfoNodes.containsKey(rootTag)) {
				Map<String, cms.TaxonomyInfo> taxonomyNodesInfo = null;
				
				try {
					taxonomyNodesInfo = sApi.getTaxonomyInfo(new List<String> {rootTag});
				} catch (Exception e) {
					System.debug('Failed to get taxonomy: ' + rootTag);
				}

				if (taxonomyNodesInfo != null) {
					taxonomyNodeInfo = taxonomyNodesInfo.get(rootTag).getTaxonomy();
					taxonomyInfoNodes.put(rootTag, taxonomyNodeInfo);
				}
			} else {
				taxonomyNodeInfo = taxonomyInfoNodes.get(rootTag);
			}
		}

		return taxonomyNodeInfo;
	}

	/**
	 * @description - Gets the full taxonomy paths for each news subscription the user is subscribed to (including mandatory ones)
	 * 					Optional ones are stored in the MyPreferences__c object and mandatory ones are set in site preferences
	 * @return List <String> - A list of full paths to each news subscription node
	 */
	public List <String> getUserNewsSubscriptionPaths () {
		List <String> defaultNewsPaths = new List <String> ();
		Map<String, String> sitePreferences = ocms_mfc_SitePreferences.getSitePreferences();
		String newsPath = sitePreferences.get('newsCategoryTaxonomy');
		String mandatoryPaths = sitePreferences.get('mandatoryNewsPaths');
		Map<String, Object> mandatoryPathsMap = new Map<String, Object>();

		if (mandatoryPaths != null) {
			mandatoryPathsMap = (Map<String, Object>) JSON.deserializeUntyped(mandatoryPaths);

			for (Object path : mandatoryPathsMap.values()) {
				defaultNewsPaths.add((String)path);
			}
		}
		
		// get subscribed paths
		if (userNewsSubscriptionPaths == null) {
			userNewsSubscriptionPaths = new Set<String>();
			RecordType prefRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'MFC_Community_Object__c' AND DeveloperName = 'My_Preferences'];
			List<MFC_Community_Object__c> userPreferences = [SELECT PrimaryLanguage__c, DailyDigest__c, Subscriptions__c FROM MFC_Community_Object__c p WHERE User__r.Id = :UserInfo.getUserId() AND RecordTypeId = :prefRecordType.Id];

			if (userPreferences.isEmpty()) {
				userNewsSubscriptionPaths.addAll(getNodeNamesForChildrenOfPath(sApi, newsPath, false));
				ocms_mfc_MyPreferences.saveDefaultPreferences(UserInfo.getUserId(), String.join(new List<String>(userNewsSubscriptionPaths), '~~~~'));
				List<String> newPaths = defaultNewsPaths;

				for (String newsNodeName : userNewsSubscriptionPaths)
					newPaths.add('/' + newsPath + '/' + newsNodeName);

				return newPaths;
			}

			if (userPreferences[0].Subscriptions__c == null)
				return defaultNewsPaths;

			List <String> subscriptions = userPreferences[0].Subscriptions__c.split('~~~~');

			if (subscriptions.isEmpty())
				return defaultNewsPaths;

			for (String newsNodeName : subscriptions)
				userNewsSubscriptionPaths.add('/' + newsPath + '/' + newsNodeName);
		}

		userNewsSubscriptionPaths.addAll(defaultNewsPaths);

		return new List<String>(userNewsSubscriptionPaths);
	}
}