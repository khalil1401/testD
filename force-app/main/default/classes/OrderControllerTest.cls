/**
 * @description       :
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             :
 * @last modified on  : 16-12-2021
 * @last modified by  : Diego Valle
 **/
@isTest
private with sharing class OrderControllerTest {
	@testSetup
	static void generarData() {
		List<Order> orders = new List<Order>();
		List<OrderItem> orderItems = new List<OrderItem>();
		List<Product2> products = new List<Product2>();

		Id pricebookId = Test.getStandardPricebookId();

		Account account = Build.anAccount()
			.withName('Test Account')
			.withPriceBook(pricebookId)
			.build();
		insert account;

		for (Integer i = 1; i <= 3; i++) {
			products.add(
				Build.aProduct()
					.withName('Test N ' + i)
					.withIsActive(true)
					.build()
			);
		}
		insert products;

		List<PricebookEntry> pricebooksEntries = [
										SELECT  IsActive,Pricebook2Id,Product2Id,UnitPrice
										FROM PricebookEntry
										WHERE Pricebook2Id = :pricebookId];
		id pedidoVentaDirecta = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('Dan360_PedidoVentaDirecta').getRecordTypeId();

		for (Integer i = 1; i <= 10; i++) {
			orders.add(
				Build.anOrder()
					.withAccount(account)
					.withStatus('Borrador')
					.withEffectiveDate(Date.today())
					.withPricebook(pricebookId)
					.withRecordType(pedidoVentaDirecta)
					.withPurchaseOrder('')
					.withBusinessUnit('5771')
					.build()
			);
		}
		insert orders;

		for (Order order : orders) {
			for (PricebookEntry pricebookEntry : pricebooksEntries) {
				orderItems.add(
					Build.anOrderItem()
						.withOrder(order)
						.withProduct2Id(pricebookEntry.Product2Id)
						.withListPrice(100)
						.withUnitPrice(100)
						.withQuantity(1000)
						.withPricebookEntryId(pricebookEntry)
						.build()
				);
			}
		}
		insert orderItems;
	}

	static List<Order> generarOrden(Integer numberOfOrders, Boolean withProducts, String idExterno) {
		List<Order> orders = new List<Order>();
		List<OrderItem> orderItems = new List<OrderItem>();
		List<Product2> products = new List<Product2>();
		id pedidoVentaDirecta = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('Dan360_PedidoVentaDirecta').getRecordTypeId();
		Id pricebookId = Test.getStandardPricebookId();

		Account account = Build.anAccount()
			.withName('Test Account')
			.build();
		insert account;

		for (Integer i = 1; i <= 3; i++) {
			products.add(
				Build.aProduct()
					.withName('Test N ' + Math.random() * 100)
					.build()
			);
		}

		insert products;

		List<PricebookEntry> pricebooksEntries = [
			SELECT  IsActive,Pricebook2Id,Product2Id,UnitPrice
			FROM PricebookEntry
			WHERE Pricebook2Id = :pricebookId];

		for (Integer i = 1; i <= numberOfOrders; i++) {
			orders.add(
				Build.anOrder()
					.withAccount(account)
					.withStatus('Borrador')
					.withEffectiveDate(Date.Today())
					.withPricebook(pricebookId)
					.withPurchaseOrder('')
					.withRecordType(pedidoVentaDirecta)
					.withBusinessUnit('5771')
					.withIdExterno(idExterno + i)
					.build()
			);
		}

		insert orders;

		if (withProducts) {
			for (Order order : orders) {
				for (PricebookEntry pricebookEntry : pricebooksEntries) {

					OrderItem orderItem = Build.anOrderItem()
						.withOrder(order)
						.withProduct2Id(pricebookEntry.Product2Id)
						.withListPrice(100)
						.withUnitPrice(100)
						.withQuantity(1000)
						.withPricebookEntryId(pricebookEntry)
						.build();

					orderItems.add(orderItem);
				}
			}

			insert orderItems;
		}

		return orders;
	}

	@isTest
	private static void cuandoRecibeOrdenDeberiaGenerarUnaNueva() {
		// Debería tener dos ordenes creadas.
		Order order = [
			SELECT  FIELDS(STANDARD),
					Orden_de_compra__c,
					Dan360_UnidadNegocio__c
			FROM    Order
			LIMIT   1
		];

		order.Status = 'Confirmado';
		order.Dan360_Id_Externo__c = order.OrderNumber+'Test';
		update order;

		Test.startTest();
			ServerResponse response = OrderController.Duplicate(order.Id, order);
		Test.stopTest();

		List<Order> ordersAfter = [
			SELECT  Id
			FROM    Order
		];

		// En el setup se insertan 10 órdenes.
		System.assertEquals('SUCCESS', response.state, 'No se registró la nueva orden clonada.');
		System.assertEquals(11, ordersAfter.size(), 'No se registró la nueva orden clonada.');
	}

	@isTest
	private static void cuandoGeneraNuevaOrdenDeberiaTenerMismoNumeroDeItems() {
		// Se ejecuta controller la nueva orden debería tener el mismo número de items.
		Order order = [
			SELECT  FIELDS(STANDARD),
					Orden_de_compra__c,
					Dan360_UnidadNegocio__c,
					Dan360_Id_Externo__c
			FROM    Order
			LIMIT   1
		];

		order.Dan360_UnidadNegocio__c = '5771';
		order.Dan360_Id_Externo__c = order.OrderNumber+'Test';
		update order;

		Test.startTest();
			ServerResponse response = OrderController.Duplicate(order.Id, order);
		Test.stopTest();

		List<OrderItem> originalOrderItems = [SELECT Id FROM OrderItem WHERE OrderId = :order.Id];
		List<OrderItem> duplicatedOrderItems = [SELECT Id FROM OrderItem WHERE OrderId = :response.data.ToString()];

		System.assertEquals(originalOrderItems.size(), duplicatedOrderItems.size(), 'El número de items no corresponde con la orden original.');
	}

	@isTest
	private static void cuandoOcurreExcepcionNoDeberiaGenerarNuevaOrden() {
		// Si hay una excepción no debería generarse orden.
		Order order = [
			SELECT  Id,
					Dan360_UnidadNegocio__c
			FROM    Order
			LIMIT   1
		];

		order.Status = 'Confirmado';
		order.Dan360_UnidadNegocio__c = '5771';
		update order;

		Test.startTest();
			ServerResponse response = OrderController.Duplicate(order.Id, order);
		Test.stopTest();

		List<Order> orders = [
			SELECT  Id
			FROM    Order
		];

		System.assertEquals('ERROR', response.state, 'La duplicación no marcó error');
		System.assertNotEquals(11, orders.size(), 'La orden se generó aún cuándo hay excepción.');
	}

	@isTest
	private static void cuandoNuevaOrdenDeberiaGenerarseConEstatusBorrador() {
		// El pedido nuevo debería estar en borrador.
		Order order = [
			SELECT  FIELDS(STANDARD),
					Orden_de_compra__c,
					Dan360_UnidadNegocio__c
            FROM    Order
            LIMIT   1
		];

		order.Status = 'Confirmado';
		order.Dan360_UnidadNegocio__c = '5771';
		order.Dan360_Id_Externo__c = order.OrderNumber+'Test';
		update order;

		Test.startTest();
			ServerResponse response = OrderController.Duplicate(order.Id, order);
		Test.stopTest();

		String statusOrder = [SELECT Status FROM Order WHERE Id = :response.data.ToString()].Status;
		System.assertEquals('Borrador', statusOrder, 'Orden clonada y generada con estatus incorrecto.');
	}

	@isTest
	private static void cuandoOrdenNuevaRecibeUnParametroNuloNoDebeGenerarse() {
		// Si recibe un parámetro null no debería generarse la orden
		Order order = [SELECT FIELDS(STANDARD), Dan360_UnidadNegocio__c FROM Order LIMIT 1];

		order.Status = 'Confirmado';
		order.Dan360_UnidadNegocio__c = '5771';
		update order;

		Test.startTest();
			ServerResponse response = OrderController.Duplicate(null, order);
		Test.stopTest();

		System.assertEquals('ERROR', response.state, '');
		List<Order> orders = [SELECT Id FROM Order];
		System.assertNotEquals(11, orders.size(), 'La orden se generó con campo vacío.');
	}

	@isTest
	private static void cuandoRecibePedidoEnEstadoBorradorDeberiaDuplicar() {
		Order order = [
			SELECT FIELDS(STANDARD), Orden_de_compra__c, Dan360_UnidadNegocio__c 
			FROM Order 
			LIMIT 1];

		order.Dan360_Id_Externo__c = order.OrderNumber+'Test';
		update order;

		Test.startTest();
			ServerResponse response = OrderController.Duplicate(order.Id, order);
		Test.stopTest();

		List<Order> totalOrders = [SELECT Id FROM Order];
		System.assertEquals(11, totalOrders.size(), 'La orden no se duplicó.');
	}

	@isTest
	private static void cuandoDuplicaPedidoDebeValidarQuePedidoOriginalTengaProductosAsociados() {
		Order order = generarOrden(1, false, '1234')[0];

		Test.startTest();
			ServerResponse response = OrderController.Duplicate(order.Id, order);
		Test.stopTest();

		Integer totalOrders = [SELECT Id FROM Order].size();
		System.assertEquals('ERROR', response.State, 'La orden se duplicó exitosamente.');
	}

	@isTest
	private static void cuandoDuplicaPedidoDebeValidarQueLosProductosDeOrdenOriginalSeEncuentrenVigentes() {
		Order order = [
			SELECT  FIELDS(STANDARD),
					Orden_de_compra__c,
					Dan360_UnidadNegocio__c
			FROM    Order
			LIMIT   1
		];

		order.Dan360_Id_Externo__c = order.OrderNumber+'Test';
		update order;

		List<OrderItem> orderItems = [
			SELECT  FIELDS(STANDARD)
			FROM    OrderItem
			WHERE   OrderId = :order.Id
			LIMIT   1
		];

		Product2 product = [
			SELECT  FIELDS(STANDARD)
			FROM    Product2
			WHERE   Id = :orderItems[0].Product2Id
		];

		product.IsActive = false;

		update product;

		Test.startTest();
			ServerResponse response = OrderController.Duplicate(order.Id, order);
		Test.stopTest();

		Id orderId = response.data.ToString();
		List<OrderItem> newOrderItems = [
			SELECT  Id
			FROM    OrderItem
			WHERE   OrderId = :orderId
		];

		System.assertEquals(2, newOrderItems.size(), 'La orden se duplicó con todos los productos de la orden original.');
	}

	@isTest
	private static void cuandoSeConfirmanOrdenesRetenidasPorCuotaConSemaforoVerdeDeberiaActualizarEstado() {
		List<Order> orders = [SELECT Id, Dan360_SemaforoPicklist__c, Status FROM Order LIMIT 5];

		for (Order order : orders) {
			order.Dan360_SemaforoPicklist__c = 'Verde';
			order.Status = 'Retenido por cuota';
		}

		update orders;

		Test.startTest();
		ServerResponse response = OrderController.Confirm(orders);
		Test.stopTest();

		Object data = response.data;
		TreeGrid grid = (TreeGrid)data;
		List<Order> gridData = (List<Order>)grid.GridData;

		System.assertEquals(5, gridData.size(), 'No se confirmaron las órdenes');
	}

	@isTest
	private static void cuandoExistenOrdenesRetenidasConSemaforoVerdeDeberiaDevolverRegistros() {
		List<Order> orders = [
			SELECT  Id,
					Dan360_SemaforoPicklist__c,
					Status
			FROM    Order
			LIMIT   5
		];

		for (Order order : orders) {
			order.Dan360_SemaforoPicklist__c = 'Verde';
			order.Status = 'Retenido por cuota';
		}

		update orders;

		Test.startTest();
		ServerResponse response = OrderController.GetRetainedOrders();
		Test.stopTest();

		Object data = response.data;
		TreeGrid grid = (TreeGrid)data;
		List<Order> gridData = (List<Order>)grid.GridData;

		System.assertEquals(5, gridData.size(), 'Las órdenes retenidas no son las esperadas.');
	}

	// @isTest
	// private static void cuandoOcurreUnErrorDuranteActualizacionDeberiaDevolverEnRespuesta() {
	// 	List<Order> orders = [
	// 		SELECT  Id,
	// 				Dan360_SemaforoPicklist__c,
	// 				Status,
	// 				Orden_de_compra__c
	// 		FROM    Order
	// 		LIMIT   5
	// 	];

	// 	Order order1 = orders[0];
	// 	order1.Orden_de_compra__c = '00000350';
	// 	Order order2 = orders[1];
	// 	order2.Orden_de_compra__c = '00000350';

	// 	update order1;
	// 	update order2;

	// 	for (Order order : orders) {
	// 		order.Status = 'Retenido por cuota';
	// 		order.Dan360_SemaforoPicklist__c = 'Verde';
	// 	}

	// 	update orders;

	// 	Test.startTest();
	// 	ServerResponse response = OrderController.Confirm(orders);
	// 	Test.stopTest();

	// 	System.assertNotEquals(0, response.errors.size(), 'No ocurrieron los erróres esperados.');
	// }

	@isTest
	private static void obtieneLosCamposDelObjeto() {
		Order orderTest = [
			SELECT RecordTypeId
			FROM Order
			LIMIT 1
		];

		RecordType recordTypeName = [
			SELECT DeveloperName
			FROM RecordType
			WHERE Id = :orderTest.RecordTypeId
			LIMIT 1
		];

		Test.startTest();
			List<String> response = OrderController.getObjectsFields(recordTypeName.DeveloperName);
		Test.stopTest();		
		
		System.assertEquals(false, response.isEmpty(), 'No se escontraron todos los campos.');	
	}
}