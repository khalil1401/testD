@isTest
public with sharing class sendOrderToSapControllerTest {
	static XHttpCalloutMock getResponse;
	static XHttpCalloutMock getBadResponse;
	static{
		
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
			.withSalesDistric('E-Commerce')
			.withDistributionChannel('00')
			.build();
		insert account;

		Product2 producto = Build.aProduct()
			.withName('Product for Test')
			.withUnidadesBulto(15)			
			.withIdSap('106959')
			.withIsActive(true)
			.build();
		insert producto;

		Product2 productoTwo = Build.aProduct()
			.withName('Producto Test2')
			.withUnidadesBulto(15)
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
            .withDivision('00')
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
			.withBusinessUnit('5800')
			.withRecordType(pedidoVentaDirecta.Id)
			.withDescription('test')
			.withCustomerSalesArea(customerSalesArea)
			.build();
		insert orderTestAMN;

		for(PricebookEntry pricebookEntry : pricebooksEntries) {
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
	
        Dan360_Partner__c shipt = Build.aPartner()
            .withIdExterno('0')
            .withRol('WE')
            .withClient(account)
            .withName('Ship to')
			.withCustomerSalesArea(customerSalesArea)
            .build();
        insert shipt;

        Dan360_Partner__c sold = Build.aPartner()
            .withIdExterno('3814320001')
            .withRol('AG')
            .withClient(account)
            .withName('Sold to')
			.withCustomerSalesArea(customerSalesArea)
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


		
		insert new ApiDanone__c(URL__c = 'https://www.danapi.com.ar',User_Key__c = 'c3366a9f16190d9efda328ecec6f6833', User_Key_Price__c = 'c3366a9f16190d9efda328ecec6f6833', urlMatPrices__c = '/testing/masterdata/price/',UrlCreateOrderExtension__c = '/testing/sales/orders/v2' );

		String datee = String.valueOf(Date.today().year())+'-'+Date.today().month().format()+'-'+Date.today().day().format();
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

		
	}

	@isTest
	public static void enqueBatchJobSendOrderSap() {
		Test.setMock(HttpCalloutMock.class, getResponse);
		Order anOrder = [
						SELECT id,Status,Dan360_PedidoConfirmado__c
						FROM Order 
						LIMIT 1
		];
		anOrder.Status = 'Confirmado';
		anOrder.Dan360_PedidoConfirmado__c = true;
		update anOrder;

		Test.startTest();
		sendOrderToSapController.sendOrderToSap(anOrder.Id);
		Test.stopTest();

		AsyncApexJob AAJ = [SELECT id, Status, CompletedDate,
								CreatedBy.Email, CreatedBy.Name,
								NumberOfErrors
							FROM AsyncApexJob
							LIMIT 1
		];

		System.debug(' AAJ.Status ------>'+ AAJ.Status);

		System.assertEquals('Completed',  AAJ.Status, 'El batch no fue encolado');
	}
	@isTest
	public static void enqueBatchJobSendOrderSapFlow() {
		Test.setMock(HttpCalloutMock.class, getResponse);
		List<String> orders = new List<String>();
		Order anOrder = [
						SELECT id 
						FROM Order
						WHERE Orden_de_compra__c = '00000742' 
						LIMIT 1
		];
		anOrder.Status = 'Confirmado';
		anOrder.Dan360_PedidoConfirmado__c = true;
		update anOrder;

		orders.add(anOrder.id);

		
		String errorMensaje;
		try {
			System.debug('testtry');
            Test.startTest();
            	sendOrderToSapController.sendOrderToSapFlow(orders);
            Test.stopTest(); 
        } catch (Exception err) {
			System.debug('testcatch');
           errorMensaje = err.getMessage();
        }
        System.assertEquals(null,  errorMensaje, 'El batch no fue encolado');
	}

    @isTest
    public static void notEnqueBatchJobSendOrderSapIfDraft() {
		Test.setMock(HttpCalloutMock.class, getResponse);
		Order anOrder = [
						SELECT id 
						FROM Order 
						LIMIT 1
		];
		anOrder.Status = 'Borrador';
		update anOrder;
        
        String errorMensaje;
        try {
            Test.startTest();
		    sendOrderToSapController.sendOrderToSap(anOrder.Id);
		    Test.stopTest(); 
        } catch (Exception err) {
           errorMensaje = err.getMessage();
        }

		System.assertEquals('Error: La Orden no esta Confirmada',  errorMensaje, 'El Batch fue encolado');
	}

	@isTest
	public static void enqueBatchJobSendCaseSap() {
		Test.setMock(HttpCalloutMock.class, getResponse);
		Case caso = [
						SELECT Id, CaseNumber, Dan360_MotivoDeReclamo__c, RecordType.Name, Dan360_Pedido__c,Dan360_EnviadoSAP__c, Description,
						Dan360_RequiredDeliveryDate__c, Dan360_OrderedDate__c, Dan360_OrderGetStart__c,Dan360_OrderGetEnd__c,
						Dan360_Remito__r.Dan360_Delivery__c, Dan360_Factura__r.Dan360_Id_Externo__c,CreatedDate
						FROM Case 
						LIMIT 1
		];
        
        String errorMensaje;
        try {
            Test.StartTest();
		    	sendOrderToSapController.sendCaseToSap(caso.Id);
			Test.stopTest();
        } catch (Exception err) {
           errorMensaje = err.getMessage();
        }

		System.assertEquals(null,  errorMensaje, 'El Batch fue encolado');
	}

	@isTest
	public static void sendOrderToSapFutureSendEmailWhenHaveABadResponse() {
		Test.setMock(HttpCalloutMock.class, getResponse);		
		String body = '{"items":[{"um":"Unidad","orderedQuantity":1.00,"matNumber":"","itemNumber":1},{"um":"Unidad","orderedQuantity":1.00,"matNumber":"","itemNumber":2}],"note":"test","poNumber":"00000742","poType":"","orderGetFinal":"2022-08-03T16:02:41.000Z","orderGetStart":"2022-07-30T16:02:41.000Z","orderDate":"2022-07-29T00:00:00.000Z","reqDelDate":"2022-07-29T00:00:00.000Z","isFreeOfCharge":false,"channelId":"01","organizationId":"5800","companyCode":"5800","businessModel":"B2B","shipTo":"550071632","soldTo":"550071632","orderNumber":"00102282","source":"SAFO"}';
		String typeObj = 'Order';
		String recordName = 'Pedido de Venta Directa';

		Test.startTest();
        	WebServiceSap.SendAlta respuesta = WebServiceSap.sendAltaToSap(body, typeObj, recordName);			
		Test.stopTest();
        sendOrderToSapController.sendEmail(respuesta);
		system.assertEquals(1, Limits.getEmailInvocations(), 'El mail no fue enviado');
		
	}

}