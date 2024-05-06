trigger LugarDeTrabajoTrigger on Dan360_Lugar_de_Trabajo__c (before insert, before update) {
    if(Trigger.isBefore) {
        if(Trigger.isInsert) {
            LugarDeTrabajoTriggerHelper.duplacateCheck(Trigger.new);
            LugarDeTrabajoTriggerHelper.updateInstitucionTopOnProfessionals(Trigger.new);
        }

        if(Trigger.isUpdate) {

        }
    }
}