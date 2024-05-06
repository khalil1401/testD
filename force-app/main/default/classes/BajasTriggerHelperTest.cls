@isTest
public class BajasTriggerHelperTest {
    @TestSetup
    static void makeData(){
        id profesionalSalud = XappiaHelper.getRecordType('Account', 'Profesional_de_la_Salud').Id;
        Profile systemAdministrator = [Select Id from Profile where Name = 'System Administrator' or name = 'Administrador del sistema' ];
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        User usuario = Build.aUser()
                .withUsername('globanttt@globant.com')           
                .withEmail('globanttt@globant.com')
                .withAlias('contact')
				.withLastName('Contacto')
                .withTimeZoneSidKey('America/Argentina/Buenos_Aires')
                .withLocaleSidKey('es_AR')
                .withCommunityNickname('test.globant')
                .withEmailEncodingKey('ISO-8859-1')
                .withProfileId(systemAdministrator.Id)
                .withUserRoleId(portalRole)				
                .withLanguageLocaleKey('es')
                .build();         
        insert usuario;

        System.runAs(usuario){

            UserRole equipoPediatricosRole = [Select Id From UserRole Where Name = 'Equipo Pediatricos Partner User' Limit 1];

            Profile apmPerfil = [
                    SELECT Id 
                    FROM Profile 
                    WHERE Name = 'APM' 
                    LIMIT 1
                ];
            String uniqueUserName = 'wsdataapptest' + DateTime.now().getTime() + '@testorg.com';
            
            Account institucion = Build.anAccount()
                .withName('InstitucionTest')
                .build();
            insert institucion;
            
            Account cuenta = Build.anAccount().withRecordTypeId(profesionalSalud).build();
            cuenta.FirstName = 'Prueba';
            cuenta.LastName = 'Test';
            insert cuenta;

            Id recordTypeVisitadorMedico = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Visitador_Medico').getRecordTypeId();
            Contact apm = Build.aContactVisitadorMedico()
            .withAccount(institucion)            
            .build();
            apm.VisMed_DNI__c = '22222333';
            apm.RecordTypeId = recordTypeVisitadorMedico;
            apm.Sub_Equipo__c = 'Metabólicos y Dieta';
            insert apm;

            User apmUser = Build.aUser()
                .withUsername(
                    'newuser'+String.valueOf(System.now().getTime() + (Math.random() * 10))+'@testorg.com'
                )               
                .withEmail('apm@xappia.com')
                .withAlias('apm')
                .withLastName('Owner')
                .withContactId(apm)
                .withTimeZoneSidKey('America/Argentina/Buenos_Aires')
                .withLocaleSidKey('es_AR')
                .withCommunityNickname('apm.xappia')
                .withEmailEncodingKey('ISO-8859-1')
                .withProfileId(apmPerfil.Id)                			
                .withLanguageLocaleKey('es')
                .build();           
            usuario.ManagerId = UserInfo.getUserId();
            usuario.IsActive = true;
            usuario.VisMed_ContrasenaApp__c = 'TestOwner';
            insert apmUser;
            
            VisMed_Contacto_Cuenta_Usuario__c fichero = Build.aVisMedContactCuentaUsuarioBuilder()
                .withAPM(apm)
                .withInstitucion(institucion)
                .withProfesional(cuenta)
                .build();
            insert fichero;
        }
    }

