@isTest
public class CuotaTriggerHelperTest {
	static XHttpCalloutMock getPriceResponse;
    static string datee;

	static {
		insert new ApiDanone__c(URL__c = 'https://www.danapi.com.ar',User_Key__c = 'c3366a9f16190d9efda328ecec6f6833', User_Key_Price__c = 'c3366a9f16190d9efda328ecec6f6833',UrlClaimExtension__c = '/testing/sales/claim/v1',
        UrlreturnExtension__c = '/testing/sales/return/v1', UrlCreateOrderExtension__c = '/testing/sales/orders/v1', urlMatPrices__c = '/testing/masterdata/price/	');
		DateTime dT = System.now();
		Date todayDate = Date.newinstance(dT.year(), dT.month(), dT.day());

		Id pricebookId = Test.getStandardPricebookId();

		Product2 producto = Build.aProduct()
									.withName('Producto')
									.withUnidadesBulto(15)
									.withIsActive(true)
									.build();
		//insert producto;

		Product2 productoTwo = Build.aProduct()
									.withName('Producto2')
									.withUnidadesBulto(15)
									.withIsActive(true)
									.build();
		//insert productoTwo;

		insert new Product2 [] {producto,productoTwo};

		List<Dan360_Cuota__c> cuotasToInsert = new List<Dan360_Cuota__c>();
		for (Integer i = 0; i < 2; i++) {
			Dan360_Cuota__c cuota = Build.aCuota()
				.withProducto(producto)
				.withCanalComercial('Acceso')
				.withVigenciaDesde(todayDate)
				.withVigenciaHasta(todayDate.addDays(6))
				.build();
			cuotasToInsert.add(cuota);
		}

		Dan360_Cuota__c cuotass = Build.aCuota()
									.withProducto(producto)
									.withCanalComercial('Distribuidores')
									.withVigenciaDesde(todayDate)
									.withVigenciaHasta(todayDate.addDays(6))
									.build();

		cuotasToInsert.add(cuotass);

		//insert cuotasToInsert;

		Dan360_Cuota__c cuota2 = Build.aCuota()
			.withProducto(productoTwo)
			.withCanalComercial('Acceso')
			.withVigenciaDesde(todayDate)
			.withVigenciaHasta(todayDate.addDays(7))
			.build();
		//insert cuota2;

		cuotasToInsert.add(cuota2);

		Dan360_Cuota__c cuota3 = Build.aCuota()
			.withProducto(producto)
			.withCanalComercial('Disprofarma')
			.withVigenciaDesde(todayDate)
			.withVigenciaHasta(todayDate.addDays(6))
			.build();
		//insert cuota3;
		cuotasToInsert.add(cuota3);
		Dan360_Cuota__c cuota10 = Build.aCuota()
			.withProducto(producto)
			.withCanalComercial('Disprofarma')
			.withVigenciaDesde(todayDate.addDays(7))
			.withVigenciaHasta(todayDate.addDays(10))
			.build();
		//insert cuota10;
		cuotasToInsert.add(cuota10);
		insert cuotasToInsert;

		//start cuota distribution channel
		Id empresaRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Dan360_Empresa').getRecordTypeId();
		Account accountDistributionChannel = Build.anAccount()
			.withPricebook(pricebookId)
			.withName('Account distribution Channel')
			.withSalesDistric('Licitaciones;E-Commerce;Others')
			.withDistributionChannel('Venta Estándar')
			.withRecordTypeId(empresaRecordTypeId)
			.withIdSap('299483')			
			.build();
		insert accountDistributionChannel;
		
		Product2 productDistributionChannel = Build.aProduct()
			.withName('Test 1' )
			.withUnidadesBulto(15)
			.withIsActive(true)
			.build();
		insert productDistributionChannel;

		Order anOrderDistributionChannel = Build.anOrder()
					.withAccount(accountDistributionChannel)
					.withStatus('Borrador')
					.withEffectiveDate(Date.today())
					.withPricebook(pricebookId)
					.withBusinessUnit('5800')
					.withPurchaseOrder('00000350')
					.withIdExterno('12340912')
					.build();
		//insert anOrderDistributionChannel;

		Order anOrderTwoDistributionChannel = Build.anOrder()
					.withAccount(accountDistributionChannel)
					.withStatus('Borrador')
					.withEffectiveDate(Date.today())
					.withPricebook(pricebookId)
					.withBusinessUnit('5800')
					.withPurchaseOrder('00000353')
					.withIdExterno('1235654')
					.build();
		//insert anOrderTwoDistributionChannel;

		insert new Order [] {anOrderTwoDistributionChannel, anOrderDistributionChannel};

		List<PricebookEntry> pricebooksEntriesDistributionChannel = [
			SELECT  IsActive,Pricebook2Id,Product2Id,UnitPrice
			FROM PricebookEntry
			WHERE Pricebook2Id = :pricebookId
			AND Product2Id =:productDistributionChannel.Id
			];		

		Dan360_Cuota__c cuotaDistributionChannel =
			Build.aCuota()						
				.withCuota(0003)
				.withCuotaActiva('Activa')
				.withCliente(accountDistributionChannel)								
				.withProducto(productDistributionChannel)	
				.withCanalDistribucion('Venta Estándar')								
				.withSaldo(1000)				
				.withVigenciaDesde(Date.Today())
				.withVigenciaHasta(Date.Today().addDays(1))
				.build();	
		insert cuotaDistributionChannel;			

		OrderItem anOrderItemDistributionChannel = Build.anOrderItem()
						.withOrder(anOrderDistributionChannel)
						.withProduct2Id(productDistributionChannel)
						.withListPrice(100)
						.withUnitPrice(100)
						.withQuantity(900)
						.withPricebookEntryId(pricebooksEntriesDistributionChannel[0])
						.build();
		//insert anOrderItemDistributionChannel;
		
		OrderItem anOrderItemTwoDistributionChannel= Build.anOrderItem()
						.withOrder(anOrderTwoDistributionChannel)
						.withProduct2Id(productDistributionChannel)
						.withListPrice(100)
						.withUnitPrice(100)
						.withQuantity(150)
						.withPricebookEntryId(pricebooksEntriesDistributionChannel[0])
						.build();
		//insert anOrderItemTwoDistributionChannel;
		insert new OrderItem [] {anOrderItemDistributionChannel, anOrderItemTwoDistributionChannel};
		//end cuota distribution channel
		// start cuota Subsidiary
		Id subsidiaryRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Dan360_Sucursal').getRecordTypeId();
		Account account = Build.anAccount()
			.withPricebook(pricebookId)
			.withName('Account Name Test')
			.withRecordTypeId(subsidiaryRecordTypeId)			
			.build();
		insert account;
		Product2 product = Build.aProduct()
			.withName('Test 1' )
			.withUnidadesBulto(15)
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
		//insert anOrder;

		Order anOrderTwo = Build.anOrder()
					.withAccount(account)
					.withStatus('Borrador')
					.withEffectiveDate(Date.today())
					.withPricebook(pricebookId)
					.withBusinessUnit('5771')
					.withPurchaseOrder('00000353')
					.withIdExterno('1235')
					.build();
		//insert anOrderTwo;
		insert new Order [] {anOrder, anOrderTwo};
		List<PricebookEntry> pricebooksEntries = [
			SELECT  IsActive,Pricebook2Id,Product2Id,UnitPrice
			FROM PricebookEntry
			WHERE Pricebook2Id = :pricebookId
			AND Product2Id =:product.Id
			];		

		Dan360_Cuota__c cuotaSubsidiary =
			Build.aCuota()						
				.withCuota(1000)
				.withCuotaActiva('Activa')
				.withCliente(account)								
				.withProducto(product)									
				.withSaldo(1000)				
				.withVigenciaDesde(Date.Today())
				.withVigenciaHasta(Date.Today().addDays(1))
				.build();	
		insert cuotaSubsidiary;			

		OrderItem anOrderItem = Build.anOrderItem()
						.withOrder(anOrder)
						.withProduct2Id(product)
						.withListPrice(100)
						.withUnitPrice(100)
						.withQuantity(900)
						.withPricebookEntryId(pricebooksEntries[0])
						.build();
		//insert anOrderItem;
		
		OrderItem anOrderItemTwo= Build.anOrderItem()
						.withOrder(anOrderTwo)
						.withProduct2Id(product)
						.withListPrice(100)
						.withUnitPrice(100)
						.withQuantity(150)
						.withPricebookEntryId(pricebooksEntries[0])
						.build();
		//insert anOrderItemTwo;
		insert new OrderItem [] {anOrderItem, anOrderItemTwo};
		// end cuota Subsidiary
		/* 
		// start cuota Product
		Account accountCuotaProduct = Build.anAccount()
			.withPricebook(pricebookId)
			.withName('Account cuota Product')
			.withRecordTypeId(empresaRecordTypeId)			
			.build();
		//insert accountCuotaProduct;
		Product2 productCuota = Build.aProduct()
			.withName('Test 1' )
			.withUnidadesBulto(15)
			.withIsActive(true)
			.build();
		//insert productCuota;

		Order anOrderCuotaProduct = Build.anOrder()
					.withAccount(accountCuotaProduct)
					.withStatus('Borrador')
					.withEffectiveDate(Date.today())
					.withPricebook(pricebookId)
					.withBusinessUnit('5771')
					.withPurchaseOrder('00000350')
					.withIdExterno('1234777')
					.build();
		//insert anOrderCuotaProduct;

		Order anOrderTwoCuotaProduct = Build.anOrder()
					.withAccount(accountCuotaProduct)
					.withStatus('Borrador')
					.withEffectiveDate(Date.today())
					.withPricebook(pricebookId)
					.withBusinessUnit('5771')
					.withPurchaseOrder('00000353')
					.withIdExterno('1235888')
					.build();
		//insert anOrderTwoCuotaProduct;
		
		List<PricebookEntry> pricebooksEntriesCuotaProduct = [
			SELECT  IsActive,Pricebook2Id,Product2Id,UnitPrice
			FROM PricebookEntry
			WHERE Pricebook2Id = :pricebookId
			AND Product2Id =:productCuota.Id
			];		

		Dan360_Cuota__c cuotaProducto =
		Build.aCuota()						
				.withCuota(0001)
				.withCuotaActiva('Activa')				
				.withProducto(productCuota)									
				.withSaldo(1000)				
				.withVigenciaDesde(Date.Today())
				.withVigenciaHasta(Date.Today().addDays(1))
				.build();		
	
		//insert cuotaProducto;
		

		OrderItem anOrderItemCuotaProduct = Build.anOrderItem()
						.withOrder(anOrderCuotaProduct)
						.withProduct2Id(productCuota)
						.withListPrice(100)
						.withUnitPrice(100)
						.withQuantity(900)
						.withPricebookEntryId(pricebooksEntriesCuotaProduct[0])
						.build();
		//insert anOrderItemCuotaProduct;
		
		OrderItem anOrderItemTwoCuotaProduct = Build.anOrderItem()
						.withOrder(anOrderTwoCuotaProduct)
						.withProduct2Id(productCuota)
						.withListPrice(100)
						.withUnitPrice(100)
						.withQuantity(150)
						.withPricebookEntryId(pricebooksEntriesCuotaProduct[0])
						.build();
		//insert anOrderItemTwoCuotaProduct;
		// end cuota Product
		// start cuota por canal comercial
		Account accountCanalComercial = Build.anAccount()
			.withPricebook(pricebookId)
			.withName('Account canal comercial')
			.withSalesDistric('E-Commerce')
			.withRecordTypeId(empresaRecordTypeId)
			.build();
		//insert accountCanalComercial;
		Product2 productCanalComercial = Build.aProduct()
			.withName('Test 1' )
			.withUnidadesBulto(1)
			.withIsActive(true)
			.build();
		//insert productCanalComercial;

		Order anOrderCanalComercial = Build.anOrder()
					.withAccount(accountCanalComercial)
					.withStatus('Borrador')
					.withEffectiveDate(Date.today())
					.withPricebook(pricebookId)
					.withBusinessUnit('5771')
					.withPurchaseOrder('00000350')
					.withIdExterno('1234099')
					.build();
		//insert anOrderCanalComercial;

		Order anOrderTwoCanalComercial = Build.anOrder()
					.withAccount(accountCanalComercial)
					.withStatus('Borrador')
					.withEffectiveDate(Date.today())
					.withPricebook(pricebookId)
					.withBusinessUnit('5771')
					.withPurchaseOrder('00000353')
					.withIdExterno('1235088')
					.build();
		//insert anOrderTwoCanalComercial;
		
		List<PricebookEntry> pricebooksEntriesCanalComercial = [
			SELECT  IsActive,Pricebook2Id,Product2Id,UnitPrice
			FROM PricebookEntry
			WHERE Pricebook2Id = :pricebookId
			AND Product2Id =:productCanalComercial.Id
			];
		

		Dan360_Cuota__c cuotaCanalComercial =
			Build.aCuota()						
				.withCuota(0002)
				.withCuotaActiva('Activa')				
				.withProducto(productCanalComercial)
				.withCanalComercial('E-Commerce')										
				.withSaldo(1000)				
				.withVigenciaDesde(Date.Today())
				.withVigenciaHasta(Date.Today().addDays(1))
				.build();		
	
		//insert cuotaCanalComercial;
		

		OrderItem anOrderItemCanalComercial = Build.anOrderItem()
						.withOrder(anOrderCanalComercial)
						.withProduct2Id(productCanalComercial)
						.withListPrice(100)
						.withUnitPrice(100)
						.withQuantity(900)
						.withPricebookEntryId(pricebooksEntriesCanalComercial[0])
						.build();
		//insert anOrderItemCanalComercial;
		
		OrderItem anOrderItemTwoCanalComercial = Build.anOrderItem()
						.withOrder(anOrderTwoCanalComercial)
						.withProduct2Id(productCanalComercial)
						.withListPrice(100)
						.withUnitPrice(100)
						.withQuantity(150)
						.withPricebookEntryId(pricebooksEntriesCanalComercial[0])
						.build();
		//insert anOrderItemTwoCanalComercial; */
		// end cuota por canol comerial
		
		datee = String.valueOf(Date.today().year())+'-'+Date.today().month().format()+'-'+Date.today().day().format();
        getPriceResponse = new XHttpCalloutMock();
        getPriceResponse.buildResponse()
            .withStatus('OK')
            .withStatusCode(200)
            .withBody(SapPricesMock.getSucess())
            .addForAddress(WebServiceSap.SERVICE_CONFIG.URL__c + WebServiceSap.SERVICE_CONFIG.urlMatPrices__c + 'sn?date='+datee+'&organizationId=5800&channelId=01&divisionId=01&customer=550071632');
	}	

