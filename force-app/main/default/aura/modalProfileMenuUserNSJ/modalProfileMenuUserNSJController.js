({
	doInit : function(component, event, helper){
		helper.getUser(component, helper);
	},

    goToLogin : function(component, event, helper) {
        helper.login(component, event, helper);
    },

	goToLogout : function(component, event, helper) {
        helper.logOut(component, event, helper);
    },

	goTo : function(component, event, helper){
		helper.redirect(component, event);
	},
})