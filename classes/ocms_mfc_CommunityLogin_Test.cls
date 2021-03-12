@isTest
global with sharing class ocms_mfc_CommunityLogin_Test {
	global static testmethod void testAuthed() {
		// Set up page context
		PageReference pageRef = Page.ocms_mfc_CommunityLogin; 
		Test.setCurrentPage(pageRef);

		// Build class; this will be a normal login
		ocms_mfc_CommunityLogin login = new ocms_mfc_CommunityLogin();
		// Make sure we get something back...
		System.assertNotEquals(null, login.forwardToAuthPage());
	}

	global static testmethod void testGuest() {
		// Set up page context
		PageReference pageRef = Page.ocms_mfc_CommunityLogin; 
		Test.setCurrentPage(pageRef);

		// Build class, guest login...
		ocms_mfc_CommunityLogin login = new ocms_mfc_CommunityLogin(true);
		System.assertEquals(null, login.forwardToAuthPage());
	}
}