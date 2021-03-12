@isTest
private class AskHR_CoveoUtillTest {
    @isTest static void testUserCore() {
        
        AskHR_CoveoUtill coveoClass = new AskHR_CoveoUtill();
        String filterExpression = coveoClass.getUserFilter();
    }
}