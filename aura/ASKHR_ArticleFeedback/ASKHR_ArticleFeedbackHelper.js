({
    /*
     * Note: Get the visibility settings from metadata ASKHR_Global_Setting__mdt by calling the
     * method getInitData of Apex Controller.
    */
	loadInitData : function(component, event, helper) {
		var actionArticle = component.get("c.getInitData");

        actionArticle.setParams({
            recordId : component.get("v.recordId")
        });

        actionArticle.setCallback(this, function(response) {
            component.set("v.isFeedbackVisible", response.getReturnValue());
        })

        //console.log('>> ' + component.get("v.recordId"));
        $A.enqueueAction(actionArticle);
	},
    
    /*
     * Save the feedback by calling the method saveFeedback of Apex Controller.
    */
	insertFeedback : function(component, event, helper) {
		var actionArticle = component.get("c.saveFeedback");

        actionArticle.setParams({
            recordId : component.get("v.recordId"),
            description : component.get("v.comments"),
            isArticleHelpful : component.get("v.isArticleHelpful")
        });

        actionArticle.setCallback(this, function(response) {
        	// Hide initial question and submit comment form and show Thank You message
            component.set("v.showQuestion", false);
            component.set("v.showSubmitComment", false);
        	component.set("v.showThankyou", true);
        })

        //console.log('>> ' + component.get("v.recordId"));
        $A.enqueueAction(actionArticle);
	},
})