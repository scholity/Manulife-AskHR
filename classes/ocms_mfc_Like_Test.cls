@isTest
private class ocms_mfc_Like_Test {

	
	//Main test method
	static testMethod void testLikeClass() {
		ocms_mfc_Like likeTest = new ocms_mfc_Like();
    	
    	System.assertEquals('ocms_mfc_Like', likeTest.getType().toString(), 'Expected ocms_mfc_Like, received ' + likeTest.getType().toString());
        
        ocms_mfc_Like.ContentLikeRecord likeRecord = new ocms_mfc_Like.ContentLikeRecord('ContentId', true, '1');

        System.assertEquals('ContentId', likeRecord.contentId, 'Expected ContentId received ' + likeRecord.contentId);
        System.assertEquals(true, likeRecord.liked, 'Expected true received ' + String.valueOf(likeRecord.liked));
        System.assertEquals('1', likeRecord.likeCount, 'Expected 1 received ' + likeRecord.likeCount);

	}

	//Test the add like function
	static testMethod void testAddLike() {
		ocms_mfc_Like likeTest = new ocms_mfc_Like();

		cms__Content__c contentObj = new cms__Content__c();
		contentObj.cms__Name__c = 'Content';
		contentObj.cms__Site_Name__c ='SiteName';

		insert contentObj;

		//Test Add Like successful, update true, count 1
		String response = likeTest.executeRequest(new Map<String, String>{
    		'action' => 'addLike',	
    		'userId' => UserInfo.getUserId(),
    		'id' => contentObj.Id,
            'type' => 'content'
		});
    	Map<String, Object> mResponse = (Map<String, Object>) JSON.deserializeUntyped(response);

    	System.assertEquals(true, mResponse.get('success'), 'Successfully created a like record.');

    	//Test Add Like successful, update false, NO count 
		response = likeTest.executeRequest(new Map<String, String>{
    		'action' => 'addLike',	
    		'userId' => UserInfo.getUserId(),
    		'id' => contentObj.Id, 
            'type' => 'content'
		});
    	mResponse = (Map<String, Object>) JSON.deserializeUntyped(response);

    	System.assertEquals(false, mResponse.get('success'), 'Record already exists.');
    	
    	//Test Add Like unsuccessful invalid user id or content id 
		response = likeTest.executeRequest(new Map<String, String>{
    		'action' => 'addLike',	
    		'userId' => '1234',
    		'id' => '1234',
            'type' => 'content'
		});
    	mResponse = (Map<String, Object>) JSON.deserializeUntyped(response);

    	System.assertEquals(false, mResponse.get('success'), 'Here is the exception error code ' + mResponse.get('exception'));

        //ADD LIKE FOR Page Origin Id
        //Create new page obj
        cms__Page__c pageObj = new cms__Page__c();
        pageObj.cms__Name__c = 'Page Name';
        pageObj.cms__Title__c = 'Page Title';

        insert pageObj;

        //Test Add Like successful, update true, count 1
        response = likeTest.executeRequest(new Map<String, String>{
            'action' => 'addLike',  
            'userId' => UserInfo.getUserId(),
            'id' => pageObj.Id,
            'type' => 'page'
        });
        mResponse = (Map<String, Object>) JSON.deserializeUntyped(response);

        System.assertEquals(true, mResponse.get('success'), 'Successfully created a like record.');

        //Test Add Like successful, update false, NO count 
        response = likeTest.executeRequest(new Map<String, String>{
            'action' => 'addLike',  
            'userId' => UserInfo.getUserId(),
            'id' => pageObj.Id, 
            'type' => 'page'
        });
        mResponse = (Map<String, Object>) JSON.deserializeUntyped(response);

        System.assertEquals(false, mResponse.get('success'), 'Record already exists.');
        
        //Test Add Like unsuccessful invalid user id or content id 
        response = likeTest.executeRequest(new Map<String, String>{
            'action' => 'addLike',  
            'userId' => '1234',
            'id' => '1234',
            'type' => 'page'
        });
        mResponse = (Map<String, Object>) JSON.deserializeUntyped(response);

        System.assertEquals(false, mResponse.get('success'), 'Here is the exception error code ' + mResponse.get('exception'));

    }

