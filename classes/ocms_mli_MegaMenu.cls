global with sharing class ocms_mli_MegaMenu extends cms.MenuController {

    // Constructor for the execute request
	global ocms_mli_MegaMenu() {}

    // Constructor for the content editor VF page
    global ocms_mli_MegaMenu(cms.GenerateContent gc) {
        super(gc);
    }

    // Constructor for generator
    global ocms_mli_MegaMenu(cms.CreateContentController cc) {
        super(cc);
    }

    /**
     * @description Generates mark-up for content.
     * @return String A string of mark-up used to generate the content.
     */
    global override String getHTML() {
        return generateNav();
    }

    /**
     * @description Used for skip link text: accessibility.
     */
     
     // removed as per STI-7198
    /*public String strSkipLink {
        get{ return this.getProperty('strSkipLink'); }
    }*

    /**
     * @description Used for open message text: accessibility.
     */
    public String strDataMsgOpen {
        get{ return this.getProperty('strDataMsgOpen'); }
    }

    /**
     * @description Used for close message text: accessibility.
     */
    public String strDataMsgClose {
        get{ return this.getProperty('strDataMsgClose'); }
    }

    /**
     * @description Text used for the close button, appears in mobile/tablet view.
     */
    public String strCloseButton {
        get { return this.getProperty('strCloseButton'); }
    }

    /**
     * @description Needed for testing preview mode condition.
     */
    public String test_pm { get; set; }

    /**
     * @description Primary mark-up generation method, makes calls to several sub-methods to build the mark-up string.
     * @return String Final mark-up for content.
     */
    private String generateNav() {

        List<cms.MenuNode> nodes = this.getOrderedRootNodes();
        String html =   '<!-- >>> ocms_mli_MegaMenu.getHTML(...) -->' + // to fix any jQuery parsing issues, see: https://pl5.projectlocker.com/Stantive/PSTools/trac/wiki/gotcha/OCMSCachingMissingMarkup
                        '<button type="button" class="mastheadPanelClose">' + ((strCloseButton != null) ? strCloseButton : '') + '</button>' +
                        '<nav aria-label="Primary" data-hw-module="module/BurgerMenu" class="mastheadNav">' +
                            '<ul class="mastheadNavL1">';

                                for(cms.MenuNode mn: nodes) {
                                    if(mn != null) {
                                        html += this.generateNavL1(mn);
                                    }
                                }

        html +=             '</ul>' +
                        '</nav>' +

                        '<script type="text/javascript">' +
                            'var megaMenuActivePath = ' + this.getActiveItemPath() + ';' +
                        '</script>';

                        if (this.pm == 'prev' || this.test_pm == 'prev'){
                            html += '<script type="text/javascript" src="' + ocms_mli_Utility.getResourceURL('ocms_mli_megaMenu', 'js/megaMenu.js') + '"></script>';
                        }
                        else if (this.pm == 'production'){
                            // Note: For performance (avoidng an https hit) consider inlining the mimifed JS. If your project uses grunt minification task then run that and
				            //       copy the <JS-FILE>.min.js` contents between the `<script>` tags, or as a fallback use the output from 'https://closure-compiler.appspot.com'.
				            //       When pasting ensure that any `\` (backslashes) are converted to `\\` as that is the escape character in Apex.
		                    // html += '<script type="text/javascript" src="' + ocms_mli_Utility.getResourceURL('ocms_mli_megaMenu', 'js/megaMenu.min.js') + '"></script>';
                            html += '<script>';
		                    html += 'function initAnalyticsSiteSection(){for(var a=["siteSection","siteSection1","siteSection2","siteSection3","siteSection4","siteSection5","siteSection6","siteSection7","siteSection8"],b=[],c=megaMenuActivePath.length-1;c>-1;c--)b.push(megaMenuActivePath[c]);for(var d=0;d<b.length;d++)MLI.analytics.page.pageInfo[a[d]]=b[d]}function megaMenuPromoDOMManip(){debug.log("megaMenu.js: megaMenuPromoDOMManip()"),$("nav .replacePromo").each(function(){var a=$(this).attr("class").split(/\\s+/),b=$(this).parent().parent(),c="",d="";a.splice(a.indexOf("replacePromo"),1),d=a[0],c=$("#mainNavigationMegaMenuPromo").find("#"+d),(null!==c||""!==c)&&(b.html(""),b.addClass("desktopOnly"),c.clone().appendTo(b))}),$("#mainNavigationMegaMenuPromo").remove()}$(document).ocmsDynamicLoadFinished(function(){megaMenuPromoDOMManip(),initAnalyticsSiteSection()});';
		                    html += '</script>';
                        }

        html +=         '<!-- <<< ocms_mli_MegaMenu.getHTML(...) -->';

        return html;
    }

    /**
     * @description Used to build the first level of navigation, these are the main headings in the menu.
     * @param  cms.MenuNode node The MenuNode passed in from generateNav().
     * @return String Mark-up for first level of navigation.
     */
    private String generateNavL1(cms.MenuNode node) {

        String html = '';

        if (node.children != null && node.children.size() > 0){

            html += '<li class="mastheadHasChild ' + node.styleClass + '">' +
                        '<a class="accessibleLink" onclick="' + ((node.javascript != null) ? node.javascript : '') + '" href="' + ocms_mli_Utility.getLinkHref(node.targetPage) + '" target="' + ocms_mli_Utility.getLinkTarget(node.target) + '" >' + node.getMenuItemName() + '</a>' +
                        '<button type="button" data-msg-open="' + strDataMsgOpen + '" data-msg-close="' + strDataMsgClose + '" class="submenuTrigger">' +
                            '<span class="icon"></span>' +
                            '<span class="accessible">Click to expand the submenu</span>' +
                        '</button>' +
                        '<div class="mastheadChild mastheadMainDropdownMenu" role="list">' +
                            //'<a href="#" class="skiplink">' + strSkipLink + ' ' + node.getMenuItemName() + '</a>' + // remove as per STI-7198, for cr#4
                            '<div class="mastheadDropdownMenuInner">' +
                                createColumns(node) +
                            '</div>' +
                        '</div>' +
                    '</li>';

        } else {

            html += '<li class="' + node.styleClass + '">' +
                        '<a class="accessibleLink" onclick=\'' + ocms_mli_Utility.getLinkScript(node.javascript) + '\' href="' + ocms_mli_Utility.getLinkHref(node.targetPage) + '" target="' + ocms_mli_Utility.getLinkTarget(node.target) + '" >' + node.getMenuItemName() + '</a>' +
                    '</li>';

        }

        return html;
    }

    /**
     * @description Used to build columns within the second level of navigation. Columns are determined
     *              by the group number the node has been assigned.
     * @param  cms.MenuNode node The MenuNode passed in from generateNavL1().
     * @return String Mark-up for the second level of navigation
     */
    private String createColumns(cms.MenuNode node) {

        String html = '';
        List<cms.MenuNode.MenuNodeGroup> mng = node.getOrderedGroups();
        cms.MenuNode[] nodeArray;

        for(Integer i = 0; i < mng.size(); i++){

            nodeArray = mng.get(i).children;

            html += '<div class="mastheadDropdownMenuColumn" role="listitem">' +
                        '<ul class="mastheadChild mastheadNavL2">';

                            for(cms.MenuNode mn: nodeArray){
                                html += generateNavL2(mn);
                            }

            html +=     '</ul>' +
                    '</div>';

        }

        return html;
    }

    /**
     * @description Used to build the menu items located in the second level of navigation. These items
     *              are created within columns and may have children.
     * @param  cms.MenuNode node The MenuNode passed in from createColumns().
     * @return String Mark-up for the second level of navigation.
     */
    private String generateNavL2(cms.MenuNode node) {

        String html = '';

        if (node.children != null && node.children.size() > 0){

            html += '<li class="mastheadHasChild ' + node.styleClass + '">' +
                        '<a class="accessibleLink" onclick=\'' + ocms_mli_Utility.getLinkScript(node.javascript) + '\' href="' + ocms_mli_Utility.getLinkHref(node.targetPage) + '" target="' + ocms_mli_Utility.getLinkTarget(node.target) + '" >' + node.getMenuItemName() + '</a>' +
                        '<button type="button" data-msg-open="' + strDataMsgOpen + '" data-msg-close="' + strDataMsgClose + '" class="innerSubmenuTrigger">' +
                            '<span class="icon"></span>' +
                            '<span class="accessible">Click to expand the submenu</span>' +
                        '</button>' +
                        '<ul class="mastheadChild mastheadNavL3">';

                            for (cms.MenuNode mn: node.getOrderedChildren()){
                                html += generateNavL3(mn);
                            }

            html +=     '</ul>' +
                    '</li>';

        } else {

            html += '<li class="' + node.styleClass + '">' +
                        '<a onclick=\'' + ocms_mli_Utility.getLinkScript(node.javascript) + '\' href="' + ocms_mli_Utility.getLinkHref(node.targetPage) + '" target="' + ocms_mli_Utility.getLinkTarget(node.target) + '" >' + node.getMenuItemName() + '</a>' +
                    '</li>';

        }

        return html;
    }

    /**
     * @description Used to build the menu items located in the third level of navigation. This is the
     *              final tier of menu items.
     * @param  cms.MenuNode node The MenuNode passed in from generateNavL2().
     * @return String Mark-up for the final level of navigation.
     */
    private String generateNavL3(cms.MenuNode node) {

        String html = '';

        html += '<li class="' + node.styleClass + '">' +
                    '<a onclick=\'' + ocms_mli_Utility.getLinkScript(node.javascript) + '\' href="' + ocms_mli_Utility.getLinkHref(node.targetPage) + '" target="' + ocms_mli_Utility.getLinkTarget(node.target) + '" >' + node.getMenuItemName() + '</a>' +
                '</li>';

        return html;
    }

    /**
     * @description Used to get a JSON string that represents the path from the active item to the top-
     *              most item in the navigation. This can then be used to fill out the siteSection
     *              parameters in the analytics javascript object.
     * @return String JSON serialized list of node names for analytics object.
     */
    public String getActiveItemPath() {

        List<String> nodeList = new List<String>();
        cms.MenuNode node = this.getActiveNode();

        if (node != null){
            nodeList.add(node.getMenuItemName());
            while (node.parent != null){
                node = node.parent;
                if (node.getMenuItemName() != ''){
                    nodeList.add(node.getMenuItemName());
                }
            }
        }

        return JSON.serialize(nodeList);

    }

}