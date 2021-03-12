public with sharing class FilteringAPIRequest extends APIRequest {

    //Actions
    public static final String GET_CONTENT_BY_NAME = 'getContentByName';
    public static final String GET_RECENT_PUBLISHED_CONTENT = 'getRecentlyPublishedContent';
    public static final String SEARCH_CONTENT = 'searchContent';
    //parameters
    public static final String LIMIT_COUNT = 'limit';
    public static final String OFFSET = 'offset';
    public static final String TERM = 'term';
    //listParams
    public static final String CONTENT_NAMES = 'contentNames';
    public static final String CONTENT_TYPES_AND_LAYOUTS = 'contentTypesAndLayouts';
    public static final String FILTER_GROUPS = 'filterGroups';
    public static final String ORDER_BY = 'order';
    //flags
    public static final String TAXONOMY = ContentAPIRequest.TAXONOMY;
    public static final String CONTENT_LAYOUTS = 'contentLayouts';
    public static final String CONTENT_TYPE = 'contentType';
    public static final String TARGETED = RenderingAPIRequest.TARGETED;


    // FilterType is just a set of well defined Strings that represent our filters
    public enum FilterType {
        Taxonomy, OriginalPublishedDate, PublishedDate
    }

    //Order of list of origins in contentOrdering
    public enum OrderType {
        Relevance, OriginalPublishedDate, PublishedDate
    }

    public FilteringAPIRequest() {
        super();
    }

}