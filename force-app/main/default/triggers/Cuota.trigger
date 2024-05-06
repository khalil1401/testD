trigger Cuota on Dan360_Cuota__c (before insert ,after insert, after update, before update) {
	if (Trigger.isAfter) {
		if (Trigger.isUpdate) {
			List<Dan360_Cuota__c> dues = new List<Dan360_Cuota__c>();

			for (Dan360_Cuota__c quota : Trigger.new) {
				Dan360_Cuota__c quotaOld = Trigger.oldMap.get(quota.Id);

				if (quota.Dan360_Saldo__c != quotaOld.Dan360_Saldo__c) {
					dues.add(quota);
				}
			}

			if (dues != null && !dues.isEmpty()) {
				if (FeatureManager.isFeatureTurnedOn('Dan360_Traffic_Light_Validation')) {
					CuotaTriggerHelper.validateTrafficLightInOrders(dues);
				}
			}
		}
	}

	if (Trigger.isBefore) {
		if (Trigger.isInsert) {
			if (FeatureManager.isFeatureTurnedOn('Dan360_Cuota_Duplicated_Cuotas')) {
				CuotaTriggerHelper.processDuplicatedLogic(Trigger.new);
			}
		} else if (Trigger.isUpdate) {
		}
	}
}