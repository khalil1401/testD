public class BatchEstadoAcciones implements Database.Batchable<sObject> {
    public Database.QueryLocator start(Database.BatchableContext bc) { 
        Date hoy = Date.today();
        String query =  
            'SELECT Id, Name, Estado__c, VisMed_FechaInicio__c, VisMed_FechaFin__c ' + 
            'FROM VisMed_Accion__c  ' + 
            'WHERE VisMed_FechaFin__c < :hoy OR VisMed_FechaInicio__c = :hoy'; 
        system.debug(query);
        return Database.getQueryLocator(query); 
    } 

    public void execute(Database.BatchableContext BC, List<VisMed_Accion__c> listaAcciones) { 
        List<VisMed_Accion__c> accionesToUpdate = new List<VisMed_Accion__c>();
        Date hoy = Date.today(); 
        if (listaAcciones.size() > 0) {
            for (VisMed_Accion__c accion : listaAcciones) { 
                if (accion.VisMed_FechaFin__c < hoy) {
                    accion.Estado__c = 'Inactivo'; 
                } else if (accion.VisMed_FechaInicio__c == hoy){
                    accion.Estado__c = 'Activo'; 
                }
                accionesToUpdate.add(accion);
            } 
            update accionesToUpdate; 
        } 
    }

    public void finish(Database.BatchableContext BC) { 
        // execute any post-processing operations
    } 

}