({
    doInit : function (component, event, helper){ 
		let staticResourceName = component.get("v.recursoEstatico");
		if(!staticResourceName){
			return;
		}
		component.set("v.rutaRecursoEstatico", $A.get('$Resource.' + staticResourceName)); 
    },
})