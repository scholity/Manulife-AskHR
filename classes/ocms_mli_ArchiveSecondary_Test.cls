/**
 * This class contains the unit tests for validating ocms_mli_ArchiveSecondary apex class
 *
 * @author  Saloni Mittal
 * @date    2015-Jun-24
 *
 */

@isTest
private class ocms_mli_ArchiveSecondary_Test {

    @isTest static void instantiate() {

        ocms_TestContentHelper tch = new ocms_TestContentHelper();
        ocms_mli_ArchiveSecondary archiveSecondaryObj = new ocms_mli_ArchiveSecondary();
        List<Map<String,String>> attr_map = new List<Map<String,String>>();

        Map<String, String> am = new Map<String, String>();

        am = new Map<String, String>();
        am.put('name', 'sArchiveSectionIcon');
        am.put('value', 'http://www.path.to/resource/desktopImage.jpg');
        am.put('type', 'Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'sArchiveSectionTitle');
        am.put('value', 'Lorem Ipsum dolor sit amet');
        am.put('type', 'Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'sArchiveSectionBody');
        am.put('value', 'Lorem Ipsum dolor sit amet, consectetur adipiscing elit.');
        am.put('type', 'Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'sArchiveSectionButton');
        am.put('value', 'Learn More');
        am.put('type', 'Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'sArchiveSectionButtonLink');
        am.put('value', 'External,,NewWindow,,,,http://www.google.ca');
        am.put('type', 'Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'sArchiveItemFile');
        am.put('value', 'Lorem Ipsum dolor sit amet, consectetur adipiscing elit.');
        am.put('type', 'Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'sArchiveSectionBody1');
        am.put('value', 'Lorem Ipsum dolor sit amet, consectetur adipiscing elit.');
        am.put('type', 'Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'sArchiveSectionButton1');
        am.put('value', 'Learn More');
        am.put('type', 'Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'sArchiveSectionButtonLink1');
        am.put('value', 'External,,NewWindow,,,,http://www.google.ca');
        am.put('type', 'Text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'sArchiveItemFile1');
        am.put('value', 'Lorem Ipsum dolor sit amet, consectetur adipiscing elit.');
        am.put('type', 'Text');
        attr_map.add(am);

        tch.createContent(attr_map, 'archiveSecondaryObj');
        archiveSecondaryObj = new ocms_mli_ArchiveSecondary(tch.gc);

        archiveSecondaryObj.getHTML();

        Test.setCurrentPageReference(new PageReference('/apex/cms__CreateContent'));
        System.currentPageReference().getParameters().put('sname', 'manulife');
        System.currentPageReference().getParameters().put('content', tch.gc.content.Id);

        cms.CreateContentController ccc = new cms.CreateContentController();
        archiveSecondaryObj = new ocms_mli_ArchiveSecondary(ccc);

    }

}