global virtual with sharing class ocms_mfc_Article extends ocms_ps_Content implements cms.Serviceinterface {

    global ocms_mfc_Article() {
    }

    global ocms_mfc_Article(cms.GenerateContent gc) {
        super(gc);
    }

    global ocms_mfc_Article(cms.CreateContentController cc) {
        super(cc);
    }

    // For generated markup, we are overriding this to support multiple templates
    global override virtual String getHTML() {
        return '';
    }

    public System.Type getType() {
        return ocms_mfc_Article.class;
    }

    /**
     * Gets the article summary html
     * Please note the class ocmsCI and data-coid with version number; this is used for content liking
     * @return [description]
     */
    global String getArticleSummaryHTML() {
        validateSitePreferencesCache();

        String html = '', pUrl = '';
        String sTitle = title == null ? '' : title;
        String sSummary = summary == null ? '' : summary;

        Map<String, String> paramMap = new Map<String, String>();
        paramMap.put('content_Id', versionOriginId);
        paramMap.put('source', 'list');

        if (contentFlavor == 'webLink') {
            if (webLink.linkType == 'Internal') {
                html += '<div class="listing ocmsCI webLink" data-pid="' + pageId + '">';
            } else {
                html += '<div class="listing ocmsCI webLink">';
            }
        } else {
            html += '<div class="listing categorize ocmsCI" data-coid="' + versionOriginId + '" data-cid="' + content.Id + '">';
        }

        html += '<div class="list-wrapper">';
        html += '<div class="inner">';
        html += '<div class="img-wrapper">';

        if (contentFlavor == 'ceoArticle') {
            if (ceoCategory != null) {
                if (sitePreferences.get('ceoCategory' + ceoCategory) != null && sitePreferences.get('ceoCategory' + ceoCategory + 'Image') != null) {
                    html += '<img src="' + sitePreferences.get('ceoCategory' + ceoCategory + 'Image') + '" alt="' + sTitle.escapeHtml4() + '">';
                    html += '<div class = "category-overlay">' + sitePreferences.get('ceoCategory' + ceoCategory) + '</div>';
                }
            }
        } else {
            if (imageIcon != null) {
                html += '<img class="imageIcon" src="' + getSiteURLForMedia(imageIcon) + '" alt="' + sTitle.escapeHtml4() + '">';
            } else if (thumbnailImage != null) {
                // Added imageIcon to the class so we can reaplce it where needed the rotate images in ocms_mfc_NewsStream.cls
                html += '<img class="thumbnail" src="' + getSiteURLForMedia(thumbnailImage) + '" alt="' + sTitle.escapeHtml4() + '">';
            }
        }

        html += '</div>';
        html += '<div class="gradient-overlay"></div>';
        html += '<div class="info-wrapper">';
        html += '<div class="info-header">';
        html += '<h3 class="ellipsis-2">' + sTitle.escapeHtml4() + '</h3>';

        if (migratedDate != null) {
            html += '<time datetime="' + migratedDate.format('yyyy-MM-dd') + '" class="mfc-date">' + ManulifeHelper.formatTheDate(migratedDate, sAPI.getRenderLanguage()) + '</time>';
        } else {
            if (originalPublishedStartDate != null) {
                html += '<time datetime="' + originalPublishedStartDate.format('yyyy-MM-dd') + '" class="mfc-date">' + originalPublishedStartDate.format('MMM. d,  yyyy') + '</time>';
            }
        }

        html += '</div>';
        html += '<div class="desc">';
        html += '<div>';
        html += '<p class="ellipsis-4">' + sSummary.escapeHtml4() + '</p>';
        html += '</div>';
        html += '</div>';
        html += '</div>';

        sTitle = sTitle.escapeHtml4().replace('%26', '&amp;');
        sTitle = sTitle.escapeHtml4().replace('%', '%25').replace('&quot;', '%22').replace(',', '%2C').replace('&#94;', '%5E').replace('&amp;#39;', '%27').replace('&amp;', '%26').replace('%26amp;', '%26');
        sTitle = sTitle.escapeHtml4().replace('&#33;', '%21').replace('&#36;', '%24').replace('&#37;', '%25').replace('&middot;', '%B7').replace('(', '%28').replace('`', '%60').replace('%26rsquo;', '’').replace('%26lsquo;', '‘').replace('%26acute;', '´').replace('middot;', '·').replace('%26ldquo;', '“');
        sTitle = sTitle.escapeHtml4().replace(')', '%29').replace('*', '%2A').replace('+', '%2B').replace('-', '%2D').replace('.', '%2E').replace('@', '%40').replace('#', '%23').replace('^', '%5E').replace('%26lt;', '%3C').replace('%26gt;', '%3E');

        if (contentFlavor == 'webLink') {
            html += '<a class="link-overlay has-hover ocms-title-taxonomy-detail-link" href="' + webLink.targetPage + '"';
            if (webLink.target == '_blank') {
                html += ' target="_blank"';
            } else if (String.isNotEmpty(webLink.javascript)) {
                html += ' onclick="' + webLink.javascript.escapeHtml4() + '"';
            }
            html += '></a>';
            html += '<div class="share-wrapper">';
            html += '<a class="like" data-article-title="' + sTitle.escapeHtml4() + '" href="#"></a><a class="share" href="mailto:?subject=' + sitePreferences.get('shareEmailSubject') + '&body=' + sTitle + ' ' + EncodingUtil.urlEncode(webLink.targetPage, 'UTF-8') + '" title="Share by Email"></a>';
            html += '</div>';
        } else if (contentFlavor == 'ceoArticle') {
            html += '<a class="link-overlay has-hover ocms-title-taxonomy-detail-link" href="' + appendQueryStringsToSitePreferences('ceoArticlePage', paramMap) + '"></a>';
            html += '<div class="share-wrapper">';
            html += '<a class="share" data-article-title="' + sTitle.escapeHtml4() + '" href="mailto:?subject=' + sitePreferences.get('shareEmailSubject') + '&body=' + sTitle + ' ' + '{urlPlaceholder}' + '" title="Share by Email"></a>';
            html += '</div>';
        } else {
            html += '<a class="link-overlay has-hover ocms-title-taxonomy-detail-link" href="' + appendQueryStringsToSitePreferences('articlePage', paramMap) + '"></a>';
            html += '<div class="share-wrapper">';
            html += '<a class="like" data-article-title="' + sTitle.escapeHtml4() + '" href="#"></a><a class="share" href="mailto:?subject=' + sitePreferences.get('shareEmailSubject') + '&body=' + sTitle + ' ' + '{urlPlaceholder}' + '" title="Share by Email"></a>';
            html += '</div>';
        }

        html += '</div>';
        html += '</div>';
        html += '</div>';

        return html;
    }

    /**
     * This method renders the tile on MFCentral news feed
     *
     * @return HTML for a tile
     */
    global String getNewsTileHTML() {
        validateSitePreferencesCache();

        String sTitle = title == null ? '' : title;
        String sSummary = summary == null ? '' : summary;
        String html = '';

        if ('article' == contentFlavor || 'ceoArticle' == contentFlavor || 'obituary' == contentFlavor || 'webLink' == contentFlavor) {
            Map<String, String> paramMap = new Map<String, String>();
            paramMap.put('content_Id', versionOriginId);
            String tagName = getTaxPathsForContentIds(content.Id);
            String ceoClass = '';

            if ('ceoArticle' == contentFlavor) {
                ceoClass = 'executive-message';
            }
            html += '<div class="tile type-news ocmsCI ' + ceoClass + '" data-coid="' + versionOriginId + '">';
            html += '<div class="inner">';
            html += '<div class="content">';
            if ('ceoArticle' == contentFlavor) {
                html += '<a class="no-style-url-link" style="text-decoration:none" href="' + appendQueryStringsToSitePreferences('ceoArticlePage', paramMap) + '">';
            } else if ('webLink' == contentFlavor) {
                String urlForWeblink = webLink.targetPage;
                if (urlForWeblink.indexOf('&lpos') > -1) {
                    urlForWeblink = urlForWeblink.substring(0, urlForWeblink.indexOf('&lpos'));
                }
                if (webLink.target == '_blank') {
                    html += '<a class="no-style-url-link" style="text-decoration:none" href="' + urlForWeblink + '" target="_blank">';
                }
                else {
                    html += '<a class="no-style-url-link" style="text-decoration:none" href="' + urlForWeblink + '">';
                }
            } else {
                html += '<a class="no-style-url-link" style="text-decoration:none" href="' + appendQueryStringsToSitePreferences('articlePage', paramMap) + '">';
            }
            html += '<div class="v-align">';
            html += '<div class="inner">';
            html += '<h3 class="title">' + sTitle.escapeHtml4() + '</h3>';
            html += '<p class="description">' + sSummary.escapeHtml4() + '</p>';
            html += '</div>';//inner
            html += '</div>';//v-align
            html += '</a>';
            html += '</div>';//content
            html += '<div class="bg">';
            html += '<img class="imageIcon" src="' +
                    getSiteURLForMedia(imageIcon) +
                    '" alt="' + sTitle.escapeHtml4() + '" />';
            html += '<div class="shadow"></div>';
            html += '</div>';
            html += '<div class="news-category">' + tagName + '</div>';
            html += '<div class="news-share">';
            html += '<div class="inner">';
            if (contentFlavor != 'obituary') {
                html += '<div class="likes"><span class="likeCount">0</span> ' + sitePreferences.get('uiLabelLike') + '</div>';
                html += '<span class="s-like" data-article-title="' + sTitle.escapeHtml4() + '">' + sitePreferences.get('uiLabelLike') + '</span>';
            }
            sTitle = sTitle.escapeHtml4().replace('%26', '&amp;');
            sTitle = sTitle.escapeHtml4().replace('%', '%25').replace('&quot;', '%22').replace(',', '%2C').replace('&#94;', '%5E').replace('&amp;#39;', '%27').replace('&amp;', '%26').replace('%26amp;', '%26');
            sTitle = sTitle.escapeHtml4().replace('&#33;', '%21').replace('&#36;', '%24').replace('&#37;', '%25').replace('&middot;', '%B7').replace('(', '%28').replace('`', '%60').replace('%26rsquo;', '’').replace('%26lsquo;', '‘').replace('%26acute;', '´').replace('middot;', '·').replace('%26ldquo;', '“');
            sTitle = sTitle.escapeHtml4().replace(')', '%29').replace('*', '%2A').replace('+', '%2B').replace('-', '%2D').replace('.', '%2E').replace('@', '%40').replace('#', '%23').replace('^', '%5E').replace('%26lt;', '%3C').replace('%26gt;', '%3E');

            html += '<a href="mailto:?subject=' + sitePreferences.get('shareEmailSubject') + '&body=' + sTitle + ' ' + '{urlPlaceholder}' + '" title="Share by Email" ><span class="s-share">' + sitePreferences.get('uiLabelShare') + '</span></a>';

            html += '</div>';
            html += '</div>';
            if (contentFlavor == 'ceoArticle') {
                html += '<div class="link-footer"><a href="' + appendQueryStringsToSitePreferences('ceoArticlePage', paramMap) + '"> <i class="icon icon-external">External Link</i></a></div>';
            } else {
                html += '<div class="link-footer"><a href="' + appendQueryStringsToSitePreferences('articlePage', paramMap) + '"> <i class="icon icon-external">External Link</i></a></div>';
            }
            html += '<div class="social-icon icon-"></div>';
            html += '<div class="custom-html">';
            html += '</div>';
            html += '</div>';
            html += '</div>';
        } else if (contentFlavor == 'socialPost') {
            String socialHTML = '';

            if (socialType == 'facebook') {
                socialHTML = '<div class="social-icon icon-fb">fb</div>';
            } else if (socialType == 'twitter') {
                socialHTML = '<div class="social-icon icon-tw">tw</div>';
            }

            html += '<div class="tile type-social ocmsCI" data-coid="' + versionOriginId + '"">';
            html += '<div class="inner">';
            html += '<div class="content">';
            html += '<div class="v-align">';
            html += '<div class="inner">';
            html += '<h3 class="title"><a href="' + socialLink.targetPage + '"></a></h3>';
            html += '<p class="description">' + sSummary.escapeHtml4() + '</p>';
            html += '</div>';
            html += '</div>';
            html += '</div>';
            html += '<div class="bg">';
            html += '<img src="" alt="">';
            html += '<div class="shadow"></div>';
            html += '</div>';

            if (socialLink.targetPage != null) {
                html += '<div class="link-footer">';
                html += socialLink.render(sitePreferences.get('uiSocialPostLinkText') + ' <i class="icon icon-external">External Link</i>');
                html += '</div>';
            }

            html += socialHTML;
            html += '<div class="custom-html">';
            html += '</div>';
            html += '</div>';
            html += '</div>';
        } else if (contentFlavor == 'newsItem') {
            html += '<div class="tile type-external ocmsCI" data-coid="' + versionOriginId + '">';
            html += '<div class="inner">		';
            html += '<div class="content">';
            html += '<div class="v-align">';
            html += '<div class="inner">';
            html += '<h3 class="titleDC">';
            html += '<a href="' + clipping1Link + '" target="_blank">';
            html += clipping1 == null ? clipping1 : clipping1.escapeHtml4();
            html += '</a>';
            html += '</h3>';
            html += '<p class="descriptionDC">' + clipping1Summary + '</p>';

            html += '<h3 class="titleDC">';
            html += '<a href="' + clipping2Link + '" target="_blank">';
            html += clipping2 == null ? clipping2 : clipping2.escapeHtml4();
            html += '</a>';
            html += '</h3>';
            html += '<p class="descriptionDC">' + clipping2Summary + '</p>';
            html += '<p class="description" css="display:none;">' + sSummary + '</p>';
            html += '</div>';
            html += '</div>';
            html += '</div>';
            html += '<div class="bg">';
            html += '<img src="" alt="">';
            html += '<div class="shadow"></div>';
            html += '</div>';
            html += '<div class="news-category">' + getTaxPathsForContentIds(content.Id) + '</div>';

            if (newsLink.targetPage != null) {
                html += '<div class="link-footer">';
                html += newsLink.render(sitePreferences.get('uiNewsItemLinkText'));
                html += '</div>';
            }

            html += '<div class="social-icon icon-"></div>';
            html += '<div class="custom-html">';
            html += '</div>';
            html += '</div>';
            html += '</div>';
        } else if (contentFlavor == 'MCTrend') {
            html += '<div class="tile type-external ocmsCI" data-coid="' + versionOriginId + '">';
            html += '<div class="inner MCTrend">';
            html += '<div class="content" style="padding: 1px 0 5px 0">';
            html += '<div class="v-align">';
            html += '<div class="inner">';

            if (null == trending2) {
                html += '<h3 class="titleDC">';
            } else {
                html += '<h3 class="titleDC" style="border-bottom: 1px solid #e1e1e1">';
            }

            html += '<a href="' + trending1Link + '" target="_blank">';
            html += trending1 == null ? trending1 : trending1.escapeHtml4();
            html += '</a>';
            html += '</h3>';

            if (null != trending2) {
                if (null == trending3) {
                    html += '<h3 class="titleDC">';
                } else {
                    html += '<h3 class="titleDC" style="border-bottom: 1px solid #e1e1e1">';
                }
                html += '<a href="' + trending2Link + '" target="_blank">';
                html += trending2 == null ? '' : trending2.escapeHtml4();
                html += '</a>';
                html += '</h3>';
            }

            if (null != trending3) {
                if (null == trending4) {
                    html += '<h3 class="titleDC">';
                } else {
                    html += '<h3 class="titleDC" style="border-bottom: 1px solid #e1e1e1">';
                }

                html += '<a href="' + trending3Link + '" target="_blank">';
                html += trending3 == null ? '' : trending3.escapeHtml4();
                html += '</a>';
                html += '</h3>';
            }

            if (null != trending4) {
                html += '<h3 class="titleDC">';
                html += '<a href="' + trending4Link + '" target="_blank">';
                html += trending4 == null ? '' : trending4.escapeHtml4();
                html += '</a>';
                html += '</h3>';
            }

            html += '<p class="description" css="display:none;">' + sSummary + '</p>';
            html += '</div>';
            html += '</div>';
            html += '</div>';
            html += '<div class="bg">';
            html += '<img src="" alt="">';
            html += '<div class="shadow"></div>';
            html += '</div>';
            html += '<div class="news-category">' + getTaxPathsForContentIds(content.Id) + '</div>';

            if (newsLink.targetPage != null) {
                html += '<div class="link-footer">';
                html += newsLink.render(sitePreferences.get('uiNewsItemLinkText'));
                html += '</div>';
            }

            html += '<div class="social-icon icon-"></div>';
            html += '<div class="custom-html">';
            html += '</div>';
            html += '</div>';
            html += '</div>';
        }
        return html;
    }

    global String getArticleDetailHTML() {
        validateSitePreferencesCache();
        String html = '', pUrl = '';

        String sTitle = title == null ? '' : title;
        String sBody = body == null ? '' : body;
        String adminEmail = sitePreferences.get('reportButtonEmail') == null ? '' : sitePreferences.get('reportButtonEmail');

        String reportAuthorEmail = '';

        if (authorEmail != null) {
            reportAuthorEmail = authorEmail;
        }

        if (reportAuthorEmail != '') {
            reportAuthorEmail = ',' + reportAuthorEmail;
        }

        //Build the author html
        String authorHTML = '';

        Map<String, String> paramMap = new Map<String, String>();
        paramMap.put('content_Id', content.Id);

        //if we dont have an author name then don't do anything
        if (author != null) {
            //Image code will go here once we know where its coming from
            authorHTML += '<div id="article-author">';
            //We need to place some image checking code here.
            if (authorImage != null) {
                authorHTML += '<div class="author-thumb">';
                authorHTML += '<img src="' + authorImage + '" alt="' + author + '">';
                authorHTML += '</div>';
            }

            authorHTML += '<div class="author-info">';
            //We will allways have a name
            if (authorEmail != null) {
                authorHTML += '<a class="author-name" href="mailto:' + authorEmail + '">' + author + '</a>';
            } else {
                authorHTML += '<span class="author-name">' + author + '</span>';
            }

            //Check for author title.
            if (authorTitle != null) {
                authorHTML += '<p class="author-title">' + authorTitle + '</p>';
            }

            authorHTML += '</div>';
            authorHTML += '</div>';
        }

        String locationTax = sitePreferences.get('locationTaxonomy');
        String divisionTax = sitePreferences.get('divisionTaxonomy');

        List<String> sitePrefTaxTags = new List<String>{
                locationTax, divisionTax
        };
        Map<String, String> taxPaths = getTagPaths(sitePrefTaxTags);
        //the below line is commented as a fix for PT-148604609
        //Boolean hasSideBar = (detailSidebar == 'false') ? false : true;
        //the below line is added as a fix for PT-148604609
        Boolean hasSideBar = (detailSidebar == 'checked') ? true : false;

        html += '<div class="article-content '
                + (hasSideBar ? 'layout-sidebar' : '')
                + ' ocmsCI" data-coid="' + versionOriginId + '" data-cid="' + content.Id + '" data-lTags="' + taxPaths.get(locationTax) + '" data-dTags="' + taxPaths.get(divisionTax) + '" >';
        html += '<div class="inner">';

        if (String.isNotBlank(ceoBannerImage)) {
            // an empty alt attribute at least makes this markup valid, and may not be too improper accessibility-wise, since
            // banner images may often be simply decorative (or not)
            html += '<div class="ceoBanner_c"><img src="' + getSiteURLForMedia(ceoBannerImage) + '" alt=""></div>';
        }

        html += '<div id="article-header">';
        html += '<h1>' + sTitle + '</h1>';

        if (migratedDate != null) {
            html += '<time datetime="' + migratedDate.format('yyyy-MM-dd') + '">' + ManulifeHelper.formatTheDate(migratedDate, sAPI.getRenderLanguage()) + '</time>';
        } else {
            if (originalPublishedStartDate != null) {
                html += '<time datetime="' + originalPublishedStartDate.format('yyyy-MM-dd') + '">' + originalPublishedStartDate.format('MMMM d,  yyyy') + '</time>';
            }
        }

        html += authorHTML;
        html += '<div class="global-flag">';
        html += '<a href="mailto:' + adminEmail + reportAuthorEmail + '?subject=PAGETITLE"></a>';
        html += '</div>';
        html += '</div>';

        if (hasSideBar) {
            html += '<div class="article-sidebar">';
            html += '<div class="article-widget article-image">';
            html += '<div class="img-wrapper">';
            // this is an improper use of alt - it should be specifically descriptive of the image
            html += '<img src="' + getSiteURLForMedia(imageHero) + '" alt="' + sTitle.escapeHtml4() + '">';
            html += '</div>';
            html += '</div>	';
            html += '</div>';
        }

        html += '<div class="article-body">';
        html += sBody;
        html += '</div>';

        if (hasSideBar) {
            html += '<div class="article-sidebar">';
            html += '<div class="article-widget article-contact">';
            html += '<p class="title">' + sitePreferences.get('uiLabelArtContactInformation') + '</p>';

            if (authorPhone != null) {
                html += '<div class="contact-phone">ext. ' + authorPhone + '</div>';
            }

            if (authorEmail != null) {
                html += '<div class="contact-email"><a href="mailto:' + authorEmail + '">' + authorEmail + '</a></div>';
            }

            html += '</div>';
            html += '<div class="clear"></div>';
            html += '</div>';
        }

        html += '<div class="clear"></div>';

        String relatedArticlesHTML = getRelatedArticleMarkup();

        if (String.isNotEmpty(relatedArticlesHTML)) {
            html += '<div class="listing-container">';
            html += '<div class="arrow arrow-r hideSelector"></div>';
            html += '<div class="arrow arrow-l hideSelector"></div>';
            html += '<div class="carousel inner">';
            html += '<div class="listing-wrapper">';
            html += relatedArticlesHTML;
            html += '</div>';
            html += '<div class="clear"></div>	';
            html += '</div>';
            html += '</div>';
        }
        sTitle = sTitle.escapeHtml4().replace('%26', '&amp;');
        sTitle = sTitle.escapeHtml4().replace('%', '%25').replace('&quot;', '%22').replace(',', '%2C').replace('&#94;', '%5E').replace('&amp;#39;', '%27').replace('&amp;', '%26').replace('%26amp;', '%26');
        sTitle = sTitle.escapeHtml4().replace('&#33;', '%21').replace('&#36;', '%24').replace('&#37;', '%25').replace('&middot;', '%B7').replace('(', '%28').replace('`', '%60').replace('%26rsquo;', '’').replace('%26lsquo;', '‘').replace('%26acute;', '´').replace('middot;', '·').replace('%26ldquo;', '“');
        sTitle = sTitle.escapeHtml4().replace(')', '%29').replace('*', '%2A').replace('+', '%2B').replace('-', '%2D').replace('.', '%2E').replace('@', '%40').replace('#', '%23').replace('^', '%5E').replace('%26lt;', '%3C').replace('%26gt;', '%3E');

        html += '<div id="bookmark-bar-article">';
        html += '<div class="align-left">';
        /**
         * Display Tags: label only when there any tags
         */
        List<String> allTags = getAllTaxPathsForContentIds(content.Id);
        if(allTags != null && allTags.size() > 0) {
            html += '<p class="tag-master">Tags:</p>';
            for (String eachTag : allTags) {
                html += '<button class="tag-each">' + eachTag + '</button>';
            }
        }
        html += '</div>';

        html += '<div class="align-right">';

        if (contentFlavor != 'obituary') {
            html += '<a class="like" data-article-title="' + sTitle.escapeHtml4() + '" href="#"><span class="likeCount">0</span></a>';
        }
        html += '<a class="share" href="mailto:?subject=' + sitePreferences.get('shareEmailSubject') + '&body=' + sTitle + ' ' + '{urlPlaceholder}' + '" title="Share by Email">' + sitePreferences.get('uiLabelShare') + '</a>';
        html += '</div>';
        html += '<div class="clear"></div>';
        html += '</div>';

        /**
         * Hide the RelatedTags on CEOMessage and LeadershipMessage Article
         */
        String contentId = content.Id;
        cms__Content__c cObj = Database.query('SELECT cms__Content_Type__r.cms__Name__c FROM cms__Content__c WHERE Id = :contentId LIMIT 1');
        String contentType = cObj.cms__Content_Type__r.cms__Name__c;
        if(contentFlavor != 'ceoArticle' && contentType != 'MFC Article' && contentFlavor == 'article'){
            html += '<div id="article-navbar-label">' + sitePreferences.get('uiLabelArtRelated') + '</div>';
        }
        if(contentFlavor == 'obituary'){
            html += '<div id="article-navbar-label">' + sitePreferences.get('uiLabelArtRelated') + '</div>';
        }

        html += '<div id="article-navbar">';
        html += '<div class="clear"></div>';
        html += '</div>';
        html += '</div>';
        html += '</div>';

        html += '<script id="mfcArticleScript">\n';
        html += '$(document).ocmsDynamicLoadFinished(function _mfcArticleScriptPostLoad() {\n';
        html += 'document.title = $("#article-header h1").text();\n';
        html += 'var cid = $(".ocmsCI").data("cid");\n';
        html += 'var url = window.location.href;\n';
        html += 'var q = window.location.search.slice(1),\n';
        html += 'nIt, keyVal, aQueryVars = {}; \n';

        html += 'if (q.length) {\n';
        html +=     'q = q.split("&");\n';
        html += '}\n';

        html += 'for (nIt = 0; nIt < q.length; nIt++) {\n';
        html +=     'keyVal = q[nIt].split("=");\n';
        html +=     'aQueryVars[unescape(keyVal[0])] = unescape(keyVal[1] || "");\n';
        html += '}\n';

        html += '// hide share/like based on passed GET params from loader\n';
        html += 'if (Number(aQueryVars["htsa"]) === 1) {$(".article-content[data-cid=" + cid + "] #bookmark-bar .share").hide()};\n';
        html += 'if (Number(aQueryVars["htla"]) === 1) {$(".article-content[data-cid=" + cid + "] #bookmark-bar .like").hide()};\n';
        html += 'var requestParams = {\n';
        html += 'action: "getPrevNext",\n';

        if (contentFlavor == 'ceoArticle') {
            html += 'type: "ceoArticle",\n';
        } else {
            html += 'type: "article",\n';
        }
        html += 'tag: "' + getTaxPathsForContentIds(content.Id) + '",\n';
        html += 'source: aQueryVars["source"],\n';
        html += 'contentId: cid\n';
        html += '};\n';

        html += '$.orchestracmsRestProxy.doAjaxServiceRequest("ocms_mfc_Article", requestParams, function (textStatus, json, xhr) {\n';
        html += 'if (json.success) {\n';
        html += '$("#article-navbar").append(json.pnhtml);\n';

        html += 'if (aQueryVars["source"] == "list") {\n';
        html += '$.each($("#article-navbar a"), function(i,v){\n';
        html += 'var url = $(v).attr("href").appendQueryString({"source":"list"});\n';
        html += '$(v).attr("href", url);\n';
        html += '});\n';
        html += '}\n';
        html += '}\n';
        html += '});\n';

        // Load Adobe analytics object
        html += 'MFC.analytics.page = MFC.analytics.page || {};\n';
        html += 'MFC.analytics.page.pageInfo = MFC.analytics.page.pageInfo || {};\n';
        html += 'MFC.analytics.page.pageName = "' + versionOriginId + '";\n';
        html += 'MFC.analytics.page.pageInfo.articleLocation = $(".ocmsCI").data("lTags");\n';
        html += 'MFC.analytics.page.pageInfo.articleDate = $(".ocmsCI time").attr("datetime");\n';
        html += 'MFC.analytics.page.pageInfo.articleId = $(".ocmsCI").data("coid");\n';
        html += 'MFC.analytics.page.pageInfo.articleAuthor = $(".author-name").text();\n';
        html += 'MFC.analytics.page.pageInfo.articleDivision = $(".ocmsCI").data("dTags");\n';
        html += 'MFC.analytics.page.pageInfo.articleTitle = $("#article-header h1").text();\n';
        html += 'MFC.analytics.bookmark = MFC.analytics.bookmark || {};\n';
        html += 'MFC.analytics.bookmark.bookmarkName = $("#article-header h1").text();\n';
        html += '$("body").trigger("mfc-adobeAnalyticsSend", {call : "articleLoaded"});\n';

        html += 'var $tiles = $(".listing");\n';
        html += '$.each($tiles, function(i,v){\n';
        html += 'var $tileLink = $("a.link-overlay", v);\n';
        html += 'if ($tileLink != undefined ) {\n';
        html += 'var $tileHref = $tileLink.attr("href");\n';
        html += '$tileLink.attr("href", $tileHref.appendQueryString({"lpos":i + 1, "lsec":"List"}));\n';
        html += '}\n';
        html += '});\n';

        html += 'var title = document.getElementsByTagName("title")[0].innerHTML;\n';
        html += 'var reportMailto = $(".global-flag a").attr("href");\n';
        html += 'var mailtoWithTitle = reportMailto.replace("PAGETITLE", title);\n';
        html += '$(".global-flag a").attr("href", mailtoWithTitle);\n';

        html += '$(".article-content .article-body a").each(function(){$(this).click(function(){clickTracking("inArticleLink", $(this).html(), $(this).attr("href"))});});\n';
        html += '$(".article-content .article-body a").each(function(){$(this).contextmenu(function(){clickTracking("inArticleLink", $(this).html(), $(this).attr("href"))});});\n';

        // hide likes in the related list as per client feedback jul 13, see DBE - MFCentral - Q3 Sprint - Issues and Resolution Review - B9 (2016-Jul-13).wmv
        // we also need to prevent likes from the detail pages, but also we dno't want to pass the hide share action
        // that the OrchestraCMS re-writer adds for us if it was passed through the loader.
        html += '$(".article-content[data-cid=' + content.Id + '] .listing-container .like").hide();\n';
        html += 'var oLinkElements = $(".article-content[data-cid=' + content.Id + '] .listing-container .link-overlay");\n';
        html += '       for (var i = 0; i < oLinkElements.length; i++) {\n';
        html += '           var sHref = $(oLinkElements[i]).attr("href");\n';
        html += '           sHref = sHref.replace(/[&??]htsa=[^&]*/,"");\n';
        html += '           sHref = sHref.appendQueryString({"htla": 1});\n';
        html += '           $(oLinkElements[i]).attr("href", sHref);\n';
        html += '       }';
        // attach the ISO slider to the related list
        html += '$$(".article-content[data-cid=' + content.Id + '] .listing-container .carousel.inner").iosSlider({\n';
        html += 'snapToChildren: true,\n';
        html += 'navPrevSelector: $$(".article-content[data-cid=' + content.Id + '] .listing-container .arrow-l"),\n';
        html += 'navNextSelector: $$(".article-content[data-cid=' + content.Id + '] .listing-container .arrow-r"),\n';
        html += 'onSlideChange: MFC.fSlideChange,\n';
        html += 'onSliderLoaded: MFC.fSlideChange,\n';
        html += 'onSliderResize: MFC.fSlideChange,\n';
        html += '}).iosSlider("update");\n';

        html += '});\n';
        html += '//# sourceURL=ocms_mfc_Article.cls#inlinedScript1\n';
        html += '</script>\n\n';

        return html;
    }

    //The main execute request function
    global String executeRequest(Map<String, String> params) {
        String response = '';
        String action = params.get('action');

        if (action == 'authorAutoComplete') {
            String authorName = params.get('name');
            List<User> userList = getUsersByName(authorName);
            if (userList.size() > 0) {
                response = '{"success": true, "users": ' + JSON.serialize(userList) + '}';
            } else {
                response = '{"success": false, "exception": "No matching users"}';
            }

        } else if (action == 'getAuthor') {
            String authorName = params.get('name');
            String authorEmail = params.get('email');
            List<User> userList = getUserByNameAndEmail(authorName, authorEmail);
            if (userList.size() > 0) {
                response = '{"success": true, "users": ' + JSON.serialize(userList) + '}';
            } else {
                response = '{"success": false, "exception": "No matching users"}';
            }
        } else if (action == 'getPrevNext') {
            String contentId = params.get('contentId');
            String type = params.get('type');

            cms__Content__c cObj = Database.query('SELECT cms__Content_Type__r.cms__Name__c FROM cms__Content__c WHERE Id = :contentId LIMIT 1');
            String contentTypeName = cObj.cms__Content_Type__r.cms__Name__c;
            String relatedHTML = getRelatedArticles(contentId, cObj.cms__Content_Type__r.cms__Name__c, type, params.get('source'), params.get('tag'));
            String temp = '"' + contentId + ';' + cObj.cms__Content_Type__r.cms__Name__c + ';' + type + ';' + params.get('source') + '"';
            if (relatedHTML != '') {
                response = '{"success": true, "inputs": '+ temp + ', "pnhtml": ' + JSON.serialize(relatedHTML) + '}';
            } else {
                response = '{"success": false}';
            }
        } else if (action == 'getPOID') {
            String pageId = params.get('pageId');
            cms__Page__c pObj = Database.query('SELECT Id, cms__Version_Origin__c FROM cms__Page__c WHERE Id = :pageId LIMIT 1');
            if (pObj.cms__Version_Origin__c != null) {
                response = '{"success": true, "pageId": "' + pObj.cms__Version_Origin__c + '"}';
            } else {
                response = '{"success": true, "pageId": "' + pageId + '"}';
            }
        } else if (action == 'getArticleTilesByName') {
            String term = params.get('term');
            String cid = params.get('contentId');
            cms__Content__c cObj = Database.query('SELECT cms__Content_Type__r.cms__Name__c, cms__Version_Origin__c FROM cms__Content__c WHERE Id = :cid LIMIT 1');
            String contentTypeName = cObj.cms__Content_Type__r.cms__Name__c;
            List<cms__Content__c> contentList = new List<cms__Content__c>();
            if (cObj.cms__Version_Origin__c != null) {
                contentList = getContentByNameAndType(term, contentTypeName, cObj.cms__Version_Origin__c);
            } else {
                contentList = getContentByNameAndType(term, contentTypeName, cid);
            }
            if (contentList.size() > 0) {
                response = '{"success": true, "contentList": ' + JSON.serialize(contentList) + '}';
            } else {
                response = '{"success": false}';
            }

        } else if (action == 'getCEOCategories') {
            String language = params.get('ocmsLang');
            Map<String, String> sitePref = ocms_mfc_SitePreferences.getSitePreferences();
            Map<String, String> ceoCategories = new Map<String, String>();
            for (Integer i = 1; i < 7; i++) {
                if (sitePref.get('ceoCategory' + i) != null && sitePref.get('ceoCategory' + i + 'Image') != null) {
                    ceoCategories.put(String.valueOf(i), sitePref.get('ceoCategory' + i));
                }
            }
            if (ceoCategories.size() > 0) {
                response = '{"success": true, "ceoCategories": ' + JSON.serialize(ceoCategories) + '}';
            } else {
                response = '{"success": false, "message": "Need to setup CEO categories in site preferences"}';
            }
        } else if (action == 'updateLastPublishedDate') {
            try {
                Cache.OrgPartition ocmsOrgPartition = Cache.Org.getPartition('ocms');
                ocmsOrgPartition.put('latestPublished', System.now());
                response = '{"success": true}';
            } catch (Exception e) {
                response = '{"success": false, "message" : ' + JSON.serialize(e) + '}';
            }
        } else if (action == 'updateOriginPublishStartDate') {
            String contentId = params.get('contentId');
            Datetime startDate = (Datetime) JSON.deserialize(params.get('startDate'), Datetime.class);

            response = updateOriginPublishStartDate(contentId, startDate);
        }
        return response;
    }

    //A list of all the ad hoc tags associated with the article and in the current language
    public List<Ad_Hoc_Tag__c> articleTagsList {
        get {
            String languageCode = sAPI.getRenderLanguage();
            List<Ad_Hoc_Tag__c> tagList = new List<Ad_Hoc_Tag__c>();
            tagList = Database.query('SELECT Name FROM Ad_Hoc_Tag__c WHERE Content__c = :versionOriginId AND Language__r.cms__Language_Code__c = :languageCode LIMIT 1000');
            return tagList;
        }
        set;
    }

    //Get a list of user who has a name like the name being passed into it.
    private List<User> getUsersByName(String name) {
        String term = '%' + String.escapeSingleQuotes(name) + '%';
        List<User> userList = new List<User>();
        userList = Database.query('SELECT Name, Title, Email, Phone, Extension FROM User WHERE Name LIKE :term AND IsActive = true LIMIT 10');
        return userList;
    }

    //Return one user based by exact name and email
    private List<User> getUserByNameAndEmail(String name, String email) {
        List<User> userList = new List<User>();
        userList = Database.query('SELECT Name, Title, Email, Phone, Extension FROM User WHERE Name = :name AND Email = :email AND IsActive = true LIMIT 1');
        return userList;
    }

    //This will return the top 3 related articles in a map
    public String getRelatedArticles(String contentId, String contentTypeName, String type, String source, String tag) {
        String relatedHTML = '';
        cms.ServiceAPI serviceAPI = getServiceAPI();
        ocms_mfc_Taxonomy taxo = new ocms_mfc_Taxonomy(serviceAPI);
        ocms_TaxonomyAPI taxApi = new ocms_TaxonomyAPI (serviceAPI);

        List<List<String>> pathLists = new List<List<String>>();
        List<String> contentIdList = new List<String>();

        Set<String> contentIdSet = new Set<String>();
        contentIdSet.add(contentId);

        if (source == 'list') {
            pathLists.add(taxo.getLocationPathList());
            pathLists.add(taxo.getEmployeeTypePathListForUser());
            pathLists.add(taxo.getDivisionPathListForUser());

            Map<String, List<String>> taxonomiesFromId = taxApi.getPathsForContentIds(contentIdSet);
            // We are looking for paths that are special about the content, example if it was tagged at /Master/Policies,forms,processes/forms
            // We want to and off these paths.
            List<String> extraPaths = new List<String>();
            for (String taxPath : taxonomiesFromId.get(contentId)) {
                if (!taxPath.contains(sitePreferences.get('locationTaxonomy')) && !taxPath.contains(sitePreferences.get('divisionTaxonomy')) &&
                        !taxPath.contains(mfcTaxonomy.getEmployeeTypeAllPath()) && !taxPath.contains(sitePreferences.get('newsCategoryTaxonomy')) &&
                        !taxPath.contains(sitePreferences.get('featuredItemTagPath')) && !taxPath.contains(sitePreferences.get('articleCategoriesTaxonomy'))) {
                    extraPaths.add(taxPath);
                }
            }

            pathLists.add(extraPaths);
        } else {
            // List page or anything else
            pathLists.add(taxo.getLocationPathList());
            pathLists.add(taxo.getEmployeeTypePathListForUser());
            pathLists.add(taxo.getDivisionPathListForUser());

            List<String> tagList = new List<String>();
            tagList.add('/Master Taxonomy/News Categories/' + tag);
            pathLists.add(tagList);
        }

        if (pathLists.size() > 0) {
            List<String> contentList = taxo.getContentIdsForTaxonomies(pathLists, contentTypeName, 'date', null, null);

            if (contentList.size() > 1) {
                for (Integer i = 0; i < contentList.size(); i++) {
                    if (contentList[i] != contentId)
                        contentIdList.add(contentList[i]);

                    if(contentIdList.size() >= 10)
                        break;
                }

                //Should change this back to faster call once OCMS bug is fixed - getContentRenderingsForContentIds
                Map<Id, String> contentRenderings = new Map<Id, String>();

                if (source == 'list') {
                    contentRenderings.putAll(taxApi.getLatestContentRenderingsForOriginContents(contentIdList, 'Tile'));
                } else {
                    contentRenderings.putAll(taxApi.getLatestContentRenderingsForOriginContents(contentIdList, 'NewsTile'));
                }

                Integer results = 0;
                for ( Integer i = 0; i < contentIdList.size(); i++) {
                    Map<String, String> paramMap = new Map<String, String>();
                    paramMap.put('content_Id', contentIdList[i]);
                    Pattern myPattern = Pattern.compile('');

                    if (source == 'list') {
                        myPattern = Pattern.compile('<h3.*>(.*)</h3>');
                    } else {
                        //myPattern = Pattern.compile('<h3.*><a href="(.*)">(.*)</a></h3>');
                        myPattern = Pattern.compile('<a.*href="(.*)"><div class="v-align">.*<h3.*>(.*)</h3>');
                    }
                    String sPattern = contentRenderings.get(contentIdList[i]);
                    Matcher myMatcher = myPattern.matcher(sPattern);
                    Boolean bMatches = myMatcher.find();
                    if (bMatches) {
                        results++;
                        relatedHTML += '<div class="article-related">';
                        relatedHTML += '<div class="article-related-summary">' + myMatcher.group(2) + '</div>';
                        if(!myMatcher.group(1).contains('Master-Article-Detail')) {
                            relatedHTML += '<a class="read-more-link" href="' + myMatcher.group(1) + '">' + sitePreferences.get('uiLabelArtReadMore') + '</a>';
                        } else if (type == 'article' || type == 'obituary') {
                            relatedHTML += '<a class="read-more-link" href="' + appendQueryStringsToSitePreferences('articlePage', paramMap) + '">' +
                                sitePreferences.get('uiLabelArtReadMore') + '</a>';
                        } else if (type == 'ceoArticle') {
                            relatedHTML += '<a class="read-more-link" href="' + appendQueryStringsToSitePreferences('ceoArticlePage', paramMap) + '">' +
                                sitePreferences.get('uiLabelArtReadMore') + '</a>';
                        }
                        relatedHTML += '</div>';
                    }

                    if(results >= 3)
                        break;
                }
            }
        }
        return relatedHTML;
    }

    public String getTaxPathsForContentIds(String contentId) {
        String taxTag = '';
        Set<String> contentIdSet = new Set<String>();
        contentIdSet.add(contentId);
        Map<String, List<String>> taxPathsMap = taxonomyApi.getPathsForContentIds(contentIdSet);
        List<String> taxPathsList = taxPathsMap.get(content.Id);
        for (String newsTax : taxPathsList) {
            if (newsTax.contains(sitePreferences.get('newsCategoryTaxonomy'))) {
                List<String> splitNewsTax = newsTax.split('/');
                if (splitNewsTax[splitNewsTax.size() - 1] != sitePreferences.get('newsCategoryTaxonomy')) {
                    taxTag = splitNewsTax[splitNewsTax.size() - 1];
                    break;
                }
            }
        }
        return taxTag;
    }// getTaxPathsForContentIds

    // Get news category to display
    public List<String> getAllTaxPathsForContentIds(String contentId) {
        List<String> taxTags = new List<String>();
        Set<String> contentIdSet = new Set<String>();
        contentIdSet.add(contentId);
        Map<String, List<String>> taxPathsMap = taxonomyApi.getPathsForContentIds(contentIdSet);
        List<String> taxPathsList = taxPathsMap.get(content.Id);
        for (String newsTax : taxPathsList) {
            if (newsTax.contains(sitePreferences.get('newsCategoryTaxonomy'))) {
                List<String> splitNewsTax = newsTax.split('/');
                if (splitNewsTax[splitNewsTax.size() - 1] != sitePreferences.get('newsCategoryTaxonomy')) {
                    taxTags.add(splitNewsTax[splitNewsTax.size() - 1]);
                }
            }
        }
        return taxTags;
    }

    // Get contents by name filtered by type
    private List<cms__content__c> getContentByNameAndType(String name, String type, String cid) {
        String term = '%' + String.escapeSingleQuotes(name) + '%';
        Datetime currentTime = Datetime.Now();
        List<cms__Content__c> contentList = Database.query('SELECT Id, cms__Name__c FROM cms__Content__c WHERE cms__Name__c LIKE :term AND cms__Published__c = true AND Id != :cid AND (cms__Published_End_Date__c > :currentTime OR cms__Published_End_Date__c = null) AND cms__Content_Type__r.cms__Name__c =: type LIMIT 5');

        return contentList;
    }    // getContentByNameAndType

    private String getRelatedArticleMarkup() {
        String renderingHTML = '';
        if (relatedArticles != null) {
            List<String> splitRelatedArticles = relatedArticles.split('~!~!');
            if (splitRelatedArticles.size() > 0) {
                List<String> articleIdList = new List<String>();
                for (Integer i = 0; i < splitRelatedArticles.size(); i++) {
                    if (Math.mod(i, 2) != 0) {
                        articleIdList.add(splitRelatedArticles[i]);
                    }
                }
                Map<Id, String> renderingMap = taxonomyApi.getLatestContentRenderingsForOriginContents(articleIdList, 'Tile');
                for (String aId : articleIdList) {
                    if (renderingMap.containsKey(aId)) {
                        renderingHTML += renderingMap.get(aId);
                    }
                }
            }
        }
        return renderingHTML;
    }// getRelatedArticleMarkup

    // Returns groups of taxonomy tags sorted by site pref tax group and separated by ';'
    public Map<String, String> getTagPaths(List<String> sitePrefPaths) {
        Map<String, String> pathStrings = new Map<String, String>();
        Set<String> contendIdSet = new Set<String>{
                content.Id
        };
        Map <String, List<String>> resultsMap = taxonomyApi.getPathsForContentIds(contendIdSet);
        if (resultsMap != null) {
            List<String> pathList = new List<String>();
            for (String tag : resultsMap.get(content.Id)) {
                for (String prefPath : sitePrefPaths) {
                    if (tag.contains(prefPath)) {
                        if (pathStrings.get(prefPath) == null) {
                            pathStrings.put(prefPath, tag);
                        } else {
                            pathStrings.put(prefPath, pathStrings.get(prefPath) + ';' + tag);
                        }
                    }
                }
            }
        }
        return pathStrings;
    }    // getTagPaths


    // Workaround for an OCMS Spring '15 past publishing issue. ISsue is fixed in Summer '15.
    public String updateOriginPublishStartDate(String contentId, Datetime startDate) {
        cms__Content__c c = [select Id, cms__Published__c, cms__Version_Number__c, cms__Revision_Number__c, cms__Published_Start_Date__c, cms__Preview_Start_Date__c, cms__Version_Origin__c from cms__Content__c where Id = :contentId];
        if (c.cms__Version_Origin__c != null) {
            c = [select Id, cms__Published__c, cms__Version_Number__c, cms__Revision_Number__c, cms__Published_Start_Date__c, cms__Preview_Start_Date__c from cms__Content__c where Id = :c.cms__Version_Origin__c];
        }

        if (c.cms__Version_Number__c != 1 || c.cms__Revision_Number__c != 0) {
            return '{"success":false,"message":"Must modify origin content only"}';
        }

        if (!c.cms__Published__c) {
            return '{"success":false,"message":"This action should only be performed on published content"}';
        }

        c.cms__Published_Start_Date__c = startDate;
        c.cms__Preview_Start_Date__c = startDate;

        try {
            cms__Content_Version_Index__c[] cvis = [select Id, cms__Original_Published_Start_Date__c, cms__Start_Date__c, cms__Origin__c, cms__Latest__c from cms__Content_Version_Index__c where cms__Origin__c = :c.Id];
            for (cms__Content_Version_Index__c cvi : cvis) {
                cvi.cms__Original_Published_Start_Date__c = c.cms__Published_Start_Date__c;
                if (cvi.cms__Origin__c == cvi.cms__Latest__c) {
                    cvi.cms__Start_Date__c = c.cms__Published_Start_Date__c;
                }
            }

            update cvis;
        } catch (QueryException e) {
            System.debug('No CVI found, carrying on.');
        }
        update c;
        return '{"success":true}';
    }

    public String title {
        get {
            return getProperty('title');
        }
        set;
    }

    public String publishDate {
        get {
            return getProperty('publishDate');
        }
        set;
    }

    public String summary {
        get {
            return getProperty('summary');
        }
        set;
    }

    public String body {
        get {
            return getProperty('body');
        }
        set;
    }

    public String detailSidebar {
        get {
            return getProperty('detailSidebar');
        }
        set;
    }

    public String thumbnailImage {
        get {
            return getProperty('thumbnailImage');
        }
        set;
    }

    public String imageIcon {
        get {
            return getProperty('imageIcon');
        }
        set;
    }

    // unique to CEO Articles, optional
    public String ceoBannerImage {
        get {
            return getProperty('ceoBannerImage');
        }
        set;
    }

    public String imageHero {
        get {
            return getProperty('imageHero');
        }
        set;
    }

    public String newsStreamRotatorImage {
        get {
            return getProperty('newsStreamRotatorImage');
        }
        set;
    }

    public String listPageRotatorImage {
        get {
            return getProperty('listPageRotatorImage');
        }
        set;
    }

    public String author {
        get {
            return getProperty('author');
        }
        set;
    }

    public String authorTitle {
        get {
            return getProperty('authorTitle');
        }
        set;
    }

    public String authorEmail {
        get {
            return getProperty('authorEmail');
        }
        set;
    }

    public String authorPhone {
        get {
            return getProperty('authorPhone');
        }
        set;
    }

    public String authorImage {
        get {
            return getProperty('authorImage');
        }
        set;
    }

    public String webLinkType {
        get {
            return this.getProperty('webLinkType');
        }
        set;
    }

    public String webLinkAsData {
        get {
            return this.getProperty('webLink');
        }
        set;
    }

    public cms.Link webLink {
        get {
            return new cms.Link(webLinkAsData);
        }
    }

    public String pageId {
        get {
            return this.getProperty('pageId');
        }
    }

    public String newsLinkAsData {
        get {
            return this.getProperty('newsLink');
        }
        set;
    }

    public cms.Link newsLink {
        get {
            return new cms.Link(newsLinkAsData);
        }
    }

    public String socialLinkAsData {
        get {
            return this.getProperty('socialLink');
        }
        set;
    }

    public cms.Link socialLink {
        get {
            return new cms.Link(socialLinkAsData);
        }
        set;
    }

    public String socialType {
        get {
            return this.getProperty('socialType');
        }
        set;
    }

    public String contentFlavor {
        get {
            return this.getProperty('contentFlavor');
        }
        set;
    }

    public String relatedArticles {
        get {
            return this.getProperty('relatedArticles');
        }
        set;
    }

    public String ceoCategory {
        get {
            return this.getProperty('ceoCategory');
        }
        set;
    }

    public String clipping1 {
        get {
            return getProperty('clipping1');
        }
        set;
    }

    public String clipping2 {
        get {
            return getProperty('clipping2');
        }
        set;
    }

    public String clipping1Link {
        get {
            return getProperty('clipping1Link');
        }
        set;
    }

    public String clipping2Link {
        get {
            return getProperty('clipping2Link');
        }
        set;
    }

    public String clipping1Summary {
        get {
            return getProperty('clipping1Summary');
        }
        set;
    }

    public String clipping2Summary {
        get {
            return getProperty('clipping2Summary');
        }
        set;
    }

    public String trending1 {
        get {
            return getProperty('trending1');
        }
        set;
    }
    public String trending1Link {
        get {
            return getProperty('trending1Link');
        }
        set;
    }

    public String trending2 {
        get {
            return getProperty('trending2');
        }
        set;
    }
    public String trending2Link {
        get {
            return getProperty('trending2Link');
        }
        set;
    }

    public String trending3 {
        get {
            return getProperty('trending3');
        }
        set;
    }
    public String trending3Link {
        get {
            return getProperty('trending3Link');
        }
        set;
    }

    public String trending4 {
        get {
            return getProperty('trending4');
        }
        set;
    }
    public String trending4Link {
        get {
            return getProperty('trending4Link');
        }
        set;
    }

    public Datetime migratedDate {
        get {
            try {
                DateTime dt = DateTime.valueOf((String) this.getProperty('migratedDate'));
                return dt;
            } catch (Exception e) {
                return null;
            }
        }
    }

    public String versionOriginId {
        get {
            versionOriginId = content.Id;
            if (content.cms__Version_Origin__c != null) {
                versionOriginId = content.cms__Version_Origin__c;
            }
            return versionOriginId;
        }
        set;
    }

    protected cms.ServiceAPI sAPI {
        get {
            if (sApi == null) {
                sApi = getServiceAPI();
            }
            return sApi;
        }
        set;
    }

    protected ocms_TaxonomyAPI taxonomyApi {
        get {
            if (taxonomyApi == null) {
                taxonomyApi = new ocms_TaxonomyAPI(sApi);
            }
            return taxonomyApi;
        }
        set;
    }

    protected ocms_mfc_Taxonomy mfcTaxonomy {
        get {
            if (mfcTaxonomy == null) {
                mfcTaxonomy = new ocms_mfc_Taxonomy(sApi);
            }
            return mfcTaxonomy;
        }
        set;
    }

    protected Map<String, String> sitePreferences {
        get {
            if (sitePreferences == null) {
                sitePreferences = ocms_mfc_SitePreferences.getSitePreferences(pm, getServiceAPI().getRenderLanguage());
            }
            return sitePreferences;
        }
        set;
    }

    /* Deprecated */
    protected cms__Content__c originalPublishDate {
        get {
            cms__Content__c contentObj = new cms__Content__c();
            String contentId = content.Id;
            List<cms__content__c> contentList = Database.query('SELECT cms__Original_Published_Start_Date__c FROM cms__Content__c WHERE Id = :contentId LIMIT 1');
            if (contentList.size() > 0) {
                contentObj = contentList[0];
            }
            return contentObj;
        }
        set;
    }

    public Datetime originalPublishedStartDate {
        get {
            if (originalPublishedStartDate == null) {
                originalPublishedStartDate = getOriginalPublishedStartDate();
            }
            return originalPublishedStartDate;
        }
        set;
    }
}