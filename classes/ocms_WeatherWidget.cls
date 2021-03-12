global virtual with sharing class ocms_WeatherWidget extends cms.ContentTemplateController {
	global ocms_WeatherWidget() { }

	global ocms_WeatherWidget(cms.CreateContentController cc) {
		super(cc);
	}

	global ocms_WeatherWidget(cms.GenerateContent gc) {
		super(gc);
	}

	global virtual override String getHTML() { return ''; }

	public String getMFCWeatherWidget() {
		Weather currentUserWeather = getCurrentWeatherForUser();
		String weatherWidgetHTML = '';

		if (currentUserWeather != null) {
			weatherWidgetHTML += '<div class="widget weather-widget">';
			weatherWidgetHTML += 	'<div class="inner">';
			weatherWidgetHTML += 		'<h3>' + this.title + '</h3>';
			weatherWidgetHTML += 		'<div class="widget-content">';
			weatherWidgetHTML += 			'<div class="v-align">';
			weatherWidgetHTML += 				'<div class="inner">';
			weatherWidgetHTML += 					'<div class="icon">';
			weatherWidgetHTML += 						'<img src="' + ocms_mfc_Utility.getResourceURL('ocms_mfc_siteFiles') + '/img/weather_icons/weather-icon-'+ currentUserWeather.icon +'.png"/>';
			weatherWidgetHTML +=					'</div>';
			weatherWidgetHTML += 					'<div class="temp">';
			weatherWidgetHTML += 						'<div class="t">';
			weatherWidgetHTML += 							'<span>' + currentUserWeather.currentTemp.round() +'°<sup>' + currentUserWeather.unit + '</sup></span>';
			weatherWidgetHTML += 						'</div>';
			weatherWidgetHTML +=            '<div class="b">';
			weatherWidgetHTML +=            	this.timeText + ' <span id="widget-weather-time">' + currentUserWeather.asOf.format('h:mm a') + '</span>';
			weatherWidgetHTML +=            '</div>';
			weatherWidgetHTML += 					'</div>';
			weatherWidgetHTML += 				'</div>';
			weatherWidgetHTML += 			'</div>';
			weatherWidgetHTML += 		'</div>';
			weatherWidgetHTML += 		'<footer class="widget-footer weather-footer">';
			weatherWidgetHTML += 			'<span>' + this.max + ' ' + currentUserWeather.maxTemp.round() + ' | ' +
																					 this.min + ' ' + currentUserWeather.minTemp.round() + '</span>';
			weatherWidgetHTML += 		'</footer>';
			weatherWidgetHTML += 	'</div>';
			weatherWidgetHTML += '</div>';
		}

		return weatherWidgetHTML;
	}

	/**
	 * @description Gets the current user City and attempts to find a weather city based off of that information.  This will
	 *              create a Weather object and resolve the data.
	 * @return Weather | null This will return a valid weather object or a null.  A null will be retured if we couldn't get valid information.
	 */
	public Weather getCurrentWeatherForUser() {
		String userId = UserInfo.getUserId();

		User currentUser = Database.query('SELECT City__c FROM User WHERE Id = :userId LIMIT 1');
		String userCityName = currentUser.City__c;
		List<Weather_City__c> weatherCity = Database.query('SELECT Id, Temperature_Unit__c FROM Weather_City__c WHERE City_Name__c = :userCityName LIMIT 1');

		Weather weatherObject = null;

		if (!weatherCity.isEmpty()) {
			RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType = 'Feed_Data__c' and Name = 'Weather Condition'];
			String recordTypeId = rt.Id;

			String weatherCityId = weatherCity[0].Id;
			Feed_Data__c currentWeatherCondition = Database.query('SELECT OpenWeather_Icon__c, LastModifiedDate, Temperature_O__c, Temperature_Max__c, Temperature_Min__c FROM Feed_Data__c WHERE City_Id__c = :weatherCityId AND RecordTypeId = :recordTypeId LIMIT 1');

			weatherObject = new Weather(currentWeatherCondition);
			weatherObject.unit = weatherCity[0].Temperature_Unit__c;
		}

		return weatherObject;
	}

	public class Weather {
		public Decimal currentTemp {get; set;}
		public Decimal maxTemp {get; set;}
		public Decimal minTemp {get; set;}
		public String unit {get; set;}
		public DateTime asOf {get; set;}
		public String icon {get; set;}

		private Feed_Data__c weatherCondition {get; set;}

		public Weather(Feed_Data__c weatherCondition) {
			this.weatherCondition = weatherCondition;
			this.icon = weatherCondition.OpenWeather_Icon__c;
			this.asOf = weatherCondition.LastModifiedDate;
			this.currentTemp = weatherCondition.Temperature_O__c;
			this.maxTemp = weatherCondition.Temperature_Max__c;
			this.minTemp = weatherCondition.Temperature_Min__c;
		}

		/**
		 * @description Gets the current feels like temperate based on the provided unit. If no unit was set it should have been
		 *              defaulted in the objects controller.
		 * @return The decimal value of the current feels like temperate for the user.
		 */
		public Decimal getFeelsLikeTemperature() {
			/*
			if (feelsLike == null) {
				if (unit == 'F') {
					feelsLike = weatherCondition.Feels_Like_F__c;
				} else {
					feelsLike = weatherCondition.Feels_Like_C__c;
				}

				feelsLike = feelsLike.round();
			}
			return feelsLike;*/

			return 0;
		}

		/**
		 * @description Gets the current temperate based on the provided unit. If no unit was set it should have been
		 *              defaulted in the objects controller.
		 * @return The decimal value of the current temperate for the user.
		 */
		public Decimal getCurrentTemperate() {
			/*
			if (currentTemp == null) {
				if (unit == 'F') {
					currentTemp = weatherCondition.Temperature_F__c;
				} else {
					currentTemp = weatherCondition.Temperature_C__c;
				}

				currentTemp = currentTemp.round();
			}*/

			return currentTemp;
		}
	}

	/** MFC Attributes */

	/**
	 * @description Attribute title
	 */
	public String title {
		get { return getProperty('title'); } set;
	}

	public String timeText {
		get { return getProperty('timeText'); } set;
	}
	/**
	 * @description Attribute max
	 */
	public String max {
		get { return getProperty('max'); } set;
	}
	/**
	 * @description Attribute min
	 */
	public String min {
		get { return getProperty('min'); } set;
	}

	/*
	public String timeText {
	    get { return getProperty('timeText');}set;
	}
	public String feelsLikeText {
	    get {return getProperty('feelsLikeText');}set;
	}*/
}