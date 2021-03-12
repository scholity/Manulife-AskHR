global without sharing class ocms_mfc_AdHocTag implements cms.ServiceInterface {
    
    public ocms_mfc_AdHocTag() {}
    public System.Type getType() { return ocms_mfc_AdHocTag.class; }

    global String executeRequest(Map<String, String> params) {
        String action = params.get('action');
        String response = '';

        String tagName = params.get('tagName');
        String contentId = params.get('contentId');
        String languageId = params.get('languageId');
        List<String> tagNameList = new List<String>();
        

        //Add a Ad Hoc tag function
        if (action == 'addTags') {
            Boolean noErrors = true;
            tagNameList = (List<String>) JSON.deserialize(params.get('tagNameList'), List<String>.class);
            for (String tagString: tagNameList) {
                try {
                    Ad_Hoc_Tag__c adHockTag = new Ad_Hoc_Tag__c();
                    adHockTag.Name = tagString;
                    adHockTag.Content__c = contentId;
                    adHockTag.Language__c = languageId;
    
                    insert adHockTag;
                } catch (Exception e) {
                    noErrors = false;
                    break;
                }
            }

            if (noErrors) {
                response = '{"success": true}';
            } else {
                response = '{"success": false, "exception": "Invalid content or language Id"}';
            }
        } 
        //Remove multiple Ad Hoc tags function
        else if (action == 'removeTags') {
            Boolean noErrors = true;
            List<Ad_Hoc_Tag__c> tagList = new List<Ad_Hoc_Tag__c>();
            tagList = Database.query('SELECT Name FROM Ad_Hoc_Tag__c WHERE Content__c = :contentId AND Language__c = :languageId LIMIT 1000');
            for (Ad_Hoc_Tag__c tag: tagList) {
                try {
                    delete tag;
                } catch (Exception e) {
                    noErrors = false;
                    break;
                }
            }

            if (noErrors) {
                response = '{"success": true}';
            } else {
                response = '{"success": false, "exception": "Unknown error deleting Ad Hoc Tag record"}';
            }
        }
        //Load tags  
        else if (action == 'loadTags') {
            List<Ad_Hoc_Tag__c> tagList = getAllTagsByContentId(contentId, languageId);
            
            if (tagList.size() > 0) {
                response = '{"success": true, "hasTags": true, "tagList": '+ JSON.serialize(tagList) +'}';
            } else {
                response = '{"success": true, "hasTags": false}';
            }
        }
        else if (action == 'tagAutoComplete') {
            List<Ad_Hoc_Tag__c> tagList = getAdHocTagsByName(languageId, tagName);
            if (tagList.size() > 0) {
                response = '{"success": true, "tagNames": '+ JSON.serialize(tagList) +'}';
            } else {
                response = '{"success": false, "exception": "No matching tags"}';
            }
        }
        
        return response;
    }

    private List<Ad_Hoc_Tag__c> getAllTagsByContentId (String contentId, String languageId) {
        List<Ad_Hoc_Tag__c> tagList = new List<Ad_Hoc_Tag__c>();
        tagList = Database.query('SELECT Name FROM Ad_Hoc_Tag__c WHERE Content__c = :contentId AND Language__c = :languageId LIMIT 1000');
        return tagList;
    }

    private List<Ad_Hoc_Tag__c> getAdHocTagsByName(String languageId, String tagName) {
        String term = '%' + String.escapeSingleQuotes(tagName) + '%';
        List<Ad_Hoc_Tag__c> tagList = new List<Ad_Hoc_Tag__c>();
        tagList = Database.query('SELECT Name FROM Ad_Hoc_Tag__c WHERE Language__c = :languageId AND Name LIKE :term LIMIT 5');
        return tagList;
    }

}