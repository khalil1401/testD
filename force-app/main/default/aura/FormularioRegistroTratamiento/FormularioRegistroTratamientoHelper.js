({
    doInit: function(component, event) {
        this.loadDiagnosticos(component, event);
        this.loadPatologias(component, event);
        this.createOptionsAlimentacion(component, event);
        //Desafios del creciemiento
        this.loadScreening(component, event);
        this.loadHerramientasScreening(component, event);
        this.loadResultadosScreening(component, event);

        let area = component.get("v.area");
        if(area) {            
            let urlString = window.location.href;
            var url = new URL(urlString);
            url.searchParams.set('area', area + '-datos-tratamiento');
            window.history.pushState({}, '', url.toString());
        }
    },

    crearDatos : function(component, event) {
        let area = component.get("v.area");
        let centro = component.get("v.tratamiento.Centro_de_tratamiento__c");
        let profesional = component.get("v.tratamientoProfesional.Profesional__c");
        let noTengoObraSocial = component.get("v.noTengoObraSocial");
        let obraSocial = component.get("v.account.Obra_social__c");
        let archivo = component.get("v.archivo");
        let files = component.get("v.fileToBeUploaded");

        let allValid = component.find('formPaciente').reduce(function (validSoFar, inputCmp) {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);

        if (profesional === '' || (centro === '' && area != 'Alergia')){ 
            allValid = false;
        }

        if((!noTengoObraSocial && obraSocial === '')) {
            allValid = false;
            component.set("v.campoObraSocialPhone", true);
        }

        if(!files || !archivo) {
            component.set("v.faltaImagen", true);
            allValid = false;
        }

        if (allValid) {
            this.editTrackForm(component);
            document.documentElement.scrollTop = 0;

            var cmpEvent = component.getEvent("changePageEvent");
            cmpEvent.setParams({
                "page" : "final"
            });
            cmpEvent.fire();
        }
    },

    anteriorForm : function(component, event) {
        let tratamiento = component.get("v.tratamiento");

        component.set("v.nombreDeArchivo", null);
        document.documentElement.scrollTop = 0;

        var cmpEvent = component.getEvent("changePageEvent");
        cmpEvent.setParams({
            "page" : "3"
        });
        cmpEvent.fire();
    },

    loadDiagnosticos : function(component, event) {
        var diagnosticos = component.get("c.getPickListDiagnosticos");
        
        diagnosticos.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                var res = response.getReturnValue();
                component.set("v.diagnosticos", res);
                this.createOptionsDiagnosticos(component, event);
            }
            else if(state === 'ERROR'){
                console.log('ERROR OCCURED.');
            }
        })
        $A.enqueueAction(diagnosticos);
    },

    createOptionsDiagnosticos : function(component, event) {
        var options = [];
        var diagnosticos = component.get("v.diagnosticos");

        for (const diagnostico of diagnosticos) {
            var obj = {};
            obj["value"] = diagnostico;
            obj["label"] = diagnostico;
            options.push(obj);
        }

        component.set("v.optionsDiagnosticos", options);
    },

    setDiagnostico : function(component, event) {
        var selectedOptionValue = event.getParam("value");
        var tratamiento = component.get("v.tratamiento");
        tratamiento.Diagnostico__c = selectedOptionValue;
        component.set("v.tratamiento", tratamiento);

        if (tratamiento.Diagnostico__c === 'No') {
            var tratamiento = component.get("v.tratamiento");
            tratamiento.Patologia__c = '';
            component.set("v.tratamiento", tratamiento);  
            this.createOptionsPatologias(component, event);
        }
    },
    
    loadPatologias : function(component, event) {
        let area = component.get("v.area");
        var action = component.get("c.getPickListPatologias");
        action.setParams({
            area : area
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                var res = response.getReturnValue();
                component.set("v.patologias", res);
                this.createOptionsPatologias(component, event);
            }
            else if(state === 'ERROR'){
                var errors = response.getError()
                console.log(errors[0].message);
            }
        })
        $A.enqueueAction(action);
    },

    createOptionsPatologias : function(component, event) {
        var options = [];
        var patologias = component.get("v.patologias");

        for (const patologia of patologias) {
            var obj = {};
            obj["value"] = patologia;
            obj["label"] = patologia;
            options.push(obj);
        }

        component.set("v.optionsPatologias", options);
    },

    createOptionsAlimentacion : function(component, event) {
        var options = [];

        var obj = {};
        obj["value"] = 'SNO';
        obj["label"] = 'Oral';
        options.push(obj);

        var obj = {};
        obj["value"] = 'SNE';
        obj["label"] = 'Enteral';
        options.push(obj);

        component.set("v.optionsAlimentacion", options);
    },

    setAlimentacion : function(component, event) {
        var selectedOptionValue = event.getParam("value");
        var tratamiento = component.get("v.tratamiento");
        tratamiento.Alimentacion__c = selectedOptionValue;
        component.set("v.tratamiento", tratamiento);
    },
    
    loadScreening : function(component, event) {
        var action = component.get("c.getPickListScreeningNutricional");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                var res = response.getReturnValue();
                component.set("v.screening", res);
                this.createOptionsScreening(component, event);
            }
            else if(state === 'ERROR'){
                var errors = response.getError();
                console.log(errors[0].message);
            }
        })
        $A.enqueueAction(action);
    },

    createOptionsScreening : function(component, event) {
        var options = [];
        var screening = component.get("v.screening");

        for (const value of screening) {
            var obj = {};
            obj["value"] = value;
            obj["label"] = value;
            options.push(obj);
        }

        component.set("v.optionsScreening", options);
    },

    loadHerramientasScreening : function(component, event) {
        var action = component.get("c.getPickListHerramientasScreening");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                var res = response.getReturnValue();
                component.set("v.herramientasScreening", res);
                this.createOptionsHerramientasScreening(component, event);
            }
            else if(state === 'ERROR'){
                var errors = response.getError();
                console.log(errors[0].message);
            }
        })
        $A.enqueueAction(action);
    },

    createOptionsHerramientasScreening : function(component, event) {
        var options = [];
        var herramientasScreening = component.get("v.herramientasScreening");

        for (const value of herramientasScreening) {
            var obj = {};
            obj["value"] = value;
            obj["label"] = value;
            options.push(obj);
        }

        component.set("v.optionsHerramientasScreening", options);
    },

    loadResultadosScreening : function(component, event){
        var action = component.get("c.getPickListResultadosScreening");
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                var res = response.getReturnValue();
                component.set("v.resultadosScreening", res);
                this.createOptionsResultadosScreening(component, event);
            }
            else if(state === 'ERROR'){
                var errors = response.getError();
                console.log(errors[0].message);
            }
        })
        $A.enqueueAction(action);
    },

    createOptionsResultadosScreening : function(component, event){
        var options = [];
        var resultadosScreening = component.get("v.resultadosScreening");

        for (const value of resultadosScreening) {
            var obj = {};
            obj["value"] = value;
            obj["label"] = value;
            options.push(obj);
        }

        component.set("v.optionsResultadosScreening", options);
    },

    setScreening : function(component, event) {
        var selectedOptionValue = event.getParam("value");
        if(selectedOptionValue == 'No'){
            var tratamiento = component.get("v.tratamiento");
            tratamiento.Herramienta_Screening_Nutricional__c = '';
            tratamiento.Resultado_Screening_Nutricional__c = '';
            component.set("v.tratamiento", tratamiento);
        }
    },

    deleteObraSocial: function (component, event) {
        var obraSocialCheck = component.get("v.noTengoObraSocial");

        if(obraSocialCheck) {
            component.set("v.account.Obra_social__c", null);
            component.set("v.campoObraSocialPhone", false);
            component.set("v.valorObraSocial", '');
        }
    },

    setArchivo: function (component, event, helper) {
        let files = component.get("v.fileToBeUploaded");
        component.set("v.faltaImagen", false);
        component.set("v.fileLimit", false);
        if (files && files.length > 0) {
            let archivo = files[0][0];
            if(3072 > archivo.size / 1024 && archivo.type == 'application/pdf'){
                component.set("v.archivo", archivo);
                component.set("v.nombreDeArchivo", archivo.name);
            }
            else if(20480 > archivo.size / 1024 && (archivo.type == 'image/jpeg' || archivo.type == 'image/png')){
                component.set("v.archivo", archivo);
                component.set("v.nombreDeArchivo", archivo.name);
            }
            else{
                component.set("v.fileToBeUploaded", null);
                component.set("v.archivo", null);
                component.set("v.nombreDeArchivo", null);
                component.set("v.fileLimit", true);
            }
        }
    },

    editTrackForm : function(component){
        let trackForm = component.get("v.trackForm");
        trackForm.Solicito_Kit_de_Inicio__c = true;
        component.set("v.trackForm", trackForm);
    },
})