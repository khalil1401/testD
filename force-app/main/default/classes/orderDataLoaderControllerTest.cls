@isTest
public class orderDataLoaderControllerTest {
    static XHttpCalloutMock getPriceResponse;
    static string datee;

    static{
        insert new ApiDanone__c(URL__c = 'https://www.danapi.com.ar',User_Key__c = 'c3366a9f16190d9efda328ecec6f6833', User_Key_Price__c = 'c3366a9f16190d9efda328ecec6f6833',UrlClaimExtension__c = '/testing/sales/claim/v1',
        UrlreturnExtension__c = '/testing/sales/return/v1', UrlCreateOrderExtension__c = '/testing/sales/orders/v1', urlMatPrices__c = '/testing/masterdata/price/	');
        		               
        RecordType pedidoVentaDirecta = [SELECT id FROM RecordType where sObjectType='Order' and Name = 'Pedido de Venta Directa'];
        
        Id pricebookId = Test.getStandardPricebookId();
        
        Date todayDate = Date.Today();

        Account account = Build.anAccount()
            .withName('Account Test')
            .withIdSap('550071632')
            .withPricebook(pricebookId)
            .build();
        insert account;

        Account account2 = Build.anAccount()
            .withName('Account Test 2')
            .withIdSap('000014')
            .build();
        insert account2;        

        Dan360_PlantillaDeProductos__c templateProducts = Build.aPlantillaDeProductos()
            .withName('AMN Canal 00')
            .withBusinessUnit('5800')
            .build();
        insert templateProducts;

        Dan360_PlantillaDeProductos__c templateProductsNuBa = Build.aPlantillaDeProductos()
            .withName('NuBa Canal 00')
            .withBusinessUnit('5771')
            .build();
        insert templateProductsNuBa;

        insert new Plantillas__c(AMN_00__c = 'AMN Canal 00', NuBa_00__c = 'NuBa Canal 00');

        Dan360_SalesArea__c salesArea = Build.aSalesArea()
            .withName('AMN-00-00')
            .withIdExterno('5800-00-00')
            .withDistributionChannel('00')
            .withDivision('00')
            .withSalesOrganization('5800')
            .build();
        insert salesArea;

        Dan360_SalesArea__c salesAreaNuBa = Build.aSalesArea()
            .withName('NuBa-00-00')
            .withIdExterno('5771-00-00')
            .withDistributionChannel('00')
            .withDivision('00')
            .withSalesOrganization('5771')
            .build();
        insert salesAreaNuBa;

        List<Dan360_CustomerSalesArea__c> customerSalesAreaLista = new List<Dan360_CustomerSalesArea__c> ();

        Dan360_CustomerSalesArea__c customerSalesArea = Build.aCustomerSalesArea()
            .withName('AMN 00')
            .withClient(account)
            .withUnidadNegocio(salesArea)
            .withIdExterno('5678-5800-00-00')
            .build();
        //insert customerSalesArea;
        customerSalesAreaLista.add(customerSalesArea);        

        Dan360_CustomerSalesArea__c customerSalesAreaNuBa = Build.aCustomerSalesArea()
            .withName('NuBa 00')
            .withClient(account)
            .withUnidadNegocio(salesAreaNuBa)
            .withIdExterno('5678-5771-00-00')
            .build();
        //insert customerSalesAreaNuBa;
        customerSalesAreaLista.add(customerSalesAreaNuBa);

        insert customerSalesAreaLista;

        Pricebook2 pricebook = Build.aPricebook()
            .withName('Lista Precios Customer')
            .withCustomerSalesArea(customerSalesAreaLista[0])
            .isActive(true)
            .build();     
        
        insert pricebook;

        Pricebook2 pricebookNuBa = Build.aPricebook()
            .withName('Lista Precios Customer')
            .withCustomerSalesArea(customerSalesAreaLista[1])
            .isActive(true)
            .build();
        insert pricebookNuBa;

        Product2 producto = Build.aProduct()
            .withName('Producto Test')
            .withUnidadesBulto(15)
            .withProductCode('0000012')
            .withIsActive(true)
            .withIdSap('106959')
            .build();
        insert producto;
        
        Product2 producto2 = Build.aProduct()
            .withName('Producto Test 2')
            .withUnidadesBulto(15)
            .withProductCode('0000013')
            .withIsActive(true)
            .withIdSap('166578')
            .build();
        insert producto2;

        Product2 producto3 = Build.aProduct()
            .withName('Producto Test 3')
            .withUnidadesBulto(15)
            .withProductCode('0000014')
            .withIsActive(true)
            .withIdSap('166566')
            .build();
        insert producto3;

        dAN360_PlantillaporcCuenta__c templatePerAccount = Build.aPlantillaPorCuenta()
            .withAccount(account)
            .withPlantillaDeProductos(templateProducts)
            .build();
            templatePerAccount.Dan360_UnidadNegocio__c = '5800';
            templatePerAccount.Dan360_DistributionChannel__c = '00';
        insert templatePerAccount;

        dAN360_PlantillaporcCuenta__c templatePerAccount2 = Build.aPlantillaPorCuenta()
            .withAccount(account)
            .withPlantillaDeProductos(templateProductsNuBa)
            .build();
            templatePerAccount2.Dan360_UnidadNegocio__c = '5771';
            templatePerAccount2.Dan360_DistributionChannel__c = '00';
        insert templatePerAccount2;

        Dan360_ProductoPorPlantilla__c productPerTemplate = Build.aProductoPorPlantilla()
			.withProductTemplate(templateProducts)
            .withProduct(producto)
			.withUnitMeasure('Unidad')
            .withVigenciaDesde(Date.Today().AddDays(-1))
			.withVigencia(Date.Today().AddDays(1))
            .withIsActive(true)
			.build();
		insert productPerTemplate;

        Dan360_ProductoPorPlantilla__c productPerTemplate2 = Build.aProductoPorPlantilla()
			.withProductTemplate(templateProductsNuBa)
            .withProduct(producto2)
			.withUnitMeasure('Unidad')
            .withVigenciaDesde(Date.Today().AddDays(-1))
			.withVigencia(Date.Today().AddDays(1))
            .withIsActive(true)
			.build();
		insert productPerTemplate2;

        datee = String.valueOf(Date.today().year())+'-'+Date.today().month().format()+'-'+Date.today().day().format();
        getPriceResponse = new XHttpCalloutMock();
        getPriceResponse.buildResponse()
            .withStatus('OK')
            .withStatusCode(200)
            .withBody('{'+
            '    \"date\": \"2022-05-01\",'+
            '    \"organizationId\": \"5800\",'+
            '    \"channelId\": \"00\",'+
            '    \"divisionId\": \"00\",'+
            '    \"customer\": \"550071632\",'+
            '    \"prices\": ['+
            '        {'+
            '            \"materialId\": \"106959\",'+
            '            \"price\": 1249.5,'+
            '            \"discount\": 0.0'+
            '        }'+
            '    ]'+
            '}')
            .addForAddress(WebServiceSap.SERVICE_CONFIG.URL__c + WebServiceSap.SERVICE_CONFIG.urlMatPrices__c + 'sn?date='+datee+'&organizationId='+salesArea.Dan360_SalesOrganization__c+'&channelId='+salesArea.Dan360_DistributionChannel__c+'&divisionId='+salesArea.Dan360_Division__c+'&customer='+account.Id_SAP__c);
        getPriceResponse.buildResponse()
            .withStatus('OK')
            .withStatusCode(200)
            .withBody('{'+
            '    \"date\": \"2022-05-01\",'+
            '    \"organizationId\": \"5771\",'+
            '    \"channelId\": \"00\",'+
            '    \"divisionId\": \"00\",'+
            '    \"customer\": \"550071632\",'+
            '    \"prices\": ['+
            '        {'+
            '            \"materialId\": \"166578\",'+
            '            \"price\": 7290.0,'+
            '            \"discount\": 0.0'+
            '        }'+
            '    ]'+
            '}')
            .addForAddress(WebServiceSap.SERVICE_CONFIG.URL__c + WebServiceSap.SERVICE_CONFIG.urlMatPrices__c + 'sn?date='+datee+'&organizationId='+salesAreaNuBa.Dan360_SalesOrganization__c+'&channelId='+salesAreaNuBa.Dan360_DistributionChannel__c+'&divisionId='+salesAreaNuBa.Dan360_Division__c+'&customer='+account.Id_SAP__c);
            //.addForAddress('https://www.danapi.com.ar/testing/masterdata/price/sn?date='+datee+'&organizationId=5800&channelId=01&divisionId=01&customer=550071632');
	}

