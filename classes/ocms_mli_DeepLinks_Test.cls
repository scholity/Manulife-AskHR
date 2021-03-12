@isTest
private class ocms_mli_DeepLinks_Test {
	
    @isTest static void instantiate() {
		
        ocms_TestContentHelper tch = new ocms_TestContentHelper();
        ocms_mli_DeepLinks deepLinks = new ocms_mli_DeepLinks();
        List<Map<String,String>> attr_map = new List<Map<String,String>>();

        Map<String, String> am = new Map<String, String>();
        am.put('name','strLink1Image');
        am.put('value','https://kittybloger.files.wordpress.com/2012/05/cute-kittens-20-great-pictures-1.jpg');
        am.put('type','Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name','strLink1Text');
        am.put('value','link 1');
        am.put('type','Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name','strLink1Link');
        am.put('value','External,,NewWindow,,,,http://www.google.ca');
        am.put('type','Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name','strLink2Image');
        am.put('value','https://kittybloger.files.wordpress.com/2012/05/cute-kittens-20-great-pictures-1.jpg');
        am.put('type','Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name','strLink2Text');
        am.put('value','link 1');
        am.put('type','Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name','strLink2Link');
        am.put('value','External,,NewWindow,,,,http://www.google.ca');
        am.put('type','Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name','strLink3Image');
        am.put('value','https://kittybloger.files.wordpress.com/2012/05/cute-kittens-20-great-pictures-1.jpg');
        am.put('type','Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name','strLink3Text');
        am.put('value','link 1');
        am.put('type','Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name','strLink3Link');
        am.put('value','External,,NewWindow,,,,http://www.google.ca');
        am.put('type','Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name','strLink4Image');
        am.put('value','https://kittybloger.files.wordpress.com/2012/05/cute-kittens-20-great-pictures-1.jpg');
        am.put('type','Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name','strLink4Text');
        am.put('value','link 1');
        am.put('type','Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name','strLink4Link');
        am.put('value','External,,NewWindow,,,,http://www.google.ca');
        am.put('type','Text');
        attr_map.add(am);


        tch.createContent(attr_map, 'deepLinks');
        deepLinks = new ocms_mli_DeepLinks(tch.gc);

        deepLinks.getHTML();

        Test.setCurrentPageReference(new PageReference('/apex/cms__CreateContent'));
        System.currentPageReference().getParameters().put('sname', 'manulife');
        System.currentPageReference().getParameters().put('content', tch.gc.content.Id);

        cms.CreateContentController ccc = new cms.CreateContentController();
        deepLinks = new ocms_mli_DeepLinks(ccc);

    }
	
}