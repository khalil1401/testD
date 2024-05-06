public with sharing class OrderPriceToConfirm {
    @InvocableMethod(label='Check if the price of products is changed' description='Check if the price of products is changed')
    public static List<FlowOutputs> OrderPriceToConfirm(List<List<OrderItem>> orderItems) {       
        List<String> pbeIdsList = new List<String>();
        Map<String, OrderItem> mapPbeOrderItem = new Map<String, OrderItem>();
       
        for(OrderItem orderIten : orderItems[0]){
            pbeIdsList.add(orderIten.PricebookEntryId);
            if(!mapPbeOrderItem.containsKey(orderIten.PricebookEntryId)){
                mapPbeOrderItem.put(orderIten.PricebookEntryId, orderIten);
            }
        }                     
        List<List<FlowOutputs>> returnDetails = new List<List<FlowOutputs>>();
        List<FlowOutputs> outputList = new List<FlowOutputs>();
        String prices = '';
        List<OrderItem> ordreItems = new List<OrderItem>();
        List<OrderItem> ordreItemsUpdates = new List<OrderItem>();

        for(PricebookEntry priceBookEntry :  [SELECT Id, UnitPriceWithDiscount__c, UnitPrice,Product2.Name, Dan360_Descuento__c,UnitPriceWithDiscountS__c FROM PricebookEntry WHERE Id IN :pbeIdsList AND isActive = true]){            
            if(mapPbeOrderItem.containsKey(priceBookEntry.Id)){
                OrderItem aOrderItem = mapPbeOrderItem.get(priceBookEntry.Id);
                Decimal decimalTest = Decimal.valueOf(pricebookentry.UnitPriceWithDiscountS__c);
                System.debug('decimalTest');
                System.debug(decimalTest);

                String decimalString1 = '00';
                List<String> listString1 = pricebookentry.UnitPriceWithDiscountS__c.split('\\.');
                
                if(listString1.size() > 1){
                    if(listString1[1].length() == 1){
                        decimalString1 = listString1[1]+'0';
                    }else{
                        decimalString1 = listString1[1].substring(0,2);
                    }
                }
                
                String fullUnitPriceString1 =  listString1[0]+'.'+decimalString1;
                Decimal fullUnitPrice1 = Decimal.valueOf(fullUnitPriceString1);
                System.debug('decimalTest Converted');
                System.debug(fullUnitPrice1);
                System.debug('aOrderItem.UnitPrice');
                System.debug(aOrderItem.UnitPrice);
                if (fullUnitPrice1 != aOrderItem.UnitPrice) {
                    
                    OrderItem orderItemToUpdate = new OrderItem(
                        UnitPrice = fullUnitPrice1,
                        Dan360_Descuento__c = pricebookentry.Dan360_Descuento__c,
                        Dan360_UnidadMedida__c = aOrderItem.Dan360_UnidadMedida__c,
                        OrderId = aOrderItem.OrderId,
                        PricebookEntryId = aOrderItem.PricebookEntryId,
                        Product2Id = aOrderItem.Product2Id,
                        Quantity = aOrderItem.Quantity
                    );
                    System.debug('orderItemToUpdate');
                    System.debug(orderItemToUpdate);
                    ordreItemsUpdates.add(orderItemToUpdate);
                    ordreItems.add(aOrderItem);
                    prices += 'Producto: '+ priceBookEntry.Product2.Name +', Precio anterior: '+ String.valueOf(aOrderItem.UnitPrice) + ', Precio actual: ' + String.valueOf(fullUnitPrice1) + '\n';
                                                        
                }  
            }          
        }
        FlowOutputs output = new FlowOutputs();
        output.oldPrice = prices;
        output.orderItem = ordreItems;
        output.orderItemUpdate = ordreItemsUpdates;
        outputList.add(output);
        returnDetails.add(outputList);        
        return outputList;
    }
     
    public class FlowOutputs {
        @InvocableVariable
        public String oldPrice;        
        @InvocableVariable
        public List<OrderItem> orderItem;
        @InvocableVariable
        public List<OrderItem> orderItemUpdate;

    }
}