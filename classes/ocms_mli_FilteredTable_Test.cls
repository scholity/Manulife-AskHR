/**
 * This class contains the unit tests for validating ocms_mli_FilteredTable apex class
 *
 * @author  Saloni Mittal
 * @date    2015-Nov-17
 *
 */

@isTest
private class ocms_mli_FilteredTable_Test {

     public static testmethod void instantiate() {

        /*
        Setup the data
        ############## */

        String sSiteName = 'TestSite'; // arbritary test site name stored in `cms__Sites__.cms__Site_Name__c`
        String type_name = 'TestContentType';
        String page_name = 'TestPage';
        String contentName = 'TestContentName';


        // Create our Site object using `cms.TestExtensionFixtures.InitiateTest` which initializes some hidden things from us - see Create Site
        cms__Sites__c oSite = cms.TestExtensionFixtures.InitiateTest(
                            sSiteName
                            ,new Map<String, String>{'runtime' => 'Intranet'
                            ,'sname' => sSiteName
                            ,'name' => page_name
                        });

        // create content type - based on `testContentHelper.createContent(...)`
        cms__Content_Type__c oCT = new cms__Content_Type__c(cms__Name__c = type_name, cms__Site_Name__c = sSiteName);
        insert oCT;

        // create content layout
        cms__Content_Layout__c oCL = new cms__Content_Layout__c(cms__Name__c = 'TestLayout');
        insert oCL;

        // create content
        cms__Content__c oC = new cms__Content__c(
                cms__Content_Type__c         = oCT.Id,
                cms__Name__c                 = contentName,
                cms__Description__c       = 'Testing',
                cms__Preview__c           = true,
                cms__Published__c           = false,
                cms__Published_Start_Date__c = System.now(),
                cms__Site_Name__c           = sSiteName,
                cms__Revision_Number__c   = 0,
                cms__Revision_Origin__c   = null,
                cms__Version_Number__c     = 1,
                cms__Version_Origin__c     = null,
                cms__Version_Original__c     = true,
                cms__Version_Parent__c     = null,
                cms__Depth__c               = 0
        );
        insert oC;

        // Create a page and associate the content layout with it
        cms__Page__c oPage = new cms__Page__c(cms__Name__c = page_name, cms__Site_Name__c = sSiteName);
        insert oPage;

        cms__Content_Layout_Instance__c oCLI = new cms__Content_Layout_Instance__c(cms__Content__c = oC.Id, cms__Content_Layout__c = oCL.Id);
        insert oCLI;

        cms__Page_Content_Layout_Instance__c oPCLI = new cms__Page_Content_Layout_Instance__c(cms__Content_Layout_Instance__c=oCLI.Id,cms__Page__c=oPage.Id);
        insert oPCLI;

        cms__Attribute__c oContentAttribute = null;

		oContentAttribute = new cms__Attribute__c(
		    cms__Content__c = oC.Id
		//    ,cms__Is_Simple__c = false
		    ,cms__Name__c = 'sTableIcon'
		    ,cms__Value__c = 'http://www.path.to/resource/desktopImage.jpg'
		);
		insert oContentAttribute;

		oContentAttribute = new cms__Attribute__c(
		    cms__Content__c = oC.Id
		//    ,cms__Is_Simple__c = false
		    ,cms__Name__c = 'sTableTitle'
		    ,cms__Value__c = 'Test Title'
		);
		insert oContentAttribute;

		oContentAttribute = new cms__Attribute__c(
		    cms__Content__c = oC.Id
		//    ,cms__Is_Simple__c = false
		    ,cms__Name__c = 'sStartingYear'
		    ,cms__Value__c = '2013'
		);
		insert oContentAttribute;

		oContentAttribute = new cms__Attribute__c(
		    cms__Content__c = oC.Id
		//    ,cms__Is_Simple__c = false
		    ,cms__Name__c = 'sYearFilterLabel'
		    ,cms__Value__c = 'Year'
		);
		insert oContentAttribute;

		oContentAttribute = new cms__Attribute__c(
		    cms__Content__c = oC.Id
		//    ,cms__Is_Simple__c = false
		    ,cms__Name__c = 'sQuarterFilterLabel'
		    ,cms__Value__c = 'Quarter'
		);
		insert oContentAttribute;

		oContentAttribute = new cms__Attribute__c(
		    cms__Content__c = oC.Id
		//    ,cms__Is_Simple__c = false
		    ,cms__Name__c = 'sReportTypeFilterLabel'
		    ,cms__Value__c = 'Report Type'
		);
		insert oContentAttribute;

		oContentAttribute = new cms__Attribute__c(
		    cms__Content__c = oC.Id
		//    ,cms__Is_Simple__c = false
		    ,cms__Name__c = 'sDocumentTitle'
		    ,cms__Value__c = 'Document Title'
		);
		insert oContentAttribute;

		oContentAttribute = new cms__Attribute__c(
		    cms__Content__c = oC.Id
		//    ,cms__Is_Simple__c = false
		    ,cms__Name__c = 'sReportType'
		    ,cms__Value__c = 'Report Type'
		);
		insert oContentAttribute;

		oContentAttribute = new cms__Attribute__c(
		    cms__Content__c = oC.Id
		//    ,cms__Is_Simple__c = false
		    ,cms__Name__c = 'sFileType'
		    ,cms__Value__c = 'File Type'
		);
		insert oContentAttribute;

		oContentAttribute = new cms__Attribute__c(
		    cms__Content__c = oC.Id
		//    ,cms__Is_Simple__c = false
		    ,cms__Name__c = 'sDate'
		    ,cms__Value__c = 'Date'
		);
		insert oContentAttribute;

		oContentAttribute = new cms__Attribute__c(
		    cms__Content__c = oC.Id
		//    ,cms__Is_Simple__c = false
		    ,cms__Name__c = 'sQuarter'
		    ,cms__Value__c = 'Quarter'
		);
		insert oContentAttribute;

		oContentAttribute = new cms__Attribute__c(
		    cms__Content__c = oC.Id
		//    ,cms__Is_Simple__c = false
		    ,cms__Name__c = 'sDescription'
		    ,cms__Value__c = 'Description'
		);
		insert oContentAttribute;

		oContentAttribute = new cms__Attribute__c(
		    cms__Content__c = oC.Id
		//    ,cms__Is_Simple__c = false
		    ,cms__Name__c = 'sYearFilterLabelAccessible'
		    ,cms__Value__c = 'Year Accessible'
		);
		insert oContentAttribute;

		oContentAttribute = new cms__Attribute__c(
		    cms__Content__c = oC.Id
		//    ,cms__Is_Simple__c = false
		    ,cms__Name__c = 'sQuarterFilterLabelAccessible'
		    ,cms__Value__c = 'Quarter Accessible'
		);
		insert oContentAttribute;

		oContentAttribute = new cms__Attribute__c(
		    cms__Content__c = oC.Id
		//    ,cms__Is_Simple__c = false
		    ,cms__Name__c = 'sReportTypeFilterLabelAccessible'
		    ,cms__Value__c = 'Report Accessible'
		);
		insert oContentAttribute;

		oContentAttribute = new cms__Attribute__c(
		    cms__Content__c = oC.Id
		//    ,cms__Is_Simple__c = false
		    ,cms__Name__c = 'sDownloadLabelAccessible'
		    ,cms__Value__c = 'Download Accessible'
		);
		insert oContentAttribute;

		oContentAttribute = new cms__Attribute__c(
		    cms__Content__c = oC.Id
		//    ,cms__Is_Simple__c = false
		    ,cms__Name__c = 'sPageLeftAccessible'
		    ,cms__Value__c = 'Page Left Accessible'
		);
		insert oContentAttribute;

		oContentAttribute = new cms__Attribute__c(
		    cms__Content__c = oC.Id
		//    ,cms__Is_Simple__c = false
		    ,cms__Name__c = 'sPageRightAccessible'
		    ,cms__Value__c = 'Page Right Accessible'
		);
		insert oContentAttribute;

        ocms_mli_FilteredTable objFilteredTable = new ocms_mli_FilteredTable();

        System.currentPageReference().getParameters().putAll(
            new Map<String,String>{
                'sname' => sSiteName
                ,'name' => page_name
                ,'page_mode' => 'prev' // OCMS ignores it , context is like a 'stack'
                ,'content_id' => oC.Id // OCMS ignores it
                ,'cli_id' => oCLI.Id   // OCMS ignores it
                ,'pcli_id' => oPCLI.Id // OCMS ignores it

		        ,'service' => 'ocms_mli_FilteredTable' // the class name
	            ,'action' => 'getFilteredListDataAsJSON' // the action to test
				,'year' => '2015'
				,'quarter' => 'en_US::Q4'
	            ,'reportType' => 'en_US::Annual Information Form'
                // 'ecms', anAPI.getSerialize() // looks like it's not needed
            }
        );

        ocms_mli_FilteredTable oInitGC =  new ocms_mli_FilteredTable(new cms.GenerateContent());

        String sTemp = null; // will hold temporary testing results of String type
        Integer iTemp = null; // will hold temporary testing results of Integer type


        sTemp = oInitGC.getHTML(); // OCMS method that is called during rendering

        oCL.cms__Name__c = 'MLIQuarterlyReportTable';
        update oCL;
        oInitGC =  new ocms_mli_FilteredTable(new cms.GenerateContent());
        sTemp = oInitGC.getHTML();


        sTemp = oInitGC.executeRequest(new Map<String, String>{
	        'service' => 'ocms_mli_FilteredTable' // the class name
            ,'action' => 'getFilteredListDataAsJSON' // the action to test
			,'year' => '2015'
			,'quarter' => 'en_US::Q4'
            ,'reportType' => 'en_US::Annual Information Form'

        });

	}
}