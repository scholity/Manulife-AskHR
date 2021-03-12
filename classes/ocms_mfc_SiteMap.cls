/**
 *  ocms_mfc_SiteMap.cls
 *
 *  2015-May-15 Bill Lucas
 *              Original, but cloned from ocms_mli_SiteMap.cls and then modified to not linkify a menu item whose targetPage and javascript member variables
 *              are empty (i.e. did not supply a destination link); in this case, simply the text of the "menu item" is output (wrapped in a span);
 *              also, diverges from OrchestraCMS markup convention wrt href value when onclick JavaScript opens link in new window;
 *              added a helper method for generating MFC site map links from menu nodes: generateMarkupFromMenuNode() instead of calling to mli_utility methods;
 *              also, changed markup to be more generic
 *                  <nav class="menuColumn_c">
 *                      <div class="menuColumn menuCol-0">
 *                          <h4>…</h4>
 *                              <ul>
 *                                  <li></li>…
 *                              </ul>
 *                      </div>
 *                      …
 *                  </nav>            
 */

global with sharing class ocms_mfc_SiteMap extends cms.MenuController {

    // Constructor for the execute request
    global ocms_mfc_SiteMap() {}


    // Constructor for the content editor VF page
    global ocms_mfc_SiteMap(cms.GenerateContent gc) {
        super(gc);
    }


    // Constructor for generator
    global ocms_mfc_SiteMap(cms.CreateContentController cc) {
        super(cc);
    }


    /**
     * @description Generates mark-up for content.
     * @return String A string of mark-up used to generate the content.
     */
    /**
     * @description Primary mark-up generation method, makes calls to several sub methods to build up
     *              entire site map.
     * @return String final mark-up string.
     */
    global override String getHTML() {

        List<cms.MenuNode> nodes = this.getOrderedRootNodes();
        Map<Integer, List<cms.MenuNode>> nodeMap = new Map<Integer, List<cms.MenuNode>>();

        // we create the a map from the ordered list of cms.MenuNode root nodes, where the key for each map entry is the group number
        for (cms.MenuNode node : nodes) {
            Integer i = node.groupNumber;

            if (nodeMap.get(i) == null) {
                nodeMap.put(i, new List<cms.MenuNode>());
            }
            nodeMap.get(i).add(node);
        }

        String html = '';

        html += '<nav class="menuColumn_c">' +
                    createColumns(nodeMap) +
                '</nav>';

        return html;
    }   // getHTML


    /**
     * @description Columns need to be created first for the sitemap, this differs from mega menu.
     *              Columns are created from the keys that are stored within the nodeMap. Since the
     *              user can use any groupnumber they like, it is wise to get these keys before
     *              building the columns.
     * @param  nodeMap Pass in the nodeMap created in getHTML(), this is a key-value pair
     *                 where the key is the groupNumber assigned to the first level of items.
     * @return String mark-up string.
     */
    private String createColumns(Map<Integer, List<cms.MenuNode>> nodeMap) {
        Integer totalColumns = nodeMap.size();
        String html = '';
        Set<Integer> nodeMapKeys = nodeMap.keySet();
        Integer columnIndex = 0;

        for (Integer i : nodeMapKeys) {
            html += '<div class="menuColumn' + ' menuCol-' + String.valueOf(columnIndex) + ' menuGroup-' + String.valueOf(i) + '">' +
                        generateSiteMapL1(nodeMap.get(i)) +
                    '</div>';
            ++columnIndex;
        }

        return html;
    }


    /**
     * @description Generates the first level of the site map, this level is unique in that it
     *              requires <h4> tags to wrap each menu item. If this heading has children 
     *              call generateSiteMapChildren() to recursively generate the unordered lists.
     * @param  nodeList A list of MenuNodes that are the menu items proper.
     * @return String mark-up string.
     */
    private String generateSiteMapL1(List<cms.MenuNode> nodeList) {
        String html = '';

        for (cms.MenuNode node : nodeList) {
            html += '<h4>' + generateMarkupFromMenuNode(node) + '</h4>';

            if (node.children != null && node.children.size() > 0) {
                html += '<ul>' + 
                            generateSiteMapChildren(node) +
                        '</ul>';
            }
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
            html += '<li>' + generateMarkupFromMenuNode(node);

            if (n.children != null && n.children.size() > 0) {
                html += '<ul>' +
                            generateSiteMapChildren(n) +
                        '</ul>';
            }

            html += '</li>';
        }

        return html;
    }

    /**
     * Generates full <a> tag markup for the given cms.MenuNode: if both the targetPage and JavaScript are empty emit the menu title text
     * wrapped in a span instead of an <a>
     * @param  cms.MenuNode
     * @return String - markup
     */
    global static String generateMarkupFromMenuNode (cms.MenuNode node) {
        String html = '<';
        String el = 'a';    // most of the time we will be creating an <a> element
        // Based on *current* OrchestraCMS code, MenuNode targetPage will be # under the following circumstances:
        //  - # was entered by the content author
        //  - nothing was entered by the content author
        //  - open in a pop-up window was chosen by the content author, **regardless** of the targetPage value
        //
        // because OrchestraCMS hides the actual author-entered data from us we don’t know if they meant to enter
        // just "#" for the targetPage or not; for our site map purposes we assume a targetPage of # is the text-only
        // case we are looking for and we do not recognize this as a link (in general, the author should be able to
        // specify a link of #; OrchestraCMS conflates this with no link specified at all)
        Boolean hasALink = String.IsNotBlank(node.targetPage) && node.targetPage != '#';
        String url = null;
        System.debug('node.targetPage: ' + node.targetPage);

        if (hasALink) {
            url = node.targetPage;
        } else {
            // can’t give up on the link just yet - if there is javascript, there _should_ be one in there
            
            // OrchestraCMS got its link generation wrong. It puts # as the href when it uses JS to open in a new window.
            // Best web practices would leave the href as was specified by the user, and have the JS leverage that.
            // So that’s what we do here (without fixing the JS), but we have to peek inside the javascript string to get the url!
            if (String.isNotBlank(node.javascript)) {
                // however, if there really was no link, OrchestraCMS adorably outputs window.open("null", …)
                Pattern urlPattern = Pattern.compile('window.open\\("([^,]+)"');    // would better use non-greedy
                Matcher urlMatcher = urlPattern.matcher(node.javascript);

                if (urlMatcher.find()) {
                    if (urlMatcher.group(1) != 'null') {
                        url = urlMatcher.group(1);
                        url = url.replaceAll('\\\\/', '/');         // really just changing \/ to / within window.open’s first parameter
                    }
                }
            }
        }

        if (url == null) {
            el = 'span';
        }

        html += el;     // html is now either '<a' or '<span'

        if (url != null) {
            // expecting that the javascript text includes double-quotes, we do not use them to delimit the onclick’s attribute value
            if (String.isNotBlank(node.javascript)) {
                html += ' onclick=\'' + node.javascript + '\'';
            } else {
                // target attribute irrelevant when JavaScript snippet used to open in new window
                if (String.isNotBlank(node.target)) {
                    html += ' target="' + node.target + '"';
                }
            }
            html += ' href="' + url + '"';
        }

        html += '>' + node.getMenuItemName() + '</' + el + '>';

        return html;
    }   // generateMarkupFromMenuNode
}   // <c ocms_mfc_SiteMap>