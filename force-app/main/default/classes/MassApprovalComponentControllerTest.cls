@isTest public with sharing class MassApprovalComponentControllerTest {
    @testSetup
    private static void testSetup() {
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
            Account account = Build.anAccount()
            .withName('Institucion')					
            .build();

            insert account;
            
            Id recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Visitador Medico').getRecordTypeId();
            Contact aContactOne = Build.aContact()
                .withAccount(account)
                .withFirstName('NameOne')
                .withLastName('LastnameOne')
                .build();
            
            aContactOne.RecordTypeId = recordTypeId;
            aContactOne.VisMed_DNI__c = '23555777';
            insert aContactOne;
            Contact apm = Build.aContact()
                .withAccount(account)
                .withFirstName('NameTwo')
                .withLastName('LastnameTwo')
                .build();     
            
            apm.RecordTypeId = recordTypeId;
            apm.VisMed_DNI__c = '23234324';
            apm.Sub_Equipo__c = 'Metabólicos y Dieta';
            insert apm;

            Profile perfil = [
                SELECT Id 
                FROM Profile 
                WHERE Name = 'Supervisores' 
                LIMIT 1
            ];

            User userApproval = Build.aUser()
                .withUsername(
                    'newuser'+String.valueOf(System.now().getTime() + (Math.random() * 10))+'@testorg.com'
                )            
                .withLastName('Approval')
                .withEmail('approval@xappia.com')
                .withAlias('appro')
                .withTimeZoneSidKey('America/Argentina/Buenos_Aires')
                .withLocaleSidKey('es_AR')
                .withCommunityNickname('approval.xappia')
                .withEmailEncodingKey('ISO-8859-1')
                .withProfileId(perfil.Id)
                .withLanguageLocaleKey('es')
                .build();

            userApproval.IsActive = true;
            userApproval.VisMed_ContrasenaApp__c = 'appro';

            insert userApproval;

            Profile perfilApm = [
                SELECT Id 
                FROM Profile 
                WHERE Name = 'APM' 
                LIMIT 1
            ];
            User userTest = Build.aUser()
                .withUsername(
                    'newuser'+String.valueOf(System.now().getTime() + (Math.random() * 10))+'@testorg.com'
                )
                .withContactId(apm)
                .withLastName('Contacto1')
                .withEmail('contacto1@xappia.com')
                .withAlias('contact1')
                .withTimeZoneSidKey('America/Argentina/Buenos_Aires')
                .withLocaleSidKey('es_AR')
                .withCommunityNickname('prueba1.xappia')
                .withEmailEncodingKey('ISO-8859-1')
                .withProfileId(perfilApm.Id)
                .withLanguageLocaleKey('es')
                .build();

            userTest.IsActive = true;
            userTest.VisMed_Es_un_Visitador_Medico__c = true;
            //userTest.IsPortalEnabled = true;
            userTest.VisMed_ContrasenaApp__c = 'Test';
            userTest.ManagerId = userApproval.Id;
            userTest.DelegatedApproverId = userApproval.Id;

            insert userTest;

            Id recordTypeProfesional = [SELECT Id, Name, SobjectType,IsPersonType 
            FROM RecordType 
            WHERE SobjectType='Account' AND IsPersonType=True AND Name = 'Profesional de la Salud'].Id;
            Account aPersonAccount = Build.aPersonalAccount()
                .withFirstName('Profesional')                
                .build();
            aPersonAccount.RecordTypeId = recordTypeProfesional;
            insert aPersonAccount;
            Account profesional = Build.aPersonalAccount()
                .withFirstName('Profesional')                
                .build();
            aPersonAccount.RecordTypeId = recordTypeProfesional;
            insert profesional;

            Id recordTypeAlergia = Schema.SObjectType.VisMed_Segmentacion__c.getRecordTypeInfosByDeveloperName().get('Adultos_General_Institucion').getRecordTypeId();
            VisMed_Segmentacion__c segmentacion = new VisMed_Segmentacion__c(
                Profesional__c = aPersonAccount.id,                
                RecordTypeId = recordTypeAlergia
            );
            insert segmentacion;

            Date today = Date.today();
            VisMed_Ciclo__c ciclo = Build.aCiclo()
            .withFechaInicio(today.toStartOfMonth())
            .withFechaFin(today.toStartOfMonth().addMonths(1).addDays(-1))
            .build();
            insert ciclo;

            Dan360_Efectividad__c efectividad = Build.aDan360Efectividad()
            .withVisMedAPM(apm)
            .withVisMedCiclo(ciclo)
            .build();
            efectividad.Fecha_de_Fin__c = Date.today().toStartOfMonth();
            efectividad.Fecha_de_inicio__c = Date.today().toStartOfMonth().addMonths(1).addDays(-1);
            insert efectividad;
        
        Id recordTypeLicencia = Schema.SObjectType.Dan360_Licencia__c.getRecordTypeInfosByDeveloperName().get('Licencia').getRecordTypeId();
        Dan360_Licencia__c licencia = new Dan360_Licencia__c(
            Fecha_de_inicio__c = Date.Today().addDays(1),
            Fecha_de_Fin__c = Date.Today().addDays(1),
            Efectividad__c = efectividad.Id,
            Motivo__c = 'Día de estudio',
            Estado__c = 'Pendiente',
            VisMed_APM__c = apm.Id,            
            RecordTypeId = recordTypeLicencia
        );
        insert licencia;

        Id recordTypeProfesionalBaja = [SELECT Id, Name, SobjectType,IsPersonType 
            FROM RecordType 
            WHERE SobjectType='VisMed_Bajas__c' AND Name = 'Profesional de la Salud'].Id;

        VisMed_Bajas__c baja = Build.aVisMedBajasProfesionaldelaSalud()
            .withProfesional(profesional)
            .withVisMedAPM(apm)
            .build();
        baja.RecordTypeId = recordTypeProfesionalBaja;
        insert baja;

        Datetime dt = System.now().addDays(1);
        Date dateVisita;
        System.debug(dt.format('EEEE'));
        if(dt.format('EEEE')== 'Sunday' || dt.format('EEEE')== 'Saturday'){
            System.debug(dt.format('EEEE'));
            dateVisita = dt.date().addDays(2);
        }
        else{
            dateVisita = dt.date();
        }


        Dan360_Interacciones__c visita = Build.aDan360Interacciones()
            .withProfesional(aPersonAccount)
            .withAPM(apm)
            .withVisMedTipodeVisita('Presencial')
            .withVisMedEfectividad(efectividad)
            .withDomiciliodelaVisita(account)
            .withVisMedFecha(dateVisita)
            .build();

            insert visita;
            
            VisMed_Contacto_Cuenta_Usuario__c seguimiento = Build.aVisMedContactCuentaUsuarioBuilder()
                .withAPM(apm)
                .withProfesional(aPersonAccount)
                .withInstitucion(account)
                .withEstado('Pendiente')
                .withSegmentaPor('Adultos General Institucion')
                .build();
            seguimiento.Aprobador_Final__c = userTest.Id;    
            insert seguimiento;
        }
    }
    @isTest
    private static void updateSeguimientoCuandoEsAprobado() {
        // Test data setup
        String objeto = 'VisMed_Contacto_Cuenta_Usuario__c';
        String estado;
        List<String> recordsId = new List<String>();
        VisMed_Contacto_Cuenta_Usuario__c seguimientoToUpdate = [
            SELECT Id, Estado__c 
            FROM VisMed_Contacto_Cuenta_Usuario__c
            WHERE Estado__c = 'Pendiente'
        ];
        recordsId.add(seguimientoToUpdate.id);
        estado = 'Aprobada';
        // Actual test
        Test.startTest();
        List<MassApprovalComponentController.ObjectWrapper> result = MassApprovalComponentController.updateRecord(recordsId, objeto, '', estado, '');
        Test.stopTest();

        System.assertEquals(0, result.size(), 'Error al aprobar Alta');        
    }
    @isTest
    private static void updateSeguimientoCuandoEsRechazado() {
        // Test data setup
        String objeto = 'VisMed_Contacto_Cuenta_Usuario__c';
        String estado;
        List<String> recordsId = new List<String>();
        VisMed_Contacto_Cuenta_Usuario__c seguimientoToUpdate = [
            SELECT Id, Estado__c 
            FROM VisMed_Contacto_Cuenta_Usuario__c
            WHERE Estado__c = 'Pendiente'
        ];
        recordsId.add(seguimientoToUpdate.id);
        estado = 'Rechazado';
        // Actual test
        Test.startTest();
        List<MassApprovalComponentController.ObjectWrapper> result = MassApprovalComponentController.updateRecord(recordsId, objeto, '', estado, '');
        Test.stopTest();

        System.assertEquals(0, result.size(), 'Error al aprobar Alta');        
    }
    @isTest
    private static void getUserDebeDevolverUsuariosRelacionadosAlSupervisor() {
        User userOwner = [
            SELECT Id
            FROM User
            WHERE Alias = 'owner'
        ];
    system.runAs(userOwner){          
        String supervisor = [
            SELECT Id
            FROM User
            WHERE Alias = 'appro' AND Profile.Name = 'Supervisores'
        ].Id;       
        
        // Actual test
        Test.startTest();
        List<user> result = MassApprovalComponentController.getUser(supervisor);
        Test.stopTest();

        System.assertEquals(1, result.size(), 'Error al obtener usuario');  
    }      
    }
    @isTest
    private static void getDataDebeDevolverUnaListaDeFicheros() {
        // Test data setup        
        Id user = UserInfo.getUserId();
        String objeto = 'VisMed_Contacto_Cuenta_Usuario__c';
        List<String> users = new List<String>();
        users.add(user);

        Contact apm = [
            SELECT Id
            FROM Contact
            WHERE VisMed_DNI__c = '23234324'
        ];
       
        // Actual test
        Test.startTest();
        List<MassApprovalComponentController.ObjectWrapper> result = MassApprovalComponentController.getData(objeto,'','',user,users,'','');
        Test.stopTest();

        VisMed_Contacto_Cuenta_Usuario__c seguimiento = [
            SELECT Id
            FROM VisMed_Contacto_Cuenta_Usuario__c
            WHERE VisMed_APM__c = :apm.Id
        ];

        System.assertEquals(1, result.size(), 'Error al obtener data');
        System.assertEquals(seguimiento.Id, result[0].Id, 'Error al obtener seguimiento');       
    }
    @isTest
    private static void getDataDebeDevolverUnaListaDeLicencias() {
        // Test data setup        
        Id user = UserInfo.getUserId();
        String objeto = 'Dan360_Licencia__c';
        List<String> users = new List<String>();
        users.add(user);

        Contact apm = [
            SELECT Id
            FROM Contact
            WHERE VisMed_DNI__c = '23234324'
        ];
       
        // Actual test
        Test.startTest();
        List<MassApprovalComponentController.ObjectWrapper> result = MassApprovalComponentController.getData(objeto,'','',user,users,'','');
        Test.stopTest();

        Dan360_Licencia__c licencia = [
            SELECT Id
            FROM Dan360_Licencia__c
            WHERE VisMed_APM__c = :apm.Id
        ];

        System.assertEquals(1, result.size(), 'Error al obtener data');
        System.assertEquals(licencia.Id, result[0].Id, 'Error al obtener licencia');
    }
    @isTest
    private static void getDataDebeDevolverUnaListaDeVisitas() {
        // Test data setup        
        Id user = UserInfo.getUserId();
        String objeto = 'Dan360_Interacciones__c';
        List<String> users = new List<String>();
        users.add(user);
        
        Contact apm = [
            SELECT Id
            FROM Contact
            WHERE VisMed_DNI__c = '23234324'
        ];
        // Actual test
        Test.startTest();
        List<MassApprovalComponentController.ObjectWrapper> result = MassApprovalComponentController.getData(objeto,'','',user,users,'','');
        Test.stopTest();

        Dan360_Interacciones__c visita = [
            SELECT Id
            FROM Dan360_Interacciones__c
            WHERE VisMed_APM__c = :apm.Id
        ];

        System.assertEquals(1, result.size(), 'Error al obtener data'); 
        System.assertEquals(visita.Id, result[0].Id, 'Error al obtener visita');       
    }
    @isTest
    private static void getDataDebeDevolverUnaListaDeBajas() {
        // Test data setup        
        Id user = UserInfo.getUserId();
        String objeto = 'VisMed_Bajas__c';
        List<String> users = new List<String>();
        users.add(user);
        Contact apm = [
            SELECT Id
            FROM Contact
            WHERE VisMed_DNI__c = '23234324'
        ];
        // Actual test
        Test.startTest();
        List<MassApprovalComponentController.ObjectWrapper> result = MassApprovalComponentController.getData(objeto,'','',user,users,'','');
        Test.stopTest();
        VisMed_Bajas__c baja = [
            SELECT Id
            FROM VisMed_Bajas__c
            WHERE VisMed_APM__c = :apm.Id
        ];
        System.assertEquals(1, result.size(), 'Error al obtener data');
        System.assertEquals(baja.Id, result[0].Id, 'Error al obtener baja');       
    }
}