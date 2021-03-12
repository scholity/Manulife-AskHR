({
	doInit : function(component, event, helper) {
		helper.loadCloseCaseLayoutFields(component, event, helper);
	},
    
    //After record is updated successfully, refresh view and close the quick action.
    handleSuccess : function(component, event, helper) {
        // refresh view so that the fields on the case gets updated.
        $A.get("e.force:refreshView").fire();
        
        // close quick action.
        $A.get("e.force:closeQuickAction").fire();
    }
})