global with sharing class ocms_mli_CountryLocator extends cms.ContentTemplateController{

    // Constructor for the execute request
    global ocms_mli_CountryLocator() {}

    // Constructor for the content editor VF page
	global ocms_mli_CountryLocator(cms.GenerateContent gc) {
        super(gc);
    }

    // Constructor for the generator
    global ocms_mli_CountryLocator(cms.CreateContentController cc) {
        super(cc);
    }

    /**
     * @description A string containing an array of json objects. These objects contain the corresponding
     *              messages and links required for the geolocation banner. These values are added to the
     *              markup via countrylocator.js
     */
    public String jsnCountryInfo {
        get { return getProperty('jsnCountryInfo'); }
    }

    /**
     * @description A string containing the label of the close button.
     */
    public String lblClose {
        get { return ocms_mli_Utility.noNull(getProperty('lblClose')); }
    }

    /**
     * @description Accessibility field used to describe what happens when the button is pressed.
     */
    public String accAction {
        get { return ocms_mli_Utility.noNull(getProperty('accAction')); }
    }

    /**
     * @description Needed for testing preview mode condition.
     */
    public String test_pm { get; set; }

    global override String getHTML() {
        String html = '';

        // define the markup of the geolocation banner, values will be added by countryLocator.js
        html += '<!-- >>> ocms_mli_CountryLocator.getHTML(...) -->' + // to fix any jQuery parsing issues, see: https://pl5.projectlocker.com/Stantive/PSTools/trac/wiki/gotcha/OCMSCachingMissingMarkup
                '<div class="geolocation hide" data-hw-module="module/Geolocation" data-hw-options="hidden: true">' +
                    '<div class="wrapper">' +
                        '<div class="content">' +
                            '<div class="geolocationTextContainer">' +
                                '<p class="introParagraph"></p>' +
                                '<a href="#" target="_blank" class="visitButton" title="' + accAction + '"><span class="accessible">: ' + accAction + '</span></a>' +
                            '</div>' +
                            '<button type="button" class="closeButton accessibleLink">' + lblClose + '</button>' +
                        '</div>' +
                    '</div>' +
                '</div>' +
                '<script>' +
                    // Extract any data needed from the controller class and append it to the MLI object
                    // Check first to make sure MLI isn't undefined, if it is, define it as an empty object.
                    'if(typeof window.MLI === "undefined"){' +
                        'window.MLI = {};' +
                    '}' +

                    'if(typeof window.MLI.content === "undefined"){' +
                        'window.MLI.content = {};' +
                    '}' +

                    'MLI.content[\'countryLocator\'] = JSON.parse(\'' + jsnCountryInfo + '\');' +

                '</script>';

                // If in preview mode, load the unminified version of this content's javascript.
                if (this.pm == 'prev' || this.test_pm == 'prev'){
                    html += '<script type="text/javascript" src="' + ocms_mli_Utility.getResourceURL('ocms_mli_countryLocator', 'js/countryLocator.js') + '"></script>';
                }
                else if (this.pm == 'production'){
                    // Note: for performance (avoidng an https hit) consider inlining the mimifed JS, run the grunt task and copy the <JS-FILE>.min.js` contents in between the script tags
                    // html += '<script type="text/javascript" src="' + ocms_mli_Utility.getResourceURL('ocms_mli_countryLocator', 'js/countryLocator.min.js') + '"></script>';
                    html += '<script>';
                    html += 'function initCountryLocator(){var a="",b=OCMS.getCookie("apex__ocmsShowGeolocationMessage");b="true"===b||void 0===b||""===b,b?($(".geolocation").attr("data-hw-options","hidden: false"),void 0!==MLI.location.country&&""!==MLI.location.country?(debug.log("countryLocator.js: Using MLI Object"),a=MLI.location.country,countryInitCheck(a)&&(populateCountryLocatorFields(a),$(".geolocation").removeClass("hide"))):void 0!==OCMS.getCookie("apex__ocmsCountry")&&""!==OCMS.getCookie("apex__ocmsCountry")?(debug.log("countryLocator.js: Using Cookie"),a=OCMS.getCookie("apex__ocmsCountry"),countryInitCheck(a)&&(populateCountryLocatorFields(a),$(".geolocation").removeClass("hide"))):(debug.log("countryLocator.js: Using GEOIP service"),$.orchestracmsRestProxy.doAjaxServiceRequest("ocms_GeoLocation",{action:"getCountryForIP"},geoIPHandler,void 0,!0))):$(".geolocation").attr("data-hw-options","hidden: true")}function countryInitCheck(a){var b=!1;return void 0!==MLI.content.countryLocator[a]&&(debug.log("countryLocator.js: countryInitCheck() passed"),b=!0),b}function populateCountryLocatorFields(a){$(".geolocation p.introParagraph").html(MLI.content.countryLocator[a].message),$(".geolocation a.visitButton").html(MLI.content.countryLocator[a].buttonText).attr("href",MLI.content.countryLocator[a].buttonLink).click(setShowGeolocation),$(".geolocation .closeButton").click(setShowGeolocation)}function geoIPHandler(a,b,c){if(b.success){var d=b.data.country.iso_code;countryInitCheck(d)&&(populateCountryLocatorFields(d),$(".geolocation").removeClass("hide"))}}function setShowGeolocation(){OCMS.setCookie("apex__ocmsShowGeolocationMessage","false")}$(document).ocmsDynamicLoadFinished(function(){debug.log("load countryLocator.js"),debug.log("countryLocator.js: initCountryLocator()"),initCountryLocator()});';
                    html += '</script>';
                }

                html += '<!-- <<< ocms_mli_CountryLocator.getHTML(...) -->';

        return html;
    }

}