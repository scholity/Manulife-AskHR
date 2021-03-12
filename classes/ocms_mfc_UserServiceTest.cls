@isTest
private class ocms_mfc_UserServiceTest {   
    static testMethod void testGetType() {
    	// Get code coverage on the default consntructor.
		ocms_mfc_UserService useService = new ocms_mfc_UserService();

		System.assertEquals(useService.getType(),ocms_mfc_UserService.class, 'Expected ocms_mfc_UserService.class got: ' + useService.getType());
	}
    
    static testMethod void testGetAnalyticsData() {
		ocms_mfc_UserService useService = new ocms_mfc_UserService();

		String response = useService.executeRequest(new Map<String, String>{
			'action' => 'getAnalyticsData'
		});
    }
}