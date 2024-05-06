trigger EfectividadTrigger on Dan360_Efectividad__c (before insert, before update) {

    if (Trigger.isBefore) {
        if (Trigger.isInsert) { 
            EfectividadTriggerHelper.insertEfectividad(Trigger.new);
        }

        if (Trigger.isUpdate) {
            EfectividadTriggerHelper.calculateFields(Trigger.new);
        }
    }

}