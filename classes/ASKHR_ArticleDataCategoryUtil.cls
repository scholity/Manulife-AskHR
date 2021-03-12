/**
* @author Mohamad Ammar Amran <mohamadammar_amran@manulife.com>
* @description Data category util for ArticleSearchController class
*/
public with sharing class ASKHR_ArticleDataCategoryUtil {
	private static final ASKHR_ArticleDataCategoryUtil INSTANCE = new ASKHR_ArticleDataCategoryUtil();
	private static final String NON_BREAKING_SPACE = '&nbsp;&nbsp;';

	//constructor
	private ASKHR_ArticleDataCategoryUtil() { }

	/**
	 *@description retrieves instance of ASKHR_ArticleDataCategoryUtil
	 *@return instance of ASKHR_ArticleDataCategoryUtil 
	 */
	public static ASKHR_ArticleDataCategoryUtil getInstance() { return INSTANCE; }

	/**
	 * @description Retrieves a List of DataCategoryGroupInfo of all the data category
	 * groups associated with Knowledge Article Version
	 * @return ASKHR_ArticleDataCategoryGroupInfo List of DataCategoryGroupInfo 
	 */
	public ASKHR_ArticleDataCategoryGroupInfo[] getAllCategoryGroups() {
		Describedatacategorygroupresult[] results = getDescribeDataCategoryGroupResults();
		ASKHR_ArticleDataCategoryGroupInfo[] dataCategoryGroups = new ASKHR_ArticleDataCategoryGroupInfo[] { };
		for (Describedatacategorygroupresult singleResult : results) {
			dataCategoryGroups.add(
			                       new ASKHR_ArticleDataCategoryGroupInfo(singleResult.getName(), singleResult.getLabel(),
			                                                              singleResult.getDescription(), getCategoryStructure(singleResult.getName())));
		}
		return dataCategoryGroups;
	}

	/**
	 * @description Retrieves a List of DataCategoryGroupInfo of all the data category
	 * groups associated with Knowledge Article Version
	 * @return Schema.DescribeDataCategoryGroup object 
	  containing the list of the category groups associated with Article type.
	 */

	private Describedatacategorygroupresult[] getDescribeDataCategoryGroupResults() {
		//String[] objTypes = new String[] {ARTICLE_TYPE};
		String[] objTypes = new String[] { ASKHR_Common.ARTICLE_TYPE };
		return Schema.describeDataCategoryGroups(objTypes);
	}
	/**
	 * @description Retrieves an ordered list of all Categories for the specified category group
	 * @param categoryGroupName Name of Category group
	 * @return ASKHR_ArticleDataCategoryInfo list of all categories
	 */
	private ASKHR_ArticleDataCategoryInfo[] getCategoryStructure(String categoryGroupName) {

		Describedatacategorygroupstructureresult structureResult = getDescribeDataCategoryGroupStructureResults(categoryGroupName);
		ASKHR_ArticleDataCategoryInfo[] allCategories = new ASKHR_ArticleDataCategoryInfo[] { };
		for (Integer i = 0; i < structureResult.getTopCategories().size(); i++)
		{
			DataCategory root = structureResult.getTopCategories() [i];
			DataCategory[] yetToBeProcessed = root.getChildCategories();
			allCategories.add(processCategory(root, ''));
			getAllCategories(yetToBeProcessed, allCategories, NON_BREAKING_SPACE); 
		}

		return allCategories;
	}
	/**
	 * @description 
	 * @param yetToBeProcessed 
	 * @param processed 
	 */
	private void getAllCategories(DataCategory[] yetToBeProcessed, ASKHR_ArticleDataCategoryInfo[] processed,
	                              String labelPrefix) {
		for (DataCategory category : yetToBeProcessed) {
			processed.add(processCategory(category, labelPrefix));
			getAllCategories(category.getChildCategories(), processed, labelPrefix + NON_BREAKING_SPACE);
		}
	}

	/**
	 * @description 
	 * @param category 
	 * @param labelPrefix 
	 */
	private ASKHR_ArticleDataCategoryInfo processCategory(DataCategory category, String labelPrefix) {
		return new ASKHR_ArticleDataCategoryInfo(category.getName(), category.getLabel(), labelPrefix +
		                                         category.getLabel());
	}

	//Commented: Not using the method suggested by SF as it doesn't work with limited DataCategory value
	/* private DataCategory getRootCategory(String categoryGroupName) {
	  Describedatacategorygroupstructureresult structureResult =
	  getDescribeDataCategoryGroupStructureResults(categoryGroupName);
	  return structureResult.getTopCategories()[0];
	  }*/

	/**
	 * @description 
	 * @param categoryGroupName 
	 */
	private Describedatacategorygroupstructureresult
	getDescribeDataCategoryGroupStructureResults(String categoryGroupName) {
		Datacategorygroupsobjecttypepair pair = new Datacategorygroupsobjecttypepair();
		//pair.setSobject(ARTICLE_TYPE);
		pair.setSObject(ASKHR_Common.ARTICLE_TYPE);
		pair.setDataCategoryGroupName(categoryGroupName);
		DescribeDataCategoryGroupStructureResult[] results = Schema.describeDataCategoryGroupStructures(new Datacategorygroupsobjecttypepair[]
		                                                                                                { pair }, false);

		return results[0];
	}

}