global with sharing class ocms_mli_DeepLinks extends cms.ContentTemplateController {

    global ocms_mli_DeepLinks() {}

    global ocms_mli_DeepLinks(cms.GenerateContent gc) {
        super(gc);
    }

    global ocms_mli_DeepLinks(cms.CreateContentController cc) {
        super(cc);
    }

    /**
     * @description Link 1 image url
     */
    public String strLink1Image {
        get { return getProperty('strLink1Image'); }
    }

    /**
     * @description Link 1 text
     */
    public String strLink1Text {
        get { return getProperty('strLink1Text'); }
    }

    /**
     * @description Link 1 link string
     */
    public String strLink1Link {
        get { return getProperty('strLink1Link'); }
    }

    /**
     * @description Link 1 link object
     */
    private cms.Link objLink1Link {
        get { return new cms.Link(strLink1Link); }
    }

    /**
     * @description Link 2 image url
     */
    public String strLink2Image {
        get { return getProperty('strLink2Image'); }
    }

    /**
     * @description Link 2 text
     */
    public String strLink2Text {
        get { return getProperty('strLink2Text'); }
    }

    /**
     * @description Link 2 link string
     */
    public String strLink2Link {
        get { return getProperty('strLink2Link'); }
    }

    /**
     * @description Link 2 link object
     */
    private cms.Link objLink2Link {
        get { return new cms.Link(strLink2Link); }
    }

    /**
     * @description Link 3 image url
     */
    public String strLink3Image {
        get { return getProperty('strLink3Image'); }
    }

    /**
     * @description Link 3 text
     */
    public String strLink3Text {
        get { return getProperty('strLink3Text'); }
    }

    /**
     * @description Link 3 link string
     */
    public String strLink3Link {
        get { return getProperty('strLink3Link'); }
    }

    /**
     * @description Link 3 link object
     */
    private cms.Link objLink3Link {
        get { return new cms.Link(strLink3Link); }
    }

    /**
     * @description Link 4 image url
     */
    public String strLink4Image {
        get { return getProperty('strLink4Image'); }
    }

    /**
     * @description Link 4 text
     */
    public String strLink4Text {
        get { return getProperty('strLink4Text'); }
    }

    /**
     * @description Link 4 link string
     */
    public String strLink4Link {
        get { return getProperty('strLink4Link'); }
    }

    /**
     * @description Link 4 link object
     */
    private cms.Link objLink4Link {
        get { return new cms.Link(strLink4Link); }
    }

    /**
     * @description Accessibility field for the word 'page', as in page 1 of 3
     */
    public String accPage {
        get { return getProperty('accPage'); }
    }

    /**
     * @description Accessibility field for the word 'of', as in 1 of 3
     */
    public String accOf {
        get { return getProperty('accOf'); }
    }

    /**
     * @description Accessibility field for the word 'selected', as in 1 of 3 : selected
     */
    public String accSelected {
        get { return getProperty('accSelected'); }
    }

    global override String getHTML() {

        String html = '';

        html += '<div class="deepLinks" ' +
                     'data-hw-module="module/ResponsiveCarousel" ' +
                     'data-hw-options="maxBreakpoint: \'mobile\', ' +
                                      'selectors: {pager: \'ul.pagination\', ' +
                                                  'item: \'.deepLinkItem\', ' +
                                                  'belt: \'.belt\', ' +
                                                  'viewport: \'.viewport\'}, ' +
                                      'accessibility: {pagerMessage: \'' + ocms_mli_Utility.noNull(accPage) + ' {{index}} ' + ocms_mli_Utility.noNull(accOf) + ' {{length}}\', ' +
                                                      'selectedMessage: \'' + ocms_mli_Utility.noNull(accSelected) + '\'}" >' +

                    '<div class="viewport">' +
                        '<div class="belt">' +

                            generateBelt() +

                        '</div>' +
                    '</div>' +
                    '<div class="controls">' +
                        '<ul class="pagination">' +
                        '</ul>' +
                    '</div>' +
                '</div>';

        return html;

    }

    /**
     * @description Responsible for generating the deep links within the belt div. There is a
     *              maximum of 4 links, and any of them can be filled in at any time, so using
     *              a list of DeepLinks we make sure we only add the deep links that are defined
     *              properly.
     * @return String of HTML
     */
    private String generateBelt(){

        List<DeepLink> deepLinkList = new List<DeepLink>();
        String html = '';

        if ( strLink1Text != null && strLink1Image != null && strLink1Link != null ){
            DeepLink link1 = new DeepLink(objLink1Link);
            link1.text = strLink1Text;
            link1.image = strLink1Image;
            deepLinkList.add(link1);
        }

        if ( strLink2Text != null && strLink2Image != null && strLink2Link != null){
            DeepLink link2 = new DeepLink(objLink2Link);
            link2.text = strLink2Text;
            link2.image = strLink2Image;
            deepLinkList.add(link2);
        }

        if ( strLink3Text != null && strLink3Image != null && strLink3Link != null){
            DeepLink link3 = new DeepLink(objLink3Link);
            link3.text = strLink3Text;
            link3.image = strLink3Image;
            deepLinkList.add(link3);
        }

        if ( strLink4Text != null && strLink4Image != null && strLink4Link != null){
            DeepLink link4 = new DeepLink(objLink4Link);
            link4.text = strLink4Text;
            link4.image = strLink4Image;
            deepLinkList.add(link4);
        }

        // If an deeplinks have been added to the list, start building the html string.
        if (deepLinkList.size() > 0){

            html += '<ul class="deepLinkList">';

            for (DeepLink deepLink : deepLinkList){
                html += '<li class="deepLinkItem">' +
                            '<div class="content">' +
                                '<a onclick=\'' + deepLink.javascript + '\' href="' + deepLink.targetPage + '" target="' + deepLink.target + '">' +
                                    '<span class="itemIcon">' +
                                        '<span class="image-icon">' +
                                            '<img src="' + deepLink.image + '" />' +
                                        '</span>' +
                                    '</span>' +
                                    '<span class="title">' +
                                        deepLink.text +
                                    '</span>' +
                                '</a>' +
                            '</div>' +
                        '</li>';

            }

            html += '</ul>';

        }

        return html;

    }

    /**
     * @description private class used to make looping through
     *              a list of deep links easier.
     */
    private class DeepLink {

        public String text;
        public String image;
        public String javascript;
        public String targetPage;
        public String target;

        public DeepLink(cms.Link link){
            this.javascript = ocms_mli_Utility.getLinkScript(link.javascript);
            this.targetPage = ocms_mli_Utility.getLinkHref(link.targetPage);
            this.target = ocms_mli_Utility.getLinkTarget(link.target);
        }
    }
}