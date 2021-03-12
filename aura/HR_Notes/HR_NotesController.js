({
	doInit : function(component, event, helper) {
        	component.set('v.recordId', component.get("v.pageReference").state.id);
        // window.open("/lightning/n/HR_Notes?id={!Case.Id}");
		console.log(component.get('v.recordId'));
    	}
})