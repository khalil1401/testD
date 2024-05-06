@IsTest public with sharing class LicenciaTriggerHelperTest {
   @TestSetup
   static void makeData(){
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
            Aprobador_Final__c = userOwner.id,
            RecordTypeId = recordTypeLicencia
        );
        insert licencia;
        Id recordTypeTNP = Schema.SObjectType.Dan360_Licencia__c.getRecordTypeInfosByDeveloperName().get('Tiempo_no_Promocional').getRecordTypeId();
        Dan360_Licencia__c licenciaTNP = new Dan360_Licencia__c(
            Fecha_de_inicio__c = Date.Today().addDays(1),
            Fecha_de_Fin__c = Date.Today().addDays(1),
            Efectividad__c = efectividad.Id,
            Motivo__c = 'Reunión de equipo',
            Estado__c = 'Pendiente',
            VisMed_APM__c = apm.Id,
            Aprobador_Final__c = userOwner.id,
            RecordTypeId = recordTypeTNP,
            Cantidad_de_Horas__c = '1.0'
        );
        insert licenciaTNP;
    }


   }
   @IsTest
   static void cuandoLicenciaEsAprobadaDebeCrearNotificacion(){
    User userOwner = [
            SELECT Id
            FROM User
            WHERE Alias = 'owner'
        ];
    system.runAs(userOwner){        
        Dan360_Licencia__c  licencia = [
            SELECT Id, Estado__c, RecordTypeId, Aprobador_Final_Name__c, Comentario_de_aprobacion__c, Motivo__c, VisMed_APM__c
            FROM Dan360_Licencia__c
            WHERE Estado__c = 'Pendiente' AND Motivo__c = 'Día de estudio'
        ];
        licencia.Estado__c = 'Aprobada';
        Test.startTest();
        update licencia;        
        Test.stopTest();
        Notificacion__c notificacion = [
            SELECT Id, Id_del_Objeto__c, Cuerpo__c, APM__c
            FROM Notificacion__c
            WHERE Id_del_Objeto__c = :licencia.Id
        ];
    
        System.assertEquals(licencia.Id, Notificacion.Id_del_Objeto__c, 'Error al crear la notificacion');
        System.assertEquals(licencia.VisMed_APM__c, Notificacion.APM__c, 'Error al crear la notificacion');       

    }
    
   }
   @IsTest
   static void cuandoLicenciaTNPEsAprobadaDebeCrearNotificacion(){
    User userOwner = [
            SELECT Id
            FROM User
            WHERE Alias = 'owner'
        ];
    system.runAs(userOwner){        
        Dan360_Licencia__c  licenciaTNP = [
            SELECT Id, Estado__c, RecordTypeId, Aprobador_Final_Name__c, Comentario_de_aprobacion__c, Motivo__c, VisMed_APM__c
            FROM Dan360_Licencia__c
            WHERE Estado__c = 'Pendiente' AND Motivo__c = 'Reunión de equipo'
        ];
        licenciaTNP.Estado__c = 'Aprobada';
        Test.startTest();
        update licenciaTNP;        
        Test.stopTest();
        Notificacion__c notificacion = [
            SELECT Id, Id_del_Objeto__c, Cuerpo__c, APM__c
            FROM Notificacion__c
            WHERE Id_del_Objeto__c = :licenciaTNP.Id
        ];
    
        System.assertEquals(licenciaTNP.Id, Notificacion.Id_del_Objeto__c, 'Error al crear la notificacion');
        System.assertEquals(licenciaTNP.VisMed_APM__c, Notificacion.APM__c, 'Error al crear la notificacion');       

    }
    
   }
   @IsTest
   static void noSePuedeCrearDosLicenciasParaLaMismaFecha(){
    User userOwner = [
            SELECT Id
            FROM User
            WHERE Alias = 'owner'
        ];
    system.runAs(userOwner){ 
        Dan360_Licencia__c  licenciaSetup = [
            SELECT Id, Estado__c, RecordTypeId, Aprobador_Final_Name__c, Comentario_de_aprobacion__c, Motivo__c, VisMed_APM__c
            FROM Dan360_Licencia__c
            WHERE Estado__c = 'Pendiente' AND Motivo__c = 'Día de estudio'
        ];
        licenciaSetup.Estado__c = 'Aprobada';
        update licenciaSetup;
    
        Contact apm = [
            SELECT Id
            FROM Contact
            WHERE VisMed_DNI__c = '22222333'
        ];

        Id recordTypeLicencia = Schema.SObjectType.Dan360_Licencia__c.getRecordTypeInfosByDeveloperName().get('Licencia').getRecordTypeId();
        Dan360_Licencia__c licencia = new Dan360_Licencia__c(
            Fecha_de_inicio__c = Date.Today().addDays(1),
            Fecha_de_Fin__c = Date.Today().addDays(1),
            Motivo__c = 'Día de estudio',
            Estado__c = 'Pendiente',
            VisMed_APM__c = apm.Id,
            Aprobador_Final__c = userOwner.id,
            RecordTypeId = recordTypeLicencia
        );
        
        Boolean error = false;
        String expectedException;
        Test.startTest();
        try {
            insert licencia;
        } catch (Exception e) {
            error = true;
            expectedException = e.getMessage();
            System.debug('error message : '+expectedException);
        }
        Test.stopTest();
        System.assertEquals(true, error, 'Error La licencia no deberia crearse');
        System.Assert(expectedException.contains('Esta licencia se superpone con otras'), 'Error La licencia no deberia  crearse');
    }
   }
   @IsTest
   static void cuandoLicenciaEsPorDiaFestivoSeApruebaAutomaticamente(){
    User userOwner = [
            SELECT Id
            FROM User
            WHERE Alias = 'owner'
        ];
    system.runAs(userOwner){ 
        
        Contact apm = [
            SELECT Id
            FROM Contact
            WHERE VisMed_DNI__c = '22222333'
        ];

        Dan360_Efectividad__c efectividad = [
            SELECT Id
            FROM Dan360_Efectividad__c
            WHERE Fecha_de_inicio__c = :Date.Today().toStartOfMonth()
        ];       

        Id recordTypeLicencia = Schema.SObjectType.Dan360_Licencia__c.getRecordTypeInfosByDeveloperName().get('Licencia').getRecordTypeId();
        Dan360_Licencia__c licencia = new Dan360_Licencia__c(
            Fecha_de_inicio__c = Date.Today().addDays(4),
            Fecha_de_Fin__c = Date.Today().addDays(5),
            Efectividad__c = efectividad.Id,
            Motivo__c = 'Festivo',           
            VisMed_APM__c = apm.Id,
            Aprobador_Final__c = userOwner.id,
            RecordTypeId = recordTypeLicencia
        );
              
        Test.startTest();
        insert licencia;
        Test.stopTest();
        Dan360_Licencia__c  licenciaToCompare = [
            SELECT Id, Estado__c, RecordTypeId, Aprobador_Final_Name__c, Comentario_de_aprobacion__c, Motivo__c, VisMed_APM__c
            FROM Dan360_Licencia__c
            WHERE Id = :licencia.Id
        ];
        System.assertEquals(licencia.Id, licenciaToCompare.id, 'Error al crear la licencia');        
    }
   }
