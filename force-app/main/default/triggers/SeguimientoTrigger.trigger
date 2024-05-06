trigger SeguimientoTrigger on VisMed_Contacto_Cuenta_Usuario__c (before insert, before update, after insert, after update) {

    if(Trigger.isBefore) {
        if (Trigger.isInsert) {            
            SeguimientoTriggerHelper.asignarSeguimientoAlAPM(Trigger.new);
            SeguimientoTriggerHelper.hacerPredeterminadoAlNuevoSeguimiento(Trigger.new); //tambien setea frecuencia
            // si se da de alta un nuevo  fichero y hay uno activo con la misma relacion apm profesional se debe copiar los valores 
            SeguimientoTriggerHelper.verificharSiHayFicheroActivoParaCopiarValores(Trigger.new, false); 
        }
        if (Trigger.isUpdate) {
            System.debug('Entra trigger');
            List<VisMed_Contacto_Cuenta_Usuario__c> seguimientosParaSetearFrecuencia = new List<VisMed_Contacto_Cuenta_Usuario__c>();
            List<VisMed_Contacto_Cuenta_Usuario__c> seguimientosParaCrearSegmentacion = new List<VisMed_Contacto_Cuenta_Usuario__c>();            
            List<VisMed_Contacto_Cuenta_Usuario__c> seguimientosParaSerPrincipal = new List<VisMed_Contacto_Cuenta_Usuario__c>();
            List<VisMed_Contacto_Cuenta_Usuario__c> seguimientosParaGuardarSegmentacionAnterior = new List<VisMed_Contacto_Cuenta_Usuario__c>();
            List<VisMed_Contacto_Cuenta_Usuario__c> seguimientosParaUpdatearSemaforo = new List<VisMed_Contacto_Cuenta_Usuario__c>();
            List<VisMed_Contacto_Cuenta_Usuario__c> seguimientosParaBlanquearFrecuencia = new List<VisMed_Contacto_Cuenta_Usuario__c>(); //Blaquear frecuencia desde la app
            List<VisMed_Contacto_Cuenta_Usuario__c> seguimientosParaBlanquearMotivo = new List<VisMed_Contacto_Cuenta_Usuario__c>(); //Blaquear motivo de fichero que vuelve a ser activo
            Set<Id> profesionalesId = new Set<Id>();
            Map<Id, Id> recordTypePorProfesional = new Map<Id, Id>();
            for (VisMed_Contacto_Cuenta_Usuario__c  Seguimiento : Trigger.new) {
                if( Trigger.oldMap.get(seguimiento.Id).Estado__c == 'Pendiente' || Trigger.oldMap.get(seguimiento.Id).Segmenta_Por__c != seguimiento.Segmenta_Por__c && seguimiento.Estado__c == 'Activo' && seguimiento.Segmenta_Por__c != null){
                    profesionalesId.add(seguimiento.Profesional__c);                    
                }
            }
            List<Account> profesionalesRecordType = [
                SELECT Id, RecordTypeId
                FROM Account
                WHERE Id IN :profesionalesId
            ];
            System.debug(profesionalesRecordType);
            if (!profesionalesRecordType.isEmpty() && profesionalesRecordType.size() > 0) {
                for (VisMed_Contacto_Cuenta_Usuario__c seguimiento : Trigger.new) {
                    for (Account acc : profesionalesRecordType) {
                        if (seguimiento.Profesional__c == acc.Id) {
                            recordTypePorProfesional.put(seguimiento.Profesional__c, acc.RecordTypeId);
                        }
                    }
                }                
            }
            Id recordTypeProfesional = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Profesional_de_la_Salud').getRecordTypeId();
            for (VisMed_Contacto_Cuenta_Usuario__c seguimiento : Trigger.new) {
                System.debug(seguimiento.Id);               
                System.debug(Trigger.oldMap.get(seguimiento.Id).Segmenta_Por__c);                
                System.debug(Trigger.oldMap.get(seguimiento.Id).Estado__c);                
                //System.debug(recordTypeProfesional);
                if (recordTypePorProfesional.containsKey(seguimiento.Profesional__c)) {
                    if (Trigger.oldMap.get(seguimiento.Id).Segmenta_Por__c != seguimiento.Segmenta_Por__c && recordTypePorProfesional.get(seguimiento.Profesional__c) == recordTypeProfesional && seguimiento.Segmenta_Por__c != null && seguimiento.Estado__c == 'Activo') {
                        System.debug('crear segmentacion');
                        seguimientosParaCrearSegmentacion.add(seguimiento);
                    }                    
                    if (Trigger.oldMap.get(seguimiento.Id).Estado__c == 'Pendiente' && recordTypePorProfesional.get(seguimiento.Profesional__c) == recordTypeProfesional && seguimiento.Segmenta_Por__c != null && seguimiento.Estado__c == 'Activo' && seguimiento.Tipo__c == 'Alta Profesional') {
                        System.debug('crear segmentacion');
                        seguimientosParaCrearSegmentacion.add(seguimiento);
                    }                    
                }
                // if (Trigger.oldMap.get(seguimiento.Id).Segmenta_Por__c != seguimiento.Segmenta_Por__c 
                //     && Trigger.oldMap.get(seguimiento.Id).Segmenta_Por__c == null
                //     && Trigger.oldMap.get(seguimiento.Id).Estado__c == seguimiento.Estado__c 
                //     && seguimiento.Estado__c == 'Activo' 
                //     && String.isNotEmpty(seguimiento.Segmenta_Por__c)) {
                //         System.debug('Set Frecuencia');
                //         seguimientosParaSetearFrecuencia.add(seguimiento);
                // }

                if (Trigger.oldMap.get(seguimiento.Id).Estado__c != seguimiento.Estado__c && seguimiento.Estado__c == 'Activo' && seguimiento.Predeterminada__c == true) {
                    System.debug('sacar principal');
                    seguimientosParaSerPrincipal.add(seguimiento);
                }
                if (Trigger.oldMap.get(seguimiento.Id).Predeterminada__c != seguimiento.Predeterminada__c && seguimiento.Estado__c == 'Activo' && seguimiento.Predeterminada__c == true) {
                    System.debug('sacar principal');
                    seguimientosParaSerPrincipal.add(seguimiento);
                }
                // if (Trigger.oldMap.containsKey(seguimiento.Id)) {
                //     System.debug(seguimiento.Segmenta_Por__c);
                //     if (Trigger.oldMap.get(seguimiento.Id).Estado__c != seguimiento.Estado__c && seguimiento.Estado__c == 'Activo' && (seguimiento.Segmenta_Por__c != null || String.isNotEmpty(seguimiento.Segmenta_Por__c))) {
                //         System.debug('Set Frecuencia');
                //         seguimientosParaSetearFrecuencia.add(seguimiento);
                //     }
                // }
                if (trigger.oldMap.get(seguimiento.Id).Segmenta_Por__c != seguimiento.Segmenta_Por__c) {
                    seguimientosParaGuardarSegmentacionAnterior.add(seguimiento);
                }
                // si cambia visitas realizadas y visitas realizadas no cambia desde la batch frecuencia semaforo se debe actualizar el semaforo en tiempo real
                if ((trigger.oldMap.get(seguimiento.Id).Visitas_Realizadas__c != seguimiento.Visitas_Realizadas__c 
                    || trigger.oldMap.get(seguimiento.Id).Visitas_acumuladas__c != seguimiento.Visitas_acumuladas__c )
                    && !BatchFrecuenciaSemaforo.isRunningFromBatch) {
                    System.debug('fichero para semaforo: '+ seguimiento.Id);
                    seguimientosParaUpdatearSemaforo.add(seguimiento);
                } 

                //Si pasa de inactivo a pendiete y el campo esta en true es porque se dio de alta un fichero que estaba inactivo desde la app.
                if(Trigger.oldMap.get(seguimiento.Id).Estado__c == 'Inactivo' && seguimiento.Estado__c == 'Pendiente' && seguimiento.Actualizar_Frecuencia__c == true){
                    seguimientosParaBlanquearFrecuencia.add(seguimiento);
                }
                //Si pasa de estado inactivo a activo se debe blanquear el motivo de la baja
                if( Trigger.oldMap.get(seguimiento.Id).Estado__c == 'Inactivo' || Trigger.oldMap.get(seguimiento.Id).Estado__c == 'Pendiente' && seguimiento.Estado__c == 'Activo'){
                    seguimientosParaBlanquearMotivo.add(seguimiento);
                }
            }
            if(!seguimientosParaCrearSegmentacion.isEmpty()){
                SeguimientoTriggerHelper.crearSegmentacion(seguimientosParaCrearSegmentacion);
            }            
            // if (!seguimientosParaSetearFrecuencia.isEmpty()) {
            //     SeguimientoTriggerHelper.setFrecuencia(seguimientosParaSetearFrecuencia, false);
            // }
            if (!seguimientosParaSerPrincipal.isEmpty()) {
                SeguimientoTriggerHelper.dejarUnSoloSeguimientoComoPrincipal(seguimientosParaSerPrincipal);
            }
            if (!seguimientosParaGuardarSegmentacionAnterior.isEmpty()) {
                SeguimientoTriggerHelper.GuardarSegmentacionAnterior(seguimientosParaGuardarSegmentacionAnterior, Trigger.oldMap);
            }
            
            if(!seguimientosParaBlanquearFrecuencia.isEmpty()){
                SeguimientoTriggerHelper.verificharSiHayFicheroActivoParaCopiarValores(seguimientosParaBlanquearFrecuencia,true);
            }
            if(!seguimientosParaBlanquearMotivo.isEmpty()){
                SeguimientoTriggerHelper.blankFieldMotivo(seguimientosParaBlanquearMotivo);
            }
            if (!seguimientosParaUpdatearSemaforo.isEmpty()) {
                SeguimientoTriggerHelper.UpdateSemaforo(seguimientosParaUpdatearSemaforo);
            }
        }
    }

    if(Trigger.isAfter) {
        List<VisMed_Contacto_Cuenta_Usuario__c> seguimientosActivos = new List<VisMed_Contacto_Cuenta_Usuario__c>();
        List<VisMed_Contacto_Cuenta_Usuario__c> seguimientosPredeterminados = new List<VisMed_Contacto_Cuenta_Usuario__c>();
        List<VisMed_Contacto_Cuenta_Usuario__c> seguimientosPredeterminadosConSegmentacion = new List<VisMed_Contacto_Cuenta_Usuario__c>();        
        if (Trigger.isInsert) {
            for (VisMed_Contacto_Cuenta_Usuario__c seguimiento : Trigger.new) {            
                if (seguimiento.Estado__c == 'Activo') {
                    seguimientosActivos.add(seguimiento);                    
                    if (seguimiento.Predeterminada__c) {
                        seguimientosPredeterminados.add(seguimiento);
                        /*if (seguimiento.Segmenta_Por__c != null) {
                            seguimientosPredeterminadosConSegmentacion.add(seguimiento);
                        }*/
                    }
                }
            }
            if (!seguimientosActivos.isEmpty()) {
                SeguimientoTriggerHelper.createAccountTeam(seguimientosActivos);
                SeguimientoTriggerHelper.createLugarDeTrabajo(seguimientosActivos);
                SeguimientoTriggerHelper.activateProfesional(seguimientosActivos);               
                // if (!seguimientosPredeterminados.isEmpty()) {
                //     SeguimientoTriggerHelper.quitarPredeterminadoALosOtrosSeguimientos(seguimientosPredeterminados);
                    /*if (!seguimientosPredeterminadosConSegmentacion.isEmpty()){
                        SeguimientoTriggerHelper.checkIfExistSegmentacion(seguimientosPredeterminadosConSegmentacion);
                    }*/
                // }
            }
        }
        if (Trigger.isUpdate) {

            List<VisMed_Contacto_Cuenta_Usuario__c> seguimientosParaHacerPredeterminados = new List<VisMed_Contacto_Cuenta_Usuario__c>();
            List<VisMed_Contacto_Cuenta_Usuario__c> seguimientosParaReemplazar = new List<VisMed_Contacto_Cuenta_Usuario__c>();
            List<VisMed_Contacto_Cuenta_Usuario__c> seguimientosRechazados = new List<VisMed_Contacto_Cuenta_Usuario__c>();
            List<VisMed_Contacto_Cuenta_Usuario__c> seguimientosParaCopiarCambios = new List<VisMed_Contacto_Cuenta_Usuario__c>();
            List<VisMed_Contacto_Cuenta_Usuario__c> seguimientosParaSyncConPrincipal = new List<VisMed_Contacto_Cuenta_Usuario__c>();
            List<VisMed_Contacto_Cuenta_Usuario__c> seguimientosAprobados = new List<VisMed_Contacto_Cuenta_Usuario__c>();            
            for (VisMed_Contacto_Cuenta_Usuario__c seguimiento : Trigger.new) {
                if (Seguimiento.Estado__c == 'Activo' && (Trigger.oldMap.get(seguimiento.Id).Estado__c != 'Inactivo' 
                && Trigger.oldMap.get(seguimiento.Id).Estado__c != 'Baja Temporal' 
                && Trigger.oldMap.get(seguimiento.Id).Estado__c != 'Rechazado') 
                && Trigger.oldMap.get(seguimiento.Id).Predeterminada__c == seguimiento.Predeterminada__c
                && !BatchFrecuenciaSemaforo.isRunningFromBatch
                && Trigger.oldMap.get(seguimiento.Id).Visitas_Realizadas__c != seguimiento.Visitas_Realizadas__c
                || Trigger.oldMap.get(seguimiento.Id).Segmenta_Por__c != seguimiento.Segmenta_Por__c
                || Trigger.oldMap.get(seguimiento.Id).Ultima_Visita__c != seguimiento.Ultima_Visita__c
                || Trigger.oldMap.get(seguimiento.Id).VisMed_Semaforo__c != seguimiento.VisMed_Semaforo__c
                || Trigger.oldMap.get(seguimiento.Id).Visitas_acumuladas__c != seguimiento.Visitas_acumuladas__c) {
                    if (SeguimientoTriggerHelper.isFirstTime) {
                        seguimientosParaCopiarCambios.add(seguimiento);
                        System.debug('Copiar Seguimiento activo');
                        System.debug(seguimiento.Estado__c);
                        System.debug(seguimiento.Segmenta_Por__c);
                        System.debug(seguimiento.Predeterminada__c);
                        System.debug(seguimiento.Id);
                    }
                    
                }
                if(Trigger.oldMap.get(seguimiento.Id).Estado__c != seguimiento.Estado__c 
                && (Trigger.oldMap.get(seguimiento.Id).Estado__c == 'Inactivo' 
                || Trigger.oldMap.get(seguimiento.Id).Estado__c == 'Baja Temporal' 
                || Trigger.oldMap.get(seguimiento.Id).Estado__c == 'Rechazado') 
                && seguimiento.Estado__c == 'Activo' 
                && seguimiento.Tipo__c == 'Alta domicilio' 
                && Trigger.oldMap.get(seguimiento.Id).Predeterminada__c == seguimiento.Predeterminada__c
                ){
                    if (SeguimientoTriggerHelper.isFirstTime) {
                        seguimientosParaCopiarCambios.add(seguimiento);
                        System.debug('Copiar Seguimiento activo que vuelve activo');
                        System.debug(seguimiento.Estado__c);
                        System.debug(seguimiento.Predeterminada__c);
                        System.debug(seguimiento.Segmenta_Por__c);
                        System.debug(seguimiento.Id);
                    }
                    
                }
                if (seguimiento.Predeterminada__c == true) {
                    seguimientosParaSyncConPrincipal.add(seguimiento);
                }
                
                if (Trigger.oldMap.containsKey(seguimiento.Id)) {
                    if (Trigger.oldMap.get(seguimiento.Id).Estado__c != seguimiento.Estado__c && seguimiento.Estado__c == 'Activo') {
                        seguimientosAprobados.add(seguimiento);
                        //seguimientosParaHacerPredeterminados.add(seguimiento);
                        seguimientosActivos.add(seguimiento);
                        // System.debug(Trigger.oldMap.get(seguimiento.Id).Segmenta_Por__c);
                        // if (Trigger.oldMap.get(seguimiento.Id).Segmenta_Por__c != seguimiento.Segmenta_Por__c) {
                        //     System.debug('crear segmentacion');
                        //     //seguimientosParaCrearSegmentacion.add(seguimiento);
                        // }
                        /*if (Trigger.oldMap.get(seguimiento.Id).Predeterminada__c && Trigger.oldMap.get(seguimiento.Id).Segmenta_Por__c != null) {
                            seguimientosPredeterminadosConSegmentacion.add(seguimiento);
                        }*/
                    } /* else if (Trigger.oldMap.get(seguimiento.Id).Estado__c != seguimiento.Estado__c && seguimiento.Estado__c != 'Activo' && seguimiento.Predeterminada__c) {
                        seguimientosParaReemplazar.add(seguimiento);
                    } */
                     if (Trigger.oldMap.get(seguimiento.Id).Estado__c != seguimiento.Estado__c && seguimiento.Estado__c == 'Rechazado') {
                        seguimientosRechazados.add(seguimiento);
                    }
                }
            }
            if (!seguimientosParaCopiarCambios.isEmpty()) {
                if (SeguimientoTriggerHelper.isFirstTime) {
                    System.debug('Copiar seguimientos');                    
                    SeguimientoTriggerHelper.copiarCambiosALosSeguimientosConMismoApmYProfesional(seguimientosParaCopiarCambios, Trigger.oldMap);                    
                }
                
            }
            // if (!seguimientosParaSyncConPrincipal.isEmpty()) {
            //     SeguimientoTriggerHelper.sincronizarFicheros(seguimientosParaSyncConPrincipal);
            // }
            if (!seguimientosAprobados.isEmpty()) {
                System.debug('crear notificacion');
                SeguimientoTriggerHelper.createNotification(seguimientosAprobados);                
            }
            if (!seguimientosActivos.isEmpty()) {               
                SeguimientoTriggerHelper.createAccountTeam(seguimientosActivos);
                SeguimientoTriggerHelper.createLugarDeTrabajo(seguimientosActivos);
                //SeguimientoTriggerHelper.quitarPredeterminadoALosOtrosSeguimientos(seguimientosParaHacerPredeterminados);
                //SeguimientoTriggerHelper.activateProfesional(seguimientosActivos);
            }
            /*if (!seguimientosPredeterminados.isEmpty()) {
                SeguimientoTriggerHelper.checkIfExistSegmentacion(seguimientosPredeterminadosConSegmentacion);
            }       */
            /* if (!seguimientosParaReemplazar.isEmpty()) {
                SeguimientoTriggerHelper.reemplazarSeguimientoPredeterminado(seguimientosParaReemplazar);
            }  */   
            if (!seguimientosRechazados.isEmpty()) {
                SeguimientoTriggerHelper.rechazarLugaresDeTrabajo(seguimientosRechazados);
                SeguimientoTriggerHelper.createNotification(seguimientosRechazados);
            }            
        }
    }
    
}