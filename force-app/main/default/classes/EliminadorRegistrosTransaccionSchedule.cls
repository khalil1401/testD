global class EliminadorRegistrosTransaccionSchedule implements Schedulable{
    global void execute(SchedulableContext sc){
        DataBase.executeBatch(new EliminadorRegistrosBatch('Transaccion_de_inventario__c'));    
    }
}