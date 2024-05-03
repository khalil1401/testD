@IsTest
public class FormularioRegistroControllerTest {

    @IsTest
    static void testSiGeneroUnaCuentaSeDebeInsertarCorrectamente() {
        Account account = Build.anAccountCuentacommunity()
            .withFirstName('Nombre')
            .withLastName('Apellido')
            .withEmail('nombreapellido@testdanone.com')
            .build();
        account.Tipo_de_telefono__c = 'Casa';
        account.Phone = '21321312';
        account.Referencia__c = 'referencia';

        Product2 producto = Build.aProduct2().build();
        producto.Producto_SAP__c = true;
        producto.Es_de_Kit_de_Inicio__c = true;
        producto.Unidades_de_Kit__c = 2;
        producto.Area_Terapeutica__c = 'Dieta Cetogénica';
        producto.Organizacion__c = 'AMN';
        insert producto;

        Test.startTest();
            Id idAccount = FormularioRegistroController.saveAccount(account, producto.Id, 'SNE');
        Test.stopTest();

        List<Account> accountDB = [
            SELECT  Id, FirstName, LastName, PersonEmail, Phone, Area_terapeutica__c, Referencia__c, Tipo_de_telefono__c
            FROM    Account
            WHERE   Id =: idAccount
        ];
        
        System.assertEquals(account.FirstName, accountDB.get(0).FirstName,
            'El nombre de la cuenta registrada no coincide con el de la cuenta almacenada');
        System.assertEquals(account.LastName, accountDB.get(0).LastName,
            'El apellido de la cuenta registrada no coincide con el de la cuenta almacenada');
        System.assertEquals(account.PersonEmail, accountDB.get(0).PersonEmail,
            'El personemail de la cuenta registrada no coincide con el de la cuenta almacenada');
        System.assertEquals(account.Tipo_de_telefono__c, accountDB.get(0).Tipo_de_telefono__c,
            'El telefono de la cuenta registrada no coincide con el de la cuenta almacenada');
        System.assertEquals('5421321312', accountDB.get(0).Phone,
            'El telefono de la cuenta registrada no coincide con el de la cuenta almacenada');
        System.assertEquals(producto.Area_Terapeutica__c, accountDB.get(0).Area_terapeutica__c,
            'El area terapeutica de la cuenta registrada no coincide con el del producto seleccionado');
        System.assertEquals(account.Referencia__c.toUppercase(), accountDB.get(0).Referencia__c,
            'La referencia de la cuenta no es igual a la direccion siendo vacía');
    }

    @IsTest
    static void testSiGeneroUnContactoSeDebeGenerarUnContactoDePacienteYAsociarloConElContactoYLaCuenta() {
        Account account = Build.anAccountCuentacommunity()
            .withFirstName('Nombre')
            .withLastName('Apellido')
            .withEmail('nombreapellido@testdanone.com')
            .withTelefono('12345678')
            .build();
        account.RecordTypeId = XappiaHelper.getRecordType('Account', 'Paciente Regular').Id;
        account.Area_terapeutica__c = 'Dieta Cetogénica';

        insert account;

        List<Contact> contacts = new List<Contact>();

        Contact contact = Build.aContact()
            .withFirstName('Madre')
            .withLastName('Madre')
            .build();
        contact.DNI__c = '13236546';
        contact.Relacion__c = 'Madre';
        contact.Principal__c = true;
        contact.Email = 'contact@gmail.com';
        contact.Tipo_de_Telefono_de_Contacto__c = 'Celular';
        contact.Phone = '11223366';
        contacts.add(contact);

        Test.startTest();
            Id contactPaciente = FormularioRegistroController.saveContacts(contacts, account.Id);
        Test.stopTest();

        List<Contacto_de_paciente__c> contactoPacienteDB = [
            SELECT  Id, Contacto__r.FirstName, Contacto__r.LastName, Paciente__c, Principal__c
            FROM    Contacto_de_paciente__c
            WHERE   Paciente__c =: account.Id
        ];

        Account accountDB = [
            SELECT  Nombre_de_Contacto__c, V_nculo__c, Tel_fono_2__c, Correo_electronico_de_Contacto__c, Tipo_de_telefono_2__c, PersonEmail
            FROM    Account
            WHERE   Id =: account.Id
        ];

        System.assertEquals(1, contactoPacienteDB.size(),
            'No se generó ningún contacto de paciente');
        System.assertEquals(contact.FirstName, contactoPacienteDB.get(0).Contacto__r.FirstName,
            'El primer nombre del contacto de paciente no es igual al del contacto');
        System.assertEquals(contact.LastName, contactoPacienteDB.get(0).Contacto__r.LastName,
            'El apellido del contacto de paciente no es igual al del contacto');
        System.assertEquals(true, contactoPacienteDB.get(0).Principal__c,
            'El primer contacto agregado principal no es principal');

        System.assertEquals(contact.FirstName + ' ' +contact.LastName, accountDB.Nombre_de_Contacto__c,
            'El nombre del contacto no está relacionado a la cuenta');
        System.assertEquals(contact.Relacion__c, accountDB.V_nculo__c,
            'La relación del contacto no está relacionado a la cuenta');
        System.assertEquals(contact.Email, accountDB.Correo_electronico_de_Contacto__c,
            'El email del contacto no está relacionado a la cuenta');
        System.assertEquals(contact.Tipo_de_Telefono_de_Contacto__c, accountDB.Tipo_de_telefono_2__c,
            'El tipo de telefono del contacto no está relacionado a la cuenta');
        System.assertEquals(contact.MobilePhone, accountDB.Tel_fono_2__c,
            'El telefono del contacto no está relacionado a la cuenta');
    }

    @IsTest
    static void testSiGenero2ContactosSeDebeGenerarLosContactosDePacienteAsociados() {
        Account account = Build.anAccountCuentacommunity()
            .withFirstName('Nombre')
            .withLastName('Apellido')
            .withEmail('nombreapellido@testdanone.com')
            .withTelefono('12345678')
            .build();
        account.RecordTypeId = XappiaHelper.getRecordType('Account', 'Paciente Regular').Id;
        account.Area_terapeutica__c = 'Dieta Cetogénica';
        insert account;        

        List<Contact> firstContacts = new List<Contact>();

        Contact contactMadre = Build.aContact()
            .withFirstName('Madre')
            .withLastName('Madre')
            .build();
        contactMadre.Principal__c = false;
        contactMadre.Relacion__c = 'Madre';
        contactMadre.DNI__c = '22333444';
        firstContacts.add(contactMadre);

        FormularioRegistroController.saveContacts(firstContacts, account.Id);

        List<Contact> secondContacts = new List<Contact>();

        Contact contactPadre = Build.aContact()
            .withFirstName('Padre')
            .withLastName('Padre')
            .build();
        contactMadre.Principal__c = false;
        contactPadre.Relacion__c = 'Padre';
        contactPadre.DNI__c = '22333444';
        secondContacts.add(contactPadre);

        Test.startTest();
            Id idAccount = FormularioRegistroController.saveContacts(secondContacts, account.Id);
        Test.stopTest();

        List<Contact> contactsDB = [
            SELECT  Id, DNI__c, Name
            FROM    Contact
            WHERE   Paciente__c =: account.Id
        ];

        List<Contacto_de_paciente__c> contactoPacienteDB = [
            SELECT  Id, Contacto__r.FirstName, Contacto__r.LastName, Paciente__c
            FROM    Contacto_de_paciente__c
            WHERE   Paciente__c =: account.Id
        ];

        System.assertEquals(1, contactsDB.size(),
            'Se generó un contacto de mas con el mismo DNI.');

        System.assertEquals(2, contactoPacienteDB.size(),
            'No se generaron los 2 contactos de pacientes esperados.');
    }

