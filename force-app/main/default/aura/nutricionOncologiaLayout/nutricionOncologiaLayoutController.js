({
	doInit: function (component, event, helper) {
        var device = $A.get("$Browser.formFactor");
		if(device === 'DESKTOP'){
			component.set('v.isDesktop', true);
		}
        else{
			component.set('v.isDesktop', false);
        }
	}
})