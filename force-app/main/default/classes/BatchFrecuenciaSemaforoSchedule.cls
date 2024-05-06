Global with sharing class BatchFrecuenciaSemaforoSchedule implements Schedulable{
    public static void execute (SchedulableContext sc) {
        BatchFrecuenciaSemaforo batch = new BatchFrecuenciaSemaforo();
        Database.executeBatch(batch);
    }

}