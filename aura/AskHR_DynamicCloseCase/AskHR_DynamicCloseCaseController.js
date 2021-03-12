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
    handleSuccess : function(component, event, helper) {
        // refresh view so that the fields on the case gets updated.
        $A.get("e.force:refreshView").fire();
        
        component.set("v.showPopup", false);
    }
})