//    @IsTest
//    static void cuandoSeCreaLicenciaSinEfectividadRelacionadaSeDebeCrearUna(){
//     User userOwner = [
//             SELECT Id
//             FROM User
//             WHERE Alias = 'owner'
//         ];
//     system.runAs(userOwner){ 
//         Dan360_Licencia__c  licenciaSetup = [
//             SELECT Id, Estado__c, RecordTypeId, Aprobador_Final_Name__c, Comentario_de_aprobacion__c, Motivo__c, VisMed_APM__c
//             FROM Dan360_Licencia__c
//             WHERE Estado__c = 'Pendiente' AND Motivo__c = 'Día de estudio'
//         ];
//         licenciaSetup.Estado__c = 'Aprobada';
//         update licenciaSetup;
    
//         Contact apm = [
//             SELECT Id
//             FROM Contact
//             WHERE VisMed_DNI__c = '22222333'
//         ];
//         Date pastMonth = Date.today().addMonths(-7);
//         VisMed_Ciclo__c ciclo = Build.aCiclo()
//         .withFechaInicio(pastMonth.toStartOfMonth())
//         .withFechaFin(pastMonth.toStartOfMonth().addMonths(1).addDays(-1))
//         .build();
//         insert ciclo;

//         System.debug(pastMonth);

//         Id recordTypeLicencia = Schema.SObjectType.Dan360_Licencia__c.getRecordTypeInfosByDeveloperName().get('Licencia').getRecordTypeId();
//         Dan360_Licencia__c licencia = new Dan360_Licencia__c(
//             Fecha_de_inicio__c = pastMonth.addDays(7),
//             Fecha_de_Fin__c = pastMonth.addMonths(-7).addDays(16),
//             Motivo__c = 'Vacaciones',
//             Estado__c = 'Pendiente',
//             VisMed_APM__c = apm.Id,
//             Aprobador_Final__c = userOwner.id,
//             RecordTypeId = recordTypeLicencia
//         );  
        
//         List<Dan360_Efectividad__c> efec = [SELECT Id, Name, Fecha_de_inicio__c, Fecha_de_Fin__c, VisMed_APM__c, VisMed_Ciclo__c
//             FROM Dan360_Efectividad__c
//             WHERE Fecha_de_inicio__c <= :licencia.Fecha_de_inicio__c AND Fecha_de_Fin__c >= :licencia.Fecha_de_fin__c AND VisMed_APM__c = :licencia.VisMed_APM__c];

