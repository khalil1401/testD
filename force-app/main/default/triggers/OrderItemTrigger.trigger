trigger OrderItemTrigger on OrderItem (after update,before update, before insert, after insert) {
    if (Trigger.isBefore) {
        if (Trigger.isUpdate) {
            List<OrderItem> orderItemsList = new List<OrderItem>();
            Map<String, String> mapOrderStatus = new Map<String, String>();
            OrderItem orderItemsOld;
            String orderStatus;

            for (Order anOrder : [SELECT Id,Status FROM Order]) {
                if (!mapOrderStatus.containsKey(anOrder.Id)) {
                    mapOrderStatus.put(anOrder.Id, anOrder.Status);
                }
            }

            for (OrderItem orderItem : Trigger.new) {
                orderItemsOld = Trigger.oldMap.get(orderItem.Id);
                orderStatus = mapOrderStatus.get(orderItem.OrderId);

                if (orderItem.Quantity != orderItemsOld.Quantity && 
                    orderItem.Dan360_UnidadMedida__c == 'Trade Unit' &&
                    orderStatus == 'Borrador') {
                    orderItemsList.add(orderItem);
                }
            }

            if (!orderItemsList.isEmpty()) {
                OrderItemTriggerHandler.quantityRounding(orderItemsList);
            }
            for(OrderItem orderIten : Trigger.new){
                System.debug('orderIten.UnitPrice Antes');
                System.debug(orderIten.UnitPrice);
                String decimalString = '00';
                String priceString = String.valueOf(orderIten.UnitPrice);
                List<String> listString = priceString.split('\\.');
                if(listString[1] != '0'){
                    decimalString = listString[1].substring(0,2);
                }
                String fullUnitPriceString =  listString[0]+'.'+decimalString;
                Decimal fullUnitPrice = Decimal.valueOf(fullUnitPriceString);
                orderIten.UnitPrice = fullUnitPrice;
                System.debug(fullUnitPrice);
                System.debug('orderIten.UnitPrice');
                System.debug(orderIten.UnitPrice);
            }
        }
        
        if (Trigger.isInsert) {
            for(OrderItem orderIten : Trigger.new){
                orderIten.UnitPrice = orderIten.UnitPrice.setscale(2);
            }
        }
        
    }

    if(Trigger.isAfter){
        if(Trigger.isInsert) {
            Set<String> orderIds = new Set<String>();
            for(OrderItem oli : Trigger.new){
                orderIds.add(oli.OrderId);
            }

            List<Order> ordenesRetenidas = new List<Order>();
            for(Order orden : [SELECT Id, Status FROM Order WHERE ID IN : orderIds AND Status = 'Retenido por cuota']){
                ordenesRetenidas.add(orden);
            }
            if(ordenesRetenidas.size() > 0){
                OrderTriggerHandler.validateQuotaLimit(ordenesRetenidas);
            }
            
        }
    }
}