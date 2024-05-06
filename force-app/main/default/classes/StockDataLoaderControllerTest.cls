@IsTest
public class StockDataLoaderControllerTest {
    @TestSetup
    static void makeData(){
        Product2 product = Build.aProduct()
        .withName('Producto Test')
        .withUnidadesBulto(15)            
        .withIsActive(true)
        .withIdSap('106959')
        .build();
        insert product;

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

        Stock_x_Ciclo__c stockXCiclo = Build.aStockXCiclo()
            .withAPM(apm)
            .withCiclo(ciclo)
            .build();
        insert stockXCiclo;

        Stock_x_MM__c stockMM = Build.aStockMMCiclo()
            .withCiclo(stockXCiclo)
            .withProduct(product)
            .withQuantity(50)
            .build();
        insert stockMM;
    }

    @IsTest
    public static void ValidateCicloHeaderError(){
        Stock_x_MM__c stocXMM = [
            SELECT id,Stock_x_Ciclo__r.APM__c,
             Stock_x_Ciclo__r.Ciclo__c, Muestra_Medica__c 
            FROM Stock_x_MM__c
            limit 1
        ];
        String data = 'hola,Producto,APM,Cantidad\r\n'+stocXMM.Stock_x_Ciclo__r.Ciclo__c+','+stocXMM.Muestra_Medica__c+','+stocXMM.Stock_x_Ciclo__r.APM__c+',4';
        Test.startTest();
        ServerResponse response = StockDataLoaderController.saveData(data);
        Test.stopTest();

        system.assertEquals(true, response.errors.containsKey('[Ln: 0, Col: 0]'));
        system.assertEquals('Cabecero no válido [Esperado: Ciclo, Actual: hola].',response.errors.get('[Ln: 0, Col: 0]'));
    }

    @IsTest
    public static void ValidateProductoHeaderError(){
        Stock_x_MM__c stocXMM = [
            SELECT id,Stock_x_Ciclo__r.APM__c,
             Stock_x_Ciclo__r.Ciclo__c, Muestra_Medica__c 
            FROM Stock_x_MM__c
            limit 1
        ];
        String data = 'Ciclo,hola,APM,Cantidad\r\n'+stocXMM.Stock_x_Ciclo__r.Ciclo__c+','+stocXMM.Muestra_Medica__c+','+stocXMM.Stock_x_Ciclo__r.APM__c+',4';
        Test.startTest();
        ServerResponse response = StockDataLoaderController.saveData(data);
        Test.stopTest();

        system.assertEquals(true, response.errors.containsKey('[Ln: 0, Col: 1]'));
        system.assertEquals('Cabecero no válido [Esperado: Producto, Actual: hola].',response.errors.get('[Ln: 0, Col: 1]'));
    }

    @IsTest
    public static void ValidateAPMHeaderError(){
        Stock_x_MM__c stocXMM = [
            SELECT id,Stock_x_Ciclo__r.APM__c,
             Stock_x_Ciclo__r.Ciclo__c, Muestra_Medica__c 
            FROM Stock_x_MM__c
            limit 1
        ];
        String data = 'Ciclo,Producto,hola,Cantidad\r\n'+stocXMM.Stock_x_Ciclo__r.Ciclo__c+','+stocXMM.Muestra_Medica__c+','+stocXMM.Stock_x_Ciclo__r.APM__c+',4';
        Test.startTest();
        ServerResponse response = StockDataLoaderController.saveData(data);
        Test.stopTest();

        system.assertEquals(true, response.errors.containsKey('[Ln: 0, Col: 2]'));
        system.assertEquals('Cabecero no válido [Esperado: APM, Actual: hola].',response.errors.get('[Ln: 0, Col: 2]'));
    }

    @IsTest
    public static void ValidateCantidadHeaderError(){
        Stock_x_MM__c stocXMM = [
            SELECT id,Stock_x_Ciclo__r.APM__c,
             Stock_x_Ciclo__r.Ciclo__c, Muestra_Medica__c 
            FROM Stock_x_MM__c
            limit 1
        ];
        String data = 'Ciclo,Producto,APM,hola\r\n'+stocXMM.Stock_x_Ciclo__r.Ciclo__c+','+stocXMM.Muestra_Medica__c+','+stocXMM.Stock_x_Ciclo__r.APM__c+',4';
        Test.startTest();
        ServerResponse response = StockDataLoaderController.saveData(data);
        Test.stopTest();

        system.assertEquals(true, response.errors.containsKey('[Ln: 0, Col: 3]'));
        system.assertEquals('Cabecero no válido [Esperado: Cantidad, Actual: hola].',response.errors.get('[Ln: 0, Col: 3]'));
    }

