/**
 * Created by Joe Zhong on 2020-01-08.
 * This class converts all MC articles' taxonomies from old ones into new ones, and removing duplicated ones
 */

global with sharing class ocms_mfc_MCTaxonomyConvertSchedulable implements Schedulable {

    private String jobName;
    private Boolean rerun = false;

    public ocms_mfc_MCTaxonomyConvertSchedulable() {
        jobName = 'MFC Taxonomies conversion';
    }

    public ocms_mfc_MCTaxonomyConvertSchedulable(String jobName) {
        this.jobName = jobName;
    }

    public ocms_mfc_MCTaxonomyConvertSchedulable(Boolean rerun) {
        this.rerun = rerun;
    }

    global class ocms_mfc_MCTaxonomyConvertSchedulableException extends Exception {

    }

    public void execute(SchedulableContext sc) {
        // Remove current job
        if(sc != null) {
            String cronid = sc.getTriggerId();
            System.abortJob(cronid); //abort scheduled job and start a new one
        }

        convertArticle();
    }

    private void convertArticle() {

        MC_article_conv_data__c convData = [select count__c, max__c, master_tax_id__c, log_file_id__c from MC_article_conv_data__c];

        String MCArticleRootTaxonomyID = convData.master_tax_id__c;
        ContentVersion contentVersion = [SELECT VersionData FROM ContentVersion Where Id = :convData.log_file_id__c LIMIT 1 FOR UPDATE];
        Blob contents = contentVersion.VersionData;
        String msgToWrite = '';

        if (convData.count__c >= convData.max__c){
            msgToWrite = '------- Completed ! --------';
            contentVersion.VersionData = Blob.valueOf(contents.toString() + msgToWrite);
            update ContentVersion;
            return;
        }

        //Create a map of old to new conversion
        Map<String, String> taxonomyConversion = new Map<String, String>();
        taxonomyConversion.put('/Mission Control/Article/Optimization', '/Mission Control/Article/Portfolio optimization');
        taxonomyConversion.put('/Mission Control/Article/Efficiencies', '/Mission Control/Article/Expense efficiency');
        taxonomyConversion.put('/Mission Control/Article/Growth', '/Mission Control/Article/Accelerate growth');
        taxonomyConversion.put('/Mission Control/Article/Transformation', '/Mission Control/Article/Digital customer leader');
        taxonomyConversion.put('/Mission Control/Article/Team', '/Mission Control/Article/High performing team');
        taxonomyConversion.put('/Mission Control/Article/Values', '/Mission Control/Article/Do the right thing');
        taxonomyConversion.put('/Mission Control/Article/CostFit', '/Mission Control/Article/Expense efficiency');
        taxonomyConversion.put('/Mission Control/Article/Brand', '/Mission Control/Article/Digital customer leader');
        taxonomyConversion.put('/Mission Control/Article/Customer Obsession', '/Mission Control/Article/Obsess about customers');
        taxonomyConversion.put('/Mission Control/Article/Customer obsession', '/Mission Control/Article/Obsess about customers');

        Map<String, String> taxonomyToAttr = new Map<String, String>();
        taxonomyToAttr.put('/Mission Control/Article/Digital customer leader', 'digitalCustomerLeader');
        taxonomyToAttr.put('/Mission Control/Article/Portfolio optimization', 'portfolioOptimization');
        taxonomyToAttr.put('/Mission Control/Article/Accelerate growth', 'accelerateGrowth');
        taxonomyToAttr.put('/Mission Control/Article/Expense efficiency', 'expenseEfficiency');
        taxonomyToAttr.put('/Mission Control/Article/Obsess about customers', 'obsessAboutCustomers');
        taxonomyToAttr.put('/Mission Control/Article/High performing team', 'highPerformingTeam');
        taxonomyToAttr.put('/Mission Control/Article/Get it done together', 'getItDoneTogether');
        taxonomyToAttr.put('/Mission Control/Article/Do the right thing', 'doTheRightThing');
        taxonomyToAttr.put('/Mission Control/Article/Share your humanity', 'shareYourHumanity');
        taxonomyToAttr.put('/Mission Control/Article/Think big', 'thinkBig');
        taxonomyToAttr.put('/Mission Control/Article/Own it', 'ownIt');

        Map<String, String> newTags = new Map<String, String>();
        newTags.put('/Mission Control/Article/Digital customer leader', 'digital customer leader;');
        newTags.put('/Mission Control/Article/Portfolio optimization', 'portfolio optimization;');
        newTags.put('/Mission Control/Article/Accelerate growth', 'accelerate growth;');
        newTags.put('/Mission Control/Article/Expense efficiency', 'expense efficiency;');
        newTags.put('/Mission Control/Article/Obsess about customers', 'obsess about customers;');
        newTags.put('/Mission Control/Article/High performing team', 'high performing team;');
        newTags.put('/Mission Control/Article/Get it done together', 'get it done together;');
        newTags.put('/Mission Control/Article/Do the right thing', 'do the right thing;');
        newTags.put('/Mission Control/Article/Share your humanity', 'share your humanity;');
        newTags.put('/Mission Control/Article/Think big', 'think big;');
        newTags.put('/Mission Control/Article/Own it', 'own it;');

        List<MC_Article_ID__c> allArticleIDs = [SELECT contentID__c from MC_Article_ID__c];

        String contentID = allArticleIDs[Integer.valueOf(convData.count__c)].contentID__c;

        Integer currentCount = Integer.valueOf(convData.count__c);
        currentCount += 1;
        msgToWrite += 'Article No. ' + String.valueOf(currentCount) + ' out of ' + String.valueOf(convData.max__c) + '\n';


        msgToWrite += 'content ID: ' + contentID + '\n';
        convData.count__c += 1;
        update convData;

        try {
            List<MC_New_Taxonomy__c> allNewTaxonomies = [SELECT Tag__c, ID__c from MC_New_Taxonomy__c];
            Map<String, String> newTaxonomies = new Map<String, String>();

            for (MC_New_Taxonomy__c eachNewTaxonomies : allNewTaxonomies) {
                newTaxonomies.put(eachNewTaxonomies.Tag__c, eachNewTaxonomies.ID__c);
            }

            List<String> allLangCode = new List<String>{
                    'in', 'ja', 'zh_CN', 'fr', 'en_US'
            };

            // get content original ID and name
            cms__Content__c currentContent = [SELECT Id, cms__Version_Origin__c, cms__Name__c from cms__Content__c where Id = :contentID];
            msgToWrite += 'Content name: ' + currentContent.cms__Name__c + '\n';

            String contentCoid = currentContent.cms__Version_Origin__c;
            if (contentCoid == null) {
                contentCoid = contentID;
            }

            List<String> taxDefIds = new List<String>();

            List<String> oldTaxonomies = getL2TaxonomyFromContent(contentID, taxDefIds);
            msgToWrite += 'Old taxonomies: ' + oldTaxonomies + '\n';


            Set<String> renamedTaxonomies = new Set<String>();

            for (String oldTaxonomy : oldTaxonomies) {
                if (newTags.containsKey(oldTaxonomy)) {
                    renamedTaxonomies.add(oldTaxonomy);
                } else if (!taxonomyConversion.containsKey(oldTaxonomy)) {
                    msgToWrite += 'Unidentified old taxonomy: ' + oldTaxonomy + '\n';
                    msgToWrite += 'ContentID: ' + contentID + '\n';

                }
            }

            // put all taxonomies to add into a buffer
            Set<String> taxonomiesToAdd = new Set<String>();

            for (String oldTax : oldTaxonomies) {
                if (taxonomyConversion.containsKey(oldTax)) {
                    taxonomiesToAdd.add(taxonomyConversion.get(oldTax));
                }
            }

            taxonomiesToAdd.addAll(renamedTaxonomies);

            msgToWrite += 'New taxonomies: ' + taxonomiesToAdd + '\n';

            // Assemble the new values for Tags property
            List<String> newTaxDefIDs = new List<String>();
            String newTagsValue = '';
            for (String tax : taxonomiesToAdd) {
                newTaxDefIDs.add(newTaxonomies.get(tax));
                newTagsValue += newTags.get(tax);
            }

            if (newTagsValue.lastIndexOf(';') == newTagsValue.length() - 1)
                newTagsValue = newTagsValue.substringBeforeLast(';');

            // Get the current attribute and create a new version, using COID not the latest verison ID
            ContentBundle contentBundle = getContentBundle(contentCoid);
            Map<String, List<AttributeBundle.ContentAttribute>> contentAttributes = contentBundle.contentAttributes;

            // Remove old checked tags, add new ones, and replaces the old "Tags" attribute with new ones
            for (String lang : allLangCode) {
                if (contentAttributes.containsKey(lang)) {
                    List<AttributeBundle.ContentAttribute> attributes = contentAttributes.get(lang);
                    Integer i = 0;

                    // Works! This is how you "remove/delete" an attribute. First, use ContentBundle API. Then, set the value to
                    // an empty string, then publishing a new content using this content bundle it will automatically remove the
                    // attribute!
                    while (true) {
                        if (attributes != null && attributes[i].value.equalsIgnoreCase('checked') && !attributes[i].name.equalsIgnoreCase('Feature')) {
                            attributes[i].value = '';
                        }
                        if (lang == 'en_US' && attributes !=null && attributes[i].name.equalsIgnoreCase('Title'))
                            msgToWrite += 'Article title (en_US): ' + attributes[i].value + '\n';

                        i++;
                        if (i >= attributes.size())
                            break;
                    }

                    for (String taxToAdd : taxonomiesToAdd) {
                        AttributeBundle.ContentAttribute contentAttribute = new AttributeBundle.ContentAttribute();
                        contentAttribute.name = taxonomyToAttr.get(taxToAdd);
                        contentAttribute.value = 'checked';
                        contentAttribute.valueType = 'Text';
                        contentAttribute.languageCode = lang;
                        contentAttribute.simple = false;
                        attributes.add(contentAttribute);
                    }
                    for (AttributeBundle.ContentAttribute eachAttribute : attributes) {
                        if (eachAttribute.name.equalsIgnoreCase('Tags')) {
                            eachAttribute.value = newTagsValue;
                            break;
                        }
                    }
                }
            }

            ContentBundle newContentBundle = createNewVersion(contentBundle);
            String newContentID = newContentBundle.contentId;

            // remove the old taxonomy and add new one
            removeTaxonomiesFromContent(newContentID, MCArticleRootTaxonomyID, taxDefIds);
            addTaxonomiesToContent(newContentID, MCArticleRootTaxonomyID, newTaxDefIDs);

            // Publish content
            PublishNewContentQueue publishNewContentQueue = new PublishNewContentQueue(newContentID);
            System.enqueueJob(publishNewContentQueue);

            msgToWrite += '--- Success ---\n';
        } catch (Exception ex) {
            msgToWrite += '!!!*** FAILED ***!!!\n';
            msgToWrite += ex.getMessage() + '\n';
            msgToWrite += ex.getLineNumber() + '\n';
            msgToWrite += ex.getStackTraceString() + '\n';
        } finally {
            msgToWrite += '----------------------------------------------------------\n\n';
            contentVersion.VersionData = Blob.valueOf(contents.toString() + msgToWrite);
            update ContentVersion;

            Datetime now = System.now();
            Datetime nextRun = now.addMinutes(3);
            String newExpression = '0 ' + nextRun.minute() + ' ' + nextRun.hour() + ' * * ?';
            ocms_mfc_MCTaxonomyConvertSchedulable mcTaxonomyConvertSchedulable = new ocms_mfc_MCTaxonomyConvertSchedulable(jobName);
            System.schedule(jobName, newExpression, mcTaxonomyConvertSchedulable);
        }
    }

    /*** Support Functions ***/
    private List<String> getL2TaxonomyFromContent(String contentID, List<String> taxonomyDefIDs) {
        TaxonomyAPIRequest taxonomyRequest = new TaxonomyAPIRequest();

        taxonomyRequest.contentId = contentID;

        Map<String, String> parameters = new Map<String, String>();
        parameters.put('service', 'TaxonomyAPI');
        parameters.put('action', 'getTagsOnContent');
        parameters.put('taxonomyRequest', json.serialize(taxonomyRequest));
        parameters.put('sname', 'MFC_Employee_Community');
        parameters.put('apiVersion', '5.0');

        String response = cms.ServiceEndPoint.doActionApex(parameters);
        JSONMessage.APIResponse apiResponse = (JSONMessage.APIResponse) json.deserialize(response, JSONMessage.APIResponse.class);

        if (!apiResponse.isSuccess) {
            throw new ocms_mfc_MCTaxonomyConvertSchedulableException('Unable to get the tags for the content.');
        }
        if (apiResponse.type != 'List<TaxonomyBundle>') {
            throw new ocms_mfc_MCTaxonomyConvertSchedulableException('Unexpected result from Taxonomy API.');
        }

        List<TaxonomyBundle> taxonomyBundles = (List<TaxonomyBundle>) json.deserialize(apiResponse.responseObject, List<TaxonomyBundle>.class);
        List<String> oldTaxonomies = new List<String>();
        for (TaxonomyBundle taxonomyBundle : taxonomyBundles) {
            if (taxonomyBundle.depth == 2) {
                oldTaxonomies.add(taxonomyBundle.languageMapOfPaths.get('en_US'));
                taxonomyDefIDs.add(taxonomyBundle.tagDefinitionID);
            }
        }
        return oldTaxonomies;
    }

    private ContentBundle getContentBundle(String contentID) {
        ContentAPIRequest contentRequest = new ContentAPIRequest();
        contentRequest.objectId = contentID; // Replace objectId with the content origin ID

        Map<String, String> parameters = new Map<String, String>();
        parameters.put('sname', 'MFC_Employee_Community'); // Replace site_name with the name of your OrchestraCMS site
        parameters.put('service', 'ContentAPI');
        parameters.put('action', 'getContent');
        parameters.put('contentRequest', json.serialize(contentRequest));
        parameters.put('apiVersion', '5.0');

        String response = cms.ServiceEndpoint.doActionApex(parameters);

        JSONMessage.APIResponse apiResponse = (JSONMessage.APIResponse) json.deserialize(response, JSONMessage.APIResponse.class);

        ContentBundle contentBundle = (ContentBundle) json.deserialize(apiResponse.responseObject, ContentBundle.class);

        return contentBundle;
    }

    public ContentBundle createNewVersion(ContentBundle contentBundle) {
        ContentAPIRequest contentRequest = new ContentAPIRequest();
        contentRequest.bundle = contentBundle;
        contentRequest.requestFlags.put('lock', true);

        Map<String, String> parameters = new Map<String, String>();
        parameters.put('sname', 'MFC_Employee_Community'); // Replace site_name with the name of your OrchestraCMS site
        parameters.put('service', 'ContentAPI');
        parameters.put('action', 'newContentVersion');
        parameters.put('contentRequest', json.serialize(contentRequest));
        parameters.put('apiVersion', '5.0');


        String response = cms.ServiceEndpoint.doActionApex(parameters);
        JSONMessage.APIResponse apiResponse = (JSONMessage.APIResponse) json.deserialize(response, JSONMessage.APIResponse.class);

        if (!apiResponse.isSuccess) {
            throw new ocms_mfc_MCTaxonomyConvertSchedulableException('Could not retrieve information from the Content API');
        }
        if (apiResponse.type != 'ContentBundle') {
            throw new ocms_mfc_MCTaxonomyConvertSchedulableException('Unexpected result from Content API');
        }

        return (ContentBundle) json.deserialize(apiResponse.responseObject, ContentBundle.class);
    }


    private void removeTaxonomiesFromContent(String contentID, String taxonomyID, List<String> tagDefIDs) {
        TaxonomyAPIRequest taxonomyRequest = new TaxonomyAPIRequest();
        taxonomyRequest.parameters = new Map<String, String>{
                'taxonomy' => taxonomyID
        }; // Replace with your taxonomy Id
        taxonomyRequest.contentId = contentID; // Replace contentId with the content version Id

        taxonomyRequest.categories = new List<TaxonomyBundle>();
        for (String tagDefID : tagDefIDs) {
            TaxonomyBundle bundle = new TaxonomyBundle(); // Here we are simulating having already retrieved an actual existing TaxonomyBundle
            bundle.taxonomyID = taxonomyID;
            bundle.tagDefinitionID = tagDefID;
            bundle.depth = 2;
            taxonomyRequest.categories.add(bundle);
        }

        Map<String, String> parameters = new Map<String, String>();
        parameters.put('service', 'TaxonomyAPI');
        parameters.put('action', 'removeTagsFromContent');
        parameters.put('taxonomyRequest', json.serialize(taxonomyRequest));
        parameters.put('sname', 'MFC_Employee_Community'); // Replace site_name with the name of your OrchestraCMS site
        parameters.put('apiVersion', '5.0');

        String response = cms.ServiceEndPoint.doActionApex(parameters);

        JSONMessage.APIResponse apiResponse = (JSONMessage.APIResponse) json.deserialize(response, JSONMessage.APIResponse.class);

        if (!apiResponse.isSuccess) {
            throw new ocms_mfc_MCTaxonomyConvertSchedulableException('Unable to reomve the tag from the content.');
        }
        if (apiResponse.type != 'Message') {
            throw new ocms_mfc_MCTaxonomyConvertSchedulableException('Unexpected result from Taxonomy API.');
        }
    }

    private void addTaxonomiesToContent(String contentID, String taxonomyID, List<String> newTaxDefIDs) {
        TaxonomyAPIRequest taxonomyRequest = new TaxonomyAPIRequest();
        taxonomyRequest.parameters = new Map<String, String>{
                'taxonomy' => taxonomyID
        }; // Replace with your taxonomy Id
        taxonomyRequest.contentId = contentID; // Replace contentId with the content version Id

        taxonomyRequest.categories = new List<TaxonomyBundle>();

        for (String newTaxDefId : newTaxDefIDs) {
            TaxonomyBundle bundle = new TaxonomyBundle(); // Here we are simulating having already retrieved an actual existing TaxonomyBundle
            bundle.taxonomyID = taxonomyID;
            bundle.tagDefinitionID = newTaxDefId;
            bundle.depth = 2;
            taxonomyRequest.categories.add(bundle);
        }

        Map<String, String> parameters = new Map<String, String>();
        parameters.put('service', 'TaxonomyAPI');
        parameters.put('action', 'addTagsToContent');
        parameters.put('taxonomyRequest', json.serialize(taxonomyRequest));
        parameters.put('sname', 'MFC_Employee_Community'); // Replace site_name with the name of your OrchestraCMS site
        parameters.put('apiVersion', '5.0');

        String response = cms.ServiceEndPoint.doActionApex(parameters);

        JSONMessage.APIResponse apiResponse = (JSONMessage.APIResponse) json.deserialize(response, JSONMessage.APIResponse.class);

        if (!apiResponse.isSuccess) {
            throw new ocms_mfc_MCTaxonomyConvertSchedulableException('Unable to add the tags to the content.');
        }
        if (apiResponse.type != 'Message') {
            throw new ocms_mfc_MCTaxonomyConvertSchedulableException('Unexpected result from Taxonomy API.');
        }
    }

    private class PublishNewContentQueue implements Queueable{
        String contentID;
        public PublishNewContentQueue(String contentID){
            this.contentID = contentID;
        }

        public void execute(QueueableContext context) {
            publishContent(this.contentID);
        }

        private void publishContent(String contentID) {
            ContentAPIRequest contentRequest = new ContentAPIRequest();
            contentRequest.objectId = contentID; // Replace objectId with the content version ID

            Map<String, String> parameters = new Map<String, String>();
            parameters.put('sname', 'MFC_Employee_Community'); // Replace site_name with the name of your OrchestraCMS site
            parameters.put('service', 'ContentAPI');
            parameters.put('action', 'publishContent');
            parameters.put('contentRequest', json.serialize(contentRequest));
            parameters.put('apiVersion', '5.0');

            String response = cms.ServiceEndpoint.doActionApex(parameters);

            JSONMessage.APIResponse apiResponse = (JSONMessage.APIResponse) json.deserialize(response, JSONMessage.APIResponse.class);

            if (!apiResponse.isSuccess) {
                throw new ocms_mfc_MCTaxonomyConvertSchedulableException('Could not retrieve information from the Content API');
            }
            if (apiResponse.type != 'ContentBundle') {
                throw new ocms_mfc_MCTaxonomyConvertSchedulableException('Unexpected result from Content API');
            }
        }
    }
}