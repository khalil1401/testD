@isTest
public with sharing class EfectividadTriggerHelperTest {
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
    
        Id recordTypeVisitadorMedico = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Visitador_Medico').getRecordTypeId();
        Contact apm = Build.aContactVisitadorMedico()
        .withAccount(institucion)            
        .build();
        apm.VisMed_DNI__c = '22222333';
        apm.RecordTypeId = recordTypeVisitadorMedico;
        apm.Sub_Equipo__c = 'Metabólicos y Dieta';
        insert apm;

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
                .withProfileId(apmPerfil.Id)
                .withLanguageLocaleKey('es')
                .build();

            userTest.IsActive = true;
            userTest.VisMed_Es_un_Visitador_Medico__c = true;
            //userTest.IsPortalEnabled = true;
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

        }
    }
    @isTest
    private static void cuandoSeCreaEfectividadDebeLLenarElCampoDeVisistasRestantes() {
        // Test data setup
        VisMed_Ciclo__c ciclo = [
            SELECT Id
            FROM VisMed_Ciclo__c
            WHERE Fecha_de_inicio__c = :Date.today().toStartOfMonth()
        ];

        Contact apm = [
            SELECT Id
            FROM Contact
            WHERE VisMed_DNI__c = '22222333'
        ];
    
        Dan360_Efectividad__c efectividad = Build.aDan360Efectividad()
            .withVisMedAPM(apm)
            .withVisMedCiclo(ciclo)
            .build();
        efectividad.Fecha_de_inicio__c = Date.today().toStartOfMonth();
        efectividad.Fecha_de_Fin__c = Date.today().toStartOfMonth().addMonths(1).addDays(-1);
        
        // Actual test
        Test.startTest();
            insert efectividad;
        Test.stopTest();

        Dan360_Efectividad__c efecToCompare = [
            SELECT Id, VisMed_Visitas_restantes__c 
            FROM Dan360_Efectividad__c
            WHERE VisMed_APM__c = :apm.Id AND VisMed_Ciclo__c = :ciclo.Id 
        ];
    
        // Asserts
        System.assertNotEquals(null, efecToCompare.VisMed_Visitas_restantes__c, 'Error al crear las visitas restantes');
        System.assertEquals(efectividad.Id, efecToCompare.Id, 'Error al crear la efectividad');
        
    }
   
   // @isTest
    private static void cuandoSeCreaEfectividadSinCicloDebeGenerarError() {
        // Test data setup
        VisMed_Ciclo__c ciclo = [
            SELECT Id
            FROM VisMed_Ciclo__c
            WHERE Fecha_de_inicio__c = :Date.today().toStartOfMonth()
        ];

        Contact apm = [
            SELECT Id
            FROM Contact
            WHERE VisMed_DNI__c = '22222333'
        ];
    
        Dan360_Efectividad__c efectividad = Build.aDan360Efectividad()
            .withVisMedAPM(apm)
            //.withVisMedCiclo(ciclo)
            .build();
        efectividad.Fecha_de_Fin__c = Date.today().toStartOfMonth().addMonths(1);
        efectividad.Fecha_de_inicio__c = Date.today().toStartOfMonth().addMonths(2).addDays(-1);
        
        Boolean error = false;
        String expectedException;
        Test.startTest();
        try {
            insert efectividad;
        } catch (Exception e) {
            error = true;
            expectedException = e.getMessage();
        }
        Test.stopTest();
        System.assertEquals(true, error, 'Error La Efectividad no deberia crearse');
       // System.Assert(expectedException.contains('Argument cannot be null'), 'Error La Efectividad no deberia  crearse');
        
    }
}