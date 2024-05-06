trigger CambioDeContrasenaAppUserTrigger on Cambio_de_Contrasena_App_User__c (after update) {

    if (Trigger.isAfter) {
        if (Trigger.isUpdate) {
            List<Cambio_de_Contrasena_App_User__c> procesosAprobados = new List<Cambio_de_Contrasena_App_User__c>();
            for (Cambio_de_Contrasena_App_User__c proceso : Trigger.new) {
                if (proceso.Estado__c == 'Aprobada') {
                    procesosAprobados.add(proceso);
                }
                CambioDeContrasenaAppUserTriggerHelper.updateUserPass(procesosAprobados);
            }
        }
    }

}