global class EliminadorRegistrosProductoSchedule implements Schedulable{
    global void execute(SchedulableContext sc){         
        DataBase.executeBatch(new EliminadorRegistrosBatch('Producto__c'));
    }
}