trigger LicenciaTrigger on Dan360_Licencia__c (before insert, before update, after insert, after update, after delete) {

    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            List<Dan360_Licencia__c> calcularDiasTranscurridos = new List<Dan360_Licencia__c>();
            Id recordTypeTPN = Schema.SObjectType.Dan360_Licencia__c.getRecordTypeInfosByDeveloperName().get('Tiempo_no_Promocional').getRecordTypeId();
            LicenciaTriggerHelper.validaciones(Trigger.new);
            LicenciaTriggerHelper.splitLicencias(Trigger.new);

            for(Dan360_Licencia__c licencia : Trigger.new) {
                if(licencia.RecordTypeId != recordTypeTPN){
                    calcularDiasTranscurridos.add(licencia);
                }
            }

            if(calcularDiasTranscurridos.size() > 0){
                LicenciaTriggerHelper.calculateDiasTranscurridos(calcularDiasTranscurridos);
            }
            
            LicenciaTriggerHelper.completarCampos(Trigger.New);
        }

        if(Trigger.isUpdate){
            for(Dan360_Licencia__c lincen : Trigger.new){
                if( (Trigger.oldMap.get(lincen.Id).Estado__c == 'Aprobada' && (lincen.Estado__c == 'Aprobada' || lincen.Estado__c != 'Aprobada'))){
                    lincen.addError('No se puede editar una licencia Aprobada');
                }
                /* if((lincen.Estado__c == 'Pendiente' && Trigger.oldMap.get(lincen.Id).Estado__c == 'Pendiente') && (lincen.Editable__c == Trigger.oldMap.get(lincen.Id).Editable__c) && Approval.isLocked(lincen.id)){
                    lincen.addError('En Pendiente: Solo se puede editar el campo "Editable"');
                } */
            }
            //Se llama a splitLicencias para que las licencias festivas se vuelvan a calcular el campo de duplicaidad. Es un parche que pidio ezequiel.
            // ya que las validaciones se tendrian que hacer en el update al igual que en el insert. Las licencias festivas solo se manejan por el codigo de duplicidad q es un campo unico
            //las demas se manejan con la logica en LicenciaTriggerHelper.validaciones y LicenciaTriggerHelper.splitLicencias(si no son festivas). Ya que agregar la validacion de las festivas en el update
            //no requeria mucho timepo, se agrego de esta forma, para las demas licencias queda pendiente para cuando nos avisen.
            Id recordTypeLicencia = Schema.SObjectType.Dan360_Licencia__c.getRecordTypeInfosByDeveloperName().get('Licencia').getRecordTypeId();
            List<Dan360_Licencia__c> licenciasFestivas = new List<Dan360_Licencia__c>();
            for(Dan360_Licencia__c lincen : Trigger.new) {
                if(lincen.recordTypeId == recordTypeLicencia && lincen.Motivo__c == 'Festivo'){
                    licenciasFestivas.add(lincen);
                }
            }
            if(!licenciasFestivas.isEmpty()){
                LicenciaTriggerHelper.splitLicencias(licenciasFestivas);
            }
            LicenciaTriggerHelper.completarCampos(Trigger.New);
        }
    }

    if (Trigger.isAfter){
        

        if (Trigger.isInsert){
            Id recordTypeTPN = Schema.SObjectType.Dan360_Licencia__c.getRecordTypeInfosByDeveloperName().get('Tiempo_no_Promocional').getRecordTypeId();
            List<Dan360_Licencia__c> calcularDiasTranscurridos = new List<Dan360_Licencia__c>();
            for(Dan360_Licencia__c licencia : Trigger.new) {
                if(licencia.RecordTypeId != recordTypeTPN){
                    calcularDiasTranscurridos.add(licencia);
                }
            }

            if(calcularDiasTranscurridos.size() > 0){
                LicenciaTriggerHelper.calculateDiasTranscurridos(calcularDiasTranscurridos);
            }
        }
        if (Trigger.isUpdate){
            List<Dan360_Licencia__c> calcularDiasTranscurridos = new List<Dan360_Licencia__c>();
            Id recordTypeTPN = Schema.SObjectType.Dan360_Licencia__c.getRecordTypeInfosByDeveloperName().get('Tiempo_no_Promocional').getRecordTypeId();
            List<Dan360_Licencia__c> licenciasParaCrearNotificacion = new List<Dan360_Licencia__c>();
            
            for(Dan360_Licencia__c licencia : Trigger.new) {
                if(licencia.RecordTypeId != recordTypeTPN){
                    calcularDiasTranscurridos.add(licencia);
                }
            }

            if(calcularDiasTranscurridos.size() > 0){
                LicenciaTriggerHelper.calculateDiasTranscurridos(calcularDiasTranscurridos);
            }

            //LicenciaTriggerHelper.calculateDiasTranscurridos(Trigger.new);
            
            
            for (Dan360_Licencia__c licencia : Trigger.new) {
                if (Trigger.oldMap.get(licencia.Id).Estado__c != licencia.Estado__c && (licencia.Estado__c == 'Aprobada' || licencia.Estado__c == 'Rechazada')) {
                    licenciasParaCrearNotificacion.add(licencia);
                }
            }
            if (!licenciasParaCrearNotificacion.isEmpty()) {
                LicenciaTriggerHelper.createNotification(Trigger.new);                
            }
        }
        if (Trigger.isDelete){
            Id recordTypeLicencia = Schema.SObjectType.Dan360_Licencia__c.getRecordTypeInfosByDeveloperName().get('Licencia').getRecordTypeId();

            //Re-Calcular dias transcurridos.
            //Fix sobre lo que ya estaba hecho: Se acomodo el trigger delete ya q no funcionaba y se acomodo para re-utilizar el metodo calculateDiasTranscurridos
            List<String> efectividadIds = new List<String>();
            for(Dan360_Licencia__c lic : Trigger.old){
                if(lic.RecordTypeId == recordTypeLicencia){
                    efectividadIds.add(lic.Efectividad__c);
                }
            }

            List<Dan360_Licencia__c> licencias = new List<Dan360_Licencia__c>();
            Map<Id, Dan360_Licencia__c> mapEfectividadLicencia = new Map<Id, Dan360_Licencia__c>();
            //Me traigo todas las licencias de las efectividades asociadas a la licencia borrada. Y la meto en un mapa con solo una licencia (ya que solo necesito enviar una sola licencia por efectividad para q funcione el metodo)
            for( Dan360_Licencia__c licencia : [SELECT Id, Fecha_de_inicio__c, Fecha_de_Fin__c, isDeleted, Estado__c, Efectividad__c, Motivo__c FROM Dan360_Licencia__c WHERE RecordTypeId = :recordTypeLicencia AND Efectividad__c IN :efectividadIds AND Estado__c = 'Aprobada']){
                if(!mapEfectividadLicencia.containsKey(licencia.Efectividad__c)){
                    mapEfectividadLicencia.put(licencia.Efectividad__c, licencia);
                }
            }
            //Armo la lista con solo 1 licencia por efectiviad a re-calcular
            for(Id efectividad : mapEfectividadLicencia.keySet()){
                licencias.add(mapEfectividadLicencia.get(efectividad));
            }

            if(licencias.size() > 0){
                LicenciaTriggerHelper.calculateDiasTranscurridos(licencias);
            }
        }
    }

}