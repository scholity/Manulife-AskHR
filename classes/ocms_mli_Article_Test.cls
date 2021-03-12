@isTest
private class ocms_mli_Article_Test {
    static testMethod void createArticle() {

        ocms_mli_Article ArticleController = new ocms_mli_Article();

        ocms_TestContentHelper tch = new ocms_TestContentHelper();
        List<Map<String,String>> attr_map = new List<Map<String, String>>();

        Map<String, String> am = new Map<String, String>();
        am.put('name', 'title');
        am.put('value', 'title');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'author');
        am.put('value', 'author');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'articleDate');
        am.put('value', '07/15/2015 00:00');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'articleSummaryImage');
        am.put('value', 'articleSummaryImage');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'articleDetailImage');
        am.put('value', 'articleDetailImage');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'detailPage');
        am.put('value', 'detailPage');
        am.put('type', 'cms.Link');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'articleType');
        am.put('value', 'articleType');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'articleSummaryHeader');
        am.put('value', 'articleSummaryHeader');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'articleSummary');
        am.put('value', 'articleSummary');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'articleDetail');
        am.put('value', 'articleDetail');
        am.put('type', 'text');
        attr_map.add(am);

        tch.createContent(attr_map, 'MLIArticle');
        ArticleController = new ocms_mli_Article(tch.gc);

        String getHTML = ArticleController.getHTML();

        System.assertEquals('title', ArticleController.title, 'Expected title got: ' + ArticleController.title);
        System.assertEquals('author', ArticleController.author, 'Expected author got: ' + ArticleController.author);
        System.assertEquals('articleSummaryImage', ArticleController.articleSummaryImage, 'Expected articleSummaryImage got: ' + ArticleController.articleSummaryImage);
        System.assertEquals('articleDetailImage', ArticleController.articleDetailImage, 'Expected articleDetailImage got: ' + ArticleController.articleDetailImage);
		System.assertEquals('07/15/2015 00:00', ArticleController.articleDate, 'Expected articleDate got: ' + ArticleController.articleDate);
		System.assertEquals('articleType', ArticleController.articleType, 'Expected articleType got: ' + ArticleController.articleType);
        System.assertEquals('articleSummaryHeader', ArticleController.articleSummaryHeader, 'Expected articleSummaryHeader got: ' + ArticleController.articleSummaryHeader);
        System.assertEquals('articleSummary', ArticleController.articleSummary, 'Expected articleSummary got: ' + ArticleController.articleSummary);
        System.assertEquals('articleDetail', ArticleController.articleDetail, 'Expected articleDetail got: ' + ArticleController.articleDetail);

    }

    static testMethod void getArticleSummaryHTMLTest() {

        ocms_mli_Article ArticleController = new ocms_mli_Article();

        ocms_TestContentHelper tch = new ocms_TestContentHelper();
        List<Map<String,String>> attr_map = new List<Map<String, String>>();

        Map<String, String> am = new Map<String, String>();
        am.put('name', 'title');
        am.put('value', 'title');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'author');
        am.put('value', 'author');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'articleDate');
        am.put('value', '07/15/2015 00:00');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'articleSummaryImage');
        am.put('value', 'articleSummaryImage');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'articleDetailImage');
        am.put('value', 'articleDetailImage');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'detailPage');
        am.put('value', 'detailPage');
        am.put('type', 'cms.Link');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'articleType');
        am.put('value', 'articleType');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'articleSummaryHeader');
        am.put('value', 'articleSummaryHeader');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'articleSummary');
        am.put('value', 'articleSummary');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'articleDetail');
        am.put('value', 'articleDetail');
        am.put('type', 'text');
        attr_map.add(am);

        tch.createContent(attr_map, 'MLIArticle');
        ArticleController = new ocms_mli_Article(tch.gc);

        String summaryHTMLTest = ArticleController.getArticleSummaryHTML();

    }

    static testMethod void getArticleLatestNewsSummaryHTMLTest() {

        ocms_mli_Article ArticleController = new ocms_mli_Article();

        ocms_TestContentHelper tch = new ocms_TestContentHelper();
        List<Map<String,String>> attr_map = new List<Map<String, String>>();

        Map<String, String> am = new Map<String, String>();
        am.put('name', 'title');
        am.put('value', 'title');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'author');
        am.put('value', 'author');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'articleDate');
        am.put('value', '07/15/2015 05:34');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'articleSummaryImage');
        am.put('value', 'articleSummaryImage');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'articleDetailImage');
        am.put('value', 'articleDetailImage');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'detailPage');
        am.put('value', 'detailPage');
        am.put('type', 'cms.Link');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'articleType');
        am.put('value', 'articleType');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'articleSummary');
        am.put('value', 'articleSummary');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'articleDetail');
        am.put('value', 'articleDetail');
        am.put('type', 'text');
        attr_map.add(am);

        tch.createContent(attr_map, 'MLIArticle');
        ArticleController = new ocms_mli_Article(tch.gc);

        String sLatestNewsSummaryHTMLTest = ArticleController.getArticleLatestNewsSummaryHTML();

    }

    static testMethod void getArticleAwardDetailHTMLTest() {

        ocms_mli_Article ArticleController = new ocms_mli_Article();

        ocms_TestContentHelper tch = new ocms_TestContentHelper();
        List<Map<String,String>> attr_map = new List<Map<String, String>>();

        Map<String, String> am = new Map<String, String>();
        am.put('name', 'title');
        am.put('value', 'title');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'author');
        am.put('value', 'author');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'articleDate');
        am.put('value', '07/15/2015 05:34');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'articleSummaryImage');
        am.put('value', 'articleSummaryImage');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'articleDetailImage');
        am.put('value', 'articleDetailImage');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'detailPage');
        am.put('value', 'detailPage');
        am.put('type', 'cms.Link');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'articleType');
        am.put('value', 'articleType');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'articleSummary');
        am.put('value', 'articleSummary');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'articleDetail');
        am.put('value', 'articleDetail');
        am.put('type', 'text');
        attr_map.add(am);

        tch.createContent(attr_map, 'MLIArticle');
        ArticleController = new ocms_mli_Article(tch.gc);

        String sArticleAwardDetailHTMLTest = ArticleController.getArticleAwardDetailHTML();
    }

    static testMethod void getNewsArticleDetailHTMLTest() {

        ocms_mli_Article ArticleController = new ocms_mli_Article();

        ocms_TestContentHelper tch = new ocms_TestContentHelper();
        List<Map<String,String>> attr_map = new List<Map<String, String>>();

        Map<String, String> am = new Map<String, String>();
        am.put('name', 'title');
        am.put('value', 'title');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'author');
        am.put('value', 'author');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'articleDate');
        am.put('value', '07/15/2015 05:34');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'articleSummaryImage');
        am.put('value', 'articleSummaryImage');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'articleDetailImage');
        am.put('value', 'articleDetailImage');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'detailPage');
        am.put('value', 'detailPage');
        am.put('type', 'cms.Link');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'articleType');
        am.put('value', 'articleType');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'articleSummary');
        am.put('value', 'articleSummary');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'articleDetail');
        am.put('value', 'articleDetail');
        am.put('type', 'text');
        attr_map.add(am);

        tch.createContent(attr_map, 'MLIArticle');
        ArticleController = new ocms_mli_Article(tch.gc);

        String sNewsArticleDetailHTMLTest = ArticleController.getNewsArticleDetailHTML();
    }

    static testMethod void getBlogArticleDetailHTMLTest() {

        ocms_mli_Article ArticleController = new ocms_mli_Article();

        ocms_TestContentHelper tch = new ocms_TestContentHelper();
        List<Map<String,String>> attr_map = new List<Map<String, String>>();

        Map<String, String> am = new Map<String, String>();
        am.put('name', 'title');
        am.put('value', 'title');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'author');
        am.put('value', 'author');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'articleDate');
        am.put('value', '07/15/2015 05:34');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'articleSummaryImage');
        am.put('value', 'articleSummaryImage');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'articleDetailImage');
        am.put('value', 'articleDetailImage');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'detailPage');
        am.put('value', 'detailPage');
        am.put('type', 'cms.Link');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'articleType');
        am.put('value', 'articleType');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'articleSummary');
        am.put('value', 'articleSummary');
        am.put('type', 'text');
        attr_map.add(am);

        am = new Map<String, String>();
        am.put('name', 'articleDetail');
        am.put('value', 'articleDetail');
        am.put('type', 'text');
        attr_map.add(am);

        tch.createContent(attr_map, 'MLIArticle');
        ArticleController = new ocms_mli_Article(tch.gc);

        String sArticleDetailHTMLTest = ArticleController.getBlogArticleDetailHTML();
    }
}