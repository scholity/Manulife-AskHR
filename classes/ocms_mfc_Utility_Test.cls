@isTest
public class ocms_mfc_Utility_Test {

	public static testMethod void test() {
		ocms_mfc_Utility.bypassUserLanguageTrigger ();
		ocms_mfc_Utility.getBypassLanguageStatus ();
		String prot = ocms_mfc_Utility.protocolAndHost;
		ocms_mfc_Utility.getResourceURL('blah');
	}
}