public with sharing class OrderConfirmationFlow {
    @InvocableMethod(label='Check if products not available' description='check If Product Is Not Available')
    public static List<List<OrderItem>> checkIfProductIsNotAvailable(List<List<OrderItem>> orderItems) {
        List<List<OrderItem>> orderItemsToReturn = new List<List<OrderItem>>();
        List<String> pbeIdsList = new List<String>();
        Set<String> productList = new Set<String>();
        Map<String, OrderItem> mapPbeOrderItem = new Map<String, OrderItem>();
        String orderId ;
        for(OrderItem orderIten : orderItems[0]){
            orderId = orderIten.OrderId;
            productList.add(orderIten.Product2Id);
            pbeIdsList.add(orderIten.PricebookEntryId);
            if(!mapPbeOrderItem.containsKey(orderIten.PricebookEntryId)){
                mapPbeOrderItem.put(orderIten.PricebookEntryId, orderIten);
            }
        }

        
        Order orden = [SELECT Dan360_UnidadNegocio__c, Dan360_PlantillaProductos__c, AccountId, RecordType.Name FROM Order WHERE Id = :orderId WITH SECURITY_ENFORCED];
        
        String distributionChannel = orden.RecordType.Name == 'Pedido de Venta Directa' ? '00' : '05';

        dAN360_PlantillaporcCuenta__c plantillaCuenta = [
            SELECT Dan360_PlantillaDeProductos__c
            FROM dAN360_PlantillaporcCuenta__c
            WHERE Dan360_Cuenta__c =:orden.AccountId
                AND 
                    (Dan360_UnidadNegocio__c = :orden.Dan360_UnidadNegocio__c AND Dan360_DistributionChannel__c = :distributionChannel)
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];


        //Dan360_PlantillaDeProductos__c plantillaProductos = [SELECT Id FROM Dan360_PlantillaDeProductos__c WHERE Id = :orden.Dan360_PlantillaProductos__c WITH SECURITY_ENFORCED];
        List<Dan360_ProductoPorPlantilla__c> productosPlantilla = [ SELECT Id, Dan360_Producto__r.Name 
                                                                    FROM Dan360_ProductoPorPlantilla__c 
                                                                    WHERE Dan360_Producto__c IN : productList
                                                                        AND Dan360_Activo__c = false
                                                                        AND Dan360_PlantillaProductos__c = :plantillaCuenta.Dan360_PlantillaDeProductos__c WITH SECURITY_ENFORCED];
        List<OrderItem> orderItemList = new List<OrderItem>();
        for(PricebookEntry pbe : [SELECT Id, isActive FROM PricebookEntry WHERE Id IN :pbeIdsList AND isActive = false WITH SECURITY_ENFORCED]){
            if(mapPbeOrderItem.containsKey(pbe.Id)){
                orderItemList.add(mapPbeOrderItem.get(pbe.Id));
            }
        }
        orderItemsToReturn.add(orderItemList);
        return orderItemsToReturn;
    }
}