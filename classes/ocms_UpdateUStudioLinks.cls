/**
 * Created by jonathanbell Stantive Technology Group on 2017-02-06.
 * <p>This Batch Class is to retrieve OrchestraCMS Attribute records of type 'Text' for a particular OrchestraCMS site.  The
 * values in the Text attributes are examined to see if the string 'players.brightcove' exists within it, if so, that records
 * information is added to the csvString.  When the process is finished, a new record is created on the MFC Community Objects
 * custom object with a record type of 'uStudio'.  The csvString is used to create a file attachment which is then added to
 * the newly created record.</p>
 *
 * @param {String} site
 *      OrchestraCMS Site to search.
 */
global class ocms_UpdateUStudioLinks implements Database.Batchable<sObject>, Database.Stateful {
    //instance member to retain string to convert to csv
    global String csvFileString='';
    global String csvProcessedFile='';
    global boolean firstRun = true;

    public ocms_UpdateUStudioLinks (){}

    global Database.QueryLocator start(Database.BatchableContext bc){
        String query = 'SELECT ID, Attribute_Id__c, Brightcove_Link__c,uStudio_Link__c,Content_Id__c,Original_Content_Id__c,Original_Publish_Date__c,Processed__c ';
        query += 'FROM BrightcoveUpdateList__c WHERE Processed__c != true';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<BrightcoveUpdateList__c> scope){
        //create set of attribute Ids.
        Set<Id> attrIds = new Set<Id>();
        List<cms__Attribute__c> updateAttributeList = new List<cms__Attribute__c>();

        if (firstRun){
            List<String> pageName;
            //setup header line
            //            csvFileString = 'Attribute Id, Content Id, Original Content Id, Content Name, Content Type, Version, Orig Publish Date, Latest Preview , Latest Published, Last Modified By, Language, Attribute Name, Attribute Type, Value, Preview Link, Brightcove links, Simple Value, Text Value, TextArea Value' + '\n';
            csvFileString = 'Status, Attribute Id, Message, Content Id, Content Name, Content Version, Original Value, Updated Value ' + '\n';
            csvProcessedFile = 'Status, Update Record Id, Message' + '\n';
        }
        firstRun = false;
        For (BrightcoveUpdateList__c updateItem:scope){
            attrIds.add(updateItem.Attribute_Id__c);
        }
        //retrieve map of attributes to update
        Map<Id,cms__Attribute__c> updateAttributesMap = new Map<Id,cms__Attribute__c>([SELECT Id,cms__Value__c, cms__Content__c, cms__Content__r.cms__Name__c,cms__Content__r.cms__Version_Number__c, cms__Content__r.cms__Revision_Number__c  FROM cms__Attribute__c WHERE Id IN :attrIds]);
        Map<Id,cms__Attribute__c> originalAttributeMap = updateAttributesMap.deepClone();

        //replace the brightcove link with the uStudio link in the body.
        For (BrightcoveUpdateList__c updateItem:scope){
            cms__Attribute__c attrToUpdate = updateAttributesMap.get(updateItem.Attribute_Id__c);
            String bodyText = attrToUpdate.cms__Value__c;
            String brightcoveString = updateItem.Brightcove_Link__c.trim();
            String uStudioString =  updateItem.uStudio_Link__c.trim();
            String updateBodyText = bodyText.replace(brightcoveString,uStudioString);
//            cms__Attribute__c updatedAttr = new cms__Attribute__c();
//            attrToUpdate.Id = updateItem.Attribute_Id__c;
            attrToUpdate.cms__Value__c = updateBodyText;
            updateAttributesMap.put(attrToUpdate.Id,attrToUpdate);
            //mark the update item as processed.
            updateItem.Processed__c = true;
        }
        //create updates list which will use DML to update attributes

        for (Id key:updateAttributesMap.keySet()){
            updateAttributeList.add(updateAttributesMap.get(key));
//            System.debug('\nkey: ' + key);
//            System.debug('\nBody Text: ' + updateAttributesMap.get(key).cms__Value__c);
        }

        //update updateitem list
        Database.SaveResult[] procResultsList = Database.update(scope,false);
        for (Database.SaveResult sr : procResultsList){
            if (sr.isSuccess()){
                csvProcessedFile += 'SUCCESS,';
            } else {
                csvProcessedFile += 'ERROR,';
            }
            csvProcessedFile += sr.getId();
            if (sr.isSuccess()){
                csvProcessedFile += ',\n';
            } else {
                csvProcessedFile += ',';
                for (Database.Error err : sr.getErrors()){
                    csvProcessedFile += err.getStatusCode() + ' : ' + err.getMessage() + '\n';
                }
            }
        }

        // use Database object to perform update allow for partial success.
        Database.SaveResult[] srList = Database.update(updateAttributeList,false);

        for (Database.SaveResult sr : srList){
            if (sr.isSuccess()){
                csvFileString += 'SUCCESS,';
            } else {
                csvFileString += 'ERROR,';
            }
            csvFileString += sr.getId();
            if (sr.isSuccess()){
                // create record of changes.
                cms__Attribute__c beforeAttr = originalAttributeMap.get(sr.getId());
                cms__Attribute__c updatedAttr = updateAttributesMap.get(sr.getId());
                csvFileString += ', ,';
                csvFileString += updatedAttr.cms__Content__c + ',';
                csvFileString += updatedAttr.cms__Content__r.cms__Name__c + ',';
                csvFileString += updatedAttr.cms__Content__r.cms__Version_Number__c.setScale(0) + '.'+ updatedAttr.cms__Content__r.cms__Revision_Number__c.setScale(0) + ',';
                csvFileString += beforeAttr.cms__Value__c.escapeCsv() + ',';
                csvFileString += updatedAttr.cms__Value__c.escapeCsv();
                csvFileString += '\n';
                system.debug('before: ' + beforeAttr.cms__Value__c);
                system.debug('after: ' + updatedAttr.cms__Value__c);
            } else {
                csvFileString += ',';
                for (Database.Error err : sr.getErrors()){
                    csvFileString += err.getStatusCode() + ' : ' + err.getMessage() + ';';
                }
                csvFileString += ',,,,,\n';
            }
        }

    }

    global void finish(Database.BatchableContext bc){
        //get uStudio record type
        RecordType uStudioRT = [SELECT Id FROM RecordType where SObjectType ='MFC_Community_Object__c' AND Name ='uStudio'];
        //create file and attach to MFC Community Objects
        //Create Object
        MFC_Community_Object__c mfcCo = new MFC_Community_Object__c();
        mfcCo.RecordTypeId = uStudioRT.id;
        insert mfcCo;
        if (String.isBlank(csvFileString)){
            csvFileString = 'No Updates';
        }
        //create attachment for updated attributes
        Blob bodyBlob = Blob.valueOf(csvFileString);
        Attachment csvFile = new Attachment(Name = 'Udpated_Attributes_Results_' + datetime.now() + '.csv',body = bodyBlob, parentId=mfcCo.Id);
        insert csvFile;

        // create attachment for updated processed list
        if (String.isBlank(csvProcessedFile)){
            csvProcessedFile = 'No records processed';
        }
        //create attachment for updated attributes
        bodyBlob = Blob.valueOf(csvProcessedFile);
        Attachment csvProcessedFile = new Attachment(Name = 'Processed_Records_' + datetime.now() + '.csv',body = bodyBlob, parentId=mfcCo.Id);
        insert csvProcessedFile;
    }
}