    @IsTest
    static void testSiAgregoLosObjetosRelacionadosATratamientoSeDebenGuardarCorrectamente() {

        Account account = Build.anAccountCuentacommunity()
            .withFirstName('Nombre')
            .withLastName('Apellido')
            .withEmail('nombreapellido@testdanone.com')
            .build();
        account.RecordTypeId = XappiaHelper.getRecordType('Account', 'Paciente Regular').Id;
        insert account;

        Account centroTratamiento = Build.anAccountInstitucion()
            .withName('Centro')
            .build();
        insert centroTratamiento;

        Account os = Build.anAccountObrasocial()
            .withName('Obra Social')
            .build();
        insert os;

        Account profesional = Build.anAccountProfesionaldelasalud()
            .withLastName('Apellido')
            .build();
        insert profesional;

        Tratamiento__c tratamiento = new Tratamiento__c();
        tratamiento.RecordTypeId = XappiaHelper.getRecordType('Tratamiento__c', 'Tratamiento Regular').Id;
        tratamiento.Diagnostico__c = 'Si';
        tratamiento.Alimentacion__c = 'SNO';
        tratamiento.Centro_de_tratamiento__c = centroTratamiento.Id;
        tratamiento.Obra_social__c = os.Id;

        Tratamiento_de_profesional__c tratProfe = new Tratamiento_de_profesional__c();
        tratProfe.Profesional__c = profesional.Id;

        Product2 producto = Build.aProduct2().build();
        producto.Producto_SAP__c = true;
        producto.Es_de_Kit_de_Inicio__c = true;
        producto.Unidades_de_Kit__c = 2;
        producto.Area_Terapeutica__c = 'Dieta Cetogénica';
        producto.Organizacion__c = 'AMN';
        insert producto;

        Producto_de_paciente__c productoPaciente = Build.aProductodepaciente()
            .build();
        productoPaciente.Formula__c = producto.Id;

        Test.startTest();
            Id idPaciente = FormularioRegistroController.saveObjetosTratamiento(tratamiento, productoPaciente, tratProfe, account.Id);
        Test.stopTest();

        Tratamiento__c tratamientosDB = [
            SELECT  Id, Cuenta__c
            FROM    Tratamiento__c
            LIMIT 1
        ];

        Tratamiento_de_profesional__c tratamientosDeProfDB = [
            SELECT  Id, Tratamiento__c, Profesional__c
            FROM    Tratamiento_de_profesional__c
            LIMIT 1
        ];

        Producto_de_paciente__c productoPacienteDB = [
            SELECT  Id, Tratamiento__c, Formula__c
            FROM    Producto_de_paciente__c
            LIMIT 1
        ];

        System.assertEquals(account.Id, tratamientosDB.Cuenta__c,
            'El producto de paciente generado no esta asociado con el producto correcto');
        System.assertEquals(tratamientosDB.Id, tratamientosDeProfDB.Tratamiento__c,
            'El tratamiento del producto de paciente generado no esta asociado con el tratamiento correcto');
        System.assertEquals(profesional.Id, tratamientosDeProfDB.Profesional__c,
            'El tratamiento del producto de paciente generado no esta asociado con el tratamiento correcto');
        System.assertEquals(producto.Id, productoPacienteDB.Formula__c,
            'El producto de paciente generado no esta asociado con el producto correcto');
        System.assertEquals(tratamiento.Id, productoPacienteDB.Tratamiento__c,
            'El tratamiento del producto de paciente generado no esta asociado con el tratamiento correcto');

    }

    @IsTest
    static void testPicklistRelacionContacto(){
    	Test.startTest();
            List<String> options = FormularioRegistroController.getPickListRelacionContacto();
        Test.stopTest();
        
        System.assertEquals(options.size() != 0, true,
            'No encontro las relaciones de contacto');
    }

    @IsTest
    static void testPicklistSexo(){
    	Test.startTest();
            List<String> options = FormularioRegistroController.getPickListSexo();
        Test.stopTest();
        
        System.assertEquals(options.size() != 0, true,
            'No encontro los sexos');
    }

    @IsTest
    static void testPicklistTiposDeTelefonos(){
    	Test.startTest();
            List<String> options = FormularioRegistroController.getPickListTiposDeTelefono();
        Test.stopTest();
        
        System.assertEquals(options.size() != 0, true,
            'No encontro los tipos de telefonos');
    }

    @IsTest
    static void testPicklistDiagnosticos() {
    	Test.startTest();
            List<String> options = FormularioRegistroController.getPickListDiagnosticos();
        Test.stopTest();
        
        System.assertEquals(options.size() != 0, true,
            'No encontro los diagnosticos');
    }

    @IsTest
    static void testPicklistPatologias(){
    	Test.startTest();
            List<String> options = FormularioRegistroController.getPickListPatologias('Alergia');
        Test.stopTest();
        
        System.assertEquals(options.size() != 0, true,
            'No encontro las patologias');
    }

    @IsTest
    static void testPicklistTiposDeTelefonosDeContacto(){
    	Test.startTest();
            List<String> options = FormularioRegistroController.getPickListTiposDeTelefonoContacto();
        Test.stopTest();
        
        System.assertEquals(options.size() != 0, true,
            'No encontro los tipos de telefonos de contacto');
    }

    @IsTest
    static void testSiConsultoLasProvinciasDevuelveLasExistentesEnMunicipios(){
        Test.startTest();
            List<String> provincias = FormularioRegistroController.getPickListProvincias();
        Test.stopTest();

        System.assertNotEquals(0, provincias.size(),
            'No se encontró alguna provincia');
    }

    @IsTest
    static void testSiConsultoLosMunicipiosSeDevuelvenLosExistentesDeLaProvincaSeleccionada(){
        Municipio__c municipio = new Municipio__c();
        municipio.Name = 'Municipio';
        municipio.Descripcion_Provincia__c = 'BUENOS AIRES';
        insert municipio;
        
        Test.startTest();
            List<Municipio__c> municipios = FormularioRegistroController.getPickListMunicipios('BUENOS AIRES');
        Test.stopTest();

        System.assertEquals(1, municipios.size(),
            'No se encontraron los municipios');
    }

    @IsTest
    static void testSiConsultoPicklistScreeningNutricionalSeDebenDevolverLosValoresExistentes(){
        Test.startTest();
            List<String> screeningNutricional = FormularioRegistroController.getPickListScreeningNutricional();
        Test.stopTest();

        System.assert(!screeningNutricional.isEmpty(),
            'No se encontraron las opciones para screening nutricional');
    }

