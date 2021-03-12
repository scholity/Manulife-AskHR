@isTest
private class ocms_mli_HeroCarouselControl_Test {
	
	@isTest static void instantiate() {
		
        ocms_TestContentHelper tch = new ocms_TestContentHelper();
        ocms_mli_HeroCarouselControl heroCarouselControl = new ocms_mli_HeroCarouselControl();
        List<Map<String,String>> attr_map = new List<Map<String,String>>();

        Map<String, String> am = new Map<String, String>();
        am.put('name', 'strAccessibleStopCarousel');
        am.put('value', 'Stop');
        am.put('type', 'Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'strAccessiblePrevSlide');
        am.put('value', 'Previous slide');
        am.put('type', 'Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'strAccessibleNextSlide');
        am.put('value', 'Next slide');
        am.put('type', 'Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'strDuration');
        am.put('value', '7000');
        am.put('type', 'Text');
        attr_map.add(am);

        tch.createContent(attr_map, 'heroCarouselControl');
        heroCarouselControl = new ocms_mli_HeroCarouselControl(tch.gc);

        heroCarouselControl.getHTML();

        heroCarouselControl.test_pm = 'prev';

        heroCarouselControl.getHTML();

        Test.setCurrentPageReference(new PageReference('/apex/cms__CreateContent'));
        System.currentPageReference().getParameters().put('sname', 'manulife');
        System.currentPageReference().getParameters().put('content', tch.gc.content.Id);

        cms.CreateContentController ccc = new cms.CreateContentController();
        heroCarouselControl = new ocms_mli_HeroCarouselControl(ccc);

	}
	
}