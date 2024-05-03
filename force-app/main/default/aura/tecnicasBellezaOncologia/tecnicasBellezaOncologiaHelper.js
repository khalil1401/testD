({
    getTecnicasDeBelleza : function(component, event) {

        var action = component.get("c.getTecnicasDeBellezaOncologia");
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                var res = response.getReturnValue();
                component.set("v.articulos", res);
                component.set("v.articuloSeleccionado", res[0]);
                let staticResourceName = res[0].Imagen__c;
                component.set("v.rutaImg", staticResourceName);
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
})