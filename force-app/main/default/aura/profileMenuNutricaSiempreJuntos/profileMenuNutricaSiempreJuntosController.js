({
    goToLogin : function(component, event, helper) {
        helper.login(component, event, helper);
    },

    goToLogout : function(component, event, helper) {
        helper.logOut(component, event, helper);
    },

    showList : function(component, event, helper) {
        let value = component.get("v.showList");
        component.set("v.showList", !value);
    },

    goTo : function(component, event, helper) {
        helper.redirect(component, event, helper);
    },

    showModalProfile : function(component, event, helper) {
        helper.showModal(component, event, helper);
    },
})