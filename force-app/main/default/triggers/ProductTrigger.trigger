trigger ProductTrigger on Product2 (before insert, after insert, after update, before update) {
	if (Trigger.isAfter) {
		if (Trigger.isUpdate) {
			Set<Id> productIds = new Set<Id>();
			Product2 productOld;

			for (Product2 product : Trigger.new) {
				productOld = Trigger.oldMap.get(product.Id);

				if (product.isActive == false && productOld.isActive != product.isActive ) {
					productIds.add(product.Id);
				}
			}

			if (productIds != null && !productIds.isEmpty()) {
				if (FeatureManager.isFeatureTurnedOn('Dan360_Inactive_Products_Validation')) {
					ProductTriggerHandler.removeInactiveProductsFromOrders(productIds);
				}
			}
		}
		if (Trigger.isInsert) {
			ProductTriggerHandler.createNewPriceBookEntry(Trigger.new);
		}
	}
}