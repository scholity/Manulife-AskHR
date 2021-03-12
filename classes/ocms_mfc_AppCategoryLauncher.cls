global without sharing class ocms_mfc_AppCategoryLauncher extends cms.ContentTemplateController {
	global ocms_mfc_AppCategoryLauncher() { }

	global ocms_mfc_AppCategoryLauncher(cms.GenerateContent gc) {
		super(gc);
	}

	global ocms_mfc_AppCategoryLauncher(cms.CreateContentController cc) {
		super(cc);
	}

	public Map<String, List<String>> allApps {
		get {
			if (allApps == null) {
				ocms_mfc_App AppController = new ocms_mfc_App();

				allApps = AppController.getFullAppList(ApexPages.currentPage().getParameters().get('category'));
			}
			
			return allApps;
		} set;
	}

	global override String getHTML() {
		String categoryLauncherHTML = '<div id="tool-category-content">';
		categoryLauncherHTML += '<div class="inner">';	

		for (String key : allApps.keySet()) {
			for (String contentRender : allApps.get(key)) {
				categoryLauncherHTML += contentRender.replace('{mobileSize}', 'mob-size-l').replace('{tabletSize}', 'tab-size-l').replace('{desktopSize}', 'dsk-size-l');
			}
		}

		categoryLauncherHTML += '<script>';
		categoryLauncherHTML += '$(document).ready(function() {';
		categoryLauncherHTML += 	'MFC.fSetupToolLibrary();';
		categoryLauncherHTML += '})';
		categoryLauncherHTML += '</script>';

		categoryLauncherHTML += '</div>';
		categoryLauncherHTML += '</div>';	

		return categoryLauncherHTML;
	}

	/**
	 * @description attribute title - required
	 */
	public String title {
	    get { return getProperty('title'); }
	}
}