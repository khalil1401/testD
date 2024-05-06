@IsTest 
public class AccionTriggerHelperTest {
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
   public static void cuandoSeCreaAccionSeDebeSetearElCampoEstadoSegunLasFechasEnActivo(){
    
    VisMed_Objetivo__c obj = Build.aVisMedObjetivo()
        .withName('Objetivo Test')
        .withVisMedFechaInicio(Date.today().toStartOfMonth())
        .withVisMedFechaFin(Date.Today().addMonths(3))
        .build();
    insert obj;
        
    VisMed_Accion__c accion = Build.aVisMedAccion()
        .withVisMedObjetivo(obj)
        .withVisMedFechaInicio(Date.today())
        .withVisMedFechaFin(Date.today().addDays(30))        
        .build();
    
    Test.startTest();    
    insert accion;
    Test.stopTest();
    VisMed_Accion__c accToCompare = [
        SELECT Id, Estado__c
        FROM VisMed_Accion__c
        WHERE Id = :accion.Id
    ];
    System.assertEquals('Activo', accToCompare.Estado__c, 'Error al activar accion');
   }
    @IsTest
   public static void cuandoSeModificaAccionSeDebeSetearElCampoEstadoSegunLasFechasEnActivo(){
    
    VisMed_Accion__c accion = [
        SELECT Id, VisMed_FechaInicio__c, Estado__c
        FROM VisMed_Accion__c
        WHERE VisMed_FechaInicio__c = :Date.today().addDays(4)
    ];

    accion.VisMed_FechaInicio__c = Date.Today();
        
    Test.startTest();    
    update accion;
    Test.stopTest();
    VisMed_Accion__c accToCompare = [
        SELECT Id, Estado__c
        FROM VisMed_Accion__c
        WHERE Id = :accion.Id
    ];
    System.assertEquals('Activo', accToCompare.Estado__c, 'Error al activar accion');
   }
    @IsTest
   public static void cuandoSeCreaAccionSeDebeSetearElCampoEstadoSegunLasFechasEnInactivo(){
    
    VisMed_Objetivo__c obj = Build.aVisMedObjetivo()
        .withName('Objetivo Test')
        .withVisMedFechaInicio(Date.today().toStartOfMonth())
        .withVisMedFechaFin(Date.Today().addMonths(3))
        .build();
    insert obj;
        
    VisMed_Accion__c accion = Build.aVisMedAccion()
        .withVisMedObjetivo(obj)
        .withVisMedFechaInicio(Date.today().addDays(3))
        .withVisMedFechaFin(Date.today().addDays(30))        
        .build();
    
    Test.startTest();    
    insert accion;
    Test.stopTest();
    VisMed_Accion__c accToCompare = [
        SELECT Id, Estado__c
        FROM VisMed_Accion__c
        WHERE Id = :accion.Id
    ];
    System.assertEquals('Inactivo', accToCompare.Estado__c, 'Error al activar accion');
   }
    @IsTest
   public static void cuandoSeModificaAccionSeDebeSetearElCampoEstadoSegunLasFechasEnInactivo(){
    
    VisMed_Accion__c accion = [
        SELECT Id, VisMed_FechaInicio__c, Estado__c
        FROM VisMed_Accion__c
        WHERE VisMed_FechaInicio__c = :Date.today().addDays(4)
    ];

    accion.VisMed_FechaInicio__c = Date.Today().addDays(1);
        
    Test.startTest();    
    update accion;
    Test.stopTest();
    VisMed_Accion__c accToCompare = [
        SELECT Id, Estado__c
        FROM VisMed_Accion__c
        WHERE Id = :accion.Id
    ];
    System.assertEquals('Inactivo', accToCompare.Estado__c, 'Error al activar accion');
   }
    @IsTest
   public static void cuandoSeModificaAccionSiEstadoEsActivoDebeActivarElObjetivoXCuenta(){
    
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
   public static void cuandoSeModificaAccionSiEstadoEsActivoDebeActivarLaAccionXCuenta(){
    
    VisMed_Accion__c accion = [
        SELECT Id, VisMed_FechaInicio__c, Estado__c
        FROM VisMed_Accion__c
        WHERE VisMed_FechaInicio__c = :Date.today().addDays(4)
    ];

    accion.VisMed_FechaInicio__c = Date.today();
    accion.Estado__c = 'Activo';
    
    Test.startTest();
    update accion;
    Test.stopTest();
    List<VisMed_AccionPorCuenta__c> accionXCuenta = [
        SELECT Id, Estado__c
        FROM VisMed_AccionPorCuenta__c
        WHERE VisMed_Accion__c = :accion.Id
    ];
    System.assertEquals('Activo', accionXCuenta.get(0).Estado__c, 'Error al activar accion');
   }
   @IsTest
   public static void cuandoSeModificaAccionSiEstadoEsInactivoDebeInactivarLaAccionXCuenta(){
    
    VisMed_Accion__c accion = [
        SELECT Id, VisMed_FechaInicio__c, Estado__c
        FROM VisMed_Accion__c
        WHERE VisMed_FechaInicio__c = :Date.today().addDays(4)
    ];

    accion.VisMed_FechaInicio__c = Date.today().addDays(6);
    accion.Estado__c = 'Inactivo';
    
    Test.startTest();
    update accion;
    Test.stopTest();
    List<VisMed_AccionPorCuenta__c> accionXCuenta = [
        SELECT Id, Estado__c
        FROM VisMed_AccionPorCuenta__c
        WHERE VisMed_Accion__c = :accion.Id
    ];

    system.debug(accionXCuenta);
    System.assertEquals('Inactivo', accionXCuenta.get(0).Estado__c, 'Error al activar accion');
   }


    @IsTest
    public static void validateWhenInsert(){

        VisMed_Objetivo__c obj = [
            SELECT id
            FROM VisMed_Objetivo__c
            LIMIT 1
        ];

        VisMed_Accion__c accion = Build.aVisMedAccion()
            .withVisMedObjetivo(obj)
            .withVisMedFechaInicio(Date.today().addDays(4))
            .withVisMedFechaFin(Date.today().addDays(30))        
            .build();
        
        test.startTest();
        insert accion;
        test.stopTest();

        List<VisMed_AccionPorCuenta__c> listAccionXCuenta = [
            SELECT Id
            FROM VisMed_AccionPorCuenta__c
            WHERE VisMed_Accion__c = :accion.Id
        ];

        system.assertEquals(1, listAccionXCuenta.size());

    }
}