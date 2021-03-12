({
	doInit : function(component, event, helper) {
		helper.loadCloseCaseLayoutFields(component, event, helper);
	},
	showCloseCaseModal : function(component, event, helper) {
		component.set("v.showPopup", true);
	},
	hideCloseCaseModal : function(component, event, helper) {
		component.set("v.showPopup", false);
	},
    
    //After record is updated successfully, refresh view and close the quick action.
    handleSubmit : function(component, event, helper) {
		event.preventDefault();       				// Stop the form from submitting
		const fields = event.getParam('fields');	// Get list of fields from controller
		fields[fields.length] = 'Status';
		fields.Status = 'Closed'; 					// Set status to Closed
		component.find('CloseCase').submit(fields); // Submit the form to update the case

        // refresh view so that the fields on the case gets updated.
        $A.get("e.force:refreshView").fire();
        
        component.set("v.showPopup", false);
    }
})