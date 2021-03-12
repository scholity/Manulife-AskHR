/**
 *
 * @description This is a wrapper around the Orchestra Global ServiceAPI class.
 *              The intention is to provide useful utilities for retrieving content renderings via taxonomy.
 * @author Jesse McGeachie
 *
 */

public with sharing class ocms_TaxonomyAPI {

    private cms.ServiceAPI sAPI;
    public Map<String, String> contentIdsMapping { get; set; }
    public Map<Id, String> contentRenderings { get; set; }
    public static Map<String, List<String>> contentIdsToPaths = new Map<String, List<String>>();
    public static Map<String, Set<String>> contentIdBuckets = new Map<String, Set<String>>();

    public ocms_TaxonomyAPI(cms.ServiceAPI serviceAPI) {
        sAPI = serviceAPI;
        this.contentIdsMapping = new Map<String, String>();
        this.contentRenderings = new Map<Id, String>();
    }

    /**
     * @description Get content renderings for all the contentIds
     * @param contentIds - Array of contentIds
     * @param contentLayout - The content layout for rendering
     * @return Map<Id, String> – A map of ContentId, Rendering
     */
    public Map<Id, String> getContentRenderingsForContentIds(List<String> contentIds, String contentLayout) {
        String [] layouts = new String[contentIds.Size()];

        for (Integer i = 0; i < contentIds.Size(); i++) {
            layouts[i] = contentLayout;
        }

        return getContentRenderingsForContentIds(contentIds, layouts);
    }

    /**
     * @description Get content renderings for all the contentIds
     * @param contentIds - List of contentIds
     * @param contentLayout - List of the contentLayouts
     * @return Map<Id, String> – A map of ContentId, Rendering
     */
    public Map<Id, String> getContentRenderingsForContentIds(List<String> contentIds, List<String> contentLayouts) {
        // This has the bug where we are not getting
        if (contentIds.size() == 0) {
            return new Map<Id, String>();
        }

        List<cms__Content__c> contents = new List<cms__Content__c>();

        for (String contentId : contentIds) {
            contents.add(new cms__Content__c(Id = contentId));
        }

        Map<Id, String> renderingMap = sApi.getGeneratedContent(contents, contentLayouts);
        if (renderingMap != null)
            return renderingMap;

        return new Map<Id, String>();
    }

    /**
     * @description Takes in a list of cms__Content_Origin__c and get the renderings for the latest version
     *              of that cms__Content_Origin__c content.
     * @param  List<String> - List of origin content ids to be rendered.
     * @param  String       - A single content layout to be redered.  All content will be rendered with this layout
     * @return Map<String, String> - A map of LatestContentId, and Renderin
     */
    public Map<Id, String> getLatestContentRenderingsForOriginContents(List<String> lContentOriginIds, String contentLayout) {
        return getLatestContentRenderingsForOriginContents(lContentOriginIds, this.generateLayoutListBySize(lContentOriginIds.size(), contentLayout));
    }

    /**
     * @description Takes in a list of cms__Content_Origin__c and get the renderings for the latest version
     *              of that cms__Content_Origin__c content.
     * @param  List<String> - List of origin content ids to be rendered.
     * @param  List<String> - A list of layouts to render content with. This will work as a parallel array between lContentOriginIds and contentLayouts
     * @return Map<String, String> - A map of LatestContentId, and Renderin
     */
    public Map<Id, String> getLatestContentRenderingsForOriginContents(List<String> lContentOriginIds, List<String> contentLayouts) {
        Map<Id, cms__Content__c> latestContentVersions = sApi.getLatestContentVersions(lContentOriginIds);

        // There is an issue with getting content latest version currently.  There has been times where content indexes
        // havent been generated for content.  An issue has been filed with support for this issue.
        //this.contentRenderings = sAPI.getGeneratedContent(latestContentVersions.values(), layouts);

        // We didn't get a redener that we expected
        if (lContentOriginIds.size() != latestContentVersions.values().size()) {
            System.debug('mismatched content layout records');
            Integer counter = 0;
            List<Integer> indexesToRemove = new List<Integer>();

            for (String contentOriginId : lContentOriginIds) {
                if (!latestContentVersions.containsKey(contentOriginId)) {
                    indexesToRemove.add(counter);
                }

                counter++;
            }

            for (Integer i = indexesToRemove.size() - 1; i >= 0; i--) {
                contentLayouts.remove(indexesToRemove[i]);
            }
        }


        this.contentRenderings = sAPI.getGeneratedContent(latestContentVersions.values(), contentLayouts);
        this.contentIdsMapping = new Map<String, String>();

        for (String latestContentVersionId : latestContentVersions.keySet()) {
            cms__Content__c latestContent = latestContentVersions.get(latestContentVersionId);
            String latestContentOriginId = (latestContent.cms__Version_Origin__c == null) ? latestContent.Id : latestContent.cms__Version_Origin__c;
            this.contentIdsMapping.put(latestContentOriginId, latestContent.Id);
        }

        return this.contentRenderings;
    }

    /**
     * @description Generates a list of strings based on the size passed and the layout name passed.
     *              This is useful when using the service API to render content where it needs a list
     *              of the content layouts for each piece of content passed.
     * @param  Integer size          The size of the list that is being requested.
     * @param  String  layoutName    The layout name that you want. This layout name will be same
     *                               for every item in the list.
     * @return         List<String> of layout names.
     */
    public List<String> generateLayoutListBySize(Integer size, String layoutName) {
        String [] layouts = new String[size];

        for (Integer i = 0; i < size; i++) {
            layouts[i] = layoutName;
        }

        return layouts;
    }

    /**
     * @description Get all content renderings for content that is tagged at every pathList
     *              Assume taxonomy: Main/Location/Kingston - Main/BusinessUnit
     *              The Pathlist we send is
     *                  List {
     *                          List{'Main/Location/Kingston', 'Main/Location/Ottawa'},
     *                          List{'Main/BusinessUnit'}
     *                  }
     *              If a content item is tagged at only Main/Location/Kingston, It will not be retrieved because it also needs to be tagged at Main/BusinessUnit
     *              If a content item is tagged at Main/Location/Kingston AND Main/BusinessUnit, it will be retrieved because it is in all path lists
     * @param pathLists - A list of lists of paths
     * @param contentType - The content type
     * @param contentLayout - The content layout for rendering
     * @param order - sort order (date = Original Published Start Date)
     * @return Map<Id, String> – Map of ContentIds and Renderings
     */
    public Map<Id, String> getContentRenderingsFromMultiplePathLists(List<List<String>> pathLists, String contentType, String contentLayout, String order, Integer maxItems, Integer offset) {
        List<String> contentIds = getContentIdsFromMultiplePathLists(pathLists, contentType, order, maxItems, offset);

        return getLatestContentRenderingsForOriginContents(contentIds, contentLayout);
    }

    /**
     * @description Get all content Ids for content tagged at exactly this path
     *              Path A/B/C/D would return content tagged at exactly A/B/C/D only
     * @param fullPath - The full path
     * @param contentType - The content type
     * @param order - sort order (date = Original Published Start Date)
     * @param maxItems - maximum number of items to retrieve
     * @param offset - the offset
     * @return List<String> – A list of content Ids
     */
    public List<String> getContentIdsForPath(String fullPath, String contentType, String order, Integer maxItems, Integer offset) {
        return getContentIdsForPathList(new List<String>{
                fullPath
        }, contentType, order, maxItems, offset);
    }


    /**
     * @description Get all content Ids for each given path
     * @param pathList - A list of paths to get Ids from
     * @param contentType - The content type
     * @param order - sort order (date = Original Published Start Date)
     * @param maxItems - maximum number of items to retrieve
     * @param offset - the offset
     * @return List<String> – A list of content Ids
     */
    public List<String> getContentIdsForPathList(List<String> pathList, String contentType, String order, Integer maxItems, Integer offset) {
        List<cms.ServiceApi.ContentObject> results = sApi.getContentObjectsByTaxonomyPaths(order, pathList, contentType, null, maxItems, offset);
        List<String> contentIds = new List<String>();

        for (cms.ServiceApi.ContentObject co : results) {
            contentIds.add(co.contentId);
        }

        return contentIds;
    }


    /**
     * @description Get all content Ids for a given path and all levels below it
     * @param pathList - A list of paths to get Ids from
     * @param contentType - The content type
     * @param order - sort order (date = Original Published Start Date)
     * @param maxItems - maximum number of items to retrieve
     * @param offset - the offset
     * @param contentLayouts - A list of contentLayouts, the size of this list determines the depth of the Taxonomy levels to grab content IDs from
     * @return List<String> – A list of content Ids
     */
    public List<String> getContentIdsForMultiplePathLevels(List<String> pathList, String contentType, String order, Integer maxItems, Integer offset, List<String> contentLayouts) {
        List<cms.ServiceApi.ContentObject> results = sApi.getContentObjectsByTaxonomyPaths(order, pathList, contentType, contentLayouts, maxItems, offset);
        List<String> contentIds = new List<String>();

        for (cms.ServiceApi.ContentObject co : results) {
            contentIds.add(co.contentId);
        }

        return contentIds;
    }


    public Map<String, List<String>> getTagsAtAncestryNode(String contentId, String fullPath) {
        return getTagsAtAncestryNode(new Set<String>{
                contentId
        }, fullPath);
    }

    public Map<String, List<String>> getTagsAtAncestryNode(Set<String> contentIds, String fullPath) {
        Map<String, List<List<cms__Tag__c>>> tagsForContents = sApi.getActiveTagsForContent(contentIds);
        Map<String, List<String>> mContentsByTag = new Map<String, List<String>>();

        List<String> splitPath = fullPath.startsWith('/') ? fullPath.removeStart('/').split('/') : fullPath.split('/');

        if (splitPath.size() > 1 && splitPath.size() < 7) {
            Integer lastTagDepth = splitPath.size() - 1;
            String lastTagInPath = splitPath[lastTagDepth];

            String lastAncestorAccessor = 'cms__Ancestor' + lastTagDepth + '__c';

            for (String contentId : tagsForContents.keySet()) {
                String desiredPathId = '';
                for (List<cms__Tag__c> tags : tagsForContents.get(contentId)) {
                    for (cms__Tag__c tag : tags) {
                        if (String.isEmpty(desiredPathId) && tag.cms__Depth__c == lastTagDepth && tag.cms__Tag_Definition_Name__c == lastTagInPath) {
                            desiredPathId = tag.cms__Tag_Definition__c;
                        }

                        if (String.isNotBlank(desiredPathId) && tag.get(lastAncestorAccessor) == desiredPathId) {
                            String tagName = tag.cms__Tag_Definition__r.cms__Name__c;

                            if (mContentsByTag.containsKey(contentId)) {
                                mContentsByTag.get(contentId).add(tagName);
                            } else {
                                mContentsByTag.put(contentId, new List<String>{
                                        tagName
                                });
                            }
                        }
                    }
                }
            }
        }

        return mContentsByTag;
    }


    /**
     * @description Get all content Ids for content that is tagged at every pathList
     *              Assume taxonomy: Main/Location/Kingston - Main/BusinessUnit
     *              The Pathlist we send is
     *                  List {
     *                          List{'Main/Location/Kingston', 'Main/Location/Ottawa'},
     *                          List{'Main/BusinessUnit'}
     *                  }
     *              If a content item is tagged at only Main/Location/Kingston, It will not be retrieved because it also needs to be tagged at Main/BusinessUnit
     *              If a content item is tagged at Main/Location/Kingston AND Main/BusinessUnit, it will be retrieved because it is in all path lists
     * @param pathLists - A list of lists of paths
     * @param contentType - The content type
     * @param order - sort order (date = Original Published Start Date)
     * @param maxItems - maximum number of items to retrieve
     * @param offset - the offset
     * @return List<String> – A list of content Ids
     */
    public List<String> getContentIdsFromMultiplePathLists(List<List<String>> pathLists, String contentType, String order, Integer maxItems, Integer offset) {
        return getContentIdsFromMultiplePathListsOld(pathLists, contentType, order, maxItems, offset);
    }

    public List<String> getContentIdsFromMultiplePathListsNew(List<List<String>> pathLists, String contentType, String order, Integer maxItems, Integer offset) {
        List<String> tagList = new List<String>();
        for (List<String> pathList : pathLists) {
            tagList.addAll(pathList);
            for (Integer i = 0; i < pathList.size(); ++i) {
                pathList[i] = pathList[i].removeStart('/').removeEnd('/');
            }
        }

        List<cms.ServiceApi.ContentObject> results = new List<cms.ServiceApi.ContentObject>();
        List<String> resultIds = new List<String>();

        if (Test.isRunningTest()) {
            cms.ServiceApi.ContentObject co = new cms.ServiceApi.ContentObject();
            co.PathList = new List<String>{
                    '/master/taxonomy/cake'
            };
            results.add(co);
        } else {
            results = sApi.getContentObjectsByTaxonomyPaths(order, tagList, contentType, null, maxItems, offset);
        }

        for (cms.ServiceApi.ContentObject co : results) {
            resultIds.add(co.contentId);
        }

        Boolean matches;
        Boolean matchesDimension;
        for (cms.ServiceApi.ContentObject co : results) {
            for (Integer i = 0; i < co.PathList.size(); ++i) {
                co.PathList[i] = co.PathList[i].removeStart('/').removeEnd('/');
            }

            matches = true;
            for (List<String> andDimension : pathLists) {
                matchesDimension = false;
                for (String andDimensionPath : andDimension) {
                    for (String path : co.PathList) {
                        matchesDimension = matchesDimension || (path == andDimensionPath);
                        if (matchesDimension) break;
                    }
                    if (matchesDimension) break;
                }
                matches = matches && matchesDimension;
                if (!matches) break;
            }

            if (matches) {
                for (String path : co.PathList) {
                    String dimension = path.substringBetween('/', '/');
                    if (dimension == null) {
                        dimension = path.substringAfter('/');
                    }
                    if (!contentIdBuckets.containsKey(dimension)) {
                        contentIdBuckets.put(dimension, new Set<String>());
                    }
                    contentIdBuckets.get(dimension).add(co.contentId);
                }
                resultIds.add(co.contentId);
            }
        }

        return resultIds;
    }

    public List<String> getContentIdsFromMultiplePathListsOld(List<List<String>> pathLists, String contentType, String order, Integer maxItems, Integer offset) {
        Map<String, Set<String>> resultMap = new Map<String, Set<String>>();
        List<String> tagList = new List<String>();
        List<String> andDimensions = new List<String>();

        // Bucket the paths into Dimensions for Anding
        // A Dimension is the second level of the taxonomy: EX /Master/Location/Canada - Here Location is the dimension
        // Anding is only done on this Dimension and uses only the dimension of the first path in the list
        for (List<String> paths : pathLists) {
            tagList.addAll(paths);

            if (paths.size() > 0) {
                String modPath = paths[0].removeStart('/').substringBetween('/', '/');

                // Given a path of "/Master Tax/Waffles", the above line returns null, so lets use the path after the first /
                if (modPath == null) {
                    modPath = paths[0].removeStart('/').substringAfter('/');
                }

                andDimensions.add(modPath);

                for (String path : paths) {
                    String modPath2 = path.removeStart('/').substringBetween('/', '/');

                    // Given a path of "/Master Tax/Waffles", the above line returns null, so lets use the path after the first /
                    if (modPath2 == null) {
                        modPath2 = path.removeStart('/').substringAfter('/');
                    }

                    if (!resultMap.containsKey(modPath2)) {
                        resultMap.put(modPath2, new Set<String>());
                    }
                }
            }
        }

        List<cms.ServiceApi.ContentObject> results = new List<cms.ServiceApi.ContentObject>();

        if (Test.isRunningTest()) {
            cms.ServiceApi.ContentObject co = new cms.ServiceApi.ContentObject();
            co.PathList = new List<String>{
                    '/master/taxonomy/cake'
            };
            results.add(co);
        } else {
            results = sApi.getContentObjectsByTaxonomyPaths(order, tagList, contentType, null, maxItems, offset);
        }

        // Bucket the content we receieved into the dimension it falls into
        for (cms.ServiceApi.ContentObject co : results) {
            for (String path : co.PathList) {
                String dimension = path.removeStart('/').substringBetween('/', '/');

                if (dimension == null) {
                    dimension = path.removeStart('/').substringAfter('/');
                }

                try {
                    resultMap.get(dimension).add(co.contentId);
                } catch (Exception e) {
                    System.debug('fail silently: ' + dimension);
                }
            }
        }

        Set<String> masterSet = new Set<String>();
        contentIdBuckets = resultMap;

        // Filter all content out that does not meet every Anding dimension
        if (andDimensions.size() > 0) {
            Boolean first = true;
            for (String key : andDimensions) {
                if (first) {
                    first = false;
                    masterSet.addAll(resultMap.get(key));
                } else {
                    masterSet.retainAll(resultMap.get(key));
                }
            }
        }

        // Put the content back into proper order (This may not be needed if Set's retain order)
        List<String> orderedResults = new List<String>();
        for (cms.ServiceApi.ContentObject co : results) {
            if (masterSet.contains(co.contentId)) {
                orderedResults.add(co.contentId);
            }
        }

        return orderedResults;
    }

    /**
     * @description Get all paths that each contentId is tagged at
     * @param contentIds - Set of contentIds to get paths for
     * @return Map<String, List<String>> - contentId : list of paths
     */
    public Map<String, List<String>> getPathsForContentIds(Set<String> contentIds) {
        return getPathsForContentIds(contentIds, true);
    }

    public Map<String, List<String>> getPathsForContentIds(Set<String> contentIds, Boolean useStaticCache) {
        Map<String, List<String>> mapOfPaths = new Map<String, List<String>>();

        Set<String> newContentIds = new Set<String>();

        for (String contentId : contentIds) {
            if (contentIdsToPaths.containsKey(contentId) && useStaticCache) {
                mapOfPaths.put(contentId, contentIdsToPaths.get(contentId));
            } else {
                newContentIds.add(contentId);
            }
        }

        if (newContentIds.Size() > 0) {
            Map<String, List<List<cms__Tag__c>>> mapOfActiveTags = sAPI.getActiveTagsForContent(newContentIds);

            // Go through each content id given
            for (String contentId : newContentIds) {
                List<String> pathsForContentId = new List<String>();
                // If there are tags for that contentId go through each one and build up paths
                if (mapOfActiveTags.containsKey(contentId)) {
                    List<List<cms__Tag__c>> currentTagList = mapOfActiveTags.get(contentId);
                    for (List<cms__Tag__c> tagList : currentTagList) {
                        String path = '/';
                        for (cms__Tag__c tag : tagList) {
                            path += tag.cms__Tag_Definition__r.cms__Name__c + '/';
                        }

                        path = path.removeEnd('/');
                        pathsForContentId.add(path);
                    }

                    contentIdsToPaths.put(contentId, pathsForContentId);
                }

                mapOfPaths.put(contentId, pathsForContentId);
            }
        }

        return mapOfPaths;
    }

    /**
    * @description Get all paths that each contentId is tagged at
    * @return Map<String, List<String>> - contentId : list of paths
    */
    public Map<String, List<String>> getPathsForContentIds(List<String> contentIds, Boolean useStaticCache) {
        return getPathsForContentIds(new Set<String>(contentIds), useStaticCache);
    }

    public Map<String, List<String>> getPathsForContentIds(List<String> contentIds) {
        return getPathsForContentIds(new Set<String>(contentIds));
    }

    /**
     * @description Get all paths between two paths
     *              Assume taxonomy: A/B/C/D/E/F/G/H, fromPath=A/B/C, toPath=A/B/C/D/E/F
     *              Paths would be returned at:
     *              A/B/C, A/B/C/D, A/B/C/D/E and A/B/C/D/E/F
     * @param fromPath - The full path to the STARTING tag
     * @param toPath - The full path to the ENDING tag
     * @return List<String> – A list of paths
     */
    public List<String> buildPathFromPathToPath(String fromPath, String toPath) {
        fromPath = normalizeTagPath(fromPath);
        toPath = normalizeTagPath(toPath);

        if (!toPath.contains(fromPath)) {
            return new List<String>();
        }

        List<String> toPathSubPaths = new List<String>();
        getSubPaths(toPath, toPathSubPaths);

        List<String> myPaths = new List<String>();
        for (String subPath : toPathSubPaths) {
            if (subPath.equals(fromPath)) {
                myPaths.add(subPath);
                break;
            } else {
                myPaths.add(subPath);
            }
        }

        return myPaths;
    }

    private String normalizeTagPath(String tagPath) {
        if (!tagPath.startsWith('/')) {
            tagPath = '/' + tagPath;
        }

        if (tagPath.endsWith('/')) {
            tagPath = tagPath.substring(0, tagPath.length() - 1);
        }

        return tagPath;
    }

    private void getSubPaths(String fullPath, List<String> subPaths) {
        fullPath = normalizeTagPath(fullPath);
        subPaths.add(fullPath);

        if (fullPath.lastIndexOf('/') != -1) {
            String subPath = fullPath.substring(0, fullPath.lastIndexOf('/'));
            getSubPaths(subPath, subPaths);
        }
    }

}