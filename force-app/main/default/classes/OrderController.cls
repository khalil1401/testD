/**
 * OrderController Description
 * Created by: Diego Rene Valle
 * Created Date: 13-08-2021
 * Update Date: 30-08-2021
 * Description: Actions related to orders.
 * Update:
 *  -Se agrega validación para que sólo se duplique la orden con productos activos.
 */
public with sharing class OrderController {
	@AuraEnabled
	public static ServerResponse Duplicate(String originalOrderId, Order order) {
		List<OrderItem> itemsToClone = null;
		List<OrderItem> duplicatedItems = null;
		String queryFields = '';
		String queryFieldsProduct  = '';
		String soqlQuery = '';
		String soqlQueryProduct = '';
		Order newOrder = null;
		Order orderHelper = null;
		ServerResponse response = null;

		try {
			if (!String.isBlank(originalOrderId)) {
				duplicatedItems = new List<OrderItem>();
				itemsToClone = [
					SELECT  FIELDS(STANDARD),
							Dan360_UnidadMedida__c, Dan360_Descuento__c
					FROM    OrderItem
					WHERE   OrderId = :originalOrderId
						AND Product2.IsActive = true
				];
				
				List<String> productsIds = new List<String>();
				for(OrderItem itemToRetrieve : itemsToClone){
					System.debug(itemToRetrieve);
					productsIds.add(itemToRetrieve.Product2Id);
				}
				System.debug('productsIds');
				System.debug(productsIds);

				System.debug('itemsToClone');
				System.debug(itemsToClone);
				if (itemsToClone != null && itemsToClone.size() > 0) {
					orderHelper = [
						SELECT  FIELDS(STANDARD), 
								Dan360_UnidadNegocio__c, 
								Orden_de_compra__c,
								Dan360_CustomerSalesArea__c,
								Dan360_PlantillaProductos__c
						FROM    Order
						WHERE   Id = :originalOrderId
					];

					System.debug('orderHelper.Dan360_PlantillaProductos__c');
					System.debug(orderHelper.Dan360_PlantillaProductos__c);
					Map<String, Dan360_ProductoPorPlantilla__c> mapProductIdProductForTemplate = new Map<String, Dan360_ProductoPorPlantilla__c>();
					for(Dan360_ProductoPorPlantilla__c productosPorPlantilla : [SELECT Id, Dan360_Producto__c 
																					FROM Dan360_ProductoPorPlantilla__c 
																					WHERE Dan360_Producto__c IN :productsIds
																					AND Dan360_PlantillaProductos__c = :orderHelper.Dan360_PlantillaProductos__c 
																					AND Dan360_Activo__c = false
																				]
						){
							if(!mapProductIdProductForTemplate.containsKey(productosPorPlantilla.Dan360_Producto__c)){
								mapProductIdProductForTemplate.put(productosPorPlantilla.Dan360_Producto__c, productosPorPlantilla);
							}
						}
					System.debug('mapProductIdProductForTemplate');
					System.debug(mapProductIdProductForTemplate);
					List<OrderItem> orderItemsToInsert = new List<OrderItem>();

					if(mapProductIdProductForTemplate.size() > 0){
						for(OrderItem orderItemToCheck : itemsToClone){
							if(!mapProductIdProductForTemplate.containsKey(orderItemToCheck.Product2Id)){ //Inserta en la lista los productos habilitados
								System.debug(orderItemToCheck);
								orderItemsToInsert.add(orderItemToCheck);
							}
						}
					} else {
						orderItemsToInsert = itemsToClone;
					}
					System.debug('orderItemsToInsert');
					System.debug(orderItemsToInsert);
					
					Map<String, Decimal> mapProductIDListPrice = new Map<String, Decimal>();

					for(PricebookEntry entry : [SELECT Product2Id, UnitPrice FROM Pricebookentry WHERE Pricebook2Id = :orderHelper.Pricebook2Id AND Product2Id IN :productsIds]){
						if(!mapProductIDListPrice.containsKey(entry.Product2Id)){
							mapProductIDListPrice.put(entry.Product2Id,entry.UnitPrice);
						}
					}
					System.debug(mapProductIDListPrice);
					newOrder = order.clone(false, true);
					newOrder.Dan360_CustomerSalesArea__c = orderHelper.Dan360_CustomerSalesArea__c;
					newOrder.Status = 'Borrador';
					newOrder.Dan360_Id_Externo__c = newOrder.OrderNumber;
					newOrder.EffectiveDate = newOrder.EffectiveDate < Date.today() ? Date.today() : newOrder.EffectiveDate;
					newOrder.Pricebook2Id = orderHelper.Pricebook2Id;
					newOrder.RecordTypeId = orderHelper.RecordTypeId;
					newOrder.Dan360_UnidadNegocio__c = orderHelper.Dan360_UnidadNegocio__c;
					
					// System.debug('Id externo '+order.Dan360_Id_Externo__c +' orden de compra '+order.Orden_de_compra__c);
					// System.debug('Id externo '+newOrder.Dan360_Id_Externo__c +' orden de compra '+newOrder.Orden_de_compra__c);
					// System.debug('pedido copia '+newOrder);

					System.debug('newOrder');
					System.debug(newOrder);
					Database.SaveResult orderInsertResult = Database.insert(newOrder, true);
					
					if (orderInsertResult.isSuccess()) {
						for (OrderItem itemToClone : orderItemsToInsert) {
							System.debug('itemToClone.Id');
							System.debug(itemToClone.Id);
							Decimal precio = mapProductIDListPrice.get(itemToClone.Product2Id);
							System.debug('precio entry');
							System.debug(precio);
							OrderItem clonedItem = itemToClone.clone(false, true);
							clonedItem.OrderId = newOrder.Id;
							clonedItem.ListPrice = precio;
							duplicatedItems.add(clonedItem);
							System.debug('clonedItem');
							System.debug(clonedItem);
						}

						List<Database.SaveResult> orderProductInsertResults = Database.insert(duplicatedItems, true);
						for (Database.SaveResult result : orderProductInsertResults) {
							if (!result.isSuccess()) {
								response = new ServerResponse('ERROR', null, 'Ocurrió un error al registrar productos para la orden.' + result.getErrors()[0].getMessage());
							}
						}

						response = new ServerResponse('SUCCESS', newOrder.Id, 'La orden fue duplicada con éxito.');
					}
				} else {
					response = new ServerResponse('ERROR', null, 'La orden original debe contener al menos un producto.');
				}
			} else {
				response = new ServerResponse('ERROR', null, 'OrderId original no encontrado.');
			}
		} catch (Exception ex) {
			response = new ServerResponse('ERROR', null, ex.getMessage() + '.');
		}

		return response;
	}

	@AuraEnabled
	public static ServerResponse GetRetainedOrders() {
		TreeGrid grid = new TreeGrid();
		Danone360Helper helper = new Danone360Helper('Order');
		GridColumn.TypeAttributes typeAttributes = new GridColumn.TypeAttributes();
		GridColumn.Label label = new GridColumn.Label();

		label.fieldName = 'OrderNumber';
		typeAttributes.label = label;
		typeAttributes.target = '_parent';

		grid.GridColumns = new List<GridColumn>();
		// grid.GridColumns.add(helper.getColumn('OrderNumber'));
		grid.GridColumns.add(new GridColumn('url', 'OrderNumberLink', 'Número de pedido', 350,  typeAttributes));
		grid.GridColumns.add(helper.getColumn('AccountId'));
		grid.GridColumns.add(helper.getColumn('EffectiveDate', 'date-local', true, typeAttributes));
		grid.GridColumns.add(helper.getColumn('TotalAmount', 'currency', true));
		//grid.GridColumns.add(helper.getColumn('Dan360_UnidadNegocio__c'));
		grid.GridColumns.add(helper.getColumn('Status'));
		grid.GridColumns.add(helper.getColumn('Orden_de_compra__c'));
		grid.GridColumns.add(helper.getColumn('Dan360_Semaforo__c'));

		grid.GridData = [
			SELECT  Id,
					OrderNumber,
					Account.Name,
					//Dan360_UnidadNegocio__c,
					EffectiveDate,
					TotalAmount,
					Status,
					Orden_de_compra__c,
					Dan360_Semaforo__C
			FROM    Order
			WHERE   Status = 'Retenido por cuota'
			AND  Dan360_SemaforoPicklist__c != 'Rojo' 
			ORDER BY CreatedDate DESC
		];

		return new ServerResponse('SUCCESS', grid, '');
	}

	@AuraEnabled
	public static ServerResponse Confirm(List<Order> orders) {
		System.debug(orders);
		Map<Id, Order> ordersToConfirm;
		ServerResponse response = new ServerResponse();
		Danone360Helper helper = new Danone360Helper('Order');
		TreeGrid treeGrid = new TreeGrid();
		GridColumn.TypeAttributes typeAttributes = new GridColumn.TypeAttributes();
		GridColumn.Label label = new GridColumn.Label();
		boolean success = true;
		Integer i = 0;

		label.fieldName = 'OrderNumber';
		typeAttributes.label = label;
		typeAttributes.target = '_parent';
		treeGrid.GridColumns = new List<GridColumn>();
		treeGrid.GridColumns.add(new GridColumn('url', 'OrderNumberLink', 'Número de pedido', 350,  typeAttributes));
		treeGrid.GridColumns.add(helper.getColumn('AccountId'));
		treeGrid.GridColumns.add(helper.getColumn('Dan360_UnidadNegocio__c'));
		treeGrid.GridColumns.add(helper.getColumn('Status'));
		treeGrid.GridColumns.add(helper.getColumn('Dan360_Semaforo__c'));
		treeGrid.GridColumns.add(new GridColumn('text', 'Result', 'Resultado', 350));

		ordersToConfirm = new Map<Id, Order>([
			SELECT  Id,
					Status
			FROM    Order
			WHERE   Id IN :orders
		]);

		for (Id orderId : ordersToConfirm.keySet()) {
			ordersToConfirm.get(orderId).Status = 'Confirmado';
		}

		// List<Database.SaveResult> saveResult =  Database.Update(ordersToConfirm.values(), false);

		// for (Database.SaveResult result : saveResult) {
		// 	if (!result.isSuccess()) {
		// 		success = false;
		// 		for (Database.Error error : result.getErrors()) {
		// 			response.addError(ordersToConfirm.values().get(i).Id, error.getMessage());
		// 		}
		// 	} else {
		// 		response.addError(result.getId(), 'Orden confirmada.');
		// 	}
		// 	i++;
		// }

		treeGrid.GridData = [
			SELECT  Id,
					OrderNumber,
					Account.Name,
					Dan360_UnidadNegocio__c,
					Status,
					Dan360_Semaforo__C
			FROM    Order
			WHERE   Id IN :ordersToConfirm.keySet()
		];

		response.state = success ? 'SUCCESS' : 'ERROR';
		response.data = treeGrid;
		response.message = success ? 'Órdenes confirmadas exitósamente' : 'No fue posible actualizar los registros seleccionados.';

		return response;
	}
	
	@AuraEnabled
	public static List<String> getObjectsFields(String recordTypeName){
		List<String> ventaDirecta = getFieldsApiName('Order-Pedido de Venta Directa');
		List<String> pedidoSinCargo = getFieldsApiName('Order-Pedido sin Cargo');

		//System.debug(recordTypeName);
		//System.debug(pedidoSinCargo);
		//System.debug(ventaDirecta);
		if (recordTypeName == '"Dan360_PedidoSinCargo"') {
			return pedidoSinCargo;
		}else {
			return ventaDirecta;
		}
	}

	@AuraEnabled
	public static List<String> getFieldsApiName(String layout){
		List<String> orderFields = new List<String>();
		List<Metadata.Metadata> layouts = Metadata.Operations.retrieve(Metadata.MetadataType.Layout, new List<String> {layout});

		Metadata.Layout layoutMd = (Metadata.Layout) layouts.get(0);

		for (Metadata.LayoutSection section : layoutMd.layoutSections) {
			for (Metadata.LayoutColumn column : section.layoutColumns) {
				if (column.layoutItems != null) {
					for (Metadata.LayoutItem item : column.layoutItems) {
						if (item.field != 'Dan360_Id_SAP__c') {
							orderFields.add(item.field);
						}
					}
				}
			}
		}
		return orderFields;
	}

	@AuraEnabled
	public static Boolean hasAccess(String recordId){
		String accountOrder = [SELECT AccountId FROM Order WHERE Id = :recordId].AccountId;
		String accountName = [SELECT Account.Name FROM Order WHERE Id = :recordId].Account.Name;
		System.debug(accountName);
		System.debug(accountOrder);
		String idUsuario = UserInfo.getUserId();
		String userName = [SELECT User.Name FROM User WHERE Id = :idUsuario].Name;
		System.debug(userName);
		System.debug(idUsuario);
		List<UserRecordAccess> recordAccess = [SELECT RecordId , HasEditAccess from UserRecordAccess where UserId = :idUsuario AND RecordId = :recordId];
		System.debug(recordAccess);

		if(recordAccess.size() >0){
			if(recordAccess[0].HasEditAccess == true){
				return true;
			} else {
				return false;
			}
		} else {
			return false;
		}
	}
	/*public class OrderFieldsClass{
		@AuraEnabled
		public List<String> ventaDirecta {get;set;}
		@AuraEnabled
		public List<String> pedidoSinCargo {get;set;}

		public OrderFieldsClass(List<String> ventaDirectaP,List<String> pedidoSinCargoP){
			this.ventaDirecta = ventaDirectaP;
			this.pedidoSinCargo = pedidoSinCargoP;
		}
	}*/
}