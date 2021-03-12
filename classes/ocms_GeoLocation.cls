//TODO: rename this to `ocms_mli_GeoLocation.cls`
global with sharing class ocms_GeoLocation implements cms.ServiceInterface, Database.AllowsCallouts {
	private static final String endpoint;
	private static final String mockCountryIPResponse;

	static {
		endpoint = 'https://geoip.maxmind.com/geoip/v2.1/country/';
		mockCountryIPResponse = '{"country":{"iso_code":"US","names":{"pt-BR":"Estados Unidos","es":"Estados Unidos","ru":"Сша","en":"United States","zh-CN":"美国","fr":"États-Unis","de":"USA","ja":"アメリカ合衆国"},"geoname_id":6252001},"continent":{"names":{"pt-BR":"América do Norte","es":"Norteamérica","ru":"Северная Америка","en":"North America","zh-CN":"北美洲","fr":"Amérique du Nord","de":"Nordamerika","ja":"北アメリカ"},"geoname_id":6255149,"code":"NA"},"maxmind":{"queries_remaining":1000},"registered_country":{"iso_code":"US","names":{"pt-BR":"Estados Unidos","es":"Estados Unidos","ru":"Сша","en":"United States","zh-CN":"美国","fr":"États-Unis","de":"USA","ja":"アメリカ合衆国"},"geoname_id":6252001},"traits":{"ip_address":"204.14.232.8"}}';
	}

	public static Type getType() {
		return ocms_GeoLocation.class;
	}

	public String executeRequest(Map<String, String> params) {
		String action = params.get('action');

		if(action == 'getCountryForIP') {
			Map<String, String> headers;
			if(ApexPages.currentPage() != null) {
				headers = ApexPages.currentPage().getHeaders();
			}
			return getCountryForIP(getUserIp(params, headers));
		}

		return '{"success":false,"message":"Unsupported action"}';
	}

	public static String getCountryForIP(String ip) {
		String userId, licenseKey;
		Boolean makeCallout = true;

		// We can't simulate VF's readOnly mode, so we fake it for tests by not touching the custom setting.
		// It would be nice if we could.
		if(!Test.isRunningTest()) {
			GeoIP_Settings__c settings = [select User_Id__c, License_Key__c, Make_Callouts__c from GeoIP_Settings__c where Name='MAXMIND'];

			userID = settings.User_Id__c;
			licenseKey = settings.License_Key__c;
			makeCallout = settings.Make_Callouts__c;
		}

		if(!makeCallout) {
			return '{"success":true,"data":' + mockCountryIPResponse + '}';
		} else {
			String credentials = userId + ':' + licenseKey;
			credentials = EncodingUtil.base64Encode(Blob.valueOf(credentials));

			HTTPRequest request = new HTTPRequest();
			request.setEndpoint(endpoint + ip);
			request.setCompressed(true);
			request.setMethod('GET');
			request.setHeader('Authorization', 'Basic ' + credentials);

			HTTP http = new HTTP();
			HTTPResponse response = http.send(request);

			if(response.getStatusCode() != 200) {
				String responseMessage = 'HTTP ' + response.getStatusCode() + ' : ' + response.getStatus();
				return '{"success":false,"message":' + JSON.serialize(responseMessage) + '}';
			}

			return '{"success":true,"data":' + response.getBody() + '}';
		}
	}

	@testVisible
	private static String getUserIp(Map<String, String> queryParams, Map<String, String> headers) {
		String ip = queryParams.get('ip');

		if(ip == null && headers != null) {

			ip = headers.get('Real-Client-IP');

            if(ip == null) {
                ip = headers.get('True-Client-IP');
            }

			if(ip == null) {
				ip = headers.get('X-Salesforce-SIP');
			}

			if(ip == null) {
				ip = headers.get('X-Forwarded-For');
			}

			// We're out of options here - hopefully we got the ip from somewhere!
		}

		return ip;
	}
}