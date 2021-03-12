global with sharing class ocms_mfc_CommunityLogin {
    global ocms_mfc_CommunityLogin() {}

    global PageReference forwardToAuthPage() {
        String userType = UserInfo.getUserType();
        if(userType == 'Guest' || runAsGuest) {
            System.debug('***Guest user redirect to the following: ' + Network.forwardToAuthPage(System.currentPageReference().getParameters().get('startURL'), System.currentPageReference().getParameters().get('display'))  );
            return Network.forwardToAuthPage( 
                System.currentPageReference().getParameters().get('startURL'),
                System.currentPageReference().getParameters().get('display')
            );
        } else {
            System.debug('***Logged in user redirect to the following: ' + Page.cms__Main);
            return Page.cms__Main;
        }
    }

    // Needed to test, since we can't reliably run as a site guest user without
    // knowing the site name..
    Boolean runAsGuest = false;
    @testVisible private ocms_mfc_CommunityLogin(Boolean runAsGuest) {
        this.runAsGuest = runAsGuest;
    }
}