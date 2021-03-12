({
    doInit : function(component, event, helper) 
    {
        var actionArticle = component.get("c.getArticle");

        actionArticle.setParams({
            recordId : component.get("v.recordId")
        });

        actionArticle.setCallback(this, function(response) {
            component.set("v.Article", response.getReturnValue());
        })

        console.log('>> ' + component.get("v.recordId"));
        $A.enqueueAction(actionArticle);


    },
    
    toggleTitle : function(component, event, helper) {
        helper.toggleSection(component, event, 'titleSection');
    },   
    
    toggleUrlName : function(component, event, helper) {
        helper.toggleSection(component, event, 'urlNameSection');
    },    
    
    toggleQuestion : function(component, event, helper) {
        helper.toggleSection(component, event, 'questionSection');
    },   
    
    toggleAnswer : function(component, event, helper) {
        helper.toggleSection(component, event, 'answerSection');
    },
    
    toggleQA : function(component, event, helper) {
        helper.toggleSection(component, event, 'QASection');
    },
    
    toggleCsr : function(component, event, helper) {
        helper.toggleSection(component, event, 'CsrSection');
    },
        
    toggleMgr : function(component, event, helper) {
        helper.toggleSection(component, event, 'MgrSection');
    },
            
    toggleLinks : function(component, event, helper) {
        helper.toggleSection(component, event, 'LinksSection');
    },
            
    toggleReviewDate : function(component, event, helper) {
        helper.toggleSection(component, event, 'ReviewDateSection');
    }     
})