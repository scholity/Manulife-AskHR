({
    /*
     * Gets the Article data from the Apex controller method.
    */
    loadArticleData : function(component, event, helper) {

        var actionArticle = component.get("c.getArticleData");

        actionArticle.setParams({
            recordId : component.get("v.recordId")
        });

        actionArticle.setCallback(this, function(response) {
            component.set("v.articleData", response.getReturnValue());
        })

        //console.log('>> ' + component.get("v.recordId"));
        $A.enqueueAction(actionArticle);

    },
    
    /*
     * THis method toggles the show hide of the field that it is clicked on.
    */
    showHideField: function(component, event, helper) {
        var currElement = event.srcElement;
        
        // Find the top level div with class 'outerDivClass' for the field that the user clicked.
        while (currElement != null) {
            //console.log('cuerrElement:' + currElement.className);
            if (currElement.className == 'outerDivClass') {
                break;
            }
            currElement = currElement.parentNode;
        }
        //console.log('cuerrElement2:' + currElement);
        
        helper.setClassOnChildElements(currElement.childNodes, helper);
    },
    
    /*
     * THis method recursively calls all the child elements and if the id of the child is 
     * 'fieldBlock', then toggle the classes 'slds-show' and 'slds-hide'
    */
    setClassOnChildElements: function(childNodes, helper) {
        for (var idx = 0; idx < childNodes.length; idx++) {
        	// if the current Element is not a node then continue
            if (childNodes[idx].nodeType != 1) continue;
            
            //console.log('chil class: ' + childNodes[idx].className);
            //console.log('chil tag: ' + childNodes[idx].tagName);
            //console.log('chil class id: ' + childNodes[idx].getAttribute('id'));
            
            // if node has id 'fieldBlock' then toggle the classes
            if (childNodes[idx].getAttribute('id') == 'fieldBlock') {
            	$A.util.toggleClass(childNodes[idx], 'slds-show');
            	$A.util.toggleClass(childNodes[idx], 'slds-hide');
            }
    		else {
            	// check the child nodes of the current node.
    			helper.setClassOnChildElements(childNodes[idx].childNodes, helper);
			}
        }
	}
})