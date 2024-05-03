public without sharing class FormularioRegistroController {

    public static Boolean failedTest = false;

    @AuraEnabled(cacheable=true)
    public static List<String> getPickListRelacionContacto(){
        List<String> relaciones = new List<String>();
        Schema.DescribeFieldResult campo = Contact.Relacion__c.getDescribe();
        List<Schema.PicklistEntry> valores = campo.getPicklistValues();

        for ( Schema.PicklistEntry valor : valores) {
            relaciones.add(valor.getLabel());
        }     

        return relaciones;
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getPickListSexo(){
        List<String> sexos = new List<String>();
        Schema.DescribeFieldResult campo = Account.Sexo__c.getDescribe();
        List<Schema.PicklistEntry> valores = campo.getPicklistValues();

        for ( Schema.PicklistEntry valor : valores) {
            sexos.add(valor.getLabel());
        }     
        
        return sexos;
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getPickListTiposDeTelefono(){
        List<String> telefonos = new List<String>();
        Schema.DescribeFieldResult campo = Account.Tipo_de_telefono__c.getDescribe();
        List<Schema.PicklistEntry> valores = campo.getPicklistValues();

        for ( Schema.PicklistEntry valor : valores) {
            telefonos.add(valor.getLabel());
        }

        return telefonos;
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getPickListTiposDeTelefonoContacto(){
        List<String> telefonos = new List<String>();
        Schema.DescribeFieldResult campo = Contact.Tipo_de_Telefono_de_Contacto__c.getDescribe();
        List<Schema.PicklistEntry> valores = campo.getPicklistValues();

        for ( Schema.PicklistEntry valor : valores) {
            telefonos.add(valor.getLabel());
        }

        return telefonos;
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getPickListDiagnosticos(){
        List<String> diagnosticos = new List<String>();
        Schema.DescribeFieldResult campo = Tratamiento__c.Diagnostico__c.getDescribe();
        List<Schema.PicklistEntry> valores = campo.getPicklistValues();

        for ( Schema.PicklistEntry valor : valores) {
            diagnosticos.add(valor.getLabel());
        }     

        return diagnosticos;
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getPickListPatologias(String area){
        Schema.DescribeFieldResult depend = Tratamiento__c.Patologia__c.getDescribe();
        Schema.sObjectField controlToken = depend.getController();
     
        Schema.DescribeFieldResult control = controlToken.getDescribe();
        List<Schema.PicklistEntry> controlEntries;
        if(control.getType() != Schema.DisplayType.Boolean) {
            controlEntries = control.getPicklistValues();
        }
     
        String base64map = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
        Map<String,List<String>> dependentPicklistValues = new Map<String,List<String>>();
        for (Schema.PicklistEntry entry : depend.getPicklistValues()) {
            if (entry.isActive() && String.isNotEmpty(String.valueOf(((Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')))) {
                List<String> base64chars =
                        String.valueOf(((Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')).split('');
                for (Integer index = 0; index < (controlEntries != null ? controlEntries.size() : 2); index++) {
                    Object controlValue =
                            (controlEntries == null
                                    ?   (Object) (index == 1)
                                    :   (Object) (controlEntries[index].isActive() ? controlEntries[index].getLabel() : null)
                            );
                    Integer bitIndex = index / 6;
                    if (bitIndex > base64chars.size() - 1) {
                        break;
                    }
                    Integer bitShift = 5 - Math.mod(index, 6);
                    if  (controlValue == null || (base64map.indexOf( base64chars[ bitIndex ] ) & (1 << bitShift)) == 0)
                        continue;
                    if (!dependentPicklistValues.containsKey((String) controlValue)) {
                        dependentPicklistValues.put((String) controlValue, new List<String>());
                    }
                    dependentPicklistValues.get((String) controlValue).add(entry.getLabel());
                }
            }
        }

        return dependentPicklistValues.get(area);
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getPickListProvincias() {
        List<String> provincias = new List<String>();
        Schema.DescribeFieldResult campo = Municipio__c.Descripcion_Provincia__c.getDescribe();
        List<Schema.PicklistEntry> valores = campo.getPicklistValues();

        for ( Schema.PicklistEntry valor : valores) {
            provincias.add(valor.getLabel());
        }

        provincias.sort();

        return provincias;
    }

    @AuraEnabled(cacheable=true)
    public static List<Municipio__c> getPickListMunicipios(String provincia) {
        String queryMunicipios = 'SELECT Id, Name FROM Municipio__c WHERE Descripcion_Provincia__c = \'' + String.escapeSingleQuotes(provincia) + '\' ORDER BY Name';
        List<Municipio__c> municipios = Database.query(queryMunicipios);

        return municipios;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<String> getPickListScreeningNutricional(){
        List<String> screeningNutricional = new List<String>();
        Schema.DescribeFieldResult campo = Tratamiento__c.Screening_Nutricional__c.getDescribe();
        List<Schema.PicklistEntry> valores = campo.getPicklistValues();

        for ( Schema.PicklistEntry valor : valores) {
            screeningNutricional.add(valor.getLabel());
        }

        return screeningNutricional;
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getPickListHerramientasScreening(){
        List<String> hearramientasScreening = new List<String>();
        Schema.DescribeFieldResult campo = Tratamiento__c.Herramienta_Screening_Nutricional__c	.getDescribe();
        List<Schema.PicklistEntry> valores = campo.getPicklistValues();

        for ( Schema.PicklistEntry valor : valores) {
            hearramientasScreening.add(valor.getLabel());
        }

        return hearramientasScreening;
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getPickListResultadosScreening(){
        List<String> resultadoScreening = new List<String>();
        Schema.DescribeFieldResult campo = Tratamiento__c.Resultado_Screening_Nutricional__c.getDescribe();
        List<Schema.PicklistEntry> valores = campo.getPicklistValues();

        for ( Schema.PicklistEntry valor : valores) {
            resultadoScreening.add(valor.getLabel());
        }

        return resultadoScreening;
    }

    @AuraEnabled(cacheable=true)
    public static List<Product2> getProductos(String area){
        String queryProductos = 'SELECT Id, Name FROM Product2 WHERE Es_de_Kit_de_Inicio__c = true AND Unidades_de_Kit__c > 0 AND Organizacion__c != null AND Producto_SAP__c = true AND Area_Terapeutica__c = \'' + String.escapeSingleQuotes(area) + '\' ORDER BY Name';
        List<Product2> productos = Database.query(queryProductos);

        return productos;
    }

    @AuraEnabled
    public static String saveAccount(Account account, String idProducto, String alimentacion) {
        Product2 producto = [
            SELECT  Id, Unidades_de_Kit__c, Organizacion__c, Area_Terapeutica__c, Codigo_producto_Id_externo__c
            FROM    Product2
            WHERE   Id =: idProducto
        ];

        account.Area_terapeutica__c = producto.Area_Terapeutica__c;
        account.FirstName = setValidName(account.FirstName);
        account.LastName = setValidName(account.LastName);
        account.RecordTypeId = XappiaHelper.getRecordType('Account', 'Paciente Regular').Id;

        //Si no tiene referencia de dirección se le agrega el número de teléfono
        if (String.isBlank(account.Referencia__c)) {
            account.Referencia__c = account.Phone;
        }

        //Seteo formato de telefonos
        if(!String.isBlank(account.Tipo_de_telefono__c)) {
            account.Phone = setFormatoTelefono(account.Tipo_de_telefono__c, account.Phone);
        }
        
        //Fecha de nacimiento 29 de febrero 
        if(account.PersonBirthdate != null && account.PersonBirthdate.day() == 29 & account.PersonBirthdate.month () == 2) {
            account.PersonBirthdate = Date.newInstance(account.PersonBirthdate.year(), 2, 28);
        }

        Task tarea = new Task();
        Envio_Sin_Cargo__c kit = new Envio_Sin_Cargo__c();
        List<Producto_de_envio__c> productosKit = new List<Producto_de_envio__c>();

        try {
            insert account;
            try {
                tarea = crearTareaPSP(account.Id);
                insert tarea;
            } catch (Exception ex) {
                String error = 'getMessage: ' + ex.getMessage() + 'getLineNumber: ' + ex.getLineNumber();
                generateLogForm(account.Id, error, tarea, null);
//                return account.Id;
            }
            try {
                kit = crearKitDeInicio(producto, alimentacion, account.Id);
                insert kit;
                try {
                    productosKit = crearProductosDeKit(producto, alimentacion, account.Id, kit.Id);
                    insert productosKit;
                } catch (Exception excProdKit) {
                    String error = 'getMessage: ' + excProdKit.getMessage() + 'getLineNumber: ' + excProdKit.getLineNumber();
                    generateLogForm(account.Id, error, productosKit.get(0), null);
                    editTaskAltaPaciente(account.Id);
//                    return account.Id;
                }
            } catch (Exception excKit) {
                String error = 'getMessage: ' + excKit.getMessage() + 'getLineNumber: ' + excKit.getLineNumber();
                generateLogForm(account.Id, error, kit, null);
                editTaskAltaPaciente(account.Id);
//                return account.Id;
            }
        } catch (Exception excPaciente) {
            Log_Form__c log = new Log_Form__c();
            log.Objeto_Fallido__c = account.getSObjectType().getDescribe().getLabel();
            log.Name = account.FirstName + ' ' + account.LastName;
            log.Error__c = 'getMessage: ' + excPaciente.getMessage() + ' - getCause: ' + excPaciente.getCause() + ' - getLineNumber: ' + excPaciente.getLineNumber();
            log.Datos_de_Paciente__c = 'Nombre: ' + account.FirstName + ' ' + account.LastName + '\n' + 'Teléfono: ' + account.Phone + '\n' + 'Correo electrónico: ' + account.PersonEmail + '\n' + 'Área terapéutica: ' + account.Area_terapeutica__c + '\n' + 'DNI: ' + account.DNI__c;
            log.Registro__c = JSON.serialize(account);
            log.Comentario__c = setComentarioLog(excPaciente.getMessage());
            insert log;

            Task taskPSP = new Task();
            taskPSP = generateTaskKitFallido(log.Id);
            insert taskPSP;
            
            return 'Fallo en la generación del paciente';
        }

        return account.Id;
    }

    @AuraEnabled
    public static Id saveContacts(List<Contact> contacts, String idAccount) {
        List<Contacto_de_paciente__c> contactosDePacientes = new List<Contacto_de_paciente__c>();
        Account account = new Account(Id = idAccount);

        //Genero los contactoss
        for (Contact contact : contacts){
            contact.Es_de_Community__c = true;
            contact.RecordTypeId = XappiaHelper.getRecordType('Contact', 'Contacto de paciente').Id;
            contact.Paciente__c = idAccount;
            //seteo valores de los contactos en la cuenta
            if(contact.Principal__c == true){
                account.Nombre_de_Contacto__c = contact.FirstName + ' ' + contact.LastName;
                account.V_nculo__c = contact.Relacion__c;
                account.Correo_electronico_de_Contacto__c = contact.Email;
                if(!String.isBlank(contact.Tipo_de_Telefono_de_Contacto__c)){
                    account.Tipo_de_telefono_2__c = contact.Tipo_de_Telefono_de_Contacto__c;
                    account.Tel_fono_2__c = setFormatoTelefono(contact.Tipo_de_Telefono_de_Contacto__c, contact.Phone);
                    if(contact.Tipo_de_Telefono_de_Contacto__c == 'Celular'){
                        contact.MobilePhone = account.Tel_fono_2__c;
                        contact.Phone = '';
                    }
                    else{
                        contact.Phone = account.Tel_fono_2__c;
                        contact.MobilePhone = '';
                    }
                }
            }
            else{
                account.Nombre_de_Contacto_3__c = contact.FirstName + ' ' + contact.LastName;
                account.V_nculo_3__c = contact.Relacion__c;
                if(failedTest == true){
                    account.V_nculo_3__c = 'Test';
                }
                account.Correo_electronico_de_Contacto_3__c = contact.Email;
                if(!String.isBlank(contact.Tipo_de_Telefono_de_Contacto__c)){
                    account.Tipo_de_Telefono_3__c = contact.Tipo_de_Telefono_de_Contacto__c;
                    account.Tel_fono_3__c = setFormatoTelefono(contact.Tipo_de_Telefono_de_Contacto__c, contact.Phone);
                    if(contact.Tipo_de_Telefono_de_Contacto__c == 'Celular'){
                        contact.MobilePhone = account.Tel_fono_3__c;
                        contact.Phone = '';
                    }
                    else{
                        contact.Phone = account.Tel_fono_3__c;
                        contact.MobilePhone = '';
                    }
                }
            }
        }

        Database.UpsertResult[] contactosResult = Database.upsert(contacts, Contact.Fields.DNI__c, false);

        //Obtengo errores de la generación de contactos
        for(Database.upsertResult resultContact : contactosResult) {
            if (!resultContact.isSuccess()) {
                String error;
                for(Database.Error err : resultContact.getErrors()) {
                    error = err.getStatusCode() + ': ' + err.getMessage() + '. Contacts fields that affected this error: ' + err.getFields();
                    generateLogForm(idAccount, error, null, contacts);
                }
                editTaskAltaPaciente(idAccount);
            }
        }

        //Genero los contactos de pacientes
        for (Contact contact : contacts) {
            if(String.isNotBlank(contact.Id)){
                Contacto_de_paciente__c contactoPaciente = new Contacto_de_paciente__c();
                contactoPaciente.Contacto__c = contact.Id;
                contactoPaciente.Paciente__c = idAccount;
                contactoPaciente.Relacion__c = contact.Relacion__c;
                contactoPaciente.Principal__c = contact.Principal__c;
                contactosDePacientes.add(contactoPaciente);
            }
        }
        
        Database.UpsertResult[] contactosDePacientesResult = Database.upsert(contactosDePacientes, false);

        //Obtengo errores de la generación de contactos de pacientes
        for(Database.upsertResult resultCDP : contactosDePacientesResult) {
            if (!resultCDP.isSuccess()) {
                String error;
                for(Database.Error err : resultCDP.getErrors()) {
                    error = err.getStatusCode() + ': ' + err.getMessage() + '. Contactos de Paciente fields that affected this error: ' + err.getFields();
                    generateLogForm(idAccount, error, null, contactosDePacientes);
                }
                editTaskAltaPaciente(idAccount);
            }
        }
    
        try {
            update account;
        } catch (Exception excPaciente) {
            String error = 'getMessage: ' + excPaciente.getMessage() + 'getLineNumber: ' + excPaciente.getLineNumber();
            generateLogForm(account.Id, error, account, null);
            editTaskAltaPaciente(idAccount);
        }

        return idAccount;
    }

    @AuraEnabled
    public static Tratamiento__c generateTratamiento(Tratamiento__c tratamiento, Id idPaciente) {
        tratamiento.Cuenta__c = idPaciente;
        tratamiento.RecordTypeId = XappiaHelper.getRecordType('Tratamiento__c', 'Tratamiento Regular').Id;

        if (tratamiento.Obra_Social__c == null){
            Account obraSocialMinisterio = [
                SELECT  Id
                FROM    Account
                WHERE   Name =: 'Ministerio de Desarrollo Social'
                LIMIT 1
            ];

            tratamiento.Obra_Social__c = obraSocialMinisterio.Id;
        }

        return tratamiento;
    }

    @AuraEnabled
    public static Producto_de_paciente__c generateProductoDePaciente(Producto_de_paciente__c producto, Id idTratamiento) {
        if(failedTest){
            producto.Renovacion_de_tratamiento__c = 'Test';
        }
        producto.Tratamiento__c = idTratamiento;

        return producto;
    }

    @AuraEnabled
    public static Id saveObjetosTratamiento(Tratamiento__c tratamiento, Producto_de_paciente__c producto,
            Tratamiento_de_profesional__c tratamientoDeProf, String idPaciente) {
        try {
            tratamiento = generateTratamiento(tratamiento, idPaciente);
            insert tratamiento;
            try {
                tratamientoDeProf.Tratamiento__c = tratamiento.Id;
                if(failedTest){
                    tratamientoDeProf.Tratamiento__c = null;
                }
                insert tratamientoDeProf;
            } catch (Exception excTratamientoDeProfesional) {
                String error = 'getMessage: ' + excTratamientoDeProfesional.getMessage() + 'getLineNumber: ' + excTratamientoDeProfesional.getLineNumber();
                generateLogForm(idPaciente, error, tratamientoDeProf, null);
                editTaskAltaPaciente(idPaciente);
            }
            try {
                producto = generateProductoDePaciente(producto, tratamiento.Id);
                insert producto;
            } catch (Exception excProductoDePaciente) {
                String error = 'getMessage: ' + excProductoDePaciente.getMessage() + 'getLineNumber: ' + excProductoDePaciente.getLineNumber();
                generateLogForm(idPaciente, error, producto, null);
                editTaskAltaPaciente(idPaciente);
            }
        } catch (Exception excTratamiento) {
            String error = 'getMessage: ' + excTratamiento.getMessage() + 'getLineNumber: ' + excTratamiento.getLineNumber();
            generateLogForm(idPaciente, error, tratamiento, null);
            editTaskAltaPaciente(idPaciente);
        }
        
        return idPaciente;
    }

    @AuraEnabled
    public static Id saveCupon(String idPaciente, String fileName, String base64Data) {
        Track_Solicitud_Kit_de_Inicio__c trackCupon = new Track_Solicitud_Kit_de_Inicio__c();
        trackCupon.Datos_Paciente__c = idPaciente;
        trackCupon.Cupon__c = 'Ingreso de cupón a Apex';
        generateTrackForm(trackCupon);

        ContentVersion contentVersion = new ContentVersion();

        try {
            contentVersion.Title = fileName;
            contentVersion.PathOnClient = fileName;
            contentVersion.VersionData = EncodingUtil.base64Decode(base64Data);
            contentVersion.IsMajorVersion = true;
            insert contentVersion;

            List<ContentVersion> listContentVersionDB =  [
                SELECT  Id, ContentDocumentId
                FROM    ContentVersion
                WHERE   Id =: contentVersion.Id
            ];

            if(!listContentVersionDB.isEmpty() && String.isNotBlank(idPaciente)){
                //Creo link para el kit de Inicio
                List<Envio_sin_Cargo__c> kits = [
                    SELECT  Id
                    FROM    Envio_sin_Cargo__c
                    WHERE   Es_De_Portal_Pacientes__c =: true
                        AND Paciente__c =: idPaciente
                    LIMIT 1
                ];

                if (!kits.isEmpty()) {
                    ContentDocumentLink newLinkKit = new ContentDocumentLink();
                    newLinkKit.LinkedEntityId = kits.get(0).Id;
                    newLinkKit.ContentDocumentId = listContentVersionDB.get(0).ContentDocumentId;
                    newLinkKit.ShareType = 'v';
                    try {
                        insert newLinkKit;
                    } catch (Exception excContentDocumentLinkKit) {
                        String error = 'getMessage: ' + excContentDocumentLinkKit.getMessage() + 'getLineNumber: ' + excContentDocumentLinkKit.getLineNumber();
                        generateLogForm(idPaciente, error, newLinkKit, null);
                        editTaskAltaPaciente(idPaciente);
                    }
                }

                //Creo link para el paciente
                ContentDocumentLink newLinkPaciente = new ContentDocumentLink();
                newLinkPaciente.LinkedEntityId = idPaciente;
                newLinkPaciente.ContentDocumentId = listContentVersionDB.get(0).ContentDocumentId;
                newLinkPaciente.ShareType = 'v';
    
                try {
                    insert newLinkPaciente;
                } catch (Exception excContentDocumentLink) {
                    String error = 'getMessage: ' + excContentDocumentLink.getMessage() + 'getLineNumber: ' + excContentDocumentLink.getLineNumber();
                    generateLogForm(idPaciente, error, newLinkPaciente, null);
                    editTaskAltaPaciente(idPaciente);
                }
            }
        } catch (Exception excContentVersion) {
            String error = 'getMessage: ' + excContentVersion.getMessage() + 'getLineNumber: ' + excContentVersion.getLineNumber();
            generateLogForm(idPaciente, error, contentVersion, null);
            editTaskAltaPaciente(idPaciente);
        }
        
        return idPaciente;
    }

    @AuraEnabled
    public static Task crearTareaPSP(String idPaciente) {
        Group psp = [
            SELECT Id
            FROM Group
            WHERE Type = 'Queue'
                AND NAME = 'PSP'
            LIMIT 1
        ];

        Task tareaPacienteWeb = new Task();
        tareaPacienteWeb.Type = 'Alta paciente via web';
        tareaPacienteWeb.Status = 'Abierta';
        tareaPacienteWeb.Subject = 'Alta Paciente Via Web';
        tareaPacienteWeb.WhatId = idPaciente;
        tareaPacienteWeb.Description = Label.Registro_Kit_de_Inicio_exitoso;
        tareaPacienteWeb.RecordTypeId = XappiaHelper.getRecordType('Task', 'Tarea').Id;
        tareaPacienteWeb.ActivityDate = getActivityDateTask(System.today());
        tareaPacienteWeb.OwnerId = psp.Id;

        return tareaPacienteWeb;
    }

    @AuraEnabled
    public static Envio_sin_Cargo__c crearKitDeInicio(Product2 producto, String alimentacion, String idPaciente) {
        Map<String,String> mapAreaAutoriza = generarRelacionAreaTerapeuticaYAutorizaEnvio();

        Envio_sin_Cargo__c kit = new Envio_sin_Cargo__c();
        kit.Paciente__c = idPaciente;
        kit.Estado_del_envio__c = 'Ingresado';
        kit.Razon_de_envio__c = 'Kit de Inicio';
        kit.Organizacion__c = producto.Organizacion__c;
        kit.Es_De_Portal_Pacientes__c = true;
        if(mapAreaAutoriza.containsKey(producto.Area_Terapeutica__c)){
            kit.Autoriza_Envio__c = mapAreaAutoriza.get(producto.Area_Terapeutica__c);
        }

        return kit;
    }

    @AuraEnabled
    public static List<Producto_de_envio__c> crearProductosDeKit(Product2 producto, String alimentacion, String idPaciente, String idKit) {
        List<Producto_de_envio__c> productosKit = new List<Producto_de_envio__c>();

        Producto_de_envio__c productoDeEnvio = new Producto_de_envio__c();
        productoDeEnvio.Envio_sin_cargo__c = idKit;
        productoDeEnvio.Formula__c = producto.Id;
        productoDeEnvio.Cantidad__c = String.valueOf(producto.Unidades_de_Kit__c);
        productosKit.add(productoDeEnvio);
        
        String idMateriales = agregarMaterialesDeKitInicio(producto.Codigo_producto_Id_externo__c, alimentacion);

        if(idMateriales != null){
            Producto_de_envio__c materialesDeProducto = new Producto_de_envio__c();
            materialesDeProducto.Envio_sin_cargo__c = idKit;
            materialesDeProducto.Formula__c = idMateriales;
            materialesDeProducto.Cantidad__c = '1';
            productosKit.add(materialesDeProducto);
        }

        return productosKit;
    }

    public static Map<String,String> generarRelacionAreaTerapeuticaYAutorizaEnvio() {
        Map<String,String> mapAreaAutoriza = new Map<String,String>();

        List<Dependencia_area_envio__mdt> areasEnvios = [
            SELECT  Area_Terapeutica__c, Autoriza_Envio__c
            FROM    Dependencia_area_envio__mdt
        ];

        for (Dependencia_area_envio__mdt area : areasEnvios) {
            mapAreaAutoriza.put(area.Area_Terapeutica__c, area.Autoriza_Envio__c);
        }

        return mapAreaAutoriza;
    }

    public static String agregarMaterialesDeKitInicio(String producto, String alimentacion) {
        String codigoMateriales;
        List<Dependencia_ProductoKit_Materiales__mdt> productoMateriales = [
            SELECT  Producto_Kit__c, Alimentacion__c, Materiales_Kit__c
            FROM    Dependencia_ProductoKit_Materiales__mdt
            WHERE   Producto_Kit__c =: producto
        ];

        if(productoMateriales.size() < 1){
            return null;
        }
        else if(productoMateriales.size() == 1 ){
            codigoMateriales = productoMateriales.get(0).Materiales_Kit__c;
        }
        else{
            for(Dependencia_ProductoKit_Materiales__mdt productoMaterial : productoMateriales){
                if(productoMaterial.Alimentacion__c == alimentacion){
                    codigoMateriales = productoMaterial.Materiales_Kit__c;
                }
            }
        }

        if(codigoMateriales != null){
            List<Product2> materiales = [
                SELECT  Id
                FROM    Product2
                WHERE   Codigo_producto_Id_externo__c =: codigoMateriales
                LIMIT   1
            ];
            
            if(!materiales.isEmpty()){
                return materiales[0].Id;
            }
        }

        return null;
    }

    public static Date getActivityDateTask(Date dia) {
        Datetime dt = DateTime.newInstance(dia, Time.newInstance(0, 0, 0, 0));
        String dayOfWeek = dt.format('EEEE');

        if(dayOfWeek == 'Friday'){
            return dia.addDays(3);
        }
        if(dayOfWeek == 'Saturday'){
            return dia.addDays(2);
        }
        else {
            return dia.addDays(1);
        }
    }

    public static String setFormatoTelefono(String tipoDeTelefono, String numero) {
        String telefonoConFormato = numero;

        if(tipoDeTelefono.equals('Casa')){
            telefonoConFormato = '54' + numero;
        }
        if(tipoDeTelefono.equals('Celular')){
            telefonoConFormato = '549' + numero;
        }

        return telefonoConFormato;
    }

    public static String setValidName(String name) {
        String lowerCase = name.toLowerCase();
        String result = '';

        for (String word : lowerCase.split(' ')) {
            if(String.isNotBlank(word)) {
                result += word.capitalize().trim() + ' ';
            }
        }

        return result.trim();
    }

    public static void generateLogForm(Id idPaciente, String message, SObject failedObject, List<SObject> failedObjectList){
        Log_Form__c log = new Log_Form__c();
        log.Paciente__c = idPaciente;
        log.Error__c = message;
        log.Comentario__c = setComentarioLog(message);
        if(failedObject != null){
            log.Objeto_Fallido__c = failedObject.getSObjectType().getDescribe().getLabel();
            log.Name = 'Error al crear ' + log.Objeto_Fallido__c;
            log.Registro__c = JSON.serialize(failedObject);
        }
        if(failedObjectList != null){
            log.Objeto_Fallido__c = failedObjectList[0].getSObjectType().getDescribe().getLabel();
            log.Name = 'Error al crear ' + log.Objeto_Fallido__c;
            log.Registro__c = JSON.serialize(failedObjectList);
        }

        insert log;
    }

    public static Task generateTaskKitFallido(String logId){
        Group psp = [
            SELECT Id
            FROM Group
            WHERE Type = 'Queue'
                AND NAME = 'PSP'
            LIMIT 1
        ];

        Task task = new Task();
        task.Status = 'Abierta';
        task.Subject = 'Error Formulario Kit de Inicio';
        task.WhatId = logId;
        task.Description = Label.Error_registro_Kit_de_Inicio_completo;
        task.RecordTypeId = XappiaHelper.getRecordType('Task', 'Tarea').Id;
        task.ActivityDate = getActivityDateTask(System.today());
        task.OwnerId = psp.Id;

        return task;
    }

    public static void editTaskAltaPaciente(String idPaciente){
        List<Task> tasks = [
            SELECT  Id, Description
            FROM    Task
            WHERE   WhatId=: idPaciente
                AND Subject= 'Alta Paciente Via Web'
        ];

        if(!tasks.isEmpty()){
            tasks[0].Description = Label.Error_registro_Kit_de_Inicio_parcial;

            update tasks;
        }
    }

    public static String setComentarioLog(String error){
        List<Errores_Formulario_NSJ__mdt> mensajesErrores = [
            SELECT  Label, Palabras_Errores__c, Mensaje__c
            FROM    Errores_Formulario_NSJ__mdt
        ];
        Map<String, List<String>> mapPalabras = new Map<String, List<String>>();
        Map<String, String> mapMensajes = new Map<String, String>();

        for (Errores_Formulario_NSJ__mdt msjError : mensajesErrores){
            mapMensajes.put(msjError.Label, msjError.Mensaje__c);
            List<String> listaPalabras = msjError.Palabras_Errores__c.split(',');
            mapPalabras.put(msjError.Label, listaPalabras);
        }

        System.debug(error);
        for (String key : mapPalabras.keySet()){
            Boolean isAll = true;
            for(String palabra : mapPalabras.get(key)){
                System.debug(palabra);
                if(!error.contains(palabra)){
                    isAll = false;
                }
            }
            if(isAll){
                return mapMensajes.get(key);
            }
        }

        return '';
    }

    @AuraEnabled
    public static Track_Solicitud_Kit_de_Inicio__c generateTrackForm(Track_Solicitud_Kit_de_Inicio__c track){
        try {
            upsert track;
            return track;
        } catch (DMLException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
            return null;
        }
    }

    @AuraEnabled(cacheable=true)
    public static Boolean isPaciente(String dni) {
        List<Account> pacientes = [
            SELECT Id
            FROM Account
            WHERE DNI__c =: dni
        ]; 
        
        return pacientes.isEmpty() ? false : true;
    }
}