trigger ProductPerTemplateTrigger on Dan360_ProductoPorPlantilla__c (before insert, after insert, after update, before update) {
	if (Trigger.isAfter) {
		if (Trigger.isUpdate) {
			Map<Id, List<Dan360_ProductoPorPlantilla__c>> productsPerTemplate = new Map<Id, List<Dan360_ProductoPorPlantilla__c>>();
			Dan360_ProductoPorPlantilla__c productPerTemplateOld;

			for (Dan360_ProductoPorPlantilla__c productPerTemplate : Trigger.new) {
				productPerTemplateOld = Trigger.oldMap.get(productPerTemplate.Id);

				if (productPerTemplate.Dan360_Activo__c == false && productPerTemplateOld.Dan360_Activo__c != productPerTemplate.Dan360_Activo__c ) {
					if (!productsPerTemplate.containsKey(productPerTemplate.Dan360_PlantillaProductos__c)) {
						productsPerTemplate.put(productPerTemplate.Dan360_PlantillaProductos__c, new List<Dan360_ProductoPorPlantilla__c>());
					}

					productsPerTemplate.get(productPerTemplate.Dan360_PlantillaProductos__c).add(productPerTemplate);
				}
			}
			System.debug('productsPerTemplate');
			System.debug(productsPerTemplate.keyset());
			if (productsPerTemplate != null && !productsPerTemplate.isEmpty()) {
				if (FeatureManager.isFeatureTurnedOn('Dan360_InactiveProductTemplateValidation')) {
					ProductPerTemplateTriggerHandler.removeInactiveProductsFromOrders(productsPerTemplate);
				}
			}
		}
	}
}