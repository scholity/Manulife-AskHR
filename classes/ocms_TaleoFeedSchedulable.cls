public with sharing class ocms_TaleoFeedSchedulable implements Schedulable {
	public class State {
		public String currentCall;
		public String jobName;
		public DateTime initiatedAt;

		public String triggerId;

		public String messageKey;
		public String correlationKey;
	}

	public static String endpoint = 'callout:Taleo_Web_Services_Prod/enterprise/soap?ServiceName=IntegrationManagementService';

	public State currentState;

	public ocms_TaleoFeedSchedulable() {
		this.currentState = new State();
		currentState.jobName = 'MFC Taleo Job Counts';
		currentState.currentCall = 'SUBMIT';
		currentState.initiatedAt = DateTime.now();
	}

	public ocms_TaleoFeedSchedulable(State newState) {
		this.currentState = newState;
	}

	public void execute(SchedulableContext sc) {
		if(sc != null) {
			this.currentState.triggerId = sc.getTriggerId();
		}

		if(currentState.currentCall == 'SUBMIT') {
			doSubmit(JSON.serialize(this.currentState));
		} else if(currentState.currentCall == 'POLLING') {
			doPoll(JSON.serialize(this.currentState));
		} else if(currentState.currentCall == 'COMPLETE') {
			doComplete(JSON.serialize(this.currentState));
		}
	}

	private static String soapNs = 'http://schemas.xmlsoap.org/soap/envelope/';
	private static String taleoManagementNs = 'http://www.taleo.com/ws/integration/toolkit/2011/05/management';
	private static String taleoNs = 'http://www.taleo.com/ws/integration/toolkit/2011/05';
	private static String exportNs = 'http://www.taleo.com/ws/integration/toolkit/2005/07/action/export';

	@future(callout=true)
	public static void doSubmit(String currentStateJson) {
		State currentState = (State)JSON.deserialize(currentStateJson, State.class);
		try {
			String messageId = 'MFCentral_Query_' + DateTime.now().getTime();

			Dom.XmlNode root = doSOAPCall(
				'<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:add="http://www.w3.org/2005/03/addressing" xmlns:man="http://www.taleo.com/ws/integration/toolkit/2011/05/management" xmlns:ns="http://www.taleo.com/ws/integration/toolkit/2011/05"><soapenv:Header><add:Action>http://www.taleo.com/ws/integration/toolkit/2005/07/action/export</add:Action><add:ReplyTo><add:Address>http://www.taleo.com/ws/integration/toolkit/2005/07/addressing/queue</add:Address><add:ReferenceParameters /></add:ReplyTo><add:MessageID>' + messageId + '</add:MessageID></soapenv:Header><soapenv:Body><man:submitDocument><ns:Document><ns:Attributes><ns:Attribute name="version">http://www.taleo.com/ws/tee800/2009/01</ns:Attribute><ns:Attribute name="mode">XML</ns:Attribute></ns:Attributes><ns:Content><ExportQuery xmlns="http://www.taleo.com/ws/integration/toolkit/2005/07/action/export"><quer:query xmlns:quer="http://www.taleo.com/ws/integration/query" productCode="RC1401" model="http://www.taleo.com/ws/tee800/2009/01" projectedClass="SourcingRequest" locale="en" alias="mainQuery" mode="XML" largegraph="true" preventDuplicates="true"><quer:subQueries><quer:query projectedClass="SourcingRequest" alias="SubQuery1"><quer:projections><quer:projection id="SubCountryDecoded"><quer:decode><quer:concatenate><quer:field path="Requisition,JobInformation,PrimaryLocation,NetworkLocation,CountryLocation,NetworkLocation.Abbreviation" /><quer:string>_</quer:string><quer:field path="Requisition,JobInformation,PrimaryLocation,NetworkLocation,StateLocation,NetworkLocation.Abbreviation" /></quer:concatenate><quer:string>CN_91</quer:string><quer:string>Hong Kong</quer:string><quer:field path="Requisition,JobInformation,PrimaryLocation,NetworkLocation,CountryLocation,NetworkLocation.Name" /></quer:decode></quer:projection><quer:projection id="RequisitionNo"><quer:field path="Requisition,ContestNumber" /></quer:projection></quer:projections><quer:filterings><quer:filtering><quer:equal><quer:field path="SourcingRequestStatus,Description" /><quer:string>Posted</quer:string></quer:equal></quer:filtering><quer:filtering><quer:equal><quer:field path="JobBoard,RecruitmentSource,Description" /><quer:string>Internal</quer:string></quer:equal></quer:filtering></quer:filterings></quer:query></quer:subQueries><quer:projections><quer:projection alias="Country" id="CountryDecoded"><quer:projection ref="SubCountryDecoded" /></quer:projection><quer:projection alias="CountReqs"><quer:count><quer:projection ref="RequisitionNo" /></quer:count></quer:projection></quer:projections><quer:projectionFilterings /><quer:filterings><quer:filtering><quer:equal><quer:field path="SourcingRequestStatus,Description" /><quer:string>Posted</quer:string></quer:equal></quer:filtering><quer:filtering><quer:equal><quer:field path="JobBoard,RecruitmentSource,Description" /><quer:string>Internal</quer:string></quer:equal></quer:filtering><quer:filtering><quer:equal><quer:projection ref="RequisitionNo" /><quer:field path="Requisition,ContestNumber" /></quer:equal></quer:filtering></quer:filterings><quer:sortings /><quer:sortingFilterings /><quer:groupings><quer:grouping><quer:projection ref="CountryDecoded" /></quer:grouping></quer:groupings><quer:joinings /></quer:query></ExportQuery></ns:Content></ns:Document></man:submitDocument></soapenv:Body></soapenv:Envelope>',
				'http://www.taleo.com/ws/integration/toolkit/2011/05/management/IntegrationManagementService#submitDocument'
			);

			Dom.xmlNode key = root.getChildElement('Body', soapNs)
				.getChildElement('submitDocumentResponse', taleoManagementNs)
				.getChildElement('IntegrationMessage', taleoNs)
				.getChildElement('MessageKey', taleoNs);

			currentState.messageKey = key.getText();
			System.debug('Got message key: ' + currentState.messageKey);

			// Got a message key. Start polling in 5 minutes
			currentState.currentCall = 'POLLING';
			reschedule(currentState, DateTime.now().addMinutes(5), false);
		} catch(Exception e) {
			System.debug(e.getMessage());
			// Failed. Try submitting again in 10 minutes
			currentState.currentCall = 'SUBMIT';
			reschedule(currentState, DateTime.now().addMinutes(10), true);
			return;
		}
	}

	@future(callout=true)
	public static void doPoll(String currentStateJson) {
		State currentState = (State)JSON.deserialize(currentStateJson, State.class);
		System.debug('Current messageKey: ' + currentState.messageKey);

		try {
			// Pass currentState.messageKey back to Taleo
			Dom.XmlNode root = doSOAPCall(
				'<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:man="http://www.taleo.com/ws/integration/toolkit/2011/05/management"><soapenv:Header/><soapenv:Body><man:getMessageByKey><man:messageKey>' + currentState.messageKey + '</man:messageKey></man:getMessageByKey></soapenv:Body></soapenv:Envelope>',
				'http://www.taleo.com/ws/integration/toolkit/2011/05/management/IntegrationManagementService#getMessageByKey'
			);

			Dom.xmlNode message = root.getChildElement('Body', soapNs)
					.getChildElement('getMessageByKeyResponse', taleoManagementNs)
					.getChildElement('IntegrationMessage', taleoNs);

			String docState = message.getChildElement('State', taleoNs).getText();
			String correlationKey = message.getChildElement('CorrelationKey', taleoNs).getText();

			if(docState == '5') {
				// Document is ready. Complete the process in 1 minute
				currentState.correlationKey = correlationKey;
				System.debug('Got correlationKey ' + correlationKey);
				currentState.currentCall = 'COMPLETE';
				reschedule(currentState, DateTime.now().addMinutes(1), false);
				return;
			} else {
				System.debug('Document not ready yet.');

				// Not ready yet, poll again in a minute
				currentState.currentCall = 'POLLING';
				reschedule(currentState, DateTime.now().addMinutes(5), false);
				return;
			}
		} catch(Exception e) {
			System.debug(e.getMessage());
			// Failed. Try submitting again in 10 minutes
			currentState.currentCall = 'SUBMIT';
			reschedule(currentState, DateTime.now().addMinutes(10), true);
			return;
		}
	}

	@future(callout=true)
	public static void doComplete(String currentStateJson) {
		State currentState = (State)JSON.deserialize(currentStateJson, State.class);
		System.debug('Current correlationKey: ' + currentState.correlationKey);

		try {
			// Pass currentState.correlationKey back to Taleo
			Dom.XmlNode root = doSOAPCall(
				'<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:man="http://www.taleo.com/ws/integration/toolkit/2011/05/management"><soapenv:Header/><soapenv:Body><man:getDocumentByKey><man:messageKey>' + currentState.correlationKey + '</man:messageKey></man:getDocumentByKey></soapenv:Body></soapenv:Envelope>',
				'http://www.taleo.com/ws/integration/toolkit/2011/05/management/IntegrationManagementService#getDocumentByKey'
			);

			Map<String, Integer> countryToJobs = new Map<String, Integer>();

			Dom.xmlNode[] records = root.getChildElement('Body', soapNs)
				.getChildElement('getDocumentByKeyResponse', taleoManagementNs)
				.getChildElement('Document', taleoNs)
				.getChildElement('Content', taleoNs)
				.getChildElement('ExportXML', exportNs)
				.getChildElements();

			for(Dom.xmlNode record : records) {
				String country, numToHire;

				for(Dom.xmlNode field : record.getChildElements()) {
					if(field.getAttributeValue('name', null) == 'Country') {
						country = field.getText();
					} else {
						numToHire = field.getText();
					}
				}

				countryToJobs.put(country, Integer.valueOf(numToHire));
			}

			updateJobCountRecords(countryToJobs);
		} catch(Exception e) {
			System.debug(e.getMessage());
		}

		// Submit again an hour after we submitted this request
		currentState.currentCall = 'SUBMIT';
		reschedule(currentState, currentState.initiatedAt.addMinutes(60), true);
	}

	public static void reschedule(State nextState, DateTime nextRun, Boolean isNewRun) {
		// Remove current job
		if(nextState.triggerId != null) {
			System.abortJob(nextState.triggerId); //abort scheduled job
		}

		String newExpression = '0 ' + nextRun.minute() + ' ' + nextRun.hour() + ' * * ?';

		ocms_TaleoFeedSchedulable taleoUpdater = new ocms_TaleoFeedSchedulable();
		if(isNewRun) {
			nextState.messageKey = null;
			nextState.correlationKey = null;
			nextState.initiatedAt = nextRun;
		}

		System.schedule(nextState.jobName, newExpression, new ocms_TaleoFeedSchedulable(nextState));
	}

	public static void updateJobCountRecords(Map<String, Integer> countryToJobs) {
		String recordTypeId = Schema.SObjectType.Feed_Data__c.getRecordTypeInfosByName().get('Job Count').getRecordTypeId();

		Feed_Data__c[] existingRecords = [select Id from Feed_Data__c where RecordTypeId = :recordTypeId];
		Feed_Data__c[] newRecords = new Feed_Data__c[]{};

		for(String country : countryToJobs.keySet()) {
			newRecords.add(new Feed_Data__c(
				Country__c = country,
				SumNumberToHire__c = countryToJobs.get(country),
				RecordTypeId = recordTypeId
			));
		}

		delete existingRecords;
		insert newRecords;
	}

	private static Dom.XmlNode doSOAPCall(String body, String action) {
		HTTPRequest req = new HTTPRequest();
		req.setEndpoint(endpoint);
		req.setMethod('POST');
		req.setBody(body);
		req.setHeader('Content-Type', 'text/xml; charset=UTF-8');
		req.setHeader('SOAPAction', action);

		HTTP http = new HTTP();
		HTTPResponse res = http.send(req);

		System.debug(JSON.serialize(res.getBody()));

		Dom.Document doc = new Dom.Document();
		doc.load(res.getBody());

		return doc.getRootElement();
	}
}