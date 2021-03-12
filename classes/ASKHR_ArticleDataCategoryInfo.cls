/**
* @author
* @description
*/

public class ASKHR_ArticleDataCategoryInfo {
    private String name;
    private String label;
    private String displayName;
    
    //Constructor
    public ASKHR_ArticleDataCategoryInfo(String name, String label, String displayName) {
        this.name = name;
        this.label = label;
        this.displayName = displayName;
    }
    
    /**
     * @description retrieves name
     * @param
     */
    public String getName() {
        return this.name;
    }
    
    /**
     * @description retrieves label
     * @param
     */
    public String getLabel() {
        return this.label;
    }
    
    /**
     * @description retrieves display name
     * @param
     */
    public String getDisplayName() {
        return this.displayName;
    }
}