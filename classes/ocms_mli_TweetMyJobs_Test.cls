@isTest
private class ocms_mli_TweetMyJobs_Test {
	
	@isTest static void instantiation() {
		
        ocms_TestContentHelper tch = new ocms_TestContentHelper();
        ocms_mli_TweetMyJobs tweetMyJobs = new ocms_mli_TweetMyJobs();
        List<Map<String,String>> attr_map = new List<Map<String,String>>();

        Map<String, String> am = new Map<String, String>();
        am.put('name', 'strLink');
        am.put('value', 'External,,NewWindow,,,,https://www.tweetmyjobs.com/job-map/manulife?campaign_id=8889');
        am.put('type', 'Text');
        attr_map.add(am);

        tch.createContent(attr_map, 'tweetMyJobs');
        tweetMyJobs = new ocms_mli_TweetMyJobs(tch.gc);

        tweetMyJobs.getHTML();

        Test.setCurrentPageReference(new PageReference('/apex/cms__CreateContent'));
        System.currentPageReference().getParameters().put('sname', 'manulife');
        System.currentPageReference().getParameters().put('content', tch.gc.content.Id);

        cms.CreateContentController ccc = new cms.CreateContentController();
        tweetMyJobs = new ocms_mli_TweetMyJobs(ccc);

	}
	
}