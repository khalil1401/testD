({
    setDevice : function(component, event){
        var device = $A.get("$Browser.formFactor");
		if(device === 'DESKTOP'){
			component.set('v.isDesktop', true);
		}
        else{
			component.set('v.isDesktop', false);
        }
    }

})