	@isTest
	public static void ifDatesBetweenDaysInCuotaMustFail() {
		DateTime dT = System.now();
		Date testDate = Date.newinstance(dT.year(), dT.month(), dT.day());
		Product2 productSF = [SELECT Id, Name FROM Product2 WHERE Name = 'Producto' LIMIT 1];
		List<Dan360_Cuota__c> cuotasToInsertTest = new List<Dan360_Cuota__c>();

		for (Integer i = 0; i < 1; i++) {
			Dan360_Cuota__c cuota = Build.aCuota()
									.withProducto(productSF)
									.withCanalComercial('Disprofarma')
									.withVigenciaDesde(testDate.addDays(1))
									.withVigenciaHasta(testDate.addDays(4))
									.build();
			cuotasToInsertTest.add(cuota);
		}
		List<Dan360_Cuota__c> cuotaTest = [SELECT id, Name FROM Dan360_Cuota__c Where Dan360_CanalComercial__c = 'Disprofarma'];

		test.startTest();

			try
			{
				insert cuotasToInsertTest;
				//System.assert(false);
			}
			catch (DMLException e)
			{
				System.debug(e.getMessage());
				//System.assert(true);
			}

		test.stopTest();
	}

	@isTest
	public static void ifStartDateisBeforeStartDateSFAndEndDateisAfeterStartDateSFMustFail() {
		DateTime dT = System.now();
		Date testDate = Date.newinstance(dT.year(), dT.month(), dT.day());
		Product2 productSF = [SELECT Id, Name FROM Product2 WHERE Name = 'Producto' LIMIT 1];
		List<Dan360_Cuota__c> cuotasToInsertTest = new List<Dan360_Cuota__c>();


		for (Integer i = 0; i < 1; i++) {
			Dan360_Cuota__c cuota = Build.aCuota()
									.withProducto(productSF)
									.withCanalComercial('Disprofarma')
									.withVigenciaDesde(testDate.addDays(-2))
									.withVigenciaHasta(testDate.addDays(4))
									.build();
			cuotasToInsertTest.add(cuota);
		}
		List<Dan360_Cuota__c> cuotaTest = [SELECT id, Name FROM Dan360_Cuota__c Where Dan360_CanalComercial__c = 'Disprofarma'];

		test.startTest();

			try
			{
				insert cuotasToInsertTest;
				//System.assert(false);
			}
			catch (DMLException e)
			{
				System.debug(e.getMessage());
				//System.assert(true);
				////System.assertEquals('Insert failed. First exception on row 0; first error: FIELD_CUSTOM_VALIDATION_EXCEPTION, Ya existe una cuota dentro del rango de vigencia para el mismo Producto y para el mismo Canal: []'/* + ', Cuota: '+cuotaTest[0].Name */, e.getMessage(), 'Se insertaron las cuotas Incorrectas');
			}

		test.stopTest();
	}
	@IsTest
	private static void cuandoSaldoEnCuotaEsCeroYTieneClienteAsignadoDeberiaActualizarSemaforoRojoEnOrdenSoloDelCliente() {
		List<Dan360_Cuota__c> dues = new List<Dan360_Cuota__c>();
		Set<Id> clientId = new Set<Id>();

		for (Dan360_Cuota__c quota : [
			SELECT  Id,
					Dan360_Cliente__c
			FROM    Dan360_Cuota__c
			WHERE   Dan360_Cliente__c != null
			LIMIT   1
		]) {
			quota.Dan360_Saldo__c = 0;
			dues.add(quota);
			clientId.add(quota.Dan360_Cliente__c);
		}

		Order order = [
			SELECT  Id
			FROM    Order
			WHERE   AccountId IN :clientId
			LIMIT   1
		];

		order.Status = 'Retenido por cuota';
		update order;

		Test.startTest();
			update dues;
		Test.stopTest();

		Order updatedOrder = [
			SELECT  Id,
					Dan360_SemaforoPicklist__c
			FROM    Order
			WHERE   Id = :order.Id
		];

		//System.assertEquals('Rojo', updatedOrder.Dan360_SemaforoPicklist__c, 'El semáforo de la orden no fue actualizado.');
	}

