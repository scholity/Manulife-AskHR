global with sharing class ocms_mli_CountryMenu extends cms.MenuController {

    // Constructor for the execute request
    global ocms_mli_CountryMenu() {}

    // Constructor for the content editor VF page
    global ocms_mli_CountryMenu(cms.GenerateContent gc) {
        super(gc);
    }

    // Constructor for generator
    global ocms_mli_CountryMenu(cms.CreateContentController cc) {
        super(cc);
    }

    /**
     * @description Generates mark-up for content.
     * @return String A string of mark-up used to generate the content.
     */
    global override String getHTML() {
        return generateCountryMenu();
    }

    /**
     * @description Although called a close button, this should typically read "back".
     *              Used in mobile-view only.
     */
    public String lblCloseButton {
        get { return getProperty('lblCloseButton'); }
    }

    /**
     * @description Accessibility feature, since the triggering button is an image,
     *              visually impaired need a worded description of the menu.
     */
    public String accDescription {
        get { return getProperty('accDescription'); }
    }

    /**
     * @description Descriptive verbage for skiplink feature. Typically reads:
     *              "Skip to next navigation item"
     */
    /*public String accSkipLink { //  removed as per STI-7198
        get { return getProperty('accSkipLink'); }
    }*/

    /**
     * @description ID of the next item to skip to minus octothorpe.
     */
   /* public String accSkipLinkTarget { //  removed as per STI-7198
        get { return getProperty('accSkipLinkTarget'); }
    }*/

    /**
     * @description Accessibility message used for links that have popup windows.
     */
    public String accPopupMsg {
        get { return ocms_mli_Utility.noNull(getProperty('accPopupMsg')); }
    }

    /**
     * @description Accessibility message used for when links open in a new window.
     */
    public String accNewWindowMsg {
        get { return ocms_mli_Utility.noNull(getProperty('accNewWindowMsg')); }
    }

    /**
     * @description Accessibility message used for when a link opens in the same window.
     */
    public String accSameWindowMsg {
        get { return ocms_mli_Utility.noNull(getProperty('accSameWindowMsg')); }
    }

    /**
     * @description Accessibility message used on globe icon title attribute.
     */
    public String accTitle {
        get { return ocms_mli_Utility.noNull(getProperty('accTitle')); }
    }

    /**
     * @description Primary method used to generate country menu markup. Makes calls to
     *              several sub-methods. Is responsible for splitting the ordered root
     *              nodes into a map of lists. The map number corresponds to the group
     *              number (which corresponds to the column) and each group will have
     *              nodes.
     * @return String
     */
    private String generateCountryMenu() {

        List<cms.MenuNode> nodes = this.getOrderedRootNodes();
        Map<Integer, List<cms.MenuNode>> nodeMap = new Map<Integer, List<cms.MenuNode>>();

        for (cms.MenuNode node : nodes){

            Integer i = node.groupNumber;

            if(nodeMap.get(i) == null){
                nodeMap.put(i, new List<cms.MenuNode>());
            }

            nodeMap.get(i).add(node);

        }

        String html = '';

        html += '<!-- >>> ocms_mli_CountryMenu.getHTML(...) -->' + // to fix any jQuery parsing issues, see: https://pl5.projectlocker.com/Stantive/PSTools/trac/wiki/gotcha/OCMSCachingMissingMarkup
                '<div class="mastheadUtilitiesItem mastheadCountry">' +
                    /*
                    2016-04-26 - [Stephen Scholtz]
                    - Changed look and feel, globe icon removed, text put in its place, and title attribute removed from the anchor                            
                    */
                    //'<a class="mastheadCountryTrigger mastheadHasChild accessibleLink" href="#" title="' + accTitle + '">' +
                    '<a class="mastheadCountryTrigger mastheadHasChild accessibleLink" href="#">' +
                        accTitle + 
                        '<span class="mastheadCountryIcon">' +
                            //'<span class="icon icon-globe"></span>' +
                            '<span class="accessible">' + accDescription + '</span>' +
                        '</span>' +
                    '</a>' +
                    '<div class="mastheadDropdownMenu" role="list" aria-hidden="true" style="display: none;">' +
                        //'<a class="skiplink" href="#' + accSkipLinkTarget + '" aria-hidden="false">' + accSkipLink + '</a>' + //  removed as per STI-7198
                        '<div class="mastheadDropdownMenuInner">' +
                            '<button class="mastheadDropdownMenuClose">' + lblCloseButton + '</button>' +
                            createColumns(nodeMap) +
                        '</div>' +
                    '</div>' +
                '</div>';

                if (this.pm == 'prev'){
                    html += '<script type="text/javascript" src="' + ocms_mli_Utility.getResourceURL('ocms_mli_countryMenu', 'js/countryMenu.js') + '"></script>';
                }
                else if (this.pm == 'production'){
                    // Note: for performance (avoidng an https hit) consider inlining the mimifed JS, run the grunt task and copy the <JS-FILE>.min.js` contents in between the script tags

                    // html += '<script type="text/javascript" src="' + ocms_mli_Utility.getResourceURL('ocms_mli_countryMenu', 'js/countryMenu.min.js') + '"></script>';
                    html += '<script>';
                    
                    //html += 'function countryMenuPromoDOMManip(){debug.log("countryMenu.js: countryMenuPromoDOMManip()"),$(".mastheadCountry .replacePromo").each(function(){var a=$(this).attr("class").split(/\\s+/),b=$(this).parent().parent().parent().parent(),c="",d="";a.splice(a.indexOf("replacePromo"),1),a.splice(a.indexOf("sm-flag-sprite"),1),d=a[0],c=$("#mainNavCountryPromo").find("#"+d),(null!==c||""!==c)&&(b.html(""),b.addClass("desktopOnly"),c.clone().appendTo(b))}),$("#mainNavCountryPromo").remove()}$(document).ocmsDynamicLoadFinished(function(){countryMenuPromoDOMManip()});';
                    
                    // 2016-04-21 - [Stephen Scholtz] New javascript; existing promo manipulation remains, added new functionality to copy final country menu
                    //              rendered code into the new desktop-only masthead.
                    html += 'function countryMenuPromoDOMManip(){debug.log("countryMenu.js: countryMenuPromoDOMManip()"),$(".mastheadCountry .replacePromo").each(function(){var a=$(this).attr("class").split(/\\s+/),b=$(this).parent().parent().parent().parent(),c="",d="";a.splice(a.indexOf("replacePromo"),1),a.splice(a.indexOf("sm-flag-sprite"),1),d=a[0],c=$("#mainNavCountryPromo").find("#"+d),(null!==c||""!==c)&&(b.html(""),b.addClass("desktopOnly"),c.clone().appendTo(b))}),$("#mainNavCountryPromo").remove();var a=$("#js-mastheadDesktopCountries"),b=$(".mastheadCountry").first().clone(!1);b.find(".mastheadCountryTrigger").remove(),a.append(b)}$(document).ocmsDynamicLoadFinished(function(){countryMenuPromoDOMManip()});';
                    
                    html += '</script>';

                }

        html += '<!-- <<< ocms_mli_CountryMenu.getHTML(...) -->';

        return html;

    }

    /**
     * @description The second method to be called while generating markup. This
     *              method will go through each unique group and generate a column
     *              for each group. It will call generateCountryMenuL1() to create
     *              the menu items in their respecitve columns.
     * @param  nodeMap A Map of Lists which represents the menu structure divided
     *                 into columns.
     * @return String
     */
    private String createColumns(Map<Integer, List<cms.MenuNode>> nodeMap) {

        String html = '';
        Set<Integer> nodeMapKeys= nodeMap.keySet();

        for (Integer i : nodeMapKeys) {

            html += '<div class="mastheadDropdownMenuColumn">' +
                        generateCountryMenuL1(nodeMap.get(i)) +
                    '</div>';

        }

        return html;

    }

    /**
     * @description Method to generate menu items given a list of nodes.
     * @param  nodeList a list of nodes given from a column/group.
     * @return String
     */
    private String generateCountryMenuL1(List<cms.MenuNode> nodeList){

        String html = '';

        for (cms.MenuNode node : nodeList) {

            String javascript = ocms_mli_Utility.getLinkScript(node.javascript);
            String targetPage = ocms_mli_Utility.getLinkHref(node.targetPage);
            String target = ocms_mli_Utility.getLinkTarget(node.target);
            String accMsg = '';

            if(javascript != ''){
                accMsg = accPopupMsg;
            } else if (target != ''){
                accMsg = accNewWindowMsg;
            } else if (targetPage != 'javascript:;'){
                accMsg = accSameWindowMsg;
            }

            html += '<div class="listItem" role="listitem">' +
                        '<a onclick=\'' + javascript + '\' href="' + targetPage + '" target="' + target + '" title="' + accMsg + '">' +
                            '<span class="country">' +
                                '<span class="sm-flag-sprite ' + node.styleClass + '"></span>' +
                                node.getMenuItemName() +
                            '</span>' +
                            '<span class="accessible">: ' + accMsg + '</span>' +
                        '</a>' +
                    '</div>';

        }

        return html;

    }

}