    //Test remove like
    static testMethod void testRemoveLike() {
        RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType = 'MFC_Community_Object__c' AND DeveloperName = 'Like'];
        String likeRecordType = rt.Id;

    	ocms_mfc_Like likeTest = new ocms_mfc_Like();

    	cms__Content__c contentObj = new cms__Content__c();
		contentObj.cms__Name__c = 'Content';
		contentObj.cms__Site_Name__c ='SiteName';

		insert contentObj;

    	//Try to remove a like record with a record, we expect success true and update false
    	MFC_Community_Object__c likeObj = new MFC_Community_Object__c();
    	likeObj.Content__c = contentObj.Id;
    	likeObj.User__c = UserInfo.getUserId();
        likeObj.RecordTypeId = likeRecordType;

    	insert likeObj;

    	String response = likeTest.executeRequest(new Map<String, String>{
    		'action' => 'removeLike',	
    		'userId' => UserInfo.getUserId(),
    		'id' => contentObj.Id,
            'type' => 'content'
		});
    	Map<String, Object> mResponse = (Map<String, Object>) JSON.deserializeUntyped(response);

    	System.assertEquals(true, mResponse.get('success'), 'Successfully deleted a like record.');

        //Try removeing a page origin id like.
        //Create new page obj
        cms__Page__c pageObj = new cms__Page__c();
        pageObj.cms__Name__c = 'Page Name';
        pageObj.cms__Title__c = 'Page Title';

        insert pageObj;

        //Try to remove a like record with a record, we expect success true and update false
        response = likeTest.executeRequest(new Map<String, String>{
            'action' => 'addLike',  
            'userId' => UserInfo.getUserId(),
            'id' => pageObj.Id,
            'type' => 'page'
        });
        mResponse = (Map<String, Object>) JSON.deserializeUntyped(response);    

        response = likeTest.executeRequest(new Map<String, String>{
            'action' => 'removeLike',   
            'userId' => UserInfo.getUserId(),
            'id' => pageObj.Id,
            'type' => 'page'
        });
        mResponse = (Map<String, Object>) JSON.deserializeUntyped(response);

