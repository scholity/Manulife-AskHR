global with sharing class ocms_mli_HeroCarouselControl extends cms.ContentTemplateController {

    global ocms_mli_HeroCarouselControl() {}

    global ocms_mli_HeroCarouselControl(cms.GenerateContent gc) {
        super(gc);
    }

    global ocms_mli_HeroCarouselControl(cms.CreateContentController cc) {
        super(cc);
    }

    public String strAccessibleStopCarousel {
        get {
            return this.getProperty('strAccessibleStopCarousel');
        }
    }

    public String strAccessiblePrevSlide {
        get {
            return this.getProperty('strAccessiblePrevSlide');
        }
    }

    public String strAccessibleNextSlide {
        get {
            return this.getProperty('strAccessibleNextSlide');
        }
    }

    public String strDuration {
        get {
            return this.getProperty('strDuration');
        }
    }

    /**
     * @description Needed for testing preview mode condition.
     */
    public String test_pm { get; set; }

    global override String getHTML() {
        String html = '';

        html += '<!-- >>> ocms_mli_HeroCarouselControl.getHTML(...) -->' + // to fix any jQuery parsing issues, see: https://pl5.projectlocker.com/Stantive/PSTools/trac/wiki/gotcha/OCMSCachingMissingMarkup
                '<div class="heroCarousel" data-hw-module="module/ResponsiveCarousel" data-hw-options="selectors:{next:\'.heroRightArrow\',prev:\'.heroLeftArrow\',pager:\'ul.slideSelect\',belt:\'.heroConveyor\',viewport:\'.heroArea\',item:\'.heroTile\'},duration:' + strDuration + '000">' +
                    '<div class="heroArea">' +

                /* legacy hero controls code
                        '<div class="heroControls">' +
                            '<div class="heroControlsInner hide">' +
                                '<button type="button" class="playPauseBtn pause" title="' + strAccessibleStopCarousel + '">' +
                                    '<span class="icon icon-play"></span>' +
                                    '<span class="accessible">' + strAccessibleStopCarousel + '</span>' +
                                '</button>' +
                                '<div class="heroPagination">' +
                                    '<button type="button" class="heroLeftArrow accessibleLink">' +
                                        '<span class="icon icon-angle-left"></span>' +
                                        '<span class="accessible">' + strAccessiblePrevSlide + '</span>' +
                                    '</button>' +
                                    '<ul class="slideSelect"></ul>' +
                                    '<button type="button" class="heroRightArrow accessibleLink">' +
                                        '<span class="icon icon-angle-right"></span>' +
                                        '<span class="accessible">' + strAccessibleNextSlide + '</span>' +
                                    '</button>' +
                                '</div>' +
                            '</div>' +
                        '</div>' +
                */

                        '<div class="heroControls heroLeftArrow">' +
                            '<div class="heroControlsInner hide">' +
                                '<div class="heroPagination">' +
                                    '<button type="button" class="heroLeftArrow accessibleLink">' +
                                        '<span class="icon icon-angle-left"></span>' +
                                        '<span class="accessible">' + strAccessiblePrevSlide + '</span>' +
                                    '</button>' +
                                '</div>' +
                            '</div>' +
                        '</div>' +

                        '<div class="heroControls heroRightArrow">' +
                            '<div class="heroControlsInner hide">' +
                                '<div class="heroPagination">' +
                                    '<button type="button" class="heroRightArrow accessibleLink">' +
                                        '<span class="icon icon-angle-right"></span>' +
                                        '<span class="accessible">' + strAccessibleNextSlide + '</span>' +
                                    '</button>' +
                                '</div>' +
                            '</div>' +
                        '</div>' +

                        '<div class="heroControls heroPaginationBar">' +
                            '<div class="heroControlsInner hide">' +
                                '<div class="heroPagination">' +
                                    '<ul class="slideSelect"></ul>' +
                                '</div>' +
                            '</div>' +
                        '</div>' +
                        '<ul class="heroConveyor" aria-live="polite" aria-relevant="additions text">' +
                        '</ul>' +
                    '</div>' +
                '</div>';

        html += '<!-- <<< ocms_mli_HeroCarouselControl.getHTML(...) -->';

        return html;
    }

}