@isTest
private class ocms_mfc_AdHocTag_Test {
    
    //Test some basic class functionality 
    static testMethod void tesAdHocTagClass() {
        ocms_mfc_AdHocTag adTagObj = new ocms_mfc_AdHocTag();

        System.assertEquals('ocms_mfc_AdHocTag', adTagObj.getType().toString(), 'Expected ocms_mfc_AdHocTag. Received ' + adTagObj.getType().toString());
    }

    //Test the load tags functionality 
    static testMethod void testLoadTags() {
        ocms_mfc_AdHocTag adTagObj = new ocms_mfc_AdHocTag();
        String response = '';
        Map<String, Object> mResponse = new Map<String, Object>();

        cms__Content__c contentObj = new cms__Content__c();
        contentObj.cms__Name__c = 'Content';
        contentObj.cms__Site_Name__c ='SiteName';

        insert contentObj;

        cms__Language__c langObj = new cms__Language__c();
        langObj.cms__Language__c = 'English';
        langObj.cms__Language_Code__c = 'en_US';
        langObj.cms__Index_Key__c = 0;
        langObj.Name = 'English';

        insert langObj;

        response = adTagObj.executeRequest(new Map<String, String>{
            'action' => 'loadTags', 
            'languageId' => langObj.Id,
            'contentId' => contentObj.Id
        });

        mResponse = (Map<String, Object>) JSON.deserializeUntyped(response);
        System.assertEquals(true, mResponse.get('success'), 'Successfully Loaded Tags.');
        System.assertEquals(false, mResponse.get('hasTags'), 'There are no tags');

        Ad_Hoc_Tag__c tag = new Ad_Hoc_Tag__c();
        tag.Name = 'tag1';
        tag.Content__c = contentObj.Id;
        tag.Language__c = langObj.Id;

        insert tag;

        Ad_Hoc_Tag__c tagTwo = new Ad_Hoc_Tag__c();
        tagTwo.Name = 'tag2';
        tagTwo.Content__c = contentObj.Id;
        tagTwo.Language__c = langObj.Id;

        insert tagTwo;

        Ad_Hoc_Tag__c tagThree = new Ad_Hoc_Tag__c();
        tagThree.Name = 'tag3';
        tagThree.Content__c = contentObj.Id;
        tagThree.Language__c = langObj.Id;

        insert tagThree;

        response = adTagObj.executeRequest(new Map<String, String>{
            'action' => 'loadTags', 
            'languageId' => langObj.Id,
            'contentId' => contentObj.Id
        });
        mResponse = (Map<String, Object>) JSON.deserializeUntyped(response);
        List<Ad_Hoc_Tag__c> adHocTagsList = (List<Ad_Hoc_Tag__c>) JSON.deserialize(JSON.serialize(mResponse.get('tagList')), List<Ad_Hoc_Tag__c>.class);
        System.assertEquals(true, mResponse.get('success'), 'Successfully Loaded Tags.');
        System.assertEquals(true, mResponse.get('hasTags'), 'There are tags');
        System.assertEquals('tag1', adHocTagsList[0].Name, 'Tag list contents ' + adHocTagsList[0].Name);
        System.assertEquals('tag2', adHocTagsList[1].Name, 'Tag list contents ' + adHocTagsList[1].Name);
        System.assertEquals('tag3', adHocTagsList[2].Name, 'Tag list contents ' + adHocTagsList[2].Name);
    }

    //Test add tag functionality.
    static testMethod void testAddTags() {
        ocms_mfc_AdHocTag adTagObj = new ocms_mfc_AdHocTag();
        String response = '';
        Map<String, Object> mResponse = new Map<String, Object>();

        cms__Content__c contentObj = new cms__Content__c();
        contentObj.cms__Name__c = 'Content';
        contentObj.cms__Site_Name__c ='SiteName';

        insert contentObj;

        cms__Language__c langObj = new cms__Language__c();
        langObj.cms__Language__c = 'English';
        langObj.cms__Language_Code__c = 'en_US';
        langObj.cms__Index_Key__c = 0;
        langObj.Name = 'English';

        insert langObj;

        List<String> tagNameList = new List<String>();
        tagNameList.add('tag1');
        tagNameList.add('tag2');
        tagNameList.add('tag3');

        response = adTagObj.executeRequest(new Map<String, String>{
            'action' => 'addTags',  
            'languageId' => 'a0MW00000084jQX',
            'contentId' => 'a0MW00000084jQX',
            'tagNameList' => JSON.serialize(tagNameList)
        });
        mResponse = (Map<String, Object>) JSON.deserializeUntyped(response);
        System.assertEquals(false, mResponse.get('success'), 'Unsucessful added bad Ids');  

        response = adTagObj.executeRequest(new Map<String, String>{
            'action' => 'addTags',  
            'languageId' => langObj.Id,
            'contentId' => contentObj.Id,
            'tagNameList' => JSON.serialize(tagNameList)
        });
        mResponse = (Map<String, Object>) JSON.deserializeUntyped(response);
        System.assertEquals(true, mResponse.get('success'), 'Successfully Added Tags.');        
        System.assertEquals(1, [ SELECT COUNT() FROM Ad_Hoc_Tag__c WHERE Content__c = :contentObj.Id AND Language__c = :langObj.Id AND Name = :tagNameList[0]], 'Found added tag ' + tagNameList[0]);
        System.assertEquals(1, [ SELECT COUNT() FROM Ad_Hoc_Tag__c WHERE Content__c = :contentObj.Id AND Language__c = :langObj.Id AND Name = :tagNameList[1]], 'Found added tag ' + tagNameList[1]);
        System.assertEquals(1, [ SELECT COUNT() FROM Ad_Hoc_Tag__c WHERE Content__c = :contentObj.Id AND Language__c = :langObj.Id AND Name = :tagNameList[2]], 'Found added tag ' + tagNameList[2]);

    }

