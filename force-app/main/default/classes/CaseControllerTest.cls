@IsTest
public with sharing class CaseControllerTest {
	@TestSetup
	static void makeData(){
		Id pricebookId = Test.getStandardPricebookId();

		Account account = Build.anAccount()
			.withPriceBook(pricebookId)
			.withName('Account Test Name')
			.build();
		insert account;

		Product2 productOne = Build.aProduct()
			.withName('Test N ' + Math.random() * 100)
			.withProductCode('0001')
			.withIdSap('0001')
			.withIsActive(true)
			.build();
		insert productOne;

		Product2 productTwo = Build.aProduct()
			.withName('Test N ' + Math.random() * 100)
			.withProductCode('0002')
			.withIdSap('0002')
			.withIsActive(true)
			.build();
		insert productTwo;

		List<PricebookEntry> pricebooksEntries = [
										SELECT  IsActive,
												Pricebook2Id,
												Product2Id,
												UnitPrice
										FROM PricebookEntry
										WHERE Pricebook2Id = :pricebookId
		];

		
		PricebookEntry pricebookEntryOne = pricebooksEntries[0];		
		PricebookEntry pricebookEntryTwo = pricebooksEntries[1];

		Order order = Build.anOrder()
			.withAccount(account)
			.withStatus('Borrador')
			.withEffectiveDate(Date.today())
			.withPricebook(pricebookId)
			.withPurchaseOrder('')
			.withBusinessUnit('5771')
			.withIdExterno('1234')
			.build();
		insert order;

		OrderItem orderItemOne = Build.anOrderItem()
			.withOrder(order)
			.withProduct2Id(pricebookEntryOne.Product2Id)
			.withListPrice(100)
			.withUnitPrice(100)
			.withQuantity(1000)
			.withPricebookEntryId(pricebookEntryOne)
			.build();
		insert orderItemOne;

		OrderItem orderItemTwo = Build.anOrderItem()
			.withOrder(order)
			.withProduct2Id(pricebookEntryTwo.Product2Id)
			.withListPrice(100)
			.withUnitPrice(100)
			.withQuantity(1000)
			.withPricebookEntryId(pricebookEntryTwo)
			.build();
		insert orderItemTwo;

		Dan360_Remito__c deliveryNote = Build.aRemito()
			.withPedido(order)
			.withSucursal(account)
			.build();
		insert deliveryNote;

		Dan360_Factura__c invoice = Build.aFactura()
			.withPedido(order)
			.withRemito(deliveryNote)
			.build();
		insert invoice;


		Dan360_ProductoDeFactura__c invoiceProduct = Build.aProductoDeFactura()
			.withCantidadProductoFacturado(orderItemOne.Quantity)
			.withFactura(invoice)
			.withProducto(productOne)
			.withPrecioUnitario(100)
			.build();
		insert invoiceProduct;

		Dan360_ProductoDeRemito__c deliveryNoteProduct = Build.aProductoDeRemito()
			.withCantidadProducto(50)
			.withProducto(productOne)
			.withRemito(deliveryNote)
			.build();
		insert deliveryNoteProduct;
	}

	@IsTest
	private static void cuandoConsultoProductosDeFacturaDeberiaObtenerListado() {
		Id invoiceId = [
			SELECT  Id
			FROM    Dan360_Factura__c
			LIMIT   1
		].Id;

		Test.startTest();
			List<CaseController.WrapperProductComplaint> productsToComplaint = CaseController.getInvoiceProducts(invoiceId, 'Dan360_Factura__c');
		Test.stopTest();

		System.assertNotEquals(0, productsToComplaint.size(), 'No se encontraron productos de esta factura.');
	}

	@IsTest
	private static void cuandoConsultoProductosDeRemitoDeberiaObtenerListado() {
		Id deliveryNoteId = [
			SELECT  Id
			FROM    Dan360_Remito__c
			LIMIT   1
		].Id;

		Test.startTest();
			List<CaseController.WrapperProductComplaint> productsToComplaint = CaseController.getInvoiceProducts(deliveryNoteId, 'Dan360_Remito__c');
		Test.stopTest();

		System.assertNotEquals(0, productsToComplaint.size(), 'No se encontraron productos de este remito.');
	}

	@IsTest
	private static void cuandoEnvioTipoDeReclamoDeberiaObtenerFieldSetAsociado() {
		Test.startTest();
			String fieldSet = CaseController.getFieldSet('Dan360_ReclamoDevolucion');
		Test.stopTest();

		System.assertNotEquals(null, fieldSet, 'No se obtuvo el fieldSet para devoluciones.');
	}

	@IsTest
	private static void deberiaGuardarReclamo() {
		Dan360_Factura__c invoice = [
			SELECT  Id,
					Dan360_Pedido__c,
					Dan360_Remito__c
			FROM    Dan360_Factura__c
			LIMIT   1
		];

		Account account = [SELECT Id FROM Account LIMIT 1];

		Id recordType = CaseController.getRecordTypeId('Dan360_Devoluciones');

		Case complaint = Build.aReclamo()
			.withAccount(account)
			.withCantidadADevolver('20 unidades de PKU ANAMIX INFANT 6X400G MLL 3')
			.withFactura(invoice)
			.withMotivoDeReclamo('DEVCVEN')
			.withPedido(invoice.Dan360_Pedido__c)
			.withRemito(invoice.Dan360_Remito__c)
			.withSucursal(account)
			.withRecordType(recordType)
			.build();

		List<Dan360_ProductosDeReclamo__c> complaintProducts = new List<Dan360_ProductosDeReclamo__c>();
		complaintProducts.add(
			Build.aProductoDeReclamo()
				.withCantidadDevolver('5 unidades de Producto 2')
				.withProducto([SELECT Id FROM Product2 LIMIT 1])
				.withRecordType(complaint.RecordType)
				.build()
		);

		Test.startTest();
			ServerResponse response = CaseController.saveComplaint(complaint, complaintProducts, true);
		Test.stopTest();

		System.assertEquals('SUCCESS', response.state, 'No se registró reclamo.');
	}

	@IsTest
	private static void cuandoListaDeProductosVaciaNoDeberiaRegistrarReclamo() {
		Dan360_Factura__c invoice = [
			SELECT  Id,
					Dan360_Pedido__c,
					Dan360_Remito__c
			FROM    Dan360_Factura__c
			LIMIT   1
		];

		Account account = [SELECT Id FROM Account LIMIT 1];

		Case complaint = Build.aReclamo()
			.withAccount(account)
			.withCantidadADevolver('20 unidades de PKU ANAMIX INFANT 6X400G MLL 3')
			.withFactura(invoice)
			.withMotivoDeReclamo('DEVCVEN')
			.withPedido(invoice.Dan360_Pedido__c)
			.withRemito(invoice.Dan360_Remito__c)
			.withSucursal(account)
			.withRecordType('0124C000000LddeQAC')
			.build();

		List<Dan360_ProductosDeReclamo__c> complaintProducts = new List<Dan360_ProductosDeReclamo__c>();

		Test.startTest();
			ServerResponse response = CaseController.saveComplaint(complaint, complaintProducts, true);
		Test.stopTest();

		System.assertEquals('ERROR', response.state, 'Reclamo registrado.');
	}

	@IsTest
	private static void deberiaObtenerDatosDeFactura() {
		Dan360_Factura__c invoice = [
			SELECT  Id,
					Dan360_Pedido__c
			FROM    Dan360_Factura__c
			LIMIT   1
		];

		Test.startTest();
			Object invoiceToValidate = CaseController.getInvoiceOrDeliveryNoteData(invoice.Id, 'Dan360_Factura__c');
		Test.stopTest();

		System.assertNotEquals(null, invoiceToValidate, 'No fue posible obtener datos de factura.');
	}

	@IsTest
	private static void deberiaObtenerDatosDeRemito() {
		Dan360_Factura__c invoice = [
			SELECT  Id,
					Dan360_Remito__c
			FROM    Dan360_Factura__c
			LIMIT   1
		];

		Test.startTest();
			Object invoiceToValidate = CaseController.getInvoiceOrDeliveryNoteData(invoice.Dan360_Remito__c, 'Dan360_Remito__c');
		Test.stopTest();

		System.assertNotEquals(null, invoiceToValidate, 'No fue posible obtener datos de remito.');
	}

	@IsTest
	private static void deberiaObtenerRecordTypeId() {
		Test.startTest();
			Id recordTypeId = CaseController.getRecordTypeId('Dan360_Devoluciones');
		Test.stopTest();

		System.assertNotEquals('', recordTypeId, 'No fue posible obtener RecordTypeId.');
	}

	@IsTest
	private static void cuandoConsultoProductosDeFacturaDeberiaObtenerListadoConLasCantidadesYaReclamadas() {
		Dan360_Factura__c invoice = [
			SELECT  Id,
					Dan360_Pedido__c,
					Dan360_Remito__c
			FROM    Dan360_Factura__c
			LIMIT   1
		];

		Account account = [SELECT Id FROM Account LIMIT 1];

		Id recordType = CaseController.getRecordTypeId('Dan360_Devoluciones');

		Case complaint = Build.aReclamo()
			.withAccount(account)
			.withCantidadADevolver('20 unidades de PKU ANAMIX INFANT 6X400G MLL 3')
			.withFactura(invoice)
			.withMotivoDeReclamo('DEVCVEN')
			.withPedido(invoice.Dan360_Pedido__c)
			.withRemito(invoice.Dan360_Remito__c)
			.withSucursal(account)
			.withRecordType(recordType)
			.build();

		List<Dan360_ProductosDeReclamo__c> complaintProducts = new List<Dan360_ProductosDeReclamo__c>();
		complaintProducts.add(
			Build.aProductoDeReclamo()
				.withCantidadDevolver('5')
				.withProducto([SELECT Id FROM Product2 WHERE ProductCode = '0001'])
				.withRecordType(complaint.RecordType)
				.build()
		);

		Case complaint2 = Build.aReclamo()
			.withAccount(account)
			.withCantidadADevolver('20 unidades de PKU ANAMIX INFANT 6X400G MLL 3')
			.withFactura(invoice)
			.withMotivoDeReclamo('DEVCVEN')
			.withPedido(invoice.Dan360_Pedido__c)
			.withRemito(invoice.Dan360_Remito__c)
			.withSucursal(account)
			.withRecordType(recordType)
			.build();

		List<Dan360_ProductosDeReclamo__c> complaintProducts2 = new List<Dan360_ProductosDeReclamo__c>();
		complaintProducts2.add(
			Build.aProductoDeReclamo()
				.withCantidadProductosFaltantes('15')
				.withProducto([SELECT Id FROM Product2 WHERE ProductCode = '0001'])
				.withRecordType(complaint.RecordType)
				.build()
		);

		Test.startTest();
			ServerResponse response = CaseController.saveComplaint(complaint, complaintProducts, true);
			ServerResponse response2 = CaseController.saveComplaint(complaint2, complaintProducts2, true);
			List<CaseController.WrapperProductComplaint> productsToComplaint = CaseController.getInvoiceProducts(invoice.Id, 'Dan360_Factura__c');
		Test.stopTest();


		System.assertEquals('SUCCESS', response.state, response.message);
		System.assertEquals('SUCCESS', response2.state, response2.message);
		System.assertNotEquals(0, productsToComplaint.size(), 'No se encontraron productos de esta factura.');
		System.assertEquals(20, productsToComplaint[0].productQuantityClaimed, 'No se encontro la cantidad reclamada consolidada para el producto.');
	}
	@IsTest
	private static void deberiaGuardarReclamoSinProductos(){
		Dan360_Factura__c invoice = [
			SELECT  Id,
					Dan360_Pedido__c,
					Dan360_Remito__c
			FROM    Dan360_Factura__c
			LIMIT   1
		];

		Account account = [SELECT Id FROM Account LIMIT 1];

		Id recordType = CaseController.getRecordTypeId('Dan360_Devoluciones');

		Case complaint = Build.aReclamo()
			.withAccount(account)
			.withCantidadADevolver('20 unidades de PKU ANAMIX INFANT 6X400G MLL 3')
			.withFactura(invoice)
			.withMotivoDeReclamo('DEVCVEN')
			.withPedido(invoice.Dan360_Pedido__c)
			.withRemito(invoice.Dan360_Remito__c)
			.withSucursal(account)
			.withRecordType(recordType)
			.build();

		Test.startTest();
			ServerResponse response = CaseController.saveComplaint(complaint, null, false);
		Test.stopTest();

		System.assertEquals('SUCCESS', response.state, response.message);
	}

	@IsTest
	private static void noDeberiaGuardarReclamoConProductos(){
		Dan360_Factura__c invoice = [
			SELECT  Id,
					Dan360_Pedido__c,
					Dan360_Remito__c
			FROM    Dan360_Factura__c
			LIMIT   1
		];

		Account account = [SELECT Id FROM Account LIMIT 1];

		Id recordType = CaseController.getRecordTypeId('Dan360_Devoluciones');

		Case complaint = Build.aReclamo()
			.withAccount(account)
			.withCantidadADevolver('20 unidades de PKU ANAMIX INFANT 6X400G MLL 3')
			.withFactura(invoice)
			.withMotivoDeReclamo('DEVCVEN')
			.withPedido(invoice.Dan360_Pedido__c)
			.withRemito(invoice.Dan360_Remito__c)
			.withSucursal(account)
			.withRecordType(recordType)
			.build();

		List<Dan360_ProductosDeReclamo__c> complaintProducts = new List<Dan360_ProductosDeReclamo__c>();
		complaintProducts.add(
			Build.aProductoDeReclamo()
				.withCantidadProductosFaltantes('15')
				.withProducto([SELECT Id FROM Product2 WHERE ProductCode = '0001'])
				.withRecordType(complaint.RecordType)
				.build()
		);

		Test.startTest();
			ServerResponse response = CaseController.saveComplaint(null, complaintProducts, true);
		Test.stopTest();

		System.assertEquals('ERROR', response.state, response.message);
	}
	@IsTest
	private static void deberiaObtenerElApiName(){
		Dan360_Factura__c invoice = [
			SELECT  Id					
			FROM    Dan360_Factura__c
			LIMIT   1
		];
		
		Test.startTest();
			String apiName = CaseController.getObjApiName(invoice.id);
		Test.stopTest();

		System.assertEquals('Dan360_Factura__c', apiName, 'Error al obtener el api name');
	}
	@IsTest
	private static void deberiaObtenerLaFacturaDelPedido(){
		Id pricebookId = Test.getStandardPricebookId();

		Account account = [
			SELECT id
			FROM Account
			LIMIT 1
		];
		
		Order order = Build.anOrder()
			.withAccount(account)
			.withStatus('Borrador')
			.withEffectiveDate(Date.today())
			.withPricebook(pricebookId)
			.withPurchaseOrder('')
			.withBusinessUnit('5771')
			.withIdExterno('77777')
			.build();
		insert order;

		Dan360_Factura__c invoice = Build.aFactura()
			.withPedido(order)			
			.build();
		insert invoice;
		
		Test.startTest();
		Object invoiceToCompare = CaseController.getFacturaByOrder(order.id);
		Test.stopTest();
		List<Object> invoiceList = new List<Object>();
		invoiceList.add(invoiceToCompare);
		
		System.assertEquals(1, invoiceList.size(), 'Error al obtener la factura por Id del pedido');
	}

	@IsTest
	private static void remitoFromNotChargeOrder(){		

		List<Dan360_Remito__c> remito = [SELECT Id FROM Dan360_Remito__c];
		
		Test.startTest();
		Boolean isNotCharge = CaseController.isDevliveryFromNotCharge(remito[0].id,'Dan360_Remito__c');
		Test.stopTest();
		System.debug(isNotCharge);
		System.assertEquals(false, isNotCharge);
	}
}