/**
 * Custom taxonomy loader to meet Manulife.com's products & services banner image and products.
 *
 * @author  Saloni Mittal
 * @date    2015-May-26
 *
 */
global virtual with sharing class ocms_mli_ProductServiceLoader extends cms.ContentTemplateController {

    private final cms.CreateContentController CCC; // convenience reference to the CreateContentController instance use when Editing content
    private final cms.GenerateContent GC; // convenience reference to the GenerateContent instance used when rendering or ajax end point?
    private final cms.ServiceAPI oServiceAPI; // convience variable to access the ServiceAPI instance which we initialize only once
    private final Map<String, String> oPageParametersMap; // will hold `ApexPages.currentPage().getParameters()`


    // called for example in `executeRequest`
    public ocms_mli_ProductServiceLoader() { /* no need the `Layout` in the name word as we are extending ContentTemplateController */
        this.oServiceAPI = this.getServiceAPI();
        this.oPageParametersMap = ApexPages.currentPage().getParameters();
    }

    // because we are an visual force page extension we must accept the instance of that visual forces page controller
    public ocms_mli_ProductServiceLoader(cms.CreateContentController cc) {
        super(cc);
    }

    // because we are an visual force page extension we must accept the instance of that visual forces page controller
    public ocms_mli_ProductServiceLoader(cms.GenerateContent gc) {
        super(gc);
    }

    // Required for cms.ServiceInterface instantiation.
    global System.Type getType() {
        return ocms_mli_ProductServiceLoader.class;
    }

    global String sTaxonomyContentType {  // upadted from page GET/POST parameters, we support OCMS `tags` PAGE parameter too
        get {
            return getProperty('sTaxonomyContentType');
        }
        set;
    }

    global String sTaxonomyContentLayout {  // upadted from page GET/POST parameters, we support OCMS `tags` PAGE parameter too
        get {
            return getProperty('sTaxonomyContentLayout');
        }
        set;
    }

    // Content Properties - but we need a fallback if called through Ajax end point using page parameters
    global String sTagPaths {  // upadted from page GET/POST parameters
        get {
            return (this.getProperty('sTagPaths') != null ? this.getProperty('sTagPaths') : '');
        }
        set;
    }

    public String getProdServTileAsHTML() {

            Pattern oRegexPattern = Pattern.compile('(\\|\\||&&)*(.*?)(?=&&|\\|\\||$)');

            cms.TagContentGroup oTCGDisplay = null;

            Matcher oMatcher = oRegexPattern.matcher(this.sTagPaths);
            Map<Id, String> oPrunedContentRenderingsMap = null; // Id is of content and string is the rendered markup

            List<String> oCurrentTagPathList = new List<String>();

            while (oMatcher.find()) {

                oCurrentTagPathList.add('/' + this.sTagPaths);

                cms.TagContentGroup oCurrentTCG = this.oServiceAPI.getContentByTaxonomyGrouping(oCurrentTagPathList
                                                  ,this.sTaxonomyContentType
                                                  ,new List<String>{this.sTaxonomyContentLayout
                                                                    ,this.sTaxonomyContentLayout
                                                                    ,this.sTaxonomyContentLayout
                                                                    ,this.sTaxonomyContentLayout
                                                                    ,this.sTaxonomyContentLayout
                                                                    ,this.sTaxonomyContentLayout}
                                                  ,'date');
                System.debug('oCurrentTCG:'+oCurrentTCG);

                oTCGDisplay = oCurrentTCG;
            }

            if (oPrunedContentRenderingsMap == null) {
                oPrunedContentRenderingsMap = new Map<Id, String>();
                // loop over the content and add it to our pruned list
                Map<Id, Map<String, String>> oTCGDisplayRenderingMap =  oTCGDisplay.getRenderingsMap();
                for (Id oKeyId : oTCGDisplayRenderingMap.keySet()) {
                    oPrunedContentRenderingsMap.put(oKeyId, oTCGDisplayRenderingMap.get(oKeyId).get(this.sTaxonomyContentLayout));
                }
                System.debug('oPrunedContentRenderingsMap:'+oPrunedContentRenderingsMap);
            }

            String sProductTileHTML = '';
            for (Id oKeyId : oPrunedContentRenderingsMap.keySet()) {
                sProductTileHTML += oPrunedContentRenderingsMap.get(oKeyId);
            }

            return sProductTileHTML;
    }

    // For generated markup
    global virtual override String getHTML() {
        String sHTML = '';
        sHTML += getProdServTileAsHTML();
        return sHTML;
    }
}