/*
Utility methods for Tooling API.
Test class: AskHR_ToolingAPIUtilsTest
*/
public with sharing class AskHR_ToolingAPIUtils2 {

    /**
     * Description: Method executeToolingAPIQuery
     * 
     * This method returns the case close layot fields assigned to the current user profile and the record type of the given case record Id
     *
     * @return List<String> - Returns list of fields in the close case layout.
     */     
     public static String executeToolingAPIQuery(String query) {
     
        // Create the endpoint for the tooling api query
        // Encode the query
        // Use Named Credentials to Connect
        String endpoint = 'callout:AskHR_UserSessionForToolingAPI_NC/services/data/v48.0/tooling/query/?q=' + EncodingUtil.urlEncode(query, 'UTF-8');
        System.debug('Tooling API Endpoint: ' + endpoint);
        
        // Create HTTP Request
        HttpRequest req = new HttpRequest();
        
        req.setHeader('Content-Type', 'application/json');    
        req.setEndpoint(endpoint);
        req.setMethod('GET');
    
        Http h = new Http();
        String responseBody = '';
        
        // Call the tooling API
        HttpResponse res = h.send(req);
        System.debug('Tooling API Status Code: ' + res.getStatusCode());
        System.debug('Tooling API Response: ' + res.getBody());
        
        // API ran successfully if Status Code is 200
        if (res.getStatusCode() == 200) {
            responseBody = res.getBody();
        }
        
        System.debug('Tooling API Response2: ' + responseBody);  
             
        return responseBody;
    
     }
     
     
    /**
     * Description: Method parseToolingAPIResponseAndGetLayoutName
     * 
     * This method parses the Tooling API response and extracts the page layout name
     *
     * @return String - The page layout name.
     */  
     public static String parseToolingAPIResponseAndGetLayoutName(String responseBody) {
        String pageLayoutName = '';             
    
        // Deserialize the returned JSON as a Map
        Map<String, Object> mapQueryResult = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
    
        Integer size =  (Integer)mapQueryResult.get('size');
        Boolean done = (Boolean)mapQueryResult.get('done');

        // Retrieve the Page Layout name if the response is success
        if (done == true && size == 1) {
            // Get the first record
            List<Object> listRecords = (List<Object>)mapQueryResult.get('records');
            Map<String, Object> mapFirstRecord = (Map<String, Object>)listRecords[0];
    
            // Get the value of FullName field
            Map<String, Object> mapLayout =   (Map<String, Object>)mapFirstRecord.get('Layout');
            pageLayoutName = (String)mapLayout.get('FullName');            
        }
        
        return pageLayoutName;
     }
     
     /*
     * This method uses Metadata API to get the fields in the given layout name.
     * The metadata returned  by Metadata API is parsed and retrieve the fields in all the sections.
     */
     public static List<String> getFieldsUsingMetadataAPI(String pageLayoutName) {
        //Retrieve the metadata of the layout
        List<Metadata.Metadata> components =
            Metadata.Operations.retrieve(Metadata.MetadataType.Layout, new String[]{ pageLayoutName });
        
        Metadata.Layout layout = (Metadata.Layout) components.get(0);
    
        // Get the fields in each section of the layout in a List.
        List<String> listFields = new List<String>();
        if (layout.layoutSections != null) {
          // Loop thru each section in the layout.
          for (Metadata.LayoutSection section : layout.layoutSections) {
              if (section.layoutColumns != null) {
                  // loop thru each Column in the section
                  for (Metadata.LayoutColumn column : section.layoutColumns) {
                      if (column.layoutItems != null) {
                          // Loop thru each item in the column
                          for (Metadata.LayoutItem item : column.layoutItems) {
                              // If the item is  field, get the field API name
                              if (item.field != null) {
                                  listFields.add(item.field);
                              }
                          }
                      }
                  }
              }
          }
        }
        return listFields;
    }
    
}