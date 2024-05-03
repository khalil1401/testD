({
    doInit : function(component, event, helper) {
		let staticResourceName = component.get("v.nombreRecursoEstatico");
		if(!staticResourceName){
			return;
		}
		component.set("v.rutaRecursoEstatico", staticResourceName);
    },
    redireccionar : function(component, event, helper) {
		helper.goToSeccion(component, event);
	},
})