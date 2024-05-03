({
    doInit: function(component, event) {
        this.loadRelaciones(component, event);
        this.loadTiposDeTelefonoContacto(component, event);

        let area = component.get("v.area");
        if(area) {            
            let urlString = window.location.href;
            var url = new URL(urlString);
            url.searchParams.set('area', area + '-datos-contactos');
            window.history.pushState({}, '', url.toString());
        }
    },

    siguienteForm : function(component, event) {
        let contact = component.get("v.contact");
        let codArea = component.get("v.codArea");
        let numTelefono = component.get("v.numTelefono");
        let contactEmpty = contact.FirstName == '' || contact.LastName == '' || contact.DNI__c  == '' || 
            contact.Email == '' || contact.Relacion__c  == '' || contact.Tipo_de_Telefono_de_Contacto__c == ''
            || codArea == '' || numTelefono == '';
        let menor = component.get("v.esMenorA18Anios");

        if(menor && contactEmpty){
            component.set("v.mensajeContactoObligatorio", true);
        }   
        else{
            let allValid = component.find('formPaciente').reduce(function (validSoFar, inputCmp) {
                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            }, true);
        
            if (allValid) {
                this.editTrackForm(component);
                this.setNumeroTelefono(component, event);
                document.documentElement.scrollTop = 0;
    
                var cmpEvent = component.getEvent("changePageEvent");
                cmpEvent.setParams({
                    "page" : "3"
                });
                cmpEvent.fire();
            }    
        }
    },

    anteriorForm : function(component, event) {
        document.documentElement.scrollTop = 0;

        var cmpEvent = component.getEvent("changePageEvent");
        cmpEvent.setParams({
            "page" : "1"
        });
        cmpEvent.fire();
    },

    loadRelaciones : function(component, event) {
        var relaciones = component.get("c.getPickListRelacionContacto");
        
        relaciones.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                var res = response.getReturnValue();
                component.set("v.relaciones", res);
                this.createOptionsRelaciones(component, event);
            }
            else if(state === 'ERROR'){
                console.log('ERROR OCCURED.');
            }
        })
        $A.enqueueAction(relaciones);
    },

    createOptionsRelaciones : function(component, event) {
        var options = [];
        var relaciones = component.get("v.relaciones");

        for (const relacion of relaciones) {
            var obj = {};
            obj["value"] = relacion;
            obj["label"] = relacion;
            options.push(obj);
        }

        component.set("v.optionsRelaciones", options);
    },

    loadTiposDeTelefonoContacto : function(component, event) {
        var action = component.get("c.getPickListTiposDeTelefonoContacto");
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                var res = response.getReturnValue();
                component.set("v.tiposDeTelefonoContacto", res);
                this.createOptionsTiposDeTelefonoContacto(component, event);
            }
            else if(state === 'ERROR'){
                console.log('ERROR OCCURED.');
            }
        })
        $A.enqueueAction(action);
    },

    createOptionsTiposDeTelefonoContacto : function(component, event) {
        var options = [];
        var tiposDeTelefonoContacto = component.get("v.tiposDeTelefonoContacto");

        for (const tipoDeTelefonoContacto of tiposDeTelefonoContacto) {
            var obj = {};
            obj["value"] = tipoDeTelefonoContacto;
            obj["label"] = tipoDeTelefonoContacto;
            options.push(obj);
        }

        component.set("v.optionsTiposDeTelefonoContacto", options);
    },

    setRelacion : function(component, event) {
        var selectedOptionValue = event.getParam("value");
        var contact = component.get("v.contact");
        contact.Relacion__c = selectedOptionValue;
        component.set("v.contact", contact);
    },

    setRelacionContact2 : function(component, event) {
        var selectedOptionValue = event.getParam("value");
        var contact = component.get("v.contact2");
        contact.Relacion__c = selectedOptionValue;
        component.set("v.contact2", contact);
    },

    setNumeroTelefono : function(component, event) {
        var codArea = component.get("v.codArea");
        var numTelefono = component.get("v.numTelefono");

        var contact = component.get("v.contact");
        contact.Phone = codArea+''+numTelefono;
        component.set("v.contact", contact);

        var otroContacto = component.get("v.agregarOtroContacto");

        if (otroContacto) {
            var codArea2 = component.get("v.codAreaContact2");
            var numTelefono2 = component.get("v.numTelefonoContact2");
    
            var contact2 = component.get("v.contact2");
            contact2.Phone = codArea2+''+numTelefono2;
            component.set("v.contact2", contact2); 
        }
    },

    agregarSegundoContacto : function(component, event) {
        component.set("v.agregarOtroContacto", true);
    },

    eliminarSegundoContacto : function(component, event) {
        component.set("v.agregarOtroContacto", false);
        component.set("v.contact2.FirstName", '');
        component.set("v.contact2.LastName", '');
        component.set("v.contact2.DNI__c", '');
        component.set("v.codAreaContact2", '');
        component.set("v.numTelefonoContact2", '');
        component.set("v.contact2.Email", '');
        component.set("v.contact2.Relacion__c", '');
        component.set("v.contact2.Principal__c", false);
    },

    editTrackForm : function(component){
        let trackForm = component.get("v.trackForm");
        trackForm.Ingreso_datos_de_contacto__c = true;
        component.set("v.trackForm", trackForm);
    }
})