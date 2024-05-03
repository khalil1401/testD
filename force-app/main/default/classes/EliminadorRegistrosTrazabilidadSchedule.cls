global class EliminadorRegistrosTrazabilidadSchedule implements Schedulable{
    global void execute(SchedulableContext sc){
        DataBase.executeBatch(new EliminadorRegistrosBatch('Trazabilidad_de_Pedido__c'));    
    }
}