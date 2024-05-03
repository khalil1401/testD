global class EliminadorRegistrosClientesSchedule implements Schedulable {
    global void execute(SchedulableContext sc){         
        DataBase.executeBatch(new EliminadorRegistrosBatch('Clientes__c'));
    }
}