    // private class Mock implements HttpCalloutMock {
    //     public HTTPResponse respond(HTTPRequest req) {
    //         System.debug(req);
    //         HTTPResponse res = new HTTPResponse();
    //         if(req.getEndpoint().contains('5800')){
    //             res.setBody('{'+
    //             '    \"date\": \"2022-05-01\",'+
    //             '    \"organizationId\": \"5800\",'+
    //             '    \"channelId\": \"00\",'+
    //             '    \"divisionId\": \"00\",'+
    //             '    \"customer\": \"550071632\",'+
    //             '    \"prices\": ['+
    //             '        {'+
    //             '            \"materialId\": \"106959\",'+
    //             '            \"price\": 1249.5,'+
    //             '            \"discount\": 0.0'+
    //             '        }'+
    //             '    ]'+
    //             '}');
    //             res.setStatusCode(200);
    //             return res;
    //         }else{
    //             res.setBody('{'+
    //             '    \"date\": \"2022-05-01\",'+
    //             '    \"organizationId\": \"5771\",'+
    //             '    \"channelId\": \"00\",'+
    //             '    \"divisionId\": \"00\",'+
    //             '    \"customer\": \"550071632\",'+
    //             '    \"prices\": ['+
    //             '        {'+
    //             '            \"materialId\": \"166578\",'+
    //             '            \"price\": 7290.0,'+
    //             '            \"discount\": 0.0'+
    //             '        }'+
    //             '    ]'+
    //             '}');
    //             res.setStatusCode(200);
    //             return res;
    //         }
    //     }
    // }
    
