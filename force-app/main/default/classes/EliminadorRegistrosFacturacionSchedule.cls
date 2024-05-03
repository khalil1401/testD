global class EliminadorRegistrosFacturacionSchedule implements Schedulable{
    global void execute(SchedulableContext sc){         
        DataBase.executeBatch(new EliminadorRegistrosBatch('Facturacion__c'));
    }
}