    @IsTest
    static void testSiConsultoPicklistHerramientasScreeningNutricionalSeDebenDevolverLosValoresExistentes(){
        Test.startTest();
            List<String> herramientasScreening = FormularioRegistroController.getPickListHerramientasScreening();
        Test.stopTest();

        System.assert(!herramientasScreening.isEmpty(),
            'No se encontró alguna herramienta para screening nutricional');
    }

    @IsTest
    static void testSiConsultoPicklistResultadoScreeningNutricionalSeDebenDevolverLosValoresExistentes(){
        Test.startTest();
            List<String> resultadosScreening = FormularioRegistroController.getPickListResultadosScreening();
        Test.stopTest();

        System.assert(!resultadosScreening.isEmpty(),
            'No se encontró algún resultado para screening nutricional');
    }

    @IsTest
    static void testSiGuardoUnContentVersionSeDebeGuardarCorrectamenteYGenerarElLinkConElPacienteYKit(){
        Account paciente = Build.anAccountCuentacommunity()
            .withFirstName('Nombre')
            .withLastName('Apellido')
            .withEmail('nombreapellido@testdanone.com')
            .build();
        paciente.RecordTypeId = XappiaHelper.getRecordType('Account', 'Paciente Regular').Id;

        Product2 producto = Build.aProduct2().build();
        producto.Producto_SAP__c = true;
        producto.Es_de_Kit_de_Inicio__c = true;
        producto.Unidades_de_Kit__c = 2;
        producto.Area_Terapeutica__c = 'Dieta Cetogénica';
        producto.Organizacion__c = 'AMN';
        insert producto;

        Id idPaciente = FormularioRegistroController.saveAccount(paciente, producto.Id, 'SNE');

        Test.startTest();
            Id link = FormularioRegistroController.saveCupon(paciente.Id, 'archivo', 'test');
        Test.stopTest();

        List<ContentDocumentLink> linkPacienteDB = [
            SELECT  Id, LinkedEntityId
            FROM    ContentDocumentLink
            WHERE   LinkedEntityId =: idPaciente
        ];

        List<Envio_sin_Cargo__c> kitsDB = [
            SELECT  Id
            FROM    Envio_sin_Cargo__c
            WHERE   Paciente__c =: idPaciente
        ];

        List<ContentDocumentLink> linkKitDB = [
            SELECT  Id, LinkedEntityId
            FROM    ContentDocumentLink
            WHERE   LinkedEntityId =: kitsDB.get(0).Id
        ];

        System.assertEquals(1, linkPacienteDB.size(),
            'No se creo la relación del archivo con el paciente');
        System.assertEquals(1, linkKitDB.size(),
            'No se creo la relación del archivo con el kit de inicio');
    }

    @IsTest
    static void testSiGuardoUnPacienteAtravesDelPortalSeDebeGenerarLaTareaParaElPSP() {
        Account paciente = Build.anAccountCuentacommunity()
            .withFirstName('Nombre')
            .withLastName('Apellido')
            .withEmail('nombreapellido@testdanone.com')
            .build();
        paciente.Tipo_de_telefono__c = 'Celular';
        paciente.Phone = '21321312';

        Product2 producto = Build.aProduct2().build();
        producto.Producto_SAP__c = true;
        producto.Es_de_Kit_de_Inicio__c = true;
        producto.Unidades_de_Kit__c = 2;
        producto.Area_Terapeutica__c = 'Dieta Cetogénica';
        producto.Organizacion__c = 'AMN';
        insert producto;

        Test.startTest();
            Id idPaciente = FormularioRegistroController.saveAccount(paciente, producto.Id, 'SNE');
        Test.stopTest();

        List<Task> tareasPSPDB = [
            SELECT  Id, Status, Subject, Type, OwnerId
            FROM    Task
            WHERE   WhatId =: paciente.Id
        ];

        Group psp = [
            SELECT Id
            FROM Group
            WHERE Type = 'Queue'
                AND NAME = 'PSP'
            LIMIT 1
        ];

        System.assertEquals(1, tareasPSPDB.size(),
            'No se encontró la tarea del PSP al generar un paciente por el portal');
        System.assertEquals('Abierta', tareasPSPDB.get(0).Status,
            'La tarea del PSP no tiene el status abierto');
        System.assertEquals('Alta paciente via web', tareasPSPDB.get(0).Type,
            'La tarea del PSP no tiene el type Alta paciente via Web');
        System.assertEquals('Alta Paciente Via Web', tareasPSPDB.get(0).Subject,
            'La tarea del PSP no tiene el Subject Alta paciente via Web');
        System.assertEquals(psp.Id, tareasPSPDB.get(0).OwnerId,
            'La tarea del PSP no tiene el type Alta paciente via Web');
        System.assertEquals('54921321312', paciente.Phone,
            'El paciente no tiene el formato de telefono correcto');
    }

    @IsTest
    static void testSiGuardoUnPacienteConProductoCetogenicoSeDebeGenerarElKitDeInicioConELMaterialCorrespondiente() {
        Account paciente = Build.anAccountCuentacommunity()
            .withFirstName('Nombre')
            .withLastName('Apellido')
            .withEmail('nombreapellido@testdanone.com')
            .withTelefono('12345678')
            .build();

        Product2 producto = Build.aProduct2().build();
        producto.Producto_SAP__c = true;
        producto.Es_de_Kit_de_Inicio__c = true;
        producto.Unidades_de_Kit__c = 2;
        producto.Codigo_producto_Id_externo__c = '168049';
        producto.Area_Terapeutica__c = 'Dieta Cetogénica';
        producto.Organizacion__c = 'AMN';
        insert producto;

        Product2 material = Build.aProduct2().build();
        material.Codigo_producto_Id_externo__c = '176035';
        material.Area_Terapeutica__c = 'Dieta Cetogénica';
        material.Producto_SAP__c = true;
        insert material;

        Test.startTest();
            Id idPaciente = FormularioRegistroController.saveAccount(paciente, producto.Id, 'SNE');
        Test.stopTest();
   
        List<Envio_sin_Cargo__c> kitsDB = [
            SELECT  Id, Estado_del_envio__c, Razon_de_envio__c, Organizacion__c, Autoriza_Envio__c, Es_De_Portal_Pacientes__c
            FROM    Envio_sin_Cargo__c
            WHERE   Paciente__c =: idPaciente
        ];

        List<Producto_de_envio__c> productosDeEnvioDB = [
            SELECT  Id, Formula__c, Cantidad__c, Envio_sin_cargo__c
            FROM    Producto_de_envio__c
            WHERE   Envio_sin_cargo__c =: kitsDB.get(0).Id
            ORDER BY CreatedDate ASC
        ];

        Map<String,String> mapAreaAutoriza = new Map<String,String>();

        List<Dependencia_area_envio__mdt> areasEnvios = [
            SELECT  Area_Terapeutica__c, Autoriza_Envio__c
            FROM    Dependencia_area_envio__mdt
        ];

        for (Dependencia_area_envio__mdt area : areasEnvios) {
            mapAreaAutoriza.put(area.Area_Terapeutica__c, area.Autoriza_Envio__c);
        }

        System.assertEquals(1, kitsDB.size(), 
            'No se encontro el kit generado esperado');
        System.assertEquals('Ingresado', kitsDB.get(0).Estado_del_envio__c, 
            'El kit generado no tiene el estado de envio en Ingresado');
        System.assertEquals('Kit de Inicio', kitsDB.get(0).Razon_de_envio__c, 
            'El kit generado no tiene Kit de inicio como razon de envio');
        System.assertEquals(producto.Organizacion__c, kitsDB.get(0).Organizacion__c, 
            'El kit generado no tiene la organizacion del producto');
        System.assertEquals(mapAreaAutoriza.get(producto.Area_Terapeutica__c), kitsDB.get(0).Autoriza_Envio__c, 
            'El kit generado no tiene autoriza envío');
        System.assertEquals(true, kitsDB.get(0).Es_De_Portal_Pacientes__c, 
            'El kit generado no es de portal pacientes');
        System.assertEquals(2, productosDeEnvioDB.size(),
            'No se encontraron los productos de envío generados esperados');
        System.assertEquals(kitsDB.get(0).Id, productosDeEnvioDB.get(0).Envio_sin_cargo__c, 
            'El producto de envio no esta relacionado con el kit de inicio');
        System.assertEquals(producto.Id, productosDeEnvioDB.get(0).Formula__c, 
            'El producto de envio no esta relacionado con el producto');
        System.assertEquals(producto.Unidades_de_Kit__c + '', productosDeEnvioDB.get(0).Cantidad__c, 
            'El producto de envio no esta relacionado con las unidades del producto');
        System.assertEquals(material.Id, productosDeEnvioDB.get(1).Formula__c, 
            'El material del producto no es el correspondiente');
        System.assertEquals('1', productosDeEnvioDB.get(1).Cantidad__c, 
            'La cantidad del material del producto no es el correspondiente');
        
    }
    
