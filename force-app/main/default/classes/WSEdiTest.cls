@isTest
public with sharing class WSEdiTest {
    static XHttpCalloutMock getResponse;
    static string datee;
    static{

        insert new Plantillas__c(NuBa_00__c='Plantilla BULTOS - NUBA');
        insert new ApiDanone__c(URL__c = 'https://www.danapi.com.ar',User_Key__c = 'c3366a9f16190d9efda328ecec6f6833', User_Key_Price__c = 'c3366a9f16190d9efda328ecec6f6833',UrlClaimExtension__c = '/testing/sales/claim/v1',
            UrlreturnExtension__c = '/testing/sales/return/v1', UrlCreateOrderExtension__c = '/testing/sales/orders/v1', urlMatPrices__c = '/testing/masterdata/price/');

        List<OrderItem> orderItems = new List<OrderItem>();

		RecordType pedidoVentaDirecta = [SELECT id 
										FROM RecordType 
										WHERE sObjectType='Order' 
										AND Name = 'Pedido de Venta Directa'];

		Id pricebookId = Test.getStandardPricebookId();
		Date todayDate = Date.Today();

		Account account = Build.anAccount()
			.withPricebook(pricebookId)
			.withCanalComercial('E-Commerce')
			.withName('Account Test')
			.withIdSap('550071632')
            .withGLN(550071632)
			.withSalesDistric('E-Commerce')
			.withDistributionChannel('00')
			.build();
		insert account;

		Product2 producto = Build.aProduct()
			.withName('Product for Test')
			.withUnidadesBulto(15)			
			.withIdSap('106959')
            .withEan('106959')
			.withIsActive(true)
			.build();
		insert producto;

		Product2 productoTwo = Build.aProduct()
			.withName('Producto Test2')
			.withUnidadesBulto(15)
			.withIdSap('123')
            .withEan('123')
			.withIsActive(true)
			.build();
		insert productoTwo;

        Product2 productoThree = Build.aProduct()
			.withName('Producto Test2 Sin precio')
			.withUnidadesBulto(15)
			.withIdSap('166578')
            .withEan('166578')
			.withIsActive(true)
			.build();
		insert productoThree;

        Dan360_SalesArea__c salesArea = Build.aSalesArea()
                .withName('NUBA-00-00')
                .withIdExterno('5771-00-00')
                .withDistributionChannel('00')
                .withDivision('00')
                .withSalesOrganization('5771')
                .build();
            insert salesArea;

       /*  Dan360_SalesArea__c salesAreaBlock = Build.aSalesArea()
            .withName('AMN-00-00')
            .withIdExterno('5800-00-00')
            .withDistributionChannel('00')
            .withDivision('00')
            .withSalesOrganization('5800')
            .build();
        insert salesAreaBlock; */

        Dan360_PlantillaDeProductos__c productsTemplate = Build.aPlantillaDeProductos()
            .withName('Plantilla BULTOS - NUBA')
            .withBusinessUnit('5771')
            .build();
        insert productsTemplate;

        /* Dan360_PlantillaDeProductos__c productsTemplateBlock = Build.aPlantillaDeProductos()
            .withName('Plantilla BULTOS - NUBA')
            .withBusinessUnit('5771')
            .build();
        insert productsTemplateBlock; */

        Dan360_CustomerSalesArea__c customerSalesArea = Build.aCustomerSalesArea()
                .withName('Nuba 00')
                .withClient(account)
                .withUnidadNegocio(salesArea)
                .withIdExterno('5678-5771-00-00')
                .build();
            insert customerSalesArea;

        Pricebook2 pricebookCustomer = Build.aPricebook().withName('CustomerPriceBook').withCustomerSalesArea(customerSalesArea).isActive(true).build();
        insert pricebookCustomer;

        /* Dan360_CustomerSalesArea__c customerSalesAreaBlock = Build.aCustomerSalesArea()
                .withName('Nuba 00')
                .withClient(account)
                .withUnidadNegocio(salesAreaBlock)
                .withIdExterno('5678-5800-00-00')
                .withBlock(true)
                .build();
        insert customerSalesAreaBlock; */

        //Pricebook2 pricebookCustomerBlock = Build.aPricebook().withName('CustomerPriceBookBlock').withCustomerSalesArea(customerSalesAreaBlock).isActive(true).build();

        PricebookEntry pricebookPriceDefault = Build.aPricebookEntry()
            .withPricebook2Id(pricebookCustomer.id)
            .withProduct2Id(producto)
            .withUnitPrice(100)
            .withIsActive(true)
            .withDiscount(0.5)
            .build();
        insert pricebookPriceDefault;
        
        PricebookEntry pricebookPriceDefault3 = Build.aPricebookEntry()
            .withPricebook2Id(pricebookCustomer.id)
            .withProduct2Id(productoThree)
            .withUnitPrice(100)
            .withIsActive(true)
            .withDiscount(0)
            .build();
        insert pricebookPriceDefault3;

        PricebookEntry pricebookPriceDefault2 = Build.aPricebookEntry()
            .withPricebook2Id(pricebookCustomer.id)
            .withProduct2Id(productoTwo)
            .withUnitPrice(50)
            .withIsActive(true)
            .withDiscount(0.5)
            .build();
        insert pricebookPriceDefault2;

        
    
            Dan360_ProductoPorPlantilla__c productPerTemplate = Build.aProductoPorPlantilla()
                .withProduct(producto)
                .withProductTemplate(productsTemplate)
                .withUnitMeasure('Unidad')
                .withVigenciaDesde(Date.Today().AddDays(-1))
                .withVigencia(Date.Today().AddDays(1))
                .withIsActive(false)
                .build();
            insert productPerTemplate;
            Dan360_ProductoPorPlantilla__c productPerTemplate3 = Build.aProductoPorPlantilla()
                .withProduct(productoThree)
                .withProductTemplate(productsTemplate)
                .withUnitMeasure('Unidad')
                .withVigenciaDesde(Date.Today().AddDays(-1))
                .withVigencia(Date.Today().AddDays(1))
                .withIsActive(false)
                .build();
            insert productPerTemplate3;
            Dan360_ProductoPorPlantilla__c productPerTemplateTwo = Build.aProductoPorPlantilla()
                .withProduct(productoTwo)
                .withProductTemplate(productsTemplate)
                .withUnitMeasure('Unidad')
                .withVigenciaDesde(Date.Today())
                .withVigencia(Date.Today().AddDays(5))
                .withIsActive(true)
                .build();
            insert productPerTemplateTwo;

            datee = String.valueOf(Date.today().year())+'-'+Date.today().month().format()+'-'+Date.today().day().format();
            getResponse = new XHttpCalloutMock();
            getResponse.buildResponse()
                .withStatus('OK')
                .withStatusCode(200)
                .withBody(SapPricesMock.getSucess())
                .addForAddress(WebServiceSap.SERVICE_CONFIG.URL__c + WebServiceSap.SERVICE_CONFIG.urlMatPrices__c + 'sn?date='+datee+'&organizationId='+salesArea.Dan360_SalesOrganization__c+'&channelId='+salesArea.Dan360_DistributionChannel__c+'&divisionId='+salesArea.Dan360_Division__c+'&customer='+account.Id_SAP__c);
    }

    @isTest
    public static void ifClientExistInMetadataDoNothing(){
        Test.setMock(HttpCalloutMock.class, getResponse);
        RestRequest req = new RestRequest();
        String body = '{' +
            '"source": "EDI",' +
            '"businessModel": "B2B",'+
            '"companyCode": "5771",' +
            '"organizationId": "5771",' +
            '"channelId": "00",' +
            '"poNumber": "123456",' +
            '"soldTo": "0002",' +
            '"shipTo": "7798130250114",' +
            '"orderDate": "2021-11-01T00:00:00",' +
            '"reqDelDate": "2021-11-01T00:00:00",' +
            '"items": [' +
                '{' +
                '"matNumber": "7795323001324",' +
                '"orderedQuantity": 24.00,' +
                '"lotQuantity": 2.00,' +
                '"quantityByLot": 12.00' +
                '}' +
            ']' +
        '}';
        req.requestURI = '/services/apexrest/edi'; 
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(body);

        RestContext.request = req;

        Test.startTest();
        WSEdi.Respuesta resp = WSEdi.doPost();
        Test.stopTest();

        System.assertEquals('Sucursal inexistente', resp.message,'Error al comprar GLN de la tabla');
        System.debug(resp);
    }

    @isTest
    public static void ifClientDontExistInSFCreateALog(){
        Test.setMock(HttpCalloutMock.class, getResponse);
        RestRequest req = new RestRequest();
        String body = '{' +
            '"source": "EDI",' +
            '"businessModel": "B2B",'+
            '"companyCode": "5771",' +
            '"organizationId": "5771",' +
            '"channelId": "00",' +
            '"poNumber": "123456",' +
            '"soldTo": "00021",' +
            '"shipTo": "5500716322",' +
            '"orderDate": "2021-11-01T00:00:00",' +
            '"reqDelDate": "2021-11-01T00:00:00",' +
            '"items": [' +
                '{' +
                '"matNumber": "7795323001324",' +
                '"orderedQuantity": 24.00,' +
                '"lotQuantity": 2.00,' +
                '"quantityByLot": 12.00' +
                '}' +
            ']' +
        '}';
        req.requestURI = '/services/apexrest/edi'; 
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(body);

        RestContext.request = req;

        Test.startTest();
        WSEdi.Respuesta resp = WSEdi.doPost();
        Test.stopTest();

        AppLog__c logError = [SELECT id, Tipo_de_Errores__c FROM AppLog__c];

        System.assertEquals('Sucursal inexistente', resp.message,'Error al buscar el cliente en SF');
        System.assertEquals('Cliente - Sucursal inexistente', logError.Tipo_de_Errores__c,'Error al crear el log de error');
    }

    @isTest
    public static void ifClientDontExistButCheckFalseCreateALog(){
        Test.setMock(HttpCalloutMock.class, getResponse);
        RestRequest req = new RestRequest();
        String body = '{' +
            '"source": "EDI",' +
            '"businessModel": "B2B",'+
            '"companyCode": "5771",' +
            '"organizationId": "5771",' +
            '"channelId": "00",' +
            '"poNumber": "123456",' +
            '"soldTo": "00021",' +
            '"shipTo": "550071632",' +
            '"orderDate": "2021-11-01T00:00:00",' +
            '"reqDelDate": "2021-11-01T00:00:00",' +
            '"items": [' +
                '{' +
                '"matNumber": "106959",' +
                '"orderedQuantity": 24.00,' +
                '"lotQuantity": 2.00,' +
                '"quantityByLot": 12.00' +
                '}' +
            ']' +
        '}';
        req.requestURI = '/services/apexrest/edi'; 
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(body);

        RestContext.request = req;

        Test.startTest();
        WSEdi.Respuesta resp = WSEdi.doPost();
        Test.stopTest();

        AppLog__c logError = [SELECT id, Tipo_de_Errores__c FROM AppLog__c];
        List<Order> pedido = [SELECT Id, Status FROM Order];

        System.assertEquals('Cliente - Sin marca EDI', logError.Tipo_de_Errores__c,'Error al crear el log de error');
        System.assertEquals('Error', pedido[0].Status,'Error al crear la orden en estado de Error');
    }

    @isTest
    public static void ifClientDontHavePriceInSapCreateLog(){
        Test.setMock(HttpCalloutMock.class, getResponse);
        RestRequest req = new RestRequest();
        String body = '{' +
            '"source": "EDI",' +
            '"businessModel": "B2B",'+
            '"companyCode": "5771",' +
            '"organizationId": "5771",' +
            '"channelId": "00",' +
            '"poNumber": "123456",' +
            '"soldTo": "00021",' +
            '"shipTo": "550071632",' +
            '"orderDate": "2021-11-01T00:00:00",' +
            '"reqDelDate": "2021-11-01T00:00:00",' +
            '"items": [' +
                '{' +
                '"matNumber": "123",' +
                '"orderedQuantity": 24.00,' +
                '"lotQuantity": 2.00,' +
                '"quantityByLot": 12.00' +
                '}' +
            ']' +
        '}';
        req.requestURI = '/services/apexrest/edi'; 
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(body);

        RestContext.request = req;

        Test.startTest();
        WSEdi.Respuesta resp = WSEdi.doPost();
        Test.stopTest();

        AppLog__c logError = [SELECT id, Tipo_de_Errores__c FROM AppLog__c];
        List<Order> pedido = [SELECT Id, Status FROM Order];

        System.assertEquals('Cliente - Sin marca EDI;Producto - Error en Producto', logError.Tipo_de_Errores__c,'Error al crear el log de error');
        System.assertEquals('Error', pedido[0].Status,'Error al crear la orden en estado de Error');
    }

    @isTest
    public static void ifClientDontHaveErrorConfirmOrder(){
        List<Account> cuenta = [SELECT ID,Id_SAP__c, Cliente_EDI__c FROM Account];
        cuenta[0].Cliente_EDI__c = true;
        update cuenta;

        Test.setMock(HttpCalloutMock.class, getResponse);
        RestRequest req = new RestRequest();
        String body = '{' +
            '"source": "EDI",' +
            '"businessModel": "B2B",'+
            '"companyCode": "5771",' +
            '"organizationId": "5771",' +
            '"channelId": "00",' +
            '"poNumber": "123456",' +
            '"soldTo": "00021",' +
            '"shipTo": "550071632",' +
            '"orderDate": "2021-11-01T00:00:00",' +
            '"reqDelDate": "2021-11-01T00:00:00",' +
            '"items": [' +
                '{' +
                '"matNumber": "106959",' +
                '"orderedQuantity": 24.00,' +
                '"lotQuantity": 2.00,' +
                '"quantityByLot": 12.00' +
                '} , ' +
                '{' +
                '"matNumber": "166578",' +
                '"orderedQuantity": 24.00,' +
                '"lotQuantity": 2.00,' +
                '"quantityByLot": 12.00' +
                '}' +
            ']' +
        '}';
        req.requestURI = '/services/apexrest/edi'; 
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(body);

        RestContext.request = req;

        Test.startTest();
        WSEdi.Respuesta resp = WSEdi.doPost();
        Test.stopTest();

        List<Order> pedido = [SELECT Id, Status FROM Order];

        System.assertEquals('Confirmado', pedido[0].Status,'Error al crear la orden en estado de Error');
    }

    @isTest
    public static void ifClientHaveCustomerSalesAreaBlockCreateAppLog(){
       
        List<Dan360_CustomerSalesArea__c> customerSalesArea = [SELECT Id, Dan360_Block__c FROM Dan360_CustomerSalesArea__c];
        customerSalesArea[0].Dan360_Block__c = true;
        update customerSalesArea;

        Test.setMock(HttpCalloutMock.class, getResponse);
        RestRequest req = new RestRequest();
        String body = '{' +
            '"source": "EDI",' +
            '"businessModel": "B2B",'+
            '"companyCode": "5771",' +
            '"organizationId": "5771",' +
            '"channelId": "00",' +
            '"poNumber": "",' +
            '"soldTo": "00021",' +
            '"shipTo": "550071632",' +
            '"orderDate": "2021-11-01T00:00:00",' +
            '"reqDelDate": "2021-11-01T00:00:00",' +
            '"items": [' +
                '{' +
                '"matNumber": "106959",' +
                '"orderedQuantity": 24.00,' +
                '"lotQuantity": 2.00,' +
                '"quantityByLot": 12.00' +
                '}' +
            ']' +
        '}';
        req.requestURI = '/services/apexrest/edi'; 
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(body);

        RestContext.request = req;

        Test.startTest();
        WSEdi.Respuesta resp = WSEdi.doPost();
        Test.stopTest();

        List<Order> pedido = [SELECT Id, Status FROM Order];

        System.assertEquals('Error', pedido[0].Status,'Error al crear la orden en estado de Error');
    }
}