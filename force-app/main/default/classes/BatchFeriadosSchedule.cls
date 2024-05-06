Global with sharing class BatchFeriadosSchedule implements Schedulable{
    
    public static void execute (SchedulableContext sc) {
        BatchFeriados batch = new BatchFeriados();
        Database.executeBatch(batch);
    }

}