    //Test the remove tags functionality 
    static testMethod void testRemoveTags() {
        ocms_mfc_AdHocTag adTagObj = new ocms_mfc_AdHocTag();
        String response = '';
        Map<String, Object> mResponse = new Map<String, Object>();

        cms__Content__c contentObj = new cms__Content__c();
        contentObj.cms__Name__c = 'Content';
        contentObj.cms__Site_Name__c ='SiteName';

        insert contentObj;

        cms__Language__c langObj = new cms__Language__c();
        langObj.cms__Language__c = 'English';
        langObj.cms__Language_Code__c = 'en_US';
        langObj.cms__Index_Key__c = 0;
        langObj.Name = 'English';

        insert langObj;

        response = adTagObj.executeRequest(new Map<String, String>{
            'action' => 'removeTags',   
            'languageId' => langObj.Id,
            'contentId' => contentObj.Id
        });

        mResponse = (Map<String, Object>) JSON.deserializeUntyped(response);
        System.assertEquals(true, mResponse.get('success'), 'Successfully Loaded Tags.');

        Ad_Hoc_Tag__c tag = new Ad_Hoc_Tag__c();
        tag.Name = 'tag1';
        tag.Content__c = contentObj.Id;
        tag.Language__c = langObj.Id;

        insert tag;

        Ad_Hoc_Tag__c tagTwo = new Ad_Hoc_Tag__c();
        tagTwo.Name = 'tag2';
        tagTwo.Content__c = contentObj.Id;
        tagTwo.Language__c = langObj.Id;

        insert tagTwo;

        Ad_Hoc_Tag__c tagThree = new Ad_Hoc_Tag__c();
        tagThree.Name = 'tag3';
        tagThree.Content__c = contentObj.Id;
        tagThree.Language__c = langObj.Id;

        insert tagThree;

        response = adTagObj.executeRequest(new Map<String, String>{
            'action' => 'removeTags',   
            'languageId' => langObj.Id,
            'contentId' => contentObj.Id
        });
        mResponse = (Map<String, Object>) JSON.deserializeUntyped(response);
        List<Ad_Hoc_Tag__c> adHocTagsList = (List<Ad_Hoc_Tag__c>) JSON.deserialize(JSON.serialize(mResponse.get('tagList')), List<Ad_Hoc_Tag__c>.class);
        System.assertEquals(true, mResponse.get('success'), 'Successfully Loaded Tags.');
        System.assertEquals(0, [ SELECT COUNT() FROM Ad_Hoc_Tag__c WHERE Content__c = :contentObj.Id AND Language__c = :langObj.Id AND Name = 'tag1'], 'tag1 not found');
        System.assertEquals(0, [ SELECT COUNT() FROM Ad_Hoc_Tag__c WHERE Content__c = :contentObj.Id AND Language__c = :langObj.Id AND Name = 'tag2'], 'tag2 not found');
        System.assertEquals(0, [ SELECT COUNT() FROM Ad_Hoc_Tag__c WHERE Content__c = :contentObj.Id AND Language__c = :langObj.Id AND Name = 'tag3'], 'tag3 not found');
    }

    //Test method for the auto complete functionality.
    static testMethod void testAutoComplete() {
        ocms_mfc_AdHocTag adTagObj = new ocms_mfc_AdHocTag();
        String response = '';
        Map<String, Object> mResponse = new Map<String, Object>();

        cms__Content__c contentObj = new cms__Content__c();
        contentObj.cms__Name__c = 'Content';
        contentObj.cms__Site_Name__c ='SiteName';

        insert contentObj;

        cms__Language__c langObj = new cms__Language__c();
        langObj.cms__Language__c = 'English';
        langObj.cms__Language_Code__c = 'en_US';
        langObj.cms__Index_Key__c = 0;
        langObj.Name = 'English';

        insert langObj;

        Ad_Hoc_Tag__c tag = new Ad_Hoc_Tag__c();
        tag.Name = 'tag1';
        tag.Content__c = contentObj.Id;
        tag.Language__c = langObj.Id;

        insert tag;

        Ad_Hoc_Tag__c tagTwo = new Ad_Hoc_Tag__c();
        tagTwo.Name = 'tag2';
        tagTwo.Content__c = contentObj.Id;
        tagTwo.Language__c = langObj.Id;

        insert tagTwo;

        Ad_Hoc_Tag__c tagThree = new Ad_Hoc_Tag__c();
        tagThree.Name = 'tag3';
        tagThree.Content__c = contentObj.Id;
        tagThree.Language__c = langObj.Id;

        insert tagThree;

        response = adTagObj.executeRequest(new Map<String, String>{
            'action' => 'tagAutoComplete',  
            'languageId' => langObj.Id,
            'tagName' => 'test'
        });

        mResponse = (Map<String, Object>) JSON.deserializeUntyped(response);
        System.assertEquals(false, mResponse.get('success'), 'Nothing should be returned.');

        response = adTagObj.executeRequest(new Map<String, String>{
            'action' => 'tagAutoComplete',  
            'languageId' => langObj.Id,
            'tagName' => 'tag'
        });

        mResponse = (Map<String, Object>) JSON.deserializeUntyped(response);
        List<Ad_Hoc_Tag__c> adHocTagsList = (List<Ad_Hoc_Tag__c>) JSON.deserialize(JSON.serialize(mResponse.get('tagNames')), List<Ad_Hoc_Tag__c>.class);
        System.assertEquals(true, mResponse.get('success'), 'We have found some tags.');
        System.assertEquals(3, adHocTagsList.size(), 'We have found '+ adHocTagsList.size() +' tags.');
    }
}