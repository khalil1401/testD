@IsTest public with sharing class ObjetivoTriggerHelperTest {
    @testSetup
    public static void testSetup() {
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
         
             Id recordTypeVisitadorMedico = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Visitador_Medico').getRecordTypeId();
             Contact apm = Build.aContactVisitadorMedico()
             .withAccount(institucion)            
             .build();
             apm.VisMed_DNI__c = '22222333';
             apm.RecordTypeId = recordTypeVisitadorMedico;
             apm.Sub_Equipo__c = 'Metabólicos y Dieta';
             insert apm;
 
             VisMed_Objetivo__c obj = Build.aVisMedObjetivo()
                 .withName('Objetivo Test')
                 .withVisMedFechaInicio(Date.today().toStartOfMonth())
                 .withVisMedFechaFin(Date.Today().addMonths(3))
                 .build();
             insert obj;
 
             VisMed_Accion__c accion = Build.aVisMedAccion()
                 .withVisMedObjetivo(obj)
                 .withVisMedFechaInicio(Date.today().addDays(4))
                 .withVisMedFechaFin(Date.today().addDays(30))        
                 .build();
             insert accion;
             
             VisMed_ObjetivoPorCuenta__c objXCuenta = Build.aVisMedObjetivoPorCuenta()
                 .withVisMedObjetivo(obj)
                 .withVisMedAPM(userOwner)
                 .build();
             insert objXCuenta;
 
             VisMed_AccionPorCuenta__c accionPorCuenta = Build.aVisMedAccionPorCuenta()
                 .withVisMedObjetivo(obj)
                 .withVisMedObjetivoPorCuenta(objXCuenta)
                 .withVisMedAccion(accion)
                 .withVisMedAPM(userOwner)
                 .build();
             insert accionPorCuenta;
         }
    }
    @IsTest
   public static void cuandoSeCreaObjetivoSeDebeSetearElCampoEstadoSegunLasFechasEnActivo(){
    
    VisMed_Objetivo__c obj = Build.aVisMedObjetivo()
        .withName('Objetivo Test')
        .withVisMedFechaInicio(Date.today().toStartOfMonth())
        .withVisMedFechaFin(Date.Today().addMonths(3))
        .build();
        
    Test.startTest();    
    insert obj;
    Test.stopTest();
    VisMed_Objetivo__c objToCompare = [
        SELECT Id, Estado__c
        FROM VisMed_Objetivo__c
        WHERE Id = :obj.Id
    ];
    System.assertEquals('Activo', objToCompare.Estado__c, 'Error al activar objetivo');
   }
    @IsTest
   public static void cuandoSeModificaObjetivoSeDebeSetearElCampoEstadoSegunLasFechasEnActivo(){
    
    VisMed_Objetivo__c obj = [
        SELECT Id, VisMed_FechaFin__c, Estado__c
        FROM VisMed_Objetivo__c
        WHERE VisMed_FechaInicio__c = :Date.today().toStartOfMonth()
    ];

    obj.VisMed_FechaFin__c = Date.Today().addMonths(1);
        
    Test.startTest();    
    update obj;
    Test.stopTest();
    VisMed_Objetivo__c objToCompare = [
        SELECT Id, Estado__c
        FROM VisMed_Objetivo__c
        WHERE Id = :obj.Id
    ];
    System.assertEquals('Activo', objToCompare.Estado__c, 'Error al activar objetivo');
   }
    @IsTest
   public static void cuandoSeCreaObjetivoSeDebeSetearElCampoEstadoSegunLasFechasEnInactivo(){
    
    VisMed_Objetivo__c obj = Build.aVisMedObjetivo()
        .withName('Objetivo Test')
        .withVisMedFechaInicio(Date.today().addMonths(4))
        .withVisMedFechaFin(Date.Today().addMonths(6))
        .build();
        
    Test.startTest();    
    insert obj;
    Test.stopTest();
    VisMed_Objetivo__c objToCompare = [
        SELECT Id, Estado__c
        FROM VisMed_Objetivo__c
        WHERE Id = :obj.Id
    ];
    System.assertEquals('Inactivo', objToCompare.Estado__c, 'Error al activar objetivo');
   }
    @IsTest
   public static void cuandoSeModificaObjetivoSiEstadoEsActivoDebeActivarElObjetivoXCuenta(){
    
    VisMed_Objetivo__c obj = [
        SELECT Id, Estado__c
        FROM VisMed_Objetivo__c
        WHERE VisMed_FechaInicio__c = :Date.today().toStartOfMonth()
    ];    
    obj.Estado__c = 'Activo';
    
    Test.startTest();
    update obj;
    Test.stopTest();
    VisMed_ObjetivoPorCuenta__c objXCuenta = [
        SELECT Id, Estado__c
        FROM VisMed_ObjetivoPorCuenta__c
        WHERE VisMed_Objetivo__c = :obj.Id
    ];
    System.assertEquals('Activo', objXCuenta.Estado__c, 'Error al activar objetivo por cuenta');
   }
   @IsTest
   public static void cuandoSeModificaObjetivoSeDebeSetearElCampoEstadoSegunLasFechasEnInactivo(){
    
    VisMed_Objetivo__c obj = [
        SELECT Id, VisMed_FechaInicio__c, Estado__c
        FROM VisMed_Objetivo__c
        WHERE VisMed_FechaInicio__c = :Date.today().toStartOfMonth()
    ];

    obj.VisMed_FechaInicio__c = Date.Today().addMonths(1);
        
    Test.startTest();    
    update obj;
    Test.stopTest();
    VisMed_Objetivo__c objToCompare = [
        SELECT Id, Estado__c
        FROM VisMed_Objetivo__c
        WHERE Id = :obj.Id
    ];
    System.assertEquals('Inactivo', objToCompare.Estado__c, 'Error al activar objetivo');
   }
    @IsTest
   public static void cuandoSeModificaObjetivoSiEstadoEsInactivoDebeInactivarElObjetivoXCuenta(){
    
    VisMed_Objetivo__c obj = [
        SELECT Id, Estado__c
        FROM VisMed_Objetivo__c
        WHERE VisMed_FechaInicio__c = :Date.today().toStartOfMonth()
    ];    
    obj.Estado__c = 'Inactivo';
    
    Test.startTest();
    update obj;
    Test.stopTest();
    VisMed_ObjetivoPorCuenta__c objXCuenta = [
        SELECT Id, Estado__c
        FROM VisMed_ObjetivoPorCuenta__c
        WHERE VisMed_Objetivo__c = :obj.Id
    ];
    System.assertEquals('Inactivo', objXCuenta.Estado__c, 'Error al activar objetivo por cuenta');
   }

}