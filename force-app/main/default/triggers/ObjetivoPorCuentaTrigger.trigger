trigger ObjetivoPorCuentaTrigger on VisMed_ObjetivoPorCuenta__c (after insert) {
    if(Trigger.isAfter){
        if(Trigger.isInsert){
            ObjetivoPorCuentaTriggerHelper.createAccionPorCuenta(Trigger.new);
        }
    }
}