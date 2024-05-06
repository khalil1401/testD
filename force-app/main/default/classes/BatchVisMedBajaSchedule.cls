Global with sharing class BatchVisMedBajaSchedule implements Schedulable {
    public static void execute (SchedulableContext sc) {
        BatchVisMedBaja batch = new BatchVisMedBaja();
        Database.executeBatch(batch);
    }
}