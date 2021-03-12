/*
Controller class for Aura Component AskHR_DynamicCloseCase.
Test class: AskHR_DynamicCloseCaseControllerTest
*/
public with sharing class AskHR_DynamicCloseCaseController_Dep {
 

    /**
     * Description: Method getCloseCaseLayoutFields
     * 
     * This method returns the case close layot fields assigned to the current user profile and the record type of the given case record Id
     *
     * @return List<String> - Returns list of fields in the close case layout.
     */
     
     @AuraEnabled
    public static List<String> getCloseCaseLayoutFields(String recordId) {
        
        // Get the record type id of the case.
        Case currCase = [SELECT Id, RecordTypeId FROM Case WHERE Id = :recordId];
        String recordTypeId = currCase.RecordTypeId;
    
        // Get the profile Id of current user.
        String profileId = UserInfo.getProfileId();
        
        // query to retrieve the current users Close Case page layout.
        String query = 'SELECT Layout.FullName FROM ProfileLayout WHERE RecordTypeId = \'' + recordTypeId + '\' AND ProfileId = \'' + profileId + '\' AND Layout.TableEnumOrId = \'CaseClose\'';
    
        String responseBody = '';
        String pageLayout = '';
        
        // Get the JSON response by executing the query using Tooling API
        responseBody = AskHR_ToolingAPIUtils_Dep.executeToolingAPIQuery(query);

        // Parse the JSON response and extract the Layout Name
        pageLayout = AskHR_ToolingAPIUtils_Dep.parseToolingAPIResponseAndGetLayoutName(responseBody);        
        
        // Retrieve the Fields in the layout by using Metadata API
        return AskHR_ToolingAPIUtils_Dep.getFieldsUsingMetadataAPI(pageLayout, 'CloseCase');
    }
}