    @IsTest
    static void testSiGuardoUnPacienteConProductoCetogenicoOralSeDebeGenerarElKitDeInicioConELMaterialCorrespondiente() {

        Account paciente = Build.anAccountCuentacommunity()
            .withFirstName('Nombre')
            .withLastName('Apellido')
            .withEmail('nombreapellido@testdanone.com')
            .withTelefono('12345678')
            .build();

        Product2 producto = Build.aProduct2().build();
        producto.Producto_SAP__c = true;
        producto.Es_de_Kit_de_Inicio__c = true;
        producto.Unidades_de_Kit__c = 2;
        producto.Codigo_producto_Id_externo__c = '168049';
        producto.Area_Terapeutica__c = 'Dieta Cetogénica';
        producto.Organizacion__c = 'AMN';
        insert producto;

        Product2 material = Build.aProduct2().build();
        material.Name = 'Material Cetogenica Oral';
        material.Codigo_producto_Id_externo__c = '176034';
        material.Area_Terapeutica__c = 'Dieta Cetogénica';
        material.Producto_SAP__c = true;
        insert material;

        Test.startTest();
            Id idPaciente = FormularioRegistroController.saveAccount(paciente, producto.Id, 'SNO');
        Test.stopTest();
   
        List<Envio_sin_Cargo__c> kitsDB = [
            SELECT  Id, Estado_del_envio__c, Razon_de_envio__c, Organizacion__c, Autoriza_Envio__c, Es_De_Portal_Pacientes__c
            FROM    Envio_sin_Cargo__c
            WHERE   Paciente__c =: idPaciente
        ];

        List<Producto_de_envio__c> productosDeEnvioDB = [
            SELECT  Id, Formula__c, Cantidad__c, Envio_sin_cargo__c
            FROM    Producto_de_envio__c
            WHERE   Envio_sin_cargo__c =: kitsDB.get(0).Id
            ORDER BY CreatedDate ASC
        ];

        Map<String,String> mapAreaAutoriza = new Map<String,String>();

        List<Dependencia_area_envio__mdt> areasEnvios = [
            SELECT  Area_Terapeutica__c, Autoriza_Envio__c
            FROM    Dependencia_area_envio__mdt
        ];

        for (Dependencia_area_envio__mdt area : areasEnvios) {
            mapAreaAutoriza.put(area.Area_Terapeutica__c, area.Autoriza_Envio__c);
        }

        System.assertEquals(1, kitsDB.size(), 
            'No se encontro el kit generado esperado');
        System.assertEquals('Ingresado', kitsDB.get(0).Estado_del_envio__c, 
            'El kit generado no tiene el estado de envio en Ingresado');
        System.assertEquals('Kit de Inicio', kitsDB.get(0).Razon_de_envio__c, 
            'El kit generado no tiene Kit de inicio como razon de envio');
        System.assertEquals(producto.Organizacion__c, kitsDB.get(0).Organizacion__c, 
            'El kit generado no tiene la organizacion del producto');
        System.assertEquals(mapAreaAutoriza.get(producto.Area_Terapeutica__c), kitsDB.get(0).Autoriza_Envio__c, 
            'El kit generado no tiene autoriza envío');
        System.assertEquals(true, kitsDB.get(0).Es_De_Portal_Pacientes__c, 
            'El kit generado no es de portal pacientes');
        System.assertEquals(2, productosDeEnvioDB.size(),
            'No se encontraron los productos de envío generados esperados');
        System.assertEquals(kitsDB.get(0).Id, productosDeEnvioDB.get(0).Envio_sin_cargo__c, 
            'El producto de envio no esta relacionado con el kit de inicio');
        System.assertEquals(producto.Id, productosDeEnvioDB.get(0).Formula__c, 
            'El producto de envio no esta relacionado con el producto');
        System.assertEquals(producto.Unidades_de_Kit__c + '', productosDeEnvioDB.get(0).Cantidad__c, 
            'El producto de envio no esta relacionado con las unidades del producto');
        System.assertEquals(material.Id, productosDeEnvioDB.get(1).Formula__c, 
            'El material del producto no es el correspondiente');
        System.assertEquals('1', productosDeEnvioDB.get(1).Cantidad__c, 
            'La cantidad del material del producto no es el correspondiente');
        
    }

