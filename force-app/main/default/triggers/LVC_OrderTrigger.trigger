trigger LVC_OrderTrigger on LVC_Order__c (after update) {
    if(Trigger.isAfter && Trigger.isUpdate){
        LVC_OrderTriggerHandler.updateStockCapacity();
    }
}