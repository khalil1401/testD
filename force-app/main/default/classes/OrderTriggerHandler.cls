public without sharing class OrderTriggerHandler {
	public static void validatePurchaseOrdersToConfirmByDateTodayAndAccount(List<Order> newOrders) {
		List<String> accountIds = new List<String>();
		List<String> purchaseOrders = new List<String>();
		Map<Id, List<Order>> existingOrders = new Map<Id, List<Order>>();
		Date today = Date.Today();

		for (Order order : newOrders) {
			accountIds.add(order.AccountId);
			purchaseOrders.add(order.Orden_de_compra__c);
		}

		for (Order order : [
			SELECT	Id,
					AccountId,
					Orden_de_compra__c
			FROM		Order
			WHERE	 ActivatedDate = TODAY
				AND AccountId IN :accountIds
				AND Orden_de_compra__c IN :purchaseOrders
				AND Status = 'Confirmado'
		]) {
			if (!existingOrders.containsKey(order.AccountId)) {
				existingOrders.put(order.accountId, new List<Order>());
			}

			existingOrders.get(order.AccountId).add(order);
		}

		for (Order order : newOrders) {
			if (existingOrders.containsKey(order.AccountId)) {
				for (Order existingOrder : existingOrders.get(order.AccountId)) {
					if (!String.isEmpty(order.Orden_de_compra__c) &&
						order.AccountId == existingOrder.AccountId &&
						order.Orden_de_compra__c == existingOrder.Orden_de_compra__c
					) {
						order.addError(
							'Orden_de_compra__c',
							Label.Orden_de_Compra_Duplicada
						);
					}
				}
			}
		}
	}

	public static void validateQuotaLimit(List<Order> orders) {
		System.debug('-->'+orders);
		String shouldBe;
		Set<String> subsidiaries = new Set<String>();
		Set<String> clients = new Set<String>();
		Set<String> salesDistricts = new Set<String>();
		Set<String> distributionChannels = new Set<String>();
		Set<String> products = new Set<String>();
		Map<String, List<Dan360_Cuota__c>> dues = new Map<String, List<Dan360_Cuota__c>>();
		Map<Id, Map<String, String>> ordersDues = new Map<Id, Map<String, String>>();
		Map<Id, List<OrderItem>> sortedItemsByOrder = new Map<Id, List<OrderItem>>();
		Map<Id, Order> ordersToSplit = new Map<Id, Order>();
		Map<Id, Order> ordersToBlock = new Map<Id, Order>();
		Map<Id, Order> ordersToProcess = new Map<Id, Order>();
		List<Order> confirmedOrders = new List<Order>();
		List<OrderItem> orderItemsToDelete = new List<OrderItem>();
		List<OrderItem> orderItemsToUpdate = new List<OrderItem>();
		List<OrderItem> orderItemsToInsert = new List<OrderItem>();
		List<Dan360_Cuota__c> duesToUpdate = new List<Dan360_Cuota__c>();
		Danone360Helper accountHelper = new Danone360Helper('Account');
		Id subsidiaryRecordTypeId = accountHelper.getRecordTypes().get('Dan360_Sucursal');

		// Get Ids to get related order dues
		for (Order order : [
			SELECT	Id,
					AccountId,
					Account.ParentId,
					Account.Dan360_SalesDistric1__c,
					Account.Dan360_DistributionChannel__c,
					Account.RecordTypeId
			FROM		Order
			WHERE	 Id IN :orders
		]) {
			Map<String, String> duesThatApply = new Map<String, String>();
			if (order.Account.RecordTypeId == subsidiaryRecordTypeId) {
				subsidiaries.add(order.AccountId);
				clients.add(order.Account.ParentId);
				duesThatApply.put('Subsidiary', order.AccountId);
				duesThatApply.put('Client', order.Account.ParentId);
			} else {
				clients.add(order.AccountId);
				duesThatApply.put('Client', order.AccountId);
			}

			if (!String.isEmpty(order.Account.Dan360_SalesDistric1__c)) {
				salesDistricts.add(order.Account.Dan360_SalesDistric1__c);
				duesThatApply.put('SalesDistrict', order.Account.Dan360_SalesDistric1__c);
			}

			if (!String.isEmpty(order.Account.Dan360_DistributionChannel__c)) {
				distributionChannels.add(order.Account.Dan360_DistributionChannel__c);
				duesThatApply.put('DistributionChannel', order.Account.Dan360_DistributionChannel__c);
			}

			ordersDues.put(order.Id, duesThatApply);
		}

		for (OrderItem orderItem : [
			SELECT	Id,
					OrderId,
					Product2Id,
					Quantity
			FROM	OrderItem
			WHERE	 OrderId IN :orders
		]) {
			products.add(orderItem.Product2Id);
			ordersDues.get(orderItem.OrderId)
				.putAll(new Map<String, String> {
					'Product' => orderItem.Product2Id
				});
		}

		sortedItemsByOrder = OrderTriggerHelper.getOrderItems(orders);
		System.debug('sortedItemsByOrder');
		System.debug(sortedItemsByOrder);
		OrderTriggerHelper.getDuesBy(subsidiaries, 'Subsidiary', dues);
		OrderTriggerHelper.getDuesBy(clients, 'Client', dues);
		OrderTriggerHelper.getDuesBy(salesDistricts, 'SalesDistrict', dues);
		OrderTriggerHelper.getDuesBy(distributionChannels, 'DistributionChannel', dues);
		OrderTriggerHelper.getDuesBy(products, 'Product', dues);
		Map<Id, Map<String, List<Dan360_Cuota__c>>> duesByOrder = OrderTriggerHelper.matchOrdersWithDues(ordersDues, dues);

		// System.debug('ordersDues >>> ' + JSON.serialize(ordersDues));
		// System.debug('duesByOrder >>> ' + JSON.serialize(duesByOrder));
		// System.debug('sortedItemsByOrder >>> ' + JSON.serialize(sortedItemsByOrder));
		// System.debug('cotenido de los dues >>>'+  JSON.serialize(dues));

		Map<Id, Map<OrderItem, Map<String, List<Dan360_Cuota__c>>>> sortedOrderItemsWithRelatedQuota = OrderTriggerHelper.matchOrderDuesWithOrderItems(ordersDues, duesByOrder, sortedItemsByOrder);

		// System.debug('sortedOrderItemsWithRelatedQuota >>> '+ JSON.serialize(sortedOrderItemsWithRelatedQuota) );

		for (Order order : [
			SELECT	Id,
					AccountId,
					Account.ParentId,
					Account.Dan360_SalesDistric1__c,
					Account.Dan360_DistributionChannel__c,
					Account.RecordTypeId
			FROM		Order
			WHERE	 Id IN :orders
		]) {
			OrderTriggerHelper.insertOrdersByQuota(order, sortedItemsByOrder.get(order.Id), dues);
		}

		for (Order order : orders) {
			//TODO: Revisar si se registrarán todas las cuotas que se usan para la orden.
			// OrderTriggerHelper.insertOrdersByQuota(order, sortedItemsByOrder.get(order.Id), dues, sortedOrderItemsWithRelatedQuota);
			if(order.Status != 'Retenido por cuota'){
				shouldBe = OrderTriggerHelper.orderShouldBe(order.Id, sortedOrderItemsWithRelatedQuota);

				switch on shouldBe {
					when 'block' {
						ordersToBlock.put(order.Id, order);
					}
					when 'split' {
						ordersToSplit.put(order.Id, order);
					}
					when else {
						ordersToProcess.put(order.Id, order);
					}
				}
			}
			
		}

		if (Trigger.isBefore) {
			if (ordersToBlock.size() > 0) {	
				for (Order order : ordersToBlock.values()) {
					order.Status = 'Retenido por cuota';
					order.Dan360_SemaforoPicklist__c = 'Rojo';
				}
			}

			// System.debug('Flag  ordersToSplit >>>' + JSON.serialize(ordersToSplit));
			// System.debug('Flag  sortedOrderItemsWithRelatedQuota >>>'+ sortedOrderItemsWithRelatedQuota);
			// System.debug('Flag  orderItemsToDelete >>>'+ JSON.serialize(orderItemsToDelete));
			// System.debug('Flag  orderItemsToUpdate >>>'+ JSON.serialize(orderItemsToUpdate));
			// System.debug('Flag  orderItemsToInsert >>>'+ JSON.serialize(orderItemsToInsert));

			if (ordersToSplit.size() > 0) {
				OrderTriggerHelper.splitOrders(
					ordersToSplit,
					sortedOrderItemsWithRelatedQuota,
					orderItemsToDelete,
					orderItemsToUpdate,
					orderItemsToInsert
				);
			}

			Map<id,OrderItem> ordenItemById = new Map<id,OrderItem>();

			ordenItemById.putall(orderItemsToInsert);
			// System.debug('Flag orderItemsToInsert 2 >>>'+ JSON.serialize(orderItemsToInsert) );
			// System.debug('Flag  ordenItemById >>>'+ ordenItemById);

			if(ordenItemById.size()>0){
				// insert ordenItemById.values();
				insert orderItemsToInsert;
			}

			Map<id,OrderItem> ordenItemByIdToUpdate = new Map<id,OrderItem>();

			ordenItemByIdToUpdate.putall(orderItemsToUpdate);
			if(ordenItemByIdToUpdate.size()>0){
				update ordenItemByIdToUpdate.values();
			}
			// System.debug('Flag  ordenItemByIdToUpdate >>>'+ ordenItemByIdToUpdate);
			// System.debug('Flag  orderItemsToDelete >>>'+ orderItemsToInsert);
			
			delete orderItemsToDelete;
			
		}

		if (Trigger.isAfter) {
			for (Order order : orders) {
				if (order.Status == 'Confirmado') {
					confirmedOrders.add(order);
				}
			}

			OrderTriggerHelper.processOrders(confirmedOrders, sortedOrderItemsWithRelatedQuota);
			//OrderTriggerHelper.sendConfirmedOrdersEmails(orders);
		}
	}

	public static void validateAndUpdatePricesIntoOrderItems(List<Order> orders) {
		Set<Id> ordersId = (new Map<Id, Order>(orders)).keySet();
		List<OrderItem> itemsToUpdate = new List<OrderItem>();
		Decimal discount;

		List<OrderItem> orderItems = [
			SELECT	Id,
					Product2Id,
					Dan360_ListPrice__c,
					UnitPrice,
					Dan360_Descuento__c,
					PricebookEntry.UnitPrice,
					PricebookEntry.Dan360_Descuento__c,
					PricebookEntry.isActive
			FROM		OrderItem
			WHERE	 OrderId IN :ordersId
				AND PricebookEntry.isActive = true
		];

		for (OrderItem orderItem : orderItems) {

			if( orderItem.UnitPrice != orderItem.PricebookEntry.UnitPrice ||
				orderItem.Dan360_Descuento__c != orderItem.PricebookEntry.Dan360_Descuento__c
			){
				orderItem.Dan360_ListPrice__c = orderItem.PricebookEntry.UnitPrice;
				orderItem.Dan360_Descuento__c = orderItem.PricebookEntry.Dan360_Descuento__c == null? 0: orderItem.PricebookEntry.Dan360_Descuento__c;

				discount = orderItem.Dan360_ListPrice__c * orderItem.Dan360_Descuento__c / 100;

				orderItem.UnitPrice = orderItem.Dan360_ListPrice__c - discount;
				itemsToUpdate.add(orderItem);
			}
		}

		update itemsToUpdate;
	}

	public static void validateAndDeletePricesIntoOrderItems(List<Order> orders) {
		Set<Id> ordersId = (new Map<Id, Order>(orders)).keySet();
		List<OrderItem> itemsToDelete = new List<OrderItem>();

		List<OrderItem> orderItems = [
			SELECT	Id,
					Product2Id,
					Dan360_ListPrice__c,
					UnitPrice,
					Dan360_Descuento__c,
					PricebookEntry.UnitPrice,
					PricebookEntry.Dan360_Descuento__c,
					PricebookEntry.isActive
			FROM		OrderItem
			WHERE	 OrderId IN :ordersId
				AND PricebookEntry.isActive = false
		];
		System.debug(orderItems);
		for (OrderItem orderItem : orderItems) {
			itemsToDelete.add(orderItem);
		}

		delete itemsToDelete;
	}

	public static void pricebookAndProductTemplateAssign(List<String> ordersIdsP){
		System.debug('Pedido trigger');
		System.debug(ordersIdsP);
		Id standardPricebookID;
		List<String> ordersIDs = new List<String>();
		List<Order> ordersToUpdate = new List<Order>();
		if(Test.IsRunningTest()){
			System.debug('test1');
			standardPricebookID = Test.getStandardPricebookId();
		}else{
			System.debug('test2');
			standardPricebookID = [
				SELECT Id 
				FROM PriceBook2 
				WHERE isStandard = true 
				LIMIT 1].Id;
		}
		
		for(Order pedido : [SELECT Id, RecordType.Name, Pricebook2Id FROM Order Where Id IN :ordersIdsP]){
			System.debug('pedido.RecordType.Name');
			System.debug(pedido.RecordType.Name);
			System.debug('pedido after insert');
			System.debug(pedido.Pricebook2Id);
			if(pedido.RecordType.Name == 'Pedido sin Cargo'){
				pedido.Pricebook2Id = standardPricebookID;
				ordersToUpdate.add(pedido);
			}
			System.debug('ordersToUpdate');
			System.debug(ordersToUpdate);
		}
		if(ordersToUpdate.size() > 0){
			update ordersToUpdate;
		}
	} 

	
	public static void updateOrderFields(List<String> ordersIds){
        List<Order> ordersToUpdate = new List<Order>();
		//sendOrderToSapController.sendOrderSinCargoToSap(ordersIds);
        //Id devolucionRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Dan360_Devoluciones').getRecordTypeId();
        for(Order orderToUpdate : [SELECT Id,RecordTypeId, Dan360_En_aprobacion__c, Dan360_PedidoSinCargoAprobado__c, Status, CreatedDate 
                                    FROM Order 
                                    WHERE Id IN :ordersIds]){            
			// orderToUpdate.Dan360_OrderGetStart__c = Date.today();
            // Date createdDateCase = date.newinstance(orderToUpdate.CreatedDate.year(), orderToUpdate.CreatedDate.month(), orderToUpdate.CreatedDate.day());
            //orderToUpdate.Dan360_En_aprobacion__c = false;
            //orderToUpdate.Dan360_PedidoSinCargoAprobado__c = true;
			if ( orderToUpdate.Status != 'Aprobado') {
				System.debug('aprobado en trigger');
				orderToUpdate.Status = 'Aprobado';				
				ordersToUpdate.add(orderToUpdate);
			}
			System.debug('Orders to update: '+ordersToUpdate);
        }
        if(!ordersToUpdate.isEmpty()){
            Database.update(ordersToUpdate);
        }
    }
}