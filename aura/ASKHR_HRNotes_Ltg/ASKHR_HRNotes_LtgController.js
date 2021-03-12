({
	doInit  : function(component, event, helper) {
		
	},
    
    submitComment : function(component, event, helper) {
        // Insert Notes
        var action = component.get("c.saveHRNotes");

        action.setParams({
            recordId : component.get("v.recordId"),
            notes : component.get("v.Notes")
            
        });
        action.setCallback(this,function(a){
            var state = a.getState();
            if(state === "SUCCESS"){
               

                
                component.set("v.submitDisabled", true);
                component.set("v.Notes", '');
                window.location.reload();
                
            } else if(state === "ERROR"){
                alert('ERROR');
                var errors = action.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        alert(errors[0].message);
                    }
                }
            }else if (status === "INCOMPLETE") {
                alert('No response from server or client is offline.');
            }
        }); 
        
        $A.enqueueAction(action);
	},
    commentsChanged : function(component, event, helper) {
        // If comments are entered, enable submit button.
        var notes = component.get("v.Notes");
        if (notes != null && notes.trim().length > 0) {
            component.set("v.submitDisabled", false);
        } else {
            component.set("v.submitDisabled", true);
        }
	},
    
})