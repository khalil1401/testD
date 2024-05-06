public with sharing class ProductPerTemplateTriggerHandler {
	public static void removeInactiveProductsFromOrders(Map<Id, List<Dan360_ProductoPorPlantilla__c>> productsPerTemplate) {
		List<OrderItem> orderItemsToDelete = new List<OrderItem>();
		List<OrderItem> orderItemsToCheck = [
			SELECT  Id,
					Product2Id,
					Order.Dan360_PlantillaProductos__c
			FROM    OrderItem
			WHERE   Order.Status = 'Borrador'
				AND Order.Dan360_PlantillaProductos__c IN :productsPerTemplate.keySet()
		];
		System.debug('orderItemsToCheck');
		System.debug(orderItemsToCheck);
		for (OrderItem orderItem : orderItemsToCheck) {
			System.debug('productsPerTemplate');
			System.debug(productsPerTemplate);
			System.debug('orderItem.Order.Dan360_PlantillaProductos__c');
			System.debug(orderItem.Order.Dan360_PlantillaProductos__c);
			if (productsPerTemplate.containsKey(orderItem.Order.Dan360_PlantillaProductos__c)) {
				for (Dan360_ProductoPorPlantilla__c productPerTemplate : productsPerTemplate.get(orderItem.Order.Dan360_PlantillaProductos__c)) {
					if (productPerTemplate.Dan360_Producto__c == orderItem.Product2Id) {
						orderItemsToDelete.add(orderItem);
					}
				}
			}
		}

		delete orderItemsToDelete;
	}
}