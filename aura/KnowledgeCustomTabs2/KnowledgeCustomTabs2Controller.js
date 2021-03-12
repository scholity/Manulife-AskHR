({
    doInit : function(component, event, helper) {
        helper.loadArticleData(component, event, helper);
    },

    toggleField : function(component, event, helper) {
        helper.showHideField(component, event, helper)
    },
    
	jumpToAnchor: function(component, event, helper) {
    	var anchor = component.find(event.target.id.replace('link_',''));
    	anchor.getElement().scrollIntoView();
	}    
})