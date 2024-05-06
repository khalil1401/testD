/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-25-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public with sharing class WSDataAppTest {
    private static final String URL_MAPPING = 'data/';

    @TestSetup
    private static void setUp () {

        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        Profile profile1 = [Select Id from Profile where Name = 'System Administrator' or name = 'Administrador del sistema' ];

        User userOwner = Build.aUser()
                .withUsername(
                    'newuser'+String.valueOf(System.now().getTime() + (Math.random() * 10))+'@testorg.com'
                )               
                .withEmail('owner@xappia.com')
                .withAlias('owner')
                .withLastName('Owner')
                .withTimeZoneSidKey('America/Argentina/Buenos_Aires')
                .withLocaleSidKey('es_AR')
                .withCommunityNickname('prueba2.xappia')
                .withEmailEncodingKey('ISO-8859-1')
                .withProfileId(profile1.Id)
                .withUserRoleId(portalRole)				
                .withLanguageLocaleKey('es')
                .build();           
        userOwner.ManagerId = UserInfo.getUserId();
        userOwner.IsActive = true;
        userOwner.VisMed_ContrasenaApp__c = 'TestOwner';
        insert userOwner;

        System.runAs(userOwner){

            Id communityProfile = [SELECT Id FROM Profile WHERE name='Partner Community User'].Id;
            String uniqueUserName = 'wsdataapptest' + DateTime.now().getTime() + '@testorg.com';

            Id recordTypeProfesional = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Profesional_de_la_Salud').getRecordTypeId();
            Account profesional = Build.aPersonalAccount()
            .withFirstName('Profesional')
            //.withLastName('Test')
            .withProfesionalActivo(true)
            .build();
            profesional.LastName = 'ProfesionalTest';
            profesional.RecordTypeId = recordTypeProfesional;
            insert profesional;
            
            Account institucion = Build.anAccount()
                .withName('InstitucionTest')
                .build();
            insert institucion;

            Id recordTypeVisitadorMedico = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Visitador_Medico').getRecordTypeId();
            Contact apm = Build.aContactVisitadorMedico()
                .withAccount(institucion)            
                .build();
            apm.VisMed_DNI__c = '22222333';
            apm.RecordTypeId = recordTypeVisitadorMedico;
            insert apm;

            VisMed_Ciclo__c ciclo = Build.aVisMedCiclo()
                .withFechadeinicio(Date.today().toStartOfMonth())
                .withFechadeFin(Date.today().toStartOfMonth().addMonths(1).addDays(-1))
                .withVisMedCmptTiemponopromocional(1)
                .build();
            insert ciclo;

            Dan360_Efectividad__c efectividad = Build.aDan360Efectividad()
                .withFechadeinicio(Date.today())
                .withFechadeFin(Date.today().addMonths(1))
                .withVisMedDiasdeLicenciaUnicos(2)
                .withVisMedTargetDiario(4)
                .withVisMedCiclo(ciclo)
                .withVisMedVisitasrealizadas(0)
                .withVisMedAPM(apm)
                .build();
            insert efectividad;

            User userTest = Build.aUser()
                .withUsername(uniqueUserName)
                .withContactId(apm)
                .withLastName('Contacto1')
                .withEmail('contacto1@xappia.com')
                .withAlias('contact1')
                .withTimeZoneSidKey('America/Argentina/Buenos_Aires')
                .withLocaleSidKey('es_AR')
                .withCommunityNickname('prueba1.xappia')
                .withEmailEncodingKey('ISO-8859-1')
                .withProfileId(communityProfile)
                .withLanguageLocaleKey('es')
                .build();
            userTest.ManagerId = UserInfo.getUserId();
            userTest.IsActive = true;
            userTest.VisMed_ContrasenaApp__c = 'Test';
            insert userTest;

            Id recordTypeAlergia = Schema.SObjectType.VisMed_Segmentacion__c.getRecordTypeInfosByDeveloperName().get('Alergia').getRecordTypeId();
            // VisMed_Segmentacion__c segmentacion = new VisMed_Segmentacion__c(
            //     Profesional__c = profesional.id,
            //     Institucion__c = institucion.id,
            //     Frecuencia__c = 1.00,            
            //     RecordTypeId = recordTypeAlergia
            // );
            // insert segmentacion;
            VisMed_Contacto_Cuenta_Usuario__c seguimiento = Build.aVisMedContactCuentaUsuarioBuilder()
                .withProfesional(profesional)
                .withInstitucion(institucion)
                .withSegmentaPor('Adultos General Comunidad')
                .withAPM(apm)
                .build();
            insert seguimiento;
    }
    }

    @isTest
    private static void doGetNothing() {
        User userOwner = [
            SELECT Id
            FROM User
            WHERE Alias = 'owner'
        ];
        List<SObject> emptyList = new List<SObject>();
        system.runAs(userOwner){
            
            RestRequest req = new RestRequest();
            System.debug('userId: '+ UserInfo.getUserId());
            req.addHeader('iddeluser', userOwner.Id);
            req.addHeader('ultimasincronizacion', '2022-12-18');
            req.addHeader('lastid', '');
            req.requestURI = '/services/apexrest/' + URL_MAPPING;
            req.httpMethod = 'GET';

            RestContext.request = req;
            
            Test.startTest();
            WSDataApp.Respuesta resp = WSDataApp.doGet();
            Test.stopTest();

            System.assertEquals(emptyList, resp.sobjects, 'La respuesta esta retornando un objeto');
        }
    }

    @isTest
    private static void doGetInstitucion() { 
        User userOwner = [
            SELECT Id
            FROM User
            WHERE Alias = 'owner'
        ];
        system.runAs(userOwner){       
            RestRequest req = new RestRequest();
            req.addHeader('iddeluser', userOwner.Id);
            req.addHeader('ultimasincronizacion', '2022-12-18');
            req.addHeader('objeto', 'institucion');
            req.addHeader('lastid', '');
            req.requestURI = '/services/apexrest/' + URL_MAPPING;
            req.httpMethod = 'GET';

            RestContext.request = req;
            
            Test.startTest();
            WSDataApp.Respuesta resp = WSDataApp.doGet();
            Test.stopTest();

            System.assertNotEquals(null, resp.sobjects, 'No se encontro ningun objeto');
        }
    }

    @isTest
    private static void doGetProfesionalDeLaSalud() {
        User userOwner = [
            SELECT Id
            FROM User
            WHERE Alias = 'owner'
        ];
        system.runAs(userOwner){ 
            RestRequest req = new RestRequest();                
            req.addHeader('iddeluser', userOwner.Id);
            req.addHeader('ultimasincronizacion', '2022-12-18');
            req.addHeader('objeto', 'profesional de la salud');
            req.addHeader('lastid', '');
            req.requestURI = '/services/apexrest/' + URL_MAPPING; 
            req.httpMethod = 'GET';

            RestContext.request = req;
            
            Test.startTest();
            WSDataApp.Respuesta resp = WSDataApp.doGet();
            Test.stopTest();

            System.assertNotEquals(null, resp.sobjects, 'No se encontro ningun objeto');
        }
    }

    @isTest
    private static void doGetOtroProfesional() {
        User userOwner = [
            SELECT Id
            FROM User
            WHERE Alias = 'owner'
        ];
        system.runAs(userOwner){ 
            RestRequest req = new RestRequest();                
            req.addHeader('iddeluser', userOwner.Id);
            req.addHeader('ultimasincronizacion', '2022-12-18');
            req.addHeader('objeto', 'otro profesional');
            req.addHeader('lastid', '');
            req.requestURI = '/services/apexrest/' + URL_MAPPING; 
            req.httpMethod = 'GET';

            RestContext.request = req;
            
            Test.startTest();
            WSDataApp.Respuesta resp = WSDataApp.doGet();
            Test.stopTest();

            System.assertNotEquals(null, resp.sobjects, 'No se encontro ningun objeto');
        }
    }

    @isTest
    private static void doGetCiclo() {
        User userOwner = [
            SELECT Id
            FROM User
            WHERE Alias = 'owner'
        ];
        system.runAs(userOwner){ 
            RestRequest req = new RestRequest();                
            req.addHeader('iddeluser', userOwner.Id);
            req.addHeader('ultimasincronizacion', '2022-12-18');
            req.addHeader('objeto', 'ciclo');
            req.addHeader('lastid', '');
            req.requestURI = '/services/apexrest/' + URL_MAPPING; 
            req.httpMethod = 'GET';

            RestContext.request = req;
            
            Test.startTest();
            WSDataApp.Respuesta resp = WSDataApp.doGet();
            Test.stopTest();

            System.assertNotEquals(null, resp.sobjects, 'No se encontro ningun objeto');
        }
    }

    @isTest
    private static void doGetEfectividad() {
        User userOwner = [
            SELECT Id
            FROM User
            WHERE Alias = 'owner'
        ];
        system.runAs(userOwner){ 
            RestRequest req = new RestRequest();                
            req.addHeader('iddeluser', userOwner.Id);
            req.addHeader('ultimasincronizacion', '2022-12-18');
            req.addHeader('objeto', 'efectividad');
            req.addHeader('lastid', '');
            req.requestURI = '/services/apexrest/' + URL_MAPPING; 
            req.httpMethod = 'GET';

            RestContext.request = req;
            
            Test.startTest();
            WSDataApp.Respuesta resp = WSDataApp.doGet();
            Test.stopTest();

            System.assertNotEquals(null, resp.sobjects, 'No se encontro ningun objeto');
        }
    }

    @isTest
    private static void doGetInteraccion() {
        User userOwner = [
            SELECT Id
            FROM User
            WHERE Alias = 'owner'
        ];
        system.runAs(userOwner){ 
            RestRequest req = new RestRequest();                
            req.addHeader('iddeluser', userOwner.Id);
            req.addHeader('ultimasincronizacion', '2022-12-18');
            req.addHeader('objeto', 'interaccion');
            req.addHeader('lastid', '');
            req.requestURI = '/services/apexrest/' + URL_MAPPING; 
            req.httpMethod = 'GET';

            RestContext.request = req;
            
            Test.startTest();
            WSDataApp.Respuesta resp = WSDataApp.doGet();
            Test.stopTest();

            System.assertNotEquals(null, resp.sobjects, 'No se encontro ningun objeto');
        }
    }

    @isTest
    private static void doGetLicencia() {
        User userOwner = [
            SELECT Id
            FROM User
            WHERE Alias = 'owner'
        ];
        system.runAs(userOwner){ 
            RestRequest req = new RestRequest();                
            req.addHeader('iddeluser', userOwner.Id);
            req.addHeader('ultimasincronizacion', '2022-12-18');
            req.addHeader('objeto', 'licencia');
            req.addHeader('lastid', '');
            req.requestURI = '/services/apexrest/' + URL_MAPPING; 
            req.httpMethod = 'GET';

            RestContext.request = req;
            
            Test.startTest();
            WSDataApp.Respuesta resp = WSDataApp.doGet();
            Test.stopTest();

            System.assertNotEquals(null, resp.sobjects, 'No se encontro ningun objeto');
        }
    }
    
    @isTest
    private static void doGetSeguimiento() {
        User userOwner = [
            SELECT Id
            FROM User
            WHERE Alias = 'owner'
        ];
        system.runAs(userOwner){ 
            RestRequest req = new RestRequest();                
            req.addHeader('iddeluser', userOwner.Id);
            req.addHeader('ultimasincronizacion', '2022-12-18');
            req.addHeader('objeto', 'seguimiento');
            req.addHeader('lastid', '');
            req.requestURI = '/services/apexrest/' + URL_MAPPING; 
            req.httpMethod = 'GET';

            RestContext.request = req;
            
            Test.startTest();
            WSDataApp.Respuesta resp = WSDataApp.doGet();
            Test.stopTest();

            System.assertNotEquals(null, resp.sobjects, 'No se encontro ningun objeto');
        }
    }

    @isTest
    private static void doGetEquipoDeCuentas() {
        User userOwner = [
            SELECT Id
            FROM User
            WHERE Alias = 'owner'
        ];
        system.runAs(userOwner){ 
            RestRequest req = new RestRequest();                
            req.addHeader('iddeluser', userOwner.Id);
            req.addHeader('ultimasincronizacion', '2022-12-18');
            req.addHeader('objeto', 'equipo de cuentas');
            req.addHeader('lastid', '');
            req.requestURI = '/services/apexrest/' + URL_MAPPING; 
            req.httpMethod = 'GET';

            RestContext.request = req;
            
            Test.startTest();
            WSDataApp.Respuesta resp = WSDataApp.doGet();
            Test.stopTest();

            System.assertNotEquals(null, resp.sobjects, 'No se encontro ningun objeto');
        }
    }

    @isTest
    private static void doGetMatricula() {
        User userOwner = [
            SELECT Id
            FROM User
            WHERE Alias = 'owner'
        ];
        system.runAs(userOwner){ 
            RestRequest req = new RestRequest();                
            req.addHeader('iddeluser', userOwner.Id);
            req.addHeader('ultimasincronizacion', '2022-12-18');
            req.addHeader('objeto', 'matricula');
            req.addHeader('lastid', '');
            req.requestURI = '/services/apexrest/' + URL_MAPPING; 
            req.httpMethod = 'GET';

            RestContext.request = req;
            
            Test.startTest();
            WSDataApp.Respuesta resp = WSDataApp.doGet();
            Test.stopTest();

            System.assertNotEquals(null, resp.sobjects, 'No se encontro ningun objeto');
        }
    }

    @isTest
    private static void doGetLugaresDeTrabajo() {
        User userOwner = [
            SELECT Id
            FROM User
            WHERE Alias = 'owner'
        ];
        system.runAs(userOwner){ 
            RestRequest req = new RestRequest();                
            req.addHeader('iddeluser', userOwner.Id);
            req.addHeader('ultimasincronizacion', '2022-12-18');
            req.addHeader('objeto', 'lugares de trabajo');
            req.addHeader('lastid', '');
            req.requestURI = '/services/apexrest/' + URL_MAPPING; 
            req.httpMethod = 'GET';

            RestContext.request = req;
            
            Test.startTest();
            WSDataApp.Respuesta resp = WSDataApp.doGet();
            Test.stopTest();

            System.assertNotEquals(null, resp.sobjects, 'No se encontro ningun objeto');
        }
    }

    @isTest
    private static void doGetRecordTypes() {
        User userOwner = [
            SELECT Id
            FROM User
            WHERE Alias = 'owner'
        ];
        system.runAs(userOwner){ 
            RestRequest req = new RestRequest();                
            req.addHeader('iddeluser', userOwner.Id);
            req.addHeader('ultimasincronizacion', '2022-12-18');
            req.addHeader('objeto', 'recordstype');
            req.addHeader('lastid', '');
            req.requestURI = '/services/apexrest/' + URL_MAPPING; 
            req.httpMethod = 'GET';

            RestContext.request = req;
            
            Test.startTest();
            WSDataApp.Respuesta resp = WSDataApp.doGet();
            Test.stopTest();

            System.assertNotEquals(null, resp.sobjects, 'No se encontro ningun objeto');
        }
    }

    @isTest
    private static void doGetBajas() {
        User userOwner = [
            SELECT Id
            FROM User
            WHERE Alias = 'owner'
        ];
        system.runAs(userOwner){ 
            RestRequest req = new RestRequest();                
            req.addHeader('iddeluser', userOwner.Id);
            req.addHeader('ultimasincronizacion', '2022-12-18');
            req.addHeader('objeto', 'bajas');
            req.addHeader('lastid', '');
            req.requestURI = '/services/apexrest/' + URL_MAPPING; 
            req.httpMethod = 'GET';

            RestContext.request = req;
            
            Test.startTest();
            WSDataApp.Respuesta resp = WSDataApp.doGet();
            Test.stopTest();

            System.assertNotEquals(null, resp.sobjects, 'No se encontro ningun objeto');
        }
    }

    @isTest
    private static void doGetStockXciclo() {
        User userOwner = [
            SELECT Id
            FROM User
            WHERE Alias = 'owner'
        ];
        system.runAs(userOwner){ 
            RestRequest req = new RestRequest();                
            req.addHeader('iddeluser', userOwner.Id);
            req.addHeader('ultimasincronizacion', '2022-12-18');
            req.addHeader('objeto', 'stockXciclo');
            req.addHeader('lastid', '');
            req.requestURI = '/services/apexrest/' + URL_MAPPING; 
            req.httpMethod = 'GET';

            RestContext.request = req;
            
            Test.startTest();
            WSDataApp.Respuesta resp = WSDataApp.doGet();
            Test.stopTest();

            System.assertNotEquals(null, resp.sobjects, 'No se encontro ningun objeto');
        }
    }

    @isTest
    private static void doGetStockxMM() {
        User userOwner = [
            SELECT Id
            FROM User
            WHERE Alias = 'owner'
        ];
        system.runAs(userOwner){ 
            RestRequest req = new RestRequest();                
            req.addHeader('iddeluser', userOwner.Id);
            req.addHeader('ultimasincronizacion', '2022-12-18');
            req.addHeader('objeto', 'stockxMM');
            req.addHeader('lastid', '');
            req.requestURI = '/services/apexrest/' + URL_MAPPING; 
            req.httpMethod = 'GET';

            RestContext.request = req;
            
            Test.startTest();
            WSDataApp.Respuesta resp = WSDataApp.doGet();
            Test.stopTest();

            System.assertNotEquals(null, resp.sobjects, 'No se encontro ningun objeto');
        }
    }

    @isTest
    private static void doGetMuestrasDeLasVisitas() {
        User userOwner = [
            SELECT Id
            FROM User
            WHERE Alias = 'owner'
        ];
        system.runAs(userOwner){ 
            RestRequest req = new RestRequest();                
            req.addHeader('iddeluser', userOwner.Id);
            req.addHeader('ultimasincronizacion', '2022-12-18');
            req.addHeader('objeto', 'muestras de las visitas');
            req.addHeader('lastid', '');
            req.requestURI = '/services/apexrest/' + URL_MAPPING; 
            req.httpMethod = 'GET';

            RestContext.request = req;
            
            Test.startTest();
            WSDataApp.Respuesta resp = WSDataApp.doGet();
            Test.stopTest();

            System.assertNotEquals(null, resp.sobjects, 'No se encontro ningun objeto');
        }
    }

    @isTest
    private static void doGetNotificacion() {
        User userOwner = [
            SELECT Id
            FROM User
            WHERE Alias = 'owner'
        ];
        system.runAs(userOwner){ 
            RestRequest req = new RestRequest();                
            req.addHeader('iddeluser', userOwner.Id);
            req.addHeader('ultimasincronizacion', '2022-12-18');
            req.addHeader('objeto', 'notificacion');
            req.addHeader('lastid', '');
            req.requestURI = '/services/apexrest/' + URL_MAPPING; 
            req.httpMethod = 'GET';

            RestContext.request = req;
            
            Test.startTest();
            WSDataApp.Respuesta resp = WSDataApp.doGet();
            Test.stopTest();

            System.assertNotEquals(null, resp.sobjects, 'No se encontro ningun objeto');
        }
    }

    @isTest
    private static void doGetReceta() {
        User userOwner = [
            SELECT Id
            FROM User
            WHERE Alias = 'owner'
        ];
        system.runAs(userOwner){ 
            RestRequest req = new RestRequest();                
            req.addHeader('iddeluser', userOwner.Id);
            req.addHeader('ultimasincronizacion', '2022-12-18');
            req.addHeader('objeto', 'receta');
            req.addHeader('lastid', '');
            req.requestURI = '/services/apexrest/' + URL_MAPPING; 
            req.httpMethod = 'GET';

            RestContext.request = req;
            
            Test.startTest();
            WSDataApp.Respuesta resp = WSDataApp.doGet();
            Test.stopTest();

            System.assertNotEquals(null, resp.sobjects, 'No se encontro ningun objeto');
        }
    }

    @isTest
    private static void doGetProductoDeReceta() {
        User userOwner = [
            SELECT Id
            FROM User
            WHERE Alias = 'owner'
        ];
        system.runAs(userOwner){ 
            RestRequest req = new RestRequest();                
            req.addHeader('iddeluser', userOwner.Id);
            req.addHeader('ultimasincronizacion', '2022-12-18');
            req.addHeader('objeto', 'producto de receta');
            req.addHeader('lastid', '');
            req.requestURI = '/services/apexrest/' + URL_MAPPING; 
            req.httpMethod = 'GET';

            RestContext.request = req;
            
            Test.startTest();
            WSDataApp.Respuesta resp = WSDataApp.doGet();
            Test.stopTest();

            System.assertNotEquals(null, resp.sobjects, 'No se encontro ningun objeto');
        }
    }

    @isTest
    private static void doGetCuatrimestre() {
        User userOwner = [
            SELECT Id
            FROM User
            WHERE Alias = 'owner'
        ];
        system.runAs(userOwner){ 
            RestRequest req = new RestRequest();                
            req.addHeader('iddeluser', userOwner.Id);
            req.addHeader('ultimasincronizacion', '2022-12-18');
            req.addHeader('objeto', 'cuatrimestre');
            req.addHeader('lastid', '');
            req.requestURI = '/services/apexrest/' + URL_MAPPING; 
            req.httpMethod = 'GET';

            RestContext.request = req;
            
            Test.startTest();
            WSDataApp.Respuesta resp = WSDataApp.doGet();
            Test.stopTest();

            System.assertNotEquals(null, resp.sobjects, 'No se encontro ningun objeto');
        }
    }

    @isTest
    private static void doGetObjetivo() {
        User userOwner = [
            SELECT Id
            FROM User
            WHERE Alias = 'owner'
        ];
        system.runAs(userOwner){ 
            RestRequest req = new RestRequest();                
            req.addHeader('iddeluser', userOwner.Id);
            req.addHeader('ultimasincronizacion', '2022-12-18');
            req.addHeader('objeto', 'objetivo');
            req.addHeader('lastid', '');
            req.requestURI = '/services/apexrest/' + URL_MAPPING; 
            req.httpMethod = 'GET';

            RestContext.request = req;
            
            Test.startTest();
            WSDataApp.Respuesta resp = WSDataApp.doGet();
            Test.stopTest();

            System.assertNotEquals(null, resp.sobjects, 'No se encontro ningun objeto');
        }
    }

    @isTest
    private static void doGetObjetivoXcuenta() {
        User userOwner = [
            SELECT Id
            FROM User
            WHERE Alias = 'owner'
        ];
        system.runAs(userOwner){ 
            RestRequest req = new RestRequest();                
            req.addHeader('iddeluser', userOwner.Id);
            req.addHeader('ultimasincronizacion', '2022-12-18');
            req.addHeader('objeto', 'objetivoXcuenta');
            req.addHeader('lastid', '');
            req.requestURI = '/services/apexrest/' + URL_MAPPING; 
            req.httpMethod = 'GET';

            RestContext.request = req;
            
            Test.startTest();
            WSDataApp.Respuesta resp = WSDataApp.doGet();
            Test.stopTest();

            System.assertNotEquals(null, resp.sobjects, 'No se encontro ningun objeto');
        }
    }

    @isTest
    private static void doGetAccion() {
        User userOwner = [
            SELECT Id
            FROM User
            WHERE Alias = 'owner'
        ];
        system.runAs(userOwner){ 
            RestRequest req = new RestRequest();                
            req.addHeader('iddeluser', userOwner.Id);
            req.addHeader('ultimasincronizacion', '2022-12-18');
            req.addHeader('objeto', 'accion');
            req.addHeader('lastid', '');
            req.requestURI = '/services/apexrest/' + URL_MAPPING; 
            req.httpMethod = 'GET';

            RestContext.request = req;
            
            Test.startTest();
            WSDataApp.Respuesta resp = WSDataApp.doGet();
            Test.stopTest();

            System.assertNotEquals(null, resp.sobjects, 'No se encontro ningun objeto');
        }
    }

    @isTest
    private static void doGetAccionXcuenta() {
        User userOwner = [
            SELECT Id
            FROM User
            WHERE Alias = 'owner'
        ];
        system.runAs(userOwner){ 
            RestRequest req = new RestRequest();                
            req.addHeader('iddeluser', userOwner.Id);
            req.addHeader('ultimasincronizacion', '2022-12-18');
            req.addHeader('objeto', 'accionXcuenta');
            req.addHeader('lastid', '');
            req.requestURI = '/services/apexrest/' + URL_MAPPING; 
            req.httpMethod = 'GET';

            RestContext.request = req;
            
            Test.startTest();
            WSDataApp.Respuesta resp = WSDataApp.doGet();
            Test.stopTest();

            System.assertNotEquals(null, resp.sobjects, 'No se encontro ningun objeto');
        }
    }

    @isTest
    private static void doGetLogs() {
        User userOwner = [
            SELECT Id
            FROM User
            WHERE Alias = 'owner'
        ];
        system.runAs(userOwner){ 
            RestRequest req = new RestRequest();                
            req.addHeader('iddeluser', userOwner.Id);
            req.addHeader('ultimasincronizacion', '2022-12-18');
            req.addHeader('objeto', 'logs');
            req.addHeader('lastid', '');
            req.requestURI = '/services/apexrest/' + URL_MAPPING; 
            req.httpMethod = 'GET';

            RestContext.request = req;

            Test.startTest();
            WSDataApp.Respuesta resp = WSDataApp.doGet();
            Test.stopTest();

            System.assertNotEquals(null, resp.sobjects, 'No se encontro ningun objeto');
        }
    }

    @isTest
    private static void doPostNoRecords() {
        RestRequest req = new RestRequest();
        WSDataApp.Request body = new WSDataApp.Request();
        
        req.requestURI = '/services/apexrest/' + URL_MAPPING + '/Dan360_Interacciones__c'; 
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serialize(body));

        RestContext.request = req;
        
        Test.startTest();
        WSDataApp.Respuesta resp = WSDataApp.doPost();
        Test.stopTest();

        System.assertEquals(508, resp.status, 'No es el status correcto');
        System.assertEquals('No hay registros para Guardar', resp.message, 'No es el mensaje correcto');
    }

    @isTest
    private static void doPostAndObtainError() {
        RestRequest req = new RestRequest();
        Account institucion = [SELECT Id FROM Account WHERE Name = 'InstitucionTest' LIMIT 1];
        Account profesional = [SELECT Id FROM Account WHERE LastName = 'ProfesionalTest' LIMIT 1];
        Contact apm = [SELECT Id FROM Contact WHERE AccountId = :institucion.Id LIMIT 1];
        Dan360_Efectividad__c efectividad = [
            SELECT Id FROM Dan360_Efectividad__c ORDER BY CreatedDate LIMIT 1
        ];
        Id recordTypeVisMed = XappiaHelper.getRecordType('Dan360_Interacciones__c', 'Visita_Medica').Id;
        string myDate = Date.today().addYears(-1).year()+'-'+ Date.today().addMonths(-1).month()+'-'+ Date.today().day();
        system.debug(myDate);
        String body = '{' +
            '"user": "' + UserInfo.getUserId() + '",' +
            '"recordsFromApp": [' +
                '{' +
                    '"Profesional__c": "'+profesional.Id+'",' +
                    '"Efectividad__c": "'+efectividad.Id+'",' +
                    '"RecordTypeId": "'+recordTypeVisMed+'",' +
                    '"VisMed_Tipo_de_Visita__c": "Presencial",' +
                    '"VisMed_Fecha__c": "'+myDate+'",' +
                    '"VisMed_Comentarios__c": "TEST APP. 2 Nutrison 500ml y 1 Nutrilon 400g",' +
                    '"Institucion__c":"'+institucion.Id+'",'+
                    //'"VisMed_APM__c": "'+apm.Id+'",' +
                    '"attributes": {' +
                        '"type": "Dan360_Interacciones__c"' +
                    '}' +
                '}' +
            '],' +
            '"fechaDeModificacionDelRegistro": "2022-07-20T16:17:34-05:00"' +
        '}';
        
        req.requestURI = '/services/apexrest/' + URL_MAPPING + '/Dan360_Interacciones__c'; 
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(body);

        RestContext.request = req;
        
        Test.startTest();
        WSDataApp.Respuesta resp = WSDataApp.doPost();
        Test.stopTest();

        System.debug(resp);
        
        System.assertEquals(508, resp.status, 'El status de la respuesta no es el esperado');
        System.assert(resp.message.contains('Hubo un error al intentar guardar'), 'No corresponde el mensaje de error');
    }

    @isTest
    private static void doPostSuccess() {
        RestRequest req = new RestRequest();
        Account institucion = [SELECT Id FROM Account WHERE Name = 'InstitucionTest' LIMIT 1];
        Account profesional = [SELECT Id FROM Account WHERE LastName = 'ProfesionalTest' LIMIT 1];
        Contact apm = [SELECT Id FROM Contact WHERE AccountId = :institucion.Id LIMIT 1];
        Dan360_Efectividad__c efectividad = [
            SELECT Id FROM Dan360_Efectividad__c ORDER BY CreatedDate LIMIT 1
        ];
        Id recordTypeVisMed = XappiaHelper.getRecordType('Dan360_Interacciones__c', 'Visita_Medica').Id;
        string myDate = Date.today().year()+'-'+ Date.today().month()+'-'+ Date.today().day();
        String body = '{' +
            '"user": "' + UserInfo.getUserId() + '",' +
            '"recordsFromApp": [' +
                '{' +
                '"Profesional__c": "'+profesional.Id+'",' +
                '"Efectividad__c": "'+efectividad.Id+'",' +
                '"RecordTypeId": "'+recordTypeVisMed+'",' +
                '"VisMed_Tipo_de_Visita__c": "Presencial",' +
                '"VisMed_Fecha__c": "'+myDate+'",' +
                '"VisMed_Domicilio_de_la_Visita__c": "'+institucion.Id+'",' +
                '"VisMed_Comentarios__c": "TEST APP. 2 Nutrison 500ml y 1 Nutrilon 400g",' +
                '"Institucion__c":"'+institucion.Id+'",'+
                '"VisMed_APM__c": "'+apm.Id+'",' +
                '"attributes": {' +
                    '"type": "Dan360_Interacciones__c"' +
                    '}' +
                '}' +
            '],' +
            '"fechaDeModificacionDelRegistro": "2022-11-21T22:34:19-03:00"' +
        '}';
        
        req.requestURI = '/services/apexrest/' + URL_MAPPING + '/Dan360_Licencia__c'; 
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(body);

        RestContext.request = req;
        
        Test.startTest();
        WSDataApp.Respuesta resp = WSDataApp.doPost();
        Test.stopTest();
        
        System.assertEquals(200, resp.status, 'El status de la respuesta no es el esperado');
        System.assertEquals('OK', resp.message, 'No corresponde el mensaje de error');
        System.assertNotEquals(null, resp.sobjects, 'No esta retornando el sobject');
    }
   
}