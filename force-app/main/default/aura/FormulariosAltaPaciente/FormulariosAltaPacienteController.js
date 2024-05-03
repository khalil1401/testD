({
    doInit : function(component, event, helper) {        
        helper.setArea(component, event);
    },

    siguientePagina : function(component, event, helper) {
        helper.changePage(component, event, helper);
    },
})