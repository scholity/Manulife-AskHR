public with sharing class AskHR_CoveoUtill {
    
    public String getUserFilter(){
        String retval = '';
        List<String> expressions = new List<String>();
        
        String visibleDataCategories = resolveProfileCategoryGroupVisibility('Topic');
        
        SYSTEM.DEBUG('visibleDataCategories=='+visibleDataCategories);
        // Secure KB Articles using Data Categories
        if (String.isNotEmpty(visibleDataCategories)){
            //expressions.add('(NOT @sfkbid OR (@sfdctopic==('+ visibleDataCategories + ')))');
            expressions.add('(NOT @sfkbid OR (@sfdatacategorytopic==('+ visibleDataCategories + ')))');
        }
        //Data Category Geography
        String visibleDataCategoriesGeo = resolveProfileCategoryGroupVisibility('Geography');
        SYSTEM.DEBUG('visibleDataCategoriesGeo=='+visibleDataCategoriesGeo);
        // Secure KB Articles using Data Categories
        if (String.isNotEmpty(visibleDataCategoriesGeo)){
            
            //expressions.add('(NOT @sfkbid OR (@sfdcgeography==('+ visibleDataCategoriesGeo + ')))');
            expressions.add('(NOT @sfkbid OR (@sfdatacategorygeography==('+ visibleDataCategoriesGeo + ')))');
            
        }
        system.debug('expressions == '+expressions);
        
        // Add other expressions here if needed…
        
        retval = string.join(expressions, ' AND ');
        system.debug('retval=='+retval);
        
        return retval;
    }
    
    private static DataCategory[] getAllCategories(DataCategory [] categories){
        if(categories.isEmpty()){
            return new DataCategory[]{};
                } else {
                    DataCategory [] categoriesClone = categories.clone();
                    DataCategory category = categoriesClone[0];
                    //system.debug('recursive ---> ' + category.getLabel());
                    DataCategory[] allCategories = new DataCategory[]{category};
                        categoriesClone.remove(0);
                    categoriesClone.addAll(category.getChildCategories());
                    allCategories.addAll(getAllCategories(categoriesClone));
                    return allCategories;
                }
    }
    
    public static String resolveProfileCategoryGroupVisibility(String categoryname) {
        String visibleDataCategories = '';        
        List<String> visibleDataCategoriesList = new List<String>();
        List <DataCategoryGroupSobjectTypePair> pairs = new List<DataCategoryGroupSobjectTypePair>();
        DataCategoryGroupSobjectTypePair pair1 = new DataCategoryGroupSobjectTypePair();
        pair1.setSobject('KnowledgeArticleVersion');
        pair1.setDataCategoryGroupName(categoryname);
        pairs.add(pair1);
        
        List<Schema.DescribeDataCategoryGroupStructureResult>results = Schema.describeDataCategoryGroupStructures(pairs, false);
        for(Schema.DescribeDataCategoryGroupStructureResult r : results){
            Schema.DataCategory[] topCategories = r.getTopCategories();
            //Recursively get all the categories
            List<DataCategory> allCategories = getAllCategories(topCategories);
            for(DataCategory category : allCategories) {
                DataCategory [] childCategories = category.getChildCategories();
                System.debug('category='+category.getLabel());
                visibleDataCategoriesList.add('"'+category.getLabel()+'"');    
            }
        }
        visibleDataCategories = string.join(visibleDataCategoriesList, ',');  
        System.debug('visibleDataCategories='+visibleDataCategories);
        return visibleDataCategories;
    }
    
}