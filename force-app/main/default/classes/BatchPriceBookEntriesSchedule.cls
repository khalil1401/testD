public with sharing class BatchPriceBookEntriesSchedule implements Schedulable {
    public static void execute (SchedulableContext sc) {
        BatchPriceBookEntries batch = new BatchPriceBookEntries();
        Database.executeBatch(batch);
    }
}