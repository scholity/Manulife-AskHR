@isTest
public with sharing class ocms_GeoLocationTest {
	public static testmethod void testGetUserIp() {
		Map<String, String> paramsWithIp = new Map<String, String>{'ip' => 'param_ip'};
		Map<String, String> paramsWithoutIp = new Map<String, String>();

		Map<String, String> noHeaders = new Map<String, String>();
		Map<String, String> trueClientIp = new Map<String, String>{'True-Client-IP' => 'trueClientIp'};
		Map<String, String> xSalesforceSip = new Map<String, String>{'X-Salesforce-SIP' => 'xSalesforceSip'};
		Map<String, String> xForwardedFor = new Map<String, String>{'X-Forwarded-For' => 'xForwardedFor'};

		// Base test
		System.assertEquals(null, ocms_GeoLocation.getUserIp(paramsWithoutIp, null), 'User IP should be null when no information is passed');

		// HTTP headers
		System.assertEquals('trueClientIp', ocms_GeoLocation.getUserIp(paramsWithoutIp, trueClientIp), 'getUserIp should check the True-Client-IP header');
		System.assertEquals('xSalesforceSip', ocms_GeoLocation.getUserIp(paramsWithoutIp, xSalesforceSip), 'getUserIp should check the X-Salesforce-SIP header');
		System.assertEquals('xForwardedFor', ocms_GeoLocation.getUserIp(paramsWithoutIp, xForwardedFor), 'getUserIp should check the X-Forwarded-For header');

		// Passed IP takes precedence over headers
		System.assertEquals('param_ip', ocms_GeoLocation.getUserIp(paramsWithIp, trueClientIp), 'getUserIp should prefer a passed IP address over headers');
	}

	public static testmethod void testCountryIpSuccess() {
		Test.setMock(HTTPCalloutMock.class, new CountrySuccessMock());
		
		Test.startTest();

		System.assertEquals('{"success":true,"data":{"foo":"bar"}}', ocms_GeoLocation.getCountryForIP('ip'));

		Test.stopTest();
	}

	public static testmethod void testCountryIpFailure() {
		Test.setMock(HTTPCalloutMock.class, new CountryFailureMock());

		Test.startTest();

		System.assertNotEquals('{"success":true,"data"{"foo":"bar"}}', ocms_GeoLocation.getCountryForIP('ip'));

		Test.stopTest();
	}

	public class CountrySuccessMock implements HttpCalloutMock {
		public HTTPResponse respond(HTTPRequest req) {
			System.assertEquals('GET', req.getMethod(), 'HTTP request should use GET');

			// Fake success response
			HTTPResponse res = new HTTPResponse();
			res.setStatusCode(200);
			res.setHeader('Content-Type', 'application/json');
			res.setBody('{"foo":"bar"}');

			return res;
		}
	}

	public class CountryFailureMock implements HttpCalloutMock {
		public HTTPResponse respond(HTTPRequest req) {
			// Fake server error
			HTTPResponse res = new HTTPResponse();
			res.setStatusCode(500);

			return res;
		}
	}
}