({
    doInit: function(component, event) {
        this.loadSexos(component, event);
        this.loadTiposDeTelefonos(component, event);
        this.loadProducts(component, event);
        //Fecha de hoy para validar calendario
        var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
        component.set('v.hoy', today);

        let area = component.get("v.area");
        if(area) {            
            let urlString = window.location.href;
            var url = new URL(urlString);
            url.searchParams.set('area', area + '-datos-paciente');
            window.history.pushState({}, '', url.toString());
        }
    },

    loadSexos : function(component, event) {
        var sexos = component.get("c.getPickListSexo");
        
        sexos.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                var res = response.getReturnValue();
                component.set("v.sexos", res);
                this.createOptionsSexos(component, event);
            }
            else if(state === 'ERROR'){
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        // log the error passed in to AuraHandledException
                        alert('ERROR OCCURED: ' + errors[0].message);
                    }
                } else {
                    alert('Unknown error');
                }
            }
        })
        $A.enqueueAction(sexos);
    },

    createOptionsSexos : function(component, event) {
        var options = [];
        var sexos = component.get("v.sexos");

        for (const sexo of sexos) {
            var obj = {};
            obj["value"] = sexo;
            obj["label"] = sexo;
            options.push(obj);
        }

        component.set("v.optionsSexos", options);
    },

    loadTiposDeTelefonos : function(component, event) {
        var tiposTel = component.get("c.getPickListTiposDeTelefono");
        
        tiposTel.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                var res = response.getReturnValue();
                component.set("v.tiposDeTelefono", res);
                this.createOptionsTiposDeTelefono(component, event);
            }
            else if(state === 'ERROR'){
                alert('ERROR OCCURED.');
            }
        })
        $A.enqueueAction(tiposTel);
    },

    createOptionsTiposDeTelefono : function(component, event) {
        var options = [];
        var tiposDeTelefono = component.get("v.tiposDeTelefono");

        for (const tipos of tiposDeTelefono) {
            var obj = {};
            obj["value"] = tipos;
            obj["label"] = tipos;
            options.push(obj);
        }

        component.set("v.optionsTelefonos", options);
    },

    loadProducts : function(component, event) {
        let area = component.get("v.area");
        if(area){
            let action = component.get("c.getProductos");
            action.setParams({
                area : area,
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if(state === 'SUCCESS'){
                    var res = response.getReturnValue();
                    component.set("v.products", res);
                    this.createOptionsProduct(component, event);
                }
                else if(state === 'ERROR'){
                    console.log('ERROR OCCURED.');
                }
            })
            $A.enqueueAction(action);
        }
    },

    createOptionsProduct : function(component, event) {
        var options = [];
        var products = component.get("v.products");

        for (const product of products) {
            var obj = {};
            obj["value"] = product.Id;
            obj["label"] = product.Name;
            options.push(obj);
        }

        component.set("v.optionsProduct", options);
    },

    setSexo : function(component, event) {
        var selectedOptionValue = event.getParam("value");
        var account = component.get("v.account");
        account.Sexo__c = selectedOptionValue;
        component.set("v.account", account);
    },

    setTipoDeTelefono : function(component, event) {
        var selectedOptionValue = event.getParam("value");
        var account = component.get("v.account");
        account.Tipo_de_telefono__c = selectedOptionValue;
        component.set("v.account", account);  
    },

    setProduct : function(component, event) {
        var selectedOptionValue = event.getParam("value");
        var product = component.get("v.producto");
        product.Formula__c = selectedOptionValue;
        component.set("v.producto", product);
    },

    setMenores : function(component, event) {
        var fechaNacimiento = component.get("v.account").PersonBirthdate;
        var fechaNacimientoDate = new Date(fechaNacimiento);
        var fechaNacimientoDate3Meses = new Date(fechaNacimiento);
        fechaNacimientoDate3Meses.setMonth(fechaNacimientoDate3Meses.getMonth()+3);
        var today = new Date();
        
        var fechaNacimientoDate18Anios = new Date(fechaNacimiento);
        fechaNacimientoDate18Anios.setYear(fechaNacimientoDate18Anios.getFullYear()+18);

        if (fechaNacimientoDate18Anios < today) {
            component.set("v.esMenorA18Anios", false);
        }
        else {
            component.set("v.esMenorA18Anios", true);
        }

        //chequeo si es menor a 3 meses
        if(fechaNacimientoDate < today) {
            if (fechaNacimientoDate3Meses < today) {
                component.set("v.esMenorA3Meses", false);
                component.set("v.noTengoDNI", false);
            }
            else {
                component.set("v.esMenorA3Meses", true);
            }
        }
        else {
            component.set("v.esMenorA3Meses", false);
        }

        //calculo la edad para el input
        var diff_ms = Date.now() - fechaNacimientoDate.getTime();
        var age_dt = new Date(diff_ms); 
        component.set("v.edad", Math.abs(age_dt.getUTCFullYear() - 1970) + ' años');
    },

    siguienteForm : function(component, event){
        //Valido los campos
        var allValid = component.find('formPaciente').reduce(function (validSoFar, inputCmp) {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);

        if (allValid) {
            this.createTrackForm(component);
            this.setNumeroTelefono(component, event);
            document.documentElement.scrollTop = 0;

            var cmpEvent = component.getEvent("changePageEvent");
            cmpEvent.setParams({
                "page" : "2",
            });
            cmpEvent.fire();
        }
    },

    setNumeroTelefono : function(component, event) {
        var codArea = component.get("v.codAreaPaciente");
        var numTelefono = component.get("v.numTelefonoPaciente");

        var account = component.get("v.account");
        account.Phone = codArea+''+numTelefono;
        account.Tel_fono_2__c = codArea+''+numTelefono;
        component.set("v.account", account);
    },

    gotoLogin : function (component, event) {
        let navService = component.find("navService");
        let pageReference = {
            type: 'comm__namedPage',
            attributes: {
                name: 'Home'
            }
        };
        navService.navigate(pageReference);
    },

    setNoTengoDNI : function (component, event) {
        var noTengoDNI = component.get("v.noTengoDNI");

        if(noTengoDNI == true) {
            component.set("v.account.DNI__c", "");
        }
    },

    createTrackForm : function(component) {
        let paciente = component.get("v.account");
        let trackForm = component.get("v.trackForm");
        trackForm.Datos_Paciente__c = paciente.LastName + ', ' + paciente.FirstName + ' - ' + paciente.DNI__c;
        trackForm.Ingreso_datos_de_paciente__c = true;
        component.set("v.trackForm", trackForm);
    },
})