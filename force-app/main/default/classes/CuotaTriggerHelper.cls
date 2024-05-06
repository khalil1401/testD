public with sharing class CuotaTriggerHelper {

	public static void processDuplicatedLogic(List<Dan360_Cuota__c> cuotaList) {

		List<String> productId = new List<String>();
		List<String> productCanal = new List<String>();
		List<Dan360_Cuota__c> mapCuotasToInsert = new List<Dan360_Cuota__c>();
		Map<String, Map< String, List<Dan360_Cuota__c>>> mapCuotasSalesForce = new Map<String, Map< String, List<Dan360_Cuota__c>>>();

		for(Dan360_Cuota__c cuota : cuotaList) {
			productId.add(cuota.Dan360_Producto__c);
			productCanal.add(cuota.Dan360_CanalComercial__c);
		}

		for(Dan360_Cuota__c cuotaSF : [
			SELECT Name, Dan360_CanalComercial__c, Dan360_VigenciaDesde__c, Dan360_VigenciaHasta__c, 
				Dan360_Producto__c, Dan360_CanalDistribucion__c, Dan360_Cliente__c
			FROM Dan360_Cuota__c
			WHERE (Dan360_Producto__c IN :productId) AND (Dan360_CanalComercial__c IN :productCanal)
			WITH SECURITY_ENFORCED
		]){

			if(!mapCuotasSalesForce.containsKey(cuotaSF.Dan360_Producto__c)){
				mapCuotasSalesForce.put(cuotaSF.Dan360_Producto__c, new Map< String, List<Dan360_Cuota__c>>());
			}

			if(!mapCuotasSalesForce.get(cuotaSF.Dan360_Producto__c).containsKey(cuotaSF.Dan360_CanalComercial__c)){
				mapCuotasSalesForce.get(cuotaSF.Dan360_Producto__c).put(cuotaSF.Dan360_CanalComercial__c, new List<Dan360_Cuota__c>());
			}
			mapCuotasSalesForce.get(cuotaSF.Dan360_Producto__c).get(cuotaSF.Dan360_CanalComercial__c).add(cuotaSF);
		}

		for(Dan360_Cuota__c cuotaToInsert : cuotaList){

			if(mapCuotasSalesForce.containsKey(cuotaToInsert.Dan360_Producto__c)){
				if(mapCuotasSalesForce.get(cuotaToInsert.Dan360_Producto__c).containsKey(cuotaToInsert.Dan360_CanalComercial__c)){
					for(Dan360_Cuota__c cuotaToCompare : mapCuotasSalesForce.get(cuotaToInsert.Dan360_Producto__c).get(cuotaToInsert.Dan360_CanalComercial__c)){
						if(
							(
								(cuotaToInsert.Dan360_VigenciaDesde__c >= cuotaToCompare.Dan360_VigenciaDesde__c) && (cuotaToInsert.Dan360_VigenciaDesde__c < cuotaToCompare.Dan360_VigenciaHasta__c) ||
								(cuotaToInsert.Dan360_VigenciaDesde__c < cuotaToCompare.Dan360_VigenciaDesde__c) && (cuotaToInsert.Dan360_VigenciaHasta__c > cuotaToCompare.Dan360_VigenciaDesde__c)
							)
							&& 
							(
								cuotaToInsert.Dan360_CanalDistribucion__c == cuotaToCompare.Dan360_CanalDistribucion__c
								&& cuotaToInsert.Dan360_CanalComercial__c == cuotaToCompare.Dan360_CanalComercial__c
								&& cuotaToInsert.Dan360_Cliente__c == cuotaToCompare.Dan360_Cliente__c
							)
						){
							cuotaToInsert.addError(System.Label.Errores + ', Cuota: '+cuotaToCompare.Name);
						}
					}
				}
			}
		}
	}

	public static void validateTrafficLightInOrders(List<Dan360_Cuota__c> dues) {
		Map<Id, Map<String, String>> ordersDues = new Map<Id, Map<String, String>>();
		Map<Id, List<OrderItem>> orderItems = new Map<Id, List<OrderItem>>();
		Map<String, Dan360_Cuota__c> productDues = new Map<String, Dan360_Cuota__c>();
		Map<String, List<Dan360_Cuota__c>> allDues = new Map<String, List<Dan360_Cuota__c>>();
		List<Order> ordersToUpdate = new List<Order>();
		Set<Id> productsId = new Set<Id>();
		Set<Id> ordersId = new Set<Id>();

		// Get products id from dues
		for (Dan360_Cuota__c quota : [
			SELECT  Dan360_Producto__c
			FROM    Dan360_Cuota__c
			WHERE   Id IN :dues
		]) {
			productsId.add(quota.Dan360_Producto__c);
		}

		// Get order items with related order by status [Retenido por cuota]
		orderItems = getOrderItems(productsId);

		if (!orderItems.isEmpty()) {
			ordersId = orderItems.keySet();

			ordersDues = getDuesThatApplyByOrder(ordersId);

			if (!ordersId.isEmpty()) {
				allDues = getDuesByType(productsId);

				if (!allDues.isEmpty()) {
					ordersToUpdate = setTrafficLightToOrders(ordersId, ordersDues, orderItems, allDues);
					
					Id profileId=userinfo.getProfileId();
					String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
					System.debug('ProfileName'+profileName);
					update ordersToUpdate;
				}
			}

		}
	}

	private static Map<Id, Map<String, String>> getDuesThatApplyByOrder(Set<Id> ordersId) {
		Map<Id, Map<String, String>> ordersDues = new Map<Id, Map<String, String>>();

		for (Order order : [
			SELECT  Id,
					AccountId,
					Account.ParentId,
					Account.Dan360_SalesDistric1__c,
					Account.Dan360_DistributionChannel__c,
					Account.RecordType.Name
			FROM    Order
			WHERE   Id IN :ordersId
		]) {
			Map<String, String> duesThatApply = new Map<String, String>();

			if (order.Account.RecordType.Name == 'Sucursal') {
				duesThatApply.put('Subsidiary', order.AccountId);
			} else {
				duesThatApply.put('Client', order.AccountId);
			}

			if (!String.isEmpty(order.Account.Dan360_SalesDistric1__c)) {
				duesThatApply.put('CommercialChannel', order.Account.Dan360_SalesDistric1__c);
			}

			if (!String.isEmpty(order.Account.Dan360_DistributionChannel__c)) {
				duesThatApply.put('DistributionChannel', order.Account.Dan360_DistributionChannel__c);
			}
			ordersDues.put(order.Id, duesThatApply);
		}

		return ordersDues;
	}

	private static Map<Id, List<OrderItem>> getOrderItems(Set<Id> productsId) {
		Map<Id, List<OrderItem>> orderItems = new Map<Id, List<OrderItem>>();

		for (OrderItem item : [
			SELECT  Product2Id,
					OrderId,
					Quantity
			FROM    OrderItem
			WHERE   Product2Id IN :productsId
				AND Order.Status = 'Retenido por cuota'
		]) {
			if (!orderItems.containsKey(item.OrderId)) {
				orderItems.put(item.OrderId, new List<OrderItem>());
			}
			orderItems.get(item.OrderId).add(item);
		}

		return orderItems;
	}

	private static Map<String, List<Dan360_Cuota__c>> getDuesByType(Set<Id> productsId) {
		Map<String, List<Dan360_Cuota__c>> dues = new Map<String, List<Dan360_Cuota__c>>();

		for (Dan360_Cuota__c quota : [
			SELECT  Id,
					Dan360_Saldo__c,
					Dan360_Producto__c,
					Dan360_Cliente__c,
					Dan360_CanalComercial__c,
					Dan360_CanalDistribucion__c,
					Dan360_EstadoCuota__c
			FROM    Dan360_Cuota__c
			WHERE   Dan360_Producto__c IN :productsId
		]) {
			if (!String.isEmpty(quota.Dan360_CanalDistribucion__c)) {
				if (!dues.containsKey('DistributionChannel')) {
					dues.put('DistributionChannel', new List<Dan360_Cuota__c>());
				}
				dues.get('DistributionChannel').add(quota);
			}

			if (String.isEmpty(quota.Dan360_CanalDistribucion__c) &&
				String.isEmpty(quota.Dan360_Cliente__c) &&
				!String.isEmpty(quota.Dan360_CanalComercial__c)
			) {
				if (!dues.containsKey('CommercialChannel')) {
					dues.put('CommercialChannel', new List<Dan360_Cuota__c>());
				}
				dues.get('CommercialChannel').add(quota);
			}

			if (String.isEmpty(quota.Dan360_CanalDistribucion__c) &&
				String.isEmpty(quota.Dan360_CanalComercial__c) &&
				!String.isEmpty(quota.Dan360_Cliente__c)
			) {
				if (!dues.containsKey('Client')) {
					dues.put('Client', new List<Dan360_Cuota__c>());
				}
				dues.get('Client').add(quota);
			}

			if (String.isEmpty(quota.Dan360_Cliente__c) &&
				String.isEmpty(quota.Dan360_CanalComercial__c) &&
				String.isEmpty(quota.Dan360_CanalDistribucion__c)
			) {
				if (!dues.containsKey('Product')) {
					dues.put('Product', new List<Dan360_Cuota__c>());
				}
				dues.get('Product').add(quota);
			}
		}
		return dues;
	}

	private static List<Order> setTrafficLightToOrders(
		Set<Id> ordersId,
		Map<Id, Map<String, String>> ordersDues,
		Map<Id, List<OrderItem>> orderItems,
		Map<String, List<Dan360_Cuota__c>> dues
	) {
		Boolean flagByClient = false; 
		Boolean flagBySubsidiary = false; 
		List<Order> ordersToUpdate = new List<Order>();

		for (Order order : [
			SELECT  Id,
					Dan360_SemaforoPicklist__c,
					Status
			FROM    Order
			WHERE   Id IN :ordersId
		]) {
			System.debug('order.Status Antes');
			System.debug(order.Status);
			List<OrderItem> orderItemsWithStock = new List<OrderItem>();
			List<OrderItem> orderItemsWithStockButNotEnough = new List<OrderItem>();
			List<OrderItem> orderItemsWithoutStock = new List<OrderItem>();
			List<OrderItem> orderItemsWithInactiveQuota = new List<OrderItem>();
			Map<String, String> orderDues = ordersDues.get(order.Id);
			Boolean hasItemsWithStock;
			Boolean hasItemsWithStockButNotEnough;
			Boolean hasItemsWithoutStock;

			for (OrderItem item : orderItems.get(order.Id)) {
				if (orderDues.containsKey('Subsidiary')) {
					if (dues.get('Client') != null && !dues.get('Client').isEmpty()) {
						for (Dan360_Cuota__c quota : dues.get('Client')) {
							if (quota.Dan360_Cliente__c == orderDues.get('Subsidiary')) {
								flagBySubsidiary = true;
								if (quota.Dan360_Producto__c == item.Product2Id) {
									if (quota.Dan360_EstadoCuota__c == 'Activa') {
										if (quota.Dan360_Saldo__c > 0 &&
											quota.Dan360_Saldo__c >= item.Quantity
										) {
											orderItemsWithStock.add(item);
										} else if (quota.Dan360_Saldo__c > 0 &&
											quota.Dan360_Saldo__c < item.Quantity
										) {
											orderItemsWithStockButNotEnough.add(item);
										} else if (quota.Dan360_Saldo__c == 0) {
											orderItemsWithoutStock.add(item);
										}
									} else {
										orderItemsWithInactiveQuota.add(item);
									}
								}
							}
						}
					} else if (dues.get('CommercialChannel') != null && !dues.get('CommercialChannel').isEmpty()) {
						for (Dan360_Cuota__c quota : dues.get('CommercialChannel')) {
							String[] listSalesDistrict = orderDues.get('CommercialChannel').split(';');
							if (!listSalesDistrict.isEmpty()) {
								if (listSalesDistrict.contains(quota.Dan360_CanalComercial__c)) {
									flagBySubsidiary = true;
									if (quota.Dan360_Producto__c == item.Product2Id) {
										if (quota.Dan360_EstadoCuota__c == 'Activa') {
											if (quota.Dan360_Saldo__c > 0 &&
												quota.Dan360_Saldo__c >= item.Quantity
											) {
												orderItemsWithStock.add(item);
											} else if (quota.Dan360_Saldo__c > 0 &&
												quota.Dan360_Saldo__c < item.Quantity
											) {
												orderItemsWithStockButNotEnough.add(item);
											} else if (quota.Dan360_Saldo__c == 0) {
												orderItemsWithoutStock.add(item);
											}
										} else {
											orderItemsWithInactiveQuota.add(item);
										}
									}
								}
							}
						}
					} else if (dues.get('DistributionChannel') != null && !dues.get('DistributionChannel').isEmpty()) {
						for (Dan360_Cuota__c quota : dues.get('DistributionChannel')) {
							String[] listDistributionChannel = orderDues.get('DistributionChannel').split(';');
							if (!listDistributionChannel.isEmpty()) {
								if (listDistributionChannel.contains(quota.Dan360_CanalDistribucion__c)) {
									flagBySubsidiary = true;
									if (quota.Dan360_Producto__c == item.Product2Id) {
										if (quota.Dan360_EstadoCuota__c == 'Activa') {
											if (quota.Dan360_Saldo__c > 0 &&
											quota.Dan360_Saldo__c >= item.Quantity
											) {
												orderItemsWithStock.add(item);
											} else if (quota.Dan360_Saldo__c > 0 &&
											quota.Dan360_Saldo__c < item.Quantity
											) {
												orderItemsWithStockButNotEnough.add(item);
											} else if (quota.Dan360_Saldo__c == 0) {
												orderItemsWithoutStock.add(item);
											}
										} else {
											orderItemsWithInactiveQuota.add(item);
										}
									}
								}
							}
						}
					} 
					if (!flagBySubsidiary) {
						if (dues.get('Product') != null && !dues.get('Product').isEmpty()) {
							for (Dan360_Cuota__c quota : dues.get('Product')) {
								if (quota.Dan360_Producto__c == item.Product2Id) {
									if (quota.Dan360_EstadoCuota__c == 'Activa') {
										if (quota.Dan360_Saldo__c > 0 &&
											quota.Dan360_Saldo__c >= item.Quantity
										) {
											orderItemsWithStock.add(item);
										} else if (quota.Dan360_Saldo__c > 0 &&
											quota.Dan360_Saldo__c < item.Quantity
										) {
											orderItemsWithStockButNotEnough.add(item);
										} else if (quota.Dan360_Saldo__c == 0) {
											orderItemsWithoutStock.add(item);
										}
									} else {
										orderItemsWithInactiveQuota.add(item);
									}
								}
							}
						}
					}
				} else if (orderDues.containsKey('Client')) {
					if (dues.get('Client') != null && !dues.get('Client').isEmpty()) {
						for (Dan360_Cuota__c quota : dues.get('Client')) {
							if (quota.Dan360_Cliente__c == orderDues.get('Client')) {
								flagByClient = true; 
								if (quota.Dan360_Producto__c == item.Product2Id) {
									if (quota.Dan360_EstadoCuota__c == 'Activa') {
										if (quota.Dan360_Saldo__c > 0 &&
											quota.Dan360_Saldo__c >= item.Quantity
										) {
											orderItemsWithStock.add(item);
										} else if (quota.Dan360_Saldo__c > 0 &&
											quota.Dan360_Saldo__c < item.Quantity
										) {
											orderItemsWithStockButNotEnough.add(item);
										} else if (quota.Dan360_Saldo__c == 0) {
											orderItemsWithoutStock.add(item);
										}
									} else {
										orderItemsWithInactiveQuota.add(item);
									}
								}
							} 
						}
					} else if (dues.get('CommercialChannel') != null && !dues.get('CommercialChannel').isEmpty()) {
						for (Dan360_Cuota__c quota : dues.get('CommercialChannel')) {
							String[] listSalesDistrict = orderDues.get('CommercialChannel').split(';');
							if (!listSalesDistrict.isEmpty()) {
								if (listSalesDistrict.contains(quota.Dan360_CanalComercial__c)) {
									flagByClient = true; 
									if (quota.Dan360_Producto__c == item.Product2Id) {
										if (quota.Dan360_EstadoCuota__c == 'Activa') {
											if (quota.Dan360_Saldo__c > 0 &&
												quota.Dan360_Saldo__c >= item.Quantity
											) {
												orderItemsWithStock.add(item);
											} else if (quota.Dan360_Saldo__c > 0 &&
												quota.Dan360_Saldo__c < item.Quantity
											) {
												orderItemsWithStockButNotEnough.add(item);
											} else if (quota.Dan360_Saldo__c == 0) {
												orderItemsWithoutStock.add(item);
											}
										} else {
											orderItemsWithInactiveQuota.add(item);
										}
									}
								}
							}
						}
					} else if (dues.get('DistributionChannel') != null && !dues.get('DistributionChannel').isEmpty()) {
						String[] listDistributionChannel; 	
						for (Dan360_Cuota__c quota : dues.get('DistributionChannel')) {
							if (orderDues.get('DistributionChannel') != null) {
								listDistributionChannel = orderDues.get('DistributionChannel').split(';');
								if (!listDistributionChannel.isEmpty()) {
									if (listDistributionChannel.contains(quota.Dan360_CanalDistribucion__c)) {
										flagByClient = true; 
										if (quota.Dan360_Producto__c == item.Product2Id) {
											if (quota.Dan360_EstadoCuota__c == 'Activa') {
												if (quota.Dan360_Saldo__c > 0 &&
												quota.Dan360_Saldo__c >= item.Quantity
												) {
													orderItemsWithStock.add(item);
												} else if (quota.Dan360_Saldo__c > 0 &&
												quota.Dan360_Saldo__c < item.Quantity
												) {
													orderItemsWithStockButNotEnough.add(item);
												} else if (quota.Dan360_Saldo__c == 0) {
													orderItemsWithoutStock.add(item);
												}
											} else {
												orderItemsWithInactiveQuota.add(item);
											}
										}
									}
								}
							} 
						}
					} 
					if (!flagByClient) {
						if (dues.get('Product') != null && !dues.get('Product').isEmpty()) {
							for (Dan360_Cuota__c quota : dues.get('Product')) {
								if (quota.Dan360_Producto__c == item.Product2Id) {
									if (quota.Dan360_EstadoCuota__c == 'Activa') {
										if (quota.Dan360_Saldo__c > 0 &&
											quota.Dan360_Saldo__c >= item.Quantity
										) {
											orderItemsWithStock.add(item);
										} else if (quota.Dan360_Saldo__c > 0 &&
											quota.Dan360_Saldo__c < item.Quantity
										) {
											orderItemsWithStockButNotEnough.add(item);
										} else if (quota.Dan360_Saldo__c == 0) {
											orderItemsWithoutStock.add(item);
										}
									} else {
										orderItemsWithInactiveQuota.add(item);
									}
								}
							}
						}
					}
				}
			}

			hasItemsWithStock = !orderItemsWithStock.isEmpty();
			hasItemsWithStockButNotEnough = !orderItemsWithStockButNotEnough.isEmpty();
			hasItemsWithoutStock = !orderItemsWithoutStock.isEmpty();

			// Si todos los items de la orden tienen cuota activa o todos se encuentran con cuota inactiva
			if (!orderItemsWithInactiveQuota.isEmpty() && orderItemsWithInactiveQuota.size() == orderItems.get(order.Id).size()) {
				order.Dan360_SemaforoPicklist__c = 'Verde';
			} else if (!orderItemsWithInactiveQuota.isEmpty()) {
				order.Dan360_SemaforoPicklist__c = getTrafficLight(hasItemsWithStock, hasItemsWithStockButNotEnough, hasItemsWithoutStock, true);
			} else {
				order.Dan360_SemaforoPicklist__c = getTrafficLight(hasItemsWithStock, hasItemsWithStockButNotEnough, hasItemsWithoutStock, false);
			}

			ordersToUpdate.add(order);
			System.debug('order.Status Despues');
			System.debug(order.Status);
		}

		return ordersToUpdate;
	}

	private static String getTrafficLight(
		Boolean hasItemsWithStock,
		Boolean hasItemsWithStockButNotEnough,
		Boolean hasItemsWithoutStock,
		Boolean hasInactiveItems
	) {
		String trafficLight;

		if (hasItemsWithStockButNotEnough || (hasItemsWithoutStock && hasItemsWithStock)) {
			trafficLight = 'Amarillo';
		} else if (hasItemsWithStock && (!hasItemsWithStockButNotEnough && !hasItemsWithoutStock)) {
			trafficLight = 'Verde';
		} else if (hasItemsWithoutStock && (!hasItemsWithStockButNotEnough && !hasItemsWithStock)) {
			if (hasInactiveItems) {
				trafficLight = 'Amarillo';
			} else {
				trafficLight = 'Rojo';
			}
		} else {
			trafficLight = 'Verde';
		}

		return trafficLight;
	}
}