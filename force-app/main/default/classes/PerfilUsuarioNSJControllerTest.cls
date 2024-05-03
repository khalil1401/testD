@isTest
public with sharing class PerfilUsuarioNSJControllerTest {
    @testSetup
    private static void testSetup() {
        Municipio__c municipio = new Municipio__c(
            Name = 'Municipio Test',
            Descripcion_Provincia__c = 'BUENOS AIRES'
        );
        insert municipio;

        Localidad__c localidad = new Localidad__c(
            Name = 'Localidad Test',
            Municipio__c = municipio.Id
        );
        insert localidad;

        Account pacienteRegular = Build.anAccount()
         .withLastName('test')
         .withDNI('1232123')
         .withEmail('test@test.com')
         .withPhone('222222222')
         .withDireccion('Test 1111')
         .build();
         pacienteRegular.Tipo_de_telefono__c = 'Celular';
         pacienteRegular.Sexo__c = 'Masculino';
         pacienteRegular.Localidad_look__c = localidad.Id;
         pacienteRegular.Codigo_postal__c = '7777';
         pacienteRegular.RecordTypeId = XappiaHelper.getRecordType('Account', 'Paciente Regular').Id;
        insert pacienteRegular;

        Product2 product = Build.aProduct2()
        .withProductoPara('Best Care')
        .withName('TestProduct')
        .withDescription('Producto')
        .withhProductoSAP(true)
        .build();
        product.ProductCode = '11593222';

        insert product;

        Envio_sin_Cargo__c envioSinCargo = Build.aEnvioSinCargo()
            .withPaciente(pacienteRegular)
            .Build();
        insert envioSinCargo;
        
        Producto_de_envio__c newProductoDeModulo =
        new Producto_de_envio__c(Formula__c = product.Id, Cantidad__c = '1', Envio_Sin_Cargo__c = envioSinCargo.Id);
        insert newProductoDeModulo;

        Account pacienteRegular2 = Build.anAccount()
         .withLastName('test2')
         .withDNI('12324533')
         .withEmail('test@test.com')
         .withPhone('33333333')
         .withDireccion('Test 2222')
         .build();
         pacienteRegular2.Tipo_de_telefono__c = 'Celular';
         pacienteRegular2.Sexo__c = 'Masculino';
         pacienteRegular2.Localidad_look__c = localidad.Id;
         pacienteRegular2.Codigo_postal__c = '7777';
         pacienteRegular2.RecordTypeId = XappiaHelper.getRecordType('Account', 'Paciente Regular').Id;
        insert pacienteRegular2;

        Contact record = new Contact();
        record.FirstName = 'test';
        record.LastName = 'test';
        record.Email = 'test2.doe@example.com';
        record.Paciente__c = pacienteRegular2.Id;
        record.Relacion__c = 'Madre';
        record.Tipo_de_Telefono_de_Contacto__c = 'Casa';
        record.Phone = '44444444';
        record.Principal__c = true;
        insert record;

        Contact record2 = new Contact();
        record2.FirstName = 'John2';
        record2.LastName = 'Doe2';
        record2.Email = 'john2.doe2@example.com';
        record2.Paciente__c = pacienteRegular2.Id;
        record2.Relacion__c = 'Madre';
        record2.Tipo_de_Telefono_de_Contacto__c = 'Celular';
        record2.Phone = '4234235';
        record2.Principal__c = false;
        insert record2;

        NIC_Envio__c envio = new NIC_Envio__c();
        envio.Cuenta__c = pacienteRegular.Id;
        envio.Fecha_Ingreso__c = '11/11/2021 17:04';
        envio.Fecha_Despacho__c = '11/11/2021 14:04';
        envio.Id_de_cuenta_SAP__c = pacienteRegular.Id + ' Name Test acc';
        envio.NIC__c = '751622656';
        insert envio;

        Account os = Build.anAccountObrasocial()
            .withName('Obra Social')
            .build();
        insert os;

        Tratamiento__c tratamiento = new Tratamiento__c();
        tratamiento.Cuenta__c = pacienteRegular.Id;
        tratamiento.Obra_social__c = os.Id;
        tratamiento.RecordTypeId = XappiaHelper.getRecordType('Tratamiento__c', 'Tratamiento Regular').Id;
        insert tratamiento;

        Account profesional = Build.anAccountProfesionaldelasalud()
            .withLastName('Apellido')
            .build();
        insert profesional;

        Tratamiento_de_profesional__c tratamientoDeProf = new Tratamiento_de_profesional__c();
        tratamientoDeProf.Tratamiento__c = tratamiento.Id;
        tratamientoDeProf.Profesional__c = profesional.Id;
        insert tratamientoDeProf;
    }
    
    @isTest
    private static void mustGetUser() {
        // Test data setup
        Id userId = UserInfo.getUserId();
        // Actual test
        Test.startTest();
          User userTest = PerfilUsuarioNSJController.getUserId();
        Test.stopTest();

        User currentUser = [
            SELECT Id
            FROM User
            WHERE Id = :userId
        ];
    
        // Asserts
        System.assertEquals(currentUser.Id, userTest.Id, 'Error to get user');        
    }

    @isTest
    private static void mustGetOneAddress() {       
         // Test data setup
         Account pacienteRegular = [
            SELECT  Direccion__c, Referencia__c, Localidad_look__c, Localidad_look__r.Name, Codigo_postal__c, Localidad_look__r.Municipio__r.Name, Localidad_look__r.Municipio__r.Descripcion_Provincia__c,
                Direccion_Secundaria__c, Referencia_Secundaria__c, Codigo_Postal_Secundario__c, Localidad_Secundaria__c, Localidad_Secundaria__r.Name, Localidad_Secundaria__r.Municipio__r.Name, Localidad_Secundaria__r.Municipio__r.Descripcion_Provincia__c
            FROM    Account 
            WHERE   Phone = '222222222'
        ];
        // Actual test
        Test.startTest();
        List<PerfilUsuarioNSJController.DireccionWrapper> pacienteRegularToCompare = PerfilUsuarioNSJController.getDirecciones(pacienteRegular.Id);
        Test.stopTest();
            
        // Asserts
        System.assertEquals(1, pacienteRegularToCompare.size(), 'Error to get Address');
        System.assertEquals(pacienteRegular.Direccion__c, pacienteRegularToCompare[0].direccion, 'Error to get Address');
        System.assertEquals('primer-contacto', pacienteRegularToCompare[0].id, 'Error to get Address');
        System.assertEquals(true, pacienteRegularToCompare[0].principal, 'Error to get Address');
        System.assertEquals(pacienteRegular.Localidad_look__c, pacienteRegularToCompare[0].localidadId, 'Error to get Address');
    }
    @isTest
    private static void mustGetTwoAddress() {       
         // Test data setup
         Account pacienteRegular = [
            SELECT  Direccion__c, Referencia__c, Localidad_look__c, Localidad_look__r.Name, Codigo_postal__c, Localidad_look__r.Municipio__r.Name, Localidad_look__r.Municipio__r.Descripcion_Provincia__c,
                Direccion_Secundaria__c, Referencia_Secundaria__c, Codigo_Postal_Secundario__c, Localidad_Secundaria__c, Localidad_Secundaria__r.Name, Localidad_Secundaria__r.Municipio__r.Name, Localidad_Secundaria__r.Municipio__r.Descripcion_Provincia__c
            FROM    Account 
            WHERE   Phone = '222222222'
        ];
        Municipio__c municipioTwo = new Municipio__c(
            Name = 'Municipio Test2',
            Descripcion_Provincia__c = 'BUENOS AIRES'
        );
        insert municipioTwo;

        Localidad__c localidadTwo = new Localidad__c(
            Name = 'Localidad Test2',
            Municipio__c = municipioTwo.Id
        );
        insert localidadTwo;

        pacienteRegular.Direccion_Secundaria__c = 'Test 2222';
        pacienteRegular.Codigo_Postal_Secundario__c = '8888';
        pacienteRegular.Localidad_Secundaria__c = localidadTwo.Id;

        update pacienteRegular;

        // Actual test
        Test.startTest();
        List<PerfilUsuarioNSJController.DireccionWrapper> pacienteRegularToCompare = PerfilUsuarioNSJController.getDirecciones(pacienteRegular.Id);
        Test.stopTest();
       
        // Asserts
        // Direccion principal
        System.assertEquals(pacienteRegular.Direccion__c, pacienteRegularToCompare[0].direccion, 'Error to get Address');
        System.assertEquals('primer-contacto', pacienteRegularToCompare[0].id, 'Error to get Address');
        System.assertEquals(true, pacienteRegularToCompare[0].principal, 'Error to get Address');
        System.assertEquals(pacienteRegular.Localidad_look__c, pacienteRegularToCompare[0].localidadId, 'Error to get Address');
        // Direccion secundaria
        System.assertEquals(2, pacienteRegularToCompare.size(), 'Error to get Address');
        System.assertEquals(pacienteRegular.Direccion_Secundaria__c, pacienteRegularToCompare[1].direccion, 'Error to get Address');
        System.assertEquals('segundo-contacto', pacienteRegularToCompare[1].id, 'Error to get Address');
        System.assertEquals(false, pacienteRegularToCompare[1].principal, 'Error to get Address');
        System.assertEquals(pacienteRegular.Localidad_Secundaria__c, pacienteRegularToCompare[1].localidadId, 'Error to get Address');
    }
    @isTest
    private static void mustDeleteAddressSecondary() {       
         // Test data setup
         Account pacienteRegular = [
            SELECT  Direccion__c, Referencia__c, Localidad_look__c, Localidad_look__r.Name, Codigo_postal__c, Localidad_look__r.Municipio__r.Name, Localidad_look__r.Municipio__r.Descripcion_Provincia__c,
                Direccion_Secundaria__c, Referencia_Secundaria__c, Codigo_Postal_Secundario__c, Localidad_Secundaria__c, Localidad_Secundaria__r.Name, Localidad_Secundaria__r.Municipio__r.Name, Localidad_Secundaria__r.Municipio__r.Descripcion_Provincia__c
            FROM    Account 
            WHERE   Phone = '222222222'
        ];
        Municipio__c municipioTwo = new Municipio__c(
            Name = 'Municipio Test2',
            Descripcion_Provincia__c = 'BUENOS AIRES'
        );
        insert municipioTwo;

        Localidad__c localidadTwo = new Localidad__c(
            Name = 'Localidad Test2',
            Municipio__c = municipioTwo.Id
        );
        insert localidadTwo;

        pacienteRegular.Direccion_Secundaria__c = 'Test 2222';
        pacienteRegular.Codigo_Postal_Secundario__c = '8888';
        pacienteRegular.Localidad_Secundaria__c = localidadTwo.Id;

        update pacienteRegular;

        System.assertEquals('Test 2222', pacienteRegular.Direccion_Secundaria__c, 'Error to delete Address');        
        System.assertEquals(localidadTwo.Id, pacienteRegular.Localidad_Secundaria__c, 'Error to delete Address');
        System.assertEquals('8888', pacienteRegular.Codigo_Postal_Secundario__c, 'Error to delete Address');

        // Actual test
        Test.startTest();
         PerfilUsuarioNSJController.deleteDireccion(pacienteRegular.Id, '');
        Test.stopTest();
        Account pacienteRegularToCompare  = [
            SELECT  Direccion__c, Referencia__c, Localidad_look__c, Localidad_look__r.Name, Codigo_postal__c, Localidad_look__r.Municipio__r.Name, Localidad_look__r.Municipio__r.Descripcion_Provincia__c,
                Direccion_Secundaria__c, Referencia_Secundaria__c, Codigo_Postal_Secundario__c, Localidad_Secundaria__c, Localidad_Secundaria__r.Name, Localidad_Secundaria__r.Municipio__r.Name, Localidad_Secundaria__r.Municipio__r.Descripcion_Provincia__c
            FROM    Account 
            WHERE   Phone = '222222222'
        ];
        
        // Asserts        
        System.assertEquals(null, pacienteRegularToCompare.Direccion_Secundaria__c, 'Error to delete Address');        
        System.assertEquals(null, pacienteRegularToCompare.Localidad_Secundaria__c, 'Error to delete Address');
        System.assertEquals(null, pacienteRegularToCompare.Codigo_Postal_Secundario__c, 'Error to delete Address');
    }
    @isTest
    private static void mustUpdateAddressPrincipal() {       
         // Test data setup
         Account pacienteRegular = [
            SELECT  Direccion__c, Referencia__c, Localidad_look__c, Localidad_look__r.Name, Codigo_postal__c, Localidad_look__r.Municipio__r.Name, Localidad_look__r.Municipio__r.Descripcion_Provincia__c,
                Direccion_Secundaria__c, Referencia_Secundaria__c, Codigo_Postal_Secundario__c, Localidad_Secundaria__c, Localidad_Secundaria__r.Name, Localidad_Secundaria__r.Municipio__r.Name, Localidad_Secundaria__r.Municipio__r.Descripcion_Provincia__c
            FROM    Account 
            WHERE   Phone = '222222222'
        ];
        Municipio__c municipioTwo = new Municipio__c(
            Name = 'Municipio Test2',
            Descripcion_Provincia__c = 'BUENOS AIRES'
        );
        insert municipioTwo;

        Localidad__c localidadTwo = new Localidad__c(
            Name = 'Localidad Test2',
            Municipio__c = municipioTwo.Id
        );
        insert localidadTwo;

        String direccion = 'Test 2222';
        String cp = '8888';
        String localidad = localidadTwo.Id;
        String idAccount = 'primer-contacto';        

        // Actual test
        Test.startTest();
         PerfilUsuarioNSJController.upsertDireccion(idAccount, false, direccion, cp, localidad, '', pacienteRegular.Id);
        Test.stopTest();

        Account pacienteRegularToCompare  = [
            SELECT  Direccion__c, Referencia__c, Localidad_look__c, Localidad_look__r.Name, Codigo_postal__c, Localidad_look__r.Municipio__r.Name, Localidad_look__r.Municipio__r.Descripcion_Provincia__c,
                Direccion_Secundaria__c, Referencia_Secundaria__c, Codigo_Postal_Secundario__c, Localidad_Secundaria__c, Localidad_Secundaria__r.Name, Localidad_Secundaria__r.Municipio__r.Name, Localidad_Secundaria__r.Municipio__r.Descripcion_Provincia__c
            FROM    Account 
            WHERE   Phone = '222222222'
        ];
        
        // Asserts        
        System.assertEquals('TEST 2222', pacienteRegularToCompare.Direccion__c, 'Error to update Address');        
        System.assertEquals(localidad, pacienteRegularToCompare.Localidad_look__c, 'Error to update Address');
        System.assertEquals('8888', pacienteRegularToCompare.Codigo_postal__c, 'Error to update Address');
    }
    
    @isTest
    private static void mustUpdateAddressSecondaryEqualToPrincipal() {       
         // Test data setup
         Account pacienteRegular = [
            SELECT  Direccion__c, Referencia__c, Localidad_look__c, Localidad_look__r.Name, Codigo_postal__c, Localidad_look__r.Municipio__r.Name, Localidad_look__r.Municipio__r.Descripcion_Provincia__c,
                Direccion_Secundaria__c, Referencia_Secundaria__c, Codigo_Postal_Secundario__c, Localidad_Secundaria__c, Localidad_Secundaria__r.Name, Localidad_Secundaria__r.Municipio__r.Name, Localidad_Secundaria__r.Municipio__r.Descripcion_Provincia__c
            FROM    Account 
            WHERE   Phone = '222222222'
        ];
        Municipio__c municipioTwo = new Municipio__c(
            Name = 'Municipio Test2',
            Descripcion_Provincia__c = 'BUENOS AIRES'
        );
        insert municipioTwo;

        Localidad__c localidadTwo = new Localidad__c(
            Name = 'Localidad Test2',
            Municipio__c = municipioTwo.Id
        );
        insert localidadTwo;

        String direccion = 'Test 2222';
        String cp = '8888';
        String localidad = localidadTwo.Id;
        //String idAccount = 'primer-contacto';        

        // Actual test
        Test.startTest();
         PerfilUsuarioNSJController.upsertDireccion('', true, direccion, cp, localidad, '', pacienteRegular.Id);
        Test.stopTest();

        Account pacienteRegularToCompare  = [
            SELECT  Direccion__c, Referencia__c, Localidad_look__c, Localidad_look__r.Name, Codigo_postal__c, Localidad_look__r.Municipio__r.Name, Localidad_look__r.Municipio__r.Descripcion_Provincia__c,
                Direccion_Secundaria__c, Referencia_Secundaria__c, Codigo_Postal_Secundario__c, Localidad_Secundaria__c, Localidad_Secundaria__r.Name, Localidad_Secundaria__r.Municipio__r.Name, Localidad_Secundaria__r.Municipio__r.Descripcion_Provincia__c
            FROM    Account 
            WHERE   Phone = '222222222'
        ];
        
        // Asserts        
        System.assertEquals(pacienteRegular.Direccion__c, pacienteRegularToCompare.Direccion_Secundaria__c, 'Error to update Address');        
        System.assertEquals(pacienteRegular.Localidad_look__c, pacienteRegularToCompare.Localidad_Secundaria__c, 'Error to update Address');
        System.assertEquals(pacienteRegular.Codigo_postal__c, pacienteRegularToCompare.Codigo_Postal_Secundario__c, 'Error to update Address');
    }
    @isTest
    private static void mustUpdateAddressSecondary() {       
         // Test data setup
         Account pacienteRegular = [
            SELECT  Direccion__c, Referencia__c, Localidad_look__c, Localidad_look__r.Name, Codigo_postal__c, Localidad_look__r.Municipio__r.Name, Localidad_look__r.Municipio__r.Descripcion_Provincia__c,
                Direccion_Secundaria__c, Referencia_Secundaria__c, Codigo_Postal_Secundario__c, Localidad_Secundaria__c, Localidad_Secundaria__r.Name, Localidad_Secundaria__r.Municipio__r.Name, Localidad_Secundaria__r.Municipio__r.Descripcion_Provincia__c
            FROM    Account 
            WHERE   Phone = '222222222'
        ];
        Municipio__c municipioTwo = new Municipio__c(
            Name = 'Municipio Test2',
            Descripcion_Provincia__c = 'BUENOS AIRES'
        );
        insert municipioTwo;

        Localidad__c localidadTwo = new Localidad__c(
            Name = 'Localidad Test2',
            Municipio__c = municipioTwo.Id
        );
        insert localidadTwo;

        String direccion = 'Test 2222';
        String cp = '8888';
        String localidad = localidadTwo.Id;
        //String idAccount = 'primer-contacto';        

        // Actual test
        Test.startTest();
         PerfilUsuarioNSJController.upsertDireccion('', false, direccion, cp, localidad, '', pacienteRegular.Id);
        Test.stopTest();

        Account pacienteRegularToCompare  = [
            SELECT  Direccion__c, Referencia__c, Localidad_look__c, Localidad_look__r.Name, Codigo_postal__c, Localidad_look__r.Municipio__r.Name, Localidad_look__r.Municipio__r.Descripcion_Provincia__c,
                Direccion_Secundaria__c, Referencia_Secundaria__c, Codigo_Postal_Secundario__c, Localidad_Secundaria__c, Localidad_Secundaria__r.Name, Localidad_Secundaria__r.Municipio__r.Name, Localidad_Secundaria__r.Municipio__r.Descripcion_Provincia__c
            FROM    Account 
            WHERE   Phone = '222222222'
        ];
        
        // Asserts        
        System.assertEquals('Test 2222', pacienteRegularToCompare.Direccion_Secundaria__c, 'Error to update Address');        
        System.assertEquals(localidad, pacienteRegularToCompare.Localidad_Secundaria__c, 'Error to update Address');
        System.assertEquals('8888', pacienteRegularToCompare.Codigo_Postal_Secundario__c, 'Error to update Address');
    }

    @isTest
    private static void mustGetDatosPersonales() {       
         // Test data setup
         Account pacienteRegular = [
            SELECT  Id, Sexo__c, PersonEmail, Direccion__c, Tipo_de_telefono__c, Phone
            FROM    Account 
            WHERE   Phone = '222222222'
        ];
        // Actual test
        Test.startTest();
           Account pacienteRegularToCompare = PerfilUsuarioNSJController.getDatosPersonales(pacienteRegular.Id);
        Test.stopTest();
    
        // Asserts
        System.assertEquals(pacienteRegular.Phone, pacienteRegularToCompare.Phone, 'Error to get person data');
    }
    @isTest
    private static void mustSaveAccountWithEmail() {       
         // Test data setup
         Account pacienteRegular = [
            SELECT  Id, Sexo__c, PersonEmail, Direccion__c, Tipo_de_telefono__c, Phone,
            Referencia__c, Localidad_look__c, Localidad_look__r.Name, Codigo_postal__c, 
            Localidad_look__r.Municipio__r.Name, Localidad_look__r.Municipio__r.Descripcion_Provincia__c
            FROM    Account 
            WHERE   Phone = '222222222'
        ];
        pacienteRegular.PersonEmail = 'saveaccount@save.com';        

        String accountJSON = JSON.serialize(pacienteRegular);
        // Actual test
        Test.startTest();
           PerfilUsuarioNSJController.saveAccount(accountJSON);
        Test.stopTest();
        
        Account pacienteRegularToCompare = [
            SELECT  Id, Sexo__c, PersonEmail, Direccion__c, Tipo_de_telefono__c, Phone,
            Referencia__c, Localidad_look__c, Localidad_look__r.Name, Codigo_postal__c, 
            Localidad_look__r.Municipio__r.Name, Localidad_look__r.Municipio__r.Descripcion_Provincia__c
            FROM    Account 
            WHERE   PersonEmail = 'saveaccount@save.com'
        ];

        // Asserts
        System.assertEquals('saveaccount@save.com', pacienteRegularToCompare.PersonEmail, 'Error to save account');
    }
    @isTest
    private static void mustSaveAccountWithOutEmail() {       
         // Test data setup
         Account pacienteRegular = [
            SELECT  Id, Sexo__c, PersonEmail, Direccion__c, Tipo_de_telefono__c, Phone,
            Referencia__c, Localidad_look__c, Localidad_look__r.Name, Codigo_postal__c, 
            Localidad_look__r.Municipio__r.Name, Localidad_look__r.Municipio__r.Descripcion_Provincia__c
            FROM    Account 
            WHERE   Phone = '222222222'
        ];
        pacienteRegular.PersonEmail = null;        
        pacienteRegular.Phone = '333333333';        

        String accountJSON = JSON.serialize(pacienteRegular);
        // Actual test
        Test.startTest();
           PerfilUsuarioNSJController.saveAccount(accountJSON);
        Test.stopTest();
        
        Account pacienteRegularToCompare = [
            SELECT  Id, Sexo__c, PersonEmail, Direccion__c, Tipo_de_telefono__c, Phone,
            Referencia__c, Localidad_look__c, Localidad_look__r.Name, Codigo_postal__c, 
            Localidad_look__r.Municipio__r.Name, Localidad_look__r.Municipio__r.Descripcion_Provincia__c
            FROM    Account 
            WHERE   Phone = '333333333'
        ];

        // Asserts
        System.assertEquals('333333333', pacienteRegularToCompare.Phone, 'Error to save account');
    }

    @isTest
    private static void mustGetLocalidad() {       
         // Test data setup
        Localidad__c localidad = [
            SELECT  Id, Name, Municipio__c, Municipio__r.Name, Municipio__r.Descripcion_Provincia__c
            FROM Localidad__c
            WHERE  Name = 'Localidad Test'
        ];
        // Actual test
        Test.startTest();
        Localidad__c localidadToCompare = PerfilUsuarioNSJController.getLocalidad(localidad.Id);
        Test.stopTest();
    
        // Asserts
        System.assertEquals(localidad.Municipio__c, localidadToCompare.Municipio__c, 'Error to get locale');
    }

    @isTest
    private static void mustGetPicklistValuesForFieldSexo() {
        // Test data setup
        String objectPicklist = 'Account';
        String fieldPicklist = 'Sexo__c';
        // Actual test
        Test.startTest();
          List<String> pickListValues =  PerfilUsuarioNSJController.getPicklistValues(objectPicklist, fieldPicklist, 'Alergia');
        Test.stopTest();
            System.debug(pickListValues);
        // Asserts
        System.assertNotEquals(0, pickListValues.size(), 'Error to get picklist values');
        System.assertEquals('Masculino', pickListValues[0], 'Error to get picklist values');
        System.assertEquals('Femenino', pickListValues[1], 'Error to get picklist values');
    }

    @isTest
    private static void mustGetEnvio() {
        // Test data setup
        Account pacienteRegular = [
            SELECT  Id, Sexo__c, PersonEmail, Direccion__c, Tipo_de_telefono__c, Phone,
            Referencia__c, Localidad_look__c, Localidad_look__r.Name, Codigo_postal__c, 
            Localidad_look__r.Municipio__r.Name, Localidad_look__r.Municipio__r.Descripcion_Provincia__c
            FROM    Account 
            WHERE   Phone = '222222222'
        ];
        // Actual test
        Test.startTest();
        NIC_Envio__c envio = PerfilUsuarioNSJController.getEnvio(pacienteRegular.Id);
        Test.stopTest();        

        NIC_Envio__c envioToCompare = [
            SELECT  Link_Seguimiento_completo__c, Cuenta__c, Cuenta__r.Name, Direccion_de_Envio__c, Localidad_de_Envio__c, NIC__c
            FROM    NIC_Envio__c
            WHERE   Cuenta__c =: pacienteRegular.Id
        ];
        // Asserts
        System.assertEquals(envioToCompare.NIC__c, envio.NIC__c, 'Error to get envio');
        System.assertEquals(pacienteRegular.Id, envio.Cuenta__c, 'Error to get envio');
    }

    @isTest
    public static void testInsertContact() {
        
        Account pacienteRegular = [
            SELECT  Id, Sexo__c, PersonEmail, Direccion__c, Tipo_de_telefono__c, Phone,
            Referencia__c, Localidad_look__c, Localidad_look__r.Name, Codigo_postal__c, 
            Localidad_look__r.Municipio__r.Name, Localidad_look__r.Municipio__r.Descripcion_Provincia__c
            FROM    Account 
            WHERE   Phone = '222222222'
        ];
        Contact record = new Contact();
        record.FirstName = 'John';
        record.LastName = 'Doe';
        record.Email = 'john.doe@example.com';
        record.Paciente__c = pacienteRegular.Id;
        record.Relacion__c = 'Madre';
        record.Tipo_de_Telefono_de_Contacto__c = 'Casa';
        record.Phone = '12332556';        

        String jsonContact = JSON.serialize(record);
        Test.startTest();
        PerfilUsuarioNSJController.insertContact(jsonContact);
        Test.stopTest();

        Account pacienteToCompare = [
            SELECT  Id, Nombre_de_Contacto_3__c, V_nculo_3__c, Tipo_de_Telefono_3__c, Tel_fono_3__c, Correo_electronico_de_Contacto_3__c            
            FROM    Account 
            WHERE   Phone = '222222222'
        ];

        System.assertEquals('John' + ' ' + 'Doe', pacienteToCompare.Nombre_de_Contacto_3__c, 'Error al crear nombre de contacto');
        System.assertEquals(record.Relacion__C, pacienteToCompare.V_nculo_3__c, 'Error al crear Vinculo de contacto');
        System.assertEquals(record.Phone, pacienteToCompare.Tel_fono_3__c, 'Error al crear telefono de contacto');
        System.assertEquals(record.Tipo_de_Telefono_de_Contacto__c, pacienteToCompare.Tipo_de_Telefono_3__c, 'Error al crear telefono de contacto');
        System.assertEquals(record.Email, pacienteToCompare.Correo_electronico_de_Contacto_3__c, 'Error al crear Email de contacto');
    }

    @isTest
    private static void testGetPacienteBestCare() {
        // Test data setup
        Account pacienteAccount = [
            SELECT  Id, Sexo__c, PersonEmail, Direccion__c, Tipo_de_telefono__c, Phone,
            Referencia__c, Localidad_look__c, Localidad_look__r.Name, Codigo_postal__c, 
            Localidad_look__r.Municipio__r.Name, Localidad_look__r.Municipio__r.Descripcion_Provincia__c
            FROM    Account 
            WHERE   Phone = '222222222'
        ];

        pacienteAccount.RecordTypeId = XappiaHelper.getRecordType('Account', 'Paciente Best Care').Id;

        update pacienteAccount;

        Modulo_de_paciente__c moduloPaciente = Build.aModulodepaciente()
         .withCuenta(pacienteAccount)
         .withModulodesde(Date.today())
         .withModulohasta(Date.today().addDays(2))
         .Build();
        insert moduloPaciente;
        
        // Actual test
        Test.startTest();
            PerfilUsuarioNSJController.PacienteBestCareWrapper paciente = PerfilUsuarioNSJController.getDataPacienteBestCare(pacienteAccount.Id);
        Test.stopTest();
    
        // Asserts
        System.assertEquals('TestProduct', paciente.producto, 'Error al obtener producto');
        System.assertEquals('En tratamiento', paciente.estadoDePaciente, 'Error al obtener estado de paciente');
        System.assertEquals(Date.today(), paciente.moduloDesde, 'Error al obtener modulo desde');
        System.assertEquals(Date.today().addDays(2), paciente.moduloHasta, 'Error al obtener modulo hasta');
    }
    @isTest
    public static void testInsertContactPrincipal() {
        
        Account pacienteRegular = [
            SELECT  Id, Sexo__c, PersonEmail, Direccion__c, Tipo_de_telefono__c, Phone,
            Referencia__c, Localidad_look__c, Localidad_look__r.Name, Codigo_postal__c, 
            Localidad_look__r.Municipio__r.Name, Localidad_look__r.Municipio__r.Descripcion_Provincia__c
            FROM    Account 
            WHERE   Phone = '222222222'
        ];
        Contact record = new Contact();
        record.FirstName = 'John';
        record.LastName = 'Doe';
        record.Email = 'john.doe@example.com';
        record.Paciente__c = pacienteRegular.Id;
        record.Relacion__c = 'Madre';
        record.Tipo_de_Telefono_de_Contacto__c = 'Casa';
        record.Phone = '12332556';
        record.Principal__c = true;
        
        String jsonContact = JSON.serialize(record);
        Test.startTest();
        PerfilUsuarioNSJController.insertContact(jsonContact);
        Test.stopTest();
        Account pacienteToCompare = [
            SELECT  Id, Nombre_de_Contacto__c, V_nculo__c, Tipo_de_telefono_2__c, Tel_fono_2__c, Correo_electronico_de_Contacto__c            
            FROM    Account 
            WHERE   Phone = '222222222'
        ];

        System.assertEquals('John' + ' ' + 'Doe', pacienteToCompare.Nombre_de_Contacto__c, 'Error al crear nombre de contacto');
        System.assertEquals(record.Relacion__C, pacienteToCompare.V_nculo__c, 'Error al crear Vinculo de contacto');
        System.assertEquals(record.Phone, pacienteToCompare.Tel_fono_2__c, 'Error al crear telefono de contacto');
        System.assertEquals(record.Tipo_de_Telefono_de_Contacto__c, pacienteToCompare.Tipo_de_telefono_2__c, 'Error al crear tipo de telefono de contacto');
        System.assertEquals(record.Email, pacienteToCompare.Correo_electronico_de_Contacto__c, 'Error al crear Email de contacto');
        
    }
    
    @isTest
    public static void testUpdateContactPrincipal() {
        Contact aContact = [
            SELECT id, Relacion__c, Phone, Tipo_de_Telefono_de_Contacto__c, Email
            FROM Contact
            WHERE Phone = '44444444' and Principal__c = true
        ];
        Contact record = new Contact();
        record.Id = aContact.Id; 
        record.FirstName = 'Updated';
        record.Phone = '4344354';
        record.Email = 'test@test.com';
        
        String jsonContact = JSON.serialize(record);
        Test.startTest();
        PerfilUsuarioNSJController.updateContact(jsonContact);
        Test.stopTest();

        Account pacienteToCompare = [
            SELECT  Id, Nombre_de_Contacto__c, V_nculo__c, Tipo_de_telefono_2__c, Tel_fono_2__c, Correo_electronico_de_Contacto__c            
            FROM    Account 
            WHERE   Phone = '33333333'
        ];

        System.assertEquals('Updated' + ' ' + 'test', pacienteToCompare.Nombre_de_Contacto__c, 'Error al crear nombre de contacto');
        System.assertEquals(aContact.Relacion__C, pacienteToCompare.V_nculo__c, 'Error al crear Vinculo de contacto');
        System.assertEquals('4344354', pacienteToCompare.Tel_fono_2__c, 'Error al crear telefono de contacto');
        System.assertEquals(aContact.Tipo_de_Telefono_de_Contacto__c, pacienteToCompare.Tipo_de_telefono_2__c, 'Error al crear tipo de telefono de contacto');
        System.assertEquals('test@test.com', pacienteToCompare.Correo_electronico_de_Contacto__c, 'Error al crear Email de contacto');
    }
    @isTest
    public static void testUpdateContact() {
        Contact aContact = [
            SELECT id, Relacion__c, Phone, Tipo_de_Telefono_de_Contacto__c, Email
            FROM Contact
            WHERE Phone = '4234235' 
        ];
        Contact record = new Contact();
        record.Id = aContact.Id;
        record.FirstName = 'Updated';
        record.MobilePhone = '4344354';
        record.Email = 'test@test.com';
        
        String jsonContact = JSON.serialize(record);
        Test.startTest();
        PerfilUsuarioNSJController.updateContact(jsonContact);
        Test.stopTest();

        Account pacienteToCompare = [
            SELECT  Id, Nombre_de_Contacto_3__c, V_nculo_3__c, Tipo_de_Telefono_3__c, Tel_fono_3__c, Correo_electronico_de_Contacto_3__c
            FROM    Account 
            WHERE   Phone = '33333333'
        ];

        System.assertEquals('Updated' + ' ' + 'Doe2', pacienteToCompare.Nombre_de_Contacto_3__c, 'Error al crear nombre de contacto');
        System.assertEquals(aContact.Relacion__C, pacienteToCompare.V_nculo_3__c, 'Error al crear Vinculo de contacto');
        System.assertEquals('4344354', pacienteToCompare.Tel_fono_3__c, 'Error al crear telefono de contacto');
        System.assertEquals(aContact.Tipo_de_Telefono_de_Contacto__c, pacienteToCompare.Tipo_de_Telefono_3__c, 'Error al crear telefono de contacto');
        System.assertEquals('test@test.com', pacienteToCompare.Correo_electronico_de_Contacto_3__c, 'Error al crear Email de contacto');
    }
   
    @IsTest
    public static void testSiActualizoLaInformacionDeLaCoberturaSinRespuestaSeDebeActualizarElEstadoDePacienteYCrearLaTarea() {
        Account pacienteRegular = [
            SELECT  Id
            FROM    Account
            WHERE   DNI__c =: '1232123'
            LIMIT 1
        ];

        Date today = Date.today();
        Test.startTest();
            PerfilUsuarioNSJController.setStatusPaciente(pacienteRegular.Id, 'sinrespuesta', today, true);
        Test.stopTest();

        Account pacienteRegularDB = [
            SELECT  Id, Fecha_de_obito__c, Estado_de_paciente__c, Subestado_del_paciente__c
            FROM    Account 
            WHERE   Id =: pacienteRegular.Id
            LIMIT 1
        ];

        List<Task> tareasPSP = [
            SELECT  Type, WhatId, Subject, Description, OwnerId
            FROM    Task
        ];

        Group psp = [
            SELECT Id
            FROM Group
            WHERE Type = 'Queue'
                AND NAME = 'PSP'
            LIMIT 1
        ];

        System.assertEquals(null, pacienteRegularDB.Fecha_de_obito__c, 
            'El paciente no tiene una Fecha de Obito null');
        System.assertEquals('En Seguimiento', pacienteRegularDB.Estado_de_paciente__c, 
            'El paciente no tiene como estado En Seguimiento');
        System.assertEquals('Tramite iniciado', pacienteRegularDB.Subestado_del_paciente__c, 
            'El paciente no tiene como subestado Tratamite iniciado');
        System.assertNotEquals(0, tareasPSP.size(), 
            'No se encontró la tarea del PSP para el aviso de no cobertura');
        System.assertEquals(pacienteRegular.Id, tareasPSP.get(0).WhatId, 
            'La cuenta de la tarea no es la del paciente regular asignado');
        System.assertEquals('Aviso No Cobertura', tareasPSP.get(0).Type, 
            'El Type de la tarea no es Aviso No Cobertura');
        System.assertEquals('Cobertura Médica Sin Respuesta', tareasPSP.get(0).Subject, 
            'El Subject de la tarea no es Cobertura Médica Sin Respuesta');
        System.assertEquals(Label.Cobertura_Medica_Sin_Respuesta, tareasPSP.get(0).Description, 
            'El Description de la tarea no es la asiganada');
    }

    @IsTest
    public static void testSiActualizoLaInformacionDeLaCoberturaParcialmenteAprobadoSeDebeActualizarElEstadoDePacienteYCrearLaTarea() {
        Account pacienteRegular = [
            SELECT  Id
            FROM    Account
            WHERE   DNI__c =: '1232123'
            LIMIT 1
        ];

        Date today = Date.today();
        Test.startTest();
            PerfilUsuarioNSJController.setStatusPaciente(pacienteRegular.Id, 'parcialmenteaprobado', today, true);
        Test.stopTest();

        Account pacienteRegularDB = [
            SELECT  Id, Fecha_de_obito__c, Estado_de_paciente__c, Subestado_del_paciente__c
            FROM    Account 
            WHERE   Id =: pacienteRegular.Id
            LIMIT 1
        ];

        List<Task> tareasPSP = [
            SELECT  Type, WhatId, Subject, Description, OwnerId
            FROM    Task
        ];

        Group psp = [
            SELECT Id
            FROM Group
            WHERE Type = 'Queue'
                AND NAME = 'PSP'
            LIMIT 1
        ];

        System.assertEquals(null, pacienteRegularDB.Fecha_de_obito__c, 
            'El paciente no tiene una Fecha de Obito null');
        System.assertEquals('En tratamiento', pacienteRegularDB.Estado_de_paciente__c, 
            'El paciente no tiene como estado En tratamiento');
        System.assertEquals('Cobertura parcial con Consumo', pacienteRegularDB.Subestado_del_paciente__c, 
            'El paciente no tiene como subestado Cobertura parcial con Consumo');
        System.assertNotEquals(0, tareasPSP.size(), 
            'No se encontró la tarea del PSP para el aviso de no cobertura');
        System.assertEquals(pacienteRegular.Id, tareasPSP.get(0).WhatId, 
            'La cuenta de la tarea no es la del paciente regular asignado');
        System.assertEquals('Aviso No Cobertura', tareasPSP.get(0).Type, 
            'El Type de la tarea no es Aviso No Cobertura');
        System.assertEquals('Cobertura Médica Aprobada Parcialmente', tareasPSP.get(0).Subject, 
            'El Subject de la tarea no es Cobertura Médica Aprobada Parcialmente');
        System.assertEquals(Label.Cobertura_Medica_Aprobada_Parcialmente, tareasPSP.get(0).Description, 
            'El Description de la tarea no es la asiganada');
    }

    @IsTest
    public static void testSiActualizoLaInformacionDeLaCoberturaRechazadoSeDebeActualizarElEstadoDePacienteYCrearLaTarea() {
        Account pacienteRegular = [
            SELECT  Id
            FROM    Account
            WHERE   DNI__c =: '1232123'
            LIMIT 1
        ];

        Date today = Date.today();
        Test.startTest();
            PerfilUsuarioNSJController.setStatusPaciente(pacienteRegular.Id, 'rechazado', today, true);
        Test.stopTest();

        Account pacienteRegularDB = [
            SELECT  Id, Fecha_de_obito__c, Estado_de_paciente__c, Subestado_del_paciente__c
            FROM    Account 
            WHERE   Id =: pacienteRegular.Id
            LIMIT 1
        ];

        List<Task> tareasPSP = [
            SELECT  Type, WhatId, Subject, Description, OwnerId
            FROM    Task
        ];

        Group psp = [
            SELECT Id
            FROM Group
            WHERE Type = 'Queue'
                AND NAME = 'PSP'
            LIMIT 1
        ];

        System.assertNotEquals(null, pacienteRegularDB.Fecha_de_obito__c, 
            'El paciente no tiene una Fecha de Obito null');
        System.assertEquals('No tratamiento', pacienteRegularDB.Estado_de_paciente__c, 
            'El paciente no tiene como estado No tratamiento');
        System.assertEquals('OOSS no autoriza indicación médica', pacienteRegularDB.Subestado_del_paciente__c, 
            'El paciente no tiene como subestado OOSS no autoriza indicación médica');
        System.assertNotEquals(0, tareasPSP.size(), 
            'No se encontró la tarea del PSP para el aviso de no cobertura');
        System.assertEquals(pacienteRegular.Id, tareasPSP.get(0).WhatId, 
            'La cuenta de la tarea no es la del paciente regular asignado');
        System.assertEquals('Aviso No Cobertura', tareasPSP.get(0).Type, 
            'El Type de la tarea no es Aviso No Cobertura');
        System.assertEquals('Cobertura Médica Rechazada', tareasPSP.get(0).Subject, 
            'El Subject de la tarea no es Cobertura Médica Rechazada');
        System.assertEquals(Label.Cobertura_Medica_Rechazada, tareasPSP.get(0).Description, 
            'El Description de la tarea no es la asiganada');
    }

    @IsTest
    public static void testSiActualizoLaInformacionDeLaCoberturaSinRespuestaSeDebeActualizarElEstadoDePaciente() {
        Account pacienteRegular = [
            SELECT  Id
            FROM    Account
            WHERE   DNI__c =: '1232123'
            LIMIT 1
        ];

        Date today = Date.today();
        Test.startTest();
            PerfilUsuarioNSJController.setStatusPaciente(pacienteRegular.Id, 'sinfecha', today, true);
        Test.stopTest();

        Account pacienteRegularDB = [
            SELECT  Id, Fecha_de_obito__c, Estado_de_paciente__c, Subestado_del_paciente__c
            FROM    Account 
            WHERE   Id =: pacienteRegular.Id
            LIMIT 1
        ];

        List<Task> tareasPSP = [
            SELECT  Type, WhatId, Subject, Description, OwnerId
            FROM    Task
        ];

        Group psp = [
            SELECT Id
            FROM Group
            WHERE Type = 'Queue'
                AND NAME = 'PSP'
            LIMIT 1
        ];

        System.assertEquals(null, pacienteRegularDB.Fecha_de_obito__c, 
            'El paciente no tiene una Fecha de Obito null');
        System.assertEquals('En Seguimiento', pacienteRegularDB.Estado_de_paciente__c, 
            'El paciente no tiene como estado En Seguimiento');
        System.assertEquals('Tramite no iniciado', pacienteRegularDB.Subestado_del_paciente__c, 
            'El paciente no tiene como subestado Tramite no iniciado');
    }

    @IsTest
    private static void testSiConsultoElTratamientoDeUnaCuentaSeDebeDevolverCorrectamente() {
        // Test data setup
        Account pacienteRegular = [
            SELECT  Id
            FROM    Account 
            WHERE   DNI__c = '1232123'
        ];

        Test.startTest();
            Tratamiento__c tratamiento = PerfilUsuarioNSJController.getTratamiento(pacienteRegular.Id);
        Test.stopTest();

        Account os = [
            SELECT  Id
            FROM    Account 
            WHERE   Name = 'Obra Social'
        ];

        System.assertEquals(os.Id, tratamiento.Obra_social__c, 
            'No se encontró la obra social relacionada con el tratamiento del paciente');
    }

    @IsTest
    private static void testSiConsultoElTratamientoDelProfesionalSeDebeDevolverCorrectamente() {
        // Test data setup
        Account pacienteRegular = [
            SELECT  Id
            FROM    Account 
            WHERE   DNI__c = '1232123'
        ];

        Tratamiento__c tratamiento = [
            SELECT  Id
            FROM    Tratamiento__c 
            WHERE   Cuenta__c =: pacienteRegular.Id
        ];

        Test.startTest();
            List<PerfilUsuarioNSJController.ProfesionalWrapper> profesionales = PerfilUsuarioNSJController.getTratamientoDeProfesional(tratamiento.Id);
        Test.stopTest();

        System.assertNotEquals(0, profesionales.size(), 
            'No se encontró el profesional relacionado con el tratamiento del paciente');
    }

    @IsTest
    private static void testSiConsultoLosContactoDeUnaCuentaSeDebeDevolverCorrectamente() {
        // Test data setup
        Account pacienteRegular = [
            SELECT  Id
            FROM    Account 
            WHERE   DNI__c = '1232123'
        ];

        Contact record = new Contact();
        record.FirstName = 'test';
        record.LastName = 'test';
        record.Email = 'test@test.com';
        record.Paciente__c = pacienteRegular.Id;
        record.Relacion__c = 'Madre';
        record.Tipo_de_Telefono_de_Contacto__c = 'Casa';
        record.Phone = '4443214';
        record.Principal__c = true;
        insert record;

        Contacto_de_paciente__c cdp = new Contacto_de_paciente__c();
        cdp.Paciente__c = pacienteRegular.Id;
        cdp.Contacto__c = record.Id;
        insert cdp;

        Test.startTest();
            List<Contact> contacts = PerfilUsuarioNSJController.getContacts(pacienteRegular.Id);
        Test.stopTest();        

        System.assertNotEquals(0, contacts.size(), 
            'No se encontraron los contactos para el paciente');
        System.assertEquals(record.FirstName, contacts.get(0).FirstName, 
            'El apellido del contacto no se relaciona con el guardado');
        System.assertEquals(record.Email, contacts.get(0).Email, 
            'El email del contacto no se relaciona con el guardado');
    }

    @IsTest
    private static void testSiUnContactoSeDebeDevolverEliminarYActualizarLaCuentCorrectamente() {
        // Test data setup
        Account pacienteRegular = [
            SELECT  Id
            FROM    Account 
            WHERE   DNI__c = '1232123'
        ];

        Contact record = new Contact();
        record.FirstName = 'test';
        record.LastName = 'test';
        record.Email = 'testdelete@test.com';
        record.Paciente__c = pacienteRegular.Id;
        record.Relacion__c = 'Madre';
        record.Tipo_de_Telefono_de_Contacto__c = 'Casa';
        record.Phone = '4123214';
        record.Principal__c = true;
        insert record;

        Contacto_de_paciente__c cdp = new Contacto_de_paciente__c();
        cdp.Paciente__c = pacienteRegular.Id;
        cdp.Contacto__c = record.Id;
        insert cdp;

        Test.startTest();
            PerfilUsuarioNSJController.deleteContact(record.Id, pacienteRegular.Id);
        Test.stopTest();        

        List<Contact> contactsDB = [
            SELECT  Id
            FROM    Contact
            WHERE   Paciente__c =: pacienteRegular.Id
        ];

        List<Contacto_de_paciente__c> contactsDPDB = [
            SELECT  Id
            FROM    Contacto_de_paciente__c
            WHERE   Paciente__c =: pacienteRegular.Id
        ];

        Account pacienteRegularDB = [
            SELECT  Id
            FROM    Account 
            WHERE   Id =: pacienteRegular.Id
        ];

        System.assertEquals(0, contactsDB.size(), 
            'No se encontraron los contactos para el paciente');
        System.assertEquals(0, contactsDPDB.size(), 
            'No se encontraron los contactos para el paciente');

    }
}