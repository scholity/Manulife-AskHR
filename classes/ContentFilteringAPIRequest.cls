public with sharing class ContentFilteringAPIRequest extends APIRequest {
    // Status values
    public static final STRING PUBLISHED = 'published';
    public static final STRING UNPUBLISHED = 'unpublished';
    public static final STRING EXPIRED = 'expired';
    public static final STRING PENDING_APPROVAL = 'pendingApproval';
    public static final STRING LOCKED = 'locked';

    // List of Actions
    public static final String GET_CONTENT = 'getContent';

    // parameters allowed
    public static final String FILTERS = 'filters';
    public static final String LIMIT_BY = 'limit';
    public static final String OFFSET = 'offset';

    // List Parameters allowed
    public static final String ORDER_BY = 'order';

    public ContentFilteringAPIRequest() {
        super();
    }
}