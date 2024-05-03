public class BatchUpdateEstadoMdp implements Database.Batchable<sObject> {

    public Database.QueryLocator start(Database.BatchableContext bc) {
        Date fechaAuctual = System.today();

        return Database.getQueryLocator([SELECT Id, Name, Modulo_hasta__c, Estado_de_modulo__c, Estado__c
        FROM Modulo_de_paciente__c 
        WHERE Modulo_hasta__c  < TODAY 
        AND Estado__c = 'Activo']);
    }

    public void execute(Database.BatchableContext bc, List<Modulo_de_paciente__c> scope){
        // process each batch of records
        List<Modulo_de_paciente__c> mdpToUpdate = new List<Modulo_de_paciente__c>();

        for(Modulo_de_paciente__c mdp : scope ){
            Modulo_de_paciente__c mdpUpdate = new Modulo_de_paciente__c(
                Id = mdp.Id,
                Estado__c = 'Inactivo',
                Fecha_de_despacho__c = Date.today()
            );
            mdpToUpdate.add(mdpUpdate);
        }
        update mdpToUpdate;
    }

    public void finish(Database.BatchableContext bc){}
}