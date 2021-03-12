@isTest
private class ocms_mli_Utility_Test {

    @isTest static void instantiate() {

        ocms_mli_Utility mliUtility = new ocms_mli_Utility();

    }

	@isTest(SeeAllData=true) static void getResourceURL_Test() {

        System.Debug('**** getResourceURL: ' + ocms_mli_Utility.getResourceURL('ocms_mli_pageSupport', 'js/ps-mli.js'));

	}

    @isTest static void getLinkScript_Test() {

        String javascript = 'window.open("http://www.google.ca" , "testWindow","location=1,status=1,scrollbars=1,resizable=1,height=500, width=500")';
        String returnStr = '';

        returnStr = ocms_mli_Utility.getLinkScript(javascript);

        System.assertEquals(javascript, returnStr, 'If javascript is not null it should return unmodified');

        javascript = null;

        returnStr = ocms_mli_Utility.getLinkScript(javascript);

        System.assertEquals('', returnStr, 'If javascript is null it should return a blank string');

    }

    @isTest static void getLinkHref_Test() {

        String targetPage = 'http://www.google.com';
        String returnStr = '';

        returnStr = ocms_mli_Utility.getLinkHref(targetPage);

        System.assertEquals(targetPage, returnStr, 'If targetPage is not null it should return unmodified');

        targetPage = null;

        returnStr = ocms_mli_Utility.getLinkHref(targetPage);

        System.assertEquals('javascript:;', returnStr, 'If targetPage is null it should return "javascript:;"');

    }

    @isTest static void getLinkTarget_Test() {

        String inputStr = 'someFrame';
        String returnedStr = '';

        returnedStr = ocms_mli_Utility.getLinkTarget(inputStr);

        System.assertEquals(inputStr, returnedStr, 'If inputStr is not null it should return unmodified');

        inputStr = null;

        returnedStr = ocms_mli_Utility.getLinkTarget(inputStr);

        System.assertEquals('_self', returnedStr, 'If inputStr is null it should return "_self"');

    }

    @isTest static void noNull_Test() {

        String target = '_blank';
        String returnStr = '';

        returnStr = ocms_mli_Utility.noNull(target);

        System.assertEquals(target, returnStr, 'If target is not null it should return unmodified');

        target = null;

        returnStr = ocms_mli_Utility.noNull(target);

        System.assertEquals('', returnStr, 'If target is null it should return a blank string');

    }

    @isTest static void getAnalyticsTag_Test() {

        ocms_mli_Utility utility = new ocms_mli_Utility();
        String result = '';

        result = utility.getAnalyticsScriptTag(); // Hit the Catch since there is no site setting initialised.

        ocms_mli_SiteSettings__c siteSetting = new ocms_mli_SiteSettings__c();
        siteSetting.Name = 'Manulife.com';
        siteSetting.Analytics_Javascript_Path__c = '//assets.adobedtm.com/caa55bf3865be487a5b4dbd4e1effd4b7cf20ea0/satelliteLib-23d1a5420810f27141b65b408f78e6b2303399df-staging.js';
        insert siteSetting;

        result = utility.getAnalyticsScriptTag();

        siteSetting = new ocms_mli_SiteSettings__c();
        siteSetting.Name = 'Manulife.com';
        siteSetting.Analytics_Javascript_Path__c = '';
        insert siteSetting;

        result = utility.getAnalyticsScriptTag(); // Blank URL test.

    }

}