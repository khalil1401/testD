({
    setIsPaciente : function(component, event){
        let isPaciente = component.get("v.isPaciente");
        if(isPaciente){
            component.set("v.validacionDNI", false);
        }
    },

    createOptionsAreas : function(component, event) {
        var options = [];
        var areas = component.get("v.areasTerapeuticas");

        for (const area of areas) {
            var obj = {};
            obj["value"] = area;
            obj["label"] = area;
            options.push(obj);
        }

        component.set("v.optionsAreas", options);
    },

    close: function(component, event){
        let navService = component.find("navService");
        let pageReference = {
            "type":'comm__namedPage',
            "attributes": {
                "name": 'Home'
            },
         };
        navService.navigate(pageReference);
    },

    getPacientes: function(component, event){
        var dni = component.get("v.account.DNI__c");
        var area = component.get("v.area");
        if(dni && area && dni.length > 6){
            component.set("v.showSpinner", true);
            component.set("v.alertaDNI", false);
            var pacientes = component.get("c.isPaciente");
            pacientes.setParams({
                dni : dni
            });
            pacientes.setCallback(this, function(response) {
                var state = response.getState();
                component.set("v.showSpinner", false);
                if(state === 'SUCCESS'){
                    var res = response.getReturnValue();
                    if(!res){
                        component.set("v.validacionDNI", false);
                        component.set("v.aceptarCondiciones", true);
                    }
                    else{
                        component.set("v.validacionDNI", false);
                        component.set("v.existeDNI", true);
                    }
                }
                else if(state === 'ERROR'){
                    var errors = response.getError();
                    console.log(errors[0].message);
                }
            })
            $A.enqueueAction(pacientes);    
        }
        else{
            component.set("v.alertaDNI", true);
        }
    },

    checkTerminosEIrAFormulario: function(component, event) {
        let checkPoliticaDePrivacidad = document.getElementById("checkPoliticaDePrivacidad").checked;
        let checkTerminosYCondiciones = document.getElementById("checkTerminosYCondiciones").checked;
        let checkConsetimiento = document.getElementById("checkConsetimiento").checked;

        if(checkPoliticaDePrivacidad * checkTerminosYCondiciones * checkConsetimiento == true){
            component.set("v.aceptarCondiciones", false);
            this.siguienteForm(component, event);
        }
        else{
            component.set("v.alertaValidaciones", true);
        }
    },

    setDNI: function(component, event) {
        component.set("v.aceptarCondiciones", false);
        component.set("v.validacionDNI", true);
        component.set("v.alertaValidaciones", false);
    },

    goTo : function(component,event,helper){
		let apiName = event.target.dataset.id;
        let navService = component.find("navService");
        let pageReference = {
           type: 'comm__namedPage',
           attributes: {
               name: apiName
           }
        };

        navService.generateUrl(pageReference)
        .then($A.getCallback(function(url) {
            var base_url = window.location.origin;
            let urlFinal = base_url + url;
            window.open(urlFinal, '_blank');            
        }));

//        navService.navigate(pageReference);
    },

    siguienteForm : function(component, event){
        var cmpEvent = component.getEvent("changePageEvent");
        cmpEvent.setParams({
            "page" : "1",
        });
        cmpEvent.fire();
    },

    changeUrl : function(component){
        let area = component.get("v.area");
        let urlString = window.location.href;
        var url = new URL(urlString);
        url.searchParams.set('area', area);
        window.history.pushState({}, '', url.toString());
    },
})