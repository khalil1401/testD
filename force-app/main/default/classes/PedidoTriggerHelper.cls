public class PedidoTriggerHelper {
    public static void ValidarNumeroCompra(List<Order> triggerOrders){
        Map<String, Order> orderByNumber = new Map<String, Order>();
        
        for(Order newOrder : triggerOrders){
            if(orderByNumber.containsKey(newOrder.Orden_de_compra__c)){
                newOrder.addError('Ya existe una orden con la misma orden de compra y fecha de creacion');
            }
            else {
                orderByNumber.put(newOrder.Orden_de_compra__c, newOrder);
            }
        }
        
        List<Order> dbOrders = [
            SELECT Id, Orden_de_compra__c, CreatedDate, AccountId
            FROM Order 
            WHERE Orden_de_compra__c IN: orderByNumber.keySet()
        ];
        
        if(dbOrders.isEmpty()){
            return;
        }
        for(Order dbOrder : dbOrders){
            if(orderByNumber.containsKey(dbOrder.Orden_de_compra__c)){
                Order newOrder = orderByNumber.get(dbOrder.Orden_de_compra__c);
                if(
                    newOrder.Id == null
                    || newOrder.Id != dbOrder.Id
                ){
                    if(
                        (newOrder.CreatedDate == null
                         	&& dbOrder.CreatedDate.date() == Date.Today() 
                         	&& newOrder.AccountId == dbOrder.AccountId)
                        || (newOrder.CreatedDate != null 
                            && newOrder.CreatedDate.date() == dbOrder.CreatedDate.date() 
                            && newOrder.AccountId == dbOrder.AccountId)
                    ){
                        newOrder.addError('Ya existe una orden con la misma orden de compra y fecha de creacion');
                    }
                }
            }
        }
    }
}