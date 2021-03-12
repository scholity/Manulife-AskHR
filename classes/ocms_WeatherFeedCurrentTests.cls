@isTest
public with sharing class ocms_WeatherFeedCurrentTests {
	/* // not used now for Open Weather
	public static testmethod void testResolveCityNames() {
		Test.setMock(HTTPCalloutMock.class, new SearchCitySuccessMock());
		initSettings();
		initCities(false);

		Test.startTest();

		ocms_WeatherFeedCurrent weatherUpdateCurrent = new ocms_WeatherFeedCurrent();
		weatherUpdateCurrent.resolveCityNames();

		Test.stopTest();

		Weather_City__c city = [select Accuweather_Key__c from Weather_City__c limit 1];
		System.assertEquals('50011', city.Accuweather_Key__c, 'Should parse api key from json response');
	}

	public static testmethod void testSearchCityName() {
		Test.setMock(HTTPCalloutMock.class, new SearchCitySuccessMock());
		initSettings();

		Test.startTest();

		ocms_WeatherFeedCurrent weatherUpdateCurrent = new ocms_WeatherFeedCurrent();
		String response = weatherUpdateCurrent.searchCityName('ca', 'qc', 'Quebec');

		Test.stopTest();

		System.assertEquals(response, cityJsonResponse, 'searchCityName should return the response body');
	}

	public static testmethod void testExtractLocationKey() {
		initSettings();

		ocms_WeatherFeedCurrent weatherUpdateCurrent = new ocms_WeatherFeedCurrent();

		String key = weatherUpdateCurrent.extractLocationKey(cityJsonResponse);

		System.assertEquals('50011', key, 'extractLocationKey should extract a locations key from the response');
	}*/

	public static testmethod void testFetchCurrentConditions() {
		Test.setMock(HTTPCalloutMock.class, new FetchCurrentConditionsSuccessMock());
		initSettings();
		initCities(true);

		Weather_City__c city = [select Id from Weather_City__c limit 1];

		Test.startTest();

		ocms_WeatherFeedCurrent weatherUpdateCurrent = new ocms_WeatherFeedCurrent();
		weatherUpdateCurrent.fetchCurrentConditions();

		Test.stopTest();

		Feed_Data__c currentCondition;
		try {
			currentCondition = [select City_Id__c from Feed_Data__c where RecordTypeId = '01250000000E7pnAAC' limit 1];
		} catch(QueryException e) {
			System.assert(false, e.getMessage());
		}

		System.assertEquals(city.Id, currentCondition.City_Id__c, 'fetchCurrentConditions should set the city Id');
	}

	public static testmethod void testFetchCityCurrentConditions() {
		Test.setMock(HTTPCalloutMock.class, new FetchCurrentConditionsSuccessMock());
		initSettings();

		Test.startTest();

		ocms_WeatherFeedCurrent weatherUpdateCurrent = new ocms_WeatherFeedCurrent();
		String response = weatherUpdateCurrent.fetchCityCurrentConditions('6325494', 'imperial');

		System.assertEquals(conditionsJsonResponse, response, 'fetchCityCurrentConditions should return the response body');
	}

	public static testmethod void testParseCityCurrentConditions() {
		initSettings();

		ocms_WeatherFeedCurrent weatherUpdateCurrent = new ocms_WeatherFeedCurrent();
		Feed_Data__c condition = weatherUpdateCurrent.parseCityCurrentConditions(conditionsJsonResponse);

		Decimal temperatureO = -3.59;
		Decimal temperatureMax = -2.78;
		Decimal temperatureMin = -5;
		String weatherIcon = '04n';

		System.assertEquals(condition.Temperature_O__c, temperatureO, 'parseCityCurrentConditions should set temperature_c');
		System.assertEquals(condition.Temperature_Max__c, temperatureMax, 'parseCityCurrentConditions should set temperature_c');
		System.assertEquals(condition.Temperature_Min__c, temperatureMin, 'parseCityCurrentConditions should set temperature_c');
		System.assertEquals(condition.OpenWeather_Icon__c, weatherIcon, 'parseCityCurrentConditions should set weather_icon');
	}

	public class SearchCitySuccessMock implements HttpCalloutMock {
		public HTTPResponse respond(HTTPRequest req) {
			System.assertEquals('GET', req.getMethod(), 'HTTP request should use GET');

			// Fake success response
			HTTPResponse res = new HTTPResponse();
			res.setStatusCode(200);
			res.setHeader('Content-Type', 'application/json; charset=utf-8');
			res.setBody(cityJsonResponse);

			return res;
		}
	}

	public class FetchCurrentConditionsSuccessMock implements HttpCalloutMock {
		public HTTPResponse respond(HTTPRequest req) {
			System.assertEquals('GET', req.getMethod(), 'HTTP request should use GET');

			// Fake success response
			HTTPResponse res = new HTTPResponse();
			res.setStatusCode(200);
			res.setHeader('Content-Type', 'application/json; charset=utf-8');
			res.setBody(conditionsJsonResponse);

			return res;
		}
	}

	public static void initSettings() {
		Weather_Settings__c settings = new Weather_Settings__c(
			Name            = 'settings name',
			API_Endpoint__c = 'endp',
			API_Key__c      = 'apiKey'
		);

		insert settings;
	}

	public static void initCities(Boolean includeKey) {
		String key = '';
		if(includeKey) key = '6325494';

		Weather_City__c city = new Weather_City__c(
			Name               = 'Quebec City',
			City_Name__c       = 'Quebec',
			OpenWeather_Key__c = key,
			Admin_Code__c      = 'qc',
			Country_Code__c    = 'ca',
			Temperature_Unit__c= 'C'
		);

		insert city;
	}

	static String cityJsonResponse;
	static String conditionsJsonResponse;

	static {
		cityJsonResponse = '';
		cityJsonResponse += '[  ';
		cityJsonResponse += '   {  ';
		cityJsonResponse += '      "Version":1,';
		cityJsonResponse += '      "Key":"50011",';
		cityJsonResponse += '      "Type":"City",';
		cityJsonResponse += '      "Rank":41,';
		cityJsonResponse += '      "LocalizedName":"Quebec",';
		cityJsonResponse += '      "EnglishName":"Quebec",';
		cityJsonResponse += '      "PrimaryPostalCode":"G1R",';
		cityJsonResponse += '      "Region":{  ';
		cityJsonResponse += '         "ID":"NAM",';
		cityJsonResponse += '         "LocalizedName":"North America",';
		cityJsonResponse += '         "EnglishName":"North America"';
		cityJsonResponse += '      },';
		cityJsonResponse += '      "Country":{  ';
		cityJsonResponse += '         "ID":"CA",';
		cityJsonResponse += '         "LocalizedName":"Canada",';
		cityJsonResponse += '         "EnglishName":"Canada"';
		cityJsonResponse += '      },';
		cityJsonResponse += '      "AdministrativeArea":{  ';
		cityJsonResponse += '         "ID":"QC",';
		cityJsonResponse += '         "LocalizedName":"Quebec",';
		cityJsonResponse += '         "EnglishName":"Quebec",';
		cityJsonResponse += '         "Level":1,';
		cityJsonResponse += '         "LocalizedType":"Province",';
		cityJsonResponse += '         "EnglishType":"Province",';
		cityJsonResponse += '         "CountryID":"CA"';
		cityJsonResponse += '      },';
		cityJsonResponse += '      "TimeZone":{  ';
		cityJsonResponse += '         "Code":"EDT",';
		cityJsonResponse += '         "Name":"America/Montreal",';
		cityJsonResponse += '         "GmtOffset":-4.0,';
		cityJsonResponse += '         "IsDaylightSaving":true,';
		cityJsonResponse += '         "NextOffsetChange":"2015-11-01T06:00:00Z"';
		cityJsonResponse += '      },';
		cityJsonResponse += '      "GeoPosition":{  ';
		cityJsonResponse += '         "Latitude":46.81,';
		cityJsonResponse += '         "Longitude":-71.22,';
		cityJsonResponse += '         "Elevation":{  ';
		cityJsonResponse += '            "Metric":{  ';
		cityJsonResponse += '               "Value":5.0,';
		cityJsonResponse += '               "Unit":"m",';
		cityJsonResponse += '               "UnitType":5';
		cityJsonResponse += '            },';
		cityJsonResponse += '            "Imperial":{  ';
		cityJsonResponse += '               "Value":16.0,';
		cityJsonResponse += '               "Unit":"ft",';
		cityJsonResponse += '               "UnitType":0';
		cityJsonResponse += '            }';
		cityJsonResponse += '         }';
		cityJsonResponse += '      },';
		cityJsonResponse += '      "IsAlias":false,';
		cityJsonResponse += '      "SupplementalAdminAreas":[  ';
		cityJsonResponse += '         {  ';
		cityJsonResponse += '            "Level":2,';
		cityJsonResponse += '            "LocalizedName":"Quebec",';
		cityJsonResponse += '            "EnglishName":"Quebec"';
		cityJsonResponse += '         }';
		cityJsonResponse += '      ]';
		cityJsonResponse += '   }';
		cityJsonResponse += ']';

		conditionsJsonResponse = '';
		conditionsJsonResponse += '{';
		conditionsJsonResponse += '	"coord": {';
		conditionsJsonResponse += ' 	"lon": -71.21,';
		conditionsJsonResponse += '   "lat": 46.81';
		conditionsJsonResponse += ' },';
		conditionsJsonResponse += ' "weather": [{';
		conditionsJsonResponse += ' 	"id": 804,';
		conditionsJsonResponse += '   "main": "Clouds",';
		conditionsJsonResponse += '   "description": "overcast clouds",';
		conditionsJsonResponse += '   "icon": "04n"';
		conditionsJsonResponse += ' }],';
		conditionsJsonResponse += ' "base": "stations",';
		conditionsJsonResponse += ' "main": {';
		conditionsJsonResponse += ' 	"temp": -3.59,';
		conditionsJsonResponse += '   "feels_like": -6.96,';
		conditionsJsonResponse += '   "temp_min": -5,';
		conditionsJsonResponse += '   "temp_max": -2.78,';
		conditionsJsonResponse += '   "pressure": 1007,';
		conditionsJsonResponse += '   "humidity": 86';
		conditionsJsonResponse += ' },';
		conditionsJsonResponse += ' "visibility": 14484,';
		conditionsJsonResponse += ' "dt": 1578519154,';
		conditionsJsonResponse += ' "sys": {';
		conditionsJsonResponse += ' 	"type": 1,';
		conditionsJsonResponse += '   "id": 879,';
		conditionsJsonResponse += '   "country": "CA",';
		conditionsJsonResponse += '   "sunrise": 1578486533,';
		conditionsJsonResponse += '   "sunset": 1578518004 ';
		conditionsJsonResponse += ' },';
		conditionsJsonResponse += ' "timezone": -18000,';
		conditionsJsonResponse += ' "id": 6325494,';
		conditionsJsonResponse += ' "name": "Quebec",';
		conditionsJsonResponse += ' "cod": 200';
		conditionsJsonResponse += '}';
	}
}