    @isTest
    static void ifCreateABajaAContactMustAssign(){
        Id institucionId = XappiaHelper.getRecordType('VisMed_Bajas__c', 'Institucion').Id;
        Account cuenta = [SELECT Id, Name FROM Account WHERE FirstName = 'Prueba'];
        User usuario = [SELECT id, ContactId FROM User WHERE Email = 'apm@xappia.com'];
        Contact contacto = [SELECT Id, Name FROM Contact WHERE Id = :usuario.ContactId];
        
        VisMed_Bajas__c baja = Build.aVisMedBajas()
            .withRecordType(institucionId)
            .withProfesional(cuenta)
            .withFechaDeDesactivacion(Date.today().addDays(-1))
            //.withFechaDeReactivacion(Date)
            .withEstado('Pendiente')
            .withMotivoDeLaBaja('No ejerce más la profesión')
            .withVisMedAPM(contacto)
        .Build();

        Test.startTest();
            insert baja;
        Test.stopTest();

        VisMed_Bajas__c bajaToCheck = [SELECT id, OwnerId FROM VisMed_Bajas__c LIMIT 1];
        System.assertEquals(usuario.Id, bajaToCheck.OwnerId, 'No se asigno el owner correspondiente');
    }

    @isTest
    static void desvincularProfesional(){
        Id profesionalSaludId = XappiaHelper.getRecordType('VisMed_Bajas__c', 'Profesional_de_la_Salud').Id;
        Account cuenta = [SELECT Id, Name FROM Account WHERE FirstName = 'Prueba'];
        User usuario = [SELECT id, ContactId FROM User WHERE Email = 'apm@xappia.com'];
        Contact contacto = [SELECT Id, Name FROM Contact WHERE Id = :usuario.ContactId];
        Account institucion = [SELECT id, Name FROM Account WHERE Name = 'InstitucionTest'];
        
        System.debug(institucion);

        VisMed_Bajas__c baja = Build.aVisMedBajas()
            .withRecordType(profesionalSaludId)
            .withProfesional(cuenta)
            .withFechaDeDesactivacion(Date.today().addDays(-1))
            .withEstado('Aprobada')
            .withMotivoDeLaBaja('Maternidad')
            .withVisMedAPM(contacto)
            .withInstitucion(institucion)
        .Build();

        Test.startTest();
            insert baja;
        Test.stopTest();

        Account cuentaTest = [SELECT Id, Name, Profesional_Activo__c FROM Account WHERE FirstName = 'Prueba'];
        System.assertEquals(false, cuentaTest.Profesional_Activo__c, 'El profesional no se desactivo');
    }

    @isTest
    static void desvincularSeguimiento(){
        Id profesionalSaludId = XappiaHelper.getRecordType('VisMed_Bajas__c', 'Seguimiento').Id;
        Account cuenta = [SELECT Id, Name FROM Account WHERE FirstName = 'Prueba'];
        User usuario = [SELECT id, ContactId FROM User WHERE Email = 'apm@xappia.com'];
        Contact contacto = [SELECT Id, Name FROM Contact WHERE Id = :usuario.ContactId];
        Account institucion = [SELECT id, Name FROM Account WHERE Name = 'InstitucionTest'];
        
        System.debug(institucion);

        VisMed_Bajas__c baja = Build.aVisMedBajas()
            .withRecordType(profesionalSaludId)
            .withProfesional(cuenta)
            .withFechaDeDesactivacion(Date.today().addDays(1))
            .withEstado('Aprobada')
            .withVisMedAPM(contacto)
            .withInstitucion(institucion)
        .Build();

        Test.startTest();
            insert baja;
        Test.stopTest();

        VisMed_Contacto_Cuenta_Usuario__c fichero = [SELECT Id, Estado__c FROM VisMed_Contacto_Cuenta_Usuario__c];
        System.assertEquals('Inactivo', fichero.Estado__c, 'El fichero no se paso a inactivo');
    }