    @IsTest
    static void testSiGuardoUnPacienteConProductoMetabolicoGMPROSeDebeGenerarElKitDeInicioConELMaterialCorrespondiente() {

        Account paciente = Build.anAccountCuentacommunity()
            .withFirstName('Nombre')
            .withLastName('Apellido')
            .withEmail('nombreapellido@testdanone.com')
            .withTelefono('12345678')
            .build();

        Product2 producto = Build.aProduct2().build();
        producto.Producto_SAP__c = true;
        producto.Es_de_Kit_de_Inicio__c = true;
        producto.Unidades_de_Kit__c = 1;
        producto.Codigo_producto_Id_externo__c = '177169';
        producto.Area_Terapeutica__c = 'Metabólicos';
        producto.Organizacion__c = 'AMN';
        insert producto;

        Product2 material = Build.aProduct2().build();
        material.Name = 'Material GMPRO';
        material.Codigo_producto_Id_externo__c = '181354';
        material.Area_Terapeutica__c = 'Metabólicos';
        material.Producto_SAP__c = true;
        insert material;

        Test.startTest();
            Id idPaciente = FormularioRegistroController.saveAccount(paciente, producto.Id, 'SNO');
        Test.stopTest();
   
        List<Envio_sin_Cargo__c> kitsDB = [
            SELECT  Id, Estado_del_envio__c, Razon_de_envio__c, Organizacion__c, Autoriza_Envio__c, Es_De_Portal_Pacientes__c
            FROM    Envio_sin_Cargo__c
            WHERE   Paciente__c =: idPaciente
        ];

        List<Producto_de_envio__c> productosDeEnvioDB = [
            SELECT  Id, Formula__c, Cantidad__c, Envio_sin_cargo__c
            FROM    Producto_de_envio__c
            WHERE   Envio_sin_cargo__c =: kitsDB.get(0).Id
            ORDER BY CreatedDate ASC
        ];

        Map<String,String> mapAreaAutoriza = new Map<String,String>();

        List<Dependencia_area_envio__mdt> areasEnvios = [
            SELECT  Area_Terapeutica__c, Autoriza_Envio__c
            FROM    Dependencia_area_envio__mdt
        ];

        for (Dependencia_area_envio__mdt area : areasEnvios) {
            mapAreaAutoriza.put(area.Area_Terapeutica__c, area.Autoriza_Envio__c);
        }

        System.assertEquals(1, kitsDB.size(), 
            'No se encontro el kit generado esperado');
        System.assertEquals('Ingresado', kitsDB.get(0).Estado_del_envio__c, 
            'El kit generado no tiene el estado de envio en Ingresado');
        System.assertEquals('Kit de Inicio', kitsDB.get(0).Razon_de_envio__c, 
            'El kit generado no tiene Kit de inicio como razon de envio');
        System.assertEquals(producto.Organizacion__c, kitsDB.get(0).Organizacion__c, 
            'El kit generado no tiene la organizacion del producto');
        System.assertEquals(mapAreaAutoriza.get(producto.Area_Terapeutica__c), kitsDB.get(0).Autoriza_Envio__c, 
            'El kit generado no tiene autoriza envío');
        System.assertEquals(true, kitsDB.get(0).Es_De_Portal_Pacientes__c, 
            'El kit generado no es de portal pacientes');
        System.assertEquals(2, productosDeEnvioDB.size(),
            'No se encontraron los productos de envío generados esperados');
        System.assertEquals(kitsDB.get(0).Id, productosDeEnvioDB.get(0).Envio_sin_cargo__c, 
            'El producto de envio no esta relacionado con el kit de inicio');
        System.assertEquals(producto.Id, productosDeEnvioDB.get(0).Formula__c, 
            'El producto de envio no esta relacionado con el producto');
        System.assertEquals(producto.Unidades_de_Kit__c + '', productosDeEnvioDB.get(0).Cantidad__c, 
            'El producto de envio no esta relacionado con las unidades del producto');
        System.assertEquals(material.Id, productosDeEnvioDB.get(1).Formula__c, 
            'El material del producto no es el correspondiente');
        System.assertEquals('1', productosDeEnvioDB.get(1).Cantidad__c, 
            'La cantidad del material del producto no es el correspondiente');
        
    }

    @IsTest
    static void testSiGuardoUnPacienteConProductoOncologicoSeDebeGenerarElKitDeInicioConELMaterialyAreaCorrespondiente() {
        Account paciente = Build.anAccountCuentacommunity()
            .withFirstName('Nombre')
            .withLastName('Apellido')
            .withEmail('nombreapellido@testdanone.com')
            .withTelefono('12345678')
            .build();

        Product2 producto = Build.aProduct2().build();
        producto.Producto_SAP__c = true;
        producto.Es_de_Kit_de_Inicio__c = true;
        producto.Unidades_de_Kit__c = 1;
        producto.Codigo_producto_Id_externo__c = '168741';
        producto.Area_Terapeutica__c = 'Oncología';
        producto.Organizacion__c = 'AMN';
        insert producto;

        Test.startTest();
            Id idPaciente = FormularioRegistroController.saveAccount(paciente, producto.Id, 'SNO');
        Test.stopTest();
   
        List<Envio_sin_Cargo__c> kitsDB = [
            SELECT  Id, Estado_del_envio__c, Razon_de_envio__c, Organizacion__c, Autoriza_Envio__c, Es_De_Portal_Pacientes__c
            FROM    Envio_sin_Cargo__c
            WHERE   Paciente__c =: idPaciente
        ];

        List<Producto_de_envio__c> productosDeEnvioDB = [
            SELECT  Id, Formula__c, Cantidad__c, Envio_sin_cargo__c
            FROM    Producto_de_envio__c
            WHERE   Envio_sin_cargo__c =: kitsDB.get(0).Id
            ORDER BY CreatedDate ASC
        ];

        Map<String,String> mapAreaAutoriza = new Map<String,String>();

        List<Dependencia_area_envio__mdt> areasEnvios = [
            SELECT  Area_Terapeutica__c, Autoriza_Envio__c
            FROM    Dependencia_area_envio__mdt
        ];

        for (Dependencia_area_envio__mdt area : areasEnvios) {
            mapAreaAutoriza.put(area.Area_Terapeutica__c, area.Autoriza_Envio__c);
        }

        System.assertEquals(1, kitsDB.size(), 
            'No se encontro el kit generado esperado');
        System.assertEquals('Ingresado', kitsDB.get(0).Estado_del_envio__c, 
            'El kit generado no tiene el estado de envio en Ingresado');
        System.assertEquals('Kit de Inicio', kitsDB.get(0).Razon_de_envio__c, 
            'El kit generado no tiene Kit de inicio como razon de envio');
        System.assertEquals(producto.Organizacion__c, kitsDB.get(0).Organizacion__c, 
            'El kit generado no tiene la organizacion del producto');
        System.assertEquals(mapAreaAutoriza.get(producto.Area_Terapeutica__c), kitsDB.get(0).Autoriza_Envio__c, 
            'El kit generado no tiene autoriza envío');
        System.assertEquals(true, kitsDB.get(0).Es_De_Portal_Pacientes__c, 
            'El kit generado no es de portal pacientes');
        System.assertEquals(1, productosDeEnvioDB.size(),
            'No se encontraron los productos de envío generados esperados');
        System.assertEquals(kitsDB.get(0).Id, productosDeEnvioDB.get(0).Envio_sin_cargo__c, 
            'El producto de envio no esta relacionado con el kit de inicio');
        System.assertEquals(producto.Id, productosDeEnvioDB.get(0).Formula__c, 
            'El producto de envio no esta relacionado con el producto');
        System.assertEquals(producto.Unidades_de_Kit__c + '', productosDeEnvioDB.get(0).Cantidad__c, 
            'El producto de envio no esta relacionado con las unidades del producto');        
    }

