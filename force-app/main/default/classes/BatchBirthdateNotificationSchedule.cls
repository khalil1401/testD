public with sharing class BatchBirthdateNotificationSchedule implements Schedulable{
    public static void execute (SchedulableContext sc) {
        BatchBirthdateNotification batch = new BatchBirthdateNotification();
        database.executebatch(batch);
    }

}