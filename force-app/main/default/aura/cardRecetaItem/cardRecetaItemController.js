({
    doInit : function(component, event, helper) {
		let staticResourceName = component.get("v.nombreRecursoEstatico");
		if(!staticResourceName){
			return;
		}
		component.set("v.rutaRecursoEstatico", $A.get('$Resource.' + staticResourceName)); 
    }
})