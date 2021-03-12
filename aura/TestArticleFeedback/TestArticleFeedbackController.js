({
	init : function(component, event, helper) {
        // THe Feedback text isin Custom Label with three parts in it seperated by ;
		var feedbackText = $A.get("$Label.c.ASKHR_Single_Article_Feedback_Text").split(';');
        component.set("v.feedbackText", feedbackText);
        
        // Get the comment label from Custom Label. The Custom Label has to parts 
        // seperated by ;
        // So split the text and take first part.
        var feedbackCommentLabel = $A.get("$Label.c.ASKHR_Article_Feedback_Text").split(';')[0];
        //feedbackCommentLabel.
        component.set("v.feedbackCommentLabel", feedbackCommentLabel);
	},
	yesClicked : function(component, event, helper) {
        // User clicked Yes, hide the question and show Thank You message
        component.set("v.showQuestion", false);
        component.set("v.showThankyou", true);
	},
	noClicked : function(component, event, helper) {
        // User clicked No, hide the question and provide option to submit comment.
        component.set("v.showQuestion", false);
        component.set("v.showSubmitComment", true);
	},
    commentsChanged : function(component, event, helper) {
        // If comments are entered, enable submit button.
        var comments = component.get("v.comments");
        if (comments != null && comments.trim().length > 0) {
            component.set("v.submitDisabled", false);
        } else {
            component.set("v.submitDisabled", true);
        }
	},
    submitComment : function(component, event, helper) {
        
	},
})