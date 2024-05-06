global with sharing class BatchCountLicenciasSchedule implements Schedulable {
    public static void execute (SchedulableContext sc) {
        BatchCountLicencias batch = new BatchCountLicencias();
        Database.executeBatch(batch);
    }
}