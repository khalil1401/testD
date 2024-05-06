trigger SubmitApprovalSeguimientoTrigger on VisMed_Contacto_Cuenta_Usuario__c (after insert, after update, before update) {

    if (trigger.isAfter) {
    if (trigger.isInsert) {
        List<VisMed_Contacto_Cuenta_Usuario__c> seguimientoForApproval = new List<VisMed_Contacto_Cuenta_Usuario__c>();
        for (VisMed_Contacto_Cuenta_Usuario__c seg : trigger.new) {
            if (seg.Estado__c == 'pendiente' && !Approval.isLocked(seg.id)) {
                seguimientoForApproval.add(seg);
                System.debug('Fichero: '+ seg.Estado__c);
            }
        }
        if (seguimientoForApproval != null && !seguimientoForApproval.isEmpty()) {
            SubmitApprovalSeguimientoTriggerHelper.SubmitApprovalProcess(seguimientoForApproval);            
        }
    }
    if (trigger.isUpdate) {
        List<VisMed_Contacto_Cuenta_Usuario__c> seguimientoForApproval = new List<VisMed_Contacto_Cuenta_Usuario__c>();
        List<VisMed_Contacto_Cuenta_Usuario__c> ficherosToUnlock = new List<VisMed_Contacto_Cuenta_Usuario__c>();
        for (VisMed_Contacto_Cuenta_Usuario__c seg : trigger.new) {
            System.debug('Estado de bloqueo del fichero: '+ Approval.isLocked(seg.id));
            if (seg.Estado__c == 'pendiente' && !Approval.isLocked(seg.id) && Trigger.oldMap.get(seg.Id).Fecha_Solicitud__c == null && seg.Fecha_Solicitud__c == null) {
                seguimientoForApproval.add(seg);
                System.debug('Fichero: '+ seg);
                System.debug('Fichero estado: '+ seg.Estado__c);
                System.debug('Fichero fecha de solicitud: '+ seg.Fecha_Solicitud__c);
            }

            //Logica para enviar nuevamente un fichero cuando pasa de inactivo a pendiente
            if((seg.Estado__c == 'pendiente' && Trigger.oldMap.get(seg.Id).Estado__c == 'Inactivo') && Approval.isLocked(seg.id)){
                ficherosToUnlock.add(seg);
                System.debug('Fichero: '+ seg);
                System.debug('Fichero estado: '+ seg.Estado__c);
                System.debug('Fichero estado anterior: '+ Trigger.oldMap.get(seg.Id).Estado__c);
            }   
        }

        if (seguimientoForApproval != null && !seguimientoForApproval.isEmpty()) {
            SubmitApprovalSeguimientoTriggerHelper.SubmitApprovalProcess(seguimientoForApproval);            
        }

        if(!ficherosToUnlock.isEmpty()){
            Approval.UnLockResult[] ficheroList = Approval.Unlock(ficherosToUnlock, false);
            SubmitApprovalSeguimientoTriggerHelper.SubmitApprovalProcess(ficherosToUnlock);  
        }
    }
  }
}