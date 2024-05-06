trigger ObjetivoTrigger on VisMed_Objetivo__c (before insert, before update, after insert, after update, after delete) {
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            List<VisMed_Objetivo__c> objetivosParaActivarODesactivar = new List<VisMed_Objetivo__c>();
            for (VisMed_Objetivo__c objetivo : Trigger.new) {
                if (objetivo.VisMed_FechaInicio__c != null && objetivo.VisMed_FechaFin__c != null ) {
                    objetivosParaActivarODesactivar.add(objetivo);
                }
            }
            if (!objetivosParaActivarODesactivar.isEmpty()) {
                ObjetivoTriggerHelper.activarODesactivarObjetivo(objetivosParaActivarODesactivar);                
            }
        }

        if (Trigger.isUpdate) {
            List<VisMed_Objetivo__c> objetivosParaActivarODesactivar = new List<VisMed_Objetivo__c>();
            for (VisMed_Objetivo__c objetivo : Trigger.new) {
                if (Trigger.oldMap.get(objetivo.Id).VisMed_FechaInicio__c != objetivo.VisMed_FechaInicio__c || Trigger.oldMap.get(objetivo.Id).VisMed_FechaFin__c != objetivo.VisMed_FechaFin__c) {
                    objetivosParaActivarODesactivar.add(objetivo);
                }
            }
            if (!objetivosParaActivarODesactivar.isEmpty()) {
                ObjetivoTriggerHelper.activarODesactivarObjetivo(objetivosParaActivarODesactivar);                
            }
        }
        
    }
    if (Trigger.isAfter){
        if (Trigger.isUpdate){
            for (VisMed_Objetivo__c objetivo : Trigger.new) {
                if (objetivo.Estado__c == 'Activo') {
                    ObjetivoTriggerHelper.activarObjetivoPorCuenta(Trigger.new);
                } else if (objetivo.Estado__c == 'Inactivo'){
                    ObjetivoTriggerHelper.desactivarObjetivoPorCuenta(Trigger.new);
                }
            }
        }
    }
}