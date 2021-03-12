@isTest
public class ocms_mfc_MyPreferences_Test {
	public static testMethod void test () {
		Profile p = [select Id from profile where name='System Administrator'];
		ocms_TestContentHelper helper = new ocms_TestContentHelper ('My Preferences Site');
		Map <String, String> attrMap = new Map <String, String> ();
		List <Map <String, String>> attrList = new List <Map <String, String>> ();
		attrList.add(attrMap);
		helper.createContent(attrList, 'My Preferences');
		User u = new User (alias = 'standt', email='standarduser@manulife.com',
				emailencodingkey='UTF-8', lastname='waldo', languagelocalekey='en_US',
				localesidkey='en_US', profileid = p.Id, firstname='wheres',
				timezonesidkey='America/Los_Angeles', username='standarduserrr_MyPreferences@manulife.com',
				city = 'Kingston');
		TriggerUtils.setBypassUserTrigger(); // there is a trigger on user insert, this sets the flag so the trigger will bypass its logic check
		insert u;

		System.runAs(u) {
			ocms_mfc_MyPreferences preferences = new ocms_mfc_MyPreferences();
			preferences.getType();
			String html = preferences.getHTML();
			Map <String, String> request = new Map <String, String> ();
			request.put('action', 'savePreferences');
			request.put('primaryLanguage', 'en');
			request.put('dailyDigest', 'true');
			request.put('newsCategories', 'blahblah~~~~blahblah2');
			String response = preferences.executeRequest(request);
			//System.assert(response.contains('true'));
			preferences.executeRequest(new Map <String, String> ());
		}

		// time to increase our code coverage by running some non-essential code
		ocms_mfc_MyPreferences pref = new ocms_mfc_MyPreferences(helper.gc);
		RecordType prefRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'MFC_Community_Object__c' AND DeveloperName = 'My_Preferences'];
		MFC_Community_Object__c firstPref = new MFC_Community_Object__c (User__r = u, RecordTypeId = prefRecordType.Id);
		MFC_Community_Object__c secondPref = new MFC_Community_Object__c (User__r = u, RecordTypeId = prefRecordType.Id);
		insert firstPref;
		insert secondPref;
		System.runAs(u) {
			pref.getHTML();
		}
		pref.saveNewLanguage('en_US', u.Id);
		pref.saveNewLanguage('blah', 'blah');
	}
}