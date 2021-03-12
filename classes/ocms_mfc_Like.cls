global without sharing class ocms_mfc_Like implements cms.ServiceInterface {

    public ocms_mfc_Like() {
    }
    public System.Type getType() {
        return ocms_mfc_Like.class;
    }

    global String executeRequest(Map<String, String> params) {
        String action = params.get('action');
        String response = '';

        if (action == 'loadLikes') {

            String userId = params.get('userId');
            List<String> contentIdList = (List<String>) JSON.deserialize(params.get('contentIdList'), List<String>.class);
            List<String> pageIdList = (List<String>) JSON.deserialize(params.get('pageIdList'), List<String>.class);
            List<String> mcContentIDList = null;

            // Mission Control does not have this params, only works for MFCentral
            Boolean MFChasMCWebLink = null != params.get('mcContentIds');

            if (MFChasMCWebLink){
                mcContentIDList = (List<String>) JSON.deserialize(params.get('mcContentIds'), List<String>.class);
            }

            //replace the MC Weblink IDs in contentIdList
            List<String> contentIdListWithMC = null;

            if (MFChasMCWebLink) {
                contentIdListWithMC = new List<String>();
                for (Integer i = 0; i < mcContentIDList.size(); i++) {
                    if (mcContentIDList[i] == 'MFC_Content') {
                        contentIdListWithMC.add(contentIdList[i]);
                    } else {
                        contentIdListWithMC.add(mcContentIDList[i]);
                    }
                }
            }else{
                contentIdListWithMC = contentIdList;
            }

            List<ContentLikeRecord> contentLikesList = new List<ContentLikeRecord>();
            List<PageLikeRecord> pageLikesList = new List<PageLikeRecord>();

            if (contentIdList.size() > 0 && userId != null) {

                List<MFC_Community_Object__c> userLikes = Database.query('SELECT Content__c FROM MFC_Community_Object__c WHERE Content__c IN :contentIdListWithMC AND User__c = :userId AND RecordTypeId = :likeRecordType');
                Set<MFC_Community_Object__c> userLikeSet = new Set<MFC_Community_Object__c>(userLikes);
                List<AggregateResult> likes = Database.query('SELECT Content__c, Count(Id) cnt FROM MFC_Community_Object__c WHERE Content__c IN :contentIdListWithMC AND RecordTypeId = :likeRecordType GROUP BY Content__c');
                for (AggregateResult aResult : likes) {
                    Boolean matchedUser = false;
                    for (Integer i = 0; i < userLikeSet.size(); i++) {
                        if (userLikes[i].Content__c == aResult.get('Content__c')) {
                            matchedUser = true;
                            break;
                        }
                    }
                    ContentLikeRecord likeRec = new ContentLikeRecord((String) aResult.get('Content__c'), matchedUser, String.valueOf(aResult.get('cnt')));

                    //Replace the ID back with the original ID
                    if (MFChasMCWebLink && contentIdListWithMC.contains(likeRec.contentId)){
                        likeRec.contentId = contentIdList[contentIdListWithMC.indexOf(likeRec.contentId)];
                    }

                    contentLikesList.add(likeRec);
                }
            }
            if (pageIdList.size() > 0 && userId != null) {

                List<MFC_Community_Object__c> userLikes = Database.query('SELECT Page__c FROM MFC_Community_Object__c WHERE Page__c IN :pageIdList AND User__c = :userId AND RecordTypeId = :likeRecordType');
                Set<MFC_Community_Object__c> userLikeSet = new Set<MFC_Community_Object__c>(userLikes);
                List<AggregateResult> likes = Database.query('SELECT Page__c, Count(Id) cnt FROM MFC_Community_Object__c WHERE Page__c IN :pageIdList AND RecordTypeId = :likeRecordType GROUP BY Page__c');

                for (AggregateResult aResult : likes) {
                    Boolean matchedUser = false;
                    for (Integer i = 0; i < userLikeSet.size(); i++) {
                        if (userLikes[i].Page__c == aResult.get('Page__c')) {
                            matchedUser = true;
                            break;
                        }
                    }
                    PageLikeRecord likeRec = new PageLikeRecord((String) aResult.get('Page__c'), matchedUser, String.valueOf(aResult.get('cnt')));
                    pageLikesList.add(likeRec);
                }
            }

            if (contentLikesList.size() > 0 && pageLikesList.size() > 0) {
                response = '{"success": true, "ContentLikeList": ' + JSON.serialize(contentLikesList) + ', "PageLikeList": ' + JSON.serialize(pageLikesList) + '}';
            } else if (contentLikesList.size() > 0) {
                response = '{"success": true, "ContentLikeList": ' + JSON.serialize(contentLikesList) + '}';
            } else if (pageLikesList.size() > 0) {
                response = '{"success": true, "PageLikeList": ' + JSON.serialize(pageLikesList) + '}';
            } else {
                response = '{"success": false, "Message": "No Likes to load."}';
            }
        } else if (action == 'loadLike') {
            String userId = params.get('userId');
            String pageId = params.get('id');

            Boolean matchedUser = false;
            List<MFC_Community_Object__c> userLikeList = Database.query('SELECT Page__c FROM MFC_Community_Object__c WHERE Page__c = :pageId AND User__c = :userId AND RecordTypeId = :likeRecordType');

            if (userLikeList.size() > 0) {
                matchedUser = true;
            }

            Integer likeCount = [SELECT COUNT() FROM MFC_Community_Object__c WHERE Page__c = :pageId];
            if (likeCount > 0) {
                PageLikeRecord likeRec = new PageLikeRecord(pageId, matchedUser, String.valueOf(likeCount));
                response = '{"success": true, "pageLike": ' + JSON.serialize(likeRec) + '}';
            } else {
                response = '{"success": true, "pageLike": "No Likes" }';
            }

        } else if (action == 'addLike') {
            try {
                String userId = params.get('userId');
                String contentPageId = params.get('id');
                String type = params.get('type');
                MFC_Community_Object__c likeObj = returnLike(contentPageId, userId, type);
                if (type == 'content') {
                    if (likeObj.Id == null) {
                        MFC_Community_Object__c likeRecord = new MFC_Community_Object__c();
                        likeRecord.Content__c = contentPageId;
                        likeRecord.User__c = userId;
                        likeRecord.RecordTypeId = likeRecordType;

                        insert likeRecord;
                        response = '{"success": true }';
                    } else {
                        response = '{"success": false }';
                    }
                } else if (type == 'page') {
                    if (likeObj.Id == null) {
                        MFC_Community_Object__c likeRecord = new MFC_Community_Object__c();
                        likeRecord.Page__c = contentPageId;
                        likeRecord.User__c = userId;
                        likeRecord.RecordTypeId = likeRecordType;

                        insert likeRecord;
                        response = '{"success": true }';
                    } else {
                        response = '{"success": false }';
                    }
                }
            } catch (Exception e) {
                //This will only happen if request is passed bad data
                response = '{"success": false, "exception": ' + e.getCause() + '}';
            }
        } else if (action == 'removeLike') {
            String userId = params.get('userId');
            String contentPageId = params.get('id');
            String type = params.get('type');

            MFC_Community_Object__c likeRecord = returnLike(contentPageId, userId, type);
            if (likeRecord.Id != null) {
                try {
                    delete likeRecord;

                    response = '{"success": true }';
                } catch (Exception e) {
                    //This should never happen
                    response = '{"success": false }';
                }
            } else {
                response = '{"success": false }';
            }
        } else if (action == 'getPOIDByName') {
            String pageName = params.get('pageName');
            cms__Page__c pObj = Database.query('SELECT Id, cms__Version_Origin__c FROM cms__Page__c WHERE cms__Search_Optimized_Name__c = :pageName LIMIT 1');
            if (pObj.cms__Version_Origin__c != null) {
                response = '{"success": true, "pageId": "' + pObj.cms__Version_Origin__c + '"}';
            } else {
                response = '{"success": true, "pageId": "' + pObj.Id + '"}';
            }
        }

        return response;
    }

    public static MFC_Community_Object__c returnLike(String contentPageId, String userId, String type) {
        RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType = 'MFC_Community_Object__c' AND DeveloperName = 'Like'];
        String likeRecordType = rt.Id;
        List<MFC_Community_Object__c> likeList = new List<MFC_Community_Object__c>();
        if (type == 'content') {
            likeList = Database.query('SELECT Id, Name, RecordTypeId FROM MFC_Community_Object__c WHERE Content__c = :contentPageId AND User__c = :userId AND RecordTypeId = :likeRecordType LIMIT 1');
        } else if (type == 'page') {
            likeList = Database.query('SELECT Id, Name, RecordTypeId FROM MFC_Community_Object__c WHERE Page__c = :contentPageId AND User__c = :userId AND RecordTypeId = :likeRecordType LIMIT 1');
        }
        if (likeList.size() > 0) {
            return likeList[0];
        } else {
            return new MFC_Community_Object__c();
        }
    }

    public List<String> sortArticlesByLikeWeight(List<String> contentIdList) {
        List<cms__Content__c> contentList = Database.query('SELECT Id, cms__Version_Origin__c FROM cms__Content__c WHERE Id IN :contentIdList');
        Map< String, String> mappedContentIds = new Map<String, String>();

        for (cms__Content__c cObj : contentList) {
            if (cObj.cms__Version_Origin__c != null) {
                mappedContentIds.put(cObj.cms__Version_Origin__c, cObj.Id);
            } else {
                mappedContentIds.put(cObj.Id, cObj.Id);
            }
        }

        Set<String> mappedIdSet = mappedContentIds.keySet();
        List<AggregateResult> likeSortByWeight = Database.query('SELECT Content__c, SUM(Weight__c) weight FROM MFC_Community_Object__c WHERE Content__c IN :mappedIdSet AND RecordTypeId = :likeRecordType GROUP BY Content__c ORDER BY SUM(Weight__c) DESC');

        List<String> sortedIdList = new List<String>();

        for (AggregateResult result : likeSortByWeight) {
            sortedIdList.add(mappedContentIds.get((String) result.get('Content__c')));
        }

        return sortedIdList;

    }

    /*
    Class for Content Like
    */
    public class ContentLikeRecord {
        public String contentId;
        public Boolean liked;
        public String likeCount;

        public ContentLikeRecord(String cId, Boolean l, String lc) {
            contentId = cId;
            liked = l;
            likeCount = lc;
        }
    }


    /*
    Class for Page Like
    */
    public class PageLikeRecord {
        public String pageId;
        public Boolean liked;
        public String likeCount;

        public PageLikeRecord(String pId, Boolean l, String lc) {
            pageId = pId;
            liked = l;
            likeCount = lc;
        }
    }

    /*
    Property for like record type
    */
    private String likeRecordType {
        get {
            if (likeRecordType == null) {
                RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType = 'MFC_Community_Object__c' AND DeveloperName = 'Like'];
                likeRecordType = rt.Id;
            }
            return likeRecordType;
        }
        set;
    }
}