global without sharing class ocms_mfc_CalendarList extends ocms_mfc_Calendar {

	global override String getHTML () {
		return getListHtml ();
	}
}