    @IsTest
    public static void ValidateDataEmptyError(){
        Stock_x_MM__c stocXMM = [
            SELECT id,Stock_x_Ciclo__r.APM__c,
             Stock_x_Ciclo__r.Ciclo__c, Muestra_Medica__c 
            FROM Stock_x_MM__c
            limit 1
        ];
        String data = '';
        Test.startTest();
        ServerResponse response = StockDataLoaderController.saveData(data);
        Test.stopTest();

        system.assertEquals(true, response.errors.containsKey('[Ln: 0, Col: 0]'));
        system.assertEquals('Contenido vacío.',response.errors.get('[Ln: 0, Col: 0]'));
    }

    @IsTest
    public static void ValidateCorrectData(){
        Stock_x_MM__c stocXMM = [
            SELECT id,Stock_x_Ciclo__r.APM__c,
             Stock_x_Ciclo__r.Ciclo__c, Muestra_Medica__c 
            FROM Stock_x_MM__c
            limit 1
        ];
        String data = 'Ciclo,Producto,APM,Cantidad\r\n'+stocXMM.Stock_x_Ciclo__r.Ciclo__c+','+stocXMM.Muestra_Medica__c+','+stocXMM.Stock_x_Ciclo__r.APM__c+',4';
        Test.startTest();
        ServerResponse response = StockDataLoaderController.saveData(data);
        Test.stopTest();

        List<StockDataLoaderController.StockWrapper> sw = (List<StockDataLoaderController.StockWrapper>)response.data;
        system.debug(sw);
        System.assertEquals(stocXMM.Stock_x_Ciclo__r.APM__c ,sw.get(0).contactId,'Error en la data');
        System.assertEquals(stocXMM.Stock_x_Ciclo__r.Ciclo__c ,sw.get(0).cycleId,'Error en la data');
        System.assertEquals(stocXMM.Muestra_Medica__c ,sw.get(0).productId,'Error en la data');
        System.assertEquals('4' ,sw.get(0).quantity,'Error en la data');
    }
    @IsTest
    public static void ValidateCorrectDataWithoutCycle(){
        Product2 product = Build.aProduct()
        .withName('Producto Test')
        .withUnidadesBulto(15)            
        .withIsActive(true)
        .withIdSap('106958')
        .build();
        insert product;

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
            .withFechaInicio(today.toStartOfMonth().addMonths(1))
            .withFechaFin(today.toStartOfMonth().addMonths(2).addDays(-1))
            .build();
            insert ciclo;
        String data = 'Ciclo,Producto,APM,Cantidad\r\n'+ciclo.Id+','+product.Id+','+apm.Id+',4';
        Test.startTest();
        ServerResponse response = StockDataLoaderController.saveData(data);
        Test.stopTest();

        List<StockDataLoaderController.StockWrapper> sw = (List<StockDataLoaderController.StockWrapper>)response.data;
        system.debug(sw);
        System.assertEquals(apm.Id,sw.get(0).contactId,'Error en la data');
        System.assertEquals(ciclo.Id ,sw.get(0).cycleId,'Error en la data');
        System.assertEquals(product.Id,sw.get(0).productId,'Error en la data');
        System.assertEquals('4' ,sw.get(0).quantity,'Error en la data');
    }

    @IsTest
    public static void ValidateCorrectWIthoutstocXMMData(){
        Stock_x_MM__c stocXMM = [
            SELECT id,Stock_x_Ciclo__r.APM__c,
             Stock_x_Ciclo__r.Ciclo__c, Muestra_Medica__c 
            FROM Stock_x_MM__c
            limit 1
        ];
        String data = 'Ciclo,Producto,APM,Cantidad\r\n'+stocXMM.Stock_x_Ciclo__r.Ciclo__c+','+stocXMM.Muestra_Medica__c+','+stocXMM.Stock_x_Ciclo__r.APM__c+',4';
        
        delete stocXMM;
        Test.startTest();
        ServerResponse response = StockDataLoaderController.saveData(data);
        Test.stopTest();

        List<StockDataLoaderController.StockWrapper> sw = (List<StockDataLoaderController.StockWrapper>)response.data;
        system.debug(sw);
        System.assertEquals(stocXMM.Stock_x_Ciclo__r.APM__c ,sw.get(0).contactId,'Error en la data');
        System.assertEquals(stocXMM.Stock_x_Ciclo__r.Ciclo__c ,sw.get(0).cycleId,'Error en la data');
        System.assertEquals(stocXMM.Muestra_Medica__c ,sw.get(0).productId,'Error en la data');
        System.assertEquals('4' ,sw.get(0).quantity,'Error en la data');
    }


    /*@IsTest
    public static void ValidateCicloEmpty(){
        Stock_x_MM__c stocXMM = [
            SELECT id,Stock_x_Ciclo__r.APM__c,
             Stock_x_Ciclo__r.Ciclo__c, Muestra_Medica__c 
            FROM Stock_x_MM__c
            limit 1
        ];
        String data = 'Ciclo,Producto,APM,Cantidad\r\n,'+stocXMM.Muestra_Medica__c+','+stocXMM.Stock_x_Ciclo__r.APM__c+',4';
        Test.startTest();
        ServerResponse response = StockDataLoaderController.saveData(data);
        Test.stopTest();

        system.debug(response);
    }*/
}