        System.assertEquals(true, mResponse.get('success'), 'Successfully deleted a like record.');

    }

    //Test the load like function for a single page Id 
    static testMethod void testLoadLike() {
        RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType = 'MFC_Community_Object__c' AND DeveloperName = 'Like'];
        String likeRecordType = rt.Id;

        ocms_mfc_Like likeTest = new ocms_mfc_Like();

         //Create new page obj
        cms__Page__c pageObj = new cms__Page__c();
        pageObj.cms__Name__c = 'Page Name';
        pageObj.cms__Title__c = 'Page Title';

        insert pageObj;

        //Try with no like record
        String response = likeTest.executeRequest(new Map<String, String>{
            'action' => 'loadLike',    
            'userId' => UserInfo.getUserId(),
            'id' => pageObj.Id
        });
        Map<String, Object> mResponse = (Map<String, Object>) JSON.deserializeUntyped(response);

        System.assertEquals(true, mResponse.get('success'), 'Successfully loaded a like.');
        System.assertEquals('No Likes', mResponse.get('pageLike'), 'However there are no likes.');

        

        Profile p = [select Id from profile where name='System Administrator'];
        User u = new User (alias = 'standt', email='standarduser@manulife.com',
        emailencodingkey='UTF-8', lastname='waldo', languagelocalekey='en_US',
        localesidkey='en_US', profileid = p.Id, firstname='wheres',
        timezonesidkey='America/Los_Angeles', username='standarduserrr@manulife.com');
        TriggerUtils.setBypassUserTrigger(); // there is a trigger on user insert, this sets the flag so the trigger will bypass its logic check

        insert u;

        MFC_Community_Object__c likeObj5 = new MFC_Community_Object__c();
        likeObj5.Page__c = pageObj.Id;
        likeObj5.User__c = u.Id;
        likeObj5.RecordTypeId = likeRecordType;

        insert likeObj5;

        //try like record with different user 
        response = likeTest.executeRequest(new Map<String, String>{
            'action' => 'loadLike',    
            'userId' => UserInfo.getUserId(),
            'id' => pageObj.Id
        });
        mResponse = (Map<String, Object>) JSON.deserializeUntyped(response);      
        ocms_mfc_Like.PageLikeRecord pageLikeRecord = (ocms_mfc_Like.PageLikeRecord) JSON.deserialize(JSON.serialize(mResponse.get('pageLike')), ocms_mfc_Like.PageLikeRecord.class);
  
        System.assertEquals(true, mResponse.get('success'), 'Successfully loaded a like.');
        System.assertEquals(pageObj.Id, pageLikeRecord.pageId, 'Page Id is correct.');
        System.assertEquals(false, pageLikeRecord.liked, 'We did not like this page');
        System.assertEquals('1', pageLikeRecord.likeCount, 'So far only 1 like.');

        MFC_Community_Object__c likeObj6 = new MFC_Community_Object__c();
        likeObj6.Page__c = pageObj.Id;
        likeObj6.User__c = UserInfo.getUserId();
        likeObj6.RecordTypeId = likeRecordType;

        insert likeObj6;

        //Try with a like record we liked as well
        response = likeTest.executeRequest(new Map<String, String>{
            'action' => 'loadLike',    
            'userId' => UserInfo.getUserId(),
            'id' => pageObj.Id
        });
        mResponse = (Map<String, Object>) JSON.deserializeUntyped(response);

        pageLikeRecord = (ocms_mfc_Like.PageLikeRecord) JSON.deserialize(JSON.serialize(mResponse.get('pageLike')), ocms_mfc_Like.PageLikeRecord.class);

        System.assertEquals(true, mResponse.get('success'), 'Successfully loaded a like.');
        System.assertEquals(pageObj.Id, pageLikeRecord.pageId, 'Page Id is correct.');
        System.assertEquals(true, pageLikeRecord.liked, 'We liked this page');
        System.assertEquals('2', pageLikeRecord.likeCount, 'Now 2 likes.');
    }

    //Load all likes for a content
    static testMethod void testLoadLikes() {
    	RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType = 'MFC_Community_Object__c' AND DeveloperName = 'Like'];
        String likeRecordType = rt.Id;

        ocms_mfc_Like likeTest = new ocms_mfc_Like();

    	List<String> contentIdList = new List<String>();
        List<String> pageIdList = new List<String>();

		String serializedContentList = JSON.serialize(contentIdList);
        String serializedPageList = JSON.serialize(pageIdList);

    	String response = likeTest.executeRequest(new Map<String, String>{
    		'action' => 'loadLikes',	
    		'userId' => UserInfo.getUserId(),
    		'contentIdList' => serializedContentList,
            'pageIdList' => serializedPageList
		});
    	Map<String, Object> mResponse = (Map<String, Object>) JSON.deserializeUntyped(response);
    
    	List<ocms_mfc_Like.ContentLikeRecord> likeRecordList = (List<ocms_mfc_Like.ContentLikeRecord>) JSON.deserialize(JSON.serialize(mResponse.get('LikeList')), List<ocms_mfc_Like.ContentLikeRecord>.class);

    	System.assertEquals(false, mResponse.get('success'), 'Unsuccessful there are no likes!.');

    	cms__Content__c contentObj = new cms__Content__c();
		contentObj.cms__Name__c = 'Content';
		contentObj.cms__Site_Name__c ='SiteName';

    	cms__Content__c contentObj2 = new cms__Content__c();
		contentObj2.cms__Name__c = 'Content';
		contentObj2.cms__Site_Name__c ='SiteName';

		insert contentObj;
		insert contentObj2;

		Profile p = [select Id from profile where name='System Administrator'];
		User u = new User (alias = 'standt', email='standarduser@manulife.com',
		emailencodingkey='UTF-8', lastname='waldo', languagelocalekey='en_US',
		localesidkey='en_US', profileid = p.Id, firstname='wheres',
		timezonesidkey='America/Los_Angeles', username='standarduserrr@manulife.com');
		TriggerUtils.setBypassUserTrigger(); // there is a trigger on user insert, this sets the flag so the trigger will bypass its logic check

		insert u;

    	//Add like records
    	MFC_Community_Object__c likeObj1 = new MFC_Community_Object__c();
    	likeObj1.Content__c = contentObj.Id;
    	likeObj1.User__c = UserInfo.getUserId();
        likeObj1.RecordTypeId = likeRecordType;

    	MFC_Community_Object__c likeObj2 = new MFC_Community_Object__c();
    	likeObj2.Content__c = contentObj.Id;
    	likeObj2.User__c = u.Id;
        likeObj2.RecordTypeId = likeRecordType;

    	MFC_Community_Object__c likeObj3 = new MFC_Community_Object__c();
    	likeObj3.Content__c = contentObj2.Id;
    	likeObj3.User__c = UserInfo.getUserId();
        likeObj3.RecordTypeId = likeRecordType;

    	MFC_Community_Object__c likeObj4 = new MFC_Community_Object__c();
    	likeObj4.Content__c = contentObj2.Id;
    	likeObj4.User__c = u.Id;
        likeObj4.RecordTypeId = likeRecordType;

    	insert likeObj1;
    	insert likeObj2;
    	insert likeObj3;
    	insert likeObj4;

    	//Create a serialized list of content ids for ajax - mimic the java that does this
    	contentIdList = new List<String>();
    	contentIdList.add(contentObj.Id);
    	contentIdList.add(contentObj2.Id);

        pageIdList = new List<String>();

    	String serializedContentIdList = JSON.serialize(contentIdList);
        String serialisedPageIdList = JSON.serialize(pageIdList);
    	response = likeTest.executeRequest(new Map<String, String>{
    		'action' => 'loadLikes',	
    		'userId' => UserInfo.getUserId(),
    		'contentIdList' => serializedContentIdList,
            'pageIdList' => serialisedPageIdList
		});
    	mResponse = (Map<String, Object>) JSON.deserializeUntyped(response);
        
    	likeRecordList = (List<ocms_mfc_Like.ContentLikeRecord>) JSON.deserialize(JSON.serialize(mResponse.get('ContentLikeList')), List<ocms_mfc_Like.ContentLikeRecord>.class);   	  	
    	Set<ocms_mfc_Like.ContentLikeRecord> cLikeSet = new Set<ocms_mfc_Like.ContentLikeRecord>(likeRecordList);
        System.assertEquals(true, mResponse.get('success'), 'Successfully loaded all likes for content.');
    	System.assert(likeRecordList[0].contentId == contentObj.Id || likeRecordList[1].contentId == contentObj.Id, 'First like content id is ' + contentObj.Id);
    	System.assert(likeRecordList[0].contentId == contentObj2.Id || likeRecordList[1].contentId == contentObj2.Id, 'Second like content id is ' + contentObj2.Id);
    	System.assertEquals(2, likeRecordList.size(), 'We were returned ' + likeRecordList.size() + ' likes!');

        //Create new page obj
        cms__Page__c pageObj1 = new cms__Page__c();
        pageObj1.cms__Name__c = 'Page Name 1';
        pageObj1.cms__Title__c = 'Page Title 1';

        insert pageObj1;

        cms__Page__c pageObj2 = new cms__Page__c();
        pageObj2.cms__Name__c = 'Page Name 2';
        pageObj2.cms__Title__c = 'Page Title 2';

        insert pageObj2;

       //Add like records
        MFC_Community_Object__c likeObj5 = new MFC_Community_Object__c();
        likeObj5.Page__c = pageObj1.Id;
        likeObj5.User__c = UserInfo.getUserId();
        likeObj5.RecordTypeId = likeRecordType;

        MFC_Community_Object__c likeObj6 = new MFC_Community_Object__c();
        likeObj6.Page__c = pageObj1.Id;
        likeObj6.User__c = u.Id;
        likeObj6.RecordTypeId = likeRecordType;

        MFC_Community_Object__c likeObj7 = new MFC_Community_Object__c();
        likeObj7.Page__c = pageObj2.Id;
        likeObj7.User__c = UserInfo.getUserId();
        likeObj7.RecordTypeId = likeRecordType;

        MFC_Community_Object__c likeObj8 = new MFC_Community_Object__c();
        likeObj8.Page__c = pageObj2.Id;
        likeObj8.User__c = u.Id;
        likeObj8.RecordTypeId = likeRecordType;
        
        insert likeObj5;
        insert likeObj6;
        insert likeObj7;
        insert likeObj8;

        contentIdList = new List<String>();

        pageIdList = new List<String>();
        pageIdList.add(pageObj1.Id);
        pageIdList.add(pageObj2.Id);

        serializedContentIdList = JSON.serialize(contentIdList);
        serialisedPageIdList = JSON.serialize(pageIdList);
        response = likeTest.executeRequest(new Map<String, String>{
            'action' => 'loadLikes',    
            'userId' => UserInfo.getUserId(),
            'contentIdList' => serializedContentIdList,
            'pageIdList' => serialisedPageIdList
        });
        mResponse = (Map<String, Object>) JSON.deserializeUntyped(response);

    	List<ocms_mfc_Like.PageLikeRecord> pageLikeRecordList = (List<ocms_mfc_Like.PageLikeRecord>) JSON.deserialize(JSON.serialize(mResponse.get('PageLikeList')), List<ocms_mfc_Like.PageLikeRecord>.class); 
        
        System.assertEquals(true, mResponse.get('success'), 'Successfully loaded all likes for pages.');
        System.assert(pageLikeRecordList[0].pageId == pageObj1.Id || pageLikeRecordList[1].pageId == pageObj1.Id, 'First like content id is ' + pageObj1.Id);
        System.assert(pageLikeRecordList[0].pageId == pageObj2.Id || pageLikeRecordList[1].pageId == pageObj2.Id, 'Second like content id is ' + pageObj2.Id);
        System.assertEquals(2, pageLikeRecordList.size(), 'We were returned ' + pageLikeRecordList.size() + ' likes!');

        contentIdList.add(contentObj.Id);
        contentIdList.add(contentObj2.Id);

        serializedContentIdList = JSON.serialize(contentIdList);
        serialisedPageIdList = JSON.serialize(pageIdList);

        response = likeTest.executeRequest(new Map<String, String>{
            'action' => 'loadLikes',    
            'userId' => UserInfo.getUserId(),
            'contentIdList' => serializedContentIdList,
            'pageIdList' => serialisedPageIdList
        });
        mResponse = (Map<String, Object>) JSON.deserializeUntyped(response);
        likeRecordList = (List<ocms_mfc_Like.ContentLikeRecord>) JSON.deserialize(JSON.serialize(mResponse.get('ContentLikeList')), List<ocms_mfc_Like.ContentLikeRecord>.class);
        pageLikeRecordList = (List<ocms_mfc_Like.PageLikeRecord>) JSON.deserialize(JSON.serialize(mResponse.get('PageLikeList')), List<ocms_mfc_Like.PageLikeRecord>.class); 

        System.assertEquals(2, likeRecordList.size(), 'We were returned ' + likeRecordList.size() + ' likes!');
        System.assertEquals(2, pageLikeRecordList.size(), 'We were returned ' + pageLikeRecordList.size() + ' likes!');

	}

    //Test the get POID by name function 
    static testMethod void testGetPOIDByName() {
        ocms_mfc_Like likeTest = new ocms_mfc_Like();

        cms__Page__c pageObj1 = new cms__Page__c();
        pageObj1.cms__Name__c = 'Page Name 1';
        pageObj1.cms__Search_Optimized_Name__c = 'Page Name 1';
        pageObj1.cms__Title__c = 'Page Title 1';

        insert pageObj1;

        cms__Page__c pageObj2 = new cms__Page__c();
        pageObj2.cms__Name__c = 'Page Name 2';
        pageObj2.cms__Search_Optimized_Name__c = 'Page Name 2';
        pageObj2.cms__Title__c = 'Page Title 2';
        pageObj2.cms__Version_Origin__c = pageObj1.Id;

        insert pageObj2;

        String response = likeTest.executeRequest(new Map<String, String>{
            'action' => 'getPOIDByName',    
            'pageName' => pageObj1.cms__Search_Optimized_Name__c
        });
        Map<String, Object> mResponse = (Map<String, Object>) JSON.deserializeUntyped(response);

        System.assert(mResponse.get('success') == true, 'We have found an ID');
        System.assert(mResponse.get('pageId') == pageObj1.Id, 'No origin id... Id equals page 1 id');

        response = likeTest.executeRequest(new Map<String, String>{
            'action' => 'getPOIDByName',    
            'pageName' => pageObj2.cms__Search_Optimized_Name__c
        });
        mResponse = (Map<String, Object>) JSON.deserializeUntyped(response);

        System.assert(mResponse.get('success') == true, 'We have found an ID');
        System.assert(mResponse.get('pageId') == pageObj1.Id, 'Has origin id, the same id as page 1.');
    }

    //Test the sort articles by weight function 
    static testMethod void testSortArticlesByLikeWeight() {
        RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType = 'MFC_Community_Object__c' AND DeveloperName = 'Like'];
        String likeRecordType = rt.Id;

        ocms_mfc_Like likeTest = new ocms_mfc_Like();

        Profile p = [select Id from profile where name='System Administrator'];
        User u1 = new User (alias = 'standt', email='standarduser@manulife.com',
        emailencodingkey='UTF-8', lastname='waldo', languagelocalekey='en_US',
        localesidkey='en_US', profileid = p.Id, firstname='wheres',
        timezonesidkey='America/Los_Angeles', username='standarduserrr@manulife.com');
        TriggerUtils.setBypassUserTrigger();

        insert u1;

        User u2 = new User (alias = 'temp', email='tempy@manulife.com',
        emailencodingkey='UTF-8', lastname='waldo', languagelocalekey='en_US',
        localesidkey='en_US', profileid = p.Id, firstname='wheres',
        timezonesidkey='America/Los_Angeles', username='tempy@manulife.com');
        TriggerUtils.setBypassUserTrigger();

        insert u2;

        cms__Content__c contentObj1 = new cms__Content__c();
        contentObj1.cms__Name__c = 'Content 1';
        contentObj1.cms__Site_Name__c ='SiteName';

        cms__Content__c contentObj2 = new cms__Content__c();
        contentObj2.cms__Name__c = 'Content 2';
        contentObj2.cms__Site_Name__c ='SiteName';

        cms__Content__c versionOID = new cms__Content__c();
        versionOID.cms__Name__c = 'VOID';
        versionOID.cms__Site_Name__c ='SiteName';

        insert versionOID;

        cms__Content__c contentObj3 = new cms__Content__c();
        contentObj3.cms__Name__c = 'Content 3';
        contentObj3.cms__Site_Name__c ='SiteName';

        insert contentObj1;
        insert contentObj2;
        insert contentObj3;

        MFC_Community_Object__c likeObj1 = new MFC_Community_Object__c();
        likeObj1.Content__c = contentObj1.Id;
        likeObj1.User__c = UserInfo.getUserId();
        likeObj1.RecordTypeId = likeRecordType;

        MFC_Community_Object__c likeObj2 = new MFC_Community_Object__c();
        likeObj2.Content__c = contentObj1.Id;
        likeObj2.User__c = u1.Id;
        likeObj2.RecordTypeId = likeRecordType;

        MFC_Community_Object__c likeObj3 = new MFC_Community_Object__c();
        likeObj3.Content__c = contentObj1.Id;
        likeObj3.User__c = u2.Id;
        likeObj3.RecordTypeId = likeRecordType;

        MFC_Community_Object__c likeObj4 = new MFC_Community_Object__c();
        likeObj4.Content__c = contentObj2.Id;
        likeObj4.User__c = u1.Id;
        likeObj4.RecordTypeId = likeRecordType;

        MFC_Community_Object__c likeObj5 = new MFC_Community_Object__c();
        likeObj5.Content__c = contentObj2.Id;
        likeObj5.User__c = UserInfo.getUserId();
        likeObj5.RecordTypeId = likeRecordType;

        MFC_Community_Object__c likeObj6 = new MFC_Community_Object__c();
        likeObj6.Content__c = contentObj3.Id;
        likeObj6.User__c = u1.Id;
        likeObj6.RecordTypeId = likeRecordType;

        insert likeObj1;
        insert likeObj2; 
        insert likeObj3; 
        insert likeObj4; 
        insert likeObj5;        
        insert likeObj6; 

        List<String> contentIdList = new List<String>{contentObj1.Id, contentObj2.Id, contentObj3.Id};
        List<String> sortedContentIdList = likeTest.sortArticlesByLikeWeight(contentIdList);

        System.assert(sortedContentIdList[0] == contentObj1.Id, 'The content with the most likes is ' + contentObj1.Id);
        System.assert(sortedContentIdList[1] == contentObj2.Id, 'The content with the second most likes is ' + contentObj2.Id);
        System.assert(sortedContentIdList[2] == contentObj3.Id, 'The content with the least amount of likes is ' + contentObj3.Id);
    }
    
    
}