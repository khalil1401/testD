public class BatchNotificacionFinDeCiclo implements Database.Batchable<sObject>{
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        Notificacion_fin_de_Ciclo__mdt mdt = [SELECT Id, DeveloperName, Dias_de_antelacion__c FROM Notificacion_fin_de_Ciclo__mdt LIMIT 1];
        Date diaFinDelCiclo = Date.today().addDays(mdt.Dias_de_antelacion__c.intValue());
        String query = 
        'SELECT Id, OwnerId, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastActivityDate, LastViewedDate, LastReferencedDate, Anio__c, Fecha_de_inicio__c, Fecha_de_Fin__c, VisMed_Cmpt_Tiempo_no_promocional__c, Numero_de_mes__c  ' +
        'FROM VisMed_Ciclo__c ' +
        'WHERE Fecha_de_Fin__c = :diaFinDelCiclo ';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<VisMed_Ciclo__c> ciclosQueCierran) {
        List<Contact> APMs = [SELECT Id, Name FROM Contact WHERE Owner.VisMed_Es_un_Visitador_Medico__c = true];system.debug(apms.size());
        List<Notificacion__c> notificacionesToInsert = new List<Notificacion__c>();
        for (Contact APM : APMs) {
            Notificacion__c newNotificacion = new Notificacion__c(
                APM__c = APM.Id,
                Name = APM.Name + ' el ciclo actual está próximo a finalizar, ',
                Cuerpo__c = 'recuerde cargar su actividad pendiente.',
                Leido__c = false
            );
            notificacionesToInsert.add(newNotificacion);
        }
        insert notificacionesToInsert;
    }

    public void finish(Database.BatchableContext BC) {
        // execute any post-processing operations
    }

}