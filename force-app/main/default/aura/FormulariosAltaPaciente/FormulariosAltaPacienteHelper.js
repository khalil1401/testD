({
    max : 4000000,

    changePage : function(component, event, helper) {
        var page = event.getParam("page");
        component.set("v.paginaActual", page);

        if (page == '2' || page == '3' || page == '4' || page == 'final') {
            this.upsertTrack(component, event);
        }

        if (page == 'final') {
            this.savePaciente(component, event, helper);            
        }
    },

    addContacts : function(component, event) {
        var contact1 = component.get("v.contact");
        var contact2 = component.get("v.contact2");
        var contacts = component.get("v.contacts");
        var esMenor = component.get("v.esMenorA18Anios");
        var agregarOtroContacto = component.get("v.agregarOtroContacto");

        if (esMenor) {
            contacts.push(contact1);
            if (agregarOtroContacto == true &&
                contact2.DNI__c != '' && contact2.LastName != '') {
                    contacts.push(contact2);
            }
            else{
                contact1.Principal__c = true;
                component.set("v.contact", contact1);
                contact2.Principal__c = false;
                component.set("v.contact2", contact2);
            }
        }
        else {
            if(agregarOtroContacto == false) {
                if(contact1.DNI__c != '' && contact1.LastName != '') {
                    contacts.push(contact1);
                }
            }
            else {
                if(contact1.DNI__c != '' && contact1.LastName != '') {
                    contacts.push(contact1);
                }
                if(contact2.DNI__c != '' && contact2.LastName != '') {
                    contacts.push(contact2);
                }
            }
        }

        component.set("v.contacts", contacts);
    },

    saveContacts : function(component, event, helper) {
        var idAccount = component.get("v.idAccount");
        var contacts = component.get("v.contacts");

        if(contacts.length > 0) {
            var action = component.get("c.saveContacts");
            action.setParams({
                contacts : contacts,
                idAccount : idAccount
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if(state === 'SUCCESS'){
                    console.log('Contactos guardados');
                }
                component.set("v.pasoContacto", true);
                helper.hideSpinner(component);
            })
            $A.enqueueAction(action);
        }
        else{
            component.set("v.pasoContacto", true);
            helper.hideSpinner(component);
        }
    },

    saveTratamiento : function(component, event, helper) {
        var area = component.get("v.area");
        var idAccount = component.get("v.idAccount");
        var paciente = component.get("v.account");
        var tratamiento = component.get("v.tratamiento");
        var tratamientoProfesional = component.get("v.tratamientoProfesional");
        var producto = component.get("v.producto");
        tratamiento.Obra_social__c = paciente.Obra_social__c;
        tratamiento.Area_terapeutica__c = area;
        component.set("v.tratamiento", tratamiento);

        var action = component.get("c.saveObjetosTratamiento");
        action.setParams({
            tratamiento : tratamiento,
            producto : producto,
            tratamientoDeProf : tratamientoProfesional,
            idPaciente : idAccount
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                console.log('Tratamiento guardado');
            }
            component.set("v.pasoTratamiento", true);
            helper.hideSpinner(component);
        })
        $A.enqueueAction(action);
    },

    createFile : function(component, event, helper){
        var idAccount = component.get("v.idAccount");
        var file = component.get("v.archivo");
        var objFileReader = new FileReader();
        objFileReader.onload = $A.getCallback(function() {
            var fileContents = objFileReader.result;
            //Falta revisar extension solo para imagenes
            var base64 = 'base64,';
            var dataStart = fileContents.indexOf(base64) + base64.length;
            let data = fileContents.substring(dataStart);

            if(data.length < helper.max || file.type == 'application/pdf'){
                helper.saveFile(component, helper, idAccount, file.name, data);
            }
            else{
                helper.optimizeFile(component, helper, idAccount, file.name, fileContents);
            }
        });
        objFileReader.onerror = $A.getCallback(function(e) {
            helper.insertTrackErrorCupon(component, e.target.error);
        });
        objFileReader.readAsDataURL(file);
    },

    optimizeFile : function(component, helper, idAccount, fileName, data){
        var img = new Image();
        img.src = data;
        img.onload = function(){
            var canvas = component.find("canvas").getElement();
            let width = img.width * 0.90;
            let height = img.height * 0.90;

            canvas.width = width;
            canvas.height = height;

            var ctx = canvas.getContext('2d');
            ctx.clearRect(0, 0, width, height);
            var image = new Image();
            image.src =  data;
            image.onload = $A.getCallback(function(){
                window.setTimeout($A.getCallback(function(){
                    ctx.drawImage(image, 0, 0, width, height);
                    var base64Data = canvas.toDataURL("image/jpeg", 0.75);
                    //Obtengo solo la data base64
                    var base64 = 'base64,';
                    var dataStart = base64Data.indexOf(base64) + base64.length;
                    let newData = base64Data.substring(dataStart);

                    if(newData.length <= helper.max){
                        helper.saveFile(component, helper, idAccount, fileName, newData);
                    }
                    else{
                        helper.optimizeFile(component, helper, idAccount, fileName, base64Data);
                    }
                },1));
            });
        }
    },

    saveFile : function(component, helper, idAccount, fileName, data) {
        if(data && data.length > 0) {
            try {
                var action = component.get("c.saveCupon");
                action.setParams({
                    idPaciente: idAccount,
                    fileName: fileName,
                    base64Data: data
                });
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        console.log("Archivo guardado correctamente");
                    }
                    else if (state === "INCOMPLETE") {
                        let error = "INCOMPLETE state archivo";
                        helper.insertTrackErrorCupon(component, error);
                    }
                    if (state === "ERROR") {
                        if (response.getError()[0].message) {
                            let errors = response.getError()[0].message;
                            let error =  errors.slice(0, 240);
                            helper.insertTrackErrorCupon(component, error);
                        }
                    }
                    component.set("v.pasoArchivo", true);
                    helper.hideSpinner(component);
                });
                $A.enqueueAction(action);
            } catch (e) {
                let error =  e.message.slice(0, 240);
                helper.insertTrackErrorCupon(component, error);
            }
        }
        else {
            let error =  "Base64 de archivo vacío";
            helper.insertTrackErrorCupon(component, error);
        }
    },

    savePaciente : function(component, event, helper) {
        component.set("v.showSpinner", true);
        this.addContacts(component, event);
        var account = component.get("v.account");
        var alimentacion = component.get("v.tratamiento").Alimentacion__c;
        var idProducto = component.get("v.producto").Formula__c;
        var action = component.get("c.saveAccount");
        action.setParams({
            account : account,
            idProducto : idProducto,
            alimentacion : alimentacion
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS') {
                var res = response.getReturnValue();
                if(res){
                    component.set("v.idAccount", res);
                    console.log('Paciente guardado');
                    this.saveContacts(component, event, helper);
                    this.saveTratamiento(component, event, helper);
                    this.createFile(component, event, helper);
                }
                else{
                    component.set("v.showSpinner", false);
                    component.set("v.isError", true);
                }
            }
            if(state === "ERROR") {
                console.log(response.getError()[0].message);
                component.set("v.showSpinner", false);
                component.set("v.isError", true);
            }
        })
        $A.enqueueAction(action);
    },

    setArea : function(component, event){
        const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        if(urlParams.get('area')){
            component.set("v.area", urlParams.get('area'));
        }
    },

    upsertTrack : function(component, event) {
        var trackForm = component.get("v.trackForm");

        var action = component.get("c.generateTrackForm");
        action.setParams({
            track : trackForm
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                var res = response.getReturnValue();
                component.set("v.trackForm", res);
            }
            if (state === "ERROR") {
                console.log(response.getError()[0].message);
            }
        })
        $A.enqueueAction(action);
    },

    hideSpinner : function(component) {
        let pasoContacto = component.get("v.pasoContacto");
        let pasoTratamiento = component.get("v.pasoTratamiento");
        let pasoArchivo = component.get("v.pasoArchivo");

        if(pasoContacto && pasoTratamiento && pasoArchivo) {
            component.set("v.showSpinner", false);
            component.set("v.isFinModalOpen", true);
        }
    },
    
    insertTrackErrorCupon : function(component, error) {
        let idAccount = component.get("v.idAccount");
        let trackErrorCupon = component.get("v.trackErrorCupon");
        trackErrorCupon.Datos_Paciente__c = idAccount;
        trackErrorCupon.Cupon__c = "Error: " + error;

        let action = component.get("c.generateTrackForm");
        action.setParams({
            track : trackErrorCupon
        });
        action.setCallback(this, function(response) {
            let state = response.getState();
            if(state === 'SUCCESS'){
                console.log("generacion de trackErrorCupon exitosa");
            }
            if (state === "ERROR") {
                console.log(response.getError()[0].message);
            }
        })
        $A.enqueueAction(action);
    },
})