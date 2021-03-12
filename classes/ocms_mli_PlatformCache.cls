public with sharing class ocms_mli_PlatformCache {
	public ocms_mli_PlatformCache() {}

	// Keys must be alphanumeric only - regex [a-zA-Z0-9]+
	public Static final String KEY_SEPARATOR = '0';

	public Static final String CACHE_KEY = 'ocms';
	public Static final String SAL_KEY_PREFIX = 'SAL' + KEY_SEPARATOR;

	public static void setSALKey(String contentType, String contentLayout, String primaryPath, String secondaryPath, List<String> idList) {
		orgCache.put(generateSALKey(contentType, contentLayout, primaryPath, secondaryPath), idList);
	}

	public static List<String> getSALKey(String contentType, String contentLayout, String primaryPath, String secondaryPath) {
		String key = generateSALKey(contentType, contentLayout, primaryPath, secondaryPath);
		if(orgCache.contains(key)) {
			return (List<String>)orgCache.get(key);
		} else {
			return null;
		}
	}

	private static String generateSALKey(String contentType, String contentLayout, String primaryPath, String secondaryPath) {
		// Key length must be <= 50 characters. base64 MD5 hash is 32 characters, leaving room for an 18-character prefix
		String prefix = generateSALKeyPrefix(contentType);
		Blob postfixHash = Crypto.generateDigest('MD5', Blob.valueOf(contentLayout + KEY_SEPARATOR + primaryPath + KEY_SEPARATOR + secondaryPath));
		String fullKey = prefix + EncodingUtil.base64Encode(postfixHash);
		return fullKey.replaceAll('[^A-Za-z0-9]', '');
	}

	private static String generateSALKeyPrefix(String contentType) {
		return SAL_KEY_PREFIX + contentType + KEY_SEPARATOR;
	}

	public static void resetSALKeys(String contentType) {
		String prefix = generateSALKeyPrefix(contentType);

		for(String key : orgCache.getKeys()) {
			if(key.startsWith(prefix)) {
				// There seems to be an issue with removing keys.. set to an empty list first
				orgCache.put(key, new String[]{});
				orgCache.remove(key);
			}
		}
	}

	public static Cache.OrgPartition orgCache {
		get {
			if (orgCache == null) {
				orgCache = Cache.Org.getPartition(CACHE_KEY);
			}

			return orgCache;
		} set;
	}
}