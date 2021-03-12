/**
 * This class contains the unit tests for validating ocms_mli_ProductServicesFilter apex class
 *
 * @author  Saloni Mittal
 * @date    2015-May-21
 *
 */

@isTest
private class ocms_mli_ProductServicesFilter_Test {

    @isTest static void instantiate() {

        ocms_TestContentHelper tch = new ocms_TestContentHelper();
        ocms_mli_ProductServicesFilter objProdServFilter = new ocms_mli_ProductServicesFilter();
        List<Map<String,String>> attr_map = new List<Map<String,String>>();

        Map<String, String> am = new Map<String, String>();
        am.put('name', 'jsnProdServFiltSelect');
        am.put('value', '[{"sFilterCode":"CA","sFilterText":"Canada","sFilterLink":"http://www.manulife.ca"},{"sFilterCode":"US","sFilterText":"United States","sFilterLink":"http://www.manulife.us"}]');
        am.put('type', 'Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'sMobileImage');
        am.put('value', 'http://www.path.to/resource/mobileImage.jpg');
        am.put('type', 'Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'sTabletImage');
        am.put('value', 'http://www.path.to/resource/tabletImage.jpg');
        am.put('type', 'Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'sDesktopImage');
        am.put('value', 'http://www.path.to/resource/desktopImage.jpg');
        am.put('type', 'Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'sBannerImageAlt');
        am.put('value', 'Test Banner Image');
        am.put('type', 'Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'sProdServFiltTitle');
        am.put('value', 'View Product & Services in');
        am.put('type', 'Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'sProdServFiltLinkText');
        am.put('value', 'Visit');
        am.put('type', 'Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'sProdServFiltCountry');
        am.put('value', 'Manulife Canada');
        am.put('type', 'Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'sProdServFiltLink');
        am.put('value', 'External,,NewWindow,,,,http://www.manulife.ca');
        am.put('type', 'Text');
        attr_map.add(am);

        tch.createContent(attr_map, 'objProdServFilter');
        objProdServFilter = new ocms_mli_ProductServicesFilter(tch.gc);

        objProdServFilter.getHTML();

        Test.setCurrentPageReference(new PageReference('/apex/cms__CreateContent'));
        System.currentPageReference().getParameters().put('sname', 'manulife');
        System.currentPageReference().getParameters().put('content', tch.gc.content.Id);

        cms.CreateContentController ccc = new cms.CreateContentController();
        objProdServFilter = new ocms_mli_ProductServicesFilter(ccc);


    }

}