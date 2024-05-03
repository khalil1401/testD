global with sharing class BatchUpdateEstadoMPBC implements Database.Batchable<sObject> {
    //  Batch para Cambiar modulos de paciente (MDP) 
    //  Tomando en cuenta que sus modulos jitterbit asociado ya cambiaron a procesado 

    global Database.QueryLocator start(Database.BatchableContext modulosJitterbitProcesados) {

        DateTime calc_onehourAgo = System.Now().addHours(-1);

        Account cuentas = [Select Id FROM Account limit 2];
        
        return Database.getQueryLocator(            
            [SELECT Id FROM Modulo_de_paciente__c 
                WHERE Id IN ( SELECT Modulo_de_paciente__c 
                    FROM Modulo_jitterbit__c 
                    WHERE Estado_Jiterrbit__c = 'Procesado' 
                    AND LastModifiedDate >= :calc_onehourAgo )]
        );        
    }
    
    global void execute(Database.BatchableContext modulosJitterbitProcesados, List<Modulo_de_paciente__c> records){
        
        List<Modulo_de_paciente__c> mdpsToUpdate = new List<Modulo_de_paciente__c>();
            
            for(Modulo_de_paciente__c modulo_dp : records){
                Modulo_de_paciente__c newMDP = new Modulo_de_paciente__c();
                newMDP.Id = modulo_dp.Id;
                newMDP.Estado_de_modulo__c = 'Procesado';
                mdpsToUpdate.add(newMDP);
            }
            
            if(!mdpsToUpdate.isEmpty()){         
                Database.update(mdpsToUpdate, false);
            }

        System.debug(' Items con los que se va a trabajar! ' + JSON.serialize(records) );
    }
    
    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
        System.debug('Se ejecuto el batch correctamente > '+ bc.getJobId());
    } 
}