public class BatchEstadoObjetivos implements Database.Batchable<sObject> { 
    public Database.QueryLocator start(Database.BatchableContext bc) { 
        Date hoy = Date.today();
        String query =  
            'SELECT Id, Name, Estado__c, VisMed_FechaInicio__c, VisMed_FechaFin__c ' + 
            'FROM VisMed_Objetivo__c  ' + 
            'WHERE VisMed_FechaFin__c < :hoy OR VisMed_FechaInicio__c = :hoy'; 
        system.debug(query);
        return Database.getQueryLocator(query); 
    } 

    public void execute(Database.BatchableContext BC, List<VisMed_Objetivo__c> listaObjetivos) { 
        List<VisMed_Objetivo__c> objetivosToUpdate = new List<VisMed_Objetivo__c>();
        Date hoy = Date.today(); 
        if (listaObjetivos.size() > 0) { 
            for (VisMed_Objetivo__c objetivo : listaObjetivos) { 
                if (objetivo.VisMed_FechaFin__c < hoy) {
                    objetivo.Estado__c = 'Inactivo'; 
                } else if (objetivo.VisMed_FechaInicio__c == hoy){
                    objetivo.Estado__c = 'Activo'; 
                }
                objetivosToUpdate.add(objetivo);
            } 
            update objetivosToUpdate; 
        } 
    }

    public void finish(Database.BatchableContext BC) { 
        // execute any post-processing operations
    } 

}