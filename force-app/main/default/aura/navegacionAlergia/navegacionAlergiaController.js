({
    doInit : function(component, event, helper) {
        var sPageURL = decodeURIComponent(window.location.href);
        var sURLVariables = sPageURL.split('/');
        component.set("v.currentPage", sURLVariables[sURLVariables.length-1]);
        //Set device
        var device = $A.get("$Browser.formFactor");
		if(device === 'DESKTOP'){
			component.set('v.isDesktop', true);
            helper.selectTab(component, event, helper);
		}
        else{
			component.set('v.isDesktop', false);
            helper.selectTab(component, event, helper);
        }
    },
    redirectToRedSocial : function(component, event, helper) {
        helper.goToRedSocial(component, event, helper);
    },
    redirectToPortalPage : function(component, event, helper) {
        helper.goToPortalPage(component, event, helper);
    },
})