trigger CicloTrigger on VisMed_Ciclo__c (before insert) {

    if (Trigger.isBefore) {
        if (Trigger.isInsert){
            CicloTriggerHelper.createCiclo(Trigger.new);
        }
    }

}