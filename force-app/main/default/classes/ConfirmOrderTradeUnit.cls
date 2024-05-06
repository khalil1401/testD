public with sharing class ConfirmOrderTradeUnit {
    
    @InvocableMethod(label='Check Cuotas in Trade Unit products' description='Check if Cuotas are enough')
    public static List<FlowOutputs> checkCuotasTradeUnit(List<List<OrderItem>> orderItems) {
        String orderId;
        String newOrderNumber = '';
        Boolean updateSameOrder = false;
        List<OrderItem> orderItemToCreate = new List<OrderItem>();
        List<String> productsWithTradeUnit = new List<String>();
        Map<String, Decimal> mapProductBulto = new Map<String, Decimal>();
        Map<String, Decimal> mapProductCuota = new Map<String, Decimal>();
        for(OrderItem orderIten : orderItems[0]){
            if(orderIten.Dan360_UnidadMedida__c == 'Trade Unit'){
                productsWithTradeUnit.add(orderIten.Product2Id);
                orderId = orderIten.OrderId;
            }
        }
        System.debug('productsWithTradeUnit');
        System.debug(productsWithTradeUnit);
        
        if(productsWithTradeUnit.size()> 0){
            String idAccount = [SELECT Id, AccountId FROM Order Where Id = :orderId].AccountId;
            List<Account> getAccountdetails = [SELECT Id, Dan360_SalesDistric1__c FROM Account WHERE Id = :idAccount];

            for(Product2 product : [SELECT id, Dan360_UnidadesPorBulto__c FROM Product2 WHERE Id IN :productsWithTradeUnit]){
                if(!mapProductBulto.containsKey(product.Id)){
                    mapProductBulto.put(product.Id, product.Dan360_UnidadesPorBulto__c);
                }
            }

            
            Date fechaActual = System.today();
            List<String> accountSalesDistricts = String.valueOf(getAccountdetails[0].Dan360_SalesDistric1__c).split(';');
            
            // System.debug('Contenido  > productsWithTradeUnit: ' + JSON.serialize(productsWithTradeUnit) );
            // System.debug('Contenido  > accountSalesDistricts: ' + JSON.serialize(accountSalesDistricts) );


            for(Dan360_Cuota__c cuota : [SELECT Id, Dan360_Producto__c, Dan360_Saldo__c FROM Dan360_Cuota__c 
            WHERE Dan360_Producto__c IN :productsWithTradeUnit 
            AND Dan360_EstadoCuota__c = 'Activa'
            AND Dan360_VigenciaDesde__c < = :fechaActual
            AND Dan360_VigenciaHasta__c > = :fechaActual
            AND Dan360_CanalComercial__c IN :accountSalesDistricts  
            ]){
                System.debug('cuota');
                System.debug('Banderilla cuotas >> '+ JSON.serialize(cuota));
                if(!mapProductCuota.containsKey(cuota.Dan360_Producto__c)){
                    mapProductCuota.put(cuota.Dan360_Producto__c, cuota.Dan360_Saldo__c);
                }
            }

            List<String> productsToCreateOrder = new List<String>();

            for(String product : mapProductBulto.keySet()){
                if(mapProductCuota.containsKey(product)){
                    if(mapProductBulto.get(product) > mapProductCuota.get(product)){
                        productsToCreateOrder.add(product);
                    }
                }
            }
            
            for(OrderItem orderIten : orderItems[0]){
                if(productsToCreateOrder.contains(orderIten.Product2Id)){
                    orderItemToCreate.add(orderIten);
                }
            }

            System.debug('orderItemToCreate');
            System.debug(orderItemToCreate);
            System.debug('orderItems[0]');
            System.debug(orderItems[0]);
            if(orderItemToCreate.size()>0){
                if(orderItemToCreate.size() != orderItems[0].size()){
                    String queryFields = DuplicateOrderExtension.getAllApiNameFields('Order');
                    String query = 'select '+queryFields+' from Order where Id=\''+orderId+'\'';
                    Order orderToClone = Database.query(query);
                    
                    Order clonedOrder = orderToClone.clone(false, true, false, false);
                    clonedOrder.Dan360_PedidoPrincipal__c = orderToClone.Id;
                    clonedOrder.Status = 'Retenido por cuota';
                    clonedOrder.Dan360_SemaforoPicklist__c = 'Rojo';
                    clonedOrder.Dan360_Id_Externo__c = null;
                    Database.insert(clonedOrder);

                    List<OrderItem> listOrderItemInsert = new List<OrderItem>();
                    for(OrderItem orderItemToClone : orderItemToCreate){
                        OrderItem orderItemCloned = orderItemToClone.clone(false, true, false, false);
                        /* if(Test.isRunningTest()){
                            OrderItem orderItemTest = [SELECT PricebookEntryId FROM OrderItem WHERE Id = :orderItemToClone.Id];
                            orderItemCloned.PricebookEntryId = orderItemTest.PricebookEntryId;
                        } */
                        //orderItemToClone.clone(false,true);
                        orderItemCloned.OrderId = clonedOrder.id;
                        System.debug('orderItemCloned.PricebookEntryId');
                        System.debug(orderItemCloned);
                        listOrderItemInsert.add(orderItemCloned);
                        //Database.insert(orderItemCloned);
                    }
                    insert listOrderItemInsert;
                    newOrderNumber = [SELECT Id, OrderNumber FROM Order WHERE Id = :clonedOrder.Id].OrderNumber;
                    System.debug('newOrder.OrderNumber');
                    System.debug(newOrderNumber);
                } else {
                    updateSameOrder = true;
                }
            }
            System.debug('orderItemToCreate');
            System.debug(orderItemToCreate);
        }
        
        
        List<FlowOutputs> outputList = new List<FlowOutputs>();
        FlowOutputs output = new FlowOutputs();
        output.orderItem = orderItemToCreate;
        output.orderId = newOrderNumber;
        output.updateSameOrder = updateSameOrder;
        outputList.add(output);
        return outputList;
    }

    public class FlowOutputs {       
        @InvocableVariable
        public List<OrderItem> orderItem;
        @InvocableVariable
        public String orderId;
        @InvocableVariable
        public Boolean updateSameOrder;
    }
}