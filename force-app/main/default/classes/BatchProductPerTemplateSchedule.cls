public with sharing class BatchProductPerTemplateSchedule implements Schedulable {
    public static void execute (SchedulableContext sc) {
        BatchProductPerTemplate batch = new BatchProductPerTemplate();
        Database.executeBatch(batch);
    }
}