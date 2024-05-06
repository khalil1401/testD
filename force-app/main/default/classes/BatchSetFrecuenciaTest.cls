@isTest public with sharing class BatchSetFrecuenciaTest {
    @TestSetup
	public static void makeData() {
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
            Account institucion = Build.anAccount()
                .withName('InstitucionTest')
                .build();
            insert institucion;

            Account institucion2 = Build.anAccount()
            .withName('InstitucionTest2')
            .build();
            insert institucion2;
                   
            Id recordTypeVisitadorMedico = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Visitador_Medico').getRecordTypeId();
            Contact apm = Build.aContactVisitadorMedico()
            .withAccount(institucion)            
            .build();
            apm.VisMed_DNI__c = '22222333';
            apm.RecordTypeId = recordTypeVisitadorMedico;
            apm.Sub_Equipo__c = 'Metabolicos';
            insert apm;
                
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
            userTest.VisMed_ContrasenaApp__c = 'Test';
            userTest.ManagerId = userOwner.Id;
            userTest.DelegatedApproverId = userOwner.Id;

            insert userTest;
                
            Date today = Date.today();
            VisMed_Ciclo__c ciclo = Build.aCiclo()
            .withFechaInicio(today.toStartOfMonth())
            .withFechaFin(today.toStartOfMonth().addMonths(1).addDays(-1))
            .build();
            insert ciclo;

            Id recordTypeProfesional = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Profesional_de_la_Salud').getRecordTypeId();
            System.debug(recordTypeProfesional);
                        
            Account profesional = Build.aPersonalAccount()
            .withFirstName('Profesional')           
            .build();
            profesional.LastName = 'Test';
            profesional.RecordTypeId = recordTypeProfesional;
            insert profesional;
            Account profesional2 = Build.aPersonalAccount()
            .withFirstName('Profesional2')           
            .build();
            profesional2.LastName = 'Test2';
            Profesional2.KOL__c = 'KOL Nicho';
            profesional2.RecordTypeId = recordTypeProfesional;
            insert profesional2;
        
            Dan360_Efectividad__c efectividad = Build.aDan360Efectividad()
            .withVisMedAPM(apm)
            .withVisMedCiclo(ciclo)
            .build();
            efectividad.Fecha_de_inicio__c = Date.today().toStartOfMonth();
            efectividad.Fecha_de_Fin__c = Date.today().toStartOfMonth().addMonths(1).addDays(-1);
            insert efectividad;

            VisMed_Contacto_Cuenta_Usuario__c seg = Build.aVisMedContactCuentaUsuarioBuilder()
                .withAPM(apm)
                .withInstitucion(institucion)
                .withProfesional(profesional) 
                .withSegmentaPor('Alergia')               
                .build();
            seg.Predeterminada__c = true;            
            seg.Estado__c = 'Activo';
            seg.Actualizar_Frecuencia__c = true;         
            insert seg;

            VisMed_Contacto_Cuenta_Usuario__c seg2 = Build.aVisMedContactCuentaUsuarioBuilder()
                .withAPM(apm)
                .withInstitucion(institucion2)
                .withProfesional(profesional2)
                .withSegmentaPor('Metabolicos')                
                .build();
            seg2.Estado_de_aprobacion__c = 'Aprobada';
            seg2.Estado__c = 'Activo';
            seg2.Actualizar_Frecuencia__c = true;      
            insert seg2;
        }
    }
    @isTest
    private static void whenExecuteBatchSetFrecuenciaMustUpdateFrecuenciaAndCategiriaOfFicherosUpdatedTheLastMonth() {
        // Test data setup
        List<VisMed_Contacto_Cuenta_Usuario__c> ficherosToUpdate = new List<VisMed_Contacto_Cuenta_Usuario__c>();
        List<VisMed_Contacto_Cuenta_Usuario__c> ficheros = [
            SELECT ID, Segmenta_Por__c, Fecha_de_Aprobacion__c
            FROM VisMed_Contacto_Cuenta_Usuario__c
            ];
        Set<Id> ficheroId = new Set<Id>();
        System.debug(ficheros.size());
        DateTime fechaAprobacion = DateTime.now().addMonths(-1);
        for (VisMed_Contacto_Cuenta_Usuario__c fichero : ficheros) {
            fichero.Segmenta_Por__c = 'Pediatricos General';            
            Test.setCreatedDate(fichero.Id, fechaAprobacion);
            ficherosToUpdate.add(fichero);
            ficheroId.add(fichero.Id);

        }
        update ficherosToUpdate;
        // Actual test
        Test.startTest();
        BatchSetFrecuencia batch = new BatchSetFrecuencia();
        Database.executeBatch(batch);
        Test.stopTest();
        
        List<VisMed_Contacto_Cuenta_Usuario__c> ficherosToCompare = [
            SELECT ID, Segmenta_Por__c, Segmenta_Anterior__c, Frecuencia__c, Categoria__c, Fecha_de_Aprobacion__c, Actualizar_Frecuencia__c
            FROM VisMed_Contacto_Cuenta_Usuario__c
            WHERE id in :ficheroId
            ];
        System.debug(ficherosToCompare);
        // Asserts
        System.assertEquals(0.5, ficherosToCompare[0].Frecuencia__c, 'Error al  obtener frecuencia');
        System.assertEquals('D', ficherosToCompare[0].Categoria__c, 'Error al  obtener categoria');
        System.assertEquals('Pediatricos General', ficherosToCompare[0].Segmenta_Anterior__c, 'Error al  setear segmenta anterior');
        System.assertEquals(false, ficherosToCompare[0].Actualizar_Frecuencia__c, 'Error al  setear Actualizar Frecuencia');
    }
}