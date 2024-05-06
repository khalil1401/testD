@isTest
public with sharing class sendOrdersToSapHelperTest {
    static XHttpCalloutMock getResponse;
    static {
        List<OrderItem> orderItems = new List<OrderItem>();

        RecordType pedidoVentaDirecta = [
            SELECT id 
            FROM RecordType
            WHERE sObjectType='Order' and Name = 'Pedido de Venta Directa'
        ]; 
        RecordType pedidoSinCargo = [
            SELECT id 
            FROM RecordType 
            WHERE sObjectType='Order' and Name = 'Pedido sin Cargo'
        ];
        RecordType devoluciones = [
            SELECT id, Name 
            FROM RecordType 
            WHERE Name = 'Devoluciones'
        ];


        Id pricebookId = Test.getStandardPricebookId();

        Account account = Build.anAccount()
            .withPricebook(pricebookId)
            .withName('Account Test')
            .withIdSap('550071632')
			.build();
		insert account;

        Product2 producto = Build.aProduct()
            .withName('Product for Test')
            .withUnidadesBulto(15)
            .withProductCode('00012')
            .withIsActive(true)
            .build();
        insert producto;

        Product2 productoTwo = Build.aProduct()
            .withName('Producto Test2')
            .withUnidadesBulto(15)
            .withProductCode('00015')
            .withIsActive(true)
            .build();
        insert productoTwo;

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
            .withPricebook(pricebookId)
            //.withBusinessUnit('5800')
            .withRecordType(pedidoVentaDirecta.Id)
            .withDescription('test')
            .withCustomerSalesArea(customerSalesArea)
            .build();
        orderTestAMN.Dan360_UnidadNegocio__c = '5800';
        insert orderTestAMN;
        
        Order orderTestNuBa = Build.anOrder()
            .withAccount(account)
            .withEffectiveDate(Date.today())
            .withEndDate(Date.today())
            .withFechaCierreCarrito(DateTime.now().addDays(5))
            .withFechaInicioCarrito(DateTime.now().addDays(1))
            .withStatus('Borrador')
            .withPurchaseOrder('00000743')
            .withPricebook(pricebookId)
            //.withBusinessUnit('5771')
            .withRecordType(pedidoSinCargo.Id)
            .withDescription('test')
            .withCustomerSalesArea(customerSalesArea)
            .build();

        orderTestNuBa.Dan360_UnidadNegocio__c = '5771';
        insert orderTestNuBa;

        for (PricebookEntry pricebookEntry : pricebooksEntries) {
            orderItems.add(
                Build.anOrderItem()
                    .withOrder(orderTestAMN)
                    .withProduct2Id(pricebookEntry.Product2Id)
                    .withListPrice(100)
                    .withUnitPrice(100)
                    .withQuantity(1)
                    .withPricebookEntryId(pricebookEntry)
                    .withDiscount(0.5)
                    .build()
            );
        }
    
        insert orderItems;

        Dan360_Partner__c partnetShiptTo = Build.aPartner()
            .withName('Partner Shipt To')
            .withIdExterno('0')
            .withRol('WE')
            .withClient(account)
            .withCustomerSalesArea(customerSalesArea)
            .build();        

        insert partnetShiptTo;

        Dan360_Partner__c partnetSoldTo = Build.aPartner()
            .withName('Partner Sold To')
            .withIdExterno('3814320001')
            .withRol('AG')
            .withClient(account)
            .withCustomerSalesArea(customerSalesArea)
            .build();        
        
        insert partnetSoldTo;

        Dan360_Factura__c factura = Build.aFactura()
            .withPedido(orderTestAMN)
            .withSucursal(account)
            .withClient(account)
            .build();
        insert factura;


        Id rtReturnCase = Schema.SObjectType.case.getRecordTypeInfosByName().get('Devoluciones').getRecordTypeId();
       // Id rtClaimCase = Schema.SObjectType.case.getRecordTypeInfosByName().get('Demora en la entrega').getRecordTypeId();
        Id rtReturnForMissing = Schema.SObjectType.case.getRecordTypeInfosByName().get('Reclamo por faltantes').getRecordTypeId();

        Case returnCase = Build.aReclamo()
            .withAccount(account)
            .withFactura(factura)
            .withPedido(orderTestAMN.Id)
            .withMotivoDeReclamo('PRODA')
            .withRecordType(rtReturnCase)
            .build();
        insert returnCase;

        Case claimCase = Build.aReclamo()
            .withAccount(account)
            .withFactura(factura)
            .withPedido(orderTestAMN.Id)
            .withRecordType(rtReturnForMissing)
            .build();
        insert claimCase;

        Dan360_ProductosDeReclamo__c productReturnCase = Build.aProductoDeReclamo()
            .withUnidadMedida('PCE')
            .withIdLinea('00010')
            .withCantidadDevolver('10')
            .withProducto(producto)
            .withReclamo(returnCase.Id)
            .build();
        insert productReturnCase;

        Dan360_ProductosDeReclamo__c productClaimCase = Build.aProductoDeReclamo()
            .withUnidadMedida('PCE')
            .withIdLinea('00010')
            .withCantidadDevolver('10')
            .withProducto(producto)
            .withReclamo(claimCase.Id)
            .build();
        insert productClaimCase;

        insert new ApiDanone__c(URL__c = 'https://www.danapi.com.ar',User_Key__c = 'c3366a9f16190d9efda328ecec6f6833', User_Key_Price__c = 'c3366a9f16190d9efda328ecec6f6833', urlMatPrices__c = '/testing/masterdata/price/',UrlCreateOrderExtension__c = '/testing/sales/orders/v1' );

		String datee = String.valueOf(Date.today().year())+'-'+Date.today().month().format()+'-'+Date.today().day().format();
		getResponse = new XHttpCalloutMock();
        getResponse.buildResponse()
			.withStatus('OK')
			.withStatusCode(200)
			.withBody(SapPricesMock.getSucess())
			.addForAddress(WebServiceSap.SERVICE_CONFIG.URL__c + WebServiceSap.SERVICE_CONFIG.urlMatPrices__c + 'sn?date='+datee+'&organizationId='+salesArea.Dan360_SalesOrganization__c+'&channelId='+salesArea.Dan360_DistributionChannel__c+'&divisionId='+salesArea.Dan360_Division__c+'&customer='+account.Id_SAP__c);
    }

    @isTest
    public static void getMapWithProductsFromOrder(){
        Test.setMock(HttpCalloutMock.class, getResponse);
        Map<String, Order> mapTest = new Map<String, Order>();
        Order orderTest = [
            SELECT id, EndDate, Orden_de_compra__c, EffectiveDate, Dan360_FechaInicioCarrito__c, 
            Dan360_FechaCierreCarrito__c, Description, Dan360_UnidadNegocio__c,RecordType.Name, 
            AccountId, OrderNumber, Dan360_CustomerSalesArea__c,CreatedDate, Dan360_OrderReason__c
            FROM Order 
            WHERE Orden_de_compra__c = '00000742'
        ];
        mapTest.put(orderTest.Id, orderTest);
        String typeObj = 'Order';
        Test.startTest();
            List<sendOrdersToSapHelper.OrderSAP> mapBody = new sendOrdersToSapHelper().getMapWithProducts(mapTest,typeObj);
        Test.stopTest();

        System.assertEquals(1, mapBody.size(), 'No se creo el MAPA');
    }

    @isTest
    public static void getDifferentMapIfRecordTypeCaseIsReturnType(){
        Test.setMock(HttpCalloutMock.class, getResponse);
        Map<String, Case> mapTest = new Map<String, Case>();
        Id rtReturnCase = Schema.SObjectType.case.getRecordTypeInfosByName().get('Devoluciones').getRecordTypeId();
        Case reclamo = [
            SELECT Id, CaseNumber, RecordType.Name, Dan360_MotivoDeReclamo__c,Dan360_Pedido__c, Dan360_EnviadoSAP__c,
            Description, Dan360_RequiredDeliveryDate__c, Dan360_OrderedDate__c, Dan360_OrderGetStart__c,Dan360_OrderGetEnd__c,
            Dan360_Remito__r.Dan360_Delivery__c, Dan360_Factura__r.Dan360_Id_Externo__c,CreatedDate
            FROM Case 
            WHERE RecordTypeId = :rtReturnCase
            ];
            mapTest.put(reclamo.Id, reclamo);
            String typeObj = 'Case';
            System.Test.startTest();
            List<sendOrdersToSapHelper.OrderSAP> mapBody = new sendOrdersToSapHelper().getMapWithProducts(mapTest,typeObj);
            System.Test.stopTest();
            System.assertEquals(1, mapBody.size(), 'No se creo el MAPA');
        }
        
    @isTest
    public static void getDifferentMapIfRecordTypeCaseIsClaimType(){
        Test.setMock(HttpCalloutMock.class, getResponse);
        Map<String, Case> mapTest = new Map<String, Case>();
        Id rtClaimCase = Schema.SObjectType.case.getRecordTypeInfosByName().get('Reclamo por faltantes').getRecordTypeId();
        Case reclamo = [
            SELECT Id, CaseNumber, RecordType.Name,Dan360_Pedido__c, Dan360_EnviadoSAP__c,
            Description, Dan360_RequiredDeliveryDate__c, Dan360_OrderedDate__c, Dan360_OrderGetStart__c,Dan360_OrderGetEnd__c,
            Dan360_Remito__r.Dan360_Delivery__c, Dan360_Factura__r.Dan360_Id_Externo__c, CreatedDate, Dan360_MotivoDeReclamo__c
            FROM Case 
            WHERE RecordTypeId = :rtClaimCase
        ];
        String typeObj = 'Case';
        mapTest.put(reclamo.Id, reclamo);
        System.Test.startTest();
        List<sendOrdersToSapHelper.OrderSAP> mapBody = new sendOrdersToSapHelper().getMapWithProducts(mapTest,typeObj);
        System.Test.stopTest();
        System.assertEquals(1, mapBody.size(), 'No se creo el MAPA');
    }
}