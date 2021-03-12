global with sharing class ocms_mfc_CareersMap extends cms.ContentTemplateController implements cms.ServiceInterface {
	public static String recordTypeName = 'Job Count';
	public static Map<String, Map<String, String>> countryCodeToValues;
	public static Map<String, cms.Link> countryCodeLinks;

	private static final Map<String, String> countryNameToId = new Map<String, String> {
		'Canada' => '1',
		'United States' => '2',
		'Japan' => '3',
		'China' => '13',
		'Taiwan' => '4',
		'Thailand' => '10',
		'Singapore' => '7',
		'Vietnam' => '11',
		'Malaysia' => '8',
		'Philippines' => '5',
		'Indonesia' => '6',
		'Hong Kong' => '12',
		'Cambodia' => '9'
	};

    global ocms_mfc_CareersMap () {}

    global ocms_mfc_CareersMap (cms.GenerateContent gc) {
        super(gc);
    }

    global ocms_mfc_CareersMap (cms.CreateContentController cc) {
    	super(cc);
    }

    public String legendText { get { return this.getProperty('legendText'); } set; }

    public String canadaLink { get { return this.getProperty('canadaLink'); } set; }

    public String unitedStatesLink { get { return this.getProperty('unitedStatesLink'); } set; }

    public String japanLink { get { return this.getProperty('japanLink'); } set; }

    public String taiwanLink { get { return this.getProperty('taiwanLink'); } set; }

    public String philippinesLink { get { return this.getProperty('philippinesLink'); } set; }

    public String indonesiaLink { get { return this.getProperty('indonesiaLink'); } set; }

    public String singaporeLink { get { return this.getProperty('singaporeLink'); } set; }

	public String malaysiaLink { get { return this.getProperty('malaysiaLink'); } set; }

    public String cambodiaLink { get { return this.getProperty('cambodiaLink'); } set; }

    public String thailandLink { get { return this.getProperty('thailandLink'); } set; }

    public String vietnamLink { get { return this.getProperty('vietnamLink'); } set; }

    public String hongKongLink { get { return this.getProperty('hongKongLink'); } set; }

    public String chinaLink { get { return this.getProperty('chinaLink'); } set; }

    public String canadaText { get { return this.getProperty('canadaText'); } set; }

    public String unitedStatesText { get { return this.getProperty('unitedStatesText'); } set; }

    public String japanText { get { return this.getProperty('japanText'); } set; }

    public String taiwanText { get { return this.getProperty('taiwanText'); } set; }

    public String philippinesText { get { return this.getProperty('philippinesText'); } set; }

    public String indonesiaText { get { return this.getProperty('indonesiaText'); } set; }

    public String singaporeText { get { return this.getProperty('singaporeText'); } set; }

	public String malaysiaText { get { return this.getProperty('malaysiaText'); } set; }

    public String cambodiaText { get { return this.getProperty('cambodiaText'); } set; }

    public String thailandText { get { return this.getProperty('thailandText'); } set; }

    public String vietnamText { get { return this.getProperty('vietnamText'); } set; }

    public String hongKongText { get { return this.getProperty('hongKongText'); } set; }

    public String chinaText { get { return this.getProperty('chinaText'); } set; }

    public List<Feed_Data__c> feedDataList = new List<Feed_Data__c>();

	public override String getHTML () {
		countryCodeToValues = new Map<String, Map<String,String>> {
			'Canada' => new Map<String, String>{'code' => '1', 'label' => canadaText, 'amount' => '0'},
			'United States' => new Map<String, String>{'code' => '2', 'label' => unitedStatesText, 'amount' => '0'},
			'Japan' => new Map<String, String>{'code' => '3', 'label' => japanText, 'amount' => '0'},
			'China' => new Map<String, String>{'code' => '13', 'label' => chinaText, 'amount' => '0'},
			'Taiwan' => new Map<String, String>{'code' => '4', 'label' => taiwanText, 'amount' => '0'},
			'Thailand' => new Map<String, String>{'code' => '10', 'label' => thailandText, 'amount' => '0'},
			'Singapore' => new Map<String, String>{'code' => '7', 'label' => singaporeText, 'amount' => '0'},
			'Vietnam' => new Map<String, String>{'code' => '11', 'label' => vietnamText, 'amount' => '0'},
			'Malaysia' => new Map<String, String>{'code' => '8', 'label' => malaysiaText, 'amount' => '0'},
			'Philippines' => new Map<String, String>{'code' => '5', 'label' => philippinesText, 'amount' => '0'},
			'Indonesia' => new Map<String, String>{'code' => '6', 'label' => indonesiaText, 'amount' => '0'},
			'Hong Kong' => new Map<String, String>{'code' => '12', 'label' => hongKongText, 'amount' => '0'},
			'Cambodia' => new Map<String, String>{'code' => '9', 'label' => cambodiaText, 'amount' => '0'}
		};

		countryCodeLinks = new Map<String, cms.Link> {
			'Canada' => new cms.Link(canadaLink),
			'United States' => new cms.Link(unitedStatesLink),
			'Japan' => new cms.Link(japanLink),
			'China' => new cms.Link(chinaLink),
			'Taiwan' => new cms.Link(taiwanLink),
			'Thailand' => new cms.Link(thailandLink),
			'Singapore' => new cms.Link(singaporeText),
			'Vietnam' => new cms.Link(vietnamLink),
			'Malaysia' => new cms.Link(malaysiaLink),
			'Philippines' => new cms.Link(philippinesLink),
			'Indonesia' => new cms.Link(indonesiaLink),
			'Hong Kong' => new cms.Link(hongKongLink),
			'Cambodia' => new cms.Link(cambodiaLink)
		};

		String html = '';

		html += '<div id="global-careers-map">';
		html +=		'<div class="resp">';
		html +=			'<div class="inner">';
		html +=				'<div class="bg">';
		html +=					'<img src="' + ocms_mfc_Utility.getResourceURL('ocms_mfc_siteFiles') + '/img/careers-map-bg.png"/>';
		html +=				'</div>';
		html +=				'<div class="content">';
		html +=					'<div class="legend">';
		html +=						'<span>' + (legendText != null ? legendText : '') + '</span>';
		html +=					'</div>';

		feedDataList = [SELECT Id, Country__c, SumNumberToHire__c FROM Feed_Data__c WHERE RecordType.Name = :recordTypeName];
		User user = ocms_mfc_Taxonomy.user;
		String currentCountry = '';
		if (user != null) {
			currentCountry = user.MFC_Country__c;
		}

		for (String careersKey : countryCodeToValues.keySet()) {
			if (countryCodeToValues.get(careersKey).get('label') == null) {
				countryCodeToValues.get(careersKey).put('label', careersKey);
			}

			html += getLocationHTML(careersKey, '', countryCodeToValues.get(careersKey).get('label'), countryCodeToValues.get(careersKey).get('link'), currentCountry == careersKey);
		}

		html +=				'</div>';
		html +=			'</div>';
		html +=		'</div>';
		html +=	'</div>';

		return html;
	}

	private String getLocationHTML(String code, String amount, String label, String link, Boolean current) {
		String html = '';

		html += '<div class="location loc-' + countryCodeToValues.get(code).get('code') + (current == true ? ' current' : '') + '">';

		cms.Link countryLink = countryCodeLinks.get(code);
		countryLink.setClasses('inner');

		html += 	countryLink.render();
		html += 		'<div class="v-align">';
		html += 			'<div class="inner">';
		html += 				'<span class="count">' + amount + '</span>';
		html += 			'</div>';
		html += 		'</div>';
		html += 		'<div class="tooltip">';
		html += 			'<div class="v-align">';
		html += 				'<div class="inner">';
		html += 				'<span class="name">' + countryCodeToValues.get(code).get('label') + '</span>';
		html += 				'</div>';
		html += 			'</div>';
		html += 		'</div>';
		html += 	'</a>';
		html += '</div>';

		return html;
	}

	public String executeRequest(Map<String, String> p) {
		String action = p.get('action');

		if(action == 'getJobCounts') {
			Map<String, Integer> response = new Map<String, Integer>();

			for(Feed_Data__c data : [SELECT Country__c, SumNumberToHire__c FROM Feed_Data__c WHERE RecordType.Name = :recordTypeName]) {
				response.put(countryNameToId.get(data.Country__c), (Integer)data.SumNumberToHire__c);
			}

			return '{"success":true,"data":' + JSON.serialize(response) + '}';
		}

		return '{"success":false,"message":"Unsupported action"}';
	}

	public System.Type getType(){
		return ocms_mfc_CareersMap.class;
	}
}