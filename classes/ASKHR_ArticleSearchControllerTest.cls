@isTest
public class ASKHR_ArticleSearchControllerTest {
    static testMethod void validateDataCategoryGroupInfo(){
        ASKHR_ArticleDataCategoryGroupInfo[] dataCategoryGroupInfo =
            ASKHR_ArticleDataCategoryUtil.getInstance().getAllCategoryGroups();
        ASKHR_ArticleSearchController vfSearchControllerObj = new ASKHR_ArticleSearchController();
        System.assertNotEquals(vfSearchControllerObj.getDataCategoryGroupInfoAsJSON(),null);
    }

    static testMethod void validateParameters(){
        ASKHR_ArticleSearchController vfSearchControllerObj = new ASKHR_ArticleSearchController();
        System.assertNotEquals(null, vfSearchControllerObj.mFeedbackRecordTypeId);
        System.assertNotEquals(null, vfSearchControllerObj.notFoundMessage);
        vfSearchControllerObj.refreshSearchResult();
        System.assertEquals(vfSearchControllerObj.getCurrentPageNumber(),1.0);
        vfSearchControllerObj.next();
        System.assertEquals(vfSearchControllerObj.getCurrentPageNumber(),1.0);
        System.assertEquals(vfSearchControllerObj.getNextRequired(),false);
    }
    
    static testMethod void validateURLParameters(){
        ApexPages.currentPage().getParameters().put('search', 'Testing Keyword');
        ApexPages.currentPage().getParameters().put('topic', 'Testing Topic');
        
        ASKHR_ArticleSearchController vfSearchControllerObj = new ASKHR_ArticleSearchController();
        system.assertEquals('Testing Keyword', vfSearchControllerObj.searchString);
        System.assertEquals('Testing Topic', vfSearchControllerObj.mTopicParam);
    }
    
    static testMethod void validateCategoryKeyword() {
        ASKHR_ArticleSearchController vfSearchControllerObj = new ASKHR_ArticleSearchController();
        ASKHR_ArticleDataCategoryGroupInfo[] categoryGroups = ASKHR_ArticleDataCategoryUtil.getInstance().getAllCategoryGroups();
        String categoryCondition = '';
        for (ASKHR_ArticleDataCategoryGroupInfo categoryGroup : categoryGroups) {
            //ApexPages.currentPage().getParameters().put('categoryType_'+categoryGroup.getName(),'All');
            vfSearchControllerObj.selectedTopic = 'All';
            vfSearchControllerObj.selectedGeography = 'All';
            if(categoryCondition==''){
                categoryCondition=categoryGroup.getName() + ':All';                
                
            }else {
                categoryCondition=categoryCondition + ',' +categoryGroup.getName() + ':All';
            }
        }
        System.assertEquals(categoryCondition, vfSearchControllerObj.getCategoryKeyword());
        
        vfSearchControllerObj.searchString = 'Test';
        vfSearchControllerObj.selectedTopic = '';
        vfSearchControllerObj.selectedGeography = 'All';
        System.assertNotEquals(null, vfSearchControllerObj.getCategoryKeyword());
                
    }
    
    static testMethod void validateCategoryKeywordBlankwithSearchString(){
         ASKHR_ArticleSearchController vfSearchControllerObj = new ASKHR_ArticleSearchController();
        //validate with search string
        vfSearchControllerObj.searchString = 'Test';        
        vfSearchControllerObj.selectedTopic = '';
        vfSearchControllerObj.selectedGeography = '';
        System.assertNotEquals(null, vfSearchControllerObj.getCategoryKeyword());
    }
    
    static testMethod void validateCategoryKeywordAllBlank(){
         ASKHR_ArticleSearchController vfSearchControllerObj = new ASKHR_ArticleSearchController();
        //validate all with blank value
        vfSearchControllerObj.searchString = '';
        vfSearchControllerObj.selectedTopic = '';
        vfSearchControllerObj.selectedGeography = '';
        System.assertEquals('', vfSearchControllerObj.getCategoryKeyword());        
    }
    
    static testMethod void validateGeneralFeedback(){
        ASKHR_ArticleSearchController vfSearchControllerObj = new ASKHR_ArticleSearchController();
        System.assertNotEquals(null,vfSearchControllerObj.mHasFAQ);
        vfSearchControllerObj.getGeneralFeedbacks();
        vfSearchControllerObj.initFeedback = true;
        System.assertNotEquals(null, vfSearchControllerObj.getGeneralFeedbacks());
        vfSearchControllerObj.refreshGeneralFaq();
    }
}