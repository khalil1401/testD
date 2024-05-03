({
    getPacientes: function(component, event) {
        var validity = component.find("dni").get("v.validity");
        var dni = component.get("v.DNI");
        if(validity.valid && dni) {
            component.set("v.showSpinner", true);
            this.loadPacientes(component, event);
        }
        else{
            component.set("v.alertaDNI", true);
        }
    },

    loadPacientes : function(component, event){
        var dni = component.get("v.DNI");
        var pacientes = component.get("c.getPacientes");
        pacientes.setParams({
            dni : dni
        });
        pacientes.setCallback(this, function(response) {
            var state = response.getState();
            component.set("v.showSpinner", false);
            if(state === 'SUCCESS'){
                var res = response.getReturnValue();
                component.set("v.pacientes", res);
                var pacientes = component.get("v.pacientes");
                if (pacientes.length > 0) {
                    this.createOptionsPacientes(component, event);
                    component.set("v.isOpen", false);
                    component.set("v.seleccionarPaciente", true);
                }
                else{
                    component.set("v.isOpen", false);
                    component.set("v.noExisteDNI", true);
                }
            }
            else if(state === 'ERROR'){
                var errors = response.getError();
                if (errors) {
                    console.log(errors[0].message);
                }
            }
        })
        $A.enqueueAction(pacientes);
    },

    createOptionsPacientes : function(component, event) {
        var options = [];
        var pacientes = component.get("v.pacientes");

        for (const paciente of pacientes) {
            var obj = {};
            obj["value"] = paciente.Id;
            obj["label"] = paciente.LastName + ', ' + paciente.FirstName;
            options.push(obj);
        }

        component.set("v.optionsPacientes", options);
    },

    setPaciente : function(component, event) {
        var selectedOptionValue = event.getParam("value");
        component.set("v.idPacienteSeleccionado", selectedOptionValue);
        component.set("v.alertaSeleccionarPaciente", false);
        //Me guardo el nombre del paciente seleccionado
        var options = component.get("v.optionsPacientes");
        for(var i = 0; i<options.length; i++) {
            if(options[i].value === selectedOptionValue) {
                component.set("v.nombrePacienteSeleccionado", options[i].label);
            }
        }
    },

    close: function(component, event) {
        let navService = component.find("navService");
        let pageReference = {
            "type":'comm__namedPage',
            "attributes": {
                "name": 'Home'
            },
         };
        navService.navigate(pageReference);
    },

    ingresarDNI: function(component, event) {
        component.set("v.isOpen", true);
        component.set("v.seleccionarPaciente", false);
        component.set("v.alertaSeleccionarPaciente", false);
        component.set("v.alertaDNI", false);
    },

    getUsername: function(component, event) {
        var idPacienteSeleccionado = component.get("v.idPacienteSeleccionado");
        if (idPacienteSeleccionado) {
            component.set("v.showSpinner", true);
            var action = component.get("c.getUser");
            action.setParams({
                idPaciente : idPacienteSeleccionado
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                component.set("v.showSpinner", false);
                if(state === 'SUCCESS'){
                    var res = response.getReturnValue();
                    if(res){
                        component.set("v.username", res.Username);
                        component.set("v.seleccionarPaciente", false);
                        component.set("v.ingresarContrasena", true);
                    }
                    else{
                        component.set("v.seleccionarPaciente", false);
                        component.set("v.esPaciente", true);
                    }
                }
                else if(state === 'ERROR'){
                    var errors = response.getError();
                    if (errors) {
                        console.log(errors[0].message);
                    }
                }
            })
            $A.enqueueAction(action);
        }
        else {
            component.set("v.alertaSeleccionarPaciente", true);
        }
    },

    logearse: function(component, event) {
        var username = component.get("v.username");
        var password = component.get("v.password");
        component.set("v.showSpinner", true);
        
        var action = component.get("c.site");
        action.setParams({
            username : username,
            pass : password
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            component.set("v.showSpinner", false);
            if(state === 'SUCCESS'){
                var res = response.getReturnValue();
                if(res.includes('nombre de usuario y la contraseña son correctos') ||
                    res.includes('Introduzca un valor')){
                    component.set("v.alertaPasswordIncorrecta", true);
                }
            }
            else if(state === 'ERROR'){
                var errors = response.getError();
                if(errors){
                    console.log(errors[0].message);
                }
            }
        })
        $A.enqueueAction(action);
    },

    getEmailUsuario: function(component, event) {
        var username = component.get("v.username");
        component.set("v.showSpinner", true);

        var action = component.get("c.getEmailUsuario");
        action.setParams({
            username : username
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            component.set("v.showSpinner", false);
            if(state === 'SUCCESS'){
                var res = response.getReturnValue();
                component.set("v.emailUsuario", res);
                component.set("v.ingresarContrasena", false);
                component.set("v.confirmacionReestablecerContrasena", true);
            }
            else if(state === 'ERROR'){
                var errors = response.getError();
                if (errors) {
                    console.log(errors[0].message);
                }
            }
        })
        $A.enqueueAction(action);
    },

    enviarMailResetPassword: function(component, event) {
        var username = component.get("v.username");
        var emailUsuario = component.get("v.emailUsuario");
        component.set("v.showSpinner", true);
        
        var action = component.get("c.restablecerPass");
        action.setParams({
            username : username
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            component.set("v.showSpinner", false);
            if(state === 'SUCCESS'){
                var res = response.getReturnValue();
                component.set("v.mensajeEmail", 'Se envió un correo electrónico a ' + emailUsuario);
                component.set("v.confirmacionReestablecerContrasena", false);
                component.set("v.passwordRestablecida", true);
            }
            else if(state === 'ERROR'){
                var errors = response.getError();
                if (errors) {
                    console.log(errors[0].message);
                }
            }
        })
        $A.enqueueAction(action);
    },

    mostrarPacientes: function(component, event) {
        component.set("v.ingresarContrasena", false);
        component.set("v.seleccionarPaciente", true);
        component.set("v.alertaPasswordIncorrecta", false);        
        this.clearData(component);
    },

    mostrarIngresarContrasena: function(component, event) {
        component.set("v.confirmacionReestablecerContrasena", false);
        component.set("v.ingresarContrasena", true);
        component.set("v.alertaPasswordIncorrecta", false);
    },

    clearData: function(component){
        component.set("v.idPacienteSeleccionado", null);
        component.set("v.nombrePacienteSeleccionado", null);
        component.set("v.username", null);
        component.set("v.password", null);
    },

    keyCheckFormDNI : function(component, event){
        if (event.which == 13){
            event.preventDefault();
            this.getPacientes(component, event);
        }
     },

     keyCheckFormPacientes : function(component, event){
        if (event.which == 13){
            event.preventDefault();
            this.getUsername(component, event);
        }
    },

    keyCheckFormPass : function(component, event){
        if (event.which == 13){
            event.preventDefault();
            this.logearse(component, event);
        }
    },
})