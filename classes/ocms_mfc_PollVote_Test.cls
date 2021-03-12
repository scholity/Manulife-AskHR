@isTest
public class ocms_mfc_PollVote_Test {
	public static testMethod void test() {
		List<Map<String,String>> pollAttributes = addPollAttributes('my awesome question', 'first answer', 'second answer');

		ocms_TestContentHelper helper = new ocms_TestContentHelper('Poll Site');
		helper.createContent(pollAttributes, 'PollVote');

		Profile p = [SELECT Id FROM profile WHERE name='System Administrator'];
		User u = new User(alias = 'standt', email='standarduser@manulife.com',
		emailencodingkey='UTF-8', lastname='waldo', languagelocalekey='en_US',
		localesidkey='en_US', profileid = p.Id, firstname='wheres',
		timezonesidkey='America/Los_Angeles', username='standarduserrr_PollVote@manulife.com');
		TriggerUtils.setBypassUserTrigger(); // there is a trigger on user insert, this sets the flag so the trigger will bypass its logic check

		insert u;

		System.runAs(u) {
			ocms_mfc_PollVote vote = new ocms_mfc_PollVote(helper.gc);
			String poll = vote.getHTML();

			// System.assert(poll.contains('<td><input type="radio" name="poll" value="0">first answer</td>')); // confirms the showPoll method was called properly as this user has not voted yet

			//List<String> beforeIdThenWithIdAndAfter = poll.split('"poll": "', 0);
			//List<String> idThenAfter = beforeIdThenWithIdAndAfter[1].split('", "title": ', 0);

			vote = new ocms_mfc_PollVote();

			Map<String,String> request = new Map<String,String>();
			request.put('action', 'recordChoice');
			request.put('poll', helper.gc.content.id);
			request.put('choice', '0');
			request.put('title', 'my awesome question');
			request.put('option1', 'first answer');
			request.put('option2', 'second answer');

			System.debug(request);

			String response = vote.executeRequest(request);

			// System.assert(response.contains('<td>first answer</td>')); // confirms the showResults method was called properly after this user submitted an action to vote

			RecordType pollRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'MFC_Community_Object__c' AND DeveloperName = 'Poll_Vote'];
			MFC_Community_Object__c pollVote = [SELECT Id, VoteIndex__c FROM MFC_Community_Object__c WHERE User__c = :u.Id AND Content__c = :helper.gc.content.id AND RecordTypeId = :pollRecordType.Id];
			System.assertNotEquals(pollVote, Null); // confirms the user's vote has been successfully recorded
			System.assertEquals(pollVote.VoteIndex__c, '0'); // confirms the vote has been given the proper index value

			vote = new ocms_mfc_PollVote(helper.gc);
			poll = vote.getHTML();
			// System.assert(poll.contains('<td>first answer</td>')); // confirms the user is not given the option to vote a second time as the getHTML has correctly seen their vote and therefore loaded the results

			vote = new ocms_mfc_PollVote();
			response = vote.executeRequest(request);
			List <MFC_Community_Object__c> pollVotes = [SELECT Id, VoteIndex__c FROM MFC_Community_Object__c WHERE User__c = :u.Id AND Content__c = :helper.gc.content.id AND RecordTypeId = :pollRecordType.Id];
			System.assertEquals(pollVotes.size(), 1); // confirms even if the user got access to the executeRequest method again somehow, their attempt to vote a second time was properly prevented
		}
	}

	/**
	* @description  Creates a map of attributes for a poll
	* @param question  The attribute value for the poll question
	* @param answer1 The attribute value for the first answer
	* @param answer2 The attribute value for the second answer
	* @return attribute map for one piece of content
	* @author Adrian Lawson
	*/
	private static List<Map<String,String>> addPollAttributes(String question, String answer1, String answer2) {
			List<Map<String,String>> poll = new List <Map<String,String>>();

			Map<String,String> attributes = new Map<String,String>();
			attributes.put('name', 'title');
			attributes.put('value', question);
			attributes.put('type', 'text');
			poll.add(attributes);

			attributes = new Map<String,String>();
			attributes.put('name', 'option1');
			attributes.put('value', answer1);
			attributes.put('type', 'text');
			poll.add(attributes);

			attributes = new Map<String,String>();
			attributes.put('name', 'option2');
			attributes.put('value', answer2);
			attributes.put('type', 'text');
			poll.add(attributes);

			return poll;
		}
}