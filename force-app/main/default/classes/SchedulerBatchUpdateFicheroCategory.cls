public class SchedulerBatchUpdateFicheroCategory implements Schedulable{
    public void execute(SchedulableContext sc) {
        BatchUpdateFicheroCategory batch = new BatchUpdateFicheroCategory();
        Database.executeBatch(batch);
    }
}