    @isTest
    static void desvincularProfesionalPorBajaTotal(){
        Id profesionalSaludId = XappiaHelper.getRecordType('VisMed_Bajas__c', 'Profesional_de_la_Salud').Id;
        Account cuenta = [SELECT Id, Name FROM Account WHERE FirstName = 'Prueba'];
        User usuario = [SELECT id, ContactId FROM User WHERE Email = 'apm@xappia.com'];
        Contact contacto = [SELECT Id, Name FROM Contact WHERE Id = :usuario.ContactId];
        Account institucion = [SELECT id, Name FROM Account WHERE Name = 'InstitucionTest'];
        
        VisMed_Bajas__c baja = Build.aVisMedBajas()
            .withRecordType(profesionalSaludId)
            .withProfesional(cuenta)
            .withFechaDeDesactivacion(Date.today().addDays(-1))
            .withEstado('Aprobada')
            .withMotivoDeLaBaja('Fallecimiento')
            .withVisMedAPM(contacto)
            .withInstitucion(institucion)
        .Build();

        Test.startTest();
            insert baja;
        Test.stopTest();

        VisMed_Contacto_Cuenta_Usuario__c fichero = [SELECT Id, Estado__c FROM VisMed_Contacto_Cuenta_Usuario__c WHERE Estado__c = 'Inactivo'];
        System.assertEquals('Inactivo', fichero.Estado__c, 'El fichero no se paso a inactivo');
    }

    @isTest
    static void desvincularProfesionalPorBajaTemporal(){
        User userOwner = [
            SELECT Id
            FROM User
            WHERE Alias = 'apm'
        ];
    system.runAs(userOwner){
        Id profesionalSaludId = XappiaHelper.getRecordType('VisMed_Bajas__c', 'Profesional_de_la_Salud').Id;
        Account cuenta = [SELECT Id, Name FROM Account WHERE FirstName = 'Prueba'];
        User usuario = [SELECT id, ContactId FROM User WHERE Email = 'apm@xappia.com'];
        Contact contacto = [SELECT Id, Name FROM Contact WHERE Id = :usuario.ContactId];
        Account institucion = [SELECT id, Name FROM Account WHERE Name = 'InstitucionTest'];
        
        System.debug(institucion);

        VisMed_Bajas__c baja = Build.aVisMedBajas()
            .withRecordType(profesionalSaludId)
            .withProfesional(cuenta)
            .withFechaDeDesactivacion(Date.today().addDays(-1))
            .withEstado('Aprobada')
            .withMotivoDeLaBaja('Enfermedad')
            .withVisMedAPM(contacto)
            .withInstitucion(institucion)
        .Build();

        Test.startTest();
            insert baja;
        Test.stopTest();

        VisMed_Contacto_Cuenta_Usuario__c fichero = [SELECT Id, Estado__c FROM VisMed_Contacto_Cuenta_Usuario__c];
        System.assertEquals('Baja Temporal', fichero.Estado__c, 'El fichero no se paso a inactivo');
    }
    }

    @isTest
    static void desvincularProfesionalPorBajaNoTemporalNiTotal(){
        Id profesionalSaludId = XappiaHelper.getRecordType('VisMed_Bajas__c', 'Profesional_de_la_Salud').Id;
        Account cuenta = [SELECT Id, Name FROM Account WHERE FirstName = 'Prueba'];
        User usuario = [SELECT id, ContactId FROM User WHERE Email = 'apm@xappia.com'];
        Contact contacto = [SELECT Id, Name FROM Contact WHERE Id = :usuario.ContactId];
        Account institucion = [SELECT id, Name FROM Account WHERE Name = 'InstitucionTest'];
        
        System.debug(institucion);

        VisMed_Bajas__c baja = Build.aVisMedBajas()
            .withRecordType(profesionalSaludId)
            .withProfesional(cuenta)
            .withFechaDeDesactivacion(Date.today().addDays(-1))
            .withEstado('Aprobada')
            .withMotivoDeLaBaja('Bajo Potencial')
            .withVisMedAPM(contacto)
            .withInstitucion(institucion)
        .Build();

        Test.startTest();
            insert baja;
        Test.stopTest();

        VisMed_Contacto_Cuenta_Usuario__c fichero = [SELECT Id, Estado__c FROM VisMed_Contacto_Cuenta_Usuario__c];
        System.assertEquals('Inactivo', fichero.Estado__c, 'El fichero no se paso a inactivo');
    }

