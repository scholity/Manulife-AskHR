@isTest
private class ocms_mfc_ListingCarousel_Test {
    static testMethod void testGetHTML() {
        ocms_TestContentHelper tch = new ocms_TestContentHelper();
        // Test the default controller
        ocms_mfc_ListingCarousel listingCarouselController = new ocms_mfc_ListingCarousel();
        listingCarouselController.getType();
        // Code coverage the mandatory getHTML

        List<Map<String,String>> attr_map = new List<Map<String, String>>();
        
        Map<String, String> am = new Map<String, String>();
        am.put('name', 'category');
        am.put('value', 'category');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'contentType');
        am.put('value', 'PFP');
        am.put('type', 'text');
        attr_map.add(am);

        tch.createContent(attr_map, 'ListingCarousel');

        listingCarouselController = new ocms_mfc_ListingCarousel(tch.gc);
        System.assertEquals(listingCarouselController.category, 'category');
        System.assertEquals(listingCarouselController.contentType, 'PFP');
        System.assertEquals(listingCarouselController.contentTemplate, 'Tile');

        String html = listingCarouselController.getHtml();
    }
}