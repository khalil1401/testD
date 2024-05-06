@isTest
private with sharing class BatchSendOrdersToSapTest {
    static XHttpCalloutMock getResponse;    
    static XHttpCalloutMock getResponseFailed;    
    static string datee;

	static {
        List<OrderItem> orderItems = new List<OrderItem>();

        insert new ApiDanone__c(URL__c = 'https://www.danapi.com.ar',User_Key__c = 'c3366a9f16190d9efda328ecec6f6833', User_Key_Price__c = 'c3366a9f16190d9efda328ecec6f6833',UrlClaimExtension__c = '/testing/sales/claim/v1',
        UrlreturnExtension__c = '/testing/sales/return/v1', UrlCreateOrderExtension__c = '/testing/sales/orders/v1', urlMatPrices__c = '/testing/masterdata/price/');
		               
        RecordType pedidoVentaDirecta = [SELECT id FROM RecordType where sObjectType='Order' and Name = 'Pedido de Venta Directa'];
        
        Id pricebookId = Test.getStandardPricebookId();
        
        Date todayDate = Date.Today();

        Account account = Build.anAccount()
            .withPricebook(pricebookId)
            .withCanalComercial('E-Commerce')
            .withName('Cuenta Prueba')
            .withIdSap('12345')
            .withSalesDistric('Distribuidores')
            .build();
        
        insert account;

        Product2 producto = Build.aProduct()
            .withName('Producto Test')
            .withUnidadesBulto(15)
            .withProductCode('00012')
            .withIdSap('106959')
            .withIsActive(true)
            .build();

        insert producto;

        Product2 productoTwo = Build.aProduct()
            .withName('Producto Test2')
            .withUnidadesBulto(15)
            .withProductCode('00015')
            .withIdSap('166578')
            .withIsActive(true)
            .build();

        insert productoTwo;

        Dan360_Cuota__c cuotaOne = Build.aCuota()
            .withProducto(producto)
            .withCanalComercial('Acceso')
            .withVigenciaDesde(todayDate)
            .withVigenciaHasta(todayDate.addDays(6))
            .build();
        insert cuotaOne;

        Dan360_Cuota__c cuotaTwo = Build.aCuota()
            .withProducto(productoTwo)
            .withCanalComercial('Acceso')
            .withVigenciaDesde(todayDate)
            .withVigenciaHasta(todayDate.addDays(6))
            .build();
        insert cuotaTwo;

        List<PricebookEntry> pricebooksEntries = [
                                    SELECT  IsActive,Pricebook2Id,Product2Id,UnitPrice
                                    FROM PricebookEntry
                                    WHERE Pricebook2Id = :pricebookId];
           
        Dan360_SalesArea__c salesArea = Build.aSalesArea()
            .withName('AMN-01-01')
            .withIdExterno('5800-01-01')
            .withDistributionChannel('01')
            .withDivision('01')
            .withSalesOrganization('5800')
            .build();

        insert salesArea;

        Dan360_CustomerSalesArea__c customerSalesArea = Build.aCustomerSalesArea()
            .withName('AMN 00')
            .withClient(account)
            .withUnidadNegocio(salesArea)
            .withIdExterno('5678-5800-01-01')
            .build();
        insert customerSalesArea;
        
       
        Order orderTestAMN = Build.anOrder()
            .withAccount(account)
            .withEffectiveDate(Date.today())
            .withEndDate(Date.today())
            .withFechaCierreCarrito(DateTime.now().addDays(5))
            .withFechaInicioCarrito(DateTime.now().addDays(1))
            .withStatus('Borrador')
            .withPurchaseOrder('00000742')
            .withBusinessUnit('5800')
            .withRecordType(pedidoVentaDirecta.Id)
            .withDescription('test')
            .withCustomerSalesArea(customerSalesArea)
            .withPricebook(pricebookId)
            .build();

        insert orderTestAMN;

        for(PricebookEntry pricebookEntry : pricebooksEntries) {
            orderItems.add(
            		Build.anOrderItem()
            			.withOrder(orderTestAMN)
            			.withProduct2Id(pricebookEntry.Product2Id)
            			.withListPrice(PricebookEntry.UnitPrice)
            			.withUnitPrice(PricebookEntry.UnitPrice)
            			.withQuantity(1)
            			.withPricebookEntryId(pricebookEntry)
            			.withDiscount(0.5)
            			.build()
            	);
            }
        
        insert orderItems;

        

        Dan360_Partner__c shipt = Build.aPartner()
            .withIdExterno('0')
            .withRol('WE')
            .withClient(account)
            .withCustomerSalesArea(customerSalesArea)
            .withName('Ship to')
            .build();

        insert shipt;

        Dan360_Partner__c sold = Build.aPartner()
            .withIdExterno('3814320001')
            .withRol('AG')
            .withClient(account)
            .withCustomerSalesArea(customerSalesArea)
            .withName('Sold to')
            .build();

        insert sold;

        Dan360_Factura__c factura = Build.aFactura()
            .withPedido(orderTestAMN)
            .withSucursal(account)
            .withClient(account)
            .build();

        insert factura;

        Id rtReturnCase = Schema.SObjectType.case.getRecordTypeInfosByName().get('Devoluciones').getRecordTypeId();
                
        Case returnCase = Build.aReclamo()
            .withAccount(account)
            .withFactura(factura)
            .withPedido(orderTestAMN.Id)
            .withMotivoDeReclamo('PRODA')
            .withRecordType(rtReturnCase)
            .build();

        insert returnCase;
       
        Dan360_ProductosDeReclamo__c productReturnCase = Build.aProductoDeReclamo()
            .withUnidadMedida('PCE')
            .withIdLinea('00010')
            .withCantidadDevolver('10')
            .withProducto(producto)
            .withReclamo(returnCase.Id)
            .build();

        insert productReturnCase;
              
        datee = String.valueOf(Date.today().year())+'-'+Date.today().month().format()+'-'+Date.today().day().format();
        getResponse = new XHttpCalloutMock();
        getResponse.buildResponse()
			.withStatus('OK')
			.withStatusCode(200)
			.withBody(SapPricesMock.getSucess())
			.addForAddress(WebServiceSap.SERVICE_CONFIG.URL__c + WebServiceSap.SERVICE_CONFIG.urlMatPrices__c + 'sn?date='+datee+'&organizationId='+salesArea.Dan360_SalesOrganization__c+'&channelId='+salesArea.Dan360_DistributionChannel__c+'&divisionId='+salesArea.Dan360_Division__c+'&customer='+account.Id_SAP__c);
			//.addForAddress('https://www.danapi.com.ar/testing/masterdata/price/sn?date='+datee+'&organizationId=5800&channelId=01&divisionId=01&customer=550071632');
		
		getResponse.buildResponse()
			.withStatus('OK')
			.withStatusCode(200)
			.withBody(WebServiceSapMock.getAltaSuccess())
			.addForAddress(WebServiceSap.SERVICE_CONFIG.URL__c + WebServiceSap.SERVICE_CONFIG.UrlCreateOrderExtension__c);

        getResponseFailed = new XHttpCalloutMock();

        getResponseFailed.buildResponse()
        .withStatus('OK')
        .withStatusCode(500)
        .withBody(WebServiceSapMock.getAltaError())
        .addForAddress(WebServiceSap.SERVICE_CONFIG.URL__c + WebServiceSap.SERVICE_CONFIG.UrlCreateOrderExtension__c);

	}
   
    @isTest
    private static void enqueBatchJobAltaCaseSap() {
        Map<String,Case> mapTest = new Map<String,Case>();
        Test.setMock(HttpCalloutMock.class, getResponse);
        Case test = [SELECT Id, CaseNumber, Dan360_MotivoDeReclamo__c, RecordType.Name, Dan360_Pedido__c,Dan360_EnviadoSAP__c, Description, 
        Dan360_RequiredDeliveryDate__c, Dan360_OrderedDate__c, Dan360_OrderGetStart__c,Dan360_OrderGetEnd__c, RecordTypeId,
        Dan360_Remito__r.Dan360_Delivery__c, Dan360_Factura__r.Dan360_Id_Externo__c, CreatedDate FROM Case LIMIT 1];
        
        
        mapTest.put(test.Id, test);
        String typeObj = 'Case';
        Id resultadoId;
        String errorMensaje;  

        System.Test.startTest();
        BatchSendOrdersToSap pruebaBatch = new BatchSendOrdersToSap(mapTest,typeObj);
        resultadoId = Database.executeBatch(pruebaBatch);
        System.Test.stopTest();        
        
        AsyncApexJob AAJ = [SELECT id, Status, CompletedDate,
        CreatedBy.Email, CreatedBy.Name,
        NumberOfErrors
        FROM AsyncApexJob WHERE Id =:resultadoId];
        
        System.assertEquals('Completed',  AAJ.Status, 'El batch no fue encolado');
    }

    @isTest
    private static void enqueBatchJobAltaCaseSapFailed() {
        Map<String,Case> mapTest = new Map<String,Case>();
        Test.setMock(HttpCalloutMock.class, getResponseFailed);
        Case test = [SELECT Id, CaseNumber, Dan360_MotivoDeReclamo__c, RecordType.Name, Dan360_Pedido__c,Dan360_EnviadoSAP__c, Description, 
        Dan360_RequiredDeliveryDate__c, Dan360_OrderedDate__c, Dan360_OrderGetStart__c,Dan360_OrderGetEnd__c, RecordTypeId,
        Dan360_Remito__r.Dan360_Delivery__c, Dan360_Factura__r.Dan360_Id_Externo__c, CreatedDate FROM Case LIMIT 1];
        
        
        mapTest.put(test.Id, test);
        String typeObj = 'Case';
        Id resultadoId;
        String errorMensaje;  

        System.Test.startTest();
        BatchSendOrdersToSap pruebaBatch = new BatchSendOrdersToSap(mapTest,typeObj);
        resultadoId = Database.executeBatch(pruebaBatch);
        System.Test.stopTest();        
        
        AsyncApexJob AAJ = [SELECT id, Status, CompletedDate,
        CreatedBy.Email, CreatedBy.Name,
        NumberOfErrors
        FROM AsyncApexJob WHERE Id =:resultadoId];
        
        System.assertEquals('Completed',  AAJ.Status, 'El batch no fue encolado');
    }

    @isTest
    private static void enqueBatchJobAltaOrderSap() {
        Map<String,Order> mapTest = new Map<String,Order>();
        Test.setMock(HttpCalloutMock.class, getResponse);
        Order test = [
            SELECT FIELDS(STANDARD), Orden_de_compra__c, Dan360_CustomerSalesArea__c, Dan360_OrderReason__c,
            Dan360_UnidadNegocio__c, Dan360_FechaInicioCarrito__c, Dan360_FechaCierreCarrito__c, 
            RecordType.Name FROM Order LIMIT 1];
        test.Status = 'Confirmado';
        test.Dan360_PedidoConfirmado__c = true;
        update test;
        
        mapTest.put(test.Id, test);
        String typeObj = 'Order';
        Id resultadoId;
        String errorMensaje;
        
        System.Test.startTest();
            BatchSendOrdersToSap pruebaBatch = new BatchSendOrdersToSap(mapTest,typeObj);
            resultadoId = Database.executeBatch(pruebaBatch);
        System.Test.stopTest();        

        AsyncApexJob AAJ = [SELECT id, Status, CompletedDate,
                                    CreatedBy.Email, CreatedBy.Name,
                                    NumberOfErrors
                        FROM AsyncApexJob WHERE Id =:resultadoId];

        System.assertEquals('Completed',  AAJ.Status, 'El batch no fue encolado');
    }
}