   @isTest
    static void ifBajaIsChangeToApproveCreateNotification(){
        Id profesionalSaludId = XappiaHelper.getRecordType('VisMed_Bajas__c', 'Profesional_de_la_Salud').Id;
        Account cuenta = [SELECT Id, Name FROM Account WHERE FirstName = 'Prueba'];
        User usuario = [SELECT id, ContactId FROM User WHERE Email = 'apm@xappia.com'];
        Contact contacto = [SELECT Id, Name FROM Contact WHERE Id = :usuario.ContactId];
        Account institucion = [SELECT id, Name FROM Account WHERE Name = 'InstitucionTest'];
        
        System.debug(institucion);

        VisMed_Bajas__c baja = Build.aVisMedBajas()
            .withRecordType(profesionalSaludId)
            .withProfesional(cuenta)
            .withFechaDeDesactivacion(Date.today().addDays(1))
            .withEstado('Rechazada')
            .withMotivoDeLaBaja('Bajo Potencial')
            .withVisMedAPM(contacto)
            .withInstitucion(institucion)
        .Build();
        insert baja;

        baja.Estado__c = 'Aprobada';
        Test.startTest();
            update baja;
        Test.stopTest();

        VisMed_Bajas__c bajaToTest = [SELECT ID, Institucion__c FROM VisMed_Bajas__c];
        VisMed_Contacto_Cuenta_Usuario__c fichero = [SELECT Id, Estado__c, Institucion__c FROM VisMed_Contacto_Cuenta_Usuario__c];
        System.assertEquals(fichero.Institucion__c, bajaToTest.Institucion__c, 'La Baja no actualizo la institucion');
    }

    @isTest
    static void ifBajaSeguimientoIsChangeToApproveCreateNotification(){
        Id profesionalSaludId = XappiaHelper.getRecordType('VisMed_Bajas__c', 'Seguimiento').Id;
        Account cuenta = [SELECT Id, Name FROM Account WHERE FirstName = 'Prueba'];
        User usuario = [SELECT id, ContactId FROM User WHERE Email = 'apm@xappia.com'];
        Contact contacto = [SELECT Id, Name FROM Contact WHERE Id = :usuario.ContactId];
        Account institucion = [SELECT id, Name FROM Account WHERE Name = 'InstitucionTest'];
        
        System.debug(institucion);

        VisMed_Bajas__c baja = Build.aVisMedBajas()
            .withRecordType(profesionalSaludId)
            .withProfesional(cuenta)
            .withFechaDeDesactivacion(Date.today().addDays(1))
            .withEstado('Rechazada')
            .withMotivoDeLaBaja('Bajo Potencial')
            .withVisMedAPM(contacto)
            .withInstitucion(institucion)
        .Build();
        insert baja;

        baja.Estado__c = 'Aprobada';
        Test.startTest();
            update baja;
        Test.stopTest();

        VisMed_Bajas__c bajaToTest = [SELECT ID, Institucion__c FROM VisMed_Bajas__c];
        VisMed_Contacto_Cuenta_Usuario__c fichero = [SELECT Id, Estado__c, Institucion__c FROM VisMed_Contacto_Cuenta_Usuario__c];
        System.assertEquals(fichero.Institucion__c, bajaToTest.Institucion__c, 'La Baja no actualizo la institucion');
    }

