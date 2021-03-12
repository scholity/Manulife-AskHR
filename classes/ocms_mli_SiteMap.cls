global with sharing class ocms_mli_SiteMap extends cms.MenuController {

    // Constructor for the execute request
    global ocms_mli_SiteMap() {}

    // Constructor for the content editor VF page
    global ocms_mli_SiteMap(cms.GenerateContent gc) {
        super(gc);
    }

    // Constructor for generator
    global ocms_mli_SiteMap(cms.CreateContentController cc) {
        super(cc);
    }

    /**
     * @description Generates mark-up for content.
     * @return String A string of mark-up used to generate the content.
     */
    global override String getHTML() {
        return generateSiteMap();
    }

    /**
     * @description Primary mark-up generation method, makes calls to several sub methods to build up
     *              entire site map.
     * @return String final mark-up string.
     */
    private String generateSiteMap() {

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

        html += '<div class="menu content">' +
                    '<div class="row">' +
                        createColumns(nodeMap) +
                    '</div>' +
                '</div>';

        return html;

    }

    /**
     * @description Columns need to be created first for the sitemap, this differs from mega menu.
     *              Columns are created from the keys that are stored within the nodeMap. Since the
     *              user can use any groupnumber they like, it is wise to get these keys before
     *              building the columns.
     * @param  nodeMap Pass in the nodeMap created in generateSiteMap(), this is a key-value pair
     *                 where the key is the groupNumber assigned to the first level of items.
     * @return String mark-up string.
     */
    private String createColumns(Map<Integer, List<cms.MenuNode>> nodeMap) {

        Integer totalColumns = nodeMap.size();
        String html = '';
        Set<Integer> nodeMapKeys= nodeMap.keySet();

        for (Integer i : nodeMapKeys) {

            html += '<div class="sectionGroup">' +
                        generateSiteMapL1(nodeMap.get(i)) +
                    '</div>';

        }

        return html;

    }

    /**
     * @description Generates the first level of the site map, this level is unique in that it
     *              requires <h3> tags to wrap each menu item. If this heading has children
     *              call generateSiteMapChildren() to recursively generate the unordered lists.
     * @param  nodeList A list of MenuNodes that are the menu items proper.
     * @return String mark-up string.
     */
    private String generateSiteMapL1(List<cms.MenuNode> nodeList) {

        String html = '';

        for (cms.MenuNode node : nodeList) {

            html += '<div class="section">' +
                        '<h3>' +
                            '<a onclick=\'' + ocms_mli_Utility.getLinkScript(node.javascript) + '\' href="' + ocms_mli_Utility.getLinkHref(node.targetPage) + '" target="' + ocms_mli_Utility.getLinkTarget(node.target) + '">' + node.getMenuItemName() + '</a>' +
                        '</h3>';

                        if (node.children != null && node.children.size() > 0) {
                            html += '<ul>' +
                                        generateSiteMapChildren(node) +
                                    '</ul>';
                        }

            html += '</div>';

        }

        return html;

    }

    /**
     * @description Recursive function to generate the list items found under the main headings.
     * @param  node A MenuNode item
     * @return String mark-up string.
     */
    private String generateSiteMapChildren(cms.MenuNode node) {

        String html = '';

        for (cms.MenuNode n : node.getOrderedChildren()) {

            html += '<li>' +
                        '<a onclick=\'' + ocms_mli_Utility.getLinkScript(n.javascript) + '\' href="' + ocms_mli_Utility.getLinkHref(n.targetPage) + '" target="' + ocms_mli_Utility.getLinkTarget(n.target) + '">' + n.getMenuItemName() + '</a>';

                        if (n.children != null && n.children.size() > 0) {
                            html += '<ul>' +
                                        generateSiteMapChildren(n) +
                                    '</ul>';
                        }

            html += '</li>';

        }

        return html;

    }

}