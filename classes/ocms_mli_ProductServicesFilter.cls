/**
 * Definition and markup generation for Manulife.com Product & Services Filter with banner image (C17A).
 *
 * @author  Saloni Mittal
 * @date    2015-May-20
 *
 */
global with sharing class ocms_mli_ProductServicesFilter extends cms.ContentTemplateController {

    // Constructor for the execute request
    global ocms_mli_ProductServicesFilter() {}

    // Constructor for the content editor VF page
    global ocms_mli_ProductServicesFilter(cms.GenerateContent gc) {
        super(gc);
    }

    // Constructor for generator
    global ocms_mli_ProductServicesFilter(cms.CreateContentController cc) {
        super(cc);
    }

    /**
     * @description  Used for active country selector in products & services filter drop-down
     */
    public String sSelectedCountry {
        get {
            return this.getProperty('sSelectedCountry');
        }
    }

    /**
     * @description  Used for banner image visible on mobile
     */
    public String sMobileImage {
        get {
            return this.getProperty('sMobileImage');
        }
    }

    /**
     * @description  Used for banner image visible on tablet
     */
    public String sTabletImage {
        get {
            return this.getProperty('sTabletImage');
        }
    }

    /**
     * @description  Used for banner image visible on desktop
     */
    public String sDesktopImage {
        get {
            return this.getProperty('sDesktopImage');
        }
    }

    /**
     * @description  Used for banner image alt text.
     */
    public String sBannerImageAlt {
        get {
            return getProperty('sBannerImageAlt');
        }
        set;
    }

    /**
     * @description  Used for product & services filter title
     */
    public String sProdServFiltTitle {
        get { return getProperty('sProdServFiltTitle'); }
    }

    /**
     * @description  Used for product services filter link text (e.g.Visit).
     */
    public String sProdServFiltLinkText {
        get { return getProperty('sProdServFiltLinkText'); }
    }

    /**
     * @description  Used for product services filter link country text (e.g.Manulife Canada)
     */
    public String sProdServFiltCountry {
        get { return getProperty('sProdServFiltCountry'); }
    }

    /**
     * @description  Used for product services submit button text
     */
    public String sButtonLabel {
        get { return getProperty('sButtonLabel'); }
    }

    /**
     * @description  Used for product services filter link.
     */
    public String sProdServFiltLink {
        get { return getProperty('sProdServFiltLink'); }
    }

    private cms.Link objLink {
        get { return new cms.Link(sProdServFiltLink); }
    }

    /**
     * @description  Used for product services page link.
     */
    public String sProdServPageTitle {
        get { return getProperty('sProdServPageTitle'); }
    }

    /**
     * @description  Used if content needs to be dropped on default products & services page to look for geolocation
     */
    public String sAddScriptForGeolocation {
        get {
            return this.getProperty('sAddScriptForGeolocation');
        }
    }

    /**
     * @description  Used for product & services filter json string
     */
    public String jsnProdServFiltSelect {
        get { return getProperty('jsnProdServFiltSelect'); }
    }

    /**
     * @description  Used for deserializing the product & services filter json string back into objects
     */
    private List<ProdServFilter> lstProdServFiltSelect {
        get {
            // attempting to resolve all caching generation exceptions
            try {
                return (List<ProdServFilter>)JSON.deserialize(jsnProdServFiltSelect, List<ProdServFilter>.class);
            }
            catch (Exception e) {
                return (new List<ProdServFilter>{});
            }
        }
    }

    /**
     * @description  Used for product & services filter object to store deserialized json string content
     */
    public class ProdServFilter {
        String sFilterCode;
        String sFilterText;
        String sFilterLink;
        public ProdServFilter() {}
    }

    /**
     * @description  Generates mark-up for product & services filter with banner image.
     * @return  String  A string of mark-up used to generate the content.
     */
    global override String getHTML() {

        String sProdServFiltHtml = '';
        sProdServFiltHtml += '<!-- >>> ocms_mli_ProductServicesFilter.getHTML(...) -->' // to fix any jQuery parsing issues, see: https://pl5.projectlocker.com/Stantive/PSTools/trac/wiki/gotcha/OCMSCachingMissingMarkup
                          +  '<div class="productsServicesFilter">'
                          +     '<div class="bannerImage">'
                          +         '<div class="mask"></div>'
                          +         '<img src="' + ((this.sMobileImage != null) ? this.sMobileImage : '') + '" alt="' + ((this.sBannerImageAlt != null) ? this.sBannerImageAlt : '') + '" class="mobileOnly">'
                          +         '<img src="' + ((this.sTabletImage != null) ? this.sTabletImage : '') + '" alt="' + ((this.sBannerImageAlt != null) ? this.sBannerImageAlt : '') + '" class="tabletOnly">'
                          +         '<img src="' + ((this.sDesktopImage != null) ? this.sDesktopImage : '') + '" alt="' + ((this.sBannerImageAlt != null) ? this.sBannerImageAlt : '') + '" class="desktopOnly">'
                          +     '</div>'
                          +     '<div class="productsServicesFilterContainer">'
                          +         '<div class="bannerContent">'
                          +         '<div class="productsServiceFilter__content">'
                          +             '<label class="prodServFiltTitle" for="prodServFiltCountrySelect">' + ((this.sProdServFiltTitle != null) ? this.sProdServFiltTitle.escapeHtml4() : '') + '</label>'
                          +             '<div class="productsServiceFilter__contentMask">';
        if (!(lstProdServFiltSelect.isEmpty())) {
            sProdServFiltHtml +=        '<div class="productsServicesFilterRow">'
                              +             '<div class="customSelect customSelect--dark accessibleLink" data-hw-module="module/SelectWithFlagsAndCustomScrollbar" aria-label="' + ((this.sProdServFiltTitle != null) ? this.sProdServFiltTitle.escapeHtml4() : '') + '">'
                              +                  buildProdServFilter()
                              +             '</div>';
            if (this.sButtonLabel != null) {
                sProdServFiltHtml +=         '<input type="submit" value="'
                                  +          this.sButtonLabel + '" class="button" />';
            }
            sProdServFiltHtml +=         '</div>';
        }
        if (this.sProdServFiltLinkText != null) {
            sProdServFiltHtml +=         '<div class="jumper">'
                              +             '<a class="prodServFiltCountryLink" onclick=\'' + ocms_mli_Utility.getLinkScript(objLink.javascript) + '\' href="' + ocms_mli_Utility.getLinkHref(objLink.targetPage) + '" target="' + ocms_mli_Utility.getLinkTarget(objLink.target) + '">'
                              +                 ((this.sProdServFiltLinkText != null) ? this.sProdServFiltLinkText : '')
                              +                 ' <span>' + ((this.sProdServFiltCountry != null) ? this.sProdServFiltCountry : '') + '</span>'
                              +             '</a>'
                              +          '</div>';
        }
        sProdServFiltHtml +=          '</div>'
                          +          '</div>'
                          +         '</div>'
                          +     '</div>'
                          + '</div>'
                          + '<h2 class="pageTitle hidden">' + ((this.sProdServPageTitle != null) ? this.sProdServPageTitle : '') + '</h2>';

        if (this.sAddScriptForGeolocation == 'true') {
            sProdServFiltHtml += '<div class="defaultProdServ"><script>'
                              +     'if(typeof window.MLI === "undefined"){'
                              +        'window.MLI = {};'
                              +     '}'
                              +     'if(typeof window.MLI.content === "undefined"){'
                              +        'window.MLI.content = {};'
                              +     '}'
                              +     'MLI.content[\'prodServCountryLocator\'] = ' + jsnProdServFiltSelect + ';'
                              +     '$(\'.T4productsServices\').hide();'
                              + '</script>';
            if (this.pm == 'prev'){
                sProdServFiltHtml += '<script type="text/javascript" src="' + ocms_mli_Utility.getResourceURL('ocms_mli_prodServCountryLocator', 'js/prodServCountryLocator.js') + '"></script>';
            }
            else if (this.pm == 'production'){
                // Note: for performance (avoidng an https hit) consider inlining the mimifed JS, run the grunt task and copy the <JS-FILE>.min.js` contents in between the script tags
                // sProdServFiltHtml += '<script type="text/javascript" src="' + ocms_mli_Utility.getResourceURL('ocms_mli_prodServCountryLocator', 'js/prodServCountryLocator.min.js') + '"></script>';
                sProdServFiltHtml += '<script>';
                sProdServFiltHtml += 'function initProdServCountryLocator(){var a="";void 0!==MLI.location.country&&""!==MLI.location.country?(debug.log("prodServCountryLocator.js: Using MLI Object"),a=MLI.location.country,fCountryInitCheck(a)?fRedirectPageToCountryProdServ():$(".T4productsServices").show()):void 0!==OCMS.getCookie("apex__ocmsCountry")&&""!==OCMS.getCookie("apex__ocmsCountry")?(debug.log("prodServCountryLocator.js: Using Cookie"),a=OCMS.getCookie("apex__ocmsCountry"),fCountryInitCheck(a)?fRedirectPageToCountryProdServ():$(".T4productsServices").show()):(debug.log("prodServCountryLocator.js: Using GEOIP service"),$.orchestracmsRestProxy.doAjaxServiceRequest("ocms_GeoLocation",{action:"getCountryForIP"},geoIPHandler,void 0,!0))}function fCountryInitCheck(a){for(var b=!1,c=MLI.content.prodServCountryLocator,d=0;d<c.length;++d){var e=c[d];if(e.sFilterCode==a){b=!0,MLI.content.prodServCountryLink=e.sFilterLink;break}}return b}function fRedirectPageToCountryProdServ(){var a=MLI.content.prodServCountryLink;void 0!==a&&null!==a&&""!==a?window.location.replace(a):$(".T4productsServices").show()}function geoIPHandler(a,b,c){if(b.success){var d=b.data.country.iso_code;fCountryInitCheck(d)?fRedirectPageToCountryProdServ():$(".T4productsServices").show()}else $(".T4productsServices").show()}MLI.content.prodServCountryLink="",$(document).ocmsDynamicLoadFinished(function(){debug.log("load prodServCountryLocator.js"),debug.log("prodServCountryLocator.js: initProdServCountryLocator()"),initProdServCountryLocator()});';
                sProdServFiltHtml += '</script>';
            }

            sProdServFiltHtml += '</div>';
        }
        sProdServFiltHtml += '<!-- <<< ocms_mli_ProductServicesFilter.getHTML(...) -->';
        return sProdServFiltHtml;
    }

    /**
     * @description  Generates mark-up for select box.
     * @return  String  A string of mark-up used to generate the select box.
     */
    private String buildProdServFilter() {
        String html = '<select class="prodServFiltCountrySelect" id="prodServFiltCountrySelect">';
        for (ProdServFilter deserializedProdServFilter : lstProdServFiltSelect) {
            html += '<option class="option' + (deserializedProdServFilter.sFilterText).replaceAll('\\s+', '')
                 + '" data-flag-class="flag-' + (deserializedProdServFilter.sFilterCode).toLowerCase();
            if (deserializedProdServFilter.sFilterCode != 'None') {
                html += '" data-country-url="' + (deserializedProdServFilter.sFilterLink);
            }
            html += '" data-country-code="' + (deserializedProdServFilter.sFilterCode);
            if ((deserializedProdServFilter.sFilterCode) == ((this.sSelectedCountry != null) ? this.sSelectedCountry : '')) {
                html += '" selected="selected';
            }
            html += '" value="' + deserializedProdServFilter.sFilterText + '">'
                 +   deserializedProdServFilter.sFilterText
                 +  '</option>';
        }
        html += '</select>';
        return html;
    }
}