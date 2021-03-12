/**
 * Created by zhonxin on 2018-09-14.
 */

public with sharing class ocms_mli_ContentExportScheduable implements Schedulable {
    private String jobName;

    public ocms_mli_ContentExportScheduable() {
        jobName = 'Export MLI Blog Content';
    }

    public ocms_mli_ContentExportScheduable(String jobName) {
        this.jobName = jobName;
    }

    public class ocms_mli_ContentExportException extends Exception {}

    public void execute(SchedulableContext sc) {
        Set<String> allContentID = new Set<String>();

        allContentID = getContentIDWithTaxonomy(allContentID, '/Brand/Category/Knowledge');
        allContentID = getContentIDWithTaxonomy(allContentID, '/Brand/Category/Community');
        allContentID = getContentIDWithTaxonomy(allContentID, '/Brand/Category/Wealth/Finance');
        allContentID = getContentIDWithTaxonomy(allContentID, '/Brand/Category/Health/Wellness');
        allContentID = getContentIDWithTaxonomy(allContentID, '/Brand/Category/Lifestyle/Culture');

        ContentVersion conVer = new ContentVersion();
        conVer.ContentLocation = 'S'; // S specify this document is in SF, use E for external files
        conVer.PathOnClient = 'MLI_Blog_Export_' + Datetime.now() + '.json'; // The files name, extension is very important here which will help the file in preview.
        conVer.Title = 'MLI Blog Export: ' + Datetime.now(); // Display name of the files
        conVer.VersionData = Blob.valueOf('MLI Blog Export' + Datetime.now() + '\n'); // converting your binary string to Blog
        conVer.IsMajorVersion = false;
        insert conVer;

        List<String> tenContentIds = new List<String>();

        for (String eachContentID : allContentID) {
            tenContentIds.add(eachContentID);
            if (tenContentIds.size() < 10) {
                continue;
            }
            ocms_mli_content_export_batch exportBatch = new ocms_mli_content_export_batch(tenContentIds.clone(), conVer.Id);
            Database.executeBatch(exportBatch, 15);
            tenContentIds.clear();
        }

        if (tenContentIds.size() > 0) {
            ocms_mli_content_export_batch exportBatch = new ocms_mli_content_export_batch(tenContentIds.clone(), conVer.Id);
            Database.executeBatch(exportBatch, 10);
        }
    }

    private Set<String> getContentIDWithTaxonomy(Set<String> contentID, String taxonomy) {
        List<String> tagPaths = new List<String>();
        tagPaths.add(taxonomy);
        RenderingAPIRequest renderingRequest = new RenderingAPIRequest();
        renderingRequest.parameters.put('renderType', 'taxonomy');
        renderingRequest.listParameters.put('contentTypes', new List<String>{
                'MLIArticle'
        });
        renderingRequest.listParameters.put('tagPaths', tagPaths);

        List<String> layoutsForTaxonomy = new List<String>{
                'MLIArticleDetail'
        };
        renderingRequest.layoutsForTaxonomy = new List<List<String>>{
                layoutsForTaxonomy
        };

        Map<String, String> renderParams = new Map<String, String>();
        renderParams.put('renderingRequest', json.serialize(renderingRequest));
        renderParams.put('action', 'getRenderedContent');
        renderParams.put('service', 'OrchestraRenderingAPI');
        renderParams.put('sname', 'Manulife'); // Replace site_name with the name of your OrchestraCMS site
        renderParams.put('application', 'runtime');
        renderParams.put('apiVersion', '5.0');

        String renderResponse = cms.ServiceEndpoint.doActionApex(renderParams);
        JSONMessage.APIResponse renderAPIResponse = (JSONMessage.APIResponse) json.deserialize(renderResponse, JSONMessage.APIResponse.class);

        if (!renderAPIResponse.isSuccess)
            throw new ocms_mli_ContentExportException('OCMS: Could not retrieve renderings for this node');

        if (renderAPIResponse.type != 'RenderResultBundle')
            throw new ocms_mli_ContentExportException('OCMS: Unexpected result from Rendering API');

        RenderResultBundle renderResultBundle = (RenderResultBundle) json.deserialize(renderAPIResponse.responseObject, RenderResultBundle.class);
        for (RenderResultBundle.RenderedContent renderedContent : renderResultBundle.renderings) {
            contentID.add(renderedContent.contentId);
        }

        return contentID;
    }
}