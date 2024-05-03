public without sharing class PerfilUsuarioNSJController {

    @AuraEnabled(cacheable=true)
    public static User getUserId() {
        Id idUser = UserInfo.getUserId();

        List<User> users = [
            SELECT  Id, AccountId, Account.FirstName, Account.LastName, Account.PersonBirthdate, Account.DNI__c,
                    Account.Phone, Account.RecordType.DeveloperName
            FROM    User 
            WHERE   Id =: idUser
        ];

        if(!users.isEmpty()){
            return users.get(0);
        }
        
        return null;
    }

    @AuraEnabled(cacheable=true)
    public static Account getDatosPersonales(String pacienteId) {
        List<Account> pacientes = [
            SELECT  Id, Sexo__c, PersonEmail, Tipo_de_telefono__c, Phone
            FROM    Account 
            WHERE   Id =: pacienteId
        ];

        if(!pacientes.isEmpty()){
            return pacientes.get(0);
        }
        
        return null;
    }

    @AuraEnabled(cacheable=true)
    public static Localidad__c getLocalidad(String idLocalidad) {
        List<Localidad__c> localidades = [
            SELECT  Id, Name, Municipio__c, Municipio__r.Name, Municipio__r.Descripcion_Provincia__c
            FROM Localidad__c
            WHERE   Id =: idLocalidad
        ];

        if(!localidades.isEmpty()){
            return localidades.get(0);
        }

        return null;
    }

    @AuraEnabled(cacheable=true)
    public static List<Contact> getContacts(String accountId) {
        Set<Id> contactosDePacienteId = new Set<Id>();
        List<Contacto_de_paciente__c> contactosDePaciente = [
            SELECT  Contacto__c
            FROM    Contacto_de_paciente__c
            WHERE   Paciente__c =: accountId
        ];

        if(!contactosDePaciente.isEmpty()){
            for(Contacto_de_paciente__c cdp : contactosDePaciente){
                contactosDePacienteId.add(cdp.Contacto__c);
            }
        }

        List<Contact> contacts = [
            SELECT  FirstName, LastName, DNI__c, Email, Relacion__c, Tipo_de_Telefono_de_Contacto__c, MobilePhone, Phone, Principal__c, Paciente__c
            FROM    Contact
            WHERE   Id IN: contactosDePacienteId
            ORDER BY Principal__c DESC
        ];

        return contacts;
    }

    @AuraEnabled(cacheable=true)
    public static Tratamiento__c getTratamiento(String accountId) {
        List<Tratamiento__c> tratamientos = [
            SELECT  Id, Patologia__c, Obra_social__c, Obra_social__r.Name, Centro_de_tratamiento__c,
                    Centro_de_tratamiento__r.Name, Cuenta__r.Area_Terapeutica__c
            FROM    Tratamiento__c
            WHERE   Cuenta__c =: accountId
        ];

        if(!tratamientos.isEmpty()) {
            return tratamientos.get(0);
        }

        return null;
    }

    @AuraEnabled(cacheable=true)
    public static List<ProfesionalWrapper> getTratamientoDeProfesional(String tratamientoId) {
        List<ProfesionalWrapper> profesionales = new List<ProfesionalWrapper>();
        List<Tratamiento_de_profesional__c> tratamientos = [
            SELECT  Id, Tratamiento__c, Profesional__c, Profesional__r.Name, Profesional_Derivador__c
            FROM    Tratamiento_de_profesional__c
            WHERE   Tratamiento__c =: tratamientoId
            ORDER BY CreatedDate ASC
            LIMIT 2
        ];

        if(!tratamientos.isEmpty()) {
            for(Integer i = 0; i<tratamientos.size(); i++) {
                ProfesionalWrapper profesional = new ProfesionalWrapper();
                profesional.id = tratamientos.get(i).Id;
                profesional.idTratamiento = tratamientos.get(i).Tratamiento__c;
                profesional.idProfesional = tratamientos.get(i).Profesional__c;
                profesional.nombreProfesional = tratamientos.get(i).Profesional__r.Name;
                profesional.profesionalDerivador = tratamientos.get(i).Profesional_Derivador__c;
                if(i == 0){
                    profesional.profesionalPrincipal = true;
                }
                else {
                    profesional.profesionalPrincipal = false;
                }
                profesionales.add(profesional);
            }
            return profesionales;
        }

        return null;
    }

    @AuraEnabled(cacheable=true)
    public static List<DireccionWrapper> getDirecciones(String accountId) {
        List<DireccionWrapper> direcciones = new List<DireccionWrapper>();
        List<Account> pacientes = [
            SELECT  Direccion__c, Referencia__c, Localidad_look__c, Localidad_look__r.Name, Codigo_postal__c, Localidad_look__r.Municipio__r.Name, Localidad_look__r.Municipio__r.Descripcion_Provincia__c,
                Direccion_Secundaria__c, Referencia_Secundaria__c, Codigo_Postal_Secundario__c, Localidad_Secundaria__c, Localidad_Secundaria__r.Name, Localidad_Secundaria__r.Municipio__r.Name, Localidad_Secundaria__r.Municipio__r.Descripcion_Provincia__c
            FROM    Account
            WHERE   Id =: accountId
        ];

        if(!pacientes.isEmpty()) {
            if(pacientes.get(0).Direccion__c != null && pacientes.get(0).Localidad_look__c != null && pacientes.get(0).Codigo_postal__c != null) {
                DireccionWrapper primerDireccion = new DireccionWrapper();
                primerDireccion.id = 'primer-contacto';
                primerDireccion.principal = true;
                primerDireccion.direccion = pacientes.get(0).Direccion__c;
                primerDireccion.referencia = pacientes.get(0).Referencia__c;
                primerDireccion.localidadId = pacientes.get(0).Localidad_look__c;
                primerDireccion.localidad = pacientes.get(0).Localidad_look__r.Name;
                primerDireccion.cp = pacientes.get(0).Codigo_postal__c;
                primerDireccion.municipio = pacientes.get(0).Localidad_look__r.Municipio__r.Name;
                primerDireccion.provincia = pacientes.get(0).Localidad_look__r.Municipio__r.Descripcion_Provincia__c;

                direcciones.add(primerDireccion);
            }
            if(pacientes.get(0).Direccion_Secundaria__c != null && pacientes.get(0).Codigo_Postal_Secundario__c != null && pacientes.get(0).Localidad_Secundaria__c != null) {
                DireccionWrapper segundaDireccion = new DireccionWrapper();
                segundaDireccion.id = 'segundo-contacto';
                segundaDireccion.principal = false;
                segundaDireccion.direccion = pacientes.get(0).Direccion_Secundaria__c;
                segundaDireccion.referencia = pacientes.get(0).Referencia_Secundaria__c;
                segundaDireccion.cp = pacientes.get(0).Codigo_Postal_Secundario__c;
                segundaDireccion.localidadId = pacientes.get(0).Localidad_Secundaria__c;
                segundaDireccion.localidad = pacientes.get(0).Localidad_Secundaria__r.Name;
                segundaDireccion.municipio = pacientes.get(0).Localidad_Secundaria__r.Municipio__r.Name;
                segundaDireccion.provincia = pacientes.get(0).Localidad_Secundaria__r.Municipio__r.Descripcion_Provincia__c;

                direcciones.add(segundaDireccion);
            }

            return direcciones;
        }

        return null;
    }

    @AuraEnabled(cacheable=true)
    public static NIC_Envio__c getEnvio(String accountId) {
        List<NIC_Envio__c> envios = [
            SELECT  Link_Seguimiento_completo__c, Cuenta__r.Name, Direccion_de_Envio__c, Localidad_de_Envio__c, NIC__c
            FROM    NIC_Envio__c
            WHERE   Cuenta__c =: accountId
            ORDER BY CreatedDate DESC
        ];

        if(!envios.isEmpty()) {
            return envios.get(0);
        }

        return null;
    }

    @AuraEnabled
    public static void saveAccount(String jsonAccount) {
        if(jsonAccount == null) {
            System.debug('json vacio');
        }
        else {
            Account record = (Account) JSON.deserialize(jsonAccount, Account.class);
            update record;

            if(record.PersonEmail != null) {
                updateEmailPaciente(record.Id, record.PersonEmail);
                setReadyForJitterbit(record.Id);
            }
            else if(record.Phone != null) {
                setReadyForJitterbit(record.Id);
            }
        }
    }

    public static void updateEmailPaciente(String pacienteId, String email) {
        List<Contact> contacts = [
            SELECT  Id
            FROM    Contact
            WHERE   AccountId =: pacienteId
        ];

        if(!contacts.isEmpty()) {
            List<User> users = [
                SELECT  Id
                FROM    User
                WHERE   ContactId =: contacts.get(0).Id
            ];

            if(!users.isEmpty()) {
                users.get(0).Email = email;
            }

            update users;
        }
    }

    @AuraEnabled
    public static void saveTratamiento(String jsonTratamiento) {
        if(jsonTratamiento == null) {
            System.debug('json vacio');
        }
        else {
            Tratamiento__c record = (Tratamiento__c) JSON.deserialize(jsonTratamiento, Tratamiento__c.class);
            update record;
        }
    }

    @AuraEnabled
    public static void saveTratamientoProf(String jsonTratamientoProf) {
        if(jsonTratamientoProf == null) {
            System.debug('json vacio');
        }
        else {
            Tratamiento_de_profesional__c record = (Tratamiento_de_profesional__c) JSON.deserialize(jsonTratamientoProf, Tratamiento_de_profesional__c.class);
            upsert record;
        }
    }

    @AuraEnabled
    public static void insertContact(String jsonContact) {
        if(jsonContact == null) {
            System.debug('json vacio');
        }
        else {
            try {
                Contact record = (Contact) JSON.deserialize(jsonContact, Contact.class);
                record.Es_de_Community__c = true;
                record.RecordTypeId = XappiaHelper.getRecordType('Contact', 'Contacto de paciente').Id;
                setContactPrincipal(record);
                insert record;
                
                if(record.Id != null) {
                    //setear los nuevos valores en los datos de la cuenta
                    List<Account> pacientes = [
                        SELECT  Id
                        FROM    Account
                        WHERE   Id =: record.Paciente__c
                    ];

                    if(!pacientes.isEmpty()){
                        if(record.Principal__c) {
                            pacientes.get(0).Nombre_de_Contacto__c = record.FirstName + ' ' + record.LastName;
                            pacientes.get(0).V_nculo__c = record.Relacion__c;
                            pacientes.get(0).Correo_electronico_de_Contacto__c = record.Email;
                            pacientes.get(0).Tipo_de_telefono_2__c = record.Tipo_de_Telefono_de_Contacto__c;
                            if(record.Tipo_de_Telefono_de_Contacto__c == 'Celular') {
                                pacientes.get(0).Tel_fono_2__c = record.MobilePhone;
                            }
                            else {
                                pacientes.get(0).Tel_fono_2__c = record.Phone;
                            }
                        }
                        else {
                            pacientes.get(0).Nombre_de_Contacto_3__c = record.FirstName + ' ' + record.LastName;
                            pacientes.get(0).V_nculo_3__c = record.Relacion__c;
                            pacientes.get(0).Correo_electronico_de_Contacto_3__c = record.Email;
                            pacientes.get(0).Tipo_de_Telefono_3__c = record.Tipo_de_Telefono_de_Contacto__c;
                            if(record.Tipo_de_Telefono_de_Contacto__c == 'Celular') {
                                pacientes.get(0).Tel_fono_3__c = record.MobilePhone;
                            }
                            else {
                                pacientes.get(0).Tel_fono_3__c = record.Phone;
                            }
                        }

                        update pacientes;
                    }

                    //Genero el contacto de paciente
                    Contacto_de_paciente__c contactoPaciente = new Contacto_de_paciente__c();
                    contactoPaciente.Contacto__c = record.Id;
                    contactoPaciente.Paciente__c = record.Paciente__c;
                    contactoPaciente.Relacion__c = record.Relacion__c;
                    contactoPaciente.Principal__c = record.Principal__c;

                    insert contactoPaciente;
                }
            } catch (DMLException e) {
                System.debug(e);                
            }
        }
    }


    @AuraEnabled
    public static void updateContact(String jsonContact) {
        if(jsonContact == null) {
            System.debug('json vacio');
        }
        else {
            try {
                Contact record = (Contact) JSON.deserialize(jsonContact, Contact.class);
                setContactPrincipal(record);
                if(record.Tipo_de_Telefono_de_Contacto__c == 'Celular') {
                    record.Phone = '';
                }
                else if(record.Tipo_de_Telefono_de_Contacto__c == 'Casa' || record.Tipo_de_Telefono_de_Contacto__c == 'Laboral' || record.Tipo_de_Telefono_de_Contacto__c == 'Otro') {
                    record.MobilePhone = '';
                }
                update record;

                List<Contact> contacts = [
                    SELECT  FirstName, LastName, Email, Relacion__c, Tipo_de_Telefono_de_Contacto__c, MobilePhone, Phone, Principal__c, Paciente__c
                    FROM    Contact
                    WHERE   Id =: record.Id
                ];

                if(!contacts.isEmpty()) {
                    //setear los nuevos valores en los datos de la cuenta
                    List<Account> pacientes = [
                        SELECT  Id
                        FROM    Account
                        WHERE   Id =: contacts.get(0).Paciente__c
                    ];

                    if(!pacientes.isEmpty()){
                        //Actualizo datos de contacto en cuenta
                        if(contacts.get(0).Principal__c) {
                            pacientes.get(0).Nombre_de_Contacto__c = contacts.get(0).FirstName + ' ' + contacts.get(0).LastName;
                            pacientes.get(0).V_nculo__c = contacts.get(0).Relacion__c;
                            pacientes.get(0).Correo_electronico_de_Contacto__c = contacts.get(0).Email;
                            pacientes.get(0).Tipo_de_telefono_2__c = contacts.get(0).Tipo_de_Telefono_de_Contacto__c;
                            if(contacts.get(0).Tipo_de_Telefono_de_Contacto__c == 'Celular') {
                                pacientes.get(0).Tel_fono_2__c = contacts.get(0).MobilePhone;
                            }
                            else {
                                pacientes.get(0).Tel_fono_2__c = contacts.get(0).Phone;
                            }
                        }
                        else {
                            pacientes.get(0).Nombre_de_Contacto_3__c = contacts.get(0).FirstName + ' ' + contacts.get(0).LastName;
                            pacientes.get(0).V_nculo_3__c = contacts.get(0).Relacion__c;
                            pacientes.get(0).Correo_electronico_de_Contacto_3__c = contacts.get(0).Email;
                            pacientes.get(0).Tipo_de_Telefono_3__c = contacts.get(0).Tipo_de_Telefono_de_Contacto__c;
                            if(contacts.get(0).Tipo_de_Telefono_de_Contacto__c == 'Celular') {
                                pacientes.get(0).Tel_fono_3__c = contacts.get(0).MobilePhone;
                            }
                            else {
                                pacientes.get(0).Tel_fono_3__c = contacts.get(0).Phone;
                            }
                        }

                        update pacientes;

                        //Actualizo datos de contacto de paciente
                        List<Contacto_de_paciente__c> contactosDePaciente = [
                            SELECT  Relacion__c, Principal__c
                            FROM    Contacto_de_paciente__c
                            WHERE   Paciente__c =: contacts.get(0).Paciente__c
                                AND Contacto__c =: contacts.get(0).Id
                        ];

                        for(Contacto_de_paciente__c cdp : contactosDePaciente) {
                            cdp.Relacion__c = contacts.get(0).Relacion__c;
                            cdp.Principal__c = contacts.get(0).Principal__c;
                        }

                        update contactosDePaciente;
                    }
                }
            } catch (DMLException e) {
                System.debug(e);
            }
        }
    }

    public static void setContactPrincipal(Contact newContact) {
        if(newContact.Principal__c != null && newContact.Principal__c == true) {
            List<Contact> contacts = [
                SELECT  FirstName, LastName, Email, Relacion__c, Tipo_de_Telefono_de_Contacto__c, MobilePhone, Phone, Principal__c, Paciente__c
                FROM    Contact
                WHERE   Paciente__c =: newContact.Paciente__c
            ];
            Contact principalAntiguo;

            for(Contact contact : contacts) {
                if(contact.Principal__c == true) {
                    principalAntiguo = contact;
                }
                contact.Principal__c = false;
            }

            update contacts;

            //Actualizo datos de contacto en cuenta
            if(principalAntiguo != null) {
                Account paciente = new Account();
                paciente.Id = principalAntiguo.Paciente__c;
                paciente.Nombre_de_Contacto_3__c = principalAntiguo.FirstName + ' ' + principalAntiguo.LastName;
                paciente.V_nculo_3__c = principalAntiguo.Relacion__c;
                paciente.Correo_electronico_de_Contacto_3__c = principalAntiguo.Email;
                paciente.Tipo_de_Telefono_3__c = principalAntiguo.Tipo_de_Telefono_de_Contacto__c;
                if(principalAntiguo.Tipo_de_Telefono_de_Contacto__c == 'Celular') {
                    paciente.Tel_fono_3__c = principalAntiguo.MobilePhone;
                }
                else {
                    paciente.Tel_fono_3__c = principalAntiguo.Phone;                    
                }

                update paciente;
            }

            //Actualizo datos de contacto de paciente
            List<Contacto_de_paciente__c> contactosDePaciente = [
                SELECT  Id
                FROM    Contacto_de_paciente__c
                WHERE   Paciente__c =: newContact.Paciente__c
            ];

            for(Contacto_de_paciente__c cdp : contactosDePaciente) {
                cdp.Principal__c = false;
            }

            update contactosDePaciente;
        }
    }
 
    @AuraEnabled(cacheable=true)
    public static List<String> getPicklistValues(String objectPicklist, String fieldPicklist, String area) {
        if (objectPicklist == 'Account' && fieldPicklist == 'Sexo__c') {
            return FormularioRegistroController.getPickListSexo();
        }
        else if (objectPicklist == 'Tratamiento__c' && fieldPicklist == 'Patologia__c') {
            return FormularioRegistroController.getPickListPatologias(area);
        }
        return null;
    }

    @AuraEnabled
    public static void deleteContact(String recordId, String pacienteId) {
        //eliminar datos de contacto en cuenta
        Account paciente = new Account(Id = pacienteId);
        List<Contact> contacts = [
            SELECT  Principal__c
            FROM    Contact
            WHERE   Id =: recordId
        ];

        if(!contacts.isEmpty()) {
            paciente.Nombre_de_Contacto_3__c = '';
            paciente.V_nculo_3__c = '';
            paciente.Correo_electronico_de_Contacto_3__c = '';
            paciente.Tipo_de_Telefono_3__c = '';
            paciente.Tel_fono_3__c = '';

            update paciente;
        }

        //eliminar datos de contacto de paciente
        List<Contacto_de_paciente__c> contactosDePaciente = [
            SELECT  Id
            FROM    Contacto_de_paciente__c
            WHERE   Contacto__c =: recordId
                AND Paciente__c =: pacienteId
        ];
        
        delete contactosDePaciente;
        delete contacts;        
    }

    @AuraEnabled
    public static void deleteDireccion(String recordId, String direccion) {
        Account paciente = new Account(Id = recordId);
        paciente.Direccion_Secundaria__c = '';
        paciente.Localidad_Secundaria__c = null;
        paciente.Codigo_Postal_Secundario__c = '';
        paciente.Referencia_Secundaria__c = '';
        update paciente;
    }

    @AuraEnabled
    public static void upsertDireccion(String id, Boolean principal, String direccion, String cp, String localidad, String ref, String pacienteId) {
        List<Account> pacientes = [
            SELECT  Direccion__c, Localidad_look__c, Codigo_postal__c, Referencia__c, Phone
            FROM    Account
            WHERE   id =: pacienteId
        ];

        if(id == 'primer-contacto') {
            pacientes.get(0).Direccion__c = direccion;
            pacientes.get(0).Localidad_look__c = localidad;
            pacientes.get(0).Codigo_postal__c = cp;
            if(ref != null) {
                pacientes.get(0).Referencia__c = ref;
            }
            else {
                pacientes.get(0).Referencia__c = pacientes.get(0).Phone;
            }

            setReadyForJitterbit(pacienteId);
        }
        else {
            if(principal) {
                pacientes.get(0).Direccion_Secundaria__c = pacientes.get(0).Direccion__c;
                pacientes.get(0).Localidad_Secundaria__c = pacientes.get(0).Localidad_look__c;
                pacientes.get(0).Codigo_Postal_Secundario__c = pacientes.get(0).Codigo_postal__c;
                pacientes.get(0).Referencia_Secundaria__c = pacientes.get(0).Referencia__c;

                pacientes.get(0).Direccion__c = direccion;
                pacientes.get(0).Localidad_look__c = localidad;
                pacientes.get(0).Codigo_postal__c = cp;
                if(ref != null) {
                    pacientes.get(0).Referencia__c = ref;
                }
                else {
                    pacientes.get(0).Referencia__c = pacientes.get(0).Phone;
                }

                setReadyForJitterbit(pacienteId);
            }
            else {
                pacientes.get(0).Direccion_Secundaria__c = direccion;
                pacientes.get(0).Localidad_Secundaria__c = localidad;
                pacientes.get(0).Codigo_Postal_Secundario__c = cp;
                if(ref != null) {
                    pacientes.get(0).Referencia_Secundaria__c = ref;
                }
                else {
                    pacientes.get(0).Referencia_Secundaria__c = pacientes.get(0).Phone;
                }
            }
        }

        update pacientes;
    }

    @AuraEnabled
    public static void setReadyForJitterbit(String accountId) {
        Account paciente = new Account(Id = accountId);
        paciente.Listo_para_Jitterbit__c = true;
        update paciente;
    }

    @AuraEnabled
    public static PacienteBestCareWrapper getDataPacienteBestCare(String pacienteId){
        PacienteBestCareWrapper pacienteBestCare = new PacienteBestCareWrapper();
        List<Modulo_de_paciente__c> moduloDePaciente = [
            SELECT  Modulo_desde__c, Modulo_hasta__c
            FROM    Modulo_de_paciente__c
            WHERE   Cuenta__c = :pacienteId
                AND Estado__c =: 'Activo'
        ];
        if (!moduloDePaciente.isEmpty()) {
            pacienteBestCare.moduloDesde = moduloDePaciente[0].Modulo_desde__c;
            pacienteBestCare.moduloHasta = moduloDePaciente[0].Modulo_hasta__c;
        }

        List<Account> pacienteList = [
            SELECT Estado_de_paciente__c
            FROM Account
            WHERE Id = : pacienteId
        ];
        
        if (!pacienteList.isEmpty()) {
            pacienteBestCare.estadoDePaciente = pacienteList[0].Estado_de_paciente__c;
        }

        List<Producto_de_envio__c> productNameList = [
            SELECT Name, Formula__r.Name 
            FROM Producto_de_envio__c
            WHERE Envio_sin_cargo__r.Paciente__c = :pacienteId
        ];

        if (!productNameList.isEmpty()) {
            pacienteBestCare.producto = productNameList[0].Formula__r.Name;
        }

        if (!moduloDePaciente.isEmpty()) {
            return pacienteBestCare;            
        }
        else {
            return null;
        }
    }

    @AuraEnabled
    public static void deleteTratamientoProf(String recordId) {
        Tratamiento_de_profesional__c tratamientoProf = new Tratamiento_de_profesional__c(Id = recordId);
        delete tratamientoProf;
    }

    @AuraEnabled
    public static void setStatusPaciente(String accountId, String step, Date fecha, Boolean primerTramite) {
        Account paciente = new Account();
        paciente.Id = accountId;
        
        if(step == 'sinrespuesta') {
            paciente.Fecha_de_obito__c = null;
            paciente.Estado_de_paciente__c = 'En Seguimiento';
            paciente.Subestado_del_paciente__c = 'Tramite iniciado';
            crearTareaAvisoCobertura(accountId, step);
            setFechaInicioTramiteCobertura(accountId, fecha, primerTramite);
        }
        else if(step == 'parcialmenteaprobado') {
            paciente.Fecha_de_obito__c = null;
            paciente.Estado_de_paciente__c = 'En tratamiento';
            paciente.Subestado_del_paciente__c = 'Cobertura parcial con Consumo';
            crearTareaAvisoCobertura(accountId, step);
            setFechaInicioTramiteCobertura(accountId, fecha, primerTramite);
        }
        else if(step == 'rechazado') {
            paciente.Fecha_de_obito__c = Date.today();
            paciente.Estado_de_paciente__c = 'No tratamiento';
            paciente.Subestado_del_paciente__c = 'OOSS no autoriza indicación médica';
            crearTareaAvisoCobertura(accountId, step);
            setFechaInicioTramiteCobertura(accountId, fecha, primerTramite);
        }
        else if(step == 'sinfecha') {
            paciente.Fecha_de_obito__c = null;
            paciente.Estado_de_paciente__c = 'En Seguimiento';
            paciente.Subestado_del_paciente__c = 'Tramite no iniciado';
        }

        update paciente;
    }

    @AuraEnabled
    public static void crearTareaAvisoCobertura(String idPaciente, String type) {
        Group psp = [
            SELECT Id
            FROM Group
            WHERE Type = 'Queue'
                AND NAME = 'PSP'
            LIMIT 1
        ];

        Task tareaAvisoCobertura = new Task();
        tareaAvisoCobertura.Status = 'Abierta';
        tareaAvisoCobertura.WhatId = idPaciente;
        tareaAvisoCobertura.Type = 'Aviso No Cobertura';
        tareaAvisoCobertura.RecordTypeId = XappiaHelper.getRecordType('Task', 'Tarea').Id;
        tareaAvisoCobertura.OwnerId = psp.Id;
        if(type == 'rechazado') {
            tareaAvisoCobertura.Subject = 'Cobertura Médica Rechazada';
            tareaAvisoCobertura.Description = Label.Cobertura_Medica_Rechazada;
        }
        else if(type == 'sinrespuesta') {
            tareaAvisoCobertura.Subject = 'Cobertura Médica Sin Respuesta';
            tareaAvisoCobertura.Description = Label.Cobertura_Medica_Sin_Respuesta;
        }
        else if(type == 'parcialmenteaprobado') {
            tareaAvisoCobertura.Subject = 'Cobertura Médica Aprobada Parcialmente';
            tareaAvisoCobertura.Description = Label.Cobertura_Medica_Aprobada_Parcialmente;
        }

        insert tareaAvisoCobertura;
    }

    @AuraEnabled
    public static void setFechaInicioTramiteCobertura(String accountId, Date fecha, Boolean primerTramite) {
        List<Tratamiento__c> tratamientos = [
            SELECT  Id
            FROM    Tratamiento__c
            WHERE   Cuenta__c =: accountId
            ORDER BY CreatedDate DESC 
        ];

        if(!tratamientos.isEmpty()) {
            tratamientos.get(0).Fecha_Inicio_Tramite_de_Cobertura__c = fecha;
            tratamientos.get(0).Primer_Tramite_de_Cobertura_Medica__c = primerTramite;
        }

        update tratamientos;
    }

    public class DireccionWrapper{
        @AuraEnabled
        public String id{get;set;}
        @AuraEnabled
        public Boolean principal{get;set;}
        @AuraEnabled
        public String direccion{get;set;}
        @AuraEnabled
        public String referencia{get;set;}
        @AuraEnabled
        public String localidadId{get;set;}
        @AuraEnabled
        public String localidad{get;set;}
        @AuraEnabled
        public String cp{get;set;}
        @AuraEnabled
        public String municipio{get;set;}
        @AuraEnabled
        public String provincia{get;set;}
    }
    
    public class PacienteBestCareWrapper{        
        @AuraEnabled
        public Date moduloDesde{get;set;}
        @AuraEnabled
        public Date moduloHasta{get;set;}
        @AuraEnabled
        public String estadoDePaciente{get;set;}
        @AuraEnabled
        public String producto{get;set;}       
    }

    public class ProfesionalWrapper{
        @AuraEnabled
        public String id{get;set;}
        @AuraEnabled
        public String idTratamiento{get;set;}
        @AuraEnabled
        public String idProfesional{get;set;}
        @AuraEnabled
        public String nombreProfesional{get;set;}
        @AuraEnabled
        public Boolean profesionalDerivador{get;set;}
        @AuraEnabled
        public Boolean profesionalPrincipal{get;set;}
    }
}