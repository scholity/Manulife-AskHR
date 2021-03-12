global with sharing class ocms_mli_StockPrice extends ocms_StockFeed {

    global ocms_mli_StockPrice() {}

    global ocms_mli_StockPrice(cms.GenerateContent gc) {
        super(gc);
    }

    global ocms_mli_StockPrice(cms.CreateContentController cc) {
        super(cc);
    }

    public String strTitle {
        get { return ocms_mli_Utility.noNull(getProperty('strTitle')); }
    }

    public String strIcon {
        get { return ocms_mli_Utility.noNull(getProperty('strIcon')); }
    }

    public String strLinkText {
        get { return ocms_mli_Utility.noNull(getProperty('strLinkText')); }
    }

    public String strLink {
        get { return getProperty('strLink'); }
    }

    public String strDelayText {
        get { return ocms_mli_Utility.noNull(getProperty('strDelayText')); }
    }

    private cms.Link objLink {
        get { return new cms.Link(strLink); }
    }

    public String accStock {
        get{ return ocms_mli_Utility.noNull(getProperty('accStock')); }
    }

    public String accStockPrice {
        get{ return ocms_mli_Utility.noNull(getProperty('accStockPrice')); }
    }

    public String accIncrease {
        get{ return ocms_mli_Utility.noNull(getProperty('accIncrease')); }
    }

    public String accDecrease {
        get{ return ocms_mli_Utility.noNull(getProperty('accDecrease')); }
    }

    global override String getHTML() {

        String html = '';

        html += '<div class="landingWidget">' +
                    '<div class="widgetHeader">';

        if (strIcon != ''){

            html +=     '<h3 class="widgetHeading">' +
                            '<span class="image-icon">' +
                                '<img src="' + strIcon + '" />' +
                            '</span>' +

                            strTitle +

                        '</h3>';

        } else {

            html +=     '<h3 class="widgetHeading widgetHeading--noIcon">' +

                            strTitle +

                        '</h3>';

        }

        html +=     '</div>' +
                    '<div class="widgetContent">' +
                        '<div class="stockPriceWidget">' +

                            generateStockFeed() +

                        '</div>' +
                    '</div>';

        if (strDelayText != ''){

            html += '<div class="row delayText">' +
                        '<span>' +
                            strDelayText +
                        '</span>' +
                    '</div>';

        }

        html +=     '<div class="widgetFooter">';


                    if (strLink != null && strLinkText != ''){

                        html += '<a onclick=\'' + ocms_mli_Utility.getLinkScript(objLink.javascript) + '\'  href="' + ocms_mli_Utility.getLinkHref(objLink.targetPage) + '" target="' + ocms_mli_Utility.getLinkTarget(objLink.target) + '" class="jumper">' +
                                    '<span class="title">'+
                                        strLinkText +
                                    '</span>' +
                                '</a>';
                    }

        html +=     '</div>' +
                '</div>';

        return html;

    }

    private String generateStockFeed(){
        String html = '';
        List<StockFeed> stockFeedList = new List<StockFeed>();
        stockFeedList = getMLIStockFeed('MLI');
        if (stockFeedList.size() > 0){

            html += '<ul>';

            for (StockFeed stock : stockFeedList){
                String accDirection = '';

                if (stock.directionClass == 'up'){
                    stock.directionClass = 'increase';
                    accDirection = accIncrease;
                } else if (stock.directionClass == 'dn'){
                    stock.directionClass = 'decrease';
                    accDirection = accDecrease;
                } else if (stock.directionClass == 'ev'){
                    stock.directionClass = 'even';
                    accDirection = 'even';
                }

                html += '<li>' +
                            '<div class ="row">' +
                                '<div class="widgetColumn">' +
                                    '<span class="stock">' +
                                        '<span class="accessible">' +
                                            accStock + // accessible text needs to be in editor
                                        '</span>' +
                                        stock.exchange + ':' + stock.symbol +
                                    '</span>' +
                                    '<span class="price">' +
                                        '<span class="accessible">' +
                                            accStockPrice + // accessible text needs to be in editor
                                        '</span>' +
                                        stock.currentPrice +
                                    '</span>' +
                                '</div>' +
                                '<div class="widgetColumn">' +
                                    '<span class="status ' + stock.directionClass + '">' +
                                        '<span class="accessible">' +
                                            accDirection + // accessible text needs to be in editor, if statement to decide on increase, decrease, even.
                                        '</span>' +
                                    '</span>' +
                                    '<span class="change">' +
                                        stock.currentChange + ' (' + stock.percent + '%)' +
                                    '</span>' +
                                '</div>' +
                            '</div>' +
                        '</li>';
            }
            html += '</ul>';
        }
        return html;
    }
}