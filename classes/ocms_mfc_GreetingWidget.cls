/**
 *  ocms_mfc_GreeetingWidget.cls
 *
 *  2015-May-06 Shawn Wilder
 *              Original
 *
 *  2015-May-17 Bill Lucas
 *              using <time datetime="…"> instead of out-dated <span class="date">
 *
 */
global with sharing class ocms_mfc_GreetingWidget extends cms.ContentTemplateController {

    
    global ocms_mfc_GreetingWidget() { }
    
    global ocms_mfc_GreetingWidget(cms.CreateContentController cc) {
        super(cc);
    }

    global ocms_mfc_GreetingWidget(cms.GenerateContent gc) {
        super(gc);
    }

    global override String getHTML() {
        String greetingsWidget = '';
        String greetings = '';
        
        Datetime currentDateTime = Datetime.now();
        Integer currentHour = Integer.valueOf(currentDateTime.format('HH'));

        String currentUserId = UserInfo.getUserId();
        Integer offset = UserInfo.getTimezone().getOffset(currentDateTime);
        Datetime local = currentDateTime.addSeconds(offset/1000);
        List<User> currentUser =  Database.query('SELECT FirstName, City__c FROM User WHERE Id = :currentUserId LIMIT 1');
        
        if (currentHour > 18) {
            greetings = eveningGreeting;
        } else if (currentHour > 11) {
            greetings = afternoonGreeting;
        } else {
            greetings = morningGreeting;
        }
        
        greetingsWidget += '<div class="widget profile-widget">';
        greetingsWidget +=  '<div class="inner">';
        greetingsWidget +=      '<div class="t">';
        greetingsWidget +=          '<span class="salutation">' + greetings + '</span>';
        greetingsWidget +=          '<span class="name">' + currentUser[0].FirstName + '</span>';
        greetingsWidget +=      '</div>';
        greetingsWidget +=      '<div class="b">';
        greetingsWidget +=          '<span class="city">';
        greetingsWidget +=              (currentUser[0].City__c != null) ? currentUser[0].City__c : '';
        greetingsWidget +=          '</span>';
        greetingsWidget +=          ' <time class="localTime" datetime="' + currentDateTime.format('YYYY-MM-dd\'T\'HH:mm:ssZ') + '">' + ManulifeHelper.formatTheDate(currentDateTime, sAPI.getRenderLanguage()) + '</time>';
       //  greetingsWidget +=          ' <time class="localTime" datetime="' +DateTime.valueOfGMT(String.valueOf(DateTime.now())) + '">' + '</time>';
        greetingsWidget +=      '</div>';
        greetingsWidget +=  '</div>';
        greetingsWidget += '</div>';
        /*
         The time value will be localized using moment.js on the front-end.  This localization occurs in
         MFC.fMoreContentAddedWatcher in mfc.js.
         */
        return greetingsWidget;
    }
    


    public String morningGreeting {
        get { return getProperty('morningGreeting'); }
    }

    public String afternoonGreeting {
        get { return getProperty('afternoonGreeting'); }
    }

    public String eveningGreeting {
        get { return getProperty('eveningGreeting'); }
    }
    
    private cms.ServiceAPI sAPI {
        get {
            if (sApi == null) {
                sApi = getServiceAPI();
            }
            return sApi;
        } set;
    }
}