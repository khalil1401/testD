public class BatchFeriados implements Database.Batchable<sObject>{
   
    public Database.QueryLocator start (Database.BatchableContext bc) {
        Date fechaAuctual = System.today();
        return Database.getQueryLocator([SELECT Id, Name, VisMed_Fecha__C FROM VisMed_Feriado__c WHERE VisMed_Fecha__c = :fechaAuctual]);
    }

    public void execute (Database.BatchableContext BC, list<VisMed_Feriado__c> feriados) {
        Date fechaAuctual = System.today();
        List<User> apms = [
            SELECT Id, Name, ContactId, Contact.Name, IsActive, IsPortalEnabled
            FROM User
            WHERE IsActive = true 
            AND IsPortalEnabled = true
            AND ContactId != null
            AND VisMed_Es_un_Visitador_Medico__c = true
        ];  
        
        List<Id> contactoDeLosAPMs = new List<Id>();
        for (User usuario : apms) {
            contactoDeLosAPMs.add(usuario.ContactId);
        }
        List<Dan360_Efectividad__c> efectividades = [SELECT Id, Name, Tiempo_no_promocional__c, Dias_feriados__c, Fecha_de_inicio__c, Fecha_de_Fin__c, Dias_de_campo_efectivo__c, 
                                                            Dias_habiles_transcurridos__c, VisMed_Visitas_restantes__c, VisMed_APM__c, VisMed_Target_Diario__c, 
                                                            Dias_habiles_del_ciclo__c, VisMed_Visitas_realizadas__c, VisMed_Ciclo__c, VisMed_Efectividad__c, VisMed_Cmpt_Tiempo_no_promocional__c
                                                     FROM Dan360_Efectividad__c
                                                     WHERE VisMed_APM__c IN :contactoDeLosAPMs AND Fecha_de_inicio__c <= :fechaAuctual AND Fecha_de_Fin__c >= :fechaAuctual];
        //Map<Id, Map<Dan360_Efectividad__c, List<Dan360_Licencia__c>>> licenciasPorEfectividadesPorAPM = New Map<Id, Map<Dan360_Efectividad__c, List<Dan360_Licencia__c>>>();
        List<Dan360_Licencia__c> newLicencias = New List<Dan360_Licencia__c>();
        for (User apm : apms) {
            for (Dan360_Efectividad__c efectividad : efectividades){
                for (VisMed_Feriado__c feriado : feriados) {
                    if (apm.ContactId == efectividad.VisMed_APM__c && (feriado.VisMed_Fecha__c >= efectividad.Fecha_de_inicio__c && feriado.VisMed_Fecha__c <= efectividad.Fecha_de_Fin__c)) {
                        Dan360_Licencia__c newLicencia = New Dan360_Licencia__c(
                        RecordTypeId = Schema.SObjectType.Dan360_Licencia__c.getRecordTypeInfosByDeveloperName().get('Licencia').getRecordTypeId(),
                        Motivo__c = 'Festivo',
                        VisMed_APM__c = apm.ContactId,
                        Efectividad__c = efectividad.Id,
                        Estado__c = 'Aprobada',
                        Fecha_de_inicio__c = feriado.VisMed_Fecha__c,
                        Fecha_de_Fin__c = feriado.VisMed_Fecha__c,
                        Comentarios__c = feriado.Name
                    );
                    newLicencias.add(newLicencia);
                    }
                }
            }
        }
        insert newLicencias;
    }

    public void finish (Database.BatchableContext BC) {
        // execute any post-processing operations
    }

}