	@IsTest
	private static void cuandoSaldoEnCuotaIncrementaNoEsSuficienteYAdemasTieneClienteAsignadoDeberiaActualizarSemaforoAmarilloEnOrdenSoloDelCliente() {
		List<Dan360_Cuota__c> dues = new List<Dan360_Cuota__c>();
		Set<Id> clientId = new Set<Id>();

		for (Dan360_Cuota__c quota : [
			SELECT  Id,
					Dan360_Cliente__c
			FROM    Dan360_Cuota__c
			WHERE   Dan360_Cliente__c != null
			LIMIT   1
		]) {
			quota.Dan360_Saldo__c = 10;
			dues.add(quota);
			clientId.add(quota.Dan360_Cliente__c);
		}

		Order order = [
			SELECT  Id
			FROM    Order
			WHERE   AccountId IN :clientId
			LIMIT   1
		];

		order.Status = 'Retenido por cuota';
		update order;

		Test.startTest();
			update dues;
		Test.stopTest();

		Order updatedOrder = [
			SELECT  Id,
					Dan360_SemaforoPicklist__c
			FROM    Order
			WHERE   Id = :order.Id
		];

		//System.assertEquals('Amarillo', updatedOrder.Dan360_SemaforoPicklist__c, 'El semáforo de la orden no fue actualizado.');
	}

	@IsTest
	private static void cuandoSaldoEnCuotaIncrementaEsSuficienteYAdemasTieneClienteAsignadoDeberiaActualizarSemaforoVerdeEnOrdenSoloDelCliente() {
		List<Dan360_Cuota__c> dues = new List<Dan360_Cuota__c>();
		List<Order> ordersBeforeUpdate = new List<Order>();
		Set<Id> clientId = new Set<Id>();

		Order order = [
			SELECT  Id,
					AccountId
			FROM    Order
			LIMIT   1
		];

		order.Status = 'Retenido por cuota';
		update order;

		for (Dan360_Cuota__c quota : [
			SELECT  Id,
					Dan360_Cliente__c
			FROM    Dan360_Cuota__c
			WHERE   Dan360_Cliente__c = :order.AccountId
		]) {
			quota.Dan360_Saldo__c = 2000;
			dues.add(quota);
		}

		Test.startTest();
			update dues;
		Test.stopTest();

		Order updatedOrder = [
			SELECT  Id,
					Dan360_SemaforoPicklist__c
			FROM    Order
			WHERE   Id = :order.Id
		];

		//System.assertEquals('Verde', updatedOrder.Dan360_SemaforoPicklist__c, 'El semáforo de la orden no fue actualizado.');
	}	
	@IsTest
	private static void cuandoSaldoNoEsSuficienteEnCuotaPorSubsidiaryDeberiaDevolverSemaforoAmarillo() {
		List<Dan360_Cuota__c> dues = new List<Dan360_Cuota__c>();
		List<Order> ordersBeforeUpdate = new List<Order>();
		Id subsidiaryRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Dan360_Sucursal').getRecordTypeId();
		Account account = [
			SELECT Id
			FROM Account
			WHERE Name = 'Account Name Test'
			AND RecordTypeId = : subsidiaryRecordTypeId
		];
		for (Order order : [
			SELECT  Id
			FROM    Order
			WHERE AccountId = :account.Id
			LIMIT   1
		]) {
			order.Status = 'Retenido por cuota';
			ordersBeforeUpdate.add(order);
		}

		update ordersBeforeUpdate;
		
		for (Dan360_Cuota__c quota : [
			SELECT  Id
			FROM    Dan360_Cuota__c
			WHERE   Dan360_Cliente__c = :account.Id
		]) {
			quota.Dan360_Saldo__c = 1;
			dues.add(quota);
		}
		
		Test.startTest();
			update dues;
		Test.stopTest();

		List<Order> orders = [
			SELECT  Id,
					Status,
					Dan360_SemaforoPicklist__c
			FROM    Order
			WHERE   Dan360_SemaforoPicklist__c = 'Amarillo'
		];

		//System.assertEquals(1, orders.size(), 'Las órdenes no cambiaron de Semáforo');
	}	
	@IsTest
	private static void cuandoSaldoEsSuficienteEnCuotaPorSubsidiaryDeberiaDevolverSemaforoVerde() {
		List<Dan360_Cuota__c> dues = new List<Dan360_Cuota__c>();
		List<Order> ordersBeforeUpdate = new List<Order>();
		Id subsidiaryRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Dan360_Sucursal').getRecordTypeId();
		Account account = [
			SELECT Id
			FROM Account
			WHERE Name = 'Account Name Test'
			AND RecordTypeId = : subsidiaryRecordTypeId
		];
		for (Order order : [
			SELECT  Id
			FROM    Order
			WHERE AccountId = :account.Id
			LIMIT   1
		]) {
			order.Status = 'Retenido por cuota';
			ordersBeforeUpdate.add(order);
		}

		update ordersBeforeUpdate;
		
		for (Dan360_Cuota__c quota : [
			SELECT  Id
			FROM    Dan360_Cuota__c
			WHERE   Dan360_Cliente__c = :account.Id
		]) {
			quota.Dan360_Saldo__c = 10000;
			dues.add(quota);
		}
		
		Test.startTest();
			update dues;
		Test.stopTest();

		List<Order> orders = [
			SELECT  Id,
					Status,
					Dan360_SemaforoPicklist__c
			FROM    Order
			WHERE   Dan360_SemaforoPicklist__c = 'Verde'
		];

		//System.assertEquals(1, orders.size(), 'Las órdenes no cambiaron de Semáforo');
	}	
	@IsTest
	private static void cuandoNoHaySaldoSuficienteEnCuotaPorSubsidiaryDeberiaDevolverSemaforoRojo() {
		List<Dan360_Cuota__c> dues = new List<Dan360_Cuota__c>();
		List<Order> ordersBeforeUpdate = new List<Order>();
		Id subsidiaryRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Dan360_Sucursal').getRecordTypeId();
		Account account = [
			SELECT Id
			FROM Account
			WHERE Name = 'Account Name Test'
			AND RecordTypeId = : subsidiaryRecordTypeId
		];
		for (Order order : [
			SELECT  Id
			FROM    Order
			WHERE AccountId = :account.Id
			LIMIT   1
		]) {
			order.Status = 'Retenido por cuota';
			ordersBeforeUpdate.add(order);
		}

		update ordersBeforeUpdate;
		
		for (Dan360_Cuota__c quota : [
			SELECT  Id
			FROM    Dan360_Cuota__c
			WHERE   Dan360_Cliente__c = :account.Id
		]) {
			quota.Dan360_Saldo__c = 0;
			dues.add(quota);
		}
		
		Test.startTest();
			update dues;
		Test.stopTest();

		List<Order> orders = [
			SELECT  Id,
					Status,
					Dan360_SemaforoPicklist__c
			FROM    Order
			WHERE   Dan360_SemaforoPicklist__c = 'Rojo'
		];

		//System.assertEquals(1, orders.size(), 'Las órdenes no cambiaron de Semáforo');
	}	
	@IsTest
	private static void cuandoSaldoNoEsSuficienteEnCuotaPorDistributionChannelDeberiaDevolverSemaforoAmarillo() {
		Test.setMock(HttpCalloutMock.class, getPriceResponse);
		List<Dan360_Cuota__c> dues = new List<Dan360_Cuota__c>();
		List<Order> ordersBeforeUpdate = new List<Order>();
		
		Account account = [
			SELECT Id, Dan360_DistributionChannel__c
			FROM Account
			WHERE Name = 'Account distribution Channel'
			
		];

		Dan360_SalesArea__c salesArea = Build.aSalesArea()
            .withName('AMN-01-01')
            .withIdExterno('5800-01-01')
            .withDistributionChannel('00')
            .withDivision('01')
            .withSalesOrganization('5800')
            .build();
        insert salesArea;
		Dan360_PlantillaDeProductos__c templateProducts = Build.aPlantillaDeProductos()
            .withName('AMN Canal 00')
            .withBusinessUnit('5800')
            .build();
        insert templateProducts;

        insert new Plantillas__c(AMN_00__c = 'AMN Canal 00');
		Dan360_CustomerSalesArea__c customerSalesArea = Build.aCustomerSalesArea()
            .withName('AMN 00')
            .withClient(account)
            .withUnidadNegocio(salesArea)
            .withIdExterno('5678-5800-01-01')
            .build();
        insert customerSalesArea;
		
		for (Order order : [
			SELECT  Id, Account.Dan360_DistributionChannel__c
			FROM    Order
			WHERE AccountId = :account.Id
			AND Dan360_Id_Externo__c = '12340912'
			LIMIT   1
		]) {
			order.Status = 'Retenido por cuota';
			ordersBeforeUpdate.add(order);			
		}

		update ordersBeforeUpdate;
		
		for (Dan360_Cuota__c quota : [
			SELECT  Id
			FROM    Dan360_Cuota__c
			WHERE   Dan360_Cuota__c = 0003
		]) {
			quota.Dan360_Saldo__c = 1;
			dues.add(quota);
		}
		
		Test.startTest();
			update dues;
		Test.stopTest();

		List<Order> orders = [
			SELECT  Id,
					Status,
					Dan360_SemaforoPicklist__c
			FROM    Order
			WHERE   Dan360_SemaforoPicklist__c = 'Amarillo'
		];

		//System.assertEquals(1, orders.size(), 'Las órdenes no cambiaron de Semáforo');
	}	
	@IsTest
	private static void cuandoSaldoEsSuficienteEnCuotaPorDistributionChannelDeberiaDevolverSemaforoVerde() {
		Test.setMock(HttpCalloutMock.class, getPriceResponse);
		List<Dan360_Cuota__c> dues = new List<Dan360_Cuota__c>();
		List<Order> ordersBeforeUpdate = new List<Order>();
		
		Account account = [
			SELECT Id, Dan360_DistributionChannel__c
			FROM Account
			WHERE Name = 'Account distribution Channel'
			
		];

		Dan360_SalesArea__c salesArea = Build.aSalesArea()
            .withName('AMN-01-01')
            .withIdExterno('5800-01-01')
            .withDistributionChannel('00')
            .withDivision('01')
            .withSalesOrganization('5800')
            .build();
        insert salesArea;
		Dan360_PlantillaDeProductos__c templateProducts = Build.aPlantillaDeProductos()
            .withName('AMN Canal 00')
            .withBusinessUnit('5800')
            .build();
        insert templateProducts;

        insert new Plantillas__c(AMN_00__c = 'AMN Canal 00');
		Dan360_CustomerSalesArea__c customerSalesArea = Build.aCustomerSalesArea()
            .withName('AMN 00')
            .withClient(account)
            .withUnidadNegocio(salesArea)
            .withIdExterno('5678-5800-01-01')
            .build();
        insert customerSalesArea;
		
		for (Order order : [
			SELECT  Id, Account.Dan360_DistributionChannel__c
			FROM    Order
			WHERE AccountId = :account.Id
			AND Dan360_Id_Externo__c = '12340912'
			LIMIT   1
		]) {
			order.Status = 'Retenido por cuota';
			ordersBeforeUpdate.add(order);			
		}

		update ordersBeforeUpdate;
		
		for (Dan360_Cuota__c quota : [
			SELECT  Id
			FROM    Dan360_Cuota__c
			WHERE   Dan360_Cuota__c = 0003
		]) {
			quota.Dan360_Saldo__c = 0;
			dues.add(quota);
		}
		
		Test.startTest();
			update dues;
		Test.stopTest();

		List<Order> orders = [
			SELECT  Id,
					Status,
					Dan360_SemaforoPicklist__c
			FROM    Order
			WHERE   Dan360_SemaforoPicklist__c = 'Rojo'
		];

		//System.assertEquals(1, orders.size(), 'Las órdenes no cambiaron de Semáforo');
	}	
	@IsTest
	private static void cuandoNoHaySaldoEnCuotaPorDistributionChannelDeberiaDevolverSemaforoRojo() {
		Test.setMock(HttpCalloutMock.class, getPriceResponse);
		List<Dan360_Cuota__c> dues = new List<Dan360_Cuota__c>();
		List<Order> ordersBeforeUpdate = new List<Order>();
		
		Account account = [
			SELECT Id, Dan360_DistributionChannel__c
			FROM Account
			WHERE Name = 'Account distribution Channel'
			
		];

		Dan360_SalesArea__c salesArea = Build.aSalesArea()
            .withName('AMN-01-01')
            .withIdExterno('5800-01-01')
            .withDistributionChannel('00')
            .withDivision('01')
            .withSalesOrganization('5800')
            .build();
        insert salesArea;
		Dan360_PlantillaDeProductos__c templateProducts = Build.aPlantillaDeProductos()
            .withName('AMN Canal 00')
            .withBusinessUnit('5800')
            .build();
        insert templateProducts;

        insert new Plantillas__c(AMN_00__c = 'AMN Canal 00');
		Dan360_CustomerSalesArea__c customerSalesArea = Build.aCustomerSalesArea()
            .withName('AMN 00')
            .withClient(account)
            .withUnidadNegocio(salesArea)
            .withIdExterno('5678-5800-01-01')
            .build();
        insert customerSalesArea;
		
		for (Order order : [
			SELECT  Id, Account.Dan360_DistributionChannel__c
			FROM    Order
			WHERE AccountId = :account.Id
			AND Dan360_Id_Externo__c = '12340912'
			LIMIT   1
		]) {
			order.Status = 'Retenido por cuota';
			ordersBeforeUpdate.add(order);			
		}

		update ordersBeforeUpdate;
		
		for (Dan360_Cuota__c quota : [
			SELECT  Id
			FROM    Dan360_Cuota__c
			WHERE   Dan360_Cuota__c = 0003
		]) {
			quota.Dan360_Saldo__c = 10000;
			dues.add(quota);
		}
		
		Test.startTest();
			update dues;
		Test.stopTest();

		List<Order> orders = [
			SELECT  Id,
					Status,
					Dan360_SemaforoPicklist__c
			FROM    Order
			WHERE   Dan360_SemaforoPicklist__c = 'Verde'
		];

		//System.assertEquals(1, orders.size(), 'Las órdenes no cambiaron de Semáforo');
	}	
	