    @IsTest
    static void testSiRegistroUnaCuentaViernesOSabadoLaTareaDelPSPDebeVencerElLunes() {

        Datetime dt = DateTime.newInstance(System.today(), Time.newInstance(0, 0, 0, 0));
        String dayOfWeek = dt.format('EEEE');

        Test.startTest();
            Date diaVencimiento = FormularioRegistroController.getActivityDateTask(System.today());
        Test.stopTest();

        if(dayOfWeek == 'Friday') {
            System.assertEquals(System.today().addDays(3), diaVencimiento,
                'La fecha de vencimiento de la tarea no es la esperada para el viernes');
        }
        else if(dayOfWeek == 'Saturday') {
            System.assertEquals(System.today().addDays(2), diaVencimiento,
                'La fecha de vencimiento de la tarea no es la esperada para el sabado');
        }
        else {
            System.assertEquals(System.today().addDays(1), diaVencimiento,
                'La fecha de vencimiento de la tarea no es la esperada para cualquier dia menos viernes y sabado');
        }

    }

    @IsTest
    static void testSiElPacienteNoIngresaReferenciaSeDebeCopiarLaDireccion() {
        Account account = Build.anAccountCuentacommunity()
            .withFirstName('Nombre')
            .withLastName('Apellido')
            .withEmail('nombreapellido@testdanone.com')
            .withTelefono('12345678')
            .build();
        account.Direccion__c = 'referencia';
        account.Phone = '12345678';
        account.RecordTypeId = XappiaHelper.getRecordType('Account', 'Paciente Regular').Id;

        Product2 producto = Build.aProduct2().build();
        producto.Producto_SAP__c = true;
        producto.Es_de_Kit_de_Inicio__c = true;
        producto.Unidades_de_Kit__c = 2;
        producto.Area_Terapeutica__c = 'Dieta Cetogénica';
        producto.Organizacion__c = 'AMN';
        insert producto;

        Test.startTest();
            Id idAccount = FormularioRegistroController.saveAccount(account, producto.Id, 'SNE');
        Test.stopTest();

        List<Account> accountDB = [
            SELECT  Id, Referencia__c
            FROM    Account
            WHERE   Id =: idAccount
        ];

        System.assertEquals(account.Phone, accountDB.get(0).Referencia__c,
            'La referencia no es igual al teléfono cuando esta era vacia');
    }

/*
    @IsTest
    static void testSiGeneroUnPacienteConTratamientoSeDebeCrearElKitConAdicionalKitCorrecto() {

        Account account = Build.anAccountCuentacommunity()
            .withFirstName('Nombre')
            .withLastName('Apellido')
            .withEmail('nombreapellido@testdanone.com')
            .withTelefono('12345678')
            .build();
        account.RecordTypeId = XappiaHelper.getRecordType('Account', 'Paciente Regular').Id;

        Product2 producto = Build.aProduct2().build();
        producto.Producto_SAP__c = true;
        producto.Es_de_Kit_de_Inicio__c = true;
        producto.Unidades_de_Kit__c = 2;
        producto.Area_Terapeutica__c = 'Dieta Cetogénica';
        producto.Organizacion__c = 'AMN';
        insert producto;

        Id idPaciente = FormularioRegistroController.saveAccount(account, producto.Id);

        Account centroTratamiento = Build.anAccountInstitucion()
            .withName('Centro')
            .build();
        insert centroTratamiento;

        Account os = Build.anAccountObrasocial()
            .withName('Ministerio de Desarrollo Social')
            .build();
        insert os;

        Account profesional = Build.anAccountProfesionaldelasalud()
            .withLastName('Apellido')
            .build();
        insert profesional;

        Tratamiento__c tratamiento = new Tratamiento__c();
        tratamiento.RecordTypeId = XappiaHelper.getRecordType('Tratamiento__c', 'Tratamiento Regular').Id;
        tratamiento.Diagnostico__c = 'Si';
        tratamiento.Alimentacion__c = 'SNO';
        tratamiento.Centro_de_tratamiento__c = centroTratamiento.Id;
        tratamiento.Obra_social__c = os.Id;

        Tratamiento_de_profesional__c tratProfe = new Tratamiento_de_profesional__c();
        tratProfe.Profesional__c = profesional.Id;

        Test.startTest();
            Id idTrat = FormularioRegistroController.saveTratamiento(tratamiento, tratProfe, idPaciente);
        Test.stopTest();

        List<Envio_sin_Cargo__c> kitsDB = [
            SELECT  Id, Adicional_Kit__c
            FROM    Envio_sin_Cargo__c
            WHERE   Paciente__c =: idPaciente
        ];

        System.assertEquals('Balanza Ketocal Oral', kitsDB.get(0).Adicional_Kit__c,
            'El adicional del kit no se corresponde con la alimentacion del tratamiento');

    }
*/

    @IsTest
    static void testSiGeneroUnPacienteSinObraSocialSeTieneQueAsignarLaDelMinisterioDeDesarrolloSocial() {
        Account account = Build.anAccountCuentacommunity()
            .withFirstName('Nombre')
            .withLastName('Apellido')
            .withEmail('nombreapellido@testdanone.com')
            .withTelefono('12345678')
            .build();
        account.RecordTypeId = XappiaHelper.getRecordType('Account', 'Paciente Regular').Id;

        Product2 producto = Build.aProduct2().build();
        producto.Producto_SAP__c = true;
        producto.Es_de_Kit_de_Inicio__c = true;
        producto.Unidades_de_Kit__c = 2;
        producto.Area_Terapeutica__c = 'Dieta Cetogénica';
        producto.Organizacion__c = 'AMN';
        insert producto;

        Producto_de_paciente__c productoDePaciente = new Producto_de_paciente__c();
        productoDePaciente.Formula__c = producto.Id;

        Id idPaciente = FormularioRegistroController.saveAccount(account, producto.Id, 'SNE');

        Account centroTratamiento = Build.anAccountInstitucion()
            .withName('Centro')
            .build();
        insert centroTratamiento;

        Account os = Build.anAccountObrasocial()
            .withName('Ministerio de Desarrollo Social')
            .build();
        insert os;

        Account profesional = Build.anAccountProfesionaldelasalud()
            .withLastName('Apellido')
            .build();
        insert profesional;

        Tratamiento__c tratamiento = new Tratamiento__c();
        tratamiento.RecordTypeId = XappiaHelper.getRecordType('Tratamiento__c', 'Tratamiento Regular').Id;
        tratamiento.Diagnostico__c = 'Si';
        tratamiento.Alimentacion__c = 'SNO';
        tratamiento.Centro_de_tratamiento__c = centroTratamiento.Id;

        Tratamiento_de_profesional__c tratProfe = new Tratamiento_de_profesional__c();
        tratProfe.Profesional__c = profesional.Id;

        Test.startTest();
            Id idTrat = FormularioRegistroController.saveObjetosTratamiento(tratamiento, productoDePaciente, tratProfe, idPaciente);
        Test.stopTest();

        Tratamiento__c tratamientoDB = [
            SELECT  Id, Obra_Social__c 
            FROM    Tratamiento__c
            LIMIT 1
        ];

        System.assertEquals(os.Id, tratamientoDB.Obra_Social__c,
            'La obra social no se seto a la del ministerio de desarrollo social');
    }

