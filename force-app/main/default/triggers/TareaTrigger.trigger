trigger TareaTrigger on Task (after update, before update, after insert, before insert)  { 
    if(Trigger.isBefore) {	
        if(Trigger.isInsert){
            List<Task> taskList = new List<Task>();
            Id llamadaSeguimiento = XappiaHelper.getRecordTypeToTratamiento('Task','Llamado de seguimiento');
            for(Task tarea : Trigger.new){
                if(
                    tarea.RecordTypeId == llamadaSeguimiento &&
                    (
                        tarea.Subject == 'Revisar status del envio del KIT' ||
                        tarea.Subject == 'KIT sin confirmar status'
                    ) &&
                    tarea.Description.contains('1. Revisar que no haya reclamos de pedido no entregado por parte de Logística que haga referencia al KIT.')
                ){
                    taskList.add(tarea);
                }
            }
            
            if(!taskList.isEmpty()){
                TareaTriggerHelper.updateFechaVencimiento(taskList);
            }
        }
        if(Trigger.isUpdate){
            Map<Id,Id> idPacienteTarea = new Map<Id,Id>();

            //CHEQUEO SI EL PACIENTE TIENE SHIPTO ANTES DE CERRAR LA TAREA DE CARGA DE PACIENTE
            for (Task tarea : Trigger.new) {
                Task oldTask = Trigger.OldMap.get(tarea.id);

                if (oldTask.Status != tarea.Status &&
                    tarea.Status == 'Completa' &&
                    tarea.Subject == 'Cargar Paciente Regular / Best Care en SAP') {
                        idPacienteTarea.put(tarea.WhatId, tarea.Id);
                    }
            }
            if(!idPacienteTarea.isEmpty()){
                TareaTriggerHelper.addErrorPacienteSinShipTo(idPacienteTarea);
            }
        }
        
        Id llamadaSeguimiento = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Llamado_de_seguimiento').getRecordTypeId();
        
        Set<id> IdCasoTarea = new Set<id>();
        for(Task t : Trigger.new) {
            if(Trigger.isInsert) {
                if(t.RecordTypeId!=null && t.RecordTypeId==llamadaSeguimiento && String.isNotBlank(t.Subject) && t.Subject.contains('Seguimiento - ')){
                    t.ActivityDate =system.today().addDays(29);
                }
                t.IsVisibleInSelfService = true;
            } 
            else {
                TareaTriggerHelper.setPaciente(Trigger.OldMap.get(t.id), t);
            }
            if( t.WhatId !=null && t.WhatId.getSobjectType() == Case.sObjectType) IdCasoTarea.add(t.WhatId);
            
        }
        if(IdCasoTarea.size() > 0) TareaTriggerHelper.updateCasePaciente(Trigger.new, IdCasoTarea);
        TareaTriggerHelper.setPacientFields(Trigger.new);
        
    }
    
    
    if (Trigger.isAfter) {	
        List<Id> idLista = new List<Id>();
        List<Id> listaAccountId = new List<Id>();
        Map<Id, Account> listaCuenta = new Map<Id, Account>();
        Id llamadaSeguimiento = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Llamado_de_seguimiento').getRecordTypeId();
        Id RTVisita = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Visita').getRecordTypeId();
        
        Set<Id> IdCasos = new set<Id>();
        
        for (Task tarea : Trigger.new) {
            if (!String.isBlank(tarea.AccountId) && tarea.RecordTypeId == llamadaSeguimiento) {
                idLista.add(tarea.AccountId);
            }
        }
        
        
        if (Trigger.isUpdate || Trigger.isInsert) {
            List<Task> taskList = new List<Task>();
            for (Task tarea : Trigger.new) {
                Boolean statusChanged = Trigger.isInsert  ||  tarea.Status != Trigger.oldMap.get(tarea.Id).Status;
                if (tarea.RecordTypeId == llamadaSeguimiento && statusChanged && tarea.IsClosed){
                    if(tarea.AccountId != null) listaAccountId.add(tarea.AccountId);
                    if(tarea.Paciente__c != null) listaAccountId.add(tarea.Paciente__c);
                }
                taskList.add(tarea);
            }
            if (Trigger.isUpdate) {
                TareaTriggerHelper.updateFechaUltimaActividadEnCuenta(taskList);
            }
        }
        
        for (Account cuenta : [
            SELECT Id, Ultimo_llamado_de_seguimiento__c 
            FROM Account 
            WHERE Id IN :listaAccountId
        ]) {
            cuenta.Ultimo_llamado_de_seguimiento__c = date.today();
            listaCuenta.put(cuenta.id, cuenta);
        }
        
        for (Formulario_MarketingCloud__c form : [
            SELECT Id, Cuenta__c 
            FROM Formulario_MarketingCloud__c 
            WHERE Id IN :listaAccountId
        ]) {
            Account a = new Account(Id = form.Cuenta__c, Ultimo_llamado_de_seguimiento__c = date.today());
            listaCuenta.put(a.id, a);
        }
        
        
        if (!listaCuenta.isEmpty()) {
            update listaCuenta.values();
        }
        
        //Seteo las cuentas listas para jitterbit y los kits a Reservados
        if(Trigger.isUpdate){
            
            Set<Id> idPacientesRegularesYBestCare = TareaTriggerHelper.getPacientesRegularesYBestCare(Trigger.new);
            List<Task> taskKitsAReservados = new List<Task>();
            List<Task> tareasCuentasListasParaJitterbit = new List<Task>();
            List<Task> tareasAltaPacienteWebParaRechazarKit = new List<Task>();
            List<Task> KitsAReservadosEYN = new List<Task>();
            
            for (Task tarea : Trigger.new) {
                Task oldTask = Trigger.OldMap.get(tarea.id);
                
                if (oldTask.IsClosed != tarea.IsClosed &&
                    tarea.IsClosed &&
                    tarea.Type == 'Alta paciente via web' &&
                    tarea.Subject == 'Alta paciente via web' &&
                    idPacientesRegularesYBestCare.contains(tarea.WhatId)) {
                        if (tarea.Status == 'Completa') {
                            tareasCuentasListasParaJitterbit.add(tarea);
                        }
                        if (tarea.Status == 'Rechazada') {
                            tareasAltaPacienteWebParaRechazarKit.add(tarea);
                        }
                }
                if (oldTask.IsClosed != tarea.IsClosed &&
                    tarea.IsClosed &&
                    tarea.Status == 'Completa' &&
                    tarea.Subject == 'Cargar Paciente Regular / Best Care en SAP' &&
                    idPacientesRegularesYBestCare.contains(tarea.WhatId)) {
                        taskKitsAReservados.add(tarea);
                }
                if(tarea.IsClosed != oldTask.IsClosed && 
                   tarea.IsClosed &&
                   tarea.Subject== Label.EYN_asunto)
                {
                    KitsAReservadosEYN.add(tarea);
                }
            }
            if(!tareasCuentasListasParaJitterbit.isEmpty()){
                TareaTriggerHelper.setCuentaListaParaJitterbit(tareasCuentasListasParaJitterbit, idPacientesRegularesYBestCare);
            }
            if(!tareasAltaPacienteWebParaRechazarKit.isEmpty()){
                TareaTriggerHelper.setKitsEnRechazados(tareasAltaPacienteWebParaRechazarKit, idPacientesRegularesYBestCare);
            }
            if(!taskKitsAReservados.isEmpty()){
                TareaTriggerHelper.setKitsEnReservados(taskKitsAReservados, idPacientesRegularesYBestCare);
            }
            if(!KitsAReservadosEYN.isEmpty()){
                TareaTriggerHelper.reservarKitsEYN(KitsAReservadosEYN);
                TareaTriggerHelper.rechazarKitsDeTareasEynRechazadas(KitsAReservadosEYN);
            }
        }
    }
}