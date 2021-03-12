global with sharing class ocms_mfc_WeatherWidget extends ocms_WeatherWidget {
	global override String getHTML() {
		return this.getMFCWeatherWidget();
	}
}