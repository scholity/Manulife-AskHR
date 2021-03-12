({
	init : function(component, event, helper) {
        // The Feedback text is in Custom Label with three parts in it seperated by ;
		var feedbackText = $A.get("$Label.c.ASKHR_Single_Article_Feedback_Text").split(';');
        component.set("v.feedbackText", feedbackText);
        
        // Get the comment label from Custom Label. The Custom Label has to parts 
        // seperated by ;
        // So split the text and take first part.
        var feedbackCommentLabel = $A.get("$Label.c.ASKHR_Article_Feedback_Text").split(';')[0];
        //06/25/2020 fix for smoke testing in UAT bug. replace the link {caselink} in text to point to Submit Case Page
		feedbackCommentLabel = feedbackCommentLabel.replace('{caselink}', '../contactsupport');
        //feedbackCommentLabel.
        component.set("v.feedbackCommentLabel", feedbackCommentLabel);
        
        // Note: Get the visibility settings from metadata ASKHR_Global_Setting__mdt by calling the
        // method getInitData of Apex Controller.
        helper.loadInitData(component, event, helper);
	},
	yesClicked : function(component, event, helper) {
        // User clicked Yes, disable Yes and No button and submit feedback with isArticleHelpful true
        component.set("v.yesButtonDisabled", true);
        component.set("v.noButtonDisabled", true);
        component.set("v.isArticleHelpful", true);
        
        // Call controller method to save feedback
        helper.insertFeedback(component, event, helper);
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
        // Disable the submit button to avoid duplicate submit.
        component.set("v.submitDisabled", true);
        component.set("v.isArticleHelpful", false);
        
        // Call controller method to save feedback
        helper.insertFeedback(component, event, helper);
	},
})