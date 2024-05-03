trigger EnvioSinCargoTrigger on Envio_sin_Cargo__c (after update,before update) {
    
    if (Trigger.isAfter) {
        if (Trigger.isUpdate) {
            Set<Id> setIdPacientes = new Set<Id>();
            Set<Id> setIdKitsCancelados = new Set<Id>();

            for (Envio_sin_Cargo__c kit : Trigger.new) {
                Envio_sin_Cargo__c oldKit = Trigger.oldMap.get(kit.Id);
                if (kit.Estado_del_envio__c == 'Reservado' &&
                    oldKit.Estado_del_envio__c == 'Ingresado' &&
                    kit.Razon_de_envio__c == 'Kit de Inicio') {
                        setIdPacientes.add(kit.Paciente__c);
                }
                if (kit.Estado_del_envio__c == 'Rechazado' &&
                    oldKit.Estado_del_envio__c == 'Ingresado' &&
                    kit.Razon_de_envio__c == 'Kit de Inicio') {
                        setIdKitsCancelados.add(kit.Id);
                }
            }
            if(!setIdPacientes.isEmpty()) {
                EnvioSinCargoTriggerHelper.revisarPacientesConUsuarios(setIdPacientes);
            }
            if(!setIdKitsCancelados.isEmpty()) {
                EnvioSinCargoTriggerHelper.cerrarCasosKitDeInicio(setIdKitsCancelados);
            }
        }
    }

    if(Trigger.isBefore && Trigger.isUpdate){
        Map<id, Envio_sin_Cargo__c> oldKits = Trigger.oldMap;
        List<Envio_sin_Cargo__c> kitsToUpdate = new List<Envio_sin_Cargo__c>();        
        for (Envio_sin_Cargo__c kit : Trigger.new) { 
             Envio_sin_Cargo__c oldKit = oldKits.get(kit.id);
            if(oldKit!=null){
                boolean changeStatus = kit.Estado_del_envio__c!= oldKit.Estado_del_envio__c;
                if( changeStatus && kit.Estado_del_envio__c =='Reservado' && !kit.Alerta_a_KAM_ya_enviada__c){
                    kitsToUpdate.add(kit);
                }
            }
        }
        if(!kitsToUpdate.isEmpty()){
            EnvioSinCargoTriggerHelper.updateFieldsToKamAlert(kitsToUpdate);
        }
    
    }
}