    @IsTest
    static void cuandoReciveCsvDeberiaCrearElPedidoCorrespondiente(){
        Test.setMock(HttpCalloutMock.class, getPriceResponse);
        //Test.setMock(HttpCalloutMock.class, new Mock());
        Account accountTest = [SELECT Id_SAP__c FROM Account WHERE Id_SAP__c = '550071632'];

        List<Pricebook2> lsitaDePrecios = [SELECT Id, Name FROM Pricebook2]; 
        System.debug(lsitaDePrecios);

        String dataString = 'Sucursal,Orden de Compra,Codigo Producto,Nombre Producto,Cantidad Solicitada\r\n'+
                    accountTest.Id_SAP__c+',123,106959,,1';
        String base64Data = JSON.serialize(dataString);

        String tipoDeVenta = '00';

        Boolean isSave = true;

        Test.startTest();
            List<orderDataLoaderController.WrapperOrder> orderResult = orderDataLoaderController.saveFile(base64Data, tipoDeVenta, isSave);
        Test.stopTest();
        

        List<Order> ordersToCompare = [SELECT Id FROM Order];
        System.debug(ordersToCompare);
        System.debug(orderResult);

        System.assertEquals(1, orderResult.size());
        System.assertEquals(1, ordersToCompare.size(), 'No se crearon la cantidad de pedidos esperados');
    } 
    
    @IsTest
    static void cuandoReciveCsvSinDatosNoDeberiaCrearPedidos(){
        Test.setMock(HttpCalloutMock.class, getPriceResponse);
        
        String dataString = 'Sucursal,Orden de Compra,Codigo Producto,Nombre Producto,Cantidad Solicitada';
        String base64Data = JSON.serialize(dataString);

        String tipoDeVenta = '00';

        Boolean isSave = true;

        Test.startTest();
            List<orderDataLoaderController.WrapperOrder> orderResult = orderDataLoaderController.saveFile(base64Data, tipoDeVenta, isSave);
        Test.stopTest();

        List<Order> ordersToCompare = [SELECT Id FROM Order];
        
        System.assertEquals(0, orderResult.size());
        System.assertEquals(0, ordersToCompare.size());
    }

    @IsTest
    static void cuandoReciveDosProductosIgualesEnElMismoPedidoNoDeberiaCrearPedidos(){
        Test.setMock(HttpCalloutMock.class, getPriceResponse);
        Account accountTest = [SELECT Id_SAP__c FROM Account WHERE Id_SAP__c = '550071632'];

        String dataString = 'Sucursal,Orden de Compra,Codigo Producto,Nombre Producto,Cantidad Solicitada\r\n'+
                    accountTest.Id_SAP__c+',123,106959,,1\r\n'+
                    accountTest.Id_SAP__c+',123,106959,,1\r\n';
        String base64Data = JSON.serialize(dataString);

        String tipoDeVenta = '00';

        Boolean isSave = true;

        String testResult;
        Test.startTest();
            try {
                orderDataLoaderController.saveFile(base64Data, tipoDeVenta, isSave);
            } catch (Exception e) {
                testResult = e.getMessage();
            }
        Test.stopTest();

        List<Order> ordersToCompare = [SELECT Id FROM Order];

        System.assertEquals('La orden: 123 para el cliente: 550071632 tiene el producto: 106959 duplicado', testResult);
        System.assertEquals(0, ordersToCompare.size());
    } 

