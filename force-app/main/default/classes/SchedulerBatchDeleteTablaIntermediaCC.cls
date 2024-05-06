global class SchedulerBatchDeleteTablaIntermediaCC implements Schedulable{
    global void execute(SchedulableContext sc){
        BatchDeleteTablaIntermediaCC batch = new BatchDeleteTablaIntermediaCC();
        ID batchId = Database.executeBatch(batch);
    }
}