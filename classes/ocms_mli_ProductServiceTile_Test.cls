/**
 * This class contains the unit tests for validating ocms_mil_ProductServiceTile apex class
 *
 * @author  Saloni Mittal
 * @date    2015-May-15
 *
 */

@isTest
private class ocms_mli_ProductServiceTile_Test {

    @isTest static void instantiate() {

        ocms_TestContentHelper tch = new ocms_TestContentHelper();
        ocms_mli_ProductServiceTile objProductServiceTile = new ocms_mli_ProductServiceTile();
        List<Map<String,String>> attr_map = new List<Map<String,String>>();

        Map<String, String> am = new Map<String, String>();

        am = new Map<String, String>();
        am.put('name', 'sTileImageIcon');
        am.put('value', 'http://www.path.to/resource/desktopImage.jpg');
        am.put('type', 'Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'sTileImageIconAlt');
        am.put('value', 'wealth-management');
        am.put('type', 'Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'sTileTitle');
        am.put('value', 'Wealth Management');
        am.put('type', 'Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'sTileDescription');
        am.put('value', 'Lorem Ipsum dolor sit amet, consectetur adipiscing elit.');
        am.put('type', 'Text');
        attr_map.add(am);

        tch.createContent(attr_map, 'objProductServiceTile');
        objProductServiceTile = new ocms_mli_ProductServiceTile(tch.gc);

        objProductServiceTile.getHTML();

        Test.setCurrentPageReference(new PageReference('/apex/cms__CreateContent'));
        System.currentPageReference().getParameters().put('sname', 'manulife');
        System.currentPageReference().getParameters().put('content', tch.gc.content.Id);

        cms.CreateContentController ccc = new cms.CreateContentController();
        objProductServiceTile = new ocms_mli_ProductServiceTile(ccc);

    }

}