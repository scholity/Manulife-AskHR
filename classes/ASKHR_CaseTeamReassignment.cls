/**
 * @author Mohamad Ammar Amran <mohamadammar_amran@manulife.com>
 * @description Class to reassign User's case team when reactivating the status
*/
public class ASKHR_CaseTeamReassignment {
	@future
    public static void performCaseTeamUpdate(String userToReconciles) {
        List<Id> userToReconcile = (List<Id>) JSON.deserialize(userToReconciles, List<Id>.class);
        List<CaseTeamMember> caseTeamsToReAdd = new List<CaseTeamMember> ();
        List<CaseTeamMember> caseTeamsToRemove = new List<CaseTeamMember> ();

        updateCaseTeamAssignment(userToReconcile, caseTeamsToReAdd, caseTeamsToRemove);

        if (!caseTeamsToRemove.isEmpty()) {
            if (caseTeamsToRemove.size() > 5000) {
                //only delete the 5k record, this to avoid DML limit
                List<CaseTeamMember> ctmDelete = new List<CaseTeamMember> ();

                for (Integer i = 0; i < 5000; i++) {
                    ctmDelete.add(caseTeamsToRemove.get(i));
                }

                delete ctmDelete;
            } else {
                delete caseTeamsToRemove;
            }
        }

        if (!caseTeamsToReAdd.isEmpty()) {
            if (caseTeamsToReAdd.size() > 5000) {
                //only insert the 5k record, this to avoid DML limit
                List<CaseTeamMember> ctmReAdd = new List<CaseTeamMember> ();

                for (Integer i = 0; i < 5000; i++) {
                    ctmReAdd.add(caseTeamsToReAdd.get(i));
                }

                Database.SaveResult[] result = Database.insert(ctmReAdd, false);
            } else {
                Database.SaveResult[] result = Database.insert(caseTeamsToReAdd, false);
            }

        }
        //System.debug('ASKHR_CaseTeamReassignment.performCaseTeamDML.Current DML rows count: ' + Limits.getDMLRows() + ' of total: ' + Limits.getLimitDMLRows());
    }

    public static Boolean isProfileUpdatable(string profileName) {
        if (!string.isEmpty(profileName))
        {
            //CMT does not bound to SOQL governor limit
            ASKHR_CaseVisibilityUpdater__mdt[] settings = [Select Profile_List__c from ASKHR_CaseVisibilityUpdater__mdt];

            for (ASKHR_CaseVisibilityUpdater__mdt setting : settings) {
                if (setting.Profile_List__c.containsIgnoreCase(profileName))
                {
                    return true;
                }
            }
        }

        return false;
    }

    /*  @description Check all cases where the User is the Contact and the case team and add into list for reassignment
     *  @param newUserIds Ids of updated user 
     *  @param m_CaseTeamsToReadds  list of CaseTeamMember to readd 
     *  @param m_CaseTeamsToRemoves list of CaseTeamMember to remove       
     */
    private static void updateCaseTeamAssignment(List<Id> newUserIds, List<CaseTeamMember> m_CaseTeamsToReAdds, List<CaseTeamMember> m_CaseTeamsToRemoves) {
        try {
            //get all Cases where the User is the contact for the past 200 days and limiting to 20000 row. this to avoid reaching 10k governor limit for DML operation and 50000 row
            //https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_gov_limits.htm            
            List<Case> userCases = [Select ContactId, Contact.User__r.Id, CaseNumber from Case where ContactId in(Select Id from Contact where User__r.Id in :newUserIds) AND CreatedDate = LAST_N_DAYS : 200 LIMIT 20000];
            //get case team for the user for the past 200 days. this to avoid reaching 10k governor limit for DML operation
            List<CaseTeamMember> caseTeamsToRemoves = [Select Id, MemberId, TeamRoleId, ParentId from CaseTeamMember where MemberId in :newUserIds AND CreatedDate = LAST_N_DAYS : 200 LIMIT 20000];
            List<CaseTeamMember> caseTeamsToReAdds;
            caseTeamsToReAdds = caseTeamsToRemoves.deepClone();

            Map<String, Id> caseTeamRolesMap = ASKHR_CaseService.getCaseTeamRolesByName();
           
            for (Case c : userCases) {
                Boolean isMatched = false;
                for (CaseTeamMember ctm : caseTeamsToRemoves) {
                    if (c.Id == ctm.ParentId) {
                        isMatched = true;
                        break;
                    }
                }

                if (!isMatched) {
                    CaseTeamMember newCtm = new CaseTeamMember();
                    newCtm.ParentId = c.Id;
                    newCtm.MemberId = c.Contact.User__r.Id;
                    newCtm.TeamRoleId = caseTeamRolesMap.get('Case Contact');
                    caseTeamsToReAdds.add(newCtm);
                }
            }

            m_CaseTeamsToRemoves.addAll(caseTeamsToRemoves);
            m_CaseTeamsToReAdds.addAll(caseTeamsToReAdds);
        }
        catch(Exception ex) {
            System.debug('ASKHR_CaseTeamReassignment.updateCaseTeamAssignment.Error: ' + ex.getMessage());
        }
    }
}