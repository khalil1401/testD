({
    doInit : function (component, event, helper){ 
		helper.validateUserLogging(component);
        helper.loadBackgroundImage(component,event);
        helper.createComponent(component,event);
    },
    
    onMouseOver: function (component,event,helper) {  
        helper.showHover(component); 
    },
    
    onMouseOut: function (component,event,helper) { 
        helper.hideHover(component); 
    },
    
    handleOnClick : function (component, event, helper) { 
        if(component.get("v.validationExecuted")){
            helper.callForm(component,event); 
        }
    },
    
    handleInitialFormEvent : function(component,event,helper){ 
        helper.setAvailability(component,event);
    },
})