    @IsTest
    static void testSiIngresoNombreConDiferentesEstilosSeDebeDevolverCamelCase() {
        String firstName = ' JuAn  ManUEL';
        String lastName = 'apelLido';

        Test.startTest();
            String firstNameCC = FormularioRegistroController.setValidName(firstName);
            String lastNameCC = FormularioRegistroController.setValidName(lastName);
        Test.stopTest();

        System.assertEquals('Juan Manuel', firstNameCC);
        System.assertEquals('Apellido', lastNameCC);
    }

    @IsTest
    static void testSiGeneroUnaCuentaConDNIDuplicadoSeDebeRegistrarElError() {
        Account pacienteViejo = Build.anAccountCuentacommunity()
            .withFirstName('Nombre')
            .withLastName('Apellido')
            .withDNI('12345678')
            .withEmail('nombreapellido@testdanone.com')
            .build();
        pacienteViejo.RecordTypeId = XappiaHelper.getRecordType('Account', 'Paciente Regular').Id;
        insert pacienteViejo;

        Account pacienteNuevo = Build.anAccountCuentacommunity()
            .withFirstName('Nombre')
            .withLastName('Apellido')
            .withDNI('12345678')
            .withEmail('nombreapellido@testdanone.com')
            .build();

        Product2 producto = Build.aProduct2().build();
        producto.Producto_SAP__c = true;
        producto.Es_de_Kit_de_Inicio__c = true;
        producto.Unidades_de_Kit__c = 2;
        producto.Area_Terapeutica__c = 'Dieta Cetogénica';
        producto.Organizacion__c = 'AMN';
        insert producto;

        Test.startTest();
            try {
                Id idAccount = FormularioRegistroController.saveAccount(pacienteNuevo, producto.Id, 'SNE');                
            } catch (Exception e) {
                List<Log_Form__c> logsForm = [
                    SELECT  Error__c, Objeto_Fallido__c, Datos_de_Paciente__c, Registro__c, Comentario__c
                    FROM    Log_Form__c
                ];

                List<Task> tasksKitFallido = [
                    SELECT  Subject
                    FROM    Task
                ];
                
                System.assertEquals(1, logsForm.size(),
                    'No se encontró el registro de log form al querer agregar un paciente con DNI duplicado');
                System.assertNotEquals('', logsForm[0].Error__c,
                    'No se encontró error en el registro de log form al querer agregar un paciente con DNI duplicado');
                System.assertEquals('Cuenta', logsForm[0].Objeto_Fallido__c,
                    'No se encontró el tipo de objeto fallido en el registro de log form al querer agregar un paciente con DNI duplicado');
                System.assertNotEquals('', logsForm[0].Datos_de_Paciente__c,
                    'No se encontró los datos de paciente del tipo de objeto fallido en el registro de log form al querer agregar un paciente con DNI duplicado');
                System.assertNotEquals('', logsForm[0].Registro__c,
                    'No se encontró el JSON en el registro de log form al querer agregar un paciente con DNI duplicado');
                System.assertNotEquals('', logsForm[0].Comentario__c,
                    'No se encontró el comentario para el PSP en el registro de log form al querer agregar un paciente con DNI duplicado');
                System.assertEquals(1, tasksKitFallido.size(),
                    'No se encontró la tarea de alta fallida al querer agregar un paciente con DNI duplicado');
                System.assertEquals('Error Formulario Kit de Inicio', tasksKitFallido[0].Subject,
                    'La tarea generada no es de Error Formulario Kit de Inicio al querer agregar un paciente con DNI duplicado');
            }
        Test.stopTest();
    }

    @IsTest
    static void testSiOcurreUnaExcepcionSeDebeRegistrarElErrorEnLogForm(){
        Account paciente = Build.anAccountCuentacommunity()
            .withFirstName('Nombre')
            .withLastName('Apellido')
            .withDNI('12345678')
            .withEmail('nombreapellido@testdanone.com')
            .build();
            paciente.RecordTypeId = XappiaHelper.getRecordType('Account', 'Paciente Regular').Id;
        insert paciente;

        Task tareaPacienteWeb = new Task();
        tareaPacienteWeb.Type = 'Alta paciente via web';
        tareaPacienteWeb.Status = 'Abierta';
        tareaPacienteWeb.Subject = 'Alta Paciente Via Web';
        tareaPacienteWeb.WhatId = paciente.Id;
        tareaPacienteWeb.RecordTypeId = XappiaHelper.getRecordType('Task', 'Tarea').Id;

        String error = 'Error objeto';

        Test.startTest();
            FormularioRegistroController.generateLogForm(paciente.Id, error, tareaPacienteWeb , null);
        Test.stopTest();

        List<Log_Form__c> logsForm = [
            SELECT Error__c, Objeto_Fallido__c, Datos_de_Paciente__c, Registro__c
            FROM Log_Form__c
        ];

        System.assertEquals(1, logsForm.size(),
            'No se encontraron los registros padre e hijo de log form');
    }

    @IsTest
    static void testSiOcurreUnaExcepcionSeDebeRegistrarElErrorEnLaTareaDelAltaDePacienteViaWeb(){
        Account account = Build.anAccountCuentacommunity()
            .withFirstName('Nombre')
            .withLastName('Apellido')
            .withEmail('nombreapellido@testdanone.com')
            .withTelefono('12345678')
            .build();
        account.Direccion__c = 'referencia';
        account.Phone = '12345678';

        Product2 producto = Build.aProduct2().build();
        producto.Producto_SAP__c = true;
        producto.Es_de_Kit_de_Inicio__c = true;
        producto.Unidades_de_Kit__c = 2;
        producto.Area_Terapeutica__c = 'Dieta Cetogénica';
        producto.Organizacion__c = 'AMN';
        insert producto;

        Id idAccount = FormularioRegistroController.saveAccount(account, producto.Id, 'SNE');

        Test.startTest();
            FormularioRegistroController.editTaskAltaPaciente(idAccount);
        Test.stopTest();

        Task task = [
            SELECT  Id, Description
            FROM    Task
            WHERE   WhatId=: idAccount
                AND Subject= 'Alta Paciente Via Web'
            LIMIT 1
        ];

        System.assertEquals(Label.Error_registro_Kit_de_Inicio_parcial, task.Description,
            'La tarea de alta de paceinte Via Web no se edito con los errores');
    }

    @IsTest
    static void testSiOcurreUnErrorAlAgregarElKitSeDebeRegistrar(){
        Account account = Build.anAccountCuentacommunity()
            .withFirstName('Nombre')
            .withLastName('Apellido')
            .withEmail('nombreapellido@testdanone.com')
            .withTelefono('12345678')
            .build();
        account.Direccion__c = 'referencia';
        account.Phone = '12345678';

        Product2 producto = Build.aProduct2().build();
        producto.Producto_SAP__c = true;
        producto.Es_de_Kit_de_Inicio__c = true;
        producto.Unidades_de_Kit__c = 2;
        producto.Area_Terapeutica__c = 'Dieta Cetogénica';
        producto.Organizacion__c = 'AMN';
        insert producto;

        Test.startTest();
            try {
                FormularioRegistroController.failedTest = true;
                Id idAccount = FormularioRegistroController.saveAccount(account, producto.Id, 'SNE');
            } catch (Exception e) {
                List<Log_Form__c> logsForm = [
                    SELECT  Error__c, Objeto_Fallido__c, Datos_de_Paciente__c, Registro__c
                    FROM    Log_Form__c
                ];

                List<Envio_Sin_Cargo__c> kits = [
                    SELECT  Id
                    FROM    Envio_Sin_Cargo__c
                ];

                System.assertEquals(1, logsForm.size(),
                    'No se encontró el registro de log form al querer agregar un paciente con DNI duplicado');
                System.assertEquals(0, kits.size(),
                    'Se encontró un kit al ocurrir un error');
            }
        Test.stopTest();
    }

