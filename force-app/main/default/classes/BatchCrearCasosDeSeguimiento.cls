global class BatchCrearCasosDeSeguimiento implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext modulosActivosVencidos) {
        
        return Database.getQueryLocator(            
            'SELECT id '+
            'FROM Account '+
            'WHERE Account.RecordType.DeveloperName= \'Paciente_Best_Care\' '+
            'AND (Relacionamiento__c= \'Alto\' OR Relacionamiento__c =\'Medio\') '+
            'AND Estado_de_paciente__c= \'En seguimiento\' '+
            'AND Dias_en_este_estado__c = 5 '+
            'AND Id NOT IN (SELECT AccountId FROM Case WHERE Subtipo__c= \'Seguimiento no renovacion\') '
        );        
    }
    
    global void execute(Database.BatchableContext modulosActivosVencidos, List<Account> records){
        
        List<Case> cases = new List<Case>();
        Id fidelizacionId = [
            SELECT Id 
            FROM Group 
            WHERE Name = 'Fidelizacion' 
            AND Type = 'Queue'
        ].Id;
        
        for(Account anAccount : records){
            Case newCase = new Case();
            newCase.accountId = anAccount.id;
            newCase.Priority = 'Media';
            newCase.RecordTypeId = XappiaHelper.getRecordType('Case', 'Retencion').id;
            newCase.Status = 'Nuevo';
            newCase.OwnerId = fidelizacionId;
            newCase.Subject = 'Nuevo seguimiento no renovacion';
            newCase.Subtipo__c ='Seguimiento no renovacion';
            newCase.Description = Label.Casos_de_seguimiento; 
            cases.add(newCase);
        }
        
        if(!cases.isEmpty()){         
            Database.insert(cases,false);
        }
    }
    
    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    } 
}