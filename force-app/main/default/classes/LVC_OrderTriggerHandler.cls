public with sharing class LVC_OrderTriggerHandler {
    public static void updateStockCapacity() {
        List<LVC_Order__c> modifiedOrders = Trigger.new;
        
        Set<Id> orderIds = new Set<Id>();
        for(LVC_Order__c ord : modifiedOrders){
            if(ord.Status__c == '2'){
                orderIds.add(ord.Id);
            }
        }
        List<LVC_OrderProduct__c> orderProducts = [SELECT Id, Quantity__c FROM LVC_OrderProduct__c WHERE Order__c =: orderIds];

        List<LVC_OrderProduct__c> opToModify = new List<LVC_OrderProduct__c>();
        if(orderProducts.size() > 0){
            for(LVC_OrderProduct__c op : orderProducts){
                op.Quantity__c = 0;
                opToModify.add(op);
            }
        }
        
        if(opToModify.size() > 0){
            update opToModify;
        }
    }
}