trigger BajasTrigger on VisMed_Bajas__c (before insert, after insert, before update, after update) {

    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            //Se chequea que no haya duplicados de bajas.
            BajasTriggerHelper.checkDuplicates(Trigger.new);
            
            BajasTriggerHelper.asignarBajaAlAPM(Trigger.new);
            List<VisMed_Bajas__C> bajasAprobadasDeProfesionales = new List<VisMed_Bajas__c>();
            
            for (VisMed_Bajas__c baja : Trigger.new) { 
                if (BajasTriggerHelper.isProfessionalAndApproved(baja)) {
                    bajasAprobadasDeProfesionales.add(baja);
                }
            }

            if (!bajasAprobadasDeProfesionales.isEmpty()) {
                BajasTriggerHelper.updateInstitucion(bajasAprobadasDeProfesionales);
            }
        }
        

        if (Trigger.isUpdate) {
            List<VisMed_Bajas__C> bajasAprobadasDeProfesionales = new List<VisMed_Bajas__c>();
            
            for (VisMed_Bajas__c baja : Trigger.new) { 
                VisMed_Bajas__c oldBaja = Trigger.oldMap.get(baja.Id);
                
                if (BajasTriggerHelper.isProfessionalAndChangesToApproved(baja, oldBaja)) {
                    bajasAprobadasDeProfesionales.add(baja);
                }
            }

            if (!bajasAprobadasDeProfesionales.isEmpty()) {
                BajasTriggerHelper.updateInstitucion(bajasAprobadasDeProfesionales);
            }
        }

    }

    if (Trigger.isAfter) {
        Id recordTypeBajaProfesional = Schema.SObjectType.VisMed_Bajas__C.getRecordTypeInfosByDeveloperName().get('Profesional_de_la_Salud').getRecordTypeId();
        Id recordTypeBajaSeguimiento = Schema.SObjectType.VisMed_Bajas__C.getRecordTypeInfosByDeveloperName().get('Seguimiento').getRecordTypeId();
        List<VisMed_Bajas__C> bajasSolicitadasAprobadas = new List<VisMed_Bajas__c>();
        List<VisMed_Bajas__C> bajasSolicitadasAprobadasDeSeguimiento = new List<VisMed_Bajas__c>();
        List<VisMed_Bajas__C> bajasParaGenerarNotificacion = new List<VisMed_Bajas__c>();
        //List<VisMed_Bajas__C> bajasSolicitadasPorAPM = new List<VisMed_Bajas__c>();
        Map<String, String> tipoDeBaja = BajasTriggerHelper.tipoDeBaja(Trigger.new);
        for (VisMed_Bajas__c baja : Trigger.new) { 
            if (baja.Estado__c == 'Aprobada' && tipoDeBaja.get(baja.Id) == 'Baja Total' && baja.RecordTypeId == recordTypeBajaProfesional) {
                bajasSolicitadasAprobadas.add(baja);
                System.debug(bajasSolicitadasAprobadas);
            }            
            if (baja.Estado__c == 'Aprobada'&& tipoDeBaja.get(baja.Id) != 'Baja Total' && baja.Fecha_de_Desactivacion__c <= System.today() && baja.RecordTypeId == recordTypeBajaProfesional) {
                bajasSolicitadasAprobadas.add(baja);
                System.debug(bajasSolicitadasAprobadas);
            } else if (baja.Estado__c == 'Aprobada' && baja.RecordTypeId == recordTypeBajaSeguimiento) {
                bajasSolicitadasAprobadasDeSeguimiento.add(baja);
            }
            
        }

        

        if (Trigger.isInsert) {
            if (!bajasSolicitadasAprobadas.isEmpty()) {
                BajasTriggerHelper.desvincularProfesional(bajasSolicitadasAprobadas);
            }
            if (!bajasSolicitadasAprobadasDeSeguimiento.isEmpty()) {
                BajasTriggerHelper.actualizarSeguimiento(bajasSolicitadasAprobadasDeSeguimiento, 'Inactivo', true);
            }
        }
        
        if (Trigger.isUpdate) {
            if (!bajasSolicitadasAprobadas.isEmpty()) {
                BajasTriggerHelper.desvincularProfesional(bajasSolicitadasAprobadas);
            }
            if (!bajasSolicitadasAprobadasDeSeguimiento.isEmpty()) {
                BajasTriggerHelper.actualizarSeguimiento(bajasSolicitadasAprobadasDeSeguimiento, 'Inactivo', true);
            }
            for(VisMed_Bajas__c baja : Trigger.new){
                if (Trigger.oldMap.containsKey(baja.Id)) {
                    if ((Trigger.oldMap.get(baja.Id).Estado__c != baja.Estado__c)&& (baja.Estado__c == 'Aprobada'||baja.Estado__c == 'Rechazada') ) {
                    //    bajasParaGenerarNotificacion.add(Trigger.oldMap.get(baja.Id));
                        bajasParaGenerarNotificacion.add(baja);
                    }
                }
            }
            if (!bajasParaGenerarNotificacion.isEmpty()) {
            BajasTriggerHelper.createNotification(bajasParaGenerarNotificacion);       
        }
        }
    }

}