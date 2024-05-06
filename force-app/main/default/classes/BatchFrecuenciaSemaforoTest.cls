@isTest
public with sharing class BatchFrecuenciaSemaforoTest {
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

            Account profesional3 = Build.aPersonalAccount()
            .withFirstName('Profesional3')           
            .build();
            profesional3.LastName = 'Test3';
            profesional3.RecordTypeId = recordTypeProfesional;
            insert profesional3;

            Account profesional4 = Build.aPersonalAccount()
            .withFirstName('Profesional4')           
            .build();
            profesional4.LastName = 'Test4';
            profesional4.RecordTypeId = recordTypeProfesional;
            insert profesional4;
        
            Dan360_Efectividad__c efectividad = Build.aDan360Efectividad()
            .withVisMedAPM(apm)
            .withVisMedCiclo(ciclo)
            .build();
            efectividad.Fecha_de_inicio__c = Date.today().toStartOfMonth();
            efectividad.Fecha_de_Fin__c = Date.today().toStartOfMonth().addMonths(1).addDays(-1);
            insert efectividad;

            VisMed_Contacto_Cuenta_Usuario__c ficheroFrecuenciaDecimalMenorAUno = Build.aVisMedContactCuentaUsuarioBuilder()
                .withAPM(apm)
                .withInstitucion(institucion)
                .withProfesional(profesional) 
                .withSegmentaPor('Alergia') //frecuencia 0,5          
                .build();
            ficheroFrecuenciaDecimalMenorAUno.Predeterminada__c = true;            
            ficheroFrecuenciaDecimalMenorAUno.Estado__c = 'Activo';            
            insert ficheroFrecuenciaDecimalMenorAUno;

            VisMed_Contacto_Cuenta_Usuario__c ficheroFrecuenciaEntera = Build.aVisMedContactCuentaUsuarioBuilder()
                .withAPM(apm)
                .withInstitucion(institucion2)
                .withProfesional(profesional2)
                .withSegmentaPor('Metabolicos')   // frecuencia 1.0             
                .build();
            ficheroFrecuenciaEntera.Estado_de_aprobacion__c = 'Aprobada';
            ficheroFrecuenciaEntera.Estado__c = 'Activo';           
            insert ficheroFrecuenciaEntera;
            VisMed_Contacto_Cuenta_Usuario__c ficheroFrecuenciaDecimalMayorAUno = Build.aVisMedContactCuentaUsuarioBuilder()
                .withAPM(apm)
                .withInstitucion(institucion2)
                .withProfesional(profesional3)
                .withSegmentaPor('Pediatricos General')   // frecuencia 1.5            
                .build();
            ficheroFrecuenciaDecimalMayorAUno.Estado_de_aprobacion__c = 'Aprobada';
            ficheroFrecuenciaDecimalMayorAUno.Estado__c = 'Activo';           
            insert ficheroFrecuenciaDecimalMayorAUno;
            VisMed_Contacto_Cuenta_Usuario__c ficheroSinFrecuencia = Build.aVisMedContactCuentaUsuarioBuilder()
                .withAPM(apm)
                .withInstitucion(institucion)
                .withProfesional(profesional4)
                  // Sin frecuencia            
                .build();
            ficheroSinFrecuencia.Estado_de_aprobacion__c = 'Aprobada';
            ficheroSinFrecuencia.Estado__c = 'Activo';           
            insert ficheroSinFrecuencia;
        }
    }
    @isTest
    private static void whenExecuteBatchFrecuenciaSemaforoMustSetFrecuenciaAunQuedanMesesSemaforoAndVisitasRealizadas() {
        
        
        // Actual test
        Test.startTest();
        BatchFrecuenciaSemaforo batch = new BatchFrecuenciaSemaforo();
        Database.executeBatch(batch);
        Test.stopTest();
        
        List<VisMed_Contacto_Cuenta_Usuario__c> ficherosToCompare = [
            SELECT ID, Segmenta_Por__c,Visitas_Realizadas__c, Segmenta_Anterior__c,VisMed_Semaforo__c, Frecuencia__c, Inicio_de_Frecuencia__c,Fin_de_Frecuencia__c,Aun_Quedan_Meses__c
            FROM VisMed_Contacto_Cuenta_Usuario__c            
            ];
        for (VisMed_Contacto_Cuenta_Usuario__c fichero : ficherosToCompare) {
            if (fichero.Frecuencia__c != null) {
                System.assertEquals('Rojo', fichero.VisMed_Semaforo__c, 'Error al establecer Semaforo Rojo con frecuencia');
            }else {
                System.assertEquals('Gris', fichero.VisMed_Semaforo__c, 'Error al establecer Semaforo Gris sin frecuencia');
            }
            System.assertEquals(0, fichero.Visitas_Realizadas__c, 'Error al establecer visitas realizadas a 0');
        }
    }
    @isTest
    private static void whenIsTheEndOfFrecuencyMustSetTheNewPeriodOfFrecuency() {
        VisMed_Contacto_Cuenta_Usuario__c ficheroFrecuenciaDecimalMayorAUno = [
            SELECT ID, Segmenta_Por__c,Visitas_Realizadas__c, Segmenta_Anterior__c,VisMed_Semaforo__c, Frecuencia__c, Inicio_de_Frecuencia__c,Fin_de_Frecuencia__c,Aun_Quedan_Meses__c
            FROM VisMed_Contacto_Cuenta_Usuario__c
            WHERE Segmenta_Por__c = 'Pediatricos General'
        ];
        ficheroFrecuenciaDecimalMayorAUno.Inicio_de_Frecuencia__c = Date.today().toStartOfMonth().addMonths(-3);
        ficheroFrecuenciaDecimalMayorAUno.Fin_de_Frecuencia__c = Date.today().toStartOfMonth().addMonths(-1).addDays(-1);
        update ficheroFrecuenciaDecimalMayorAUno;
        // Actual test
        Test.startTest();
        BatchFrecuenciaSemaforo batch = new BatchFrecuenciaSemaforo();
        Database.executeBatch(batch);
        Test.stopTest();
        
        VisMed_Contacto_Cuenta_Usuario__c ficherosToCompare = [
            SELECT ID,Visitas_Realizadas__c,Visitas_acumuladas__c ,VisMed_Semaforo__c, Frecuencia__c, Inicio_de_Frecuencia__c,Fin_de_Frecuencia__c,Aun_Quedan_Meses__c
            FROM VisMed_Contacto_Cuenta_Usuario__c
            WHERE Id = :ficheroFrecuenciaDecimalMayorAUno.Id            
            ];
        
        System.assertEquals('Rojo', ficherosToCompare.VisMed_Semaforo__c, 'Error al establecer Semaforo Rojo');
        System.assertEquals(Date.today().toStartOfMonth(), ficherosToCompare.Inicio_de_Frecuencia__c, 'Error al establecer inicio de frecuencia');
        System.assertEquals(Date.today().toStartOfMonth().addMonths(2).addDays(-1), ficherosToCompare.Fin_de_Frecuencia__c, 'Error al establecer final de frecuencia');
        System.assertEquals(true, ficherosToCompare.Aun_Quedan_Meses__c, 'Error al establecer final de frecuencia');
        System.assertEquals(0, ficherosToCompare.Visitas_Realizadas__c, 'Error al establecer visitas Realizadas');
        System.assertEquals(0, ficherosToCompare.Visitas_acumuladas__c, 'Error al establecer visitas totales ante del ultimo mes');
               
    }
    @isTest
    private static void whenIsTheLastMonthOfFrecuencyMustSetAunQuedanMesesInFalse() {
        VisMed_Contacto_Cuenta_Usuario__c ficheroFrecuenciaDecimalMayorAUno = [
            SELECT ID, Segmenta_Por__c,Visitas_Realizadas__c, Segmenta_Anterior__c,VisMed_Semaforo__c, Frecuencia__c, Inicio_de_Frecuencia__c,Fin_de_Frecuencia__c,Aun_Quedan_Meses__c
            FROM VisMed_Contacto_Cuenta_Usuario__c
            WHERE Segmenta_Por__c = 'Pediatricos General'
        ];
        
        ficheroFrecuenciaDecimalMayorAUno.Inicio_de_Frecuencia__c = Date.today().toStartOfMonth().addMonths(-1);
        ficheroFrecuenciaDecimalMayorAUno.Fin_de_Frecuencia__c = Date.today().toStartOfMonth().addMonths(1).addDays(-1);
        ficheroFrecuenciaDecimalMayorAUno.Visitas_Realizadas__c = 2;
        update ficheroFrecuenciaDecimalMayorAUno;
        // Actual test
        Test.startTest();
        BatchFrecuenciaSemaforo batch = new BatchFrecuenciaSemaforo();
        Database.executeBatch(batch);
        Test.stopTest();
        
        VisMed_Contacto_Cuenta_Usuario__c ficherosToCompare = [
            SELECT ID,Visitas_Realizadas__c,Visitas_acumuladas__c ,VisMed_Semaforo__c, Frecuencia__c, Inicio_de_Frecuencia__c,Fin_de_Frecuencia__c,Aun_Quedan_Meses__c
            FROM VisMed_Contacto_Cuenta_Usuario__c
            WHERE Id = :ficheroFrecuenciaDecimalMayorAUno.Id            
            ];
               
        System.assertEquals(false, ficherosToCompare.Aun_Quedan_Meses__c, 'Error al establecer final de frecuencia');
        System.assertEquals(0, ficherosToCompare.Visitas_Realizadas__c, 'Error al establecer visitas Realizadas');
        System.assertEquals(2, ficherosToCompare.Visitas_acumuladas__c, 'Error al establecer visitas totales ante del ultimo mes');
               
    }
}