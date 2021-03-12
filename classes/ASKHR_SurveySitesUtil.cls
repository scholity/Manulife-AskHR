/**
 *@description ASKHR Survey sites Utility class
*/
public with sharing class ASKHR_SurveySitesUtil {

    

    public Boolean hasSites() {
        return Schema.getGlobalDescribe().keySet().contains('site');
    }
    
    public List<SurveySiteInfo> getSiteList() {
        
        List<SurveySiteInfo> ret = new List<SurveySiteInfo>();
        
        if (!hasSites()) {
            return ret;
        }
        
        List<Sobject> sitesResults = Database.query('Select Name, Subdomain, UrlPathPrefix from Site Where Status = \'Active\'');
                
        for (Sobject current : sitesResults) {
            ret.add(new SurveySiteInfo((String)current.get('Name'), (String)current.get('UrlPathPrefix'), (String)current.get('Subdomain')));
        }
        
        return ret;
        
    }
    
    public class SurveySiteInfo {
        public String name { get; set; }
        public String prefix { get; set; }
        public String subdomain {get; set; }
        
        public SurveySiteInfo(String name, String prefix, String subdomain) {
            this.name = name;
            this.prefix = prefix;
            this.subdomain = subdomain;
        }
    }
    
    static testmethod void testSurveySiteInfo() {
        ASKHR_SurveySitesUtil.SurveySiteInfo info = new ASKHR_SurveySitesUtil.SurveySiteInfo('one', 'two', 'three');
        System.assertEquals(info.name, 'one');
        System.assertEquals(info.prefix, 'two');
        System.assertEquals(info.subdomain, 'three');
    }
    
    static testmethod void testHasSites() {
        ASKHR_SurveySitesUtil util = new ASKHR_SurveySitesUtil();
        
        if (Schema.getGlobalDescribe().keySet().contains('site')) {
            System.assert(util.hasSites());
        } else {
            System.assert(!util.hasSites());
        }
    }
    
    static testmethod void testGetInfo() {
        ASKHR_SurveySitesUtil util = new ASKHR_SurveySitesUtil();
        System.assert(util.getSiteList() != null);
        if (util.hasSites()) {
            if (util.getSiteList().size() > 0) {
                ASKHR_SurveySitesUtil.SurveySiteInfo current = util.getSiteList()[0];
                System.assert(current != null);
            }
        }
    }
    
}