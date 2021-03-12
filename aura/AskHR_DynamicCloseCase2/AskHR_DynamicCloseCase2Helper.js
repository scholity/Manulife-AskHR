({
    /*
     * Gets the Close Case Layout fields from the Apex controller method.
    */
	loadCloseCaseLayoutFields : function(component, event, helper) {

        var actionGetFields = component.get("c.getCloseCaseLayoutFields");
        actionGetFields.setParams({
            recordId : component.get("v.recordId")
        });

        actionGetFields.setCallback(this, function(response) {
            component.set("v.closeCaseLayoutFields", response.getReturnValue());
        });
        
        $A.enqueueAction(actionGetFields);
	}
})