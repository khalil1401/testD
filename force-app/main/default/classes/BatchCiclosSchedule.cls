global with sharing class BatchCiclosSchedule implements Schedulable{
    public static void execute (SchedulableContext sc) {
        BatchCiclos batch = new BatchCiclos();
        Database.executeBatch(batch);
    }
}