global with sharing class ocms_mfc_BookmarkControl  extends ocms_mfc_BookmarkContentServiceLayout  {

    global ocms_mfc_BookmarkControl() {}

    global ocms_mfc_BookmarkControl(cms.CreateContentController cmsCC) {
        super(cmsCC);
    }

    global ocms_mfc_BookmarkControl(cms.GenerateContent cmsGC) {
        super(cmsGC); 
    }

    global  override String getHTML () {
        return this.getBookmarkBarHTML();
    }
}