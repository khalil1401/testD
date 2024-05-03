({
    doInit: function(component, event) {      
        var objeto = component.get("v.objeto");

        if (objeto === 'Localidad') {
            this.loadOptionsLocalidades(component, event);
        }
        if (objeto === 'Institucion') {
            this.loadOptionsInstitucion(component, event);
        }
        if (objeto === 'Profesional') {
            this.loadOptionsProfesionales(component, event);
        }
        if (objeto === 'Obra Social') {
            this.loadOptionsObrasSociales(component, event);
        }
    },
    
    reloadLocalidades: function(component, event) {
        component.set("v.value", '');
        component.set("v.itemSelected", '');
        component.set("v.existeSeleccionado", false);
        this.loadOptionsLocalidades(component, event);
    },

    loadOptionsLocalidades: function(component, event) {
        var idMunicipio = component.get("v.idMunicipio");
        var action = component.get("c.getLocalidades");
        action.setParams({
            idMunicipio : idMunicipio,
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                var res = response.getReturnValue();
//                component.set("v.optionsComponent", res);
                if(res.length == 1){
                    component.set("v.value", res[0].Name);
                    component.set("v.itemSelected", res[0].Id);
                    component.set("v.existeSeleccionado", true);            
                }
                else{
                    component.set("v.options", res);
                }
            }
            else if(state === 'ERROR'){
                var errors = response.getError();
                if (errors.length > 0) {
                    console.log(errors[0].message);
                }
                else {
                    console.log('Unknown error');
                }
            }
        })
        $A.enqueueAction(action);
    },

    loadOptionsInstitucion: function(component, event) {
        var action = component.get("c.getInstituciones");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                var res = response.getReturnValue();
                component.set("v.options", res);
//                component.set("v.optionsComponent", res);
            }
            else if(state === 'ERROR'){
                var errors = response.getError();
                if (errors.length > 0) {
                    console.log(errors[0].message);
                }
                else {
                    console.log('Unknown error');
                }
            }
        })
        $A.enqueueAction(action);
    },

    loadOptionsProfesionales: function(component, event) {
        var action = component.get("c.getProfesionales");
        action.setCallback(this, function(response) {
            var state = response.getState();
            this.dispatchEvent(component, event);
            if(state === 'SUCCESS'){
                var res = response.getReturnValue();
                component.set("v.options", res);
            }
            else if(state === 'ERROR'){
                var errors = response.getError();
                component.set("v.loadSpinner", false);
                if (errors.length > 0) {
                    console.log(errors[0].message);
                }
                else {
                    console.log('Unknown error');
                }
            }
        })
        $A.enqueueAction(action);
    },

    loadOptionsObrasSociales: function(component, event) {
        var action = component.get("c.getObrasSociales");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                var res = response.getReturnValue();
                component.set("v.options", res);
//                component.set("v.optionsComponent", res);
            }
            else if(state === 'ERROR'){
                var errors = response.getError();
                if (errors.length > 0) {
                    console.log(errors[0].message);
                }
                else {
                    console.log('Unknown error');
                }
            }
        })
        $A.enqueueAction(action);
    },

    filtrar : function(component, event) {
        var input = component.get("v.value");
        var options = component.get("v.options");
        let cantCaracteres = component.get("v.caracteresFiltro");

        if (input.length >= cantCaracteres) {
            component.set("v.loadSpinner",true);
            var newArray = options.filter(function (el) {
                return el.Name.toLowerCase().includes(input.toLowerCase());
            });
            
            component.set("v.optionsComponent", newArray);
            component.set("v.loadSpinner", false);
            component.set("v.itemSelected", '');
            component.set("v.existeSeleccionado", false);
        }
        else{
            component.set("v.optionsComponent", []);
            component.set("v.itemSelected", '');
            component.set("v.existeSeleccionado", false);
        }
    },

    setSeleccionado : function(component, event) {
        component.set("v.itemSelected", event.currentTarget.dataset.value);
        component.set("v.value", event.currentTarget.dataset.nombre.toUpperCase());
        component.set("v.existeSeleccionado", true);
    },

    dispatchEvent : function(component, event){
        var cmpEvent = component.getEvent("lookupFormEvent");
        cmpEvent.setParams({
            "message" : "false",
        });
        cmpEvent.fire();
    }
})