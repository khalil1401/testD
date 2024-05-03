({
    doInit : function(component, event, helper) {
        helper.setPatologias(component);
    },

    goTo : function(component, event, helper) {
        helper.redirect(component, event);
    },

    hideNav : function(component, event, helper) {
        helper.hideTableNav(component);
    },
})