//         System.assertEquals(0, efec.size(), 'Error no deberia haber efectividad');
//         Test.startTest();        
//             insert licencia;        
//         Test.stopTest();

//         Dan360_Licencia__c  licenciaToCompare = [
//             SELECT Id, Estado__c, RecordTypeId, Efectividad__c,Aprobador_Final_Name__c, Comentario_de_aprobacion__c, Motivo__c, VisMed_APM__c
//             FROM Dan360_Licencia__c
//             WHERE Id = :licencia.Id
//         ];
//         List<Dan360_Efectividad__c> efectividades = [SELECT Id, Name, Fecha_de_inicio__c, Fecha_de_Fin__c, VisMed_APM__c, VisMed_Ciclo__c
//                                                      FROM Dan360_Efectividad__c
//                                                      WHERE Fecha_de_inicio__c <= :licencia.Fecha_de_inicio__c AND Fecha_de_Fin__c >= :licencia.Fecha_de_fin__c AND VisMed_APM__c = :licencia.VisMed_APM__c];
//         System.assertNotEquals(null,licenciaToCompare.Efectividad__c, 'Error al crear efectividad en la licencia');
//         System.assertEquals(licenciaToCompare.Efectividad__c, efectividades[0].Id, 'Error al crear la efectividad en la licencia');
        
//     }
//    }
   @IsTest
   static void cuandoLicenciaOcupaDosMesesDistintosSeDebenGenerarDosLicenciasDistintas(){
    User userOwner = [
            SELECT Id
            FROM User
            WHERE Alias = 'owner'
        ];
    system.runAs(userOwner){ 
            
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

        Date nextMonth = Date.today().addMonths(1);
        VisMed_Ciclo__c ciclo = Build.aCiclo()
        .withFechaInicio(nextMonth.toStartOfMonth())
        .withFechaFin(nextMonth.toStartOfMonth().addMonths(1).addDays(-1))
        .build();
        insert ciclo;
        Dan360_Efectividad__c efectividad = Build.aDan360Efectividad()
        .withVisMedAPM(apm)
        .withVisMedCiclo(ciclo)
        .build();
        efectividad.Fecha_de_Fin__c = nextMonth.toStartOfMonth();
        efectividad.Fecha_de_inicio__c = nextMonth.toStartOfMonth().addMonths(1).addDays(-1);
        insert efectividad;

        Id recordTypeLicencia = Schema.SObjectType.Dan360_Licencia__c.getRecordTypeInfosByDeveloperName().get('Licencia').getRecordTypeId();
        Dan360_Licencia__c licencia = new Dan360_Licencia__c(
            Fecha_de_inicio__c = Date.Today(),
            Fecha_de_Fin__c = Date.Today().addDays(32),
            Motivo__c = 'Vacaciones',
            Estado__c = 'Pendiente',
            VisMed_APM__c = apm.Id,
            Aprobador_Final__c = userOwner.id,
            RecordTypeId = recordTypeLicencia
        );  
                
        Test.startTest();        
            insert licencia;        
        Test.stopTest();

        List<Dan360_Licencia__c>  licenciaToCompare = [
            SELECT Id, Estado__c, RecordTypeId, Efectividad__c,Aprobador_Final_Name__c, Comentario_de_aprobacion__c, Motivo__c, VisMed_APM__c
            FROM Dan360_Licencia__c
            WHERE VisMed_APM__c = :apm.Id
        ];
        
        //System.assertNotEquals(null,licenciaToCompare.Efectividad__c, 'Error al crear efectividad en la licencia');
        System.assertEquals(2, licenciaToCompare.size(), 'Error al crear la efectividad en la licencia');
        
    }
   }

   @IsTest
   static void cuandoSeEliminaLicenciaSeDebenActualizarLosDiasTranscurridos(){
    User userOwner = [
            SELECT Id
            FROM User
            WHERE Alias = 'owner'
        ];
    system.runAs(userOwner){        
        Dan360_Licencia__c  licencia = [
            SELECT Id, Estado__c, RecordTypeId, Aprobador_Final_Name__c, Comentario_de_aprobacion__c, Motivo__c, VisMed_APM__c
            FROM Dan360_Licencia__c
            WHERE Estado__c = 'Pendiente' AND Motivo__c = 'Día de estudio'
        ];
        
        Test.startTest();
        delete licencia;        
        Test.stopTest();
        List<Dan360_Efectividad__c> efectividades = [SELECT Id, Name, Fecha_de_inicio__c, Fecha_de_Fin__c, VisMed_APM__c, VisMed_Ciclo__c, Dias_de_Licencia_Transcurridos__c
                                                     FROM Dan360_Efectividad__c
                                                     WHERE VisMed_APM__c = :licencia.VisMed_APM__c];
    
        System.assertEquals(0, efectividades[0].Dias_de_Licencia_Transcurridos__c, 'Error al crear la notificacion');              

    }
    
   }
   
}