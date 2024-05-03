global class BatchInactivarModulos implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext modulosActivosVencidos) {
        
        return Database.getQueryLocator(
            'SELECT Id, Estado__c, Modulo_hasta__c,Fecha_de_despacho__c ' +
            'FROM Modulo_de_paciente__c ' +
            'WHERE Modulo_hasta__c < TODAY AND Estado__c = \'Activo\'' 
        );
        
    }
    global void execute(Database.BatchableContext modulosActivosVencidos, List<Modulo_de_paciente__c> records){
        List<Modulo_de_paciente__c> mdpList = new List<Modulo_de_paciente__c>();
        List<Account> accList = new List<Account>();
        Set<Id> accIds = new Set<Id>();
        for (Modulo_de_paciente__c mdp : records) {
            mdp.Estado__c = 'Inactivo';
            mdpList.add(mdp);
        }
        
        if(!mdpList.isEmpty()){ 
            
            Database.update(mdpList,false);
        }
    }
    
    
    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    } 
}