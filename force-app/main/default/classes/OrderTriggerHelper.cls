public with sharing class OrderTriggerHelper {
	/**
	 * @author            : Diego Valle
	 * @created date      : 08-09-2021
	 * @last modified by  : Luis Hurtado
	 * @last modified on  : 07-08-2023
	 * @description       : Class that contains all helper functions
	 *                      related to Order Trigger object.
	 * Modifications Log
	 * Ver   Date         Author        Modification
	 * 1.0   02-09-2021   Diego Valle   Initial Version
	**/
	public class OrderItemWithQuotaWrapper {
		OrderItem orderItem;
		Dan360_Cuota__c quota;

		public OrderItemWithQuotaWrapper(OrderItem orderItem, Dan360_Cuota__c quota) {
			this.orderItem = orderItem;
			this.quota = quota;
		}
	}

	public static String orderShouldBe(
		Id orderId,
		Map<Id, Map<OrderItem,Map<String, List<Dan360_Cuota__c>>>> orderWithItemsAndDues
	) {
		Map<OrderItem, Map<String, List<Dan360_Cuota__c>>> orderItemsWithDues = orderWithItemsAndDues.get(orderId);
		Boolean canProcess = true;
		Boolean needToSplit = false;
		Boolean block = false;

		Map<String, Decimal> mapProductUnidadPorButo = new Map<String, Decimal>();
		Integer dif = 0;
		Set<String> productList = new Set<String>();
		for (OrderItem orderItem : orderItemsWithDues.keySet()) {
			productList.add(orderItem.Product2Id);
		}
		System.debug(productList);
		for (Product2 product : [SELECT Id, Dan360_UnidadesPorBulto__c FROM Product2 WHERE ID IN :productList]) {
			if (!mapProductUnidadPorButo.containsKey(product.Id)) {
				mapProductUnidadPorButo.put(product.Id, product.Dan360_UnidadesPorBulto__c);
			}
		}
		for (OrderItem orderItem : orderItemsWithDues.keySet()) {

			Integer unidadesxBulto = Integer.valueOf(mapProductUnidadPorButo.get(orderItem.Product2Id));  
				
			Map<String, List<Dan360_Cuota__c>> dues = orderItemsWithDues.get(orderItem);

			List<Dan360_Cuota__c> duesBySubsidiary = dues.get('Subsidiary');
			List<Dan360_Cuota__c> duesByClient = dues.get('Client');
			List<Dan360_Cuota__c> duesBySalesDistrict = dues.get('SalesDistrict');
			List<Dan360_Cuota__c> duesByDistributionChannel = dues.get('DistributionChannel');
			List<Dan360_Cuota__c> duesByProduct = dues.get('Product');

			System.debug('test - dues By Subsidiary');
			System.debug(duesBySubsidiary);
			System.debug('test - dues By Client');
			System.debug(duesByClient);
			System.debug('test - dues By SalesDistrict');
			System.debug(duesBySalesDistrict);
			System.debug('test - dues By DistributionChannel');
			System.debug(duesByDistributionChannel);
			System.debug('test - dues By Product');
			System.debug(duesByProduct);

			if (duesBySubsidiary != null && !duesBySubsidiary.isEmpty()) {
				for (Dan360_Cuota__c quota : duesBySubsidiary) {
					if( quota.Dan360_Producto__c == orderItem.Product2Id ){
						if (quota.Dan360_Saldo__c < orderItem.Quantity) {
							canProcess = false;

							if (quota.Dan360_Saldo__c == 0 && !needToSplit) {
								block = true;
							} else if (quota.Dan360_Saldo__c >= unidadesxBulto) {
								needToSplit = true;
								block = false;
							}
						} else if (!canProcess && quota.Dan360_Saldo__c >= orderItem.Quantity) {
							needToSplit = true;
							block = false;
						}
					}
				}
				break; 
			}

			else if (canProcess && duesByClient != null && !duesByClient.isEmpty()) {
				for (Dan360_Cuota__c quota : duesByClient) {
					system.debug('Saldo cuota '+quota.Dan360_Saldo__c);
					system.debug('Cantidad item '+orderItem.Quantity);
					system.debug('Unidad x Bulto '+unidadesxBulto);
					if( quota.Dan360_Producto__c == orderItem.Product2Id ){
						if (quota.Dan360_Saldo__c < orderItem.Quantity) { 
							canProcess = false;

							if (quota.Dan360_Saldo__c == 0 && !needToSplit) {
								block = true;
							} else if (quota.Dan360_Saldo__c >= unidadesxBulto) {
								needToSplit = true;
								block = false;
							}
						} else if (!canProcess && quota.Dan360_Saldo__c >= orderItem.Quantity) { 
							needToSplit = true;
							block = false;
						}
					}
				}
				break; 
			} else {
				if (canProcess && duesBySalesDistrict != null && !duesBySalesDistrict.isEmpty()) {
					for (Dan360_Cuota__c quota : duesBySalesDistrict) {
						if( quota.Dan360_Producto__c == orderItem.Product2Id ){

							if (quota.Dan360_Saldo__c < orderItem.Quantity) { 
								canProcess = false;

								if (quota.Dan360_Saldo__c == 0 && !needToSplit) {
									block = true;
								} else if (quota.Dan360_Saldo__c >= unidadesxBulto) {
									needToSplit = true;
									block = false;
								}
							} else if (!canProcess && quota.Dan360_Saldo__c >= orderItem.Quantity) {
								needToSplit = true;
								block = false;
							}
						}
					}
				}

				if (canProcess && duesByDistributionChannel != null && !duesByDistributionChannel.isEmpty()) {
					for (Dan360_Cuota__c quota : duesByDistributionChannel) {
						if( quota.Dan360_Producto__c == orderItem.Product2Id ){
							if (quota.Dan360_Saldo__c < orderItem.Quantity) {
								canProcess = false;

								if (quota.Dan360_Saldo__c == 0 && !needToSplit) {
									block = true;
								} else if (quota.Dan360_Saldo__c >= unidadesxBulto) {
									needToSplit = true;
									block = false;
								}
							} else if (!canProcess && quota.Dan360_Saldo__c >= orderItem.Quantity) {
								needToSplit = true;
								block = false;
							}
						}
					}
				}

				if (canProcess && duesByProduct != null && !duesByProduct.isEmpty()) {
					for (Dan360_Cuota__c quota : duesByProduct) {
						if( quota.Dan360_Producto__c == orderItem.Product2Id ){
							if (quota.Dan360_Saldo__c < orderItem.Quantity) {
								canProcess = false;

								if (quota.Dan360_Saldo__c == 0 && !needToSplit) {
									block = true;
								} else if (quota.Dan360_Saldo__c >= unidadesxBulto) {
									needToSplit = true;
									block = false;
								}
							} else if (!canProcess && quota.Dan360_Saldo__c >= orderItem.Quantity) {
								needToSplit = true;
								block = false;
							}
						}
					}
				}
			}
		}
		if (block) {
			System.debug('block');
			return 'block';
		} else if (needToSplit) {
			System.debug('split');
			return 'split';
		} else {
			System.debug('process');
			return 'process';
		}
	}

	public static void splitOrders(
		Map<Id, Order> ordersToSplit,
		Map<Id, Map<OrderItem, Map<String, List<Dan360_Cuota__c>>>> sortedItemsByOrder,
		List<OrderItem> orderItemsWithQuotaZero,
		List<OrderItem> orderItemsToUpdate,
		List<OrderItem> orderItemsToNewSplittedOrder
	) {
		List<Order> clonedOrders = new List<Order>();
		decimal menorSaldo; 
		decimal itemQuantityReply; 
		List<String> ordersIds = new List<String>();
		Map<String, String> mapOrderPedidoPorCuota = new Map<String, String>();
		System.debug('ordersToSplit: '+ ordersToSplit);
		for (Order orderToClone : ordersToSplit.values()) {
			ordersIds.add(orderToClone.Id);
		}

		/* for(Dan360_Pedidos_por_cuota__c pedidoCuota : [SELECT id, Dan360_Pedido__c FROM Dan360_Pedidos_por_cuota__c WHERE Dan360_Pedido__c IN :ordersIds]){
			if(!mapOrderPedidoPorCuota.containsKey(pedidoCuota.Dan360_Pedido__c)){
				mapOrderPedidoPorCuota.put(pedidoCuota.Dan360_Pedido__c, pedidoCuota.Id);
			}
		}
		System.debug('mapOrderPedidoPorCuota');
		System.debug(mapOrderPedidoPorCuota); */

		for (Order orderToClone : ordersToSplit.values()) {
			Order clonedOrder = orderToClone.clone(false, true, false, false);
			clonedOrder.Dan360_PedidoPrincipal__c = orderToClone.Id;
			clonedOrder.Status = 'Retenido por cuota';
			clonedOrder.Dan360_SemaforoPicklist__c = 'Rojo';
			clonedOrder.Dan360_Id_Externo__c = null;
			clonedOrders.add(clonedOrder);		
		}

		System.debug('[splitOrders] cloned orders: ' + JSON.serialize(clonedOrders));

		insert clonedOrders;



		Map<String, Decimal> mapProductUnidadPorButo = new Map<String, Decimal>();
		Integer dif = 0;
		for (Product2 product : [SELECT Id, Dan360_UnidadesPorBulto__c FROM Product2]) {
			if (!mapProductUnidadPorButo.containsKey(product.Id)) {
				mapProductUnidadPorButo.put(product.Id, product.Dan360_UnidadesPorBulto__c);
			}
		}

		for (Order order : clonedOrders) {
			/* if(mapOrderPedidoPorCuota.containsKey(order.Dan360_PedidoPrincipal__c)){
				String pedidoPorCuotaOld = mapOrderPedidoPorCuota.get(order.Dan360_PedidoPrincipal__c);
				Dan360_Pedidos_por_cuota__c pedidoCuotaNew = new Dan360_Pedidos_por_cuota__c();
				pedidoCuotaNew.Dan360_Pedido__c = order.Id;
				pedidoCuotaNew.Dan360_Cuota__c = pedidoPorCuotaOld;
				//pedidoPorCuotaNuevosInsert.add(pedidoCuotaNew);
			} */
			
            System.debug('originalOrder Contenido >> '+ JSON.serialize(order) );
			Order originalOrder = ordersToSplit.get(order.Dan360_PedidoPrincipal__c);
			if (sortedItemsByOrder.containsKey(originalOrder.Id)) {
				Map<OrderItem, Map<String, List<Dan360_Cuota__c>>> orderItemsWithDues = sortedItemsByOrder.get(originalOrder.Id);
				Set<OrderItem> orderItems = orderItemsWithDues.keySet();
	
				for (OrderItem item : orderItems) {
					OrderItem clonedOrderItem = item.clone(false, true, false, false);
					Map<String, List<Dan360_Cuota__c>> orderItemDues = orderItemsWithDues.get(item);
					clonedOrderItem.ListPrice = null;
					clonedOrderItem.OrderId = order.Id;

					List<Dan360_Cuota__c> duesBySubsidiary = orderItemDues.get('Subsidiary');
					List<Dan360_Cuota__c> duesByClient = orderItemDues.get('Client');
					List<Dan360_Cuota__c> duesBySalesDistrict = orderItemDues.get('SalesDistrict');
					List<Dan360_Cuota__c> duesByDistributionChannel = orderItemDues.get('DistributionChannel');
					List<Dan360_Cuota__c> duesByProduct = orderItemDues.get('Product');

					if (duesBySubsidiary != null && !duesBySubsidiary.isEmpty()) {
						for (Dan360_Cuota__c quota : duesBySubsidiary) {
							System.debug('Entro en duesBySubsidiary');
							if (quota.Dan360_Producto__c == item.Product2Id) {
								if (quota.Dan360_Saldo__c == 0) {
									orderItemsWithQuotaZero.add(item);
									orderItemsToNewSplittedOrder.add(clonedOrderItem);
									break;
								} else if (quota.Dan360_Saldo__c > 0 && quota.Dan360_Saldo__c < item.Quantity) { 
									Integer unidadesPorBulto = Integer.valueOf(mapProductUnidadPorButo.get(item.Product2Id)); 
									if (quota.Dan360_Saldo__c > unidadesPorBulto && unidadesPorBulto != 0) { 
										dif = Math.mod( Integer.valueOf(quota.Dan360_Saldo__c), unidadesPorBulto);     
									}
									if (dif != 0) {
										Decimal itemQuantityInnitial = item.Quantity;         
										item.Quantity = quota.Dan360_Saldo__c - dif;
										clonedOrderItem.Quantity = itemQuantityInnitial - item.quantity;
									} else {
										clonedOrderItem.Quantity = item.Quantity - quota.Dan360_Saldo__c; 
										item.Quantity = quota.Dan360_Saldo__c;
									}
									orderItemsToNewSplittedOrder.add(clonedOrderItem);  
									orderItemsToUpdate.add(item); 
									break;
								}                               
							}
						}
						break; 
                    }
					else if (duesByClient != null && !duesByClient.isEmpty()) {
						for (Dan360_Cuota__c quota : duesByClient) {
								System.debug('Entro en duesByClient');
								if (quota.Dan360_Producto__c == item.Product2Id) {
									if (quota.Dan360_Saldo__c == 0) {
										orderItemsWithQuotaZero.add(item);
										orderItemsToNewSplittedOrder.add(clonedOrderItem);
										break;
									} else if (quota.Dan360_Saldo__c > 0 && quota.Dan360_Saldo__c < item.Quantity) {	
										Integer unidadesPorBulto = Integer.valueOf(mapProductUnidadPorButo.get(item.Product2Id)); 

										if (quota.Dan360_Saldo__c > unidadesPorBulto && unidadesPorBulto != 0) { 
											dif = Math.mod( Integer.valueOf(quota.Dan360_Saldo__c), unidadesPorBulto); 
										}
	
										if (dif != 0) {
											Decimal itemQuantityInnitial = item.Quantity; 
											item.Quantity = quota.Dan360_Saldo__c - dif; 
											clonedOrderItem.Quantity = itemQuantityInnitial - item.quantity; 
										} else {
											clonedOrderItem.Quantity = item.Quantity - quota.Dan360_Saldo__c;
											item.Quantity = quota.Dan360_Saldo__c; 
										}
										orderItemsToNewSplittedOrder.add(clonedOrderItem);  
										orderItemsToUpdate.add(item); 
										break;
									} 
								}
								break; 				
						}
						break; 
					} else {
						if (duesBySalesDistrict != null && !duesBySalesDistrict.isEmpty()) { 
							for (Dan360_Cuota__c quota : duesBySalesDistrict) {
								System.debug('Entro en duesBySalesDistrict');
								if (quota.Dan360_Producto__c == item.Product2Id) {									
									if (quota.Dan360_Saldo__c == 0) {
										orderItemsWithQuotaZero.add(item);
										orderItemsToNewSplittedOrder.add(clonedOrderItem);
										break;
									} else if (quota.Dan360_Saldo__c > 0 && quota.Dan360_Saldo__c < item.Quantity) {										
										Integer unidadesPorBulto = Integer.valueOf(mapProductUnidadPorButo.get(item.Product2Id)); 
										menorSaldo = quota.Dan360_Saldo__c; 
										itemQuantityReply = item.Quantity; 

										if (quota.Dan360_Saldo__c > unidadesPorBulto && unidadesPorBulto != 0) { 
											dif = Math.mod( Integer.valueOf(menorSaldo), unidadesPorBulto); 
									    }

										if (dif != 0) {
											Decimal itemQuantityInnitial = item.Quantity;               
											item.Quantity = quota.Dan360_Saldo__c - dif; 
											clonedOrderItem.Quantity = itemQuantityInnitial - item.quantity; 
										} else {
											clonedOrderItem.Quantity = item.Quantity - menorSaldo; 
											item.Quantity = quota.Dan360_Saldo__c; 				
										}
										orderItemsToNewSplittedOrder.add(clonedOrderItem); 
										orderItemsToUpdate.add(item);
										break;
									}
								}
							}
						}
						if (duesByDistributionChannel != null && !duesByDistributionChannel.isEmpty()) {
							for (Dan360_Cuota__c quota : duesByDistributionChannel) {
								System.debug('Entro en duesByDistributionChannel');
								if (quota.Dan360_Producto__c == item.Product2Id) {
									if (quota.Dan360_Saldo__c == 0) {
										orderItemsWithQuotaZero.add(item);
										orderItemsToNewSplittedOrder.add(clonedOrderItem);
										break;
									} else if (quota.Dan360_Saldo__c > 0 && quota.Dan360_Saldo__c < item.Quantity) {
										Integer unidadesPorBulto = Integer.valueOf(mapProductUnidadPorButo.get(item.Product2Id)); 
										if (menorSaldo != null) {
											if (quota.Dan360_Saldo__c < menorSaldo) { 
												menorSaldo = quota.Dan360_Saldo__c;
												item.Quantity = itemQuantityReply;
											}
										} else {
											menorSaldo = quota.Dan360_Saldo__c; 
										}

										if (quota.Dan360_Saldo__c > unidadesPorBulto && unidadesPorBulto != 0) { 
											dif = Math.mod( Integer.valueOf(menorSaldo), unidadesPorBulto);				
									    }
										
										if (dif != 0) {
											Decimal itemQuantityInnitial = item.Quantity;
											item.Quantity = quota.Dan360_Saldo__c - dif; 
											clonedOrderItem.Quantity = itemQuantityInnitial - item.quantity; 
										} else {
											clonedOrderItem.Quantity = item.Quantity - menorSaldo; 
											item.Quantity = quota.Dan360_Saldo__c; 
										}
										orderItemsToNewSplittedOrder.add(clonedOrderItem); 
										orderItemsToUpdate.add(item);
										break;
									}
								}
							}
						}		
						if (duesByProduct != null && !duesByProduct.isEmpty()) {
							for (Dan360_Cuota__c quota : duesByProduct) {
								System.debug('Entro en duesByProduct');
								if (quota.Dan360_Producto__c == item.Product2Id) {
									if (quota.Dan360_Saldo__c == 0) {
										orderItemsWithQuotaZero.add(item);
										orderItemsToNewSplittedOrder.add(clonedOrderItem);
										break;
									} else if (quota.Dan360_Saldo__c > 0 && quota.Dan360_Saldo__c < item.Quantity) {
										Integer unidadesPorBulto = Integer.valueOf(mapProductUnidadPorButo.get(item.Product2Id)); //
										if (menorSaldo != null) {
											if (quota.Dan360_Saldo__c < menorSaldo) { 
												menorSaldo = quota.Dan360_Saldo__c; 
												item.Quantity = itemQuantityReply; 
											}
										} else {
											menorSaldo = quota.Dan360_Saldo__c; 
										}

										if (quota.Dan360_Saldo__c > unidadesPorBulto && unidadesPorBulto != 0) { 
											dif = Math.mod( Integer.valueOf(menorSaldo), unidadesPorBulto);  
									    }

										if (dif != 0) {
											Decimal itemQuantityInnitial = item.Quantity;             
											item.Quantity = quota.Dan360_Saldo__c - dif; 
											clonedOrderItem.Quantity = itemQuantityInnitial - item.quantity; 
										} else {
											clonedOrderItem.Quantity = item.Quantity - menorSaldo; 
											item.Quantity = quota.Dan360_Saldo__c; 
										}
										orderItemsToNewSplittedOrder.add(clonedOrderItem); 
										orderItemsToUpdate.add(item);
										break;
									}
								}
							}
						}
					}
				}
			}
		}
	}

	public static void processOrders(
		List<Order> orders,
		Map<Id, Map<OrderItem, Map<String, List<Dan360_Cuota__c>>>> sortedOrderItemsWithRelatedQuota
	) {
		Map<Id, Dan360_Cuota__c> duesToUpdate = new Map<Id, Dan360_Cuota__c>();
		System.debug('orders '+JSON.serialize(orders));
		System.debug('order item con cuota: '+sortedOrderItemsWithRelatedQuota);

		for (Order order : orders) {
			Map<OrderItem, Map<String, List<Dan360_Cuota__c>>> itemsDues = sortedOrderItemsWithRelatedQuota.get(order.Id);
			Set<OrderItem> orderItems = itemsDues.keySet();

			System.debug('itemsDues');
			System.debug(JSON.serialize(itemsDues));

			System.debug('orderItems');
			System.debug(JSON.serialize(orderItems));

			for (OrderItem item : orderItems) {
				Map<String, List<Dan360_Cuota__c>> orderItemDues = itemsDues.get(item);

				System.debug('orderItemDues - 1');
				System.debug(JSON.serialize(orderItemDues));

				List<Dan360_Cuota__c> duesBySubsidiary = orderItemDues.get('Subsidiary');
				List<Dan360_Cuota__c> duesByClient = orderItemDues.get('Client');
				List<Dan360_Cuota__c> duesBySalesDistrict = orderItemDues.get('SalesDistrict');
				List<Dan360_Cuota__c> duesByDistributionChannel = orderItemDues.get('DistributionChannel');
				List<Dan360_Cuota__c> duesByProduct = orderItemDues.get('Product');

				System.debug('duesBySubsidiary');
				System.debug(JSON.serialize(duesBySubsidiary));
				System.debug('this duesByClient');
				System.debug(JSON.serialize(duesByClient));
				System.debug('this duesBySalesDistrict');
				System.debug(JSON.serialize(duesBySalesDistrict));
				System.debug('duesByDistributionChannel');
				System.debug(JSON.serialize(duesByDistributionChannel));
				System.debug('duesByProduct');
				System.debug(JSON.serialize(duesByProduct));

				if (duesBySubsidiary != null && !duesBySubsidiary.isEmpty()) {
					for (Dan360_Cuota__c quota : duesBySubsidiary) {
						if (quota.Dan360_Producto__c == item.Product2Id) {
							quota.Dan360_Saldo__c = quota.Dan360_Saldo__c - item.Quantity < 0 ? 0 : quota.Dan360_Saldo__c - item.Quantity;
							duesToUpdate.put(quota.Id, quota);
						}
					}
				}

				if (duesByClient != null && !duesByClient.isEmpty()) {
					for (Dan360_Cuota__c quota : duesByClient) {
						if (quota.Dan360_Producto__c == item.Product2Id) {
							quota.Dan360_Saldo__c = quota.Dan360_Saldo__c - item.Quantity < 0 ? 0 : quota.Dan360_Saldo__c - item.Quantity;
							duesToUpdate.put(quota.Id, quota);
						}
					}
				}

				if (duesBySalesDistrict != null && !duesBySalesDistrict.isEmpty()) {
					for (Dan360_Cuota__c quota : duesBySalesDistrict) {
						if (quota.Dan360_Producto__c == item.Product2Id) {
							quota.Dan360_Saldo__c = quota.Dan360_Saldo__c - item.Quantity < 0 ? 0 : quota.Dan360_Saldo__c - item.Quantity;
							duesToUpdate.put(quota.Id, quota);
						}
					}
				}

				if (duesByDistributionChannel != null && !duesByDistributionChannel.isEmpty()) {
					for (Dan360_Cuota__c quota : duesByDistributionChannel) {
						if (quota.Dan360_Producto__c == item.Product2Id) {
							quota.Dan360_Saldo__c = quota.Dan360_Saldo__c - item.Quantity < 0 ? 0 : quota.Dan360_Saldo__c - item.Quantity;
							duesToUpdate.put(quota.Id, quota);
						}
					}
				}

				if (duesByProduct != null && !duesByProduct.isEmpty()) {
					for (Dan360_Cuota__c quota : duesByProduct) {
						if (quota.Dan360_Producto__c == item.Product2Id) {
							quota.Dan360_Saldo__c = quota.Dan360_Saldo__c - item.Quantity < 0 ? 0 : quota.Dan360_Saldo__c - item.Quantity;
							duesToUpdate.put(quota.Id, quota);
						}
					}
				}
			}
		}
		update duesToUpdate.values();
	}

	public static void insertOrdersByQuota(
		Order order,
		List<OrderItem> orderItems,
		Map<String, List<Dan360_Cuota__c>> dues
	) {
		List<Dan360_Pedidos_por_cuota__c> ordersByQuota = new List<Dan360_Pedidos_por_cuota__c>();
		Map<Id, List<Dan360_Pedidos_por_cuota__c>> mappedQuota = new Map<Id, List<Dan360_Pedidos_por_cuota__c>>();
		List<Dan360_Pedidos_por_cuota__c> listOrderByQuota = new List<Dan360_Pedidos_por_cuota__c>();
		
		if (orderItems != null && !orderItems.isEmpty()) {
			Map<Id, List<Dan360_Cuota__c>> duesToOrder = getDuesToOrders(order, dues, orderItems);

			for (OrderItem orderItem : orderItems) {
				System.debug('orderItem');
				System.debug(orderItem);
				if (duesToOrder.containsKey(orderItem.Product2Id)) { 
					List<Dan360_Cuota__c> listQuotas = duesToOrder.get(orderItem.Product2Id);
					for (Dan360_Cuota__c quota : listQuotas) { 
						System.debug('quota');
						System.debug(quota);
						System.debug('mappedQuota');
						System.debug(mappedQuota);
						
						Dan360_Pedidos_por_cuota__c orderByQuota = new Dan360_Pedidos_por_cuota__c();
						if(quota.Dan360_Cliente__c == order.AccountId && (quota.Dan360_CanalComercial__c == null && quota.Dan360_CanalDistribucion__c == null)){
							System.debug('entra Cliente');
							if (!mappedQuota.containsKey(quota.Id)) {
								orderByQuota.Dan360_Pedido__c = order.Id;
								orderByQuota.Dan360_Cuota__c = quota.Id;
								orderByQuota.Dan360_Cantidad__c = orderItem.Quantity;
								mappedQuota.put(quota.Id, new List<Dan360_Pedidos_por_cuota__c>());
								listOrderByQuota.add(orderByQuota);
								mappedQuota.get(quota.Id).add(orderByQuota);
							}
						}
						String[] listSalesDistrict = order.Account.Dan360_SalesDistric1__c.split(';');
						if(listSalesDistrict.contains(quota.Dan360_CanalComercial__c) && (quota.Dan360_Cliente__c == null && quota.Dan360_CanalDistribucion__c == null)){
							System.debug('entra Dan360_CanalComercial__c');
							if (!mappedQuota.containsKey(quota.Id)) {
								orderByQuota.Dan360_Pedido__c = order.Id;
								orderByQuota.Dan360_Cuota__c = quota.Id;
								orderByQuota.Dan360_Cantidad__c = orderItem.Quantity;
								mappedQuota.put(quota.Id, new List<Dan360_Pedidos_por_cuota__c>());
								listOrderByQuota.add(orderByQuota);
								mappedQuota.get(quota.Id).add(orderByQuota);
							}
						}
						if(quota.Dan360_CanalDistribucion__c == order.Account.Dan360_DistributionChannel__c && (quota.Dan360_CanalComercial__c ==  null && quota.Dan360_Cliente__c == null)){
							System.debug('entra Dan360_CanalDistribucion__c');
							if (!mappedQuota.containsKey(quota.Id)) {
								orderByQuota.Dan360_Pedido__c = order.Id;
								orderByQuota.Dan360_Cuota__c = quota.Id;
								orderByQuota.Dan360_Cantidad__c = orderItem.Quantity;
								mappedQuota.put(quota.Id, new List<Dan360_Pedidos_por_cuota__c>());
								listOrderByQuota.add(orderByQuota);
								mappedQuota.get(quota.Id).add(orderByQuota);
							}
						}
						if(quota.Dan360_CanalDistribucion__c == null && quota.Dan360_CanalComercial__c == null && quota.Dan360_Cliente__c == null){
							System.debug('entra producto');
							if (!mappedQuota.containsKey(quota.Id)) {
								orderByQuota.Dan360_Pedido__c = order.Id;
								orderByQuota.Dan360_Cuota__c = quota.Id;
								orderByQuota.Dan360_Cantidad__c = orderItem.Quantity;
								mappedQuota.put(quota.Id, new List<Dan360_Pedidos_por_cuota__c>());
								listOrderByQuota.add(orderByQuota);
								mappedQuota.get(quota.Id).add(orderByQuota);
							}
						}
						//mappedQuota.get(quota.Id).add(orderByQuota);
					}
				}
			}
		}
		if (Trigger.isAfter) {
			insert listOrderByQuota;
		}
	}

	public static Map<Id, List<Dan360_Cuota__c>> getDuesToOrders(
		Order order,
		Map<String, List<Dan360_Cuota__c>> dues,
		List<OrderItem> orderItems 

	) {
		Map<Id, List<Dan360_Cuota__c>> duesToOrder = new Map<Id, List<Dan360_Cuota__c>>();
		Map<String, List<Dan360_Cuota__c>> mappedDues = new Map<String, List<Dan360_Cuota__c>>();

		for (String type : dues.keySet()) {
			if (dues.get(type) != null && !dues.get(type).isEmpty()) {
				for (Dan360_Cuota__c quota : dues.get(type)) {
					switch on type {
						when 'Subsidiary', 'Client' {
							if (!mappedDues.containsKey(quota.Dan360_Cliente__c)) {
								mappedDues.put(quota.Dan360_Cliente__c, new List<Dan360_Cuota__c>());
							}
							mappedDues.get(quota.Dan360_Cliente__c).add(quota);
						}
						when 'SalesDistrict' {
							if (!mappedDues.containsKey(quota.Dan360_CanalComercial__c)) {
								mappedDues.put(quota.Dan360_CanalComercial__c, new List<Dan360_Cuota__c>());
							}
							mappedDues.get(quota.Dan360_CanalComercial__c).add(quota);
						}
						when 'DistributionChannel' {
							if (!mappedDues.containsKey(quota.Dan360_CanalDistribucion__c)) {
								mappedDues.put(quota.Dan360_CanalDistribucion__c, new List<Dan360_Cuota__c>());
							}
							mappedDues.get(quota.Dan360_CanalDistribucion__c).add(quota);
						}
						when 'Product' {
							if (!mappedDues.containsKey(quota.Dan360_Producto__c)) {
								mappedDues.put(quota.Dan360_Producto__c, new List<Dan360_Cuota__c>());
							}
							mappedDues.get(quota.Dan360_Producto__c).add(quota);
						}
					}					
				}
			}
		}

		if (mappedDues.containsKey(order.AccountId)) {
			for (Dan360_Cuota__c quota : mappedDues.get(order.AccountId)) {
				if (!duesToOrder.containsKey(quota.Dan360_Producto__c)) {
					duesToOrder.put(quota.Dan360_Producto__c, new List<Dan360_Cuota__c>());
				}
				duesToOrder.get(quota.Dan360_Producto__c).add(quota);
			}
		}

		if (order.Account.Dan360_SalesDistric1__c != null){
			String[] listSalesDistrict = order.Account.Dan360_SalesDistric1__c.split(';');
			if (!listSalesDistrict.isEmpty()) {
				for (String aSaleDistrict : listSalesDistrict) {
					if (mappedDues.containsKey(aSaleDistrict)) {
						for (Dan360_Cuota__c quota : mappedDues.get(aSaleDistrict)) {
							if (!duesToOrder.containsKey(quota.Dan360_Producto__c)) {
								duesToOrder.put(quota.Dan360_Producto__c, new List<Dan360_Cuota__c>());
							}
							if(quota.Dan360_CanalDistribucion__c == null && quota.Dan360_Cliente__c == null){
								duesToOrder.get(quota.Dan360_Producto__c).add(quota);
							}
							
						}
					}
				}
			}
		}

		if (order.Account.Dan360_DistributionChannel__c != null){
			String[] listDistributionChannel = order.Account.Dan360_DistributionChannel__c.split(';');
			if (!listDistributionChannel.isEmpty()) {
				for (String aDistributionChannel : listDistributionChannel) {
					if (mappedDues.containsKey(aDistributionChannel)) {
						for (Dan360_Cuota__c quota : mappedDues.get(aDistributionChannel)) {
							if (!duesToOrder.containsKey(quota.Dan360_Producto__c)) {
								duesToOrder.put(quota.Dan360_Producto__c, new List<Dan360_Cuota__c>());
							}
								duesToOrder.get(quota.Dan360_Producto__c).add(quota);
							
						}
					}
				}
			}
		}

		if (!orderItems.isEmpty()) {
			for (OrderItem orderItem : orderItems) {
				if (mappedDues.containsKey(orderItem.Product2Id)) {
					for (Dan360_Cuota__c quota : mappedDues.get(orderItem.Product2Id)) {
						if (!duesToOrder.containsKey(quota.Dan360_Producto__c)) {
							duesToOrder.put(quota.Dan360_Producto__c, new List<Dan360_Cuota__c>());
						}
						
							duesToOrder.get(quota.Dan360_Producto__c).add(quota);
		
						
					}
				}
			}
		}
		System.debug(duesToOrder);
		return duesToOrder;
	}

	public static Map<Id, List<OrderItem>> getOrderItems(List<Order> orders) {
		Map<Id, List<OrderItem>> orderItems = new Map<Id, List<OrderItem>>();

		for (OrderItem orderItem : [
			SELECT  Id,
					OrderId,
					Product2Id,
					Quantity,
					PricebookEntryId,
					UnitPrice,
					Dan360_UnidadMedida__c
			FROM    OrderItem
			WHERE   OrderId IN :orders
		]) {
			if (!orderItems.containsKey(orderItem.OrderId)) {
				orderItems.put(orderItem.OrderId, new List<OrderItem>());
			}
			orderItems.get(orderItem.OrderId).add(orderItem);
		}

		return orderItems;
	}

	public static void getDuesBy(
		Set<String> filter,
		String filterBy,
		Map<String, List<Dan360_Cuota__c>> mappedDues
	) {
		String soqlQuery = 'SELECT  Id,';
		soqlQuery += '              Name,';
		soqlQuery += '              Dan360_Cliente__c,';
		soqlQuery += '              Dan360_CanalComercial__c,';
		soqlQuery += '              Dan360_CanalDistribucion__c,';
		soqlQuery += '              Dan360_Producto__c,';
		soqlQuery += '              Dan360_Saldo__c,';
		soqlQuery += '              Dan360_EstadoCuota__c';
		soqlQuery += '      FROM    Dan360_Cuota__c';
		soqlQuery += '      WHERE   Dan360_EstadoCuota__c = \'Activa\'';

		if (filterBy == 'Subsidiary' || filterBy == 'Client') {
			soqlQuery += '  AND Dan360_Cliente__c IN :filter';
		}

		if (filterBy == 'SalesDistrict') {

			String[] listSalesDistrict = new List<String>();
			for (String aFilter : filter) {
				listSalesDistrict = aFilter.split(';');
			}
			
			soqlQuery += '  AND Dan360_CanalComercial__c IN :listSalesDistrict';
		}
		if (filterBy == 'DistributionChannel') {
			String[] listDistributionChannel = new List<String>();
			for (String aFilter : filter) {
				listDistributionChannel = aFilter.split(';');
			}
			soqlQuery += '  AND Dan360_CanalDistribucion__c IN :listDistributionChannel';
		}

		if (filterBy == 'Product') {
			soqlQuery += '  AND Dan360_Producto__c IN :filter';
		}

		System.debug(Database.query(soqlQuery));

		for (Dan360_Cuota__c quota : Database.query(soqlQuery)) {
			switch on filterBy {
				when 'Client', 'Subsidiary' {
					if (!mappedDues.containsKey(filterBy)) {
						mappedDues.put(filterBy, new List<Dan360_Cuota__c>());
					}
					mappedDues.get(filterBy).add(quota);
				}
				when 'SalesDistrict' {
					if (!mappedDues.containsKey(filterBy)) {
						mappedDues.put(filterBy, new List<Dan360_Cuota__c>());
					}
					mappedDues.get(filterBy).add(quota);
				}
				when 'DistributionChannel' {
					if (!mappedDues.containsKey(filterBy)) {
						mappedDues.put(filterBy, new List<Dan360_Cuota__c>());
					}
					mappedDues.get(filterBy).add(quota);
				}
				when 'Product' {
					if (!mappedDues.containsKey(filterBy)) {
						mappedDues.put(filterBy, new List<Dan360_Cuota__c>());
					}
					mappedDues.get(filterBy).add(quota);
				}
			}
		}
	}

	public static void sendConfirmedOrdersEmails(List<Order> orders) {
		String body;
		String subject;

		subject = 'Pedido  {0} confirmado.';

		body = 'Hola {0},';
		body += '<br />';
		body += '<br />';
		body += 'Se le informa que su pedido {1} ha sido confirmado.';
		body += '<br />';
		body += '<br />';
		body += 'Gracias.';

		List<Map<String, String>> mailsTemplates = new List<Map<String, String>>();

		Set<Id> creators = new Set<Id>();
		for (Order order : orders) {
			creators.add(order.CreatedById);
		}

		Map<Id, String> creatorsNames = new Map<Id, String>();
		for (User user : [
			SELECT  Id,
					Name
			FROM    User
			WHERE   Id IN :creators
		]) {
			creatorsNames.put(user.Id, user.Name);
		}

		for (Order order : orders) {
			String creator = creatorsNames.get(order.CreatedById);

			List<String> subjectValues = new List<String> { order.OrderNumber };
			List<String> bodyValues = new List<String> {
				creator,
				order.OrderNumber
			};

			mailsTemplates.add(
				EmailController.getMailTemplate(
					order.CreatedById,
					String.format(subject, subjectValues),
					String.format(body, bodyValues)
				)
			);
		}

		ServerResponse response = EmailController.sendMail(mailsTemplates);

		System.debug(response.state);
		System.debug(response.errors);
	}

	public static Map<Id, Map<String, List<Dan360_Cuota__c>>> matchOrdersWithDues(
		Map<Id, Map<String, String>> ordersDues,
		Map<String, List<Dan360_Cuota__c>> dues
	) {
		Map<Id, Map<String, List<Dan360_Cuota__c>>> duesByOrder = new Map<Id, Map<String, List<Dan360_Cuota__c>>>();
		System.debug(ordersDues);
		System.debug('ordersDues');
		for (Id orderId : ordersDues.keySet()) {
			Map<String, String> orderDues = ordersDues.get(orderId);
			Map<String, List<Dan360_Cuota__c>> duesByType = new Map<String, List<Dan360_Cuota__c>>();

			for (String type : orderDues.keySet()) {
				List<Dan360_Cuota__c> duesList = new List<Dan360_Cuota__c>();
				if (dues.get(type) != null && !dues.get(type).isEmpty()) {
					for (Dan360_Cuota__c quota : dues.get(type)) {
						switch on type {
							when 'Subsidiary', 'Client' {
								if (quota.Dan360_Cliente__c == orderDues.get(type)) {
									duesList.add(quota);
								}
							}
							when 'SalesDistrict' {
								String[] listSalesDistrict = orderDues.get(type).split(';');
								if (!listSalesDistrict.isEmpty()) {
									if (listSalesDistrict.contains(quota.Dan360_CanalComercial__c)) {
										duesList.add(quota);
									} 
								}
							}
							when 'DistributionChannel' {
								String[] listDistributionChannel = orderDues.get(type).split(';');
								if (!listDistributionChannel.isEmpty()) {
									if (listDistributionChannel.contains(quota.Dan360_CanalDistribucion__c)) {
										duesList.add(quota);
									}
								}
							}
							when 'Product' {
								if (quota.Dan360_Producto__c == orderDues.get(type)) {
									duesList.add(quota);
								}
							}
						}
					}
					duesByType.put(type, duesList);
				}
			}

			duesByOrder.put(orderId, duesByType);
		}

		return duesByOrder;
	}

	public static Map<Id, Map<OrderItem, Map<String, List<Dan360_Cuota__c>>>> matchOrderDuesWithOrderItems(
		Map<Id, Map<String, String>> ordersDues,
		Map<Id, Map<String, List<Dan360_Cuota__c>>> duesByOrder,
		Map<Id, List<OrderItem>> itemsByOrder
	) {
		Map<Id, Map<OrderItem, Map<String, List<Dan360_Cuota__c>>>> orderDuesWithItems = new Map<Id, Map<OrderItem, Map<String, List<Dan360_Cuota__c>>>>();

		for (Id orderId : duesByOrder.keySet()) {
			Map<OrderItem, Map<String, List<Dan360_Cuota__c>>> duesByOrderItem = new Map<OrderItem, Map<String, List<Dan360_Cuota__c>>>();
			Map<String, List<Dan360_Cuota__c>> duesTypesByOrder = duesByOrder.get(orderId);
			Map<String, String> orderDues = ordersDues.get(orderId);
			List<OrderItem> orderItems = itemsByOrder.get(orderId);
			Map<String, List<Dan360_Cuota__c>> duesBy = new Map<String, List<Dan360_Cuota__c>>();

			List<Dan360_Cuota__c> duesBySubsidiary = duesTypesByOrder.get('Subsidiary');
			List<Dan360_Cuota__c> duesByClient = duesTypesByOrder.get('Client');
			List<Dan360_Cuota__c> duesBySalesDistrict = duesTypesByOrder.get('SalesDistrict');
			List<Dan360_Cuota__c> duesByDistributionChannel = duesTypesByOrder.get('DistributionChannel');
			List<Dan360_Cuota__c> duesByProduct = duesTypesByOrder.get('Product');

			for (OrderItem item : orderItems) {
				if (duesByDistributionChannel != null && !duesByDistributionChannel.isEmpty()) {
					String[] listDistributionChannel = orderDues.get('DistributionChannel').split(';');
					for (Dan360_Cuota__c quota : duesByDistributionChannel) {
						if (quota.Dan360_Producto__c == item.Product2Id &&
							(listDistributionChannel.contains(quota.Dan360_CanalDistribucion__c))
						) {
							if (!duesBy.containsKey('DistributionChannel')) {
								duesBy.put('DistributionChannel', new List<Dan360_Cuota__c>());
							}
							duesBy.get('DistributionChannel').add(quota);
						}
					}
				}

				if (duesByProduct != null && !duesByProduct.isEmpty()) {
					for (Dan360_Cuota__c quota : duesByProduct) {
						if (quota.Dan360_Producto__c == item.Product2Id &&
							quota.Dan360_Producto__c == orderDues.get('Product') &&
							quota.Dan360_Cliente__c == null &&
							quota.Dan360_CanalDistribucion__c == null &&
							quota.Dan360_CanalComercial__c == null
						) {
							if (!duesBy.containsKey('Product')) {
								duesBy.put('Product', new List<Dan360_Cuota__c>());
							}

							if (!quotaIsNotAddedTo(duesBy.get('DistributionChannel'), quota.Id)) {
								duesBy.get('Product').add(quota);
							}
						}
					}
				}

				if (duesBySalesDistrict != null && !duesBySalesDistrict.isEmpty()) {
					String[] listSalesDistrict = orderDues.get('SalesDistrict').split(';');
					for (Dan360_Cuota__c quota : duesBySalesDistrict) {
						if (quota.Dan360_Producto__c == item.Product2Id &&
							(listSalesDistrict.contains(quota.Dan360_CanalComercial__c)) &&
							quota.Dan360_CanalDistribucion__c == null &&
							quota.Dan360_Cliente__c == null
						) {
							if (!duesBy.containsKey('SalesDistrict')) {
								duesBy.put('SalesDistrict', new List<Dan360_Cuota__c>());
							}

							if (!quotaIsNotAddedTo(duesBy.get('DistributionChannel'), quota.Id)) {
								duesBy.get('SalesDistrict').add(quota);
							}
						}
					}
				}

				if (duesByClient != null && !duesByClient.isEmpty()) {
					for (Dan360_Cuota__c quota : duesByClient) {
						if (quota.Dan360_Producto__c == item.Product2Id &&
							quota.Dan360_Cliente__c == orderDues.get('Client') &&
							quota.Dan360_CanalComercial__c == null &&
							quota.Dan360_CanalDistribucion__c == null
						) {
							if (!duesBy.containsKey('Client')) {
								duesBy.put('Client', new List<Dan360_Cuota__c>());
							}

							if (!quotaIsNotAddedTo(duesBy.get('DistributionChannel'), quota.Id)) {
								duesBy.get('Client').add(quota);
							}
						}
					}
				}

				if (duesBySubsidiary != null && !duesBySubsidiary.isEmpty()) {
					for (Dan360_Cuota__c quota : duesBySubsidiary) {
						if (quota.Dan360_Producto__c == item.Product2Id &&
							quota.Dan360_Cliente__c == orderDues.get('Subsidiary') &&
							quota.Dan360_CanalComercial__c == null &&
							quota.Dan360_CanalDistribucion__c == null
						) {
							if (!duesBy.containsKey('Subsidiary')) {
								duesBy.put('Subsidiary', new List<Dan360_Cuota__c>());
							}

							if (!quotaIsNotAddedTo(duesBy.get('DistributionChannel'), quota.Id)) {
								duesBy.get('Subsidiary').add(quota);
							}
						}
					}
				}				
				duesByOrderItem.put(item, duesBy);
			}
				
			orderDuesWithItems.put(orderId, duesByOrderItem);
		}

		return orderDuesWithItems;
	}

	public static Map<Id, List<Dan360_Cuota__c>> sortDuesByProduct(List<Dan360_Cuota__c> dues) {
		Map<Id, List<Dan360_Cuota__c>> duesByProduct = new Map<Id, List<Dan360_Cuota__c>>();

		if (dues != null && !dues.isEmpty()) {
			for (Dan360_Cuota__c quota : dues) {
				if (!duesByProduct.containsKey(quota.Dan360_Producto__c)) {
					duesByProduct.put(quota.Dan360_Producto__c, new List<Dan360_Cuota__c>());
				}
				duesByProduct.get(quota.Dan360_Producto__c).add(quota);
			}
		}

		return duesByProduct;
	}

	public static Boolean quotaIsNotAddedTo(List<Dan360_Cuota__c> dues, Id quotaId) {
		Boolean exists = false;

		if (dues != null && !dues.isEmpty()) {
			for (Dan360_Cuota__c q : dues) {
				if (q.Id == quotaId) {
					exists = true;
					break;
				}
			}
		}
		return exists;
	}
}