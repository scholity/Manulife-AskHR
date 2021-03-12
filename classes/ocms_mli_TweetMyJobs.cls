global with sharing class ocms_mli_TweetMyJobs extends cms.ContentTemplateController {

    global ocms_mli_TweetMyJobs() {}

    global ocms_mli_TweetMyJobs(cms.GenerateContent gc) {
        super(gc);
    }

    global ocms_mli_TweetMyJobs(cms.CreateContentController cc) {
        super(cc);
    }

    public String strLink {
        get { return this.getProperty('strLink'); }
    }

    private cms.Link objLink {
        get { return new cms.Link(strLink); }
    }

    global override String getHTML() {

        String html = '';

        html += '<div class="genericContentContainer">' +
                    '<iframe class="tweetMyJobs" src="' + ocms_mli_Utility.getLinkHref(objLink.targetPage) + '"></iframe>' +
                '</div>';

        return html;

    }

}