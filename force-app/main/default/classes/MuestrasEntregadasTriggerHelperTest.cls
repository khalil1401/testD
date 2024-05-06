@isTest
public with sharing class MuestrasEntregadasTriggerHelperTest {
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
            Id  recordTypeProfesional = [
                    SELECT Id, Name, SobjectType,IsPersonType 
                    FROM RecordType 
                    WHERE SobjectType='Account' 
                    AND IsPersonType=True 
                    AND Name = 'Profesional de la Salud'
                ].Id;
            Account profesional = Build.aPersonalAccount()
                    .withFirstName('Profesional')                
                    .build();
                    profesional.RecordTypeId = recordTypeProfesional;
    
                insert profesional;
        
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

            Product2 product2 = Build.aProduct()
                .withName('Producto Test 2')
                .withUnidadesBulto(15)            
                .withIsActive(true)
                .withIdSap('1069592')
                .build();
            insert product2;

            Product2 product3 = Build.aProduct()
                .withName('Producto Test 3')
                .withUnidadesBulto(15)            
                .withIsActive(true)
                .withIdSap('1069593')
                .build();
            insert product3;

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

            Stock_x_MM__c stockMM2 = Build.aStockMMCiclo()
                .withCiclo(stockXCiclo)
                .withProduct(product2)
                .withQuantity(50)
                .build();
            insert stockMM2;

            Stock_x_MM__c stockMM3 = Build.aStockMMCiclo()
                .withCiclo(stockXCiclo)
                .withProduct(product3)
                .withQuantity(50)
                .build();
            insert stockMM3;
        
            Dan360_Efectividad__c efectividad = Build.aDan360Efectividad()
            .withVisMedAPM(apm)
            .withVisMedCiclo(ciclo)
            .build();
            efectividad.Fecha_de_Fin__c = Date.today().toStartOfMonth();
            efectividad.Fecha_de_inicio__c = Date.today().toStartOfMonth().addMonths(1).addDays(-1);
            insert efectividad;
            Integer daysToAdd2 = interaccionDaySaturdayOrSunday(false);
            Dan360_Interacciones__c visita = Build.aDan360Interacciones()
                    .withProfesional(profesional)
                    .withAPM(apm)
                    .withVisMedTipodeVisita('Presencial')
                    .withVisMedEfectividad(efectividad)
                    .withDomiciliodelaVisita(institucion)
                    .withVisMedFecha(Date.Today().addDays(daysToAdd2))                    
                    .build();                
                insert visita;

            Muestras_Entregadas__c muestraMedica1 =  new Muestras_Entregadas__c();
            muestraMedica1.Stock_x_MM__c = stockMM.id;
            muestraMedica1.Interaccion__c = visita.id;
            muestraMedica1.Cantidad__c = 4;
            insert muestraMedica1;

            Muestras_Entregadas__c muestraMedica2 =  new Muestras_Entregadas__c();
            muestraMedica2.Stock_x_MM__c = stockMM2.id;
            muestraMedica2.Interaccion__c = visita.id;
            muestraMedica2.Cantidad__c = 2;
            insert muestraMedica2;

        }
    }
    public static integer interaccionDaySaturdayOrSunday(Boolean subtractMonth) {
        if (subtractMonth) {
            DateTime now = DateTime.now().addMonths(-1);
            String dayOfWeek = now.format('EEEE');
            System.debug('****** now: ' + now + ' ' + dayOfWeek);
            if (dayOfWeek == 'Saturday') {
                return 2;
            }else if(dayOfWeek == 'Sunday'){
                return 1;
            }else {
                return 0;
            }            
        } else {
            DateTime now = DateTime.now();
            String dayOfWeek = now.format('EEEE');
            System.debug('****** now: ' + now + ' ' + dayOfWeek);
            if (dayOfWeek == 'Saturday') {
                return 2;
            }else if(dayOfWeek == 'Sunday'){
                return 1;
            }else {
                return 0;
            }
        }
    }
    @isTest
    public static void checkDuplicatesInInsert(){
        Dan360_Interacciones__c visita = [SELECT id, Name FROM Dan360_Interacciones__c LIMIT 1];
        Id productoError = [SELECT id FROM Product2 WHERE Name = 'Producto Test'].Id;
        Stock_x_MM__c stockMMError = [SELECT Id, Name FROM Stock_x_MM__c WHERE Muestra_Medica__c = :productoError LIMIT 1];
        
        Id producto = [SELECT id FROM Product2 WHERE Name = 'Producto Test 3'].Id;
        Stock_x_MM__c stockMM = [SELECT Id, Name FROM Stock_x_MM__c WHERE Muestra_Medica__c = :producto LIMIT 1];
        Boolean error = false;
        List<Muestras_Entregadas__c> muentrasAInsertar = new List<Muestras_Entregadas__c>();

        Muestras_Entregadas__c muestraMedicaTestSinError =  new Muestras_Entregadas__c(
            Stock_x_MM__c = stockMM.id,
            Interaccion__c = visita.id,
            Cantidad__c = 2
        );
        muentrasAInsertar.add(muestraMedicaTestSinError);
        Muestras_Entregadas__c muestraMedicaTest =  new Muestras_Entregadas__c(
            Stock_x_MM__c = stockMMError.id,
            Interaccion__c = visita.id,
            Cantidad__c = 2
        );
        muentrasAInsertar.add(muestraMedicaTest);
        Test.startTest();
        try {
            Database.SaveResult[] saveResultList = Database.insert(muentrasAInsertar, false);
            for (Database.SaveResult sr : saveResultList) {
                if (!sr.isSuccess()) {
                    for(Database.Error err : sr.getErrors()) {
                        error = true;
                    } 
                }
            }
        } catch (Exception e) {
            error = true;
        } 
        Test.stopTest();

        List<Muestras_Entregadas__c> muestrasInsertadas = [SELECT id FROM Muestras_Entregadas__c];
        System.assertEquals(true, error, 'Se inserto una muestra medica duplicada');
        System.assertEquals(3, muestrasInsertadas.size(), 'No se inserto la muestra');
    }
}