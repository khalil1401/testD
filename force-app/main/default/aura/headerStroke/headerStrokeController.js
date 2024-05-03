({
    doInit : function(component, event, helper) {

        let staticResourceName;

        var device = $A.get("$Browser.formFactor");
		if(device === 'DESKTOP'){
            component.set('v.isDesktop', true);
            staticResourceName = component.get("v.recursoEstatico");
		}
        else{
            component.set('v.isDesktop', false);
            staticResourceName = component.get("v.recursoEstaticoMobile");
        }

        let staticResourceNameBoton = component.get("v.recursoEstaticoBoton");
        component.set("v.rutaImg", staticResourceName);
        component.set("v.rutaRecursoEstaticoBoton", staticResourceNameBoton);

    },

    goTo : function(component, event, helper) {
        helper.redirectTo(component, event, helper);
    }
})