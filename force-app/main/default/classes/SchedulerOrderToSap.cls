global class SchedulerOrderToSap implements Schedulable {
    
    global void execute(SchedulableContext sc) {
        String typeObj = 'Order';
        Map<String,Order> orderMap = new Map<String,Order>();
        DateTime timeToUse = datetime.newInstance(2022, 1, 9); // Borrar para produccion.

        for(Order pedido : [
            SELECT id, Orden_de_compra__c,OrderNumber, Dan360_UnidadNegocio__c, RecordType.Name ,
            EndDate, EffectiveDate, Dan360_FechaInicioCarrito__c, Dan360_FechaCierreCarrito__c,
            AccountId, Description, Status, Dan360_CustomerSalesArea__c, Dan360_OrderReason__c
            FROM Order
            WHERE Status = 'Confirmado'
            AND LastModifiedDate >= :timeToUse])
            {
                if(!orderMap.containsKey(pedido.Id)){
                    orderMap.put(pedido.Id, pedido);
                }
            }
        
        for(String key : orderMap.keySet()){
            Order orderToShow = orderMap.get(key);
            System.debug('Numero de orden: ' + orderToShow.OrderNumber);
        }

        if(orderMap.size() > 0) {
            try {
                BatchSendOrdersToSap orderBatch = new BatchSendOrdersToSap(orderMap,typeObj);
                ID batchId = Database.executeBatch(orderBatch, 10);
            } catch (Exception e) {
                System.debug('Error al encolar el batch: ' + e.getMessage());
            }
        }
    }
}