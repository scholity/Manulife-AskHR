/**
* @author Mohamad Ammar Amran <mohamadammar_amran@manulife.com>
* @description This class is part of ASKHR Article Search Controller
*/
public class ASKHR_ArticleDataCategoryGroupInfo {
    private String name;
    private String label;
    private String description;
    private ASKHR_ArticleDataCategoryInfo[] groupStructure;
    
    //Constructor
    public ASKHR_ArticleDataCategoryGroupInfo (String name, String label, String description,
                                               ASKHR_ArticleDataCategoryInfo[] structure) {
                                                   this.name = name;
                                                   this.label = label;
                                                   this.description = description;
                                                   this.groupStructure = structure;
    }
    /**
     * @description retrieves name
    */
    public String getName(){
        return this.name;
    }
    
    /**
     * @description retrieves label
    */
    public String getLabel(){
        return this.label;
    }
    
    /**
     * @description retrieves description
     */
    public String getDescription(){
        return this.description;
    }
    
    /**
     * @description retrieves group structure
    */
    public ASKHR_ArticleDataCategoryInfo[] getGroupStructure(){
        return this.groupStructure;
    }
}