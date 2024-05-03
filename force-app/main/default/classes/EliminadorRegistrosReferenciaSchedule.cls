global class EliminadorRegistrosReferenciaSchedule implements Schedulable{
    global void execute(SchedulableContext sc){         
        DataBase.executeBatch(new EliminadorRegistrosBatch('Referencia_cruzada__c'));
    }
}