    @IsTest
    static void cuandoRecibeUnProductoQueNoEstaEnLaPlantillaNoSeDebeGenerarElPedido(){
        Test.setMock(HttpCalloutMock.class, getPriceResponse);
        Account accountTest = [SELECT Id_SAP__c FROM Account WHERE Id_SAP__c = '550071632'];

        String dataString = 'Sucursal,Orden de Compra,Codigo Producto,Nombre Producto,Cantidad Solicitada\r\n'+
                    accountTest.Id_SAP__c+',123,166566,,1\r\n';
        String base64Data = JSON.serialize(dataString);

        String tipoDeVenta = '00';

        Boolean isSave = true;

        String testResult;
        Test.startTest();
            try {
                orderDataLoaderController.saveFile(base64Data, tipoDeVenta, isSave);
            } catch (Exception e) {
                testResult = e.getMessage();
            }
        Test.stopTest();

        List<Order> ordersToCompare = [SELECT Id FROM Order];

        System.assertEquals('El producto: 166566 para cliente: 550071632 es incorrecto', testResult);
        System.assertEquals(0, ordersToCompare.size());
    }

    @IsTest
    static void cuandoElClienteNoTieneCustumerSalesAreaCorrespondienteNoSeCreaElPedido(){
        Test.setMock(HttpCalloutMock.class, getPriceResponse);
        Account accountTest = [SELECT Id_SAP__c FROM Account WHERE Id_SAP__c = '000014'];

        String dataString = 'Sucursal,Orden de Compra,Codigo Producto,Nombre Producto,Cantidad Solicitada\r\n'+
                    accountTest.Id_SAP__c+',123,106959,,1';
        String base64Data = JSON.serialize(dataString);

        String tipoDeVenta = '00';

        Boolean isSave = true;

        String testResult;
        Test.startTest();
            try {
                orderDataLoaderController.saveFile(base64Data, tipoDeVenta, isSave);
            } catch (Exception e) {
                testResult = e.getMessage();
            }
        Test.stopTest();
        System.debug(testResult);

        List<Order> ordersToCompare = [SELECT Id FROM Order];

        System.assertEquals('No pude crear pedidos para el cliente: 000014', testResult);
        System.assertEquals(0, ordersToCompare.size());
    } 

    @IsTest
    static void cuandoNoExisteplantillaParaElPedidoNoSeCreaElPedido(){
        Test.setMock(HttpCalloutMock.class, getPriceResponse);
        Account accountTest = [SELECT Id_SAP__c FROM Account WHERE Id_SAP__c = '550071632'];

        String dataString = 'Sucursal,Orden de Compra,Codigo Producto,Nombre Producto,Cantidad Solicitada\r\n'+
                    accountTest.Id_SAP__c+',123,106959,,1';
        String base64Data = JSON.serialize(dataString);

        String tipoDeVenta = '05';

        Boolean isSave = true;

        String testResult;
        Test.startTest();
            try {
                orderDataLoaderController.saveFile(base64Data, tipoDeVenta, isSave);
            } catch (Exception e) {
                testResult = e.getMessage();
            }
        Test.stopTest();

        List<Order> ordersToCompare = [SELECT Id FROM Order];
        System.assertEquals('No pude crear pedidos para el cliente: 550071632', testResult);
        System.assertEquals(0, ordersToCompare.size());
    }

    @IsTest
    static void cuandoRecibeDosProductosConDistintasUnidadDeNegocioNoSeDebeGenerarElPedido(){
        //Test.setMock(HttpCalloutMock.class, new Mock());
        Test.setMock(HttpCalloutMock.class, getPriceResponse);
        Account accountTest = [SELECT Id,Id_SAP__c FROM Account WHERE Id_SAP__c = '550071632'];

        String dataString = 'Sucursal,Orden de Compra,Codigo Producto,Nombre Producto,Cantidad Solicitada\r\n'+
                    accountTest.Id_SAP__c+',123,106959,,1\r\n'+
                    accountTest.Id_SAP__c+',123,166578,,1\r\n';
        String base64Data = JSON.serialize(dataString);

        String tipoDeVenta = '00';

        Boolean isSave = true;
        
        String testResult;
        Test.startTest();
            try {
                orderDataLoaderController.saveFile(base64Data, tipoDeVenta, isSave);
            } catch (Exception e) {
                testResult = e.getMessage();
            }
        Test.stopTest();
        System.debug(testResult);

        List<Order> ordersToCompare = [SELECT Id FROM Order];

        System.assertEquals('El producto: 166578 para la orden: 123 no pertenece a la misma unidad de negocio del pedido (5800)', testResult);
        System.assertEquals(0, ordersToCompare.size());
    }   
}