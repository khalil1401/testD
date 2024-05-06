@isTest public with sharing class StockXCicloTriggerHelperTest {
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

        User userAPM = Build.aUser()
            .withUsername(
                'newuser'+String.valueOf(System.now().getTime() + (Math.random() * 10))+'@testorg.com'
            )               
            .withEmail('apm@xappia.com')
            .withAlias('uapm')
            .withContactId(apm)
            .withLastName('Owner')
            .withTimeZoneSidKey('America/Argentina/Buenos_Aires')
            .withLocaleSidKey('es_AR')
            .withCommunityNickname('prueba')
            .withEmailEncodingKey('ISO-8859-1')
            .withProfileId(apmPerfil.Id)            			
            .withLanguageLocaleKey('es')
            .build();           
        userOwner.ManagerId = userOwner.Id;
        userOwner.IsActive = true;
        userOwner.VisMed_ContrasenaApp__c = 'TestOwner';
        insert userAPM;
        
        Date mesAnterior = Date.today().addMonths(-1);
        VisMed_Ciclo__c cicloAnterior = Build.aCiclo()
        .withFechaInicio(mesAnterior.toStartOfMonth())
        .withFechaFin(mesAnterior.toStartOfMonth().addMonths(1).addDays(-1))
        .build();
        insert cicloAnterior;

        Product2 product = Build.aProduct()
            .withName('Producto Test')
            .withUnidadesBulto(15)            
            .withIsActive(true)
            .withIdSap('106959')
            .build();
        insert product;
        
        Date today = Date.today();
        VisMed_Ciclo__c ciclo = Build.aCiclo()
        .withFechaInicio(today.toStartOfMonth())
        .withFechaFin(today.toStartOfMonth().addMonths(1).addDays(-1))
        .build();
        insert ciclo;

        Stock_x_Ciclo__c stockXCiclo = Build.aStockXCiclo()
            .withAPM(apm)
            .withCiclo(cicloAnterior)
            .build();
        insert stockXCiclo;

        Stock_x_MM__c stockMM = Build.aStockMMCiclo()
            .withCiclo(stockXCiclo)
            .withProduct(product)
            .withQuantity(50)
            .build();
        insert stockMM;
    
        Dan360_Efectividad__c efectividad = Build.aDan360Efectividad()
        .withVisMedAPM(apm)
        .withVisMedCiclo(ciclo)
        .build();
        efectividad.Fecha_de_Fin__c = Date.today().toStartOfMonth();
        efectividad.Fecha_de_inicio__c = Date.today().toStartOfMonth().addMonths(1).addDays(-1);
        insert efectividad;
    }
    }

    @IsTest
    static void cuandoCreoStockXCicloDebeAsignarAlUsuarioApmComoOwner(){

        Contact apm = [
            SELECT Id
            FROM Contact
            WHERE VisMed_DNI__c = '22222333'
        ];

        VisMed_Ciclo__c ciclo = [
            SELECT ID
            FROM VisMed_Ciclo__c
            WHERE Fecha_de_inicio__c = :Date.Today().toStartOfMonth()
        ];

        User userApm = [
            SELECT Id
            FROM User
            WHERE Alias = 'uapm'
        ];

        Stock_x_Ciclo__c stockXCiclo = Build.aStockXCiclo()
            .withAPM(apm)
            .withCiclo(ciclo)
            .build();
            
        Test.startTest();
        insert stockXCiclo;        
        Test.stopTest();

        Stock_x_Ciclo__c stockToCompare = [
            SELECT Id, OwnerId
            FROM Stock_x_Ciclo__c
            WHERE Id = :stockXCiclo.Id
            LIMIT 1
        ];
        
        System.assertEquals(userApm.Id, stockToCompare.OwnerId, 'Error al crear el owner del stock por mes');
        
    }
    @IsTest
    static void cuandoCreoStockXCicloDebeAsignarStockxMmAlApm(){

        Contact apm = [
            SELECT Id
            FROM Contact
            WHERE VisMed_DNI__c = '22222333'
        ];

        VisMed_Ciclo__c ciclo = [
            SELECT ID
            FROM VisMed_Ciclo__c
            WHERE Fecha_de_inicio__c = :Date.Today().toStartOfMonth()
        ];
        
        Stock_x_Ciclo__c stockXCiclo = Build.aStockXCiclo()
            .withAPM(apm)
            .withCiclo(ciclo)
            .build();
            
        Test.startTest();
        insert stockXCiclo;        
        Test.stopTest();        

        List<Stock_x_MM__c> stockXMM = [
            SELECT Id
            FROM Stock_x_MM__c 
            WHERE Stock_x_Ciclo__c = :stockXCiclo.Id           
        ];

        System.assertEquals(1, stockXMM.size(), 'Error al crear el stock por mes');
        
    }
}