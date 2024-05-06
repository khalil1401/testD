/**
 * @author            : Diego Valle
 * @created date      : 06-09-2021
 * @group             :
 * @last modified on  : 16-12-2021
 * @last modified by  : Diego Valle
 * @description       :
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   20-08-2021   Diego Valle   Initial Version
**/
@IsTest
public with sharing class OrderTriggerHandlerTest {
	@TestSetup
	static void generarData() {
		List<Order> orders = new List<Order>();
		List<OrderItem> orderItems = new List<OrderItem>();
		List<Product2> products = new List<Product2>();

		Id pricebookId = Test.getStandardPricebookId();

		Account account = Build.anAccount()
			.withPriceBook(pricebookId)
			.withName('Account test')
			.withCanalComercial('E-Commerce')
			.withSalesDistric('Licitaciones;E-Commerce;Others')
			.withDistributionChannel('00')
			.withIdSap('1234')
			.build();
		insert account;

		for (Integer i = 1; i <= 3; i++) {
			products.add(
				Build.aProduct()
					.withName('Test ' + Math.random() * 100)
					.withIsActive(true)
					.build()
			);
		}

		insert products;

		List<Dan360_Cuota__C> dues = new List<Dan360_Cuota__C>();
		List<PricebookEntry> pricebooksEntries = [
										SELECT  IsActive,Pricebook2Id,Product2Id,UnitPrice
										FROM PricebookEntry
										WHERE Pricebook2Id = :pricebookId];
		for (Product2 product : products) {
			dues.add(
				Build.aCuota()
					.withCliente(account)
					.withCuota(1000)
					.withCuotaActiva('Activa')
					.withProducto(product)									
					.withSaldo(1000)
					.withVigenciaDesde(Date.Today())
					.withVigenciaHasta(Date.Today().addDays(1))
					.build()
			);
		}

		insert dues;

		for (Integer i = 1; i <= 10; i++) {
			orders.add(
				Build.anOrder()
					.withAccount(account)
					.withStatus('Borrador')
					.withEffectiveDate(Date.today())
					.withPricebook(pricebookId)
					.withBusinessUnit('5771')
					.withIdExterno('1234'+i)
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

		List<OrderItem> insertedOrders = [SELECT Id FROM OrderItem];
	}

	// #region ·TW [Validación Orden de compra duplicada] | https://xappia.teamwork.com/#tasks/24242917

	@IsTest
	private static void cuandoPedidoEsConfirmadoDeberiaActualizarSiNoExisteMismaOrdenDeCompraParaMismoClienteHoy() {
		List<Order> orders = [
			SELECT  Id,
					Status,
					Orden_de_compra__c
			FROM    Order
			LIMIT   2
		];

		orders[0].Orden_de_compra__c = '00001000';
		orders[0].Status = 'Confirmado';

		update orders[0];

		orders[1].Orden_de_compra__c = '00001000';
		orders[1].Status = 'Confirmado';

		Test.startTest();
			Database.SaveResult result = Database.update(orders[1], false);
		Test.stopTest();

		List<Order> updatedOrders = [
			SELECT  Id
			FROM    Order
			WHERE   Status = 'Confirmado'
		];

		System.assertEquals(1, updatedOrders.size(), 'Se actualizaron órdenes de compra para el mismo cliente el mismo día.');
		System.assertEquals(Label.Orden_de_Compra_Duplicada, result.getErrors()[0].getMessage(), 'Órdenes con misma orden de compra confirmadas');
	}

	@IsTest
	private static void cuandoPedidoEsConfirmadoDeberiaFallarSiYaExisteOrdenDeCompraParaMismoClienteHoy() {
		List<Order> orders = [
			SELECT  Id
			FROM    Order
			LIMIT 1
		];

		for (Order order : orders) {
			order.Orden_de_compra__c = '00000350';
			order.Status = 'Confirmado';
		}

		update orders;

		orders = null;
		orders = [
			SELECT  Id,
					Status
			FROM    Order
			WHERE   Orden_de_compra__c != '00000350'
				AND Status = 'Borrador'
			LIMIT 1
		];

		for (Order order : orders) {
			order.Orden_de_compra__c = '00000350';
			order.Status = 'Confirmado';
		}

		Test.startTest();
			List<Database.SaveResult> results = Database.update(orders, false);
		Test.stopTest();

		for (Database.SaveResult result : results) {
			for (Database.Error error : result.getErrors()) {
				System.assertEquals(
					Label.Orden_de_Compra_Duplicada,
					error.getMessage(),
					'La orden se confirmó correctamente.'
				);
			}
		}
	}

	@IsTest
	private static void cuandoSeActualizaCualquierOtroCampoDePedidoNoDeberiaOcurrirError() {
		Id pricebookId = Test.getStandardPricebookId();
		

		Account account = Build.anAccount()
			.withPriceBook(pricebookId)
			.withName('Account test')
			.withCanalComercial('E-Commerce')
			.withSalesDistric('Licitaciones;E-Commerce;Others')
			.withDistributionChannel('00')
			.build();
		insert account;

		Order anOrder = Build.anOrder()
					.withAccount(account)
					.withStatus('Borrador')
					.withEffectiveDate(Date.today())
					.withPricebook(pricebookId)
					.withBusinessUnit('5771')
					.withIdExterno('1234')
					.build();
		insert anOrder;

		anOrder.EffectiveDate = Date.Today().addDays(2);
		

		Test.startTest();
			update anOrder;
		Test.stopTest();

		List<Order> updatedOrders = [
			SELECT Id
			FROM Order
			WHERE Id = : anOrder.Id			
		];
		System.assertEquals(1, updatedOrders.size(), 'No se actualizó registro.');
	}

	@IsTest
	private static void cuandoPedidoEsConfirmadoSiExisteMismoNumeroDeOrdenConOtroClienteDeberiaActualizarEstatus() {
		Id pricebookId = Test.getStandardPricebookId();
		Order existingOrder = [
			SELECT  Id
			FROM    Order
			LIMIT   1
		];

		existingOrder.Orden_de_compra__c = '00000350';
		existingOrder.Status = 'Confirmado';

		update existingOrder;

		Account account = Build.anAccount()
			.withPricebook(pricebookId)
			.withSalesDistric('Licitaciones;E-Commerce;Others')
			.withName('Account Name Test')
			.build();
		insert account;

		Order anOrder = Build.anOrder()
					.withAccount(account)
					.withStatus('Borrador')
					.withEffectiveDate(Date.today())
					.withPricebook(pricebookId)
					.withBusinessUnit('5771')
					.withPurchaseOrder('00000350')
					.withIdExterno('1234')
					.build();
		insert anOrder;

		List<PricebookEntry> pricebooksEntries = [
										SELECT  IsActive,Pricebook2Id,Product2Id,UnitPrice
										FROM PricebookEntry
										WHERE Pricebook2Id = :pricebookId];

		OrderItem anOrderItem = Build.anOrderItem()
						.withOrder(anOrder)
						.withProduct2Id(pricebooksEntries[0].Product2Id)
						.withListPrice(100)
						.withUnitPrice(100)
						.withQuantity(1000)
						.withPricebookEntryId(pricebooksEntries[0])
						.build();
		insert anOrderItem;
		anOrder.Status = 'Confirmado';
		
		Test.startTest();
			update anOrder;
		Test.stopTest();

		List<Order> updatedOrders = [
			SELECT Id
			FROM Order
			WHERE Orden_de_compra__c = '00000350'
		];
		System.assertEquals(
			2,
			updatedOrders.size(),
			'No pudo confirmar pedidos de distintas cuentas con misma orden de compra.'
		);
	}

	@IsTest
	private static void cuandoPedidoSeEncuentraConfirmadoNoDeberiaPasarNuevamentePorValidacion() {
		Order order = [
			SELECT  Id
			FROM    Order
			LIMIT   1
		];

		order.Status = 'Confirmado';
		order.Orden_de_compra__c = '00000350';

		update order;

		order.Dan360_UnidadNegocio__c = '5771';

		Test.startTest();
			update order;
		Test.stopTest();

		Order updatedOrder = [
			SELECT Id, Dan360_UnidadNegocio__c
			FROM Order
			WHERE Orden_de_compra__c = '00000350'
		];
		System.assertEquals(
			'5771',
			updatedOrder.Dan360_UnidadNegocio__c,
			'No fue posible actualizar registro ya confirmado.'
		);
	}
	

	@IsTest
	private static void cuandoConfirmaPedidoSiHaySuficienteSaldoDeProductosOrdenDeberiaConfirmarse() {
		Set<Id> productIds = new Set<Id>();
		List<Dan360_Cuota__C> dues = new List<Dan360_Cuota__C>();

		Order orderToConfirm = [SELECT Id, Status FROM Order LIMIT 1];
		orderToConfirm.Status = 'Confirmado';

		Test.startTest();
			update orderToConfirm;
		Test.stopTest();

		orderToConfirm = [SELECT Status FROM Order WHERE Id = :orderToConfirm.Id];
		System.assertEquals('Confirmado', orderToConfirm.Status, 'La orden actual no se confirmó.');
	}

	@IsTest
	private static void cuandoConfirmaPedidoSiSaldoNoEsSuficienteEnCuotaPorClienteDeberiaGenerarNuevoPedidoConFaltante() {
		Id pricebookId = Test.getStandardPricebookId();
		
		Account account = Build.anAccount()
			.withPricebook(pricebookId)
			.withName('Account Name Test')
			.withIdSap('12345')
			.withSalesDistric('Licitaciones;E-Commerce;Others')
			.build();
			insert account;
		Product2 product = Build.aProduct()
			.withName('Test ' + Math.random() * 100)
			.withUnidadesBulto(1)
			.withIsActive(true)
			.build();
		insert product;

		Order anOrder = Build.anOrder()
					.withAccount(account)
					.withStatus('Borrador')
					.withEffectiveDate(Date.today())
					.withPricebook(pricebookId)
					.withBusinessUnit('5771')
					.withPurchaseOrder('00000350')
					.withIdExterno('1234')
					.build();
		insert anOrder;

		Order anOrderTwo = Build.anOrder()
					.withAccount(account)
					.withStatus('Borrador')
					.withEffectiveDate(Date.today())
					.withPricebook(pricebookId)
					.withBusinessUnit('5771')
					.withPurchaseOrder('00000353')
					.withIdExterno('1235')
					.build();
		insert anOrderTwo;
		
		List<PricebookEntry> pricebooksEntries = [
			SELECT  IsActive,Pricebook2Id,Product2Id,UnitPrice
			FROM PricebookEntry
			WHERE Pricebook2Id = :pricebookId
			AND Product2Id =:product.Id
			];
		

		Dan360_Cuota__c dues =
			Build.aCuota()						
				.withCuota(1000)
				.withCuotaActiva('Activa')
				.withCliente(account)
				.withProducto(product)										
				.withSaldo(1000)
				.withVigenciaDesde(Date.Today())
				.withVigenciaHasta(Date.Today().addDays(1))
				.build();		
	
		insert dues;
		

		OrderItem anOrderItem = Build.anOrderItem()
						.withOrder(anOrder)
						.withProduct2Id(product)
						.withListPrice(100)
						.withUnitPrice(100)
						.withQuantity(900)
						.withPricebookEntryId(pricebooksEntries[0])
						.build();
		insert anOrderItem;
		
		OrderItem anOrderItemTwo= Build.anOrderItem()
						.withOrder(anOrderTwo)
						.withProduct2Id(product)
						.withListPrice(100)
						.withUnitPrice(100)
						.withQuantity(1500)
						.withPricebookEntryId(pricebooksEntries[0])
						.build();
		insert anOrderItemTwo;
		anOrder.Status = 'Confirmado';
		anOrderTwo.Status = 'Confirmado';
		Test.startTest();
			//Database.SaveResult result = Database.update(anOrder, true);
			Database.SaveResult resultTwo = Database.update(anOrderTwo, true);
		Test.stopTest();

		List<Order> orders = [
			SELECT  Id, Dan360_PedidoPrincipal__c, Status
			FROM    Order
			WHERE   Id = :anOrderTwo.Id
			OR  Dan360_PedidoPrincipal__c = :anOrderTwo.Id
		];

		System.assertEquals(2, orders.size(), 'No se generó desdoble.');
		//System.assertEquals(0, result.getErrors().size(), 'Ocurrieron erróres al generar desdoble.');
	}
	@IsTest
	private static void cuandoConfirmaPedidoSiSaldoNoEsSuficienteEnCuotaPorProductoDeberiaGenerarNuevoPedidoConFaltante() {
		Id pricebookId = Test.getStandardPricebookId();
		
		Account account = Build.anAccount()
			.withPricebook(pricebookId)
			.withName('Account Name Test')
			.withIdSap('12345')
			.withSalesDistric('Distribuidores')	
			.build();
			insert account;
		Product2 product = Build.aProduct()
			.withName('Test 1' )
			.withUnidadesBulto(1)
			.withIsActive(true)
			.build();
		insert product;

		Order anOrder = Build.anOrder()
					.withAccount(account)
					.withStatus('Borrador')
					.withEffectiveDate(Date.today())
					.withPricebook(pricebookId)
					.withBusinessUnit('5771')
					.withPurchaseOrder('00000350')
					.withIdExterno('1234')
					.build();
		insert anOrder;

		Order anOrderTwo = Build.anOrder()
					.withAccount(account)
					.withStatus('Borrador')
					.withEffectiveDate(Date.today())
					.withPricebook(pricebookId)
					.withBusinessUnit('5771')
					.withPurchaseOrder('00000353')
					.withIdExterno('1235')
					.build();
		insert anOrderTwo;
		
		List<PricebookEntry> pricebooksEntries = [
			SELECT  IsActive,Pricebook2Id,Product2Id,UnitPrice
			FROM PricebookEntry
			WHERE Pricebook2Id = :pricebookId
			AND Product2Id =:product.Id
			];
		

		Dan360_Cuota__c dues =
			Build.aCuota()						
				.withCuota(1000)
				.withCuotaActiva('Activa')				
				.withProducto(product)									
				.withSaldo(1000)				
				.withVigenciaDesde(Date.Today())
				.withVigenciaHasta(Date.Today().addDays(1))
				.build();		
	
		insert dues;
		

		OrderItem anOrderItem = Build.anOrderItem()
						.withOrder(anOrder)
						.withProduct2Id(product)
						.withListPrice(100)
						.withUnitPrice(100)
						.withQuantity(900)
						.withPricebookEntryId(pricebooksEntries[0])
						.build();
		insert anOrderItem;
		
		OrderItem anOrderItemTwo= Build.anOrderItem()
						.withOrder(anOrderTwo)
						.withProduct2Id(product)
						.withListPrice(100)
						.withUnitPrice(100)
						.withQuantity(1500)
						.withPricebookEntryId(pricebooksEntries[0])
						.build();
		insert anOrderItemTwo;
		anOrder.Status = 'Confirmado';
		anOrderTwo.Status = 'Confirmado';
		Test.startTest();
			//Database.SaveResult result = Database.update(anOrder, true);
			Database.SaveResult resultTwo = Database.update(anOrderTwo, true);
		Test.stopTest();

		List<Order> orders = [
			SELECT  Id, Dan360_PedidoPrincipal__c, Status
			FROM    Order
			WHERE   Id = :anOrderTwo.Id
			OR  Dan360_PedidoPrincipal__c = :anOrderTwo.Id
		];

		System.assertEquals(2, orders.size(), 'No se generó desdoble.');
		//System.assertEquals(0, result.getErrors().size(), 'Ocurrieron erróres al generar desdoble.');
	}
	@IsTest
	private static void cuandoConfirmaPedidoSiSaldoNoEsSuficienteEnCuotaPoSubsidiaryDeberiaGenerarNuevoPedidoConFaltante() {
		Id pricebookId = Test.getStandardPricebookId();
		Id subsidiaryRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Dan360_Sucursal').getRecordTypeId();
		Account account = Build.anAccount()
			.withPricebook(pricebookId)
			.withName('Account Name Test')
			.withRecordTypeId(subsidiaryRecordTypeId)
			.withSalesDistric('Licitaciones;E-Commerce;Others')
			.withIdSap('12345')		
			.build();
		insert account;
		Product2 product = Build.aProduct()
			.withName('Test 1' )
			.withUnidadesBulto(1)
			.withIsActive(true)
			.build();
		insert product;

		Order anOrder = Build.anOrder()
					.withAccount(account)
					.withStatus('Borrador')
					.withEffectiveDate(Date.today())
					.withPricebook(pricebookId)
					.withBusinessUnit('5771')
					.withPurchaseOrder('00000350')
					.withIdExterno('1234')
					.build();
		insert anOrder;

		Order anOrderTwo = Build.anOrder()
					.withAccount(account)
					.withStatus('Borrador')
					.withEffectiveDate(Date.today())
					.withPricebook(pricebookId)
					.withBusinessUnit('5771')
					.withPurchaseOrder('00000353')
					.withIdExterno('1235')
					.build();
		insert anOrderTwo;
		
		List<PricebookEntry> pricebooksEntries = [
			SELECT  IsActive,Pricebook2Id,Product2Id,UnitPrice
			FROM PricebookEntry
			WHERE Pricebook2Id = :pricebookId
			AND Product2Id =:product.Id
			];
		

		Dan360_Cuota__c dues =
			Build.aCuota()						
				.withCuota(1000)
				.withCuotaActiva('Activa')
				.withCliente(account)								
				.withProducto(product)									
				.withSaldo(1000)				
				.withVigenciaDesde(Date.Today())
				.withVigenciaHasta(Date.Today().addDays(1))
				.build();		
	
		insert dues;
		

		OrderItem anOrderItem = Build.anOrderItem()
						.withOrder(anOrder)
						.withProduct2Id(product)
						.withListPrice(100)
						.withUnitPrice(100)
						.withQuantity(900)
						.withPricebookEntryId(pricebooksEntries[0])
						.build();
		insert anOrderItem;
		
		OrderItem anOrderItemTwo= Build.anOrderItem()
						.withOrder(anOrderTwo)
						.withProduct2Id(product)
						.withListPrice(100)
						.withUnitPrice(100)
						.withQuantity(1500)
						.withPricebookEntryId(pricebooksEntries[0])
						.build();
		insert anOrderItemTwo;
		anOrder.Status = 'Confirmado';
		anOrderTwo.Status = 'Confirmado';
		Test.startTest();
			//Database.SaveResult result = Database.update(anOrder, true);
			Database.SaveResult resultTwo = Database.update(anOrderTwo, true);
		Test.stopTest();

		List<Order> orders = [
			SELECT  Id, Dan360_PedidoPrincipal__c, Status
			FROM    Order
			WHERE   Id = :anOrderTwo.Id
			OR  Dan360_PedidoPrincipal__c = :anOrderTwo.Id
		];

		System.assertEquals(2, orders.size(), 'No se generó desdoble.');
		//System.assertEquals(0, result.getErrors().size(), 'Ocurrieron erróres al generar desdoble.');
	}
	
	@IsTest
	private static void cuandoConfirmaPedidoSiSaldoNoEsSuficienteEnCuotaPorSalesDistricDeberiaGenerarNuevoPedidoConFaltante() {
		Id pricebookId = Test.getStandardPricebookId();
		
		Account account = Build.anAccount()
			.withPricebook(pricebookId)
			.withName('Account Name Test')
			.withSalesDistric('E-Commerce')
			.withIdSap('12345')
			.build();
			insert account;
		Product2 product = Build.aProduct()
			.withName('Test 1' )
			.withUnidadesBulto(1)
			.withIsActive(true)
			.build();
		insert product;

		Order anOrder = Build.anOrder()
					.withAccount(account)
					.withStatus('Borrador')
					.withEffectiveDate(Date.today())
					.withPricebook(pricebookId)
					.withBusinessUnit('5771')
					.withPurchaseOrder('00000350')
					.withIdExterno('1234')
					.build();
		insert anOrder;

		Order anOrderTwo = Build.anOrder()
					.withAccount(account)
					.withStatus('Borrador')
					.withEffectiveDate(Date.today())
					.withPricebook(pricebookId)
					.withBusinessUnit('5771')
					.withPurchaseOrder('00000353')
					.withIdExterno('1235')
					.build();
		insert anOrderTwo;
		
		List<PricebookEntry> pricebooksEntries = [
			SELECT  IsActive,Pricebook2Id,Product2Id,UnitPrice
			FROM PricebookEntry
			WHERE Pricebook2Id = :pricebookId
			AND Product2Id =:product.Id
			];
		

		Dan360_Cuota__c dues =
			Build.aCuota()						
				.withCuota(1000)
				.withCuotaActiva('Activa')				
				.withProducto(product)
				.withCanalComercial('E-Commerce')										
				.withSaldo(1000)				
				.withVigenciaDesde(Date.Today())
				.withVigenciaHasta(Date.Today().addDays(1))
				.build();		
	
		insert dues;
		

		OrderItem anOrderItem = Build.anOrderItem()
						.withOrder(anOrder)
						.withProduct2Id(product)
						.withListPrice(100)
						.withUnitPrice(100)
						.withQuantity(900)
						.withPricebookEntryId(pricebooksEntries[0])
						.build();
		insert anOrderItem;
		
		OrderItem anOrderItemTwo= Build.anOrderItem()
						.withOrder(anOrderTwo)
						.withProduct2Id(product)
						.withListPrice(100)
						.withUnitPrice(100)
						.withQuantity(1500)
						.withPricebookEntryId(pricebooksEntries[0])
						.build();
		insert anOrderItemTwo;
		anOrder.Status = 'Confirmado';
		anOrderTwo.Status = 'Confirmado';
		Test.startTest();
			//Database.SaveResult result = Database.update(anOrder, true);
			Database.SaveResult resultTwo = Database.update(anOrderTwo, true);
		Test.stopTest();

		List<Order> orders = [
			SELECT  Id, Dan360_PedidoPrincipal__c, Status
			FROM    Order
			WHERE   Id = :anOrderTwo.Id
			OR  Dan360_PedidoPrincipal__c = :anOrderTwo.Id
		];

		System.assertEquals(2, orders.size(), 'No se generó desdoble.');
		//System.assertEquals(0, result.getErrors().size(), 'Ocurrieron erróres al generar desdoble.');
	}

	@IsTest
	private static void cuandoConfirmaPedidoSiSaldoEsCeroDeberiaActualizarEstadoComoRetenidoPorCuota() {
		Set<Id> productIds = new Set<Id>();
		List<Dan360_Cuota__C> dues = new List<Dan360_Cuota__C>();

		Order orderToConfirm = [
			SELECT  Id,
					Status
			FROM    Order
			LIMIT   1
		];
		orderToConfirm.Status = 'Confirmado';

		for (OrderItem orderItem : [
			SELECT  Product2Id
			FROM    OrderItem
			WHERE   OrderId = :orderToConfirm.Id
		]) {
			productIds.add(orderItem.Product2Id);
		}

		for (Dan360_Cuota__C quota : [
			SELECT  Id,
					Dan360_Cuota__C
			FROM    Dan360_Cuota__C
			WHERE   Dan360_Producto__c IN :productIds
		]) {
			quota.Dan360_Saldo__c = 0;
			dues.add(quota);
		}

		update dues;

		Test.startTest();
			update orderToConfirm;
		Test.stopTest();

		orderToConfirm = [SELECT Status, Dan360_SemaforoPicklist__c FROM Order WHERE Id = :orderToConfirm.Id];

		System.assertEquals('Retenido por cuota', orderToConfirm.Status, 'La orden actual no se retuvo por cuota.');
		System.assertEquals('Rojo', orderToConfirm.Dan360_SemaforoPicklist__c, 'Semáforo incorrecto pues saldo no es suficiente.');
	}

	@IsTest
	private static void cuandoConfirmaPedidoDeberiaRestarCantidadesEnCuotas() {
		Set<Id> productIds = new Set<Id>();
		List<OrderItem> orderItems = new List<OrderItem>();

		Order orderToConfirm = [
			SELECT  Id,
					Status
			FROM    Order
			LIMIT   1
		];
		orderToConfirm.Status = 'Confirmado';

		for (OrderItem orderItem : [
			SELECT  Id,
					Quantity,
					Product2Id
			FROM    OrderItem
			WHERE   OrderId = :orderToConfirm.Id
		]) {
			orderItem.Quantity = 100;
			productIds.add(orderItem.Product2Id);
			orderItems.add(orderItem);
		}

		update orderItems;

		Test.startTest();
			update orderToConfirm;
		Test.stopTest();

		Boolean success = true;
		for (Dan360_Cuota__c quota : [
			SELECT  Id,
					Dan360_Saldo__c
			FROM    Dan360_Cuota__C
			WHERE   Dan360_Producto__c IN :productIds
		]) {
			system.debug('quota '+ quota.Dan360_Saldo__c);
			success = quota.Dan360_Saldo__c == 900;

			if (!success) {
				break;
			}
		}

		System.assertEquals(true, success, 'La cantidades en cuota no se están actualizando.');
	}

	
	@IsTest
	private static void cuandoNoHayCuotasRegistradasParaProductosDePedidoDeberiaConfirmarse() {
		Set<Id> productIds = new Set<Id>();

		Order orderToConfirm = [
			SELECT  Id,
					Status
			FROM    Order
			LIMIT   1
		];
		orderToConfirm.Status = 'Confirmado';

		for (OrderItem orderItem : [
			SELECT  Product2Id
			FROM    OrderItem
			WHERE   OrderId = :orderToConfirm.Id
		]) {
			productIds.add(orderItem.Product2Id);
		}

		List<Dan360_Cuota__c> dues = [
			SELECT  Id,
					Dan360_EstadoCuota__c
			FROM    Dan360_Cuota__c
			WHERE   Dan360_Producto__c IN :productIds
		];

		
		for (Dan360_Cuota__c quota : dues) {
			quota.Dan360_EstadoCuota__c = 'Inactiva';
		}

		update dues;

		Test.startTest();
			update orderToConfirm;
		Test.stopTest();

		orderToConfirm = [SELECT Status FROM Order WHERE Id = :orderToConfirm.Id];
		System.assertEquals('Confirmado', orderToConfirm.Status, 'Los productos de la orden no tienen cuotas registradas.');
	}
	
	@isTest
	private static void cuandoSendConfirmedOrdersEmailsEsLLamadoDebeEviarUnEmail() {
		List<Order> orders = [
			SELECT Id, Status, CreatedById, OrderNumber 
			FROM Order
		];
		for (Order anOrder : Orders) {
			anOrder.Status ='Confirmado';
		}
		update orders;
		Test.startTest();
			System.assertEquals(0, Limits.getEmailInvocations(), 'Error al enviar el email');
			OrderTriggerHelper.sendConfirmedOrdersEmails(orders);
			System.assertEquals(1, Limits.getEmailInvocations(), 'Error al enviar el email');
		Test.stopTest();

	}
	@isTest
	private static void cuandoSortDuesByProductEsLLamadoDebeDevolverCuotasOrdenadasPorProducto() {
		Product2 product = [
			SELECT Id
			FROM Product2
			LIMIT 1
		];
		List<Dan360_Cuota__c> dues = [
			SELECT Id, Dan360_Producto__c 
			FROM Dan360_Cuota__c			
		];
		
		Test.startTest();			
			Map<Id, List<Dan360_Cuota__c>> result = OrderTriggerHelper.sortDuesByProduct(dues);			
		Test.stopTest();
		
		System.assertEquals(true, result.containsKey(product.Id), 'Error al ordenar por producto');
	}

		
	@IsTest
	private static void cuandoConfirmaPedidoDeberiaActualizarPreciosEnProductosDeOrden() {
		Order order = [SELECT Id FROM Order LIMIT 1];
		PricebookEntry pricebookEntry = [
			SELECT  Id,
					UnitPrice,
					Dan360_Descuento__c
			FROM    PricebookEntry
			LIMIT 1
		];

		pricebookEntry.UnitPrice = 1;
		pricebookEntry.Dan360_Descuento__c = 1;
		order.Status = 'Confirmado';

		update pricebookEntry;

		Test.startTest();
			update order;
		Test.stopTest();

		List<OrderItem> items = [
			SELECT  Id,
					PricebookEntry.UnitPrice,
					PricebookEntry.Dan360_Descuento__c
			FROM    OrderItem
			WHERE   OrderId = :order.Id
				AND PricebookEntryId = :pricebookEntry.Id
		];
		System.assertEquals(1, items[0].PricebookEntry.UnitPrice, 'Los precios en los productos de la orden no se actualizaron.');
		System.assertEquals(1, items[0].PricebookEntry.Dan360_Descuento__c, 'Los precios en los productos de la orden no se actualizaron.');
	}

	// #endregion

}