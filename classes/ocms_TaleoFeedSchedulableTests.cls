@isTest
public with sharing class ocms_TaleoFeedSchedulableTests {
	public static testmethod void testDoSubmit() {
		Test.setMock(HTTPCalloutMock.class, new DoSubmitMock());

		ocms_TaleoFeedSchedulable sch = new ocms_TaleoFeedSchedulable();
		sch.currentState.jobName = 'Test MFC Job Count';

		sch.currentState.currentCall = 'SUBMIT';

		Test.startTest();
		sch.execute(null);
		Test.stopTest();
	}

	public static testmethod void testDoPoll() {
		Test.setMock(HTTPCalloutMock.class, new DoPollMock());

		ocms_TaleoFeedSchedulable sch = new ocms_TaleoFeedSchedulable();
		sch.currentState.jobName = 'Test MFC Job Count';

		sch.currentState.currentCall = 'POLLING';
		sch.currentState.messageKey = messageKey;

		Test.startTest();
		sch.execute(null);
		Test.stopTest();
	}

	public static testmethod void testDoComplete() {
		Test.setMock(HTTPCalloutMock.class, new DoCompleteMock());

		ocms_TaleoFeedSchedulable sch = new ocms_TaleoFeedSchedulable();
		sch.currentState.jobName = 'Test MFC Job Count';

		sch.currentState.currentCall = 'COMPLETE';
		sch.currentState.correlationKey = correlationKey;

		Test.startTest();
		sch.execute(null);
		Test.stopTest();

		Feed_Data__c[] data = [select Id from Feed_Data__c where RecordType.Name='Job Count'];
		System.assert(data.size() > 0, 'Should insert Feed_Data__c records');
	}

	static String doSubmitResponse = '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><soap:Body><ns1:submitDocumentResponse xmlns:ns1="http://www.taleo.com/ws/integration/toolkit/2011/05/management"><IntegrationMessage xmlns="http://www.taleo.com/ws/integration/toolkit/2011/05"><MessageKey>124275399</MessageKey></IntegrationMessage></ns1:submitDocumentResponse></soap:Body></soap:Envelope>';
	static String messageKey = '124275399';
	public class DoSubmitMock implements HttpCalloutMock {
		public HTTPResponse respond(HTTPRequest req) {
			System.assertEquals('POST', req.getMethod(), 'HTTP request should use POST');

			HTTPResponse res = new HTTPResponse();
			res.setStatusCode(200);
			res.setHeader('Content-Type', 'text/xml; charset=utf-8');
			res.setBody(doSubmitResponse);

			return res;
		}
	}

	static String doPollResponse = '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><soap:Body><ns1:getMessageByKeyResponse xmlns:ns1="http://www.taleo.com/ws/integration/toolkit/2011/05/management"><IntegrationMessage xmlns="http://www.taleo.com/ws/integration/toolkit/2011/05"><MessageKey>124275399</MessageKey><CorrelationKey>124275400</CorrelationKey><MessageID>MFCentral_Query_1434719983292</MessageID><ConversationID/><State>5</State><Target>1</Target><Format>2</Format><ServiceName>IntegrationManagementService</ServiceName><MethodName>submitDocument</MethodName><ServiceID>http://www.taleo.com/ws/integration/toolkit/2005/07/action/export</ServiceID><ApplicationCode>enterprise</ApplicationCode><CreationDate>2015-06-19T09:19:44.741-04:00</CreationDate><LastModificationDate>2015-06-19T09:28:49.516-04:00</LastModificationDate><OwnerUserName>tcc_integration</OwnerUserName><Document><RecordCount>1</RecordCount><RecordIndex>1</RecordIndex><Attributes><Attribute><Name>mode</Name><Value>XML</Value></Attribute><Attribute><Name>version</Name><Value>http://www.taleo.com/ws/tee800/2009/01</Value></Attribute></Attributes></Document><Attributes><Attribute><Namespace>http://www.taleo.com/ws/integration/toolkit/2005/07</Namespace><Name>MiddlewareHost</Name><Value/><AttributeType>1</AttributeType></Attribute><Attribute><Namespace>http://www.taleo.com/ws/integration/toolkit/2005/07</Namespace><Name>MiddlewarePath</Name><Value/><AttributeType>1</AttributeType></Attribute><Attribute><Namespace>http://www.taleo.com/ws/integration/toolkit/2005/07</Namespace><Name>MiddlewarePort</Name><Value/><AttributeType>1</AttributeType></Attribute><Attribute><Namespace>http://www.taleo.com/ws/integration/toolkit/2005/07</Namespace><Name>MiddlewareProtocol</Name><Value/><AttributeType>1</AttributeType></Attribute><Attribute><Namespace>http://www.w3.org/2005/03/addressing</Namespace><Name>ReplyTo</Name><Value>http://www.taleo.com/ws/integration/toolkit/2005/07/addressing/queue</Value><AttributeType>4</AttributeType></Attribute></Attributes><HistoryItems><HistoryItem><Sequence>1</Sequence><InitialState>1</InitialState><FinalState>1</FinalState><UserName>tcc_integration</UserName><CreationDate>2015-06-19T09:19:44.741-04:00</CreationDate></HistoryItem><HistoryItem><Sequence>2</Sequence><InitialState>1</InitialState><FinalState>2</FinalState><UserName>tcc_integration</UserName><CreationDate>2015-06-19T09:19:44.754-04:00</CreationDate></HistoryItem><HistoryItem><Sequence>3</Sequence><InitialState>2</InitialState><FinalState>3</FinalState><UserName>tcc_integration</UserName><CreationDate>2015-06-19T09:19:45.015-04:00</CreationDate></HistoryItem><HistoryItem><Sequence>4</Sequence><InitialState>3</InitialState><FinalState>4</FinalState><UserName>tcc_integration</UserName><CreationDate>2015-06-19T09:19:45.529-04:00</CreationDate></HistoryItem><HistoryItem><Sequence>5</Sequence><InitialState>4</InitialState><FinalState>5</FinalState><UserName>tcc_integration</UserName><CreationDate>2015-06-19T09:19:45.769-04:00</CreationDate></HistoryItem></HistoryItems></IntegrationMessage></ns1:getMessageByKeyResponse></soap:Body></soap:Envelope>';
	static String correlationKey = '124275400';
	public class DoPollMock implements HttpCalloutMock {
		public HTTPResponse respond(HTTPRequest req) {
			System.assertEquals('POST', req.getMethod(), 'HTTP request should use POST');

			HTTPResponse res = new HTTPResponse();
			res.setStatusCode(200);
			res.setHeader('Content-Type', 'text/xml; charset=utf-8');
			res.setBody(doPollResponse);

			return res;
		}
	}

	static String doCompleteResponse = '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><soap:Body><ns1:getDocumentByKeyResponse xmlns:ns1="http://www.taleo.com/ws/integration/toolkit/2011/05/management"><Document xmlns="http://www.taleo.com/ws/integration/toolkit/2011/05"><Attributes><Attribute name="count">12</Attribute><Attribute name="duration">0:00:00.183</Attribute><Attribute name="entity">SourcingRequest</Attribute><Attribute name="mode">XML</Attribute><Attribute name="version">http://www.taleo.com/ws/tee800/2009/01</Attribute></Attributes><Content>'
										 + '<ExportXML xmlns="http://www.taleo.com/ws/integration/toolkit/2005/07/action/export">'
										 + '    <record>'
										 + '        <field name="Country">United Kingdom</field>'
										 + '        <field name="SumNumberToHire">33</field>'
										 + '    </record>'
										 + '    <record>'
										 + '        <field name="Country">China</field>'
										 + '        <field name="SumNumberToHire">561</field>'
										 + '    </record>'
										 + '    <record>'
										 + '        <field name="Country">Malaysia</field>'
										 + '        <field name="SumNumberToHire">44</field>'
										 + '    </record>'
										 + '    <record>'
										 + '        <field name="Country">United States</field>'
										 + '        <field name="SumNumberToHire">2354</field>'
										 + '    </record>'
										 + '    <record>'
										 + '        <field name="Country">Philippines</field>'
										 + '        <field name="SumNumberToHire">342</field>'
										 + '    </record>'
										 + '    <record>'
										 + '        <field name="Country">Vietnam</field>'
										 + '        <field name="SumNumberToHire">52</field>'
										 + '    </record>'
										 + '    <record>'
										 + '        <field name="Country">Canada</field>'
										 + '        <field name="SumNumberToHire">653</field>'
										 + '    </record>'
										 + '    <record>'
										 + '        <field name="Country">Indonesia</field>'
										 + '        <field name="SumNumberToHire">96</field>'
										 + '    </record>'
										 + '    <record>'
										 + '        <field name="Country">Singapore</field>'
										 + '        <field name="SumNumberToHire">107</field>'
										 + '    </record>'
										 + '    <record>'
										 + '        <field name="Country">Japan</field>'
										 + '        <field name="SumNumberToHire">38</field>'
										 + '    </record>'
										 + '    <record>'
										 + '        <field name="Country">Cambodia</field>'
										 + '        <field name="SumNumberToHire">73</field>'
										 + '    </record>'
										 + '    <record>'
										 + '        <field name="Country">Thailand</field>'
										 + '        <field name="SumNumberToHire">11</field>'
										 + '    </record>'
										 + '</ExportXML></Content></Document></ns1:getDocumentByKeyResponse></soap:Body></soap:Envelope>';
	public class DoCompleteMock implements HttpCalloutMock {
		public HTTPResponse respond(HTTPRequest req) {
			System.assertEquals('POST', req.getMethod(), 'HTTP request should use POST');

			HTTPResponse res = new HTTPResponse();
			res.setStatusCode(200);
			res.setHeader('Content-Type', 'text/xml; charset=utf-8');
			res.setBody(doCompleteResponse);

			return res;
		}
	}
}