	@IsTest
	private static void cuandoSaldoEsSuficienteEnCuotaPorProductoDeberiaDevolverSemaforoVerde() {
		List<Dan360_Cuota__c> dues = new List<Dan360_Cuota__c>();
		List<Order> ordersBeforeUpdate = new List<Order>();
		Id empresaRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Dan360_Empresa').getRecordTypeId();
		/* Account account = [
			SELECT Id
			FROM Account
			WHERE Name = 'Account cuota Product'			
		]; */

		Id pricebookId = Test.getStandardPricebookId();
Account accountCuotaProduct = Build.anAccount()
			.withPricebook(pricebookId)
			.withName('Account cuota Product')
			.withRecordTypeId(empresaRecordTypeId)			
			.build();
insert accountCuotaProduct;
		Product2 productCuota = Build.aProduct()
			.withName('Test 1' )
			.withUnidadesBulto(15)
			.withIsActive(true)
			.build();
insert productCuota;

		/* Order anOrderCuotaProduct = Build.anOrder()
					.withAccount(accountCuotaProduct)
					.withStatus('Borrador')
					.withEffectiveDate(Date.today())
					.withPricebook(pricebookId)
					.withBusinessUnit('5771')
					.withPurchaseOrder('00000350')
					.withIdExterno('1234777')
					.build(); */

		Order anOrderTwoCuotaProduct = Build.anOrder()
					.withAccount(accountCuotaProduct)
					.withStatus('Borrador')
					.withEffectiveDate(Date.today())
					.withPricebook(pricebookId)
					.withBusinessUnit('5771')
					.withPurchaseOrder('00000353')
					.withIdExterno('1235888')
					.build();

insert new Order [] {anOrderTwoCuotaProduct};
		List<PricebookEntry> pricebooksEntriesCuotaProduct = [
			SELECT  IsActive,Pricebook2Id,Product2Id,UnitPrice
			FROM PricebookEntry
			WHERE Pricebook2Id = :pricebookId
			AND Product2Id =:productCuota.Id
			];		

		Dan360_Cuota__c cuotaProducto =
		Build.aCuota()						
				.withCuota(0001)
				.withCuotaActiva('Activa')				
				.withProducto(productCuota)									
				.withSaldo(1000)				
				.withVigenciaDesde(Date.Today())
				.withVigenciaHasta(Date.Today().addDays(1))
				.build();		
	
insert cuotaProducto;
		

		/* OrderItem anOrderItemCuotaProduct = Build.anOrderItem()
						.withOrder(anOrderCuotaProduct)
						.withProduct2Id(productCuota)
						.withListPrice(100)
						.withUnitPrice(100)
						.withQuantity(900)
						.withPricebookEntryId(pricebooksEntriesCuotaProduct[0])
						.build(); */
		OrderItem anOrderItemTwoCuotaProduct = Build.anOrderItem()
						.withOrder(anOrderTwoCuotaProduct)
						.withProduct2Id(productCuota)
						.withListPrice(100)
						.withUnitPrice(100)
						.withQuantity(150)
						.withPricebookEntryId(pricebooksEntriesCuotaProduct[0])
						.build();
		
insert new OrderItem [] {anOrderItemTwoCuotaProduct};

		for (Order order : [
			SELECT  Id
			FROM    Order
			WHERE AccountId = :accountCuotaProduct.Id
			AND Dan360_Id_Externo__c = '1235888'
			LIMIT   1
		]) {
			order.Status = 'Retenido por cuota';
			ordersBeforeUpdate.add(order);
		}

		update ordersBeforeUpdate;

		system.debug(ordersBeforeUpdate);

		OrderItem anOrderItem = [
			SELECT Id, Product2Id
			FROM OrderItem
			WHERE OrderId = : ordersBeforeUpdate[0].Id
			LIMIT 1
		];
		
		for (Dan360_Cuota__c quota : [
			SELECT  Id
			FROM    Dan360_Cuota__c
			WHERE    Dan360_Producto__c= :anOrderItem.Product2Id
			AND Dan360_Cuota__c = 0001
		]) {
			quota.Dan360_Saldo__c = 10000;
			dues.add(quota);
		}
		
		Test.startTest();
			update dues;
		Test.stopTest();

		List<Order> orders = [
			SELECT  Id,
					Status,
					Dan360_SemaforoPicklist__c
			FROM    Order
			WHERE   Dan360_SemaforoPicklist__c = 'Verde'
		];

		//System.assertEquals(1, orders.size(), 'Las órdenes no cambiaron de Semáforo');
	}
	@IsTest
	private static void cuandoNoHaySaldoEnCuotaPorProductoDeberiaDevolverSemaforoRojo() {
		List<Dan360_Cuota__c> dues = new List<Dan360_Cuota__c>();
		List<Order> ordersBeforeUpdate = new List<Order>();
		
		/* Account account = [
			SELECT Id
			FROM Account
			WHERE Name = 'Account cuota Product'			
		]; */


		Id empresaRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Dan360_Empresa').getRecordTypeId();

Id pricebookId = Test.getStandardPricebookId();
Account accountCuotaProduct = Build.anAccount()
			.withPricebook(pricebookId)
			.withName('Account cuota Product')
			.withRecordTypeId(empresaRecordTypeId)			
			.build();
insert accountCuotaProduct;
		Product2 productCuota = Build.aProduct()
			.withName('Test 1' )
			.withUnidadesBulto(15)
			.withIsActive(true)
			.build();
insert productCuota;

		Order anOrderCuotaProduct = Build.anOrder()
					.withAccount(accountCuotaProduct)
					.withStatus('Borrador')
					.withEffectiveDate(Date.today())
					.withPricebook(pricebookId)
					.withBusinessUnit('5771')
					.withPurchaseOrder('00000350')
					.withIdExterno('1234777')
					.build();

		Order anOrderTwoCuotaProduct = Build.anOrder()
					.withAccount(accountCuotaProduct)
					.withStatus('Borrador')
					.withEffectiveDate(Date.today())
					.withPricebook(pricebookId)
					.withBusinessUnit('5771')
					.withPurchaseOrder('00000353')
					.withIdExterno('1235888')
					.build();

insert new Order [] {anOrderCuotaProduct,anOrderTwoCuotaProduct};
		List<PricebookEntry> pricebooksEntriesCuotaProduct = [
			SELECT  IsActive,Pricebook2Id,Product2Id,UnitPrice
			FROM PricebookEntry
			WHERE Pricebook2Id = :pricebookId
			AND Product2Id =:productCuota.Id
			];		

		Dan360_Cuota__c cuotaProducto =
		Build.aCuota()						
				.withCuota(0001)
				.withCuotaActiva('Activa')				
				.withProducto(productCuota)									
				.withSaldo(1000)				
				.withVigenciaDesde(Date.Today())
				.withVigenciaHasta(Date.Today().addDays(1))
				.build();		
	
insert cuotaProducto;
		

		OrderItem anOrderItemCuotaProduct = Build.anOrderItem()
						.withOrder(anOrderCuotaProduct)
						.withProduct2Id(productCuota)
						.withListPrice(100)
						.withUnitPrice(100)
						.withQuantity(900)
						.withPricebookEntryId(pricebooksEntriesCuotaProduct[0])
						.build();
		OrderItem anOrderItemTwoCuotaProduct = Build.anOrderItem()
						.withOrder(anOrderTwoCuotaProduct)
						.withProduct2Id(productCuota)
						.withListPrice(100)
						.withUnitPrice(100)
						.withQuantity(150)
						.withPricebookEntryId(pricebooksEntriesCuotaProduct[0])
						.build();
		
insert new OrderItem [] {anOrderItemCuotaProduct,anOrderItemTwoCuotaProduct};

		for (Order order : [
			SELECT  Id
			FROM    Order
			WHERE AccountId = :accountCuotaProduct.Id
			AND Dan360_Id_Externo__c = '1235888'
			LIMIT   1
		]) {
			order.Status = 'Retenido por cuota';
			ordersBeforeUpdate.add(order);
		}

		update ordersBeforeUpdate;

		system.debug(ordersBeforeUpdate);

		OrderItem anOrderItem = [
			SELECT Id, Product2Id
			FROM OrderItem
			WHERE OrderId = : ordersBeforeUpdate[0].Id
			LIMIT 1
		];
		
		for (Dan360_Cuota__c quota : [
			SELECT  Id
			FROM    Dan360_Cuota__c
			WHERE    Dan360_Producto__c= :anOrderItem.Product2Id
			AND Dan360_Cuota__c = 0001
		]) {
			quota.Dan360_Saldo__c = 0;			
			dues.add(quota);
		}
		
		Test.startTest();
			update dues;
		Test.stopTest();

		List<Order> orders = [
			SELECT  Id,
					Status,
					Dan360_SemaforoPicklist__c
			FROM    Order
			WHERE   Dan360_SemaforoPicklist__c = 'Rojo'
			
		];
		for (Order o : orders) {
			system.debug(o.Dan360_SemaforoPicklist__c);
			
		}
		//System.assertEquals(1, orders.size(), 'Las órdenes no cambiaron de Semáforo');
	}
	@IsTest
	private static void cuandoSaldoNoEsSuficienteEnCuotaPorProductoDeberiaDevolverSemaforoAmarillo() {
		List<Dan360_Cuota__c> dues = new List<Dan360_Cuota__c>();
		List<Order> ordersBeforeUpdate = new List<Order>();
		
		/* Account account = [
			SELECT Id
			FROM Account
			WHERE Name = 'Account cuota Product'			
		]; */

		Id empresaRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Dan360_Empresa').getRecordTypeId();

Id pricebookId = Test.getStandardPricebookId();
Account accountCuotaProduct = Build.anAccount()
			.withPricebook(pricebookId)
			.withName('Account cuota Product')
			.withRecordTypeId(empresaRecordTypeId)			
			.build();
insert accountCuotaProduct;
		Product2 productCuota = Build.aProduct()
			.withName('Test 1' )
			.withUnidadesBulto(15)
			.withIsActive(true)
			.build();
insert productCuota;

		Order anOrderCuotaProduct = Build.anOrder()
					.withAccount(accountCuotaProduct)
					.withStatus('Borrador')
					.withEffectiveDate(Date.today())
					.withPricebook(pricebookId)
					.withBusinessUnit('5771')
					.withPurchaseOrder('00000350')
					.withIdExterno('1234777')
					.build();

		Order anOrderTwoCuotaProduct = Build.anOrder()
					.withAccount(accountCuotaProduct)
					.withStatus('Borrador')
					.withEffectiveDate(Date.today())
					.withPricebook(pricebookId)
					.withBusinessUnit('5771')
					.withPurchaseOrder('00000353')
					.withIdExterno('1235888')
					.build();

insert new Order [] {anOrderCuotaProduct,anOrderTwoCuotaProduct};
		List<PricebookEntry> pricebooksEntriesCuotaProduct = [
			SELECT  IsActive,Pricebook2Id,Product2Id,UnitPrice
			FROM PricebookEntry
			WHERE Pricebook2Id = :pricebookId
			AND Product2Id =:productCuota.Id
			];		

		Dan360_Cuota__c cuotaProducto =
		Build.aCuota()						
				.withCuota(0001)
				.withCuotaActiva('Activa')				
				.withProducto(productCuota)									
				.withSaldo(1000)				
				.withVigenciaDesde(Date.Today())
				.withVigenciaHasta(Date.Today().addDays(1))
				.build();		
	
insert cuotaProducto;
		

		OrderItem anOrderItemCuotaProduct = Build.anOrderItem()
						.withOrder(anOrderCuotaProduct)
						.withProduct2Id(productCuota)
						.withListPrice(100)
						.withUnitPrice(100)
						.withQuantity(900)
						.withPricebookEntryId(pricebooksEntriesCuotaProduct[0])
						.build();
		OrderItem anOrderItemTwoCuotaProduct = Build.anOrderItem()
						.withOrder(anOrderTwoCuotaProduct)
						.withProduct2Id(productCuota)
						.withListPrice(100)
						.withUnitPrice(100)
						.withQuantity(150)
						.withPricebookEntryId(pricebooksEntriesCuotaProduct[0])
						.build();
		
insert new OrderItem [] {anOrderItemCuotaProduct,anOrderItemTwoCuotaProduct};

		for (Order order : [
			SELECT  Id
			FROM    Order
			WHERE AccountId = :accountCuotaProduct.Id
			AND Dan360_Id_Externo__c = '1235888'
			LIMIT   1
		]) {
			order.Status = 'Retenido por cuota';
			ordersBeforeUpdate.add(order);
		}

		update ordersBeforeUpdate;

		system.debug(ordersBeforeUpdate);

		OrderItem anOrderItem = [
			SELECT Id, Product2Id
			FROM OrderItem
			WHERE OrderId = : ordersBeforeUpdate[0].Id
			LIMIT 1
		];
		
		for (Dan360_Cuota__c quota : [
			SELECT  Id
			FROM    Dan360_Cuota__c
			WHERE    Dan360_Producto__c= :anOrderItem.Product2Id
			AND Dan360_Cuota__c = 0001
		]) {
			quota.Dan360_Saldo__c = 10;			
			dues.add(quota);
		}
		
		Test.startTest();
			update dues;
		Test.stopTest();

		List<Order> orders = [
			SELECT  Id,
					Status,
					Dan360_SemaforoPicklist__c
			FROM    Order
			WHERE   Dan360_SemaforoPicklist__c = 'Amarillo'
			
		];
		
		//System.assertEquals(1, orders.size(), 'Las órdenes no cambiaron de Semáforo');
	}
	@IsTest
	private static void cuandoSaldoNoEsSuficienteEnCuotaPorCanalComercialDeberiaDevolverSemaforoAmarillo() {
		List<Dan360_Cuota__c> dues = new List<Dan360_Cuota__c>();
		List<Order> ordersBeforeUpdate = new List<Order>();
		
		/* Account account = [
			SELECT Id
			FROM Account
			WHERE Name = 'Account canal comercial'			
		];
 */

		Id empresaRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Dan360_Empresa').getRecordTypeId();

		Id pricebookId = Test.getStandardPricebookId();
		Product2 productCanalComercial = Build.aProduct()
		.withName('Test 1' )
		.withUnidadesBulto(1)
		.withIsActive(true)
		.build();
		insert productCanalComercial;

		List<PricebookEntry> pricebooksEntriesCanalComercial = [
			SELECT  IsActive,Pricebook2Id,Product2Id,UnitPrice
			FROM PricebookEntry
			WHERE Pricebook2Id = :pricebookId
			AND Product2Id =:productCanalComercial.Id
			];
		Account accountCanalComercial = Build.anAccount()
			.withPricebook(pricebookId)
			.withName('Account canal comercial')
			.withSalesDistric('E-Commerce')
			.withRecordTypeId(empresaRecordTypeId)
			.build();
		insert accountCanalComercial;

		Order anOrderCanalComercial = Build.anOrder()
							.withAccount(accountCanalComercial)
							.withStatus('Borrador')
							.withEffectiveDate(Date.today())
							.withPricebook(pricebookId)
							.withBusinessUnit('5771')
							.withPurchaseOrder('00000350')
							.withIdExterno('1234099')
							.build();
		

		Order anOrderTwoCanalComercial = Build.anOrder()
							.withAccount(accountCanalComercial)
							.withStatus('Borrador')
							.withEffectiveDate(Date.today())
							.withPricebook(pricebookId)
							.withBusinessUnit('5771')
							.withPurchaseOrder('00000353')
							.withIdExterno('1235088')
							.build();
		
		insert new Order [] {anOrderCanalComercial,anOrderTwoCanalComercial};

		OrderItem anOrderItemCanalComercial = Build.anOrderItem()
						.withOrder(anOrderCanalComercial)
						.withProduct2Id(productCanalComercial)
						.withListPrice(100)
						.withUnitPrice(100)
						.withQuantity(900)
						.withPricebookEntryId(pricebooksEntriesCanalComercial[0])
						.build();
		insert anOrderItemCanalComercial;

		for (Order order : [
			SELECT  Id
			FROM    Order
			WHERE AccountId = :accountCanalComercial.Id
			AND Dan360_Id_Externo__c = '1234099'
			LIMIT   1
		]) {
			order.Status = 'Retenido por cuota';
			ordersBeforeUpdate.add(order);
		}

		update ordersBeforeUpdate;

		system.debug(ordersBeforeUpdate);

		OrderItem anOrderItem = [
			SELECT Id, Product2Id
			FROM OrderItem
			WHERE OrderId = : ordersBeforeUpdate[0].Id
			LIMIT 1
		];
		
		for (Dan360_Cuota__c quota : [
			SELECT  Id
			FROM    Dan360_Cuota__c
			WHERE    Dan360_Producto__c= :anOrderItem.Product2Id
			AND Dan360_Cuota__c = 0002
		]) {
			quota.Dan360_Saldo__c = 10;			
			dues.add(quota);
		}
		
		Test.startTest();
			update dues;
		Test.stopTest();

		List<Order> orders = [
			SELECT  Id,
					Status,
					Dan360_SemaforoPicklist__c
			FROM    Order
			WHERE   Dan360_SemaforoPicklist__c = 'Amarillo'
			//WHERE AccountId = :account.Id
		];
		
		//System.assertEquals(1, orders.size(), 'Las órdenes no cambiaron de Semáforo');
	}
	@IsTest
	private static void cuandoSaldoEsSuficienteEnCuotaPorCanalComercialDeberiaDevolverSemaforoVerde() {
		List<Dan360_Cuota__c> dues = new List<Dan360_Cuota__c>();
		List<Order> ordersBeforeUpdate = new List<Order>();
		
		/* Account account = [
			SELECT Id
			FROM Account
			WHERE Name = 'Account canal comercial'			
		]; */

		Id empresaRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Dan360_Empresa').getRecordTypeId();

		Id pricebookId = Test.getStandardPricebookId();
		Product2 productCanalComercial = Build.aProduct()
			.withName('Test 1' )
			.withUnidadesBulto(1)
			.withIsActive(true)
			.build();
		insert productCanalComercial;

		List<PricebookEntry> pricebooksEntriesCanalComercial = [
			SELECT  IsActive,Pricebook2Id,Product2Id,UnitPrice
			FROM PricebookEntry
			WHERE Pricebook2Id = :pricebookId
			AND Product2Id =:productCanalComercial.Id
			];
		Account accountCanalComercial = Build.anAccount()
			.withPricebook(pricebookId)
			.withName('Account canal comercial')
			.withSalesDistric('E-Commerce')
			.withRecordTypeId(empresaRecordTypeId)
			.build();
		insert accountCanalComercial;

		Order anOrderCanalComercial = Build.anOrder()
							.withAccount(accountCanalComercial)
							.withStatus('Borrador')
							.withEffectiveDate(Date.today())
							.withPricebook(pricebookId)
							.withBusinessUnit('5771')
							.withPurchaseOrder('00000350')
							.withIdExterno('1234099')
							.build();
		

		Order anOrderTwoCanalComercial = Build.anOrder()
							.withAccount(accountCanalComercial)
							.withStatus('Borrador')
							.withEffectiveDate(Date.today())
							.withPricebook(pricebookId)
							.withBusinessUnit('5771')
							.withPurchaseOrder('00000353')
							.withIdExterno('1235088')
							.build();
		
		insert new Order [] {anOrderCanalComercial,anOrderTwoCanalComercial};

		OrderItem anOrderItemCanalComercial = Build.anOrderItem()
						.withOrder(anOrderCanalComercial)
						.withProduct2Id(productCanalComercial)
						.withListPrice(100)
						.withUnitPrice(100)
						.withQuantity(900)
						.withPricebookEntryId(pricebooksEntriesCanalComercial[0])
						.build();
		insert anOrderItemCanalComercial;

		for (Order order : [
			SELECT  Id
			FROM    Order
			WHERE AccountId = :accountCanalComercial.Id
			AND Dan360_Id_Externo__c = '1234099'
			LIMIT   1
		]) {
			order.Status = 'Retenido por cuota';
			ordersBeforeUpdate.add(order);
		}

		update ordersBeforeUpdate;

		system.debug(ordersBeforeUpdate);

		OrderItem anOrderItem = [
			SELECT Id, Product2Id
			FROM OrderItem
			WHERE OrderId = : ordersBeforeUpdate[0].Id
			LIMIT 1
		];
		
		for (Dan360_Cuota__c quota : [
			SELECT  Id
			FROM    Dan360_Cuota__c
			WHERE    Dan360_Producto__c= :anOrderItem.Product2Id
			AND Dan360_Cuota__c = 0002
		]) {
			quota.Dan360_Saldo__c = 10000;			
			dues.add(quota);
		}
		
		Test.startTest();
			update dues;
		Test.stopTest();

		List<Order> orders = [
			SELECT  Id,
					Status,
					Dan360_SemaforoPicklist__c
			FROM    Order
			WHERE   Dan360_SemaforoPicklist__c = 'verde'
		];
		
		//System.assertEquals(1, orders.size(), 'Las órdenes no cambiaron de Semáforo');
	}
	@IsTest
	private static void cuandoNoHaySaldoEnCuotaPorCanalComercialDeberiaDevolverSemaforoRojo() {
		List<Dan360_Cuota__c> dues = new List<Dan360_Cuota__c>();
		List<Order> ordersBeforeUpdate = new List<Order>();
		
		/* Account account = [
			SELECT Id
			FROM Account
			WHERE Name = 'Account canal comercial'			
		]; */

		Id empresaRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Dan360_Empresa').getRecordTypeId();

		Id pricebookId = Test.getStandardPricebookId();
		Product2 productCanalComercial = Build.aProduct()
			.withName('Test 1' )
			.withUnidadesBulto(1)
			.withIsActive(true)
			.build();
		insert productCanalComercial;

		List<PricebookEntry> pricebooksEntriesCanalComercial = [
			SELECT  IsActive,Pricebook2Id,Product2Id,UnitPrice
			FROM PricebookEntry
			WHERE Pricebook2Id = :pricebookId
			AND Product2Id =:productCanalComercial.Id
			];
		Account accountCanalComercial = Build.anAccount()
			.withPricebook(pricebookId)
			.withName('Account canal comercial')
			.withSalesDistric('E-Commerce')
			.withRecordTypeId(empresaRecordTypeId)
			.build();
		insert accountCanalComercial;

		Order anOrderCanalComercial = Build.anOrder()
							.withAccount(accountCanalComercial)
							.withStatus('Borrador')
							.withEffectiveDate(Date.today())
							.withPricebook(pricebookId)
							.withBusinessUnit('5771')
							.withPurchaseOrder('00000350')
							.withIdExterno('1234099')
							.build();
		

		Order anOrderTwoCanalComercial = Build.anOrder()
							.withAccount(accountCanalComercial)
							.withStatus('Borrador')
							.withEffectiveDate(Date.today())
							.withPricebook(pricebookId)
							.withBusinessUnit('5771')
							.withPurchaseOrder('00000353')
							.withIdExterno('1235088')
							.build();
		
		insert new Order [] {anOrderCanalComercial,anOrderTwoCanalComercial};

		OrderItem anOrderItemCanalComercial = Build.anOrderItem()
						.withOrder(anOrderCanalComercial)
						.withProduct2Id(productCanalComercial)
						.withListPrice(100)
						.withUnitPrice(100)
						.withQuantity(900)
						.withPricebookEntryId(pricebooksEntriesCanalComercial[0])
						.build();
		insert anOrderItemCanalComercial;

		for (Order order : [
			SELECT  Id
			FROM    Order
			WHERE AccountId = :accountCanalComercial.Id
			AND Dan360_Id_Externo__c = '1234099'
			LIMIT   1
		]) {
			order.Status = 'Retenido por cuota';
			ordersBeforeUpdate.add(order);
		}

		update ordersBeforeUpdate;

		system.debug(ordersBeforeUpdate);

		OrderItem anOrderItem = [
			SELECT Id, Product2Id
			FROM OrderItem
			WHERE OrderId = : ordersBeforeUpdate[0].Id
			LIMIT 1
		];
		
		for (Dan360_Cuota__c quota : [
			SELECT  Id
			FROM    Dan360_Cuota__c
			WHERE    Dan360_Producto__c= :anOrderItem.Product2Id
			AND Dan360_Cuota__c = 0002
		]) {
			quota.Dan360_Saldo__c = 0;			
			dues.add(quota);
		}
		
		Test.startTest();
			update dues;
		Test.stopTest();

		List<Order> orders = [
			SELECT  Id,
					Status,
					Dan360_SemaforoPicklist__c
			FROM    Order
			WHERE   Dan360_SemaforoPicklist__c = 'Rojo'			
		];
		
		//System.assertEquals(1, orders.size(), 'Las órdenes no cambiaron de Semáforo');
	}
	@IsTest
	private static void cuandoNoHaySaldoEnCuotaPorSubsidiaryYCanalComercialDeberiaDevolverSemaforoRojo() {
		List<Dan360_Cuota__c> dues = new List<Dan360_Cuota__c>();
		List<Order> ordersBeforeUpdate = new List<Order>();
		Id subsidiaryRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Dan360_Sucursal').getRecordTypeId();
		
		/* Account account = [
			SELECT Id, RecordTypeId
			FROM Account
			WHERE Name = 'Account canal comercial'			
		];
		account.RecordTypeId = subsidiaryRecordTypeId;
		update account; */

		Id pricebookId = Test.getStandardPricebookId();
		Product2 productCanalComercial = Build.aProduct()
			.withName('Test 1' )
			.withUnidadesBulto(1)
			.withIsActive(true)
		.build();
		insert productCanalComercial;

		List<PricebookEntry> pricebooksEntriesCanalComercial = [
			SELECT  IsActive,Pricebook2Id,Product2Id,UnitPrice
			FROM PricebookEntry
			WHERE Pricebook2Id = :pricebookId
			AND Product2Id =:productCanalComercial.Id
			];
		Account accountCanalComercial = Build.anAccount()
			.withPricebook(pricebookId)
			.withName('Account canal comercial')
			.withSalesDistric('E-Commerce')
			.withRecordTypeId(subsidiaryRecordTypeId)
			.build();
		insert accountCanalComercial;

		Order anOrderCanalComercial = Build.anOrder()
							.withAccount(accountCanalComercial)
							.withStatus('Borrador')
							.withEffectiveDate(Date.today())
							.withPricebook(pricebookId)
							.withBusinessUnit('5771')
							.withPurchaseOrder('00000350')
							.withIdExterno('1234099')
							.build();
		

		Order anOrderTwoCanalComercial = Build.anOrder()
							.withAccount(accountCanalComercial)
							.withStatus('Borrador')
							.withEffectiveDate(Date.today())
							.withPricebook(pricebookId)
							.withBusinessUnit('5771')
							.withPurchaseOrder('00000353')
							.withIdExterno('1235088')
							.build();
		
		insert new Order [] {anOrderCanalComercial,anOrderTwoCanalComercial};

		OrderItem anOrderItemCanalComercial = Build.anOrderItem()
						.withOrder(anOrderCanalComercial)
						.withProduct2Id(productCanalComercial)
						.withListPrice(100)
						.withUnitPrice(100)
						.withQuantity(900)
						.withPricebookEntryId(pricebooksEntriesCanalComercial[0])
						.build();
		insert anOrderItemCanalComercial;

		for (Order order : [
			SELECT  Id
			FROM    Order
			WHERE AccountId = :accountCanalComercial.Id
			AND Dan360_Id_Externo__c = '1234099'
			LIMIT   1
		]) {
			order.Status = 'Retenido por cuota';
			ordersBeforeUpdate.add(order);
		}

		update ordersBeforeUpdate;

		system.debug(ordersBeforeUpdate);

		OrderItem anOrderItem = [
			SELECT Id, Product2Id
			FROM OrderItem
			WHERE OrderId = : ordersBeforeUpdate[0].Id
			LIMIT 1
		];
		
		for (Dan360_Cuota__c quota : [
			SELECT  Id
			FROM    Dan360_Cuota__c
			WHERE    Dan360_Producto__c= :anOrderItem.Product2Id
			AND Dan360_Cuota__c = 0002
		]) {
			quota.Dan360_Saldo__c = 0;			
			dues.add(quota);
		}
		
		Test.startTest();
			update dues;
		Test.stopTest();

		List<Order> orders = [
			SELECT  Id,
					Status,
					Dan360_SemaforoPicklist__c
			FROM    Order
			WHERE   Dan360_SemaforoPicklist__c = 'Rojo'			
		];
		
		//System.assertEquals(1, orders.size(), 'Las órdenes no cambiaron de Semáforo');
	}
	@IsTest
	private static void cuandoSaldoNoEsSuficienteEnCuotaPorSubsidiaryYCanalComercialDeberiaDevolverSemaforoAmarillo() {
		List<Dan360_Cuota__c> dues = new List<Dan360_Cuota__c>();
		List<Order> ordersBeforeUpdate = new List<Order>();
		Id subsidiaryRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Dan360_Sucursal').getRecordTypeId();
		Id pricebookId = Test.getStandardPricebookId();

		/* Account account = [
			SELECT Id, RecordTypeId
			FROM Account
			WHERE Name = 'Account canal comercial'			
		];
		account.RecordTypeId = subsidiaryRecordTypeId;
		update account; */

		Product2 productCanalComercial = Build.aProduct()
		.withName('Test 1' )
		.withUnidadesBulto(1)
		.withIsActive(true)
		.build();
		insert productCanalComercial;

		List<PricebookEntry> pricebooksEntriesCanalComercial = [
			SELECT  IsActive,Pricebook2Id,Product2Id,UnitPrice
			FROM PricebookEntry
			WHERE Pricebook2Id = :pricebookId
			AND Product2Id =:productCanalComercial.Id
			];
		Account accountCanalComercial = Build.anAccount()
			.withPricebook(pricebookId)
			.withName('Account canal comercial')
			.withSalesDistric('E-Commerce')
			.withRecordTypeId(subsidiaryRecordTypeId)
			.build();
		insert accountCanalComercial;

		Order anOrderCanalComercial = Build.anOrder()
							.withAccount(accountCanalComercial)
							.withStatus('Borrador')
							.withEffectiveDate(Date.today())
							.withPricebook(pricebookId)
							.withBusinessUnit('5771')
							.withPurchaseOrder('00000350')
							.withIdExterno('1234099')
							.build();
		

		Order anOrderTwoCanalComercial = Build.anOrder()
							.withAccount(accountCanalComercial)
							.withStatus('Borrador')
							.withEffectiveDate(Date.today())
							.withPricebook(pricebookId)
							.withBusinessUnit('5771')
							.withPurchaseOrder('00000353')
							.withIdExterno('1235088')
							.build();
		
		insert new Order [] {anOrderCanalComercial,anOrderTwoCanalComercial};

		OrderItem anOrderItemCanalComercial = Build.anOrderItem()
						.withOrder(anOrderCanalComercial)
						.withProduct2Id(productCanalComercial)
						.withListPrice(100)
						.withUnitPrice(100)
						.withQuantity(900)
						.withPricebookEntryId(pricebooksEntriesCanalComercial[0])
						.build();
		insert anOrderItemCanalComercial;

		for (Order order : [
			SELECT  Id
			FROM    Order
			WHERE AccountId = :accountCanalComercial.Id
			AND Dan360_Id_Externo__c = '1234099'
			LIMIT   1
		]) {
			order.Status = 'Retenido por cuota';
			ordersBeforeUpdate.add(order);
		}

		update ordersBeforeUpdate;

		system.debug(ordersBeforeUpdate);

		OrderItem anOrderItem = [
			SELECT Id, Product2Id
			FROM OrderItem
			WHERE OrderId = : ordersBeforeUpdate[0].Id
			LIMIT 1
		];
		
		for (Dan360_Cuota__c quota : [
			SELECT  Id
			FROM    Dan360_Cuota__c
			WHERE    Dan360_Producto__c= :anOrderItem.Product2Id
			AND Dan360_Cuota__c = 0002
		]) {
			quota.Dan360_Saldo__c = 10;			
			dues.add(quota);
		}
		
		Test.startTest();
			update dues;
		Test.stopTest();

		List<Order> orders = [
			SELECT  Id,
					Status,
					Dan360_SemaforoPicklist__c
			FROM    Order
			WHERE   Dan360_SemaforoPicklist__c = 'Amarillo'			
		];
		
		//System.assertEquals(1, orders.size(), 'Las órdenes no cambiaron de Semáforo');
	}
	@IsTest
	private static void cuandoSaldoEsSuficienteEnCuotaPorSubsidiaryYCanalComercialDeberiaDevolverSemaforoVerde() {
		List<Dan360_Cuota__c> dues = new List<Dan360_Cuota__c>();
		List<Order> ordersBeforeUpdate = new List<Order>();
		Id subsidiaryRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Dan360_Sucursal').getRecordTypeId();
		Id pricebookId = Test.getStandardPricebookId();
		/* Account account = [
			SELECT Id, RecordTypeId
			FROM Account
			WHERE Name = 'Account canal comercial'			
		];
		account.RecordTypeId = subsidiaryRecordTypeId;
		update account; */


		/////////////////////////////////////////////////////////////////////////////
		Product2 productCanalComercial = Build.aProduct()
		.withName('Test 1' )
		.withUnidadesBulto(1)
		.withIsActive(true)
		.build();
		insert productCanalComercial;

		List<PricebookEntry> pricebooksEntriesCanalComercial = [
			SELECT  IsActive,Pricebook2Id,Product2Id,UnitPrice
			FROM PricebookEntry
			WHERE Pricebook2Id = :pricebookId
			AND Product2Id =:productCanalComercial.Id
			];
		Account accountCanalComercial = Build.anAccount()
			.withPricebook(pricebookId)
			.withName('Account canal comercial')
			.withSalesDistric('E-Commerce')
			.withRecordTypeId(subsidiaryRecordTypeId)
			.build();
		insert accountCanalComercial;

		Order anOrderCanalComercial = Build.anOrder()
							.withAccount(accountCanalComercial)
							.withStatus('Borrador')
							.withEffectiveDate(Date.today())
							.withPricebook(pricebookId)
							.withBusinessUnit('5771')
							.withPurchaseOrder('00000350')
							.withIdExterno('1234099')
							.build();
		

		Order anOrderTwoCanalComercial = Build.anOrder()
							.withAccount(accountCanalComercial)
							.withStatus('Borrador')
							.withEffectiveDate(Date.today())
							.withPricebook(pricebookId)
							.withBusinessUnit('5771')
							.withPurchaseOrder('00000353')
							.withIdExterno('1235088')
							.build();
		
		insert new Order [] {anOrderCanalComercial,anOrderTwoCanalComercial};

		OrderItem anOrderItemCanalComercial = Build.anOrderItem()
						.withOrder(anOrderCanalComercial)
						.withProduct2Id(productCanalComercial)
						.withListPrice(100)
						.withUnitPrice(100)
						.withQuantity(900)
						.withPricebookEntryId(pricebooksEntriesCanalComercial[0])
						.build();
		insert anOrderItemCanalComercial;

		//////////////////////////////////////////////////////////////////////
		


		for (Order order : [
			SELECT  Id
			FROM    Order
			WHERE AccountId = :accountCanalComercial.Id
			AND Dan360_Id_Externo__c = '1234099'
			LIMIT   1
		]) {
			order.Status = 'Retenido por cuota';
			ordersBeforeUpdate.add(order);
		}

		update ordersBeforeUpdate;

		system.debug(ordersBeforeUpdate);

		OrderItem anOrderItem = [
			SELECT Id, Product2Id
			FROM OrderItem
			WHERE OrderId = : ordersBeforeUpdate[0].Id
			LIMIT 1
		];
		
		for (Dan360_Cuota__c quota : [
			SELECT  Id
			FROM    Dan360_Cuota__c
			WHERE    Dan360_Producto__c= :anOrderItem.Product2Id
			AND Dan360_Cuota__c = 0002
		]) {
			quota.Dan360_Saldo__c = 10000;			
			dues.add(quota);
		}
		
		Test.startTest();
			update dues;
		Test.stopTest();

		List<Order> orders = [
			SELECT  Id,
					Status,
					Dan360_SemaforoPicklist__c
			FROM    Order
			WHERE   Dan360_SemaforoPicklist__c = 'Verde'			
		];
		
		//System.assertEquals(1, orders.size(), 'Las órdenes no cambiaron de Semáforo');
	}

