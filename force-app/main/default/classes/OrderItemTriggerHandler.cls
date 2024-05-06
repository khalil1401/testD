public class OrderItemTriggerHandler {
    public static void quantityRounding(List<OrderItem> orderItems){
        Map<String, Decimal> mapProductUnidadPorButo = new Map<String, Decimal>();
        Integer dif;
        for (Product2 product : [SELECT Id, Dan360_UnidadesPorBulto__c FROM Product2]) {
            if (!mapProductUnidadPorButo.containsKey(product.Id)) {
                mapProductUnidadPorButo.put(product.Id, product.Dan360_UnidadesPorBulto__c);
            }
        }
        for (OrderItem orderItem : orderItems) {         
            Integer quantity = Integer.valueOf(orderItem.Quantity);
            Integer unidadesPorBulto = Integer.valueOf(mapProductUnidadPorButo.get(orderItem.Product2Id));

            if (Math.mod(quantity, unidadesPorBulto) != 0) {
                dif = Math.mod(quantity, unidadesPorBulto);
                dif = unidadesPorBulto - dif;
                orderItem.Quantity = quantity + dif;
            }else{
                orderItem.Quantity = quantity;
            }
            
        }
    }
}