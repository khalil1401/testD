trigger PedidoTrigger on Order (before insert, before update) {
    if(Trigger.isBefore) {
        if(Trigger.isInsert) {
            Map<Id, Order> accountsOrder = New Map<Id, Order>();
            
            for(Order order : Trigger.New){
                accountsOrder.put(order.AccountId, order);
            }
            
            List<Account> cuentas = [ 
                SELECT Id, Lista_de_precios__c 
                FROM Account
                WHERE Id IN :accountsOrder.keySet() 
            ];
            
            Order pedido;
            For( Account cuenta: cuentas ){
                
                pedido = accountsOrder.get(cuenta.Id);
                pedido.Pricebook2Id = cuenta.Lista_de_precios__c;
                
            }
            
            PedidoTriggerHelper.ValidarNumeroCompra(Trigger.New);
        }
        else if (Trigger.isUpdate) {
            List<Order> ordersToValidate = new List<Order>();
            for(Order order : Trigger.new){
                Order dbOrder = Trigger.oldMap.get(order.Id);
                
                if(!order.Orden_de_compra__c.equalsIgnoreCase(dbOrder.Orden_de_compra__c)){
                    ordersToValidate.add(order);
                }
            }
            
            if(ordersToValidate.size() > 0) {
                PedidoTriggerHelper.ValidarNumeroCompra(ordersToValidate);
            }
        }
    }
}