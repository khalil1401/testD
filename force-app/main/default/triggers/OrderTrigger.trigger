/**
 * @author            : Diego Valle
 * @created date      : 08-09-2021
 * @last modified by  : Luis Hurtado
 * @last modified on  : 22-03-2024
 * @description       : Events over Order object.
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   03-09-2021   Diego Valle   Initial Version
 * 2.0   22-03-2024   Luis Hurtado  Ajustas para dejarla igual que Prod
**/

trigger OrderTrigger on Order(after update, before update, after insert) {
	if (Trigger.isBefore) {
		if (Trigger.isUpdate) {
			List<Order> ordersToConfirm = new List<Order>();
			Order orderOld;

			for (Order order : Trigger.new) {
				System.debug('order.Pricebook2Id');
				System.debug(order.Pricebook2Id);
				orderOld = Trigger.oldMap.get(order.Id);

				if (order.Status == 'Confirmado' && orderOld.Status != 'Confirmado') {
					ordersToConfirm.add(order);
				}

				if(order.Status == 'Confirmado' && orderOld.Status == 'Error'){
					order.EndDate = Date.today();
				}
			}

			if (ordersToConfirm.size() > 0) {
				System.debug('testtrigger');
				if (FeatureManager.isFeatureTurnedOn('Dan360_Order_Purchase_Order_Validation')) {
					System.debug('testtrigger1');
					OrderTriggerHandler.validatePurchaseOrdersToConfirmByDateTodayAndAccount(ordersToConfirm);
				}

				if (FeatureManager.isFeatureTurnedOn('Dan360_Order_Items_Prices_Validation')) {
					System.debug('testtrigger2');
					OrderTriggerHandler.validateAndDeletePricesIntoOrderItems(ordersToConfirm);
				}

				if (FeatureManager.isFeatureTurnedOn('Dan360_Order_Quota_Limit_Validation')) {
					System.debug('testtrigger3');
					OrderTriggerHandler.validateQuotaLimit(ordersToConfirm);
				}
			}
		}
		
	}

	if (Trigger.isAfter){
		if (Trigger.isUpdate) {
			List<Order> ordersToConfirm = new List<Order>();
			Order orderOld;

			for (Order order : Trigger.new) {
				System.debug('order.Pricebook2Id');
				System.debug(order.Pricebook2Id);
				orderOld = Trigger.oldMap.get(order.Id);
				if (order.Status == 'Confirmado' && orderOld.Status != 'Confirmado') {
					ordersToConfirm.add(order);
				}
			}

			if (ordersToConfirm.size() > 0) {
				if (FeatureManager.isFeatureTurnedOn('Dan360_Items_Prices_Update_Validation')) {
					System.debug('Items_Prices_Update_Validation');
					OrderTriggerHandler.validateAndUpdatePricesIntoOrderItems(ordersToConfirm);
				}

				if (FeatureManager.isFeatureTurnedOn('Dan360_Order_Quota_Limit_Validation')) {
					System.debug('Order_Quota_Limit_Validation');
					OrderTriggerHandler.validateQuotaLimit(ordersToConfirm);
				}
			}
			/* Descomentar este bloque  ya que estaba sin comentar en UAt , se comento el 20 de febrero de 2024 para hacer pruebas UAT
			List<String> ordersToSendSap = new List<String>();
            List<String> ordersIds = new List<String>();
            for(Order aOrder : Trigger.new){
                if(aOrder.Dan360_Registro_aprobado__c == true && Trigger.oldMap.get(aOrder.Id).Dan360_Registro_aprobado__c == false){
                    ordersIds.add(aOrder.id);
                }
            }
            for(ProcessInstance instance : [SELECT Id, TargetObjectId FROM ProcessInstance WHERE TargetObjectId IN :ordersIds AND Status = 'Approved']){
                ordersToSendSap.add(instance.TargetObjectId);
            }
            if(!ordersToSendSap.isEmpty()){
				System.debug('Trigger order');
                //sendOrderToSapController.sendOrderSinCargoToSap(ordersToSendSap);
                OrderTriggerHandler.updateOrderFields(ordersToSendSap);
            }*/
		}
		if(Trigger.isInsert){

			List<String> orderSinCargo = new List<String>();
			for(Order pedido : Trigger.new){
				System.debug('pedido.Pricebook2Id');
				System.debug(pedido.Pricebook2Id);
				orderSinCargo.add(pedido.Id);
			}
			OrderTriggerHandler.pricebookAndProductTemplateAssign(orderSinCargo);
		}
	}
	
}