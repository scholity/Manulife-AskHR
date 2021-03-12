public with sharing class ocms_WeatherFeedCurrent {
	private String endpointPrefix;
	private String key;

	public static final String recordTypeId;

	static {
		recordTypeId = Schema.SObjectType.Feed_Data__c.getRecordTypeInfosByName().get('Weather Condition').getRecordTypeId();
	}

	public ocms_WeatherFeedCurrent() {
		try {
			Weather_Settings__c settings = [select API_Endpoint__c, API_Key__c from Weather_Settings__c where Name = 'open_weather_settings'];

			endpointPrefix = settings.API_Endpoint__c;
			key = settings.API_Key__c;
		} catch(QueryException e) {
			endPointPrefix = 'http://api.openweathermap.org/data/2.5/weather';
			key = '';
		}
	}

	public void fetchCurrentConditions() {
		List<Weather_City__c> cities = [select Id, OpenWeather_Key__c, Country_Code__c, Temperature_Unit__c  from Weather_City__c];

		Map<String, String> responses = new Map<String, String>();

		for(Weather_City__c city : cities) {
			if(String.isBlank(city.OpenWeather_Key__c)) continue;

			responses.put(city.Id, fetchCityCurrentConditions(city.OpenWeather_Key__c, city.Temperature_Unit__c));
		}

		List<Feed_Data__c> oldConditions = [select Id from Feed_Data__c where RecordTypeId = :recordTypeId];
		delete oldConditions;

		List<Feed_Data__c> newConditions = new List<Feed_Data__c>();

		for(String cityId : responses.keySet()) {
			Feed_Data__c condition = parseCityCurrentConditions(responses.get(cityId));
			condition.City_Id__c = cityId;
			newConditions.add(condition);
		}

		insert newConditions;
	}

	public String fetchCityCurrentConditions(String cityKey, String units) {
		units = (units =='C')?'metric':'imperial';
		String endpoint = endpointPrefix + '?appid=' + key + '&id=' + cityKey + '&units=' + units;

		HTTPRequest feedRequest;
		HTTPResponse feedResponse;

		feedRequest = new HTTPRequest();
		feedRequest.setEndpoint(endpoint);
		feedRequest.setCompressed(true);
		feedRequest.setMethod('GET');

		HTTP http = new HTTP();
		feedResponse = http.send(feedRequest);

		return feedResponse.getBody();
	}

	public Feed_Data__c parseCityCurrentConditions(String jsonResponse) {
		Map<String, Object> responseObject = (Map<String,Object>)JSON.deserializeUntyped(jsonResponse);

		List<Object> weatherArray = (List<Object>)responseObject.get('weather');
		Map<String, Object> weather = (Map<String, Object>)weatherArray[0];
		Map<String, Object> main = (Map<String, Object>)responseObject.get('main');

		Feed_Data__c condition = new Feed_Data__c(
			OpenWeather_Icon__c  = (String)weather.get('icon'),
			Temperature_O__c = (Decimal)main.get('temp'),
			Temperature_Max__c  = (Decimal)main.get('temp_max'),
			Temperature_Min__c  = (Decimal)main.get('temp_min'),
			RecordTypeId     = recordTypeId
		);

		return condition;
	}

	/*not used now*/
	public void resolveCitynames() {
		List<Weather_City__c> cities = [select City_Name__c, Accuweather_Key__c, Admin_Code__c, Country_Code__c from Weather_City__c];

		for(Weather_City__c city : cities) {
			if(!String.isBlank(city.Accuweather_Key__c)) continue;

			String searchResult = searchCityName(city.Country_Code__c, city.Admin_Code__c, city.City_Name__c);
			System.debug(searchResult);
			city.Accuweather_Key__c = extractLocationKey(searchResult);
		}

		update cities;
	}
	public String searchCityName(String country, String admin, String name) {
		String endpoint = endpointPrefix + 'locations/v1/cities/' + country + '/';
		if(!String.isBlank(admin)) endpoint += admin + '/';
		endpoint += 'search.json?q=' + name + '&apikey=' + key;

		System.debug(endpoint);

		HTTPRequest feedRequest;
		HTTPResponse feedResponse;

		feedRequest = new HTTPRequest();
		feedRequest.setEndpoint(endpoint);
		feedRequest.setCompressed(true);
		feedRequest.setMethod('GET');

		HTTP http = new HTTP();
		feedResponse = http.send(feedRequest);

		return feedResponse.getBody();
	}
	public String extractLocationKey(String jsonResponse) {
		List<Object> results = (List<Object>)JSON.deserializeUntyped(jsonResponse);

		if(results.size() == 0) return '';

		Map<String, Object> firstResult = (Map<String, Object>)results[0];
		return (String)firstResult.get('Key');
	}
	/*not used now*/
}