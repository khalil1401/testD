trigger InteraccionTrigger on Dan360_Interacciones__c (before insert, before update, after insert, after update, after delete) {
    
    if (Trigger.isBefore){
        System.debug('etrar trigger interacciones');
        ///////////////////////// VALIDACIONES //////////////////////////////////
        // Hacer Owner del registro al APM.
        // Validar que no se este cargando una interaccion sobre un dia con licencia
        // Validar que exista la relacion Profesional-Institucion-APM
        Id recordTypeTareaAccion = Schema.SObjectType.Dan360_Interacciones__c.getRecordTypeInfosByDeveloperName().get('Tarea_de_Accion').getRecordTypeId();
        Id recordTypeVisitaMedica = Schema.SObjectType.Dan360_Interacciones__c.getRecordTypeInfosByDeveloperName().get('Visita_Medica').getRecordTypeId();
        List<Dan360_Interacciones__c> interaccionesNoTareaAccion = new List<Dan360_Interacciones__c>();
        List<Dan360_Interacciones__c> interaccionesVisitaMedica = new List<Dan360_Interacciones__c>();
        for(Dan360_Interacciones__c interaccion : Trigger.new){
            if(interaccion.RecordTypeId != recordTypeTareaAccion){
                interaccionesNoTareaAccion.add(interaccion);
            }
        }


        if(interaccionesNoTareaAccion.size()>0){
            InteraccionTriggerHelper.validarQueLaInteraccionNoSeCreeElMismoDiaQueUnaLicencia(Trigger.new);
        }
        
        InteraccionTriggerHelper.validarQueExistaRelacionProfesionalInstitucionAPM(Trigger.new);
        ///////////////////////// FIN VALIDACIONES //////////////////////////////////
        if (Trigger.isInsert){
            // Crear Codigo de Duplicidad.
            // Validar si crearla aprobada o pendiente dependiendo de la metadata de retraso (Solo Visitas y no Visitas).
            // Asignar al interaccion a la efectividad correspondiente (Solo Visitas y no Visitas).

            //Inicio - Validar visitas para el mismo profesional el mismo dia - Solo Visita Medica
            for(Dan360_Interacciones__c interaccion : Trigger.new) {
                if(interaccion.RecordtypeId == recordTypeVisitaMedica){
                    interaccionesVisitaMedica.add(interaccion);
                }
            }
            if(!interaccionesVisitaMedica.isEmpty()){
                InteraccionTriggerHelper.checkDuplicates(interaccionesVisitaMedica);
            }
            //FIN - Validar visitas para el mismo profesional el mismo dia - Solo Visita Medica */
            InteraccionTriggerHelper.hacerOwnerDelRegistroAlAPM(Trigger.new);
            InteraccionTriggerHelper.generarCodigoDeDuplicidad(Trigger.new);
            InteraccionTriggerHelper.determinarSiLaInteraccionPasaPorProcesoDeAprobacion(Trigger.new);
            InteraccionTriggerHelper.asignarInteraccionALaEfectividadCorrespondiente(Trigger.new);
        }

        if(Trigger.isUpdate){
            List<Dan360_Interacciones__c> interacionDateChanged = new List<Dan360_Interacciones__c>();
             //Inicio - Validar visitas para el mismo profesional el mismo dia - Solo Visita Medica (si se le cambia la fecha)
            for(Dan360_Interacciones__c interaccion : Trigger.new) {
                if(interaccion.RecordtypeId == recordTypeVisitaMedica && Trigger.oldMap.get(interaccion.Id).VisMed_Fecha__c != interaccion.VisMed_Fecha__c){
                    interaccionesVisitaMedica.add(interaccion);
                }
                // si se edita la fecha de la visita y pertenece a otro ciclo se debe actulizar la efectividad
                if (interaccion.Estado__c == 'Aprobada' && interaccion.RecordTypeId == recordTypeVisitaMedica) {
                    
                    if (trigger.oldMap.get(interaccion.Id).VisMed_Fecha__c != interaccion.VisMed_Fecha__c ) {
                        System.debug('cambio fecha');
                        interacionDateChanged.add(interaccion);
                    }
                }
            }
            if(!interaccionesVisitaMedica.isEmpty()){
                InteraccionTriggerHelper.checkDuplicates(interaccionesVisitaMedica);
            }
            //FIN - Validar visitas para el mismo profesional el mismo dia - Solo Visita Medica
            InteraccionTriggerHelper.generarCodigoDeDuplicidad(Trigger.new);
            //InteraccionTriggerHelper.changeCodigoDeDuplicidad(Trigger.new);
            if (!interacionDateChanged.isEmpty()) {
                InteraccionTriggerHelper.cambiarEfectividad(interacionDateChanged);
            }

        } 
    }

    if (Trigger.isAfter) {
        // Actualizar Ultima Visita y Cantidad de visitas en el Seguimiento.
        // Actualizar Cantidad de Visitas en la efectividad.
        // Crear Notificacion.
        
        
        if(Trigger.isInsert) {
           
            Id recordTypeTareaAccion = Schema.SObjectType.Dan360_Interacciones__c.getRecordTypeInfosByDeveloperName().get('Tarea_de_Accion').getRecordTypeId();
            Id recordTypeVisitaMedica = Schema.SObjectType.Dan360_Interacciones__c.getRecordTypeInfosByDeveloperName().get('Visita_Medica').getRecordTypeId();

            List<Dan360_Interacciones__c> interacionVisitalist = new List<Dan360_Interacciones__c>();
            List<Dan360_Interacciones__c> interacionTareaAccionlist = new List<Dan360_Interacciones__c>();

            List<Dan360_Interacciones__c> interacionRelatedToSeguimiento = new List<Dan360_Interacciones__c>();
            
            for(Dan360_Interacciones__c interaccion : Trigger.new){
                if(interaccion.RecordTypeId == recordTypeVisitaMedica){
                    interacionVisitalist.add(interaccion);
                }
                if(interaccion.RecordTypeId == recordTypeTareaAccion){
                    interacionTareaAccionlist.add(interaccion);
                }
                if (interaccion.Estado__c == 'Aprobada' && interaccion.RecordTypeId == recordTypeVisitaMedica) {
                    interacionRelatedToSeguimiento.add(interaccion);
                }
            }
            if (!interacionRelatedToSeguimiento.isEmpty()) {
                System.debug('updatear seguimientos relacionados a la interaccion');
                InteraccionTriggerHelperWithOutSharing.updateInteraccionesRelatedToSeguimiento(interacionRelatedToSeguimiento);            
            }
            if(interacionVisitalist.size() > 0){
                InteraccionTriggerHelper.updateInteraccionesRelatedToEfectividad(interacionVisitalist);
            }

            if(interacionTareaAccionlist.size() > 0){
                InteraccionTriggerHelper.createObjetivoyAcciondelProfesional(interacionTareaAccionlist);
            }
            
        }

        if (Trigger.isUpdate){
            //InteraccionTriggerHelper.updateInteraccionesRelatedToEfectividad();
            Dan360_Interacciones__c[] interaccionesWithStatusChanged = new List<Dan360_Interacciones__c>();
            Dan360_Interacciones__c[] interaccionesSendNotification = new List<Dan360_Interacciones__c>();
            Id recordTypeVisitaMedica = Schema.SObjectType.Dan360_Interacciones__c.getRecordTypeInfosByDeveloperName().get('Visita_Medica').getRecordTypeId();
            List<Dan360_Interacciones__c> interacionRelatedToSeguimiento = new List<Dan360_Interacciones__c>();
            List<Dan360_Interacciones__c> interacionRelatedToSeguimientoProfesionalChanged = new List<Dan360_Interacciones__c>();            

            for(Dan360_Interacciones__c interaccion : Trigger.new) {
                Dan360_Interacciones__c oldInteraccion = Trigger.oldMap.get(interaccion.Id);
                if(interaccion.Estado__c != oldInteraccion.Estado__c) {
                    interaccionesWithStatusChanged.add(interaccion);
                    switch on oldInteraccion.Estado__c {
                        when 'Aprobada', 'Rechazada' { 
                            System.debug('No enviar');
                        } when else {
                            interaccionesSendNotification.add(interaccion);
                        }
                    }  
                }
                if (interaccion.Estado__c == 'Aprobada' && interaccion.RecordTypeId == recordTypeVisitaMedica) {
                    interacionRelatedToSeguimiento.add(interaccion);
                    System.debug('profesional anterior: '+oldInteraccion.Profesional__c);
                    System.debug('profesional Nuevo: '+interaccion.Profesional__c);
                    if (oldInteraccion.Profesional__c != interaccion.Profesional__c  || oldInteraccion.VisMed_Fecha__c != interaccion.VisMed_Fecha__c) {
                        System.debug('cambio profesional');
                        interacionRelatedToSeguimientoProfesionalChanged.add(oldInteraccion);
                    }                    
                }
            }
            
            if (!interacionRelatedToSeguimiento.isEmpty()) {
                System.debug('updatear seguimientos relacionados a la interaccion');
                InteraccionTriggerHelperWithOutSharing.updateInteraccionesRelatedToSeguimiento(interacionRelatedToSeguimiento);            
            }

            if (!interacionRelatedToSeguimientoProfesionalChanged.isEmpty()) {                
                InteraccionTriggerHelperWithOutSharing.updateInteraccionesRelatedToSeguimientoWhenChangeProfesional(interacionRelatedToSeguimientoProfesionalChanged);            
            }

            if(!interaccionesWithStatusChanged.isEmpty()) {
                InteraccionTriggerHelper.updateInteraccionesRelatedToEfectividad(interaccionesWithStatusChanged);
            }
            
            if(!interaccionesSendNotification.isEmpty()) {
                InteraccionTriggerHelper.createNotification(interaccionesSendNotification);
            }
        }

        if(Trigger.isDelete) {
            Id recordTypeVisitaMedica = Schema.SObjectType.Dan360_Interacciones__c.getRecordTypeInfosByDeveloperName().get('Visita_Medica').getRecordTypeId();
            List<Dan360_Interacciones__c> interaccionesDeleted = new List<Dan360_Interacciones__c>();            
            InteraccionTriggerHelper.updateInteraccionesRelatedToEfectividad(Trigger.old);
            for (Dan360_Interacciones__c interaccion : Trigger.old) {
                if( interaccion.Estado__c == 'Aprobada' && interaccion.RecordTypeId == recordTypeVisitaMedica){
                    interaccionesDeleted.add(interaccion);
                }
            }
            if (!interaccionesDeleted.isEmpty()) {
                System.debug('interaccion eliminadas: '+ interaccionesDeleted);
                InteraccionTriggerHelperWithOutSharing.updateSeguimientoRelatedToInteraccionDeleted(interaccionesDeleted);                
            }
        }
    } 

}