    @IsTest
    static void testSiOcurreUnErrorAlIngresarUnContactoSeDebeRegistrar(){
        Account account = Build.anAccountCuentacommunity()
            .withFirstName('Nombre')
            .withLastName('Apellido')
            .withEmail('nombreapellido@testdanone.com')
            .withTelefono('12345678')
            .build();
        account.Direccion__c = 'referencia';
        account.Phone = '12345678';
        account.RecordTypeId = XappiaHelper.getRecordType('Account', 'Paciente Regular').Id;
        insert account;

        Contact contacto = Build.aContact().build();
        contacto.FirstName = 'Nombre';
        contacto.LastName = 'Apellido';
        contacto.Principal__c = false;
        contacto.Tipo_de_Telefono_de_Contacto__c = 'Casa';

        Contact contacto2 = Build.aContact().build();
        contacto2.FirstName = 'Nombre';
        contacto2.LastName = 'Apellido';
        contacto2.Principal__c = true;
        contacto2.Tipo_de_Telefono_de_Contacto__c = 'Casa';

        List<Contact> contactos = new List<Contact>();
        contactos.add(contacto);
        contactos.add(contacto2);

        Test.startTest();
            try {
                FormularioRegistroController.failedTest = true;
                Id idAccountContact = FormularioRegistroController.saveContacts(contactos, account.Id);
            } catch (Exception e) {
                List<Log_Form__c> logsForm = [
                    SELECT  Error__c, Objeto_Fallido__c, Datos_de_Paciente__c, Registro__c
                    FROM    Log_Form__c
                ];

                System.assertEquals(1, logsForm.size(),
                    'No se encontró el registro de log form al querer agregar un contacto');
            }
        Test.stopTest();
    }

    @IsTest
    static void testSiOcurreUnErrorAlIngresarUnTratamientoSeDebeRegistrar(){
        Account account = Build.anAccountCuentacommunity()
            .withFirstName('Nombre')
            .withLastName('Apellido')
            .withEmail('nombreapellido@testdanone.com')
            .withTelefono('12345678')
            .build();
        account.Direccion__c = 'referencia';
        account.Phone = '12345678';
        account.RecordTypeId = XappiaHelper.getRecordType('Account', 'Paciente Regular').Id;

        Product2 producto = Build.aProduct2().build();
        producto.Producto_SAP__c = true;
        producto.Es_de_Kit_de_Inicio__c = true;
        producto.Unidades_de_Kit__c = 2;
        producto.Area_Terapeutica__c = 'Dieta Cetogénica';
        producto.Organizacion__c = 'AMN';
        insert producto;

        Id idAccount = FormularioRegistroController.saveAccount(account, producto.Id, 'SNE');

        Account centroTratamiento = Build.anAccountInstitucion()
            .withName('Centro')
            .build();
        insert centroTratamiento;

        Account os = Build.anAccountObrasocial()
            .withName('Obra Social')
            .build();
        insert os;

        Account profesional = Build.anAccountProfesionaldelasalud()
            .withLastName('Apellido')
            .build();
        insert profesional;

        Tratamiento__c tratamiento = new Tratamiento__c();
        tratamiento.RecordTypeId = XappiaHelper.getRecordType('Tratamiento__c', 'Tratamiento Regular').Id;
        tratamiento.Diagnostico__c = 'No';
        tratamiento.Alimentacion__c = 'SNO';
        tratamiento.Centro_de_tratamiento__c = centroTratamiento.Id;
        tratamiento.Obra_social__c = os.Id;

        Tratamiento_de_profesional__c tratProfe = new Tratamiento_de_profesional__c();
        tratProfe.Profesional__c = profesional.Id;

        Producto_de_paciente__c productoPaciente = new Producto_de_paciente__c();
        productoPaciente.Producto_Portal_Pacientes__c = producto.Id;

        Test.startTest();
            FormularioRegistroController.failedTest = true;
            Id idAccountTratamiento = FormularioRegistroController.saveObjetosTratamiento(tratamiento, productoPaciente, tratProfe, idAccount);
        Test.stopTest();

        List<Log_Form__c> logsForm = [
            SELECT  Error__c, Objeto_Fallido__c, Datos_de_Paciente__c, Registro__c
            FROM    Log_Form__c
        ];

        System.assertEquals(2, logsForm.size(),
            'No se encontraron los registro de log form al ingresar un tratamiento y un producto de paciente erroneo');
    }

    @IsTest
    static void testSiUnUsuarioNavegaLosFormsSeDebenGenerarLosTracksCorrespondientes(){
        Track_Solicitud_Kit_de_Inicio__c track = new Track_Solicitud_Kit_de_Inicio__c();
        track.Datos_Paciente__c = 'Tes, Test - 12345678';

        Test.startTest();
            FormularioRegistroController.generateTrackForm(track);
        Test.stopTest();

        List<Track_Solicitud_Kit_de_Inicio__c> tracksForm = [
            SELECT  Datos_Paciente__c
            FROM    Track_Solicitud_Kit_de_Inicio__c
        ];

        System.assertEquals(1, tracksForm.size(),
            'No se encontraron los registros track del form');
    }

    @IsTest
    static void testSiExistePaciente() {
        Account paciente = Build.anAccountCuentacommunity()
            .withFirstName('Nombre')
            .withLastName('Apellido')
            .withEmail('nombreapellido@testdanone.com')
            .withTelefono('12345678')
            .build();
        paciente.DNI__c = '12345678';
        paciente.RecordTypeId = XappiaHelper.getRecordType('Account', 'Paciente Regular').Id;
        insert paciente;

        Test.startTest();
            Boolean isPaciente = FormularioRegistroController.isPaciente(paciente.DNI__c);
        Test.stopTest();

        System.assertEquals(True, isPaciente,
            'No se encontró un paciente con el DNI insertado anteriormente');
    }

    @IsTest
    static void testSiExisteProductosDeUnAreaTerapeuticaSeDebenDevolverCorrectamente() {
        String ta = 'Dieta Cetogénica';

        Product2 producto = Build.aProduct2().build();
        producto.Producto_SAP__c = true;
        producto.Es_de_Kit_de_Inicio__c = true;
        producto.Unidades_de_Kit__c = 2;
        producto.Area_Terapeutica__c = ta;
        producto.Organizacion__c = 'AMN';
        insert producto;

        Test.startTest();
            List<Product2> productos = FormularioRegistroController.getProductos(ta);
        Test.stopTest();

        System.assert(!productos.isEmpty(), 'No se econtraron productos para el área terapéutica');
    }
}