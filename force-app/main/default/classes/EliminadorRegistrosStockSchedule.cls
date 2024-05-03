global class EliminadorRegistrosStockSchedule implements Schedulable{
    
    global void execute(SchedulableContext sc){
         DataBase.executeBatch(new EliminadorRegistrosBatch('Stock__c'));
    }

}