trigger LVC_ProductStockDateTrigger on LVC_ProductStockDate__c (after insert, after update) {

    if(!CheckTriggerRecursive.firstcall) {
        CheckTriggerRecursive.firstcall = true;
        if(Trigger.isAfter){
            if(Trigger.isInsert || Trigger.isUpdate){
                LVC_ProductStockDateTriggerHandler.completeStockExternalId();
            }
        }
    }

}