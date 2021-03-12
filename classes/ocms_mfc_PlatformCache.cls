public with sharing class ocms_mfc_PlatformCache {
    
    public ocms_mfc_PlatformCache() {}

    public Static final String CACHE_KEY = 'ocms';
    public Static final String SESSION_NEWS_STREAM_CACHE_KEY = 'newsStream';
    public Static final String ORG_SITE_PREF_CACHE_KEY = 'MFCSitePreferences';
    public Static final String LAST_SEEN_KEY = 'latestSeenPublished';
    public Static final String LAST_PUBLISHED_KEY = 'latestPublished';

    public Boolean hasNewsStreamKey(String cacheKey) { 
        Boolean hasKey = false;

        if (sessionCache != null && sessionCache.contains(SESSION_NEWS_STREAM_CACHE_KEY)) {
            Map<String, Object> jsonUntyped = (Map<String, Object>) JSON.deserializeUntyped((String) sessionCache.get(SESSION_NEWS_STREAM_CACHE_KEY));

            if (jsonUntyped != null && jsonUntyped.get(cacheKey) != null) {
                hasKey = true;
            }
        }

        return hasKey;
    }

    public String getNewsStreamKey(String cacheKey) {
        String result = null;

        if (sessionCache != null && sessionCache.contains(SESSION_NEWS_STREAM_CACHE_KEY)) {
            Map<String, Object> jsonUntyped = (Map<String, Object>) JSON.deserializeUntyped((String) sessionCache.get(SESSION_NEWS_STREAM_CACHE_KEY));

            if (jsonUntyped != null && jsonUntyped.get(cacheKey) != null) {
                result = (String) jsonUntyped.get(cacheKey);
            }
        }

        return result;
    }

    public Boolean setNewsStreamKey(String key, String value) {
        Boolean success = true;
        Map<String, Object> jsonUntyped = new Map<String, Object>();

        if (sessionCache != null) {
            if (sessionCache.contains(SESSION_NEWS_STREAM_CACHE_KEY)) {
                jsonUntyped = (Map<String, Object>) JSON.deserializeUntyped((String) sessionCache.get(SESSION_NEWS_STREAM_CACHE_KEY));
                jsonUntyped.put(key, value);
            } else {
                jsonUntyped.put(key, (Object) value);
            }

            sessionCache.put(SESSION_NEWS_STREAM_CACHE_KEY, JSON.serialize(jsonUntyped));
        } else {
            success = false;
        }

        return success;
    }

    public void updateLastSeen() {
        if (sessionCache != null) {
            DateTime lastSeen = (DateTime)orgCache.get(LAST_PUBLISHED_KEY);
            if (lastSeen == null)
            {
                orgCache.put(LAST_PUBLISHED_KEY, System.now());
            }
            sessionCache.put(LAST_SEEN_KEY, (DateTime) orgCache.get(LAST_PUBLISHED_KEY));
        }
    }

    public static void removeNewsStreamCache() {
        try {
            Cache.SessionPartition ocmsSessionCache = Cache.Session.getPartition(CACHE_KEY);
            ocmsSessionCache.remove(SESSION_NEWS_STREAM_CACHE_KEY);
        } catch (Exception e) {

        }
    }

    public static void removeSitePreferencesCache() {
        try {
            Cache.OrgPartition ocmsOrgCache = Cache.Org.getPartition(CACHE_KEY);
            ocmsOrgCache.remove(ORG_SITE_PREF_CACHE_KEY);

            Cache.OrgPartition ocmsOrgPartition = Cache.Org.getPartition('ocms');
            ocmsOrgPartition.put('latestPublished', System.now());
        } catch (Exception e) {

        }
    }

    public Boolean hasSitePreferencesKey(String cacheKey) { 
        Boolean hasKey = false;

        if (orgCache != null && orgCache.contains(ORG_SITE_PREF_CACHE_KEY)) {
            Map<String, Object> jsonUntyped = (Map<String, Object>) JSON.deserializeUntyped((String) orgCache.get(ORG_SITE_PREF_CACHE_KEY));

            if (jsonUntyped != null && jsonUntyped.get(cacheKey) != null) {
                hasKey = true;
            }
        }

        return hasKey;
    }

    public String getSitePreferencesKey(String cacheKey) {
        String result = null;

        if (orgCache != null && orgCache.contains(ORG_SITE_PREF_CACHE_KEY)) {
            Map<String, Object> jsonUntyped = (Map<String, Object>) JSON.deserializeUntyped((String) orgCache.get(ORG_SITE_PREF_CACHE_KEY));

            if (jsonUntyped != null && jsonUntyped.get(cacheKey) != null) {
                result = (String) jsonUntyped.get(cacheKey);
            }
        }

        return result;
    }

    public Boolean setSitePreferencesKey(String key, String value) {
        Boolean success = true;
        Map<String, Object> jsonUntyped = new Map<String, Object>();

        if (orgCache != null) {
            if (orgCache.contains(ORG_SITE_PREF_CACHE_KEY)) {
                jsonUntyped = (Map<String, Object>) JSON.deserializeUntyped((String) orgCache.get(ORG_SITE_PREF_CACHE_KEY));
                jsonUntyped.put(key, value);
            } else {
                jsonUntyped.put(key, (Object) value);
            }

            orgCache.put(ORG_SITE_PREF_CACHE_KEY, JSON.serialize(jsonUntyped));
        } else {
            success = false;
        }

        return success;
    }

    public Boolean regenCache {
        get {
            try {
                if (regenCache == null) {
                    Map<String, Object> jsonUntyped = new Map<String, Object>();

                    if (sessionCache.contains(SESSION_NEWS_STREAM_CACHE_KEY)) {
                         jsonUntyped = (Map<String, Object>) JSON.deserializeUntyped((String) sessionCache.get(SESSION_NEWS_STREAM_CACHE_KEY));

                        // When we do the call to get the content for a users news stream we set the LAST_SEEN_KEY to be the same as the org cache LAST_PUBLISHED_KEY
                        // the org cache LAST_PUBLISHED_KEY gets set when content is saved.  Which forces any caches to be refreshed.
                        if ((DateTime) orgCache.get(LAST_PUBLISHED_KEY) == null || ((DateTime) orgCache.get(LAST_PUBLISHED_KEY) != (DateTime) sessionCache.get(LAST_SEEN_KEY))) {
                            sessionCache.remove(SESSION_NEWS_STREAM_CACHE_KEY);
                            
                            regenCache = true;
                        } else {
                            regenCache = false;
                        }
                    } else {
                        regenCache = true;
                    }
                }
            } catch (Exception e) {
                if (sessionCache != null && sessionCache.contains(SESSION_NEWS_STREAM_CACHE_KEY)) {
                    sessionCache.remove(SESSION_NEWS_STREAM_CACHE_KEY);
                }

                regenCache = true;
            }

            System.debug(regenCache);

            return regenCache;
        } set;
    }
    
    public Cache.SessionPartition sessionCache {
        get {
            if (sessionCache == null) {
                try {
                    sessionCache = Cache.Session.getPartition(CACHE_KEY);
                } catch (Exception e) {
                    System.debug(e);
                }
            }
            
            return sessionCache;
        } set;
    }

    public Cache.OrgPartition orgCache {
        get {
            if (orgCache == null) {
                try {
                    orgCache = Cache.Org.getPartition(CACHE_KEY);
                } catch (Exception e) {
                    System.debug(e);
                }
            }
            
            return orgCache;
        } set;
    }
}