Global with sharing class BatchDeleteOldNotificationSchedule implements Schedulable{
    public static void execute (SchedulableContext sc) {
        BatchDeleteOldNotification batch = new BatchDeleteOldNotification();
        database.executebatch(batch);
    }
}