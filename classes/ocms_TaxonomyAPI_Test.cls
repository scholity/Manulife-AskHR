@isTest
private class ocms_TaxonomyAPI_Test {
    static testMethod void testCalls() {
        ocms_TestContentHelper tch = new ocms_TestContentHelper();
        List<Map<String,String>> attr_map = new List<Map<String, String>>();
        Map<String, String> am = new Map<String, String>();
        tch.createContent(attr_map, 'taxonomyAPI');
        
        // Don't know how to get the service api in a test without doing weird stuff like this.
        ocms_mfc_NewsStream newsStreamController = new ocms_mfc_NewsStream(tch.gc);
        ocms_TaxonomyAPI tApi = new ocms_TaxonomyAPI(newsStreamController.sAPI);

        String contentId = tch.gc.content.Id;

        tApi.getContentRenderingsForContentIds(new List<String>(), 'template');
        tApi.getContentRenderingsForContentIds(new List<String>{contentId}, 'template');
        tApi.getContentRenderingsForContentIds(new List<String>{contentId}, new List<String>{'asdf'});
        tApi.getContentIdsForPath('/master/taxonomy/cake', 'taxonomyAPI', 'date', null, null);
        tApi.getContentIdsForPathList(new List<String>{'/master/taxonomy/location'}, 'taxonomyAPI', 'date', null, null);
        tApi.getTagsAtAncestryNode(contentId, '/master/taxonomy/path');
        tApi.getTagsAtAncestryNode(new Set<String>{contentId}, '/master/taxonomy/path');
        tApi.getLatestContentRenderingsForOriginContents(new List<String>{contentId}, 'template');
        tApi.getLatestContentRenderingsForOriginContents(new List<String>{contentId}, new List<String>{'template'});
        tApi.getContentRenderingsFromMultiplePathLists(new List<List<String>>{new List<String>{'/master/taxonomy/cake'}}, 'taxonomyAPI', 'template', 'date', null, null);
		tApi.getContentIdsFromMultiplePathLists(new List<List<String>>{new List<String>{'/master/taxonomy/cake'},new List<String>{'/master/taxonomy/bake'}}, 'taxonomyAPI','date', null, null);
		tApi.getContentIdsFromMultiplePathLists(new List<List<String>>{new List<String>{'/master'}}, 'taxonomyAPI','date', null, null);
		tApi.getPathsForContentIds(new Set<String>{contentId});
		tApi.getPathsForContentIds(new List<String>{contentId});
		tApi.buildPathFromPathToPath('/master/taxonomy', '/master/taxonomy/location/kingston/ontario/canada');
		tApi.buildPathFromPathToPath('/master/taxonomy', 'what');
    }
}