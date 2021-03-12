@isTest
private class ASKHR_NotificationUtilsTest { 
    
    static testMethod void sendEmailTest(){ 
        Test.startTest();
        ASKHR_NotificationUtils.sendEmailNotification('Test 1', 'Test Email Body');
        ASKHR_NotificationUtils.sendHTMLEmailNotification('Test 2', '<b>Test HTML Email Body</b>');

        //negative test
        ASKHR_NotificationUtils.sendEmailNotification('Test 1', null);
        ASKHR_NotificationUtils.sendHTMLEmailNotification('', '<b>Test HTML Email Body</b>');

        Test.stopTest();
    }
     
}