trigger AccionTrigger on VisMed_Accion__c (before insert, before update, after insert, after update, after delete) {
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            AccionTriggerHelper.calcularEstadoRegistro(Trigger.new);
            List<VisMed_Accion__c> accionesParaActivarODesactivar = new List<VisMed_Accion__c>();
            for (VisMed_Accion__c accion : Trigger.new) {
                if (accion.VisMed_FechaInicio__c != null && accion.VisMed_FechaFin__c != null ) {
                    accionesParaActivarODesactivar.add(accion);
                }
            }
            if (!accionesParaActivarODesactivar.isEmpty()) {
                AccionTriggerHelper.activarODesactivarAccion(accionesParaActivarODesactivar);                
            }
        }

        if (Trigger.isUpdate) {
            List<VisMed_Accion__c> accionesParaActivarODesactivar = new List<VisMed_Accion__c>();
            for (VisMed_Accion__c accion : Trigger.new) {
                if (Trigger.oldMap.get(accion.Id).VisMed_FechaInicio__c != accion.VisMed_FechaInicio__c || Trigger.oldMap.get(accion.Id).VisMed_FechaFin__c != accion.VisMed_FechaFin__c) {
                    accionesParaActivarODesactivar.add(accion);
                }
            }
            if (!accionesParaActivarODesactivar.isEmpty()) {
                AccionTriggerHelper.activarODesactivarAccion(accionesParaActivarODesactivar);                
            }
        }
    }
    
    if (Trigger.isAfter){
        if (Trigger.isUpdate){
            for (VisMed_Accion__c accion : Trigger.new) {
                if (accion.Estado__c == 'Activo') {
                    AccionTriggerHelper.activarAccionPorCuenta(Trigger.new);
                } else if (accion.Estado__c == 'Inactivo'){
                    AccionTriggerHelper.desactivarAccionPorCuenta(Trigger.new);
                }
            }
        }

        if(Trigger.isInsert){
            AccionTriggerHelper.createAccionPorCuenta(Trigger.new);
        }
    }    
}