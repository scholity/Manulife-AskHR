global with sharing class ocms_mli_Breadcrumb extends cms.MenuController {

    // Constructor for the execute request
    global ocms_mli_Breadcrumb() {}

    // Constructor for the content editor VF page
    global ocms_mli_Breadcrumb(cms.GenerateContent gc) {
        super(gc);
    }

    // Constructor for generator
    global ocms_mli_Breadcrumb(cms.CreateContentController cc) {
        super(cc);
    }

    /**
     * @description A label for the home node, this was needed because standard
     *              Orchestra breadcrumbs hard-code the home node (not translatable)
     */
    public String strHomeLabel {
        get { return ocms_mli_Utility.noNull(getProperty('strHomeLabel')); }
    }

    /**
     * @description In addition to a custom label, a custom link is needed.
     */
    public String strHomeLink {
        get { return this.getProperty('strHomeLink'); }
    }

    /**
     * @description The object form of the home link
     */
    private cms.Link objHomeLink {
        get { return new cms.Link(strHomeLink); }
    }

    global override String getHTML() {

        String html = '';
        cms.MenuNode activeNode = this.getNodeByIndex(this.getActiveIndex());

        if (Test.isRunningTest()) {
            activeNode = this.getNodeByIndex('1');
        }

        html += '<div class="breadcrumb">' +
                    '<div class="breadcrumbContainer">' +
                        '<ul>' +
                            generateBreadcrumbs(activeNode) +
                        '</ul>' +
                    '</div>' +
                '</div>';

        return html;
    }

    /**
     * @description The primary workhorse for breadcrumbs. This will generate the markup needed within the unordered
     *              list generated in getHTML().
     * @param  activeNode A page parameter that indicates what page we're on. This will be the last crumb and will
     *                    not be a clickable link.
     * @return String HTML of generated breadcrumbs.
     */
    private String generateBreadcrumbs(cms.MenuNode activeNode) {

        List<cms.MenuNode> nodeList = new List<cms.MenuNode>();
        cms.MenuNode node = activeNode;
        String html = '';

        // If the activeNode hasn't been provided then we cannot generate the breadcrumbs.
        if(activeNode != null){

            // Here we generate nodeList, which starts at the active item and uses the parent attribute to work up the list
            // until we hit the root node. This unfortunately creates the list in reverse order, but that's easy enough
            // to work with.
            while (node.level != -1) {
                nodeList.add(node);
                node = node.parent;
            }

            if (nodeList.size() > 0){

                // We'll only generate the Home crumb if the home label has been provided, otherwise we'll move on to the rest of the breadcrumb.
                // This is graceful failure.
                if (strHomeLabel != ''){

                    html += '<li>' +
                                '<a onclick=\'' + ocms_mli_Utility.getLinkScript(objHomeLink.javascript) + '\' href="' + ocms_mli_Utility.getLinkHref(objHomeLink.targetPage) + '" target="' + ocms_mli_Utility.getLinkTarget(objHomeLink.target) + '">' +
                                    strHomeLabel +
                                '</a>' +
                            '</li>';

                }

                // This is the main loop, we start off at the end of the nodeList and work our way back to the beginning,
                // this is because our list is created in reverse, with the page we're on being the first item in the list.
                for (Integer i = nodeList.size() -1; i >= 0; i--) {

                    cms.MenuNode n = nodeList.get(i);

                    // If this is not the active node, generate as an anchor tag, otherwise generate as a paragraph tag.
                    if (i != 0) {

                        html += '<li>' +
                                    '<a onclick=\'' + ocms_mli_Utility.getLinkScript(n.javascript) + '\' href="' + ocms_mli_Utility.getLinkHref(n.targetPage) + '" target="' + ocms_mli_Utility.getLinkTarget(n.target) + '">' +
                                        n.getMenuItemName() +
                                    '</a>' +
                                '</li>';

                    } else {

                        html += '<li>' +
                                    '<p>' +
                                        n.getMenuItemName() +
                                    '</p>' +
                                '</li>';

                    }
                }
            }
        }

        return html;
    }

}