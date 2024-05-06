public class BatchVisMedBaja implements Database.Batchable<sObject> {
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        Date hoy = Date.today();
        String query = 
            'SELECT Id, Fecha_de_Reactivacion__c, Fecha_de_Desactivacion__c, Profesional__c, Motivo_de_la_Baja__c, VisMed_APM__c, Institucion__c  ' +
            'FROM VisMed_Bajas__c ' +
            'WHERE (Fecha_de_Reactivacion__c = :hoy OR Fecha_de_Desactivacion__c = :hoy) AND Estado__c = \'Aprobada\'';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<VisMed_Bajas__c> visitasMedBajas) {
        List<VisMed_Bajas__c> visitasMedBajasToDeactivate = new List<VisMed_Bajas__c>();
        List<Id> accountsToReactivateIds = new List<Id>();
        List<Id> apmsFicheros = new List<Id>();
        List<VisMed_Bajas__c> bajasToActivate = new List<VisMed_Bajas__c>();
        Date hoy = date.today();

        for (VisMed_Bajas__c visitaMedBajas : visitasMedBajas) {
            //Reactivation
            if (visitaMedBajas.Fecha_de_Reactivacion__c == hoy) {
                accountsToReactivateIds.add(visitaMedBajas.Profesional__c);
                apmsFicheros.add(visitaMedBajas.VisMed_APM__c);
                bajasToActivate.add(visitaMedBajas);
            }
            //Deactivation
            if (visitaMedBajas.Fecha_de_Desactivacion__c == hoy) {
                visitasMedBajasToDeactivate.add(visitaMedBajas); 
            }
        }

        //Deactivation
        if (visitasMedBajasToDeactivate.size() > 0) {
            BajasTriggerHelper.desvincularProfesional(visitasMedBajasToDeactivate);
        }
        //Reactivation
        System.debug('Activar');
        System.debug(accountsToReactivateIds);
        if (accountsToReactivateIds.size() > 0) {
            List<Account> accountsToUpdate = [
                SELECT Id, Profesional_Activo__c
                FROM Account
                WHERE Id IN :accountsToReactivateIds
            ];
            
            for (Account account : accountsToUpdate) {
                account.Profesional_Activo__c = true;
            }

            update accountsToUpdate;
            BajasTriggerHelper.actualizarSeguimiento(bajasToActivate,'Activo', false);
        }
    }

    public void finish(Database.BatchableContext BC) {
        // execute any post-processing operationsjaja
    }
}