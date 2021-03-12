/**
  * @author Mohamad Ammar Amran <mohamadammar_amran@manulife.com>
  * @description Schedulable class for User Contact resynchronization job. The class will handle querying and deactivating all Terminated employees.
  *				the job is dependent on the setting (ASKHR_UserContactReSyncSetting__mdt), if it is set to Active = false, no deactivation will be perform. 
  *				Results from daily job will be send to the reporting group using the ASKHR Notification Util.
*/
public with sharing class ASKHR_UserContactReSync implements Schedulable {
	public void execute(SchedulableContext sc) {
		performOperation();
	}

	/**
	* @description Perform the operation by querying the active Users from the terminated Contacts. Then the user is deactivated and results are send to the reporting group
	* @return void 
	*/
	private void performOperation() {
			List<User> usersToDeactivate = [Select Id, IsActive,
			                                Name,
			                                Employee_ID__c,
			                                User_License__c,
											Profile.Name,
			                                FederationIdentifier,
			                                LastLoginDate,
			                                LastModifiedDate,
			                                LastModifiedBy.Name
			                                FROM User
			                                WHERE Id in
			(
			 Select User__c from Contact
			 where User__r.IsActive = TRUE AND Employee_Status__c = 'Terminated'
			)
			                                LIMIT 1000];

			if (!usersToDeactivate.isEmpty()) {
				for (User user : usersToDeactivate) {
					user.IsActive = false;
				}

				Database.SaveResult[] results = Database.update(usersToDeactivate, false);
				List<String> operationResults = new List<String> ();
				operationResults.add(createHTMLTable());

				Integer loopIndex = 0;
				Integer countFailedOperation = 0;
				for (loopIndex = 0; loopIndex < results.size(); loopIndex++) {
					Database.SaveResult sr = results.get(loopIndex);
					User currUser = usersToDeactivate.get(loopIndex);
					String operationResult;

					operationResult = '<tr><td>' + currUser.Id + '</td>' +
					'<td>' + currUser.Name + '</td>' +
					'<td>' + currUser.Employee_ID__c + '</td>' +
					'<td>' + currUser.User_License__c + '</td>' +
					'<td>' + currUser.Profile.Name + '</td>' +
					'<td>' + currUser.FederationIdentifier + '</td>' +
					'<td>' + currUser.LastLoginDate + '</td>' + 
					'<td>' + currUser.LastModifiedBy.Name + '</td>';

					if (!sr.isSuccess()) {
						operationResult += '<td>Failed-';
						for (Database.Error err : sr.getErrors()) {
							operationResult += 'Details: ' + err.getStatusCode() + '<br/>' + err.getMessage();
						}
						operationResult += '</td>';
						countFailedOperation++;
					} else {
						operationResult += '<td>Success</td>';
					}

					operationResult += '</tr>';
					operationResults.add(operationResult);
				}

				operationResults.add('</table>');
				if (!operationResults.isEmpty()) {
					Integer successOperation = results.size() - countFailedOperation;
					operationResults.add(0, '<b>ASKHR User/Contact Resync Operation Result: </b><br/>' +
					                     'Success: ' + successOperation + '<br/>' +
					                     'Fail: ' + countFailedOperation + '<br/><br/>');
					ASKHR_NotificationUtils.sendHTMLEmailNotification('ASKHR- User Contact ReSync Job', string.join(operationResults, '\n'));
				}
			}
	}

	private string createHTMLTable() {
		return '<table border="1"><tr><th>Id</th><th>Name</th><th>Employee Id</th><th>User License</th><th>Profile</th><th>Federation Identifier</th><th>Last Login Date</th><th>Last Modified By</th><th>Result</th></tr>';
	}
}