    @isTest
    static void ifInsertBajaTotalCheckForDuplicateInProfesional(){
        Id institucionId = XappiaHelper.getRecordType('VisMed_Bajas__c', 'Profesional_de_la_Salud').Id;
        Account cuenta = [SELECT Id, Name FROM Account WHERE FirstName = 'Prueba'];
        User usuario = [SELECT id, ContactId FROM User WHERE Email = 'apm@xappia.com'];
        Contact contacto = [SELECT Id, Name FROM Contact WHERE Id = :usuario.ContactId];
        Boolean errorDup = false;

        VisMed_Bajas__c baja = Build.aVisMedBajas()
            .withRecordType(institucionId)
            .withProfesional(cuenta)
            .withEstado('Aprobada')
            .withMotivoDeLaBaja('No ejerce más la profesión')
            .withVisMedAPM(contacto)
        .Build();
        insert baja;

        VisMed_Bajas__c bajaDup = Build.aVisMedBajas()
            .withRecordType(institucionId)
            .withProfesional(cuenta)
            .withEstado('Aprobada')
            .withMotivoDeLaBaja('No ejerce más la profesión')
            .withVisMedAPM(contacto)
        .Build();
        
        Test.startTest();
        try {
            insert bajaDup;
        } catch (Exception e) {
            errorDup = true;
        }
        Test.stopTest();
        
        System.assertEquals(true, errorDup, 'Se inserto la baja TOTAL duplicada');
    }

    @isTest
    static void ifInsertBajaTemporalCheckForDuplicateInProfesional(){
        Id institucionId = XappiaHelper.getRecordType('VisMed_Bajas__c', 'Profesional_de_la_Salud').Id;
        Account cuenta = [SELECT Id, Name FROM Account WHERE FirstName = 'Prueba'];
        User usuario = [SELECT id, ContactId FROM User WHERE Email = 'apm@xappia.com'];
        Contact contacto = [SELECT Id, Name FROM Contact WHERE Id = :usuario.ContactId];
        Boolean errorDup = false;

        VisMed_Bajas__c baja = Build.aVisMedBajas()
            .withRecordType(institucionId)
            .withProfesional(cuenta)
            .withEstado('Aprobada')
            .withMotivoDeLaBaja('Enfermedad')
            .withFechaDeDesactivacion(Date.today())
            .withFechaDeReactivacion(Date.today().addDays(2))
            .withVisMedAPM(contacto)
        .Build();
        insert baja;

        VisMed_Bajas__c bajaDup = Build.aVisMedBajas()
            .withRecordType(institucionId)
            .withProfesional(cuenta)
            .withEstado('Aprobada')
            .withMotivoDeLaBaja('Enfermedad')
            .withFechaDeDesactivacion(Date.today())
            .withFechaDeReactivacion(Date.today().addDays(2))
            .withVisMedAPM(contacto)
        .Build();
        
        Test.startTest();
        try {
            insert bajaDup;
        } catch (Exception e) {
            errorDup = true;
        }
        Test.stopTest();
        
        System.assertEquals(true, errorDup, 'Se inserto la baja Temporal duplicada');
    }

    @isTest
    static void ifInsertCheckForDuplicateInSeguimiento(){
        Id institucionId = XappiaHelper.getRecordType('VisMed_Bajas__c', 'Seguimiento').Id;
        Account cuenta = [SELECT Id, Name FROM Account WHERE FirstName = 'Prueba'];
        User usuario = [SELECT id, ContactId FROM User WHERE Email = 'apm@xappia.com'];
        Contact contacto = [SELECT Id, Name FROM Contact WHERE Id = :usuario.ContactId];
        Boolean errorDup = false;

        VisMed_Bajas__c baja = Build.aVisMedBajas()
            .withRecordType(institucionId)
            .withProfesional(cuenta)
            .withEstado('Aprobada')
            .withVisMedAPM(contacto)
        .Build();
        insert baja;

        VisMed_Bajas__c bajaDup = Build.aVisMedBajas()
            .withRecordType(institucionId)
            .withProfesional(cuenta)
            .withEstado('Aprobada')
            .withVisMedAPM(contacto)
        .Build();
        
        Test.startTest();
        try {
            insert bajaDup;
        } catch (Exception e) {
            errorDup = true;
        }
        Test.stopTest();
        
        System.assertEquals(true, errorDup, 'Se inserto la baja de seguimiento duplicada');
    }

}