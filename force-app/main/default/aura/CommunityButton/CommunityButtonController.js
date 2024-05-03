({
    doInit : function (component, event, helper){ 
        let openLink = component.get("v.openLink");
        if(openLink) {
            component.set("v.validationExecuted", true); 
            component.set("v.isLoading", false);  
        } else {
            helper.createComponent(component,event);
        }
        helper.setURls(component,event);
    },
    
    onMouseOver: function (component,event,helper) {  
        helper.showHover(component); 
    },
    
    onMouseOut: function (component,event,helper) { 
        helper.hideHover(component);
    },
    
    handleInitialFormEvent : function(component,event,helper){ 
        helper.setAvailability(component,event);
    },
})