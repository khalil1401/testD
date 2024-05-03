({
    doInit: function(component, event) {
        this.loadProvincias(component, event);

        let area = component.get("v.area");
        if(area) {            
            let urlString = window.location.href;
            var url = new URL(urlString);
            url.searchParams.set('area', area + '-datos-direccion');
            window.history.pushState({}, '', url.toString());
        }
    },

    loadProvincias : function(component, event) {
        var provincia = component.get("v.provincia");
        var action = component.get("c.getPickListProvincias");
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            component.set("v.showSpinner", false);
            if(state === 'SUCCESS'){
                var res = response.getReturnValue();
                component.set("v.provincias", res);
                this.createOptionsProvincias(component, event);
                if (provincia != '') {
                    this.loadMunicipios(component, event);
                }
            }
            else if(state === 'ERROR'){
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        alert('ERROR OCCURED: ' + errors[0].message);
                    }
                }
            }
        })
        $A.enqueueAction(action);
    },

    createOptionsProvincias : function(component, event) {
        var options = [];
        var provincias = component.get("v.provincias");

        for (const provincia of provincias) {
            var obj = {};
            obj["value"] = provincia;
            obj["label"] = provincia;
            options.push(obj);
        }

        component.set("v.optionsProvincias", options);
    },

    loadMunicipios : function(component, event) {
        var provincia = component.get("v.provincia");
        var action = component.get("c.getPickListMunicipios");
        action.setParams({
            provincia : provincia
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                var res = response.getReturnValue();
                component.set("v.municipios", res);
                this.createOptionsMunicipios(component, event);
                if(res.length == 1){
                    component.set("v.municipio", res[0].Id);
                }
            }
            else if(state === 'ERROR'){
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log('ERROR OCCURED: ' + errors[0].message);
                    }
                }
            }
        })
        $A.enqueueAction(action);
    },

    createOptionsMunicipios : function(component, event) {
        var options = [];
        var municipios = component.get("v.municipios");

        for (const municipio of municipios) {
            var obj = {};
            obj["value"] = municipio.Id;
            obj["label"] = municipio.Name;
            options.push(obj);
        }

        component.set("v.optionsMunicipios", options);
    },

    cargarMunicipios : function(component, event) {
        this.loadMunicipios(component, event);
        component.set("v.municipio", '');
        component.set("v.municipioSeleccionado", false);
    },

    cargarLocalidades : function(component, event) {
        component.set("v.municipioSeleccionado", true);
    },

    siguienteForm : function(component, event) {
        //Valido los campos
        var allValid = component.find('formPaciente').reduce(function (validSoFar, inputCmp) {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);

        var localidad = component.get("v.account.Localidad_look__c");
        
        if (allValid && localidad != '') {
            this.editTrackForm(component);
            this.setCamposACuenta(component, event);
            document.documentElement.scrollTop = 0;

            var cmpEvent = component.getEvent("changePageEvent");
            cmpEvent.setParams({
                "page" : "4"
            });
            cmpEvent.fire();
        }
    },

    anteriorForm : function(component, event) {
        document.documentElement.scrollTop = 0;

        var cmpEvent = component.getEvent("changePageEvent");
        cmpEvent.setParams({
            "page" : "2"
        });
        cmpEvent.fire();
    },

    setCamposACuenta : function(component, event) {
        var calle = component.get("v.calle");
        var altura = component.get("v.altura");
        var piso = component.get("v.piso");
        var dpto = component.get("v.dpto");

        component.set('v.account.Direccion__c', calle+' '+altura+' '+piso+' '+dpto);
    },

    editTrackForm : function(component){
        let trackForm = component.get("v.trackForm");
        trackForm.Ingreso_datos_de_direccion__c = true;
        component.set("v.trackForm", trackForm);
    }
})