@isTest
private class ocms_mli_HeroCarouselSlide_Test {
	
	@isTest static void instantiate() {
        
        ocms_TestContentHelper tch = new ocms_TestContentHelper();
        ocms_mli_HeroCarouselSlide heroCarouselSlide = new ocms_mli_HeroCarouselSlide();
        List<Map<String,String>> attr_map = new List<Map<String,String>>();

        Map<String, String> am = new Map<String, String>();
        am.put('name', 'strMobileImage');
        am.put('value', 'http://www.path.to/resource/mobileImage.jpg');
        am.put('type', 'Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'strTabletImage');
        am.put('value', 'http://www.path.to/resource/tabletImage.jpg');
        am.put('type', 'Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'strDesktopImage');
        am.put('value', 'http://www.path.to/resource/desktopImage.jpg');
        am.put('type', 'Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'strTitle');
        am.put('value', 'Slide 1');
        am.put('type', 'Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'strSubTitle');
        am.put('value', 'subtitle');
        am.put('type', 'Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'strPlayVideo');
        am.put('value', 'Play Video');
        am.put('type', 'Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'strAccessibleDescription');
        am.put('value', 'accessible description');
        am.put('type', 'Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'strAccessiblePlayAction');
        am.put('value', 'Open in overly');
        am.put('type', 'Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'strAccessiblePlayVideo');
        am.put('value', 'Play Video');
        am.put('type', 'Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'strVideoURL');
        am.put('value', 'https://www.youtube.com/watch?v=nuHfVn_cfHU');
        am.put('type', 'Text');
        attr_map.add(am);

        tch.createContent(attr_map, 'heroCarouselSlide');
        heroCarouselSlide = new ocms_mli_HeroCarouselSlide(tch.gc);

        heroCarouselSlide.getHTML();

        Test.setCurrentPageReference(new PageReference('/apex/cms__CreateContent'));
        System.currentPageReference().getParameters().put('sname', 'manulife');
        System.currentPageReference().getParameters().put('content', tch.gc.content.Id);

        cms.CreateContentController ccc = new cms.CreateContentController();
        heroCarouselSlide = new ocms_mli_HeroCarouselSlide(ccc);

    }

}