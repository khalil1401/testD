public class SchedulerBatchSendEmailCC implements Schedulable{
    public void execute(SchedulableContext sc) {
        BatchSendEmailCC batch = new BatchSendEmailCC();
        Database.executeBatch(batch);
    }
}