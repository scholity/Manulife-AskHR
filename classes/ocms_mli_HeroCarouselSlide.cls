global with sharing class ocms_mli_HeroCarouselSlide extends cms.ContentTemplateController {

    global ocms_mli_HeroCarouselSlide() {}

    global ocms_mli_HeroCarouselSlide(cms.GenerateContent gc) {
        super(gc);
    }

    global ocms_mli_HeroCarouselSlide(cms.CreateContentController cc) {
        super(cc);
    }

    public String strMobileImage {
        get {
            return ocms_mli_Utility.noNull(this.getProperty('strMobileImage'));
        }
    }

    public String strTabletImage {
        get {
            return ocms_mli_Utility.noNull(this.getProperty('strTabletImage'));
        }
    }

    public String strDesktopImage {
        get {
            return ocms_mli_Utility.noNull(this.getProperty('strDesktopImage'));
        }
    }

    public String strTitle {
        get {
            return ocms_mli_Utility.noNull(getProperty('strTitle'));
        }
    }

    public String strSubTitle {
        get {
            return ocms_mli_Utility.noNull(getProperty('strSubTitle'));
        }
    }

    public String strPlayVideo {
        get {
            return ocms_mli_Utility.noNull(getProperty('strPlayVideo'));
        }
    }

    public String strAccessibleDescription {
        get {
            return ocms_mli_Utility.noNull(getProperty('strAccessibleDescription')); //The story of Tony & Sandra
        }
    }

    public String strAccessiblePlayAction {
        get {
            return ocms_mli_Utility.noNull(getProperty('strAccessiblePlayAction')); //Opens in an overlay
        }
    }

    public String strAccessiblePlayVideo {
        get {
            return ocms_mli_Utility.noNull(getProperty('strAccessiblePlayVideo')); //Play video: opens in an overlay
        }
    }

    public String strAccessibleOverlayClose {
        get {
            return ocms_mli_Utility.noNull(getProperty('strAccessibleOverlayClose')); //Close Overlay
        }
    }

    public String strOverlayTitle {
        get {
            return ocms_mli_Utility.noNull(getProperty('strOverlayTitle'));
        }
    }

    public String strVideoURL {
        get {
            return ocms_mli_Utility.noNull(getProperty('strVideoURL')); //Link to video to play.
        }
    }

    public String strAccessibleArticleName {
        get {
            return ocms_mli_Utility.noNull(getProperty('strAccessibleArticleName'));
        }
    }

    public String strAccessibleViewArticle {
        get {
            return ocms_mli_Utility.noNull(getProperty('strAccessibleViewArticle'));
        }
    }

    public String strLink {
        get { return getProperty('strLink'); }
    }

    private cms.Link objLink {
        get { return new cms.Link(strLink); }
    }

    private String strHTMLOverlay {
        get {

            String html = '';
            html += '<script type="text/template" id="overlay' + this.content_layout_instance.Id + '">' +
                        '<div class="dialog" role="dialog" aria-labelledby="' + this.content_layout_instance.Id + 'Title">' +
                            '<button type="button" class="closeOverlay accessibleLink">' + strAccessibleOverlayClose + '</button>' +
                            '<div class="dialogHeader">' +
                                '<h2 class="dialogHeading" id="' + this.content_layout_instance.Id + 'Title">' + strOverlayTitle + '</h2>' +
                            '</div>' +
                            '<div class="dialogContent">' +
                                '<div class="videoContainer">' +
                                    '<iframe id="player" width="560" height="315" src="' + strVideoURL + '?rel=0&enablejsapi=1" frameborder="0" allowfullscreen></iframe>' +
                                '</div>' +
                            '</div>' +
                        '</div>' +
                    '</script>';

            return html;

        }
    }

    global override String getHTML() {
        String html = '';
        html += '<!-- >>> ocms_mli_HeroCarouselSlide.getHTML(...) -->'; // to fix any jQuery parsing issues, see: https://pl5.projectlocker.com/Stantive/PSTools/trac/wiki/gotcha/OCMSCachingMissingMarkup

        html += '<div class="heroTile hide">' +
                    '<div class="heroTileInner">' +
                        '<a onclick="' + objLink.javascript + '" href="' + ocms_mli_Utility.getLinkHref(objLink.targetPage) + '" target="' + ocms_mli_Utility.getLinkTarget(objLink.target) + '" aria-hidden="true" tabindex="-1" class="heroTile__link" title="' + strAccessibleViewArticle + '">' + // needs a link
                            '<span>' + strAccessibleViewArticle + '</span>' + // new accessibility field
                        '</a>' +
                        '<div class="heroTileBackground">' +
                            '<img class="mobileOnly" src="' + strMobileImage + '" alt="" />' +
                            '<img class="tabletOnly" src="' + strTabletImage + '" alt="" />' +
                            '<img class="desktopOnly" src="' + strDesktopImage + '" alt="" />' +
                        '</div>' +
                        // STI-7086: nutty hack to make the 'white' bar image overlay clickable, wrapping it in another anchor is invalid html, we are checking for overlay because prevent default was not working within HW code,
                        // and we are simulating the click on the actuall link rather then location.href change because of possible link attributes that can be specified in OrchestraCMS. 
                        '<div class="heroTextArea" onclick="$(\'.overlay\') ? $(this).prev().prev()[0].click() : true" style="cursor: pointer">' + 
                            '<div class="heroTextAreaInner">' +
                                '<p class="heroTileTitle">' + strTitle + '</p>' +
                                '<p class="heroTileSubtitle">' + strSubTitle + '</p>' ;

                                //only render the Hero Carousel image skiplink if all three items are supplied (link, Accessible Article Name and Accessible View Article label).
                                //ocms_mli_Utility.getLinkHref returns 'javascript:;' if no link was specified.'
                                if ((ocms_mli_Utility.getLinkHref(objLink.targetPage)!='javascript:;') && String.isNotBlank(strAccessibleArticleName) && String.isNotBlank(strAccessibleViewArticle)){ 
                                html += '<a class="skiplink" href="'+ ocms_mli_Utility.getLinkHref(objLink.targetPage) +'">' +
                                    	'<span class="accessible">' + strAccessibleArticleName + '</span>' +
                                    	strAccessibleViewArticle +
                                		'</a>';	
                                }
                                

                                if (strVideoURL != null && strVideoURL != '') {

                                    html += '<a onclick="if (typeof _satellite !== \'undefined\') { _satellite.track(\'YouTube\')}" href="#overlay' + this.content_layout_instance.Id + '" data-hw-module="widget/core/OverlayTrigger" class="heroPlayButton" title="' + ((strAccessiblePlayVideo != null) ? strAccessiblePlayVideo : '') + '">' +
                                                '<span class="icon icon-play"></span>' +
                                                '<span class="accessible">' + strAccessibleDescription + '</span>' +
                                                strPlayVideo +
                                                '<span class="accessible">' + strAccessiblePlayAction + '</span>' +
                                            '</a>';

                                }

        html +=             '</div>' +
                        '</div>' +
                    '</div>' +
                '</div>' +

                strHTMLOverlay;

        html += '<!-- <<< ocms_mli_HeroCarouselSlide.getHTML(...) -->'; // to fix any jQuery parsing issues, see: https://pl5.projectlocker.com/Stantive/PSTools/trac/wiki/gotcha/OCMSCachingMissingMarkup

        return html;
    }

}