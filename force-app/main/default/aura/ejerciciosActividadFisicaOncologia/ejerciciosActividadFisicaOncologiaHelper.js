({
    setDevice : function(component, event) {
        var device = $A.get("$Browser.formFactor");
		if(device === 'DESKTOP'){
			component.set('v.isDesktop', true);
		}
        else{
			component.set('v.isDesktop', false);
        }
    },
    getTiposDeEjercicios : function(component, event) {

        var action = component.get("c.getTiposDeEjerciciosOncologia");
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
//                var res = response.getReturnValue();
                var res = response.getReturnValue();
                component.set("v.tiposEjercicios", res);
                console.log(res);
                if(res.length > 0){
                    component.set("v.tipoEjercicio", res[0].Ejercicio__c);
                    this.getEjercicios(component, event);
                }
                component.set("v.isLoading", false);
            }
            else if(state === 'ERROR'){
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                }
            }
        })
        $A.enqueueAction(action);

    },
    getEjercicios : function(component, event) {
        component.set("v.isLoading", true);
        const tipoEjercicio = component.get("v.tipoEjercicio");
        var action = component.get("c.getEjercicios");
        action.setParams({
            tipoEjercicio: tipoEjercicio,
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                var res = response.getReturnValue();
                component.set("v.articulos", res);
                component.set("v.articuloSeleccionado", res[0]);
                let staticResourceName = component.get("v.articuloSeleccionado.Imagen__c");
                component.set("v.rutaRecursoEstatico", staticResourceName);
                component.set("v.indiceActual", 0);
                component.set("v.cantidadArticulos", res.length -1 );
                component.set("v.isLoading", false);
            }
            else if(state === 'ERROR'){
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                }
            }
        })
        $A.enqueueAction(action);

    },
    adelantar : function(component, event) {
        let indiceActual = component.get("v.indiceActual");
        const listaArticulos = component.get("v.articulos");
        if(indiceActual + 1 < listaArticulos.length){
            component.set("v.articuloSeleccionado", listaArticulos[indiceActual + 1]);
            let staticResourceName = component.get("v.articuloSeleccionado.Imagen__c");
            component.set("v.rutaRecursoEstatico", staticResourceName);
            component.set("v.indiceActual", indiceActual + 1);
        }
    },
    atrasar : function(component, event) {
        let indiceActual = component.get("v.indiceActual");
        const listaArticulos = component.get("v.articulos");
        if(indiceActual > 0){
            component.set("v.articuloSeleccionado", listaArticulos[indiceActual - 1]);
            let staticResourceName = component.get("v.articuloSeleccionado.Imagen__c");
            component.set("v.rutaRecursoEstatico", staticResourceName);
            component.set("v.indiceActual", indiceActual - 1);
        }
    },
})