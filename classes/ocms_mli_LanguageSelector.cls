global with sharing class ocms_mli_LanguageSelector extends cms.ContentTemplateController {

    global ocms_mli_LanguageSelector() {}

    global ocms_mli_LanguageSelector(cms.GenerateContent gc) {
        super(gc);
    }

    global ocms_mli_LanguageSelector(cms.CreateContentController cc) {
        super(cc);
    }

    /**
     * @description Needed for testing preview mode condition.
     */
    public String test_pm { get; set; }

    public String jsnAvailableLanguages {
        get {

            List<SObject> queryList = new List<SObject>();
            Map<String, String> langPair = new Map<String, String>();

            //SELECT cms__Language__c, cms__Language_Code__c FROM cms__Language__c WHERE cms__sites__r.cms__Site_Name__c = 'Manulife' AND cms__Active__c = true

            queryList = Database.query('SELECT cms__Language__c, cms__Language_Code__c FROM cms__Language__c WHERE cms__sites__r.cms__Site_Name__c = \'' + site_name + '\' AND cms__Active__c = true');

            for(SObject obj: queryList){
                langPair.put((String)obj.get('cms__Language_Code__c'), (String)obj.get('cms__Language__c'));
            }

            return JSON.serialize(langPair);

            // Was using the service API method to get the language list but found that after disabling a language, it would still appear in the possible selections. ServiceAPI does not currently
            // have a method for finding just active languages. However, it could, in the future.

            //cms.ServiceAPI sAPI = getServiceAPI();
            //List<Map<String,String>> langList = new List<Map<String,String>>();
            //Map<String,String> langMap = new Map<String,String>();

            //langList = sAPI.getLanguageOptions();

            //for(Map<String, String> m: langList){
            //    langMap.putAll(m);
            //}

            //return JSON.serialize(langMap);

        }
        set;
    }

    public String jsnLanguageButtons {
        get{
            return getProperty('jsnLanguageButtons');
        }
        set;
    }

    global override String getHTML() {
        String html = '';

        html += '<!-- >>> ocms_mli_languageSelector.getHTML(...) -->' +
                '<div class="languageSelector mastheadUtilitiesItem mastheadLanguge" id="languageSelector">' +
                '</div>' +
                '<script>' +

                    'if(typeof window.MLI === \'undefined\'){' +
                        'window.MLI = {};' +
                    '}' +

                    'if(typeof window.MLI.content === \'undefined\'){' +
                        'window.MLI.content = {}' +
                    '}' +

                    'MLI.content[\'languageSelector\'] = {};' +
                    'MLI.content.languageSelector[\'langButtons\'] = JSON.parse(\'' + jsnLanguageButtons + '\')' +

                '</script>';

                if (this.pm == 'prev' || this.test_pm == 'prev'){
                    html += '<script type="text/javascript" src="' + ocms_mli_Utility.getResourceURL('ocms_mli_languageSelector', 'js/languageSelector.js') + '"></script>';
                }
                else if (this.pm == 'production'){
	                // Note: For performance (avoidng an https hit) consider inlining the mimifed JS. If your project uses grunt minification task then run that and
		            //       copy the <JS-FILE>.min.js` contents between the `<script>` tags, or as a fallback use the output from 'https://closure-compiler.appspot.com'.
		            //       When pasting ensure that any `\` (backslashes) are converted to `\\` as that is the escape character in Apex. //html += '<script type="text/javascript" src="' + ocms_mli_Utility.getResourceURL('ocms_mli_languageSelector', 'js/languageSelector.min.js') + '"></script>';

                    html += '<script>';
                    // 2016-03-16 - [Stephen Scholtz] Revised functionality to strip out the ocmsLang URL param, if present, before
                    //              attempting to redirect or reload the page after setting the language cookie.  This is to avoid
                    //              a "language trap" where the cookie was set, the page reloaded, but the ocmsLang URL param would
                    //              stay and the user would be "stuck" in whatever language the URL param specified.
                    //
                    // Note: If we use location.assign, or even location.href, but don't actually modify the page URL, the browser
                    // won't go back to the server and ask Orchestra to re-generate the page in the right language content. Strip
                    // out the ocmsLang param if present, which will force the browser back to the server. Otherwise, use "reload(true)".
                        // Previous compressed JS
                        // html += 'function initLanguageSelector(){var a=CMS.lang;for(var b in MLI.content.languageSelector.langButtons){var c=MLI.content.languageSelector.langButtons[b];b!=a&&addLanguageButton(b,c)}}function addLanguageButton(a,b){var c=\'<a class="mastheadLanguageTrigger accessibleLink" href="#" onClick="setLanguage(\\\'\'+a+\'\\\')" title="\'+b.accLanguage+\'"><span aria-hidden="true">\'+b.inputVal+\'</span><span class="accessible" lang="\'+a+\'">\'+b.accLanguage+"</span></a>";$("#languageSelector").append(c)}function setLanguage(a){OCMS.setCookie("apex__ocmsLang",a),location.reload(true)}$(document).ocmsDynamicLoadFinished(function(){"MSIE"===OCMS.browserName&&parseInt(OCMS.browserVersion)<=8||(debug.log("load languageSelector.js"),debug.log("languageSelector.js: initLanguageSelector()"),initLanguageSelector())});';
                    
                    // 2016-04-20 - [Stephen Scholtz] Revised again, added another location to append the language select link, the new
                    //              desktop-only mast head.
                    // 2017-09-15 - [mmcg] Revised to force language toggle to properly domain'd site now that French site will always serve French content
                    html += 'function initLanguageSelector(){var a=CMS.lang;for(var b in MLI.content.languageSelector.langButtons){var c=MLI.content.languageSelector.langButtons[b];b!=a&&addLanguageButton(b,c)}}function addLanguageButton(a,b){var c=a,d=/en/,e=(window.location.hostname,window.location.search),f=/\\?/,g=window.location.hash,h=/#/,i=d.test(c),j=f.test(e),k=h.test(g),l="";l+=i?"http://www.manulife.com":"http://www.manuvie.com",l+=window.location.pathname,j&&(l+=e),k&&(l+=g);var m=\'<a class="mastheadLanguageTrigger accessibleLink" href="\'+l+\'" title="\'+b.accLanguage+\'"><span aria-hidden="true">\'+b.accLanguage+\'</span><span class="accessible" lang="\'+a+\'">\'+b.accLanguage+"</span></a>";$("#languageSelector").append(m),$("#mastheadDesktopLanguageSelector").append(m)}function setLanguage(a){OCMS.setCookie("apex__ocmsLang",a),document.location.search.indexOf("ocmsLang=")>-1?0==document.location.search.indexOf("?ocmsLang=")&&document.location.search.indexOf("&")>-1?document.location.assign(document.location.href.replace(/ocmsLang=[a-zA-Z_]+[&]?/g,"")):document.location.assign(document.location.href.replace(/[&?]?ocmsLang=[a-zA-Z_]+/g,"")):location.reload(!0)}$(document).ocmsDynamicLoadFinished(function(){"MSIE"===OCMS.browserName&&parseInt(OCMS.browserVersion)<=8||(debug.log("load languageSelector.js"),debug.log("languageSelector.js: initLanguageSelector()"),initLanguageSelector())});';


                    html += '</script>';
                }

        html += '<!-- <<< ocms_mli_languageSelector.getHTML(...) -->';

        return html;
    }

}