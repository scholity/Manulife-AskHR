({
    toggleSection : function(component, event, sectionId) {
        var acc = component.find(sectionId);
        for(var cmp in acc) {
            $A.util.toggleClass(acc[cmp], 'slds-show');  
            $A.util.toggleClass(acc[cmp], 'slds-hide');  
        }
    }
})