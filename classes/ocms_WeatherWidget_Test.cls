@isTest
public with sharing class ocms_WeatherWidget_Test {
	public static testMethod void testGetWeatherWidgetCelcius() {
		ocms_WeatherWidget_Test.createWeatherData();

		ocms_WeatherWidget WeatherController = new ocms_WeatherWidget();
		ocms_TestContentHelper tch = new ocms_TestContentHelper();

		User testUser = tch.createAndInsertUser(new Map<String, String>{
			'City' => 'Toronto',
			'Country' => 'Canada',
			'Username' => 'dai_tian@manulife.com.uat2.test'
		});

		System.runAs(testUser) {
			ocms_WeatherWidget.Weather WeatherObject = WeatherController.getCurrentWeatherForUser();
			String widgetMarkup = WeatherController.getMFCWeatherWidget();
		}
	}

	public static testMethod void testGetWeatherWidgetFahrenheit() {
		ocms_WeatherWidget_Test.createWeatherData();

		ocms_WeatherWidget WeatherController = new ocms_WeatherWidget();
		ocms_TestContentHelper tch = new ocms_TestContentHelper();

		User testUser = tch.createAndInsertUser(new Map<String, String>{
			'City' => 'Boston',
			'Country' => 'United States',
			'Username' => 'dai_tian@manulife.com.uat2.test'
		});

		System.runAs(testUser) {
			ocms_WeatherWidget.Weather WeatherObject = WeatherController.getCurrentWeatherForUser();
			String widgetMarkup = WeatherController.getMFCWeatherWidget();
		}
	}

	public static testMethod void testGetMFCProperties() {
		ocms_TestContentHelper tch = new ocms_TestContentHelper();
		List<Map<String,String>> attr_map = new List<Map<String, String>>();

		Map<String, String> am = new Map<String, String>();
		am.put('name', 'title');
		am.put('value', 'title');
		am.put('type', 'text');
		attr_map.add(am);

		am = new Map<String, String>();
		am.put('name', 'max');
		am.put('value', 'max');
		am.put('type', 'text');
		attr_map.add(am);

		am = new Map<String, String>();
		am.put('name', 'min');
		am.put('value', 'min');
		am.put('type', 'text');
		attr_map.add(am);

		tch.createContent(attr_map, 'Weather Widget');

		ocms_WeatherWidget WeatherController = new ocms_WeatherWidget(tch.gc);

		// Get the coverage on the getHTML base call.
		WeatherController.getHTML();

		System.assertEquals('title', WeatherController.title, 'Expected: title. Received: ' + WeatherController.title);
		System.assertEquals('max', WeatherController.max, 'Expected: max. Received: ' + WeatherController.max);
		System.assertEquals('min', WeatherController.min, 'Expected: min. Received: ' + WeatherController.min);
	}

	public static void createWeatherData() {

		RecordType rt = [select Id from RecordType where SObjectType = 'Feed_Data__c' and Name = 'Weather Condition'];

		Weather_City__c testWeatherCityToronto = new Weather_City__c();
		testWeatherCityToronto.Name = 'Toronto';
		testWeatherCityToronto.City_Name__c = 'Toronto';
		testWeatherCityToronto.Temperature_Unit__c = 'C';
		testWeatherCityToronto.Country_Code__c = 'ca';

		insert testWeatherCityToronto;

		Weather_City__c testWeatherCityBoston = new Weather_City__c();
		testWeatherCityBoston.Name = 'Boston';
		testWeatherCityBoston.City_Name__c = 'Boston';
		testWeatherCityBoston.Temperature_Unit__c = 'F';
		testWeatherCityBoston.Country_Code__c = 'us';

		insert testWeatherCityBoston;

		Feed_Data__c testWeatherConditionToronto = new Feed_Data__c();
		testWeatherConditionToronto.Temperature_O__c = -5.05;
		testWeatherConditionToronto.Temperature_Max__c = -2.05;
		testWeatherConditionToronto.Temperature_Min__c = -7.05;
		testWeatherConditionToronto.OpenWeather_Icon__c = '03d';
		testWeatherConditionToronto.City_Id__c = testWeatherCityToronto.Id;
		testWeatherConditionToronto.RecordTypeId = rt.Id;

		insert testWeatherConditionToronto;

		Feed_Data__c testWeatherConditionBoston = new Feed_Data__c();
		testWeatherConditionBoston.Temperature_O__c = 70.06;
		testWeatherConditionBoston.Temperature_Max__c = 77.06;
		testWeatherConditionBoston.Temperature_Min__c = 67.06;
		testWeatherConditionBoston.OpenWeather_Icon__c = '02d';
		testWeatherConditionBoston.City_Id__c = testWeatherCityBoston.Id;
		testWeatherConditionBoston.RecordTypeId = rt.Id;

		insert testWeatherConditionBoston;
	}
}