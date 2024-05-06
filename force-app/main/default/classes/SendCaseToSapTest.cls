@isTest
public with sharing class SendCaseToSapTest {
    static XHttpCalloutMock getResponse;
    static XHttpCalloutMock getPriceResponse;
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
            .build();
        
        insert account;

        Product2 producto = Build.aProduct()
            .withName('Producto Test')
            .withUnidadesBulto(15)
            .withProductCode('00012')
            .withIdSap('106959')
            .build();

        insert producto;

        Product2 productoTwo = Build.aProduct()
            .withName('Producto Test2')
            .withUnidadesBulto(15)
            .withProductCode('00015')
            .withIdSap('166578')
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
        Id rtClaimCase = Schema.SObjectType.case.getRecordTypeInfosByName().get('Diferencia de precios y descuentos').getRecordTypeId();
        Id rtReturnForMissing = Schema.SObjectType.case.getRecordTypeInfosByName().get('Reclamo por faltantes').getRecordTypeId();
        Id rtReturnForReturnWithoutCharge = Schema.SObjectType.case.getRecordTypeInfosByName().get('Devoluciones de pedidos sin cargo').getRecordTypeId();
        
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
            .withRecordType(rtClaimCase)
            .build();

        insert claimCase;

        Case ReturnForMissingCase = Build.aReclamo()
            .withAccount(account)
            .withFactura(factura)
            .withPedido(orderTestAMN.Id)
            .withRecordType(rtReturnForMissing)
            .build();

        insert ReturnForMissingCase;

        Case ReturnForReturnWithoutChargeCase = Build.aReclamo()
            .withAccount(account)
            .withFactura(factura)
            .withPedido(orderTestAMN.Id)
            .withRecordType(rtReturnForReturnWithoutCharge)
            .build();

        insert ReturnForReturnWithoutChargeCase;

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
        productClaimCase.Diferencia_Precio_Unitario__c = 22.22;
        insert productClaimCase;
        
        Dan360_ProductosDeReclamo__c productReturnForReturnWithoutChargeCase = Build.aProductoDeReclamo()
            .withUnidadMedida('PCE')
            .withIdLinea('00010')
            .withCantidadDevolver('10')
            .withProducto(producto)
            .withReclamo(ReturnForReturnWithoutChargeCase.Id)
            .build();
        
        insert productReturnForReturnWithoutChargeCase;

        Dan360_ProductosDeReclamo__c productReturnForMissingCase = Build.aProductoDeReclamo()
            .withUnidadMedida('PCE')
            .withIdLinea('00010')
            .withCantidadDevolver('10')
            .withProducto(producto)
            .withReclamo(ReturnForMissingCase.Id)
            .build();

        insert productReturnForMissingCase;

        getResponse = new XHttpCalloutMock();
        getResponse.buildResponse()
            .withStatus('OK')
            .withStatusCode(200)
            .withBody(WebServiceSapMock.getAltaSuccess())
            .addForAddress(WebServiceSap.SERVICE_CONFIG.URL__c + WebServiceSap.SERVICE_CONFIG.UrlreturnExtension__c);

        datee = String.valueOf(Date.today().year())+'-'+Date.today().month().format()+'-'+Date.today().day().format();
        getPriceResponse = new XHttpCalloutMock();
        getPriceResponse.buildResponse()
            .withStatus('OK')
            .withStatusCode(200)
            .withBody(SapPricesMock.getSucess())
            .addForAddress(WebServiceSap.SERVICE_CONFIG.URL__c + WebServiceSap.SERVICE_CONFIG.urlMatPrices__c + 'sn?date='+datee+'&organizationId='+salesArea.Dan360_SalesOrganization__c+'&channelId='+salesArea.Dan360_DistributionChannel__c+'&divisionId='+salesArea.Dan360_Division__c+'&customer='+account.Id_SAP__c);
            //.addForAddress('https://www.danapi.com.ar/testing/masterdata/price/sn?date='+datee+'&organizationId=5800&channelId=01&divisionId=01&customer=550071632');

    }

    @isTest
    public static void sendReturnCase() {
        Test.setMock(HttpCalloutMock.class, getResponse);
        Case returnCase = [SELECT id FROM Case Where RecordType.Name = 'Devoluciones'];
        List<String> listIdCase = new List<String>{returnCase.Id};
        String errorMensaje;
        try {
            System.Test.startTest();
		    SendCaseToSap.sendCaseToSapFlow(listIdCase);
		    System.Test.stopTest(); 
        } catch (Exception err) {
           errorMensaje = err.getMessage();
        }

		System.assertEquals(null,  errorMensaje, 'El Batch fue encolado');
    }

    @isTest
    public static void sendClaimCase() {
        Test.setMock(HttpCalloutMock.class, getResponse);
        Case claimCase = [SELECT id FROM Case Where RecordType.Name = 'Diferencia de precios y descuentos'];
        
        List<String> listIdCase = new List<String>{claimCase.Id};
        String errorMensaje;
        try {
            System.Test.startTest();
		    SendCaseToSap.sendCaseToSapFlow(listIdCase);
		    System.Test.stopTest(); 
        } catch (Exception err) {
           errorMensaje = err.getMessage();
        }

		System.assertEquals(null,  errorMensaje, 'El Batch fue encolado');
    }

    @isTest
    public static void sendReturnForMissingCase() {
        Test.setMock(HttpCalloutMock.class, getResponse);
        Case ReturnForMissingCase = [SELECT id FROM Case Where RecordType.Name = 'Reclamo por faltantes'];
        List<String> listIdCase = new List<String>{ReturnForMissingCase.Id};
        String errorMensaje;
        try {
            System.Test.startTest();
		    SendCaseToSap.sendCaseToSapFlow(listIdCase);
		    System.Test.stopTest(); 
        } catch (Exception err) {
           errorMensaje = err.getMessage();
        }

		System.assertEquals(null,  errorMensaje, 'El Batch fue encolado');
    }

    @isTest
    public static void sendReturnForReturnWithoutChargeCase() {
        Test.setMock(HttpCalloutMock.class, getResponse);
        Case ReturnForReturnWithoutChargeCase = [SELECT id FROM Case Where RecordType.Name = 'Devoluciones de pedidos sin cargo'];
        List<String> listIdCase = new List<String>{ReturnForReturnWithoutChargeCase.Id};
        String errorMensaje;
        try {
            System.Test.startTest();
		    SendCaseToSap.sendCaseToSapFlow(listIdCase);
		    System.Test.stopTest(); 
        } catch (Exception err) {
           errorMensaje = err.getMessage();
        }

		System.assertEquals(null,  errorMensaje, 'El Batch fue encolado');
    }
}