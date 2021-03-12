/**
 * Definition and markup generation for Manulife.com Social Feeds Tabbed Menu (C105).
 *
 * @author  Saloni Mittal
 * @date    2015-Jun-17
 *
 */
global with sharing class ocms_mli_SocialFeedsTabbedMenu extends cms.ContentTemplateController {
    // Constructor for the execute request
    global ocms_mli_SocialFeedsTabbedMenu() {}

    // Constructor for the content editor VF page
    global ocms_mli_SocialFeedsTabbedMenu(cms.GenerateContent gc) {
        super(gc);
    }

    // Constructor for generator
    global ocms_mli_SocialFeedsTabbedMenu(cms.CreateContentController cc) {
        super(cc);
    }

    /**
     * @description  Used for social feeds json string
     */
    public String jsnSocialFeedslist {
        get {
            return getProperty('jsnSocialFeedslist');
        } set;
    }

    /**
     * @description  Used for deserializing the social feeds json string back into objects
     */
    public List<SocialFeeds> lstSocialFeeds{get; set;}

    /**
     * @description  Used for social feeds object to store deserialized json string content
     */
    public class SocialFeeds implements Comparable {
        String sSocialMedia;
        String sAccessibleText;
        String sTabId;

        // Implement the compareTo() method
        public Integer compareTo(Object ObjToCompare) {
            return sTabId.CompareTo(((SocialFeeds)ObjToCompare).sTabId);
        }
    }

    /**
     * @description  Generates mark-up for social feeds tabbed menu.
     * @return  String  A string of mark-up used to generate the select box.
     */
    global override String getHTML() {

        // attempting to resolve all caching generation exceptions
        try {
            lstSocialFeeds = (List<SocialFeeds>)JSON.deserialize(jsnSocialFeedslist, List<SocialFeeds>.class);
            lstSocialFeeds.sort();
        }
        catch (Exception e){}

        String sHTML = '';

        // we don't want to bleed potential vector of attack info, so we only output our debug in prev mode
        sHTML += '<!-- >>> ocms_mli_SocialFeedsTabbedMenu.getHTML(...) -->\n';  // to fix any jQuery parsing issue and it's a good design pattern, see: https://pl5.projectlocker.com/Stantive/PSTools/trac/wiki/gotcha/OCMSCachingMissingMarkup

        sHTML +=  '<div class="socialFeeds" data-hw-attach-point="socialFeeds">'
             +      '<div class="socialFeedsContainer">'
             +          '<div class="socialFeedsTabs" data-hw-module="module/TabsWithCustomScrollbars"'
             +          ' data-hw-options="selectors: { list: \'.socialFeedsTabsList > ul\', section: \'div.tabSection\', content: \'div.tabContent\'}">';
        if (!(lstSocialFeeds.isEmpty())) {
            sHTML +=             '<div class="socialFeedsTabsList">'
                 +                 buildSocialFeedsTabbedMenu()
                 +              '</div>';
        }
        sHTML +=         '</div>'
             +     '</div>'
             + '</div>';


        // we don't want to bleed potential vector of attack info, so we only output our debug in prev mode
        sHTML += '<!-- <<< ocms_mli_SocialFeedsTabbedMenu.getHTML(...) -->\n'; //  to fix any jQuery parsing issue and it's a good design pattern, see: https://pl5.projectlocker.com/Stantive/PSTools/trac/wiki/gotcha/OCMSCachingMissingMarkup

        return sHTML;
    }

    /**
     * @description  Generates mark-up for the tabbed menu.
     * @return  String  A string of mark-up used to generate the tabbed menu.
     */
    private String buildSocialFeedsTabbedMenu() {
        String html = '<ul>';
        for (SocialFeeds deserializedSocialFeeds : lstSocialFeeds) {
            html += '<li role="presentation"';
            if (deserializedSocialFeeds.sTabId == '1') {
                html += ' class="is-active"';
            }
            html += '>'
                 +     '<a role="tab" aria-controls="socialFeedsTab' + ((deserializedSocialFeeds.sTabId != null) ? deserializedSocialFeeds.sTabId : '')
                 +     '" aria-label="'+ ((deserializedSocialFeeds.sAccessibleText != null) ? deserializedSocialFeeds.sAccessibleText : '')
                 +     '" class="accessibleLink socialFeedsTab'  + deserializedSocialFeeds.sSocialMedia
                 +     '" href="#socialFeedsTab'  + ((deserializedSocialFeeds.sTabId != null) ? deserializedSocialFeeds.sTabId : '')
                 +     '">'
                 +         '<span class="socialFeedsTabIcon"></span>'
                 +         '<span class="accessible">' + ((deserializedSocialFeeds.sAccessibleText != null) ? deserializedSocialFeeds.sAccessibleText : '') + '</span>'
                 +     '</a>'
                 + '</li>';
       }
       html += '</ul>';
       return html;
    }
}