public with sharing class AskHR_KnowledgeCustomTabs {

  

    /**
     * Description: Method getArticleDataForCommunity
     * This method is used by the Lightning component AskHR_KnowledgeCustomTabs that is added to Community Page.
     * 
     * This method returns Sections and the Fields (name, value, type, relatedobjectname) in each section to 
     * be displayed in Lightning component.
     * 
     * The Page Layout data is retrieved using REST API. See method getPageLayoutUsingRestAPI().
     * 
     * Sections and its Fields are retrieved from the name value pair Page Layout data.
     * If a field in a section is not accessible to the user or if it is null, then that field is not returned.
     * If all the fields in a section is not accessible to the user or if it is null, then that section is not returned.
     * 
     *
     * @param  recordId Id  - The Id of the Knowledge Article, the user is viewing.
     *
     * @return List<Section>
     */
     

    @AuraEnabled
    public static List<Section> getArticleDataForCommunity(ID recordId)
    {
        //
        // get Page Layout data for the Current Knowlwdge Article using REST API
        Map<String, Object> mapPageLayoutResult = getPageLayoutUsingRestAPI(recordId);

        // Loop through the Map data and parse each section to retrieve the field
        List<Object> layoutSections = (List<Object>)mapPageLayoutResult.get('detailLayoutSections');

        // Get the fields in each section of the layout in a Set.
        Set<String> setFields = new Set<String>();
        if (layoutSections != null) {
            for (Object sectionObj : layoutSections) {
                Map<String, Object> section = (Map<String, Object>)sectionObj;

                List<Object> layoutRows = (List<Object>)section.get('layoutRows');
                if (layoutRows != null) {
                    for (Object rowObj : layoutRows) {
                        Map<String, Object> row = (Map<String, Object>)rowObj;

                        List<Object> layoutItems = (List<Object>)row.get('layoutItems');
                        if (layoutItems != null) {
                            for (Object itemObj : layoutItems) {
                                Map<String, Object> item = (Map<String, Object>)itemObj;                          
            
                                List<Object> layoutComponents = (List<Object>)item.get('layoutComponents');
                                if (layoutComponents != null) {
                                    for (Object componentObj : layoutComponents) {
                                        Map<String, Object> component = (Map<String, Object>)componentObj;

                                        // type should be Field and value has the field API name
                                        String type = (String)component.get('type');
                                        if (type == 'Field') {
                                            String field = (String)component.get('value');
                                            if (field != null) {
                                                setFields.add(field);
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
                          
                    

        // Get the map of all fields on Knowledge__kav
        Map<String, Schema.SObjectField> mapFields = Schema.sObjectType.Knowledge__kav.fields.getMap();

        // Collect fields that are accessible
        Set<String> setAccessibleFields = new Set<String>();
        
        // Create a query using fields in the layout and field accessibility.
        String query = 'SELECT Id';
        for (String field : setFields) {
            Schema.DescribeFieldResult dfr = mapFields.get(field).getDescribe();
            // Add to query only if the field is accessible to the user
            if (dfr.isAccessible()) {

              // This field is accessible
              setAccessibleFields.add(field);
              
              query += ', ' + field;

              // Check if it is a lookup field.
              // For lookup field get the Name field of child object.
              if (dfr.getType() == Schema.DisplayType.Reference) {
                  String lookupNameField = field;
                  if (field.endsWithIgnoreCase('__c')) {
                      //for custom fields change __c to __r
                      lookupNameField = lookupNameField.left(lookupNameField.length() - 1) + 'r';
                  }
                  else if (field.endsWithIgnoreCase('Id')) {
                      //for standard fields remove Id. Example LastModifiedById to LastModifiedBy
                      lookupNameField = lookupNameField.left(lookupNameField.length() - 2);
                  }

                  query += ', ' + lookupNameField + '.Name';
              }
            }
        }
        query += ' FROM Knowledge__kav WHERE Id = :recordId LIMIT 1';

        Knowledge__kav article = Database.query(query);


        // The list of Sections to return.
        List<Section> listSections = new List<Section>();

        Section currSection = null;


        // Again loop through the layout data and create the sections and the fields if the values are not null
        if (layoutSections != null) {
            for (Object sectionObj : layoutSections) {
                Map<String, Object> section = (Map<String, Object>)sectionObj;

                // Starting new Section in Layout
                currSection = null;
                
                List<Object> layoutRows = (List<Object>)section.get('layoutRows');
                if (layoutRows != null) {
                    for (Object rowObj : layoutRows) {
                        Map<String, Object> row = (Map<String, Object>)rowObj;

                        List<Object> layoutItems = (List<Object>)row.get('layoutItems');
                        if (layoutItems != null) {
                            for (Object itemObj : layoutItems) {
                                Map<String, Object> item = (Map<String, Object>)itemObj;                          
            
                                List<Object> layoutComponents = (List<Object>)item.get('layoutComponents');
                                if (layoutComponents != null) {
                                    for (Object componentObj : layoutComponents) {
                                        Map<String, Object> component = (Map<String, Object>)componentObj;

                                        String type = (String)component.get('type');
                                        if (type == 'Field') {
                                            String field = (String)component.get('value');
                                            // Add only if the field is accessible
                                            if (field != null && setAccessibleFields.contains(field)) {
                                                // Get the value of this field
                                                Object value = article.get(field);
            
                                                // Check if the value is not null.
                                                // The value can be null in the record or if the field is not accessible
                                                if (value != null) {
                                                    // First field is getting added to a new Section, so create a new Section
                                                    if (currSection == null) {
                                                        currSection = new Section((String)section.get('heading'));
                                                        listSections.add(currSection);
                                                    }
            
                                                    // Add the field with the label and value to the section.
                                                    Schema.DescribeFieldResult dfr = mapFields.get(field).getDescribe();
            
                                                    Object lookupNameFieldValue = null;
                                                    
                                                    // Check if it is a lookup field.
                                                    // For lookup field get the Name field of child object.
                                                    if (dfr.getType() == Schema.DisplayType.Reference) {
                                                        String lookupNameField = field;
                                                        if (field.endsWithIgnoreCase('__c')) {
                                                            //for custom fields change __c to __r
                                                            lookupNameField = lookupNameField.left(lookupNameField.length() - 1) + 'r';
                                                        }
                                                        else if (field.endsWithIgnoreCase('Id')) {
                                                            //for standard fields remove Id. Example LastModifiedById to LastModifiedBy
                                                            lookupNameField = lookupNameField.left(lookupNameField.length() - 2);
                                                        }
            
                                                        lookupNameFieldValue = article.getSObject(lookupNameField).get('Name');
                                                    }
            
                                                    
                                                    currSection.fields.add(new Field(dfr.getLabel(), dfr.getType().name(), value, lookupNameFieldValue));                                        
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        System.debug('Returning Sections: ' + JSON.serialize(listSections));

        return listSections;

    }


    /**
     * Description: Method getArticleDataForPlatform
     * This method is used by the Lightning component AskHR_PlatformKACustomTabs that is added to Knowledge Lightning Page.
     * 
     * This method returns Sections and the Fields (name, value, type, relatedobjectname) in each section to 
     * be displayed in Lightning component.
     * 
     * The Page Layout is determined based on the PageAssignments for the Knowledge Record Type and the User Profile.
     * The Page Layout name is retrieved using Tooling API.
     * 
     * Sections and its Fields are retrieved from the Page Layout.
     * If a field in a section is not accessible to the user or if it is null, then that field is not returned.
     * If all the fields in a section is not accessible to the user or if it is null, then that section is not returned.
     * 
     *
     * @param  recordId Id  - The Id of the Knowledge Article, the user is viewing.
     *
     * @return List<Section>
     */ 
    @AuraEnabled
    public static List<Section> getArticleDataForPlatform(ID recordId)
    {
        //
        // get Layout name for the Current User using Tooling API
        String pageLayout = getLayoutUsingPageAssignments(recordId);
        List<Metadata.Metadata> components =
            Metadata.Operations.retrieve(Metadata.MetadataType.Layout, new String[]{pageLayout });
    
        Metadata.Layout layout = (Metadata.Layout) components.get(0);
    
        // Get the fields in each section of the layout in a Set.
        Set<String> setFields = new Set<String>();
        if (layout.layoutSections != null) {
          for (Metadata.LayoutSection section : layout.layoutSections) {
              if (section.layoutColumns != null) {
                  for (Metadata.LayoutColumn column : section.layoutColumns) {
                      if (column.layoutItems != null) {
                          for (Metadata.LayoutItem item : column.layoutItems) {
                              if (item.field != null) {
                                  setFields.add(item.field);
                              }
                          }
                      }
                  }
              }
          }
        }
    
        // Get the map of all fields on Knowledge__kav
        Map<String, Schema.SObjectField> mapFields = Schema.sObjectType.Knowledge__kav.fields.getMap();
    
        // Collect fields that are accessible
        Set<String> setAccessibleFields = new Set<String>();
        
        // Create a query using fields in the layout and field accessibility.
        String query = 'SELECT Id';
        for (String field : setFields) {
            Schema.DescribeFieldResult dfr = mapFields.get(field).getDescribe();
            // Add to query only if the field is accessible to the user
            if (dfr.isAccessible()) {
    
              // o6-17-2020 This field is accessible
              setAccessibleFields.add(field);
              
              query += ', ' + field;
    
              // Check if it is a lookup field.
              // For lookup field get the Name field of child object.
              if (dfr.getType() == Schema.DisplayType.Reference) {
                  String lookupNameField = field;
                  if (field.endsWithIgnoreCase('__c')) {
                      //for custom fields change __c to __r
                      lookupNameField = lookupNameField.left(lookupNameField.length() - 1) + 'r';
                  }
                  else if (field.endsWithIgnoreCase('Id')) {
                      //for standard fields remove Id. Example LastModifiedById to LastModifiedBy
                      lookupNameField = lookupNameField.left(lookupNameField.length() - 2);
                  }
    
                  query += ', ' + lookupNameField + '.Name';
              }
            }
        }
        query += ' FROM Knowledge__kav WHERE Id = :recordId LIMIT 1';
    
        Knowledge__kav article = Database.query(query);
    
    
        // The list of Sections to return.
        List<Section> listSections = new List<Section>();
    
        Section currSection = null;
    
        if (layout.layoutSections != null) {
            for (Metadata.LayoutSection section : layout.layoutSections) {
                // Starting new Section in Layout
                currSection = null;
                if (section.layoutColumns != null) {
                    for (Metadata.LayoutColumn column : section.layoutColumns) {
                        if (column.layoutItems != null) {
                            for (Metadata.LayoutItem item : column.layoutItems) {
    
                                // 06-17-2020 Also check if the field is accessible
                                //if (item.field != null) {
                                if (item.field != null && setAccessibleFields.contains(item.field)) {
                                    // Get the value of this field
                                    Object value = article.get(item.field);
    
                                    // Check if the value is not null.
                                    // The value can be null in the record or if the field is not accessible
                                    if (value != null) {
                                        // First field is getting added to a new Section, so create a new Section
                                        if (currSection == null) {
                                            currSection = new Section(section.label);
                                            listSections.add(currSection);
                                        }
    
                                        // Add the field with the label and vale to the section.
                                        Schema.DescribeFieldResult dfr = mapFields.get(item.field).getDescribe();
    
                                        Object lookupNameFieldValue = null;
                                        
                                        // Check if it is a lookup field.
                                        // For lookup field get the Name field of child object.
                                        if (dfr.getType() == Schema.DisplayType.Reference) {
                                            String lookupNameField = item.field;
                                            if (item.field.endsWithIgnoreCase('__c')) {
                                                //for custom fields change __c to __r
                                                lookupNameField = lookupNameField.left(lookupNameField.length() - 1) + 'r';
                                            }
                                            else if (item.field.endsWithIgnoreCase('Id')) {
                                                //for standard fields remove Id. Example LastModifiedById to LastModifiedBy
                                                lookupNameField = lookupNameField.left(lookupNameField.length() - 2);
                                            }
    
                                            lookupNameFieldValue = article.getSObject(lookupNameField).get('Name');
                                        }
    
                                        
                                        currSection.fields.add(new Field(dfr.getLabel(), dfr.getType().name(), value, lookupNameFieldValue));                                        
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        System.debug('Returning Sections: ' + JSON.serialize(listSections));
    
        return listSections;    
    }
    
    
        
    /**
     * Description: Method getPageLayoutUsingRestAPI
     * 
     * This method returns the  Page Layout details which is retrieved using the REST API call to
     * /services/data/v48.0/sobjects/<Object api name>/describe/layouts/<Record Type Id>
     * 
     * <Object api name> is replaced by Knowledge__kav
     * <Record Type Id> is replaced by Record Type Id of the current Knowledge Article.
     *
     * @param  recordId Id  - The Id of the Knowledge Article, the user is viewing.
     *
     * @return Map<String, Object> - The name value pair of the JSON data returned by the API.
     */    
    public static Map<String, Object> getPageLayoutUsingRestAPI(ID recordId) {

        // Get the record type id of the article.
        Knowledge__kav article = [SELECT Id, RecordTypeId FROM Knowledge__kav WHERE Id = :recordId];
        String recordTypeId = article.RecordTypeId;
        
        String responseBody = '';

        
        // Create the endpoint URL
        String endpointPageLayout = URL.getOrgDomainUrl().toExternalForm() + '/services/data/v48.0/sobjects/Knowledge__kav/describe/layouts/' + recordTypeId;
        System.debug('API Endpoint: ' + endpointPageLayout);
        System.debug('Site Id: ' + Site.getSiteId() );
        
        HttpRequest httpReq = new HttpRequest();
        httpReq.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());
        httpReq.setHeader('Content-Type', 'application/json');

        httpReq.setEndpoint(endpointPageLayout);
        httpReq.setMethod('GET');

        Http httpObj = new Http();

        // Make API call only if it not called from Test class 
        if (!Test.isRunningTest()) {
            HttpResponse httpRes = httpObj.send(httpReq);
            System.debug('REST API Status Code: ' + httpRes.getStatusCode());
            System.debug('REST API Response: ' + httpRes.getBody());
            if (httpRes.getStatusCode() == 200) {
                responseBody = httpRes.getBody();
            }
        } 
        else {
            // For test class
            responseBody = '{"detailLayoutSections": [{"heading": "Information","layoutRows": [{"layoutItems": [{"layoutComponents": [{"type": "Field", "value": "Title"}]}]}, {"layoutItems": [{"layoutComponents": [{"type": "Field", "value": "UrlName"}]}]}]}]}';
        }
        System.debug('REST API Response2: ' + responseBody);  
        
             

        // Parse the returned JSON
        Map<String, Object> mapPageLayoutResult = (Map<String, Object>) JSON.deserializeUntyped(responseBody);

        return mapPageLayoutResult;
    }

    
    /**
     * Description: Method getLayoutUsingPageAssignments
     * 
     * This method returns the name of the Page Layout which is detemined based on on the PageAssignmets for 
     * the Knowledge Record Type and the User Profile.
     * 
     * The Page Layout name is retrived using Tooling API.
     * 
     * If there is error or if it is called from Test class, the page Layout name is retrieved from the
     * custom metadata KnowledgeLayoutSetting__mdt.
     *
     * @param  recordId Id  - The Id of the Knowledge Article, the user is viewing.
     *
     * @return String - The name of the Page Layout
     */
     
    public static String getLayoutUsingPageAssignments(ID recordId) {
    
        // Get default layout name from metadata KnowledgeLayoutSetting__mdt
        KnowledgeLayoutSetting__mdt knowledgeLayoutSetting = [SELECT LayoutName__c FROM KnowledgeLayoutSetting__mdt LIMIT 1];
        String pageLayout = 'Knowledge__kav-' + knowledgeLayoutSetting.LayoutName__c;
    
        // Get the record type id of the article.
        Knowledge__kav article = [SELECT Id, RecordTypeId FROM Knowledge__kav WHERE Id = :recordId];
        String recordTypeId = article.RecordTypeId;
    
        // Get the profile Id of current user.
        String profileId = UserInfo.getProfileId();
    
        // query to retrieve the current users page layout.
        String query = 'SELECT Layout.FullName FROM ProfileLayout WHERE RecordTypeId = \'' + recordTypeId + '\' AND ProfileId = \'' + profileId + '\'';
    
        //String endpoint = URL.getSalesforceBaseUrl().toExternalForm() + '/services/data/v48.0/tooling/query/?q=' + EncodingUtil.urlEncode(query, 'UTF-8');
        String endpoint = 'callout:AskHR_UserSessionForToolingAPI_NC' + '/services/data/v48.0/tooling/query/?q=' + EncodingUtil.urlEncode(query, 'UTF-8');
        System.debug('Tooling API Endpoint: ' + endpoint);
        
        HttpRequest req = new HttpRequest();
        req.setHeader('Authorization', ' Bearer ' + UserInfo.getSessionID());
        req.setHeader('Content-Type', 'application/json');
    
        req.setEndpoint(endpoint);
        req.setMethod('GET');
    
        Http h = new Http();
		System.debug('req--'+req);
        System.debug('---session id--'+EncodingUtil.base64Encode(Blob.valueOf(UserInfo.getSessionID())));
        // Set default page if Tooling API fails.
        String responseBody = '{"size" : 1, "done" : true, "records" : [ {"Layout" : {"FullName" : "' + pageLayout + '"} } ]}';

        // Call the tooling API if not called from Test classes.
        if (!Test.isRunningTest()) {
            // Call the tooling API
            HttpResponse res = h.send(req);
            System.debug('Tooling API Status Code: ' + res.getStatusCode());
            System.debug('Tooling API Response: ' + res.getBody());
            if (res.getStatusCode() == 200) {
                responseBody = res.getBody();
            }      
        } 
        
        System.debug('Tooling API Response2: ' + responseBody);  
             
    
        // Parse the returned JSON
        Map<String, Object> mapQueryResult = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
    
        Integer size =  (Integer)mapQueryResult.get('size');
        Boolean done = (Boolean)mapQueryResult.get('done');

        // Retrieve the Page Layout name
        if (done == true && size == 1) {
            List<Object> listRecords = (List<Object>)mapQueryResult.get('records');
            Map<String, Object> mapFirstRecord = (Map<String, Object>)listRecords[0];
    
            Map<String, Object> mapLayout =   (Map<String, Object>)mapFirstRecord.get('Layout');
            pageLayout = (String)mapLayout.get('FullName');        
            system.debug('pagelayout name::'+pageLayout);
        }
    
        return pageLayout;        
    }
    


    // Inner class to hold field label and value.
    public class Field {
        @AuraEnabled
        public String label {get; set;}

        // The datatype of this field
        @AuraEnabled
        public String type {get; set;}
        @AuraEnabled
        public Object value {get; set;}

        // If this field is a Lookup, lookupNameValue has the value from Name field of the child object.
        @AuraEnabled
        public Object lookupNameValue {get; set;}

        public Field(String label, String type, Object value, Object lookupNameValue) {
          this.label = label;
          this.type = type;
          this.value = value;
          this.lookupNameValue = lookupNameValue;
        }
    }

    

    // Inner class to hold a Section and its fields.
    public class Section {
        @AuraEnabled
        public String name {get; set;}

        @AuraEnabled
        public List<Field> fields {get; set;}

        public Section(String name) {
          this.name = name;
          this.fields = new List<Field>();
        }
    }
    
}