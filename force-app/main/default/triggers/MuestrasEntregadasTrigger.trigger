trigger MuestrasEntregadasTrigger on Muestras_Entregadas__c (before insert) {
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            MuestrasEntregadasTriggerHelper.checkDuplicates(Trigger.new);
        }
    }
}