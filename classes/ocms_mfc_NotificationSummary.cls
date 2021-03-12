global with sharing class ocms_mfc_NotificationSummary extends ocms_mfc_Notification{
	global virtual override String getHTML() {
		return this.title;
	}
}