@isTest
public class ASKHR_HRNotes_Controller_Test {

    static testMethod void doHRNotes(){
        Case generalHRCase = ASKHR_TestUtility.createGeneralHRCase(); 

        Private_Notes__c notes = new Private_Notes__c(); 
        notes.Case__c = generalHRCase.Id;
        notes.Comments__c = 'testing Private Notes/HR Notes';
        insert notes;               

        ApexPages.currentPage().getParameters().put('CaseId', generalHRCase.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(notes);
        ASKHR_HRNotes_Controller hrController = new ASKHR_HRNotes_Controller(sc);   

        hrController.save();
        hrController.Cancel();

        System.assertEquals(hrController.caseId, generalHRCase.Id);
        System.assertEquals(hrController.newHRNote.Case__c, generalHRCase.Id);
        
        ASKHR_HRNotes_Controller.saveHRNotes(generalHRCase.Id, 'notes');
    }

}