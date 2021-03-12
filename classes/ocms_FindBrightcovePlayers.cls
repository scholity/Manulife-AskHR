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
global class ocms_FindBrightcovePlayers implements Database.Batchable<sObject>, Database.Stateful {
    //instance member to retain string to convert to csv
    global String csvFileString='';
    global Map<String,String> detailURL= new Map<String,String>();
    global boolean firstRun = true;
    global String siteDomain;
    global String siteName;
    global String articleContentType;
    global String ceoMsgContentType;


    public ocms_FindBrightcovePlayers (String site, String domain, String artContType, String ceoMsgContType){
        siteName = String.isBlank(site) ? 'AskHR_Employee_Community' : site;
        siteDomain = String.isBlank(domain) ? 'https://domain-not-supplied' : domain;
        articleContentType = String.isBlank(artContType) ? 'MFC Article' : artContType;
        ceoMsgContentType = String.isBlank(ceoMsgContType) ? 'CEOMessage' : ceoMsgContType;
    }

    global Database.QueryLocator start(Database.BatchableContext bc){
        String query = 'SELECT ID, cms__Content__c, cms__Content__r.cms__Version_Origin__c, cms__Content__r.cms__Name__c, cms__Content__r.cms__Content_Type__r.cms__Name__c, cms__Content__r.cms__Published_Start_Date__c, cms__Content__r.cms__Published_End_Date__c,';
        query += 'cms__Content_Layout_Instance__c,cms__Language__r.Name, cms__Page_Content_Layout_Instance__c, cms__Simple_Name__c, cms__Simple_Value__c,cms__Content__r.cms__Am_Latest_Preview__c,cms__Content__r.cms__Am_Latest_Published__c,';
        query += 'cms__Text_Value__c, cms__TextArea_Value__c, cms__Type__c, cms__Value__c, cms__Content__r.cms__Version_Number__c, cms__Content__r.cms__Revision_Number__c,';
        query += 'cms__Content__r.cms__Original_Published_Start_Date__c, lastModifiedBy.Name ';
        query += 'FROM cms__Attribute__c ';
        query += 'WHERE  cms__Content__r.cms__Site_Name__c = \'' + siteName + '\' AND cms__Type__c = \'Text\' ';
        query += 'AND (cms__Content__r.cms__Published_Start_date__c <= TODAY AND (cms__Content__r.cms__Published_End_Date__c = null OR cms__Content__r.cms__Published_End_Date__c >= TODAY ))';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<cms__Attribute__c> scope){
        if (firstRun){
            List<String> pageName;
            //setup header line
//            csvFileString = 'Attribute Id, Content Id, Original Content Id, Content Name, Content Type, Version, Orig Publish Date, Latest Preview , Latest Published, Last Modified By, Language, Attribute Name, Attribute Type, Value, Preview Link, Brightcove links, Simple Value, Text Value, TextArea Value' + '\n';
            csvFileString = 'Attribute Id, Content Id, Original Content Id, Content Name, Content Type, Version, Orig Publish Date, Latest Preview , Latest Published, Last Modified By, Language, Attribute Name, Attribute Type, Preview Link, Brightcove links' + '\n';

            //obtain detail URLs and site domain
            try{
                System.debug('supplied siteDomain: ' + siteDomain);
                //retrieve the article detail page name from site preferences.
                System.debug('query for articleDetailUrl');
                cms__Attribute__c articleDetailUrl = [SELECT cms__Value__c FROM cms__Attribute__c WHERE cms__Content__r.cms__Site_Name__c =: siteName AND cms__Simple_Name__c ='articlePage' AND cms__Language__r.Name = 'English' AND (cms__Content__r.cms__Published_Start_date__c <= TODAY AND (cms__Content__r.cms__Published_End_Date__c = null OR cms__Content__r.cms__Published_End_Date__c >= TODAY )) LIMIT 1];
                if (articleDetailUrl != null){
                    pageName = articleDetailUrl.cms__Value__c.split(',');
                    detailURL.put(articleContentType, siteDomain + '/apex/Preview?sname=' + siteName + '&name=' + pageName[3] + '&content_id=');
                }
                System.debug('query for ceoDetailUrl');
                cms__Attribute__c ceoDetailUrl = [SELECT cms__Value__c FROM cms__Attribute__c WHERE cms__Content__r.cms__Site_Name__c =: siteName AND cms__Simple_Name__c ='ceoArticlePage' AND cms__Language__r.Name = 'English' AND (cms__Content__r.cms__Published_Start_date__c <= TODAY AND (cms__Content__r.cms__Published_End_Date__c = null OR cms__Content__r.cms__Published_End_Date__c >= TODAY )) LIMIT 1];
                if (ceoDetailUrl != null){
                    pageName = ceoDetailUrl.cms__Value__c.split(',');
                    detailURL.put(ceoMsgContentType,siteDomain + '/apex/Preview?sname=' + siteName + '&name=' + pageName[3] + '&content_id=');
                }
            } catch (exception e){
                System.debug('Error caught: ' + e.getMessage());
            }
        }
        firstRun = false;
        For (cms__Attribute__c attr:scope){
            if ((attr.cms__Value__c != null && attr.cms__Value__c.indexOf('players.brightcove') > -1) || (attr.cms__Simple_Value__c != null && attr.cms__Simple_Value__c.indexOf('players.brightcove') > -1)) {
                // brightcove player found.
                // isolate the player code(s)
                String[] playerCodes = new String[]{};
                String bodyText = attr.cms__Value__c != null ? attr.cms__Value__c : attr.cms__Simple_Value__c;
                Boolean endOfBody = false;
                Integer oldStartIdx;
                Integer startIdx = bodyText.indexOf('players.brightcove');
                Integer startVideoIdx;
                Integer srcStartIdx;

                while (startIdx > -1) {
                    startVideoIdx = bodyText.indexOf('videoId', startIdx);
                    srcStartIdx = bodyText.lastIndexOf('src=',startIdx);
                    if (srcStartIdx == -1 || (startIdx - srcStartIdx > 14)){
                        srcStartIdx = bodyText.lastIndexOf('https://',startIdx);
                        if (srcStartIdx == -1 || (startIdx - srcStartIdx > 8)){
                            srcStartIdx = bodyText.lastIndexOf('http://', startIdx);
                            if (srcStartIdx == -1 || (startIdx - srcStartIdx > 7) ){
                                srcStartIdx = bodyText.lastIndexOf('//', startIdx);
                                if (srcStartIdx == -1 || (startIdx - srcStartIdx > 2)){
                                    //this brightcove player text is not in a recognizable url format
                                    srcStartIdx = startIdx;
                                }
                            }
                        }
                    }
                    //assumption: videoId will be within 70 characters of players.brightcove text
                    if (startVideoIdx > -1 && (startVideoIdx-startIdx < 70)){
                        String chkURL = bodyText.substring(srcStartIdx,startVideoIdx + 21);
                        String srcUrl;
                        //trim the src=" from the string if present.
                        if (chkURL.indexOf('src="') >= 0){
                            srcUrl = chkURL.substring(chkURL.indexOf('src="') + 5);
                        } else{
                            srcUrl = chkURL;
                        }
                        playerCodes.add(srcUrl);
                    }
                    oldStartIdx = startIdx;
                    startIdx = bodyText.indexOf('players.brightcove', oldStartIdx + 1 );
                }

                // if playerCodes is empty (seize = 0), create a blank entry.
                if (playerCodes.size() == 0) {
                  playerCodes.add('');
                }
                // build the csv record
                // add 1 row for each player code occurring in the body
                for (Integer i=0,j=playerCodes.size(); i<j; i++){
                    csvFileString += attr.id + ',';
                    csvFileString += attr.cms__Content__c != null ? attr.cms__Content__c + ',' : ',';
                    csvFileString += attr.cms__Content__r.cms__Version_Origin__c != null ? attr.cms__Content__r.cms__Version_Origin__c + ',' : attr.cms__Content__c != null ? attr.cms__Content__c + ',' : ',';
                    csvFileString += attr.cms__Content__r.cms__Name__c != null ? attr.cms__Content__r.cms__Name__c.escapeCsv() + ',' : ',';
                    csvFileString += attr.cms__Content__r.cms__Content_Type__r.cms__Name__c != null ? attr.cms__Content__r.cms__Content_Type__r.cms__Name__c.escapeCsv() + ',' : ',';
                    csvFileString += attr.cms__Content__r.cms__Version_Number__c.setScale(0) + '.' + attr.cms__Content__r.cms__Revision_Number__c.setScale(0) + ',';
                    csvFileString += attr.cms__Content__r.cms__Original_Published_Start_Date__c != null ? attr.cms__Content__r.cms__Original_Published_Start_Date__c + ',' : ',';
                    csvFileString += attr.cms__Content__r.cms__Am_Latest_Preview__c != null ? attr.cms__Content__r.cms__Am_Latest_Preview__c + ',' : ',';
                    csvFileString += attr.cms__Content__r.cms__Am_Latest_Published__c != null ? attr.cms__Content__r.cms__Am_Latest_Published__c + ',' : ',';
                    csvFileString += attr.lastModifiedBy.Name != null ? attr.lastModifiedBy.Name + ',' : ',';
                    csvFileString += attr.cms__Language__r.Name != null ? attr.cms__Language__r.Name.escapeCsv() + ',' : ',';
                    csvFileString += attr.cms__Simple_Name__c != null ? attr.cms__Simple_Name__c.escapeCsv() + ',' : ',' ;
                    csvFileString += attr.cms__Type__c != null ? attr.cms__Type__c.escapeCsv() + ',' : ',';
//                    csvFileString += attr.cms__Value__c != null ? attr.cms__Value__c.escapeCsv() + ',' : ',';
//                System.debug('contentType: ' + attr.cms__Content__r.cms__Content_Type__r.cms__Name__c);
                    if (attr.cms__Content__r.cms__Content_Type__r.cms__Name__c != null && detailURL !=null && detailURL.containsKey(attr.cms__Content__r.cms__Content_Type__r.cms__Name__c)) {
                        String baseURL = detailURL.get(attr.cms__Content__r.cms__Content_Type__r.cms__Name__c).escapeCsv();
                        csvFileString += baseURL != null ? baseURL + attr.cms__Content__c + ',' : ',';
                        system.debug('detail url: ' + baseURL + attr.cms__Content__c);
                    } else {
                        csvFileString += ',';
                    }
                    csvFileString += playerCodes[i];
                    csvFileString += '\n';
                }
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
            csvFileString = 'No Records Found';
        }
        //create attachment
        Blob bodyBlob = Blob.valueOf(csvFileString);
        Attachment csvFile = new Attachment(Name = 'Attribute_Records_With_Video_Embed.csv',body = bodyBlob, parentId=mfcCo.Id);
        insert csvFile;
    }
}