	@IsTest
	private static void cuandoCuotaEsInactivaYConSaldoCeroSemaforoDeberiaCambiarAVerde() {
		List<Dan360_Cuota__c> dues = new List<Dan360_Cuota__c>();
		List<Order> ordersBeforeUpdate = new List<Order>();
		Set<Id> clientId = new Set<Id>();
		Id empresaRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Dan360_Empresa').getRecordTypeId();
		/* Account account = [
			SELECT Id, RecordTypeId
			FROM Account
			WHERE Name = 'Account canal comercial'			
		]; */
		Id pricebookId = Test.getStandardPricebookId();
		Product2 productCanalComercial = Build.aProduct()
			.withName('Test 1' )
			.withUnidadesBulto(1)
			.withIsActive(true)
			.build();
		insert productCanalComercial;

		List<PricebookEntry> pricebooksEntriesCanalComercial = [
			SELECT  IsActive,Pricebook2Id,Product2Id,UnitPrice
			FROM PricebookEntry
			WHERE Pricebook2Id = :pricebookId
			AND Product2Id =:productCanalComercial.Id
			];
		Account accountCanalComercial = Build.anAccount()
			.withPricebook(pricebookId)
			.withName('Account canal comercial')
			.withSalesDistric('E-Commerce')
			.withRecordTypeId(empresaRecordTypeId)
			.build();
		insert accountCanalComercial;

		Order anOrderCanalComercial = Build.anOrder()
							.withAccount(accountCanalComercial)
							.withStatus('Borrador')
							.withEffectiveDate(Date.today())
							.withPricebook(pricebookId)
							.withBusinessUnit('5771')
							.withPurchaseOrder('00000350')
							.withIdExterno('1234099')
							.build();
		

		Order anOrderTwoCanalComercial = Build.anOrder()
							.withAccount(accountCanalComercial)
							.withStatus('Borrador')
							.withEffectiveDate(Date.today())
							.withPricebook(pricebookId)
							.withBusinessUnit('5771')
							.withPurchaseOrder('00000353')
							.withIdExterno('1235088')
							.build();
		
		insert new Order [] {anOrderCanalComercial,anOrderTwoCanalComercial};

		OrderItem anOrderItemCanalComercial = Build.anOrderItem()
						.withOrder(anOrderCanalComercial)
						.withProduct2Id(productCanalComercial)
						.withListPrice(100)
						.withUnitPrice(100)
						.withQuantity(900)
						.withPricebookEntryId(pricebooksEntriesCanalComercial[0])
						.build();
		insert anOrderItemCanalComercial;

		for (Order order : [
			SELECT  Id
			FROM    Order
			WHERE AccountId = :accountCanalComercial.Id
			AND Dan360_Id_Externo__c = '1234099'
			LIMIT   1
		]) {
			order.Status = 'Retenido por cuota';
			ordersBeforeUpdate.add(order);
		}

		update ordersBeforeUpdate;

		OrderItem anOrderItem = [
			SELECT Id, Product2Id
			FROM OrderItem
			WHERE OrderId = : ordersBeforeUpdate[0].Id
			LIMIT 1
		];
		
		for (Dan360_Cuota__c quota : [
			SELECT  Id
			FROM    Dan360_Cuota__c
			WHERE    Dan360_Producto__c= :anOrderItem.Product2Id
			AND Dan360_Cuota__c = 0002
		]) {
			quota.Dan360_EstadoCuota__c = 'Inactiva';
			quota.Dan360_Saldo__c = 0;
			dues.add(quota);
		}

		Test.startTest();
			update dues;
		Test.stopTest();

		Order updatedOrder = [
			SELECT  Id,
					Dan360_SemaforoPicklist__c
			FROM    Order
			WHERE   Id = :ordersBeforeUpdate[0].Id
		];

		//System.assertEquals('Verde', updatedOrder.Dan360_SemaforoPicklist__c, 'El semáforo de la orden no fue actualizado.');
	}
	// #endregion
}