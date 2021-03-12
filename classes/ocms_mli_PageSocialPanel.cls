/**
 * @author Jialin Guo
 * @description Social Link Panel that generates links to Facebook, Twitter and LinkedIn
 *                Social links will be specific to the Article that is loaded on the page
 */

global with sharing class ocms_mli_PageSocialPanel extends cms.ContentTemplateController{

    global ocms_mli_PageSocialPanel() {}

    global ocms_mli_PageSocialPanel (cms.GenerateContent gc) {
        super(gc);
    }

    global ocms_mli_PageSocialPanel(cms.CreateContentController cc) {
        super(cc);
    }

    public String strSocialPanelLabel {
        get { return getProperty('strSocialPanelLabel'); }
    }

    public String strFacebookLike {
        get { return getProperty('strFacebookLike'); }
    }

    public String strFacebookLikeIcon {     
        get {return getProperty('strFacebookLikeIcon'); }
    }

    public String strFacebookShare {
        get { return getProperty('strFacebookShare'); }
    }

    public String strFacebookShareIcon {     
        get {return getProperty('strFacebookShareIcon'); }
    }

    public String strTwitterShare {
        get { return getProperty('strTwitterShare'); }
    }

    public String strTwitterShareIcon {     
        get {return getProperty('strTwitterShareIcon'); }
    }

    public String strLinkedIn {
        get { return getProperty('strLinkedIn'); }
    }

    public String strLinkedInIcon {     
        get {return getProperty('strLinkedInIcon'); }
    }

    // For generated markup
    global virtual override String getHTML() { // For generated markup
        
        String strHTML = '';

			strHTML +=	    '<!--Social Sharing Area-->';
			strHTML +=		'<div class="contentSharing">';
			strHTML +=			'<div class="contentSharingContainer" data-hw-module="module/ShowHide" data-hw-options="';
			strHTML +=				'selectors: {';
			strHTML +=					'button: \'.contentSharingShare\'';
			strHTML +=				'},';
			strHTML +=				'classes: {';
			strHTML +=					'isOpen: \'is-active\'';
			strHTML +=				'},';
			strHTML +=				'maxBreakpoint: \'mobile\'';
			strHTML +=			'">';

			strHTML +=				'<!--Social sharing list for tablet up, hidden in mobile-->';
			strHTML +=				'<div class="tabletUpSocialSharingList tabletUp">';
			strHTML +=					'<span class="subtitle">'+this.strSocialPanelLabel+'</span>';
			strHTML +=						'<ul>';
			strHTML +=							'<li>';
			strHTML +=								'<a href="#" class="contentSharingFacebook" title="External site: Opens in a new window">Like<span class="accessible"> page on Facebook: External site: Opens in a new window</span></a><span>24</span>';
			strHTML +=							'</li>';
			strHTML +=							'<li>';
			strHTML +=								'<a href="#" class="contentSharingFacebook" title="External site: Opens in a new window">Share<span class="accessible"> page on Facebook: External site: Opens in a new window</span></a><span>64K</span>';
			strHTML +=							'</li>';
			strHTML +=							'<li>';
			strHTML +=								'<a href="#" class="contentSharingTwitter" title="External site: Opens in a new window">Share<span class="accessible"> page on Twitter: External site: Opens in a new window</span></a><span>1K</span>';
			strHTML +=							'</li>';
			strHTML +=							'<li>';
			strHTML +=								'<a href="#" class="contentSharingLinkedin" title="External site: Opens in a new window"><span class="accessible">Share page on </span>LinkedIn<span class="accessible">: External site: Opens in a new window</span></a><span>1K</span>';
			strHTML +=							'</li>';
			strHTML +=						'</ul>';
			strHTML +=				'</div>';

			strHTML +=				'<!--Initial Sharing Button Options, dropdown hidden in tablet view up-->';
			strHTML +=				'<div class="contentSharingButtonList">';
			strHTML +=					'<ul>';
			strHTML +=						'<li class="sharingButtonDropdownArrow mobileOnly">';
			strHTML +=							'<a href="#" class="contentSharingShare accessibleLink">Share<span class="accessible">: Has popup</span></a>';
			strHTML +=						'</li>';
			strHTML +=						'<li class="tabletUp">';
			strHTML +=							'<a href="#" class="contentSharingButton accessibleLink contentSharingPrint">Print<span class="accessible"> this page</span></a>';
			strHTML +=						'</li>';
			strHTML +=						'<li>';
			strHTML +=							'<a href="#" class="contentSharingButton accessibleLink contentSharingMail">Email<span class="accessible"> this page</span></a>';
			strHTML +=						'</li>';
			strHTML +=					'</ul>';

			strHTML +=					'<div class="contentArea">';
			strHTML +=					'<!--Share Drop Down Options, mobile only-->';
			strHTML +=						'<div class="contentSharingDropdown">';
			strHTML +=							'<ul>';
			strHTML +=								'<li>';
			strHTML +=									'<a href="#" class="contentSharingFacebook" title="External site: Opens in a new window">Like<span class="accessible"> page on Facebook: External site: Opens in a new window</span></a><span>24</span>';
			strHTML +=								'</li>';
			strHTML +=								'<li>';
			strHTML +=									'<a href="#" class="contentSharingFacebook" title="External site: Opens in a new window">Share<span class="accessible"> page on Facebook: External site: Opens in a new window</span></a><span>64K</span>';
			strHTML +=								'</li>';
			strHTML +=								'<li>';
			strHTML +=									'<a href="#" class="contentSharingTwitter" title="External site: Opens in a new window">Share<span class="accessible"> page on Twitter: External site: Opens in a new window</span></a><span>1K</span>';
			strHTML +=								'</li>';
			strHTML +=								'<li>';
			strHTML +=									'<a href="#" class="contentSharingLinkedin" title="External site: Opens in a new window"><span class="accessible">Share page on </span>LinkedIn<span class="accessible">: External site: Opens in a new window</span></a><span>1K</span>';
			strHTML +=								'</li>';
			strHTML +=							'</ul>';
			strHTML +=						'</div>';
			strHTML +=					'</div>';
			strHTML +=				'</div>';

			strHTML +=			'</div>';
			strHTML +=		'</div>';

		return strHTML;

    }
}