/**
 * Created by Joe Zhong on 2018-09-14.
 */

global with sharing class ocms_mli_content_export_batch implements Database.Batchable<String>, Database.AllowsCallouts {
    private List<String> contentID;
    private String allContents;
    private Id contentVersionId;
    global class OCMS_MLI_API_Exception extends Exception {
    }

    global ocms_mli_content_export_batch(){

    }

    global ocms_mli_content_export_batch(List<String> contentID, Id fileId) {
        this.contentID = contentID;
        this.contentVersionId = fileId;
        this.allContents = '';
    }

    // The batch job starts
    global Iterable<String> start(Database.BatchableContext bc) {

        // Return our list of Strings we'd like to use for processing
        return this.contentID;
    }

    // The batch job executes and operates on one batch of records
    global void execute(Database.BatchableContext bc, List<String> scope) {

        // Loop through each string in our scope and process it accordingly
        for (String contentId : scope) {
            // API Code goes here

            ContentAPIRequest contentAPIRequest = new ContentAPIRequest();
            //contentAPIRequest.objectId = Id;
            contentAPIRequest.requestFlags.put('allData', true);
            contentAPIRequest.parameters.put('versionId', contentId);

            Map<String, String> contentParams = new Map<String, String>();
            contentParams.put('sname', 'Manulife'); // Replace site_name with the name of your OrchestraCMS site
            contentParams.put('service', 'ContentAPI');
            contentParams.put('action', 'getContent');
            contentParams.put('contentRequest', json.serialize(contentAPIRequest));
            contentParams.put('apiVersion', '5.0');

            String contentResponse = cms.ServiceEndpoint.doActionApex(contentParams);

            JSONMessage.APIResponse contentAPIResponse = (JSONMessage.APIResponse) json.deserialize(contentResponse, JSONMessage.APIResponse.class);

            if (!contentAPIResponse.isSuccess) {
                throw new OCMS_MLI_API_Exception('OCMS: Could not retrieve information from the Content API, ID is ' + contentId);
            }

            if (contentAPIResponse.type != 'ContentBundle') {
                throw new OCMS_MLI_API_Exception('OCMS: Unexpected result from Content API, ID is ' + contentId);
            }

            if (null != contentAPIResponse.responseObject && contentAPIResponse.responseObject.compareTo('null') != 0){
                allContents += contentAPIResponse.responseObject;
            }
        }

        ContentVersion contentVersion = [SELECT VersionData FROM ContentVersion Where Id = :this.contentVersionId LIMIT 1 FOR UPDATE];
        Blob contents = contentVersion.VersionData;
        contents = Blob.valueOf(contents.toString() + allContents);
        contentVersion.VersionData = contents;
        update ContentVersion;
    }

    // The batch job finishes
    global